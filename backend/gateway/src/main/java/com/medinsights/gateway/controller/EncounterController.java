package com.medinsights.gateway.controller;

import com.medinsights.gateway.entity.Encounter;
import com.medinsights.gateway.entity.TriageResult;
import com.medinsights.gateway.entity.ClinicianReview;
import com.medinsights.gateway.model.SymptomPayload;
import com.medinsights.gateway.service.EncounterService;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EncounterController {

    private final EncounterService encounterService;

    @PostMapping("/encounters")
    public ResponseEntity<EncounterResponse> createEncounter(
            @RequestBody @Valid EncounterCreateRequest request,
            @RequestHeader(value = "X-Source-Channel", required = false) String sourceChannel) {
        Encounter encounter = encounterService.createEncounter(
                request.getPatientId(),
                request.getConsentToken(),
                sourceChannel
        );
        return ResponseEntity.ok(new EncounterResponse(
                encounter.getId(),
                encounter.getCreatedAt().toString()
        ));
    }

    @PostMapping("/encounters/{id}/symptoms")
    public ResponseEntity<?> addSymptoms(
            @PathVariable("id") String id,
            @RequestBody @Valid SymptomPayload payload) {
        encounterService.addSymptoms(id, payload);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/encounters/{id}/triage")
    public ResponseEntity<TriageResultResponse> triage(
            @PathVariable("id") String id,
            @RequestHeader(value = "X-Trace-Id", required = false) String traceId) {
        TriageResult triageResult = encounterService.performTriage(
                id,
                traceId != null ? traceId : UUID.randomUUID().toString()
        );
        return ResponseEntity.ok(TriageResultResponse.fromEntity(triageResult));
    }

    @PostMapping("/encounters/{id}/clinician-review")
    public ResponseEntity<?> clinicianReview(
            @PathVariable("id") String id,
            @RequestBody @Valid ClinicianReviewPayload payload) {
        encounterService.addClinicianReview(
                id,
                payload.getDecision(),
                payload.getOverrideFlag(),
                payload.getOverrideReason(),
                payload.getNotes(),
                payload.getReviewerId()
        );
        return ResponseEntity.accepted().build();
    }

    @GetMapping("/encounters/{id}")
    public ResponseEntity<EncounterResponse> getEncounter(@PathVariable("id") String id) {
        Encounter encounter = encounterService.getEncounter(id);
        return ResponseEntity.ok(new EncounterResponse(
                encounter.getId(),
                encounter.getCreatedAt().toString()
        ));
    }

    @GetMapping("/encounters/patient/{patientId}")
    public ResponseEntity<List<EncounterResponse>> getEncountersByPatient(@PathVariable("patientId") String patientId) {
        List<Encounter> encounters = encounterService.getEncountersByPatient(patientId);
        List<EncounterResponse> responses = encounters.stream()
                .map(e -> new EncounterResponse(e.getId(), e.getCreatedAt().toString()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @Data
    public static class EncounterCreateRequest {
        private String patientId;
        private String consentToken;
    }

    @Data
    public static class EncounterResponse {
        private final String encounterId;
        private final String createdAt;
    }

    @Data
    public static class TriageResultResponse {
        private String acuity;
        private Boolean emergencyFlag;
        private Float confidenceScore;
        private String rationaleInternal;
        private String clarifyingQuestions;
        private String summaryForClinician;
        private String safetyWarnings;
        private String modelVersion;
        private String adapterVersion;
        private String ruleVersion;
        private String traceId;

        public static TriageResultResponse fromEntity(TriageResult entity) {
            TriageResultResponse response = new TriageResultResponse();
            response.setAcuity(entity.getAcuity());
            response.setEmergencyFlag(entity.getEmergencyFlag());
            response.setConfidenceScore(entity.getConfidenceScore());
            response.setRationaleInternal(entity.getRationaleInternal());
            response.setClarifyingQuestions(entity.getClarifyingQuestions());
            response.setSummaryForClinician(entity.getSummaryForClinician());
            response.setSafetyWarnings(entity.getSafetyWarnings());
            response.setModelVersion(entity.getModelVersion());
            response.setAdapterVersion(entity.getAdapterVersion());
            response.setRuleVersion(entity.getRuleVersion());
            response.setTraceId(entity.getTraceId());
            return response;
        }
    }

    @Data
    public static class ClinicianReviewPayload {
        private String decision;
        private Boolean overrideFlag;
        private String overrideReason;
        private String notes;
        private String reviewerId;
    }
}

