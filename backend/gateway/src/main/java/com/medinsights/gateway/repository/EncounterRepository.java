package com.medinsights.gateway.repository;

import com.medinsights.gateway.entity.Encounter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EncounterRepository extends JpaRepository<Encounter, String> {
    Optional<Encounter> findById(String id);
    
    @Query("SELECT e FROM Encounter e WHERE e.patient.patientId = :patientId")
    List<Encounter> findByPatientId(@Param("patientId") String patientId);
    
    List<Encounter> findByStatus(String status);
    
    @Query("SELECT e FROM Encounter e WHERE e.patient.patientId = :patientId AND e.status = :status")
    List<Encounter> findByPatientIdAndStatus(@Param("patientId") String patientId, @Param("status") String status);
    
    Optional<Encounter> findByEncounterRef(String encounterRef);
}
