package com.medinsights.gateway.repository;

import com.medinsights.gateway.entity.ClinicianReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClinicianReviewRepository extends JpaRepository<ClinicianReview, String> {
    Optional<ClinicianReview> findByEncounterId(String encounterId);
    
    List<ClinicianReview> findByDecision(String decision);
    
    List<ClinicianReview> findByReviewerId(String reviewerId);
}
