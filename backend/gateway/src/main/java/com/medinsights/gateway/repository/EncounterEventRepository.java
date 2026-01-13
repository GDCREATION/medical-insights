package com.medinsights.gateway.repository;

import com.medinsights.gateway.entity.EncounterEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EncounterEventRepository extends JpaRepository<EncounterEvent, Long> {
    @Query("SELECT e FROM EncounterEvent e WHERE e.encounter.id = :encounterId")
    List<EncounterEvent> findByEncounterId(@Param("encounterId") String encounterId);
    
    List<EncounterEvent> findByEventType(String eventType);
    
    @Query("SELECT e FROM EncounterEvent e WHERE e.encounter.id = :encounterId ORDER BY e.createdAt DESC")
    List<EncounterEvent> findByEncounterIdOrderByCreatedAtDesc(@Param("encounterId") String encounterId);
}
