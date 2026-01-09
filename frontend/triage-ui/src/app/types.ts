export interface SymptomPayload {
  symptoms: string[];
  freeText?: string;
  vitals?: Record<string, unknown>;
  riskFactors?: Record<string, unknown>;
  pregnancyFlag?: boolean | null;
}

export interface TriageResult {
  acuity: string;
  emergencyFlag: boolean;
  rationale: string;
  clarifyingQuestions: string[];
  summaryForClinician: string;
  safetyWarnings: string;
  modelVersion?: string;
  adapterVersion?: string;
  ruleVersion?: string;
  traceId?: string;
}

