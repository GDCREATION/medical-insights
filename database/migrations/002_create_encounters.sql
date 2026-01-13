-- Migration: 002_create_encounters.sql
-- Description: Creates the ENCOUNTERS table with foreign key to PATIENTS
-- Created: 2024

BEGIN;

-- Create ENCOUNTERS table
CREATE TABLE IF NOT EXISTS encounters (
    id VARCHAR(255) PRIMARY KEY,
    patient_id VARCHAR(255) NOT NULL,
    consent_token VARCHAR(255) NOT NULL,
    encounter_ref VARCHAR(255) UNIQUE,
    status VARCHAR(50) NOT NULL DEFAULT 'created',
    source_channel VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign key constraint
    CONSTRAINT fk_encounters_patient_id 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) 
        ON DELETE RESTRICT,
    
    -- Check constraint for status values
    CONSTRAINT chk_encounters_status 
        CHECK (status IN ('created', 'symptoms_captured', 'triaged', 'reviewed', 'completed', 'expired', 'cancelled'))
);

-- Add table comment
COMMENT ON TABLE encounters IS 'Stores patient encounter records linking to triage workflow';

-- Add column comments
COMMENT ON COLUMN encounters.id IS 'Primary key: Unique identifier for the encounter';
COMMENT ON COLUMN encounters.patient_id IS 'Foreign key: References patients.patient_id';
COMMENT ON COLUMN encounters.consent_token IS 'Token representing patient consent for this encounter';
COMMENT ON COLUMN encounters.encounter_ref IS 'Unique reference identifier for the encounter';
COMMENT ON COLUMN encounters.status IS 'Current status of the encounter (created, symptoms_captured, triaged, reviewed, completed, expired, cancelled)';
COMMENT ON COLUMN encounters.source_channel IS 'Source channel where the encounter originated (web, mobile, etc.)';
COMMENT ON COLUMN encounters.created_at IS 'Timestamp when the encounter was created';
COMMENT ON COLUMN encounters.updated_at IS 'Timestamp when the encounter was last updated';
COMMENT ON COLUMN encounters.expires_at IS 'Timestamp when the encounter expires';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_encounters_patient_id ON encounters(patient_id);
CREATE INDEX IF NOT EXISTS idx_encounters_status ON encounters(status);
CREATE INDEX IF NOT EXISTS idx_encounters_created_at ON encounters(created_at);
CREATE INDEX IF NOT EXISTS idx_encounters_expires_at ON encounters(expires_at);
CREATE INDEX IF NOT EXISTS idx_encounters_consent_token ON encounters(consent_token);

COMMIT;
