-- Migration: 004_create_triage_results.sql
-- Description: Creates the TRIAGE_RESULTS table with foreign key to ENCOUNTERS
-- Created: 2024

BEGIN;

-- Create TRIAGE_RESULTS table
CREATE TABLE IF NOT EXISTS triage_results (
    encounter_id VARCHAR(255) PRIMARY KEY,
    acuity VARCHAR(50) NOT NULL,
    emergency_flag BOOLEAN NOT NULL DEFAULT false,
    confidence_score REAL,
    rationale_internal TEXT,
    clarifying_questions TEXT,
    summary_for_clinician TEXT,
    safety_warnings TEXT,
    model_version VARCHAR(100),
    adapter_version VARCHAR(100),
    rule_version VARCHAR(100),
    trace_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_triage_results_encounter_id 
        FOREIGN KEY (encounter_id) 
        REFERENCES encounters(id) 
        ON DELETE CASCADE,
    
    -- Check constraint for acuity values
    CONSTRAINT chk_triage_results_acuity 
        CHECK (acuity IN ('emergent', 'urgent', 'routine', 'non_urgent')),
    
    -- Check constraint for confidence_score range
    CONSTRAINT chk_triage_results_confidence_score 
        CHECK (confidence_score IS NULL OR (confidence_score >= 0.0 AND confidence_score <= 1.0))
);

-- Add table comment
COMMENT ON TABLE triage_results IS 'Stores AI-generated triage results with acuity level, emergency flags, and clinical summaries';

-- Add column comments
COMMENT ON COLUMN triage_results.encounter_id IS 'Primary key: Foreign key to encounters.id';
COMMENT ON COLUMN triage_results.acuity IS 'Triage acuity level (emergent, urgent, routine, non_urgent)';
COMMENT ON COLUMN triage_results.emergency_flag IS 'Flag indicating if this is an emergency situation requiring immediate attention';
COMMENT ON COLUMN triage_results.confidence_score IS 'Confidence score of the triage result (0.0 to 1.0)';
COMMENT ON COLUMN triage_results.rationale_internal IS 'Internal rationale for the triage decision (for system use)';
COMMENT ON COLUMN triage_results.clarifying_questions IS 'Suggested clarifying questions to gather more information';
COMMENT ON COLUMN triage_results.summary_for_clinician IS 'Summary of the triage result for clinician review';
COMMENT ON COLUMN triage_results.safety_warnings IS 'Safety warnings or alerts for the clinician';
COMMENT ON COLUMN triage_results.model_version IS 'Version of the AI model used for triage';
COMMENT ON COLUMN triage_results.adapter_version IS 'Version of the adapter used';
COMMENT ON COLUMN triage_results.rule_version IS 'Version of the rule engine used';
COMMENT ON COLUMN triage_results.trace_id IS 'Trace ID for auditing and debugging';
COMMENT ON COLUMN triage_results.created_at IS 'Timestamp when the triage result was created';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_triage_results_acuity ON triage_results(acuity);
CREATE INDEX IF NOT EXISTS idx_triage_results_emergency_flag ON triage_results(emergency_flag);
CREATE INDEX IF NOT EXISTS idx_triage_results_created_at ON triage_results(created_at);
CREATE INDEX IF NOT EXISTS idx_triage_results_trace_id ON triage_results(trace_id);

COMMIT;
