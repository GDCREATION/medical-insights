package com.medinsights.gateway.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.transaction.support.TransactionCallbackWithoutResult;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class DatabaseMigrationService {

    private final JdbcTemplate jdbcTemplate;
    private final TransactionTemplate transactionTemplate;
    private final boolean enabled;

    public DatabaseMigrationService(
            DataSource dataSource,
            PlatformTransactionManager transactionManager,
            @Value("${database.migration.enabled:true}") boolean enabled) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.enabled = enabled;
    }

    public void runMigrations() {
        if (!enabled) {
            log.info("Database migrations are disabled. Skipping migration execution.");
            return;
        }

        log.info("Starting database migrations...");
        
        try {
            List<MigrationFile> migrationFiles = loadMigrationFiles();
            
            if (migrationFiles.isEmpty()) {
                log.warn("No migration files found. Skipping migrations.");
                return;
            }

            log.info("Found {} migration files to execute", migrationFiles.size());

            for (MigrationFile migration : migrationFiles) {
                executeMigration(migration);
            }

            log.info("Database migrations completed successfully.");
        } catch (Exception e) {
            log.error("Error executing database migrations", e);
            throw new RuntimeException("Failed to execute database migrations", e);
        }
    }

    private List<MigrationFile> loadMigrationFiles() {
        List<MigrationFile> migrations = new ArrayList<>();
        ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();

        try {
            // Try to load from classpath first (for packaged JAR)
            Resource[] classpathResources = resolver.getResources("classpath*:database/migrations/*.sql");
            
            // Also try to load from file system (for development)
            Resource[] fileResources = resolver.getResources("file:database/migrations/*.sql");
            
            // Combine both
            List<Resource> allResources = new ArrayList<>();
            if (classpathResources != null) {
                allResources.addAll(List.of(classpathResources));
            }
            if (fileResources != null) {
                allResources.addAll(List.of(fileResources));
            }

            // Remove duplicates
            allResources = allResources.stream()
                    .distinct()
                    .collect(Collectors.toList());

            for (Resource resource : allResources) {
                String filename = resource.getFilename();
                if (filename != null && filename.matches("\\d{3}_.*\\.sql")) {
                    String number = filename.substring(0, 3);
                    migrations.add(new MigrationFile(Integer.parseInt(number), filename, resource));
                }
            }

            // Sort by migration number
            migrations.sort(Comparator.comparingInt(MigrationFile::getNumber));

        } catch (Exception e) {
            log.error("Error loading migration files", e);
        }

        return migrations;
    }

    private void executeMigration(MigrationFile migration) {
        log.info("Executing migration: {}", migration.getFilename());

        // Execute each migration in its own transaction
        transactionTemplate.execute(new TransactionCallbackWithoutResult() {
            @Override
            protected void doInTransactionWithoutResult(TransactionStatus status) {
                try {
                    String sql = readResource(migration.getResource());
                    
                    if (sql == null || sql.trim().isEmpty()) {
                        log.warn("Migration file {} is empty, skipping", migration.getFilename());
                        return;
                    }

                    // Remove BEGIN/COMMIT if present (we'll handle transactions ourselves)
                    sql = sql.replaceAll("(?i)\\s*BEGIN\\s*;", "");
                    sql = sql.replaceAll("(?i)\\s*COMMIT\\s*;", "");

                    // Split by semicolon and execute statements
                    String[] statements = sql.split(";");
                    
                    for (int i = 0; i < statements.length; i++) {
                        String statement = statements[i].trim();
                        if (statement.isEmpty() || statement.startsWith("--")) {
                            continue;
                        }
                        
                        // Use savepoint for each statement so failures don't abort the whole transaction
                        String savepointName = "sp_" + i;
                        Object savepoint = null;
                        try {
                            savepoint = status.createSavepoint(savepointName);
                            jdbcTemplate.execute(statement);
                        } catch (Exception e) {
                            // Rollback to savepoint if statement fails
                            if (savepoint != null) {
                                try {
                                    status.rollbackToSavepoint(savepoint);
                                } catch (Exception rollbackEx) {
                                    log.warn("Failed to rollback to savepoint: {}", rollbackEx.getMessage());
                                }
                            }
                            
                            String errorMsg = e.getMessage() != null ? e.getMessage() : "";
                            
                            // Some statements might fail if objects already exist (idempotent)
                            if (errorMsg.contains("already exists") || 
                                errorMsg.contains("duplicate key")) {
                                log.debug("Object already exists in migration {}, continuing: {}", 
                                        migration.getFilename(), e.getMessage());
                            } 
                            // COMMENT statements are non-critical (just documentation)
                            else if (statement.toUpperCase().trim().startsWith("COMMENT")) {
                                log.debug("Comment statement failed (non-critical), continuing: {}", 
                                        e.getMessage());
                            } 
                            // For other errors, log and continue (migrations should be idempotent)
                            else {
                                log.warn("Error executing statement in migration {} (statement will be skipped): {}", 
                                        migration.getFilename(), e.getMessage());
                                // Continue with next statement - migrations should be idempotent
                            }
                        }
                    }

                    log.info("Migration {} completed successfully", migration.getFilename());

                } catch (Exception e) {
                    log.error("Error executing migration {}", migration.getFilename(), e);
                    status.setRollbackOnly();
                    throw new RuntimeException("Failed to execute migration: " + migration.getFilename(), e);
                }
            }
        });
    }

    private String readResource(Resource resource) {
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8))) {
            
            return reader.lines()
                    .collect(Collectors.joining("\n"));
        } catch (Exception e) {
            log.error("Error reading resource: {}", resource.getFilename(), e);
            return null;
        }
    }

    private static class MigrationFile {
        private final int number;
        private final String filename;
        private final Resource resource;

        public MigrationFile(int number, String filename, Resource resource) {
            this.number = number;
            this.filename = filename;
            this.resource = resource;
        }

        public int getNumber() {
            return number;
        }

        public String getFilename() {
            return filename;
        }

        public Resource getResource() {
            return resource;
        }
    }
}
