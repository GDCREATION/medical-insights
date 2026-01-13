# Database Migration Scripts

This directory contains PostgreSQL database migration scripts for the Medical Insights patient triage system.

## Database Schema

The schema implements the following tables:

- **patients** - Patient demographic and contact information
- **encounters** - Patient encounter records
- **symptom_payloads** - Symptom, vital signs, and risk factor data
- **triage_results** - AI-generated triage results
- **clinician_reviews** - Clinician review decisions and overrides
- **encounter_events** - Audit log of encounter lifecycle events

## Migration Files

The migrations are numbered sequentially and should be executed in order:

1. `001_create_patients.sql` - Creates the PATIENTS table
2. `002_create_encounters.sql` - Creates the ENCOUNTERS table with FK to PATIENTS
3. `003_create_symptom_payloads.sql` - Creates the SYMPTOM_PAYLOADS table with FK to ENCOUNTERS
4. `004_create_triage_results.sql` - Creates the TRIAGE_RESULTS table with FK to ENCOUNTERS
5. `005_create_clinician_reviews.sql` - Creates the CLINICIAN_REVIEWS table with FK to ENCOUNTERS
6. `006_create_encounter_events.sql` - Creates the ENCOUNTER_EVENTS table with FK to ENCOUNTERS
7. `007_create_indexes.sql` - Creates additional performance indexes

## Running Migrations

### Using psql

```bash
# Connect to the database
psql -U meduser -d medinsights -h localhost

# Run migrations in order
\i database/migrations/001_create_patients.sql
\i database/migrations/002_create_encounters.sql
\i database/migrations/003_create_symptom_payloads.sql
\i database/migrations/004_create_triage_results.sql
\i database/migrations/005_create_clinician_reviews.sql
\i database/migrations/006_create_encounter_events.sql
\i database/migrations/007_create_indexes.sql
```

### Using psql from command line

```bash
# Run all migrations in sequence
psql -U meduser -d medinsights -h localhost -f database/migrations/001_create_patients.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/002_create_encounters.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/003_create_symptom_payloads.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/004_create_triage_results.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/005_create_clinician_reviews.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/006_create_encounter_events.sql
psql -U meduser -d medinsights -h localhost -f database/migrations/007_create_indexes.sql
```

### Using Docker

If using Docker Compose, you can run migrations inside the postgres container:

```bash
# Copy migration files to container (if needed)
docker cp database/migrations/. <container_name>:/tmp/migrations/

# Execute migrations
docker exec -i <container_name> psql -U meduser -d medinsights < database/migrations/001_create_patients.sql
docker exec -i <container_name> psql -U meduser -d medinsights < database/migrations/002_create_encounters.sql
# ... and so on for each migration
```

### Using a Migration Tool

For production environments, consider using a migration tool like:
- **Flyway** - Java-based migration tool
- **Liquibase** - Database-independent migration tool
- **Alembic** - Python-based migration tool (if using Python)

## Database Connection Details

Default connection details (from docker-compose.yml):
- **Host**: localhost (or postgres service name in Docker network)
- **Port**: 5432
- **Database**: medinsights
- **User**: meduser
- **Password**: medpass

## Schema Features

- **Primary Keys**: String-based IDs (VARCHAR) for most tables, BIGSERIAL for encounter_events
- **Foreign Keys**: Proper referential integrity with CASCADE or RESTRICT as appropriate
- **Indexes**: Comprehensive indexing on foreign keys, commonly queried fields, and JSONB columns
- **Constraints**: Check constraints for enum-like fields (status, decision, acuity, event_type)
- **JSONB**: JSONB type for flexible JSON data with GIN indexes for efficient querying
- **Timestamps**: All datetime fields use TIMESTAMP WITH TIME ZONE
- **Comments**: Table and column comments for documentation

## Notes

- All migrations use transactions (BEGIN/COMMIT) for atomicity
- Migrations are idempotent (use IF NOT EXISTS where appropriate)
- Foreign key constraints ensure referential integrity
- JSONB columns have GIN indexes for efficient JSON queries
- Check constraints validate enum-like values at the database level

## Verification

After running migrations, verify the schema:

```sql
-- List all tables
\dt

-- Check table structure
\d patients
\d encounters
\d symptom_payloads
\d triage_results
\d clinician_reviews
\d encounter_events

-- Check indexes
\di

-- Check foreign keys
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE constraint_type = 'FOREIGN KEY';
```
