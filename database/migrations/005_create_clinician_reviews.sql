-- Migration: 005_create_clinician_reviews.sql
-- Description: Creates the CLINICIAN_REVIEWS table with foreign key to ENCOUNTERS
-- Created: 2024

BEGIN;

-- Create CLINICIAN_REVIEWS table
CREATE TABLE IF NOT EXISTS clinician_reviews (
    encounter_id VARCHAR(255) PRIMARY KEY,
    decision VARCHAR(50) NOT NULL,
    override_flag BOOLEAN NOT NULL DEFAULT false,
    override_reason TEXT,
    notes TEXT,
    reviewer_id VARCHAR(255) NOT NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_clinician_reviews_encounter_id 
        FOREIGN KEY (encounter_id) 
        REFERENCES encounters(id) 
        ON DELETE CASCADE,
    
    -- Check constraint for decision values
    CONSTRAINT chk_clinician_reviews_decision 
        CHECK (decision IN ('approved', 'overridden', 'rejected', 'needs_more_info'))
);

-- Add table comment
COMMENT ON TABLE clinician_reviews IS 'Stores clinician review decisions and overrides for triage results';

-- Add column comments
COMMENT ON COLUMN clinician_reviews.encounter_id IS 'Primary key: Foreign key to encounters.id';
COMMENT ON COLUMN clinician_reviews.decision IS 'Clinician decision (approved, overridden, rejected, needs_more_info)';
COMMENT ON COLUMN clinician_reviews.override_flag IS 'Flag indicating if the clinician overrode the AI triage result';
COMMENT ON COLUMN clinician_reviews.override_reason IS 'Reason for overriding the AI triage result';
COMMENT ON COLUMN clinician_reviews.notes IS 'Additional notes from the clinician';
COMMENT ON COLUMN clinician_reviews.reviewer_id IS 'Identifier of the clinician who reviewed the encounter';
COMMENT ON COLUMN clinician_reviews.reviewed_at IS 'Timestamp when the review was completed';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_clinician_reviews_decision ON clinician_reviews(decision);
CREATE INDEX IF NOT EXISTS idx_clinician_reviews_override_flag ON clinician_reviews(override_flag);
CREATE INDEX IF NOT EXISTS idx_clinician_reviews_reviewer_id ON clinician_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_clinician_reviews_reviewed_at ON clinician_reviews(reviewed_at);

COMMIT;
