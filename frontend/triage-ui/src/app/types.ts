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
  confidenceScore?: number | null;
  rationaleInternal?: string;
  clarifyingQuestions?: string; // Now a string, not array
  summaryForClinician?: string;
  safetyWarnings?: string;
  modelVersion?: string;
  adapterVersion?: string;
  ruleVersion?: string;
  traceId?: string;
}

export interface EncounterResponse {
  encounterId: string;
  createdAt: string;
}

export interface ClinicianReviewPayload {
  decision: string; // 'approved' | 'overridden' | 'rejected' | 'needs_more_info'
  overrideFlag?: boolean;
  overrideReason?: string;
  notes?: string;
  reviewerId: string;
}
