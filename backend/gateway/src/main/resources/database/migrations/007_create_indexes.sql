-- Migration: 007_create_indexes.sql
-- Description: Creates additional performance indexes for common query patterns
-- Created: 2024

BEGIN;

-- Composite indexes for common query patterns

-- Index for querying encounters by patient and status
CREATE INDEX IF NOT EXISTS idx_encounters_patient_status 
    ON encounters(patient_id, status);

-- Index for querying encounters by status and creation time (for dashboards)
CREATE INDEX IF NOT EXISTS idx_encounters_status_created 
    ON encounters(status, created_at DESC);

-- Index for querying active encounters that haven't expired
CREATE INDEX IF NOT EXISTS idx_encounters_active 
    ON encounters(status, expires_at) 
    WHERE expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP;

-- Index for querying triage results by emergency flag and acuity
CREATE INDEX IF NOT EXISTS idx_triage_results_emergency_acuity 
    ON triage_results(emergency_flag, acuity);

-- Index for querying clinician reviews by decision and review time
CREATE INDEX IF NOT EXISTS idx_clinician_reviews_decision_reviewed 
    ON clinician_reviews(decision, reviewed_at DESC);

-- Index for querying events by type and time (for audit queries)
CREATE INDEX IF NOT EXISTS idx_encounter_events_type_created 
    ON encounter_events(event_type, created_at DESC);

-- Index for full-text search on free_text in symptom_payloads (if using full-text search)
-- Note: This requires the pg_trgm extension for trigram matching
-- Uncomment if you plan to use full-text search:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_symptom_payloads_free_text_trgm 
--     ON symptom_payloads USING GIN (free_text gin_trgm_ops);

COMMIT;
