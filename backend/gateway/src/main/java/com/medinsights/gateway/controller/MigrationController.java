package com.medinsights.gateway.controller;

import com.medinsights.gateway.service.DatabaseMigrationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class MigrationController {

    private final DatabaseMigrationService migrationService;

    @PostMapping("/migrations/run")
    public ResponseEntity<String> runMigrations() {
        try {
            migrationService.runMigrations();
            return ResponseEntity.ok("Migrations executed successfully");
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body("Failed to execute migrations: " + e.getMessage());
        }
    }
}
