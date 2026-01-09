package com.medinsights.gateway.model;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class SymptomPayload {
    @NotEmpty
    private List<String> symptoms;
    private String freeText;
    private Map<String, Object> vitals;
    private Map<String, Object> riskFactors;
    private Boolean pregnancyFlag;
}

