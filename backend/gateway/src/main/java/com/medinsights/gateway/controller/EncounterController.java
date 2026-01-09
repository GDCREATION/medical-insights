package com.medinsights.gateway.controller;

import com.medinsights.gateway.model.Encounter;
import com.medinsights.gateway.model.SymptomPayload;
import com.medinsights.gateway.model.TriageRequest;
import com.medinsights.gateway.service.AgentClient;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EncounterController {

    private final AgentClient agentClient;
    private final Map<UUID, Encounter> store = new ConcurrentHashMap<>();

    @PostMapping("/encounters")
    public ResponseEntity<EncounterResponse> createEncounter(@RequestBody @Valid EncounterCreateRequest request) {
        UUID id = UUID.randomUUID();
        Encounter encounter = Encounter.builder()
                .id(id)
                .patientId(request.getPatientId())
                .consentToken(request.getConsentToken())
                .build();
        store.put(id, encounter);
        return ResponseEntity.ok(new EncounterResponse(id.toString(), Instant.now().toString()));
    }

    @PostMapping("/encounters/{id}/symptoms")
    public ResponseEntity<?> addSymptoms(@PathVariable("id") UUID id, @RequestBody @Valid SymptomPayload payload) {
        Encounter encounter = requireEncounter(id);
        encounter.setSymptoms(payload);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/encounters/{id}/triage")
    public ResponseEntity<Encounter.TriageResult> triage(@PathVariable("id") UUID id, @RequestHeader(value = "X-Trace-Id", required = false) String traceId) {
        Encounter encounter = requireEncounter(id);
        if (encounter.getSymptoms() == null) {
            return ResponseEntity.badRequest().build();
        }
        TriageRequest request = new TriageRequest();
        request.setEncounterRef(id.toString());
        request.setSymptoms(encounter.getSymptoms());
        Encounter.TriageResult triageResult = agentClient.triage(request, traceId == null ? UUID.randomUUID().toString() : traceId);
        encounter.setTriageResult(triageResult);
        return ResponseEntity.ok(triageResult);
    }

    @PostMapping("/encounters/{id}/clinician-review")
    public ResponseEntity<?> clinicianReview(@PathVariable("id") UUID id, @RequestBody @Valid ClinicianReviewPayload payload) {
        Encounter encounter = requireEncounter(id);
        encounter.setClinicianReview(Encounter.ClinicianReview.builder()
                .decision(payload.getDecision())
                .notes(payload.getNotes())
                .reviewer(payload.getReviewer())
                .build());
        return ResponseEntity.accepted().build();
    }

    private Encounter requireEncounter(UUID id) {
        Encounter encounter = store.get(id);
        if (encounter == null) {
            throw new EncounterNotFoundException("Encounter not found: " + id);
        }
        return encounter;
    }

    @ResponseStatus(code = org.springframework.http.HttpStatus.NOT_FOUND)
    private static class EncounterNotFoundException extends RuntimeException {
        EncounterNotFoundException(String msg) {
            super(msg);
        }
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
    public static class ClinicianReviewPayload {
        private String decision;
        private String notes;
        private String reviewer;
    }
}

