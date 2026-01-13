package com.medinsights.gateway.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.OffsetDateTime;
import java.util.Map;

@Entity
@Table(name = "symptom_payloads")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SymptomPayload {
    @Id
    @Column(name = "encounter_id", length = 255)
    private String encounterId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "encounter_id", foreignKey = @ForeignKey(name = "fk_symptom_payloads_encounter_id"))
    @MapsId
    private Encounter encounter;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "symptoms_json", columnDefinition = "jsonb")
    private Map<String, Object> symptomsJson;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "vitals_json", columnDefinition = "jsonb")
    private Map<String, Object> vitalsJson;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "risk_factors_json", columnDefinition = "jsonb")
    private Map<String, Object> riskFactorsJson;

    @Column(name = "free_text", columnDefinition = "TEXT")
    private String freeText;

    @Column(name = "pregnancy_flag")
    @Builder.Default
    private Boolean pregnancyFlag = false;

    @Column(name = "language_code", length = 10)
    @Builder.Default
    private String languageCode = "en";

    @Column(name = "captured_at", nullable = false)
    @Builder.Default
    private OffsetDateTime capturedAt = OffsetDateTime.now();
}
