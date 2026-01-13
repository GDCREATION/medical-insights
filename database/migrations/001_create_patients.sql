-- Migration: 001_create_patients.sql
-- Description: Creates the PATIENTS table with all required fields, constraints, and indexes
-- Created: 2024

BEGIN;

-- Create PATIENTS table
CREATE TABLE IF NOT EXISTS patients (
    patient_id VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex_at_birth VARCHAR(50),
    gender_identity VARCHAR(50),
    phone_tokenized VARCHAR(255),
    email_tokenized VARCHAR(255),
    address_line1 VARCHAR(500),
    address_line2 VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add table comment
COMMENT ON TABLE patients IS 'Stores patient demographic and contact information with tokenized PII';

-- Add column comments
COMMENT ON COLUMN patients.patient_id IS 'Primary key: Unique identifier for the patient';
COMMENT ON COLUMN patients.first_name IS 'Patient first name';
COMMENT ON COLUMN patients.last_name IS 'Patient last name';
COMMENT ON COLUMN patients.date_of_birth IS 'Patient date of birth';
COMMENT ON COLUMN patients.sex_at_birth IS 'Sex assigned at birth';
COMMENT ON COLUMN patients.gender_identity IS 'Patient gender identity';
COMMENT ON COLUMN patients.phone_tokenized IS 'Tokenized phone number for privacy';
COMMENT ON COLUMN patients.email_tokenized IS 'Tokenized email address for privacy';
COMMENT ON COLUMN patients.address_line1 IS 'Primary address line';
COMMENT ON COLUMN patients.address_line2 IS 'Secondary address line (apartment, suite, etc.)';
COMMENT ON COLUMN patients.city IS 'City';
COMMENT ON COLUMN patients.state IS 'State or province';
COMMENT ON COLUMN patients.postal_code IS 'Postal or ZIP code';
COMMENT ON COLUMN patients.country IS 'Country';
COMMENT ON COLUMN patients.is_active IS 'Indicates if the patient record is active';
COMMENT ON COLUMN patients.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN patients.updated_at IS 'Timestamp when the record was last updated';

-- Create index on is_active for filtering active patients
CREATE INDEX IF NOT EXISTS idx_patients_is_active ON patients(is_active);

-- Create index on created_at for time-based queries
CREATE INDEX IF NOT EXISTS idx_patients_created_at ON patients(created_at);

-- Create composite index for name searches
CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(last_name, first_name);

COMMIT;
