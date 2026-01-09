package com.medinsights.gateway.model;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class Encounter {
    private UUID id;
    private String patientId;
    private String consentToken;
    private SymptomPayload symptoms;
    private TriageResult triageResult;
    private ClinicianReview clinicianReview;

    @Data
    @Builder
    public static class ClinicianReview {
        private String decision; // approved|overridden
        private String notes;
        private String reviewer;
    }

    @Data
    @Builder
    public static class TriageResult {
        private String acuity;
        private boolean emergencyFlag;
        private String rationale;
        private List<String> clarifyingQuestions;
        private String summaryForClinician;
        private String safetyWarnings;
        private String modelVersion;
        private String adapterVersion;
        private String ruleVersion;
        private String traceId;
    }
}

