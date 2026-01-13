package com.medinsights.gateway.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Entity
@Table(name = "encounters")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Encounter {
    @Id
    @Column(name = "id", length = 255)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false, foreignKey = @ForeignKey(name = "fk_encounters_patient_id"))
    private Patient patient;

    @Column(name = "consent_token", nullable = false, length = 255)
    private String consentToken;

    @Column(name = "encounter_ref", unique = true, length = 255)
    private String encounterRef;

    @Column(name = "status", nullable = false, length = 50)
    @Builder.Default
    private String status = "created";

    @Column(name = "source_channel", length = 100)
    private String sourceChannel;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private OffsetDateTime createdAt = OffsetDateTime.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    @Column(name = "expires_at")
    private OffsetDateTime expiresAt;

    @OneToOne(mappedBy = "encounter", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private SymptomPayload symptomPayload;

    @OneToOne(mappedBy = "encounter", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private TriageResult triageResult;

    @OneToOne(mappedBy = "encounter", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private ClinicianReview clinicianReview;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
