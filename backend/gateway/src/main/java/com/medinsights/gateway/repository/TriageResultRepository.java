package com.medinsights.gateway.repository;

import com.medinsights.gateway.entity.TriageResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TriageResultRepository extends JpaRepository<TriageResult, String> {
    Optional<TriageResult> findByEncounterId(String encounterId);
    
    List<TriageResult> findByEmergencyFlagTrue();
    
    List<TriageResult> findByAcuity(String acuity);
}
