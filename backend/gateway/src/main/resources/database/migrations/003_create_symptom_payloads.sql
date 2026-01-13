-- Migration: 003_create_symptom_payloads.sql
-- Description: Creates the SYMPTOM_PAYLOADS table with foreign key to ENCOUNTERS
-- Created: 2024

BEGIN;

-- Create SYMPTOM_PAYLOADS table
CREATE TABLE IF NOT EXISTS symptom_payloads (
    encounter_id VARCHAR(255) PRIMARY KEY,
    symptoms_json JSONB,
    vitals_json JSONB,
    risk_factors_json JSONB,
    free_text TEXT,
    pregnancy_flag BOOLEAN DEFAULT false,
    language_code VARCHAR(10) DEFAULT 'en',
    captured_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_symptom_payloads_encounter_id 
        FOREIGN KEY (encounter_id) 
        REFERENCES encounters(id) 
        ON DELETE CASCADE
);

-- Add table comment
COMMENT ON TABLE symptom_payloads IS 'Stores structured symptom, vital signs, and risk factor data captured during encounter';

-- Add column comments
COMMENT ON COLUMN symptom_payloads.encounter_id IS 'Primary key: Foreign key to encounters.id';
COMMENT ON COLUMN symptom_payloads.symptoms_json IS 'JSONB structure containing symptom data';
COMMENT ON COLUMN symptom_payloads.vitals_json IS 'JSONB structure containing vital signs (blood pressure, temperature, etc.)';
COMMENT ON COLUMN symptom_payloads.risk_factors_json IS 'JSONB structure containing risk factors';
COMMENT ON COLUMN symptom_payloads.free_text IS 'Free text description of symptoms';
COMMENT ON COLUMN symptom_payloads.pregnancy_flag IS 'Flag indicating if patient is pregnant';
COMMENT ON COLUMN symptom_payloads.language_code IS 'Language code for the captured data (ISO 639-1)';
COMMENT ON COLUMN symptom_payloads.captured_at IS 'Timestamp when the symptom data was captured';

-- Create GIN indexes for JSONB columns to enable efficient JSON queries
CREATE INDEX IF NOT EXISTS idx_symptom_payloads_symptoms_json ON symptom_payloads USING GIN (symptoms_json);
CREATE INDEX IF NOT EXISTS idx_symptom_payloads_vitals_json ON symptom_payloads USING GIN (vitals_json);
CREATE INDEX IF NOT EXISTS idx_symptom_payloads_risk_factors_json ON symptom_payloads USING GIN (risk_factors_json);

-- Create index on pregnancy_flag for filtering
CREATE INDEX IF NOT EXISTS idx_symptom_payloads_pregnancy_flag ON symptom_payloads(pregnancy_flag);

COMMIT;
