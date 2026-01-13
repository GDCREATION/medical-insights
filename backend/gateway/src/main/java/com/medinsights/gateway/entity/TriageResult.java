package com.medinsights.gateway.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Entity
@Table(name = "triage_results")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TriageResult {
    @Id
    @Column(name = "encounter_id", length = 255)
    private String encounterId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "encounter_id", foreignKey = @ForeignKey(name = "fk_triage_results_encounter_id"))
    @MapsId
    private Encounter encounter;

    @Column(name = "acuity", nullable = false, length = 50)
    private String acuity;

    @Column(name = "emergency_flag", nullable = false)
    @Builder.Default
    private Boolean emergencyFlag = false;

    @Column(name = "confidence_score")
    private Float confidenceScore;

    @Column(name = "rationale_internal", columnDefinition = "TEXT")
    private String rationaleInternal;

    @Column(name = "clarifying_questions", columnDefinition = "TEXT")
    private String clarifyingQuestions;

    @Column(name = "summary_for_clinician", columnDefinition = "TEXT")
    private String summaryForClinician;

    @Column(name = "safety_warnings", columnDefinition = "TEXT")
    private String safetyWarnings;

    @Column(name = "model_version", length = 100)
    private String modelVersion;

    @Column(name = "adapter_version", length = 100)
    private String adapterVersion;

    @Column(name = "rule_version", length = 100)
    private String ruleVersion;

    @Column(name = "trace_id", length = 255)
    private String traceId;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private OffsetDateTime createdAt = OffsetDateTime.now();
}
