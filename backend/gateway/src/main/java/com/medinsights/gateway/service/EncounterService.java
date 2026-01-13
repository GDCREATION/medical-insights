package com.medinsights.gateway.service;

import com.medinsights.gateway.entity.*;
import com.medinsights.gateway.model.SymptomPayload;
import com.medinsights.gateway.model.TriageRequest;
import com.medinsights.gateway.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EncounterService {

    private final EncounterRepository encounterRepository;
    private final PatientRepository patientRepository;
    private final SymptomPayloadRepository symptomPayloadRepository;
    private final TriageResultRepository triageResultRepository;
    private final ClinicianReviewRepository clinicianReviewRepository;
    private final EncounterEventRepository encounterEventRepository;
    private final AgentClient agentClient;

    @Transactional
    public com.medinsights.gateway.entity.Encounter createEncounter(String patientId, String consentToken, String sourceChannel) {
        // Verify patient exists
        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new IllegalArgumentException("Patient not found: " + patientId));

        String encounterId = UUID.randomUUID().toString();
        String encounterRef = "ENC-" + System.currentTimeMillis();

        com.medinsights.gateway.entity.Encounter encounter = com.medinsights.gateway.entity.Encounter.builder()
                .id(encounterId)
                .patient(patient)
                .consentToken(consentToken)
                .encounterRef(encounterRef)
                .status("created")
                .sourceChannel(sourceChannel)
                .createdAt(OffsetDateTime.now())
                .updatedAt(OffsetDateTime.now())
                .build();

        encounter = encounterRepository.save(encounter);

        // Log event
        logEvent(encounterId, "encounter_created", null, Map.of("source_channel", sourceChannel != null ? sourceChannel : "unknown"));

        return encounter;
    }

    @Transactional
    public void addSymptoms(String encounterId, SymptomPayload symptomPayload) {
        com.medinsights.gateway.entity.Encounter encounter = encounterRepository.findById(encounterId)
                .orElseThrow(() -> new IllegalArgumentException("Encounter not found: " + encounterId));

        // Convert DTO to entity
        Map<String, Object> symptomsJson = Map.of("symptoms", symptomPayload.getSymptoms());
        Map<String, Object> vitalsJson = symptomPayload.getVitals() != null ? symptomPayload.getVitals() : Map.of();
        Map<String, Object> riskFactorsJson = symptomPayload.getRiskFactors() != null ? symptomPayload.getRiskFactors() : Map.of();

        com.medinsights.gateway.entity.SymptomPayload entity = com.medinsights.gateway.entity.SymptomPayload.builder()
                .encounterId(encounterId)
                .encounter(encounter)
                .symptomsJson(symptomsJson)
                .vitalsJson(vitalsJson)
                .riskFactorsJson(riskFactorsJson)
                .freeText(symptomPayload.getFreeText())
                .pregnancyFlag(symptomPayload.getPregnancyFlag() != null ? symptomPayload.getPregnancyFlag() : false)
                .languageCode("en")
                .capturedAt(OffsetDateTime.now())
                .build();

        symptomPayloadRepository.save(entity);

        // Update encounter status
        encounter.setStatus("symptoms_captured");
        encounterRepository.save(encounter);

        // Log event
        logEvent(encounterId, "symptoms_captured", null, Map.of());
    }

    @Transactional
    public TriageResult performTriage(String encounterId, String traceId) {
        com.medinsights.gateway.entity.Encounter encounter = encounterRepository.findById(encounterId)
                .orElseThrow(() -> new IllegalArgumentException("Encounter not found: " + encounterId));

        com.medinsights.gateway.entity.SymptomPayload symptomPayload = symptomPayloadRepository.findByEncounterId(encounterId)
                .orElseThrow(() -> new IllegalArgumentException("Symptoms not captured for encounter: " + encounterId));

        // Convert entity to DTO for agent call
        SymptomPayload dto = new SymptomPayload();
        if (symptomPayload.getSymptomsJson() != null && symptomPayload.getSymptomsJson().containsKey("symptoms")) {
            @SuppressWarnings("unchecked")
            List<String> symptoms = (List<String>) symptomPayload.getSymptomsJson().get("symptoms");
            dto.setSymptoms(symptoms);
        } else {
            dto.setSymptoms(List.of()); // Empty list if no symptoms
        }
        dto.setFreeText(symptomPayload.getFreeText());
        dto.setVitals(symptomPayload.getVitalsJson());
        dto.setRiskFactors(symptomPayload.getRiskFactorsJson());
        dto.setPregnancyFlag(symptomPayload.getPregnancyFlag());

        TriageRequest request = new TriageRequest();
        request.setEncounterRef(encounter.getEncounterRef());
        request.setSymptoms(dto);

        // Call agent service
        com.medinsights.gateway.model.Encounter.TriageResult agentResult = agentClient.triage(request, traceId);

        // Convert agent result to entity
        TriageResult triageResult = TriageResult.builder()
                .encounterId(encounterId)
                .encounter(encounter)
                .acuity(agentResult.getAcuity())
                .emergencyFlag(agentResult.isEmergencyFlag())
                .confidenceScore(agentResult.getConfidenceScore() != null ? agentResult.getConfidenceScore().floatValue() : null)
                .rationaleInternal(agentResult.getRationale())
                .clarifyingQuestions(agentResult.getClarifyingQuestions() != null ? 
                        String.join("\n", agentResult.getClarifyingQuestions()) : null)
                .summaryForClinician(agentResult.getSummaryForClinician())
                .safetyWarnings(agentResult.getSafetyWarnings())
                .modelVersion(agentResult.getModelVersion())
                .adapterVersion(agentResult.getAdapterVersion())
                .ruleVersion(agentResult.getRuleVersion())
                .traceId(traceId)
                .createdAt(OffsetDateTime.now())
                .build();

        triageResult = triageResultRepository.save(triageResult);

        // Update encounter status
        encounter.setStatus("triaged");
        encounterRepository.save(encounter);

        // Log event
        logEvent(encounterId, "triage_completed", null, Map.of("trace_id", traceId != null ? traceId : ""));

        return triageResult;
    }

    @Transactional
    public ClinicianReview addClinicianReview(String encounterId, String decision, Boolean overrideFlag, 
                                             String overrideReason, String notes, String reviewerId) {
        com.medinsights.gateway.entity.Encounter encounter = encounterRepository.findById(encounterId)
                .orElseThrow(() -> new IllegalArgumentException("Encounter not found: " + encounterId));

        ClinicianReview review = ClinicianReview.builder()
                .encounterId(encounterId)
                .encounter(encounter)
                .decision(decision)
                .overrideFlag(overrideFlag != null ? overrideFlag : false)
                .overrideReason(overrideReason)
                .notes(notes)
                .reviewerId(reviewerId)
                .reviewedAt(OffsetDateTime.now())
                .build();

        review = clinicianReviewRepository.save(review);

        // Update encounter status
        encounter.setStatus("reviewed");
        if ("completed".equals(decision) || "approved".equals(decision)) {
            encounter.setStatus("completed");
        }
        encounterRepository.save(encounter);

        // Log event
        logEvent(encounterId, "clinician_review_completed", reviewerId, Map.of("decision", decision));

        return review;
    }

    public com.medinsights.gateway.entity.Encounter getEncounter(String encounterId) {
        return encounterRepository.findById(encounterId)
                .orElseThrow(() -> new IllegalArgumentException("Encounter not found: " + encounterId));
    }

    public List<com.medinsights.gateway.entity.Encounter> getEncountersByPatient(String patientId) {
        return encounterRepository.findByPatientId(patientId);
    }

    public List<com.medinsights.gateway.entity.Encounter> getEncountersByStatus(String status) {
        return encounterRepository.findByStatus(status);
    }

    public List<EncounterEvent> getEncounterEvents(String encounterId) {
        return encounterEventRepository.findByEncounterIdOrderByCreatedAtDesc(encounterId);
    }

    private void logEvent(String encounterId, String eventType, String actor, Map<String, Object> details) {
        com.medinsights.gateway.entity.Encounter encounter = encounterRepository.findById(encounterId)
                .orElse(null);
        
        if (encounter == null) {
            return; // Silently fail if encounter doesn't exist
        }

        EncounterEvent event = EncounterEvent.builder()
                .encounter(encounter)
                .eventType(eventType)
                .actor(actor)
                .detailsJson(details)
                .createdAt(OffsetDateTime.now())
                .build();

        encounterEventRepository.save(event);
    }
}
