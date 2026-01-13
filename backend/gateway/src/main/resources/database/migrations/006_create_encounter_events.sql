-- Migration: 006_create_encounter_events.sql
-- Description: Creates the ENCOUNTER_EVENTS table with foreign key to ENCOUNTERS
-- Created: 2024

BEGIN;

-- Create ENCOUNTER_EVENTS table
CREATE TABLE IF NOT EXISTS encounter_events (
    id BIGSERIAL PRIMARY KEY,
    encounter_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    actor VARCHAR(255),
    details_json JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_encounter_events_encounter_id 
        FOREIGN KEY (encounter_id) 
        REFERENCES encounters(id) 
        ON DELETE CASCADE,
    
    -- Check constraint for common event types
    CONSTRAINT chk_encounter_events_event_type 
        CHECK (event_type IN (
            'encounter_created',
            'symptoms_captured',
            'triage_initiated',
            'triage_completed',
            'clinician_review_started',
            'clinician_review_completed',
            'encounter_completed',
            'encounter_expired',
            'encounter_cancelled',
            'consent_verified',
            'consent_revoked',
            'other'
        ))
);

-- Add table comment
COMMENT ON TABLE encounter_events IS 'Append-only audit log of events that occur during an encounter lifecycle';

-- Add column comments
COMMENT ON COLUMN encounter_events.id IS 'Primary key: Auto-incrementing event identifier';
COMMENT ON COLUMN encounter_events.encounter_id IS 'Foreign key: References encounters.id';
COMMENT ON COLUMN encounter_events.event_type IS 'Type of event that occurred';
COMMENT ON COLUMN encounter_events.actor IS 'Identifier of the actor who triggered the event (user, system, etc.)';
COMMENT ON COLUMN encounter_events.details_json IS 'JSONB structure containing additional event details';
COMMENT ON COLUMN encounter_events.created_at IS 'Timestamp when the event occurred';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_encounter_events_encounter_id ON encounter_events(encounter_id);
CREATE INDEX IF NOT EXISTS idx_encounter_events_event_type ON encounter_events(event_type);
CREATE INDEX IF NOT EXISTS idx_encounter_events_created_at ON encounter_events(created_at);
CREATE INDEX IF NOT EXISTS idx_encounter_events_actor ON encounter_events(actor);

-- Create GIN index for JSONB column
CREATE INDEX IF NOT EXISTS idx_encounter_events_details_json ON encounter_events USING GIN (details_json);

-- Create composite index for common query patterns (encounter events by time)
CREATE INDEX IF NOT EXISTS idx_encounter_events_encounter_created ON encounter_events(encounter_id, created_at);

COMMIT;
