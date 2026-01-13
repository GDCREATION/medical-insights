package com.medinsights.gateway.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Entity
@Table(name = "clinician_reviews")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClinicianReview {
    @Id
    @Column(name = "encounter_id", length = 255)
    private String encounterId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "encounter_id", foreignKey = @ForeignKey(name = "fk_clinician_reviews_encounter_id"))
    @MapsId
    private Encounter encounter;

    @Column(name = "decision", nullable = false, length = 50)
    private String decision;

    @Column(name = "override_flag", nullable = false)
    @Builder.Default
    private Boolean overrideFlag = false;

    @Column(name = "override_reason", columnDefinition = "TEXT")
    private String overrideReason;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "reviewer_id", nullable = false, length = 255)
    private String reviewerId;

    @Column(name = "reviewed_at", nullable = false)
    @Builder.Default
    private OffsetDateTime reviewedAt = OffsetDateTime.now();
}
