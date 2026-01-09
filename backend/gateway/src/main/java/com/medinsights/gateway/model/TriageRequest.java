package com.medinsights.gateway.model;

import lombok.Data;

@Data
public class TriageRequest {
    private String encounterRef;
    private SymptomPayload symptoms;
}

