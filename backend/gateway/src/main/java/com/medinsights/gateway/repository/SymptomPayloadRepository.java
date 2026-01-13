package com.medinsights.gateway.repository;

import com.medinsights.gateway.entity.SymptomPayload;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SymptomPayloadRepository extends JpaRepository<SymptomPayload, String> {
    Optional<SymptomPayload> findByEncounterId(String encounterId);
}
