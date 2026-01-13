package com.medinsights.gateway.service;

import com.medinsights.gateway.model.Encounter;
import com.medinsights.gateway.model.TriageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Objects;

@Component
@RequiredArgsConstructor
public class AgentClient {

    private final RestTemplate restTemplate;

    @Value("${agent.url:http://agent:8000}")
    private String agentUrl;

    public Encounter.TriageResult triage(TriageRequest request, String traceId) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.add("X-Trace-Id", traceId);
        HttpEntity<TriageRequest> entity = new HttpEntity<>(request, headers);
        Encounter.TriageResult result = restTemplate.postForObject(agentUrl + "/triage", entity, Encounter.TriageResult.class);
        return Objects.requireNonNullElse(result, Encounter.TriageResult.builder()
                .acuity("unknown")
                .emergencyFlag(false)
                .confidenceScore(0.0)
                .rationale("Agent unreachable; fallback response")
                .summaryForClinician("Agent unavailable. Please proceed with clinician assessment.")
                .safetyWarnings("No AI decision. Manual review required.")
                .build());
    }
}

