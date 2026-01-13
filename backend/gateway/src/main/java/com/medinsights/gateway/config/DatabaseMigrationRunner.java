package com.medinsights.gateway.config;

import com.medinsights.gateway.service.DatabaseMigrationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;

import javax.sql.DataSource;

@Slf4j
@Configuration
@ConditionalOnProperty(name = "database.migration.run-on-startup", havingValue = "true", matchIfMissing = true)
public class DatabaseMigrationRunner {

    @Bean
    @DependsOn("dataSource")
    public Object migrationInitializer(
            DataSource dataSource,
            DatabaseMigrationService migrationService) {
        log.info("Application starting - executing database migrations before JPA initialization...");
        try {
            migrationService.runMigrations();
            log.info("Database migrations completed successfully on startup.");
        } catch (Exception e) {
            log.error("Failed to execute database migrations on startup", e);
            throw new RuntimeException("Database migrations failed. Application cannot start.", e);
        }
        // Return a marker object to ensure this bean is created
        return new Object();
    }
}
