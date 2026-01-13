# Supabase Database Setup

This guide explains how to connect the application to Supabase and run database migrations.

## Prerequisites

1. A Supabase project created at [supabase.com](https://supabase.com)
2. Database connection details from your Supabase project

## Getting Supabase Connection Details

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **Database**
3. Find the **Connection string** section
4. Copy the connection details:
   - **Host**: Your project's database host (e.g., `db.xxxxx.supabase.co`)
   - **Port**: `5432`
   - **Database**: `postgres`
   - **User**: `postgres` (or your custom user)
   - **Password**: Your database password

## Configuration

### Option 1: Environment Variables (Recommended)

Set the following environment variables:

```bash
# Supabase connection (takes precedence)
export SUPABASE_DB_URL="jdbc:postgresql://db.xxxxx.supabase.co:5432/postgres"
export SUPABASE_DB_USER="postgres"
export SUPABASE_DB_PASSWORD="your-database-password"

# Or use generic DATABASE_* variables
export DATABASE_URL="jdbc:postgresql://db.xxxxx.supabase.co:5432/postgres"
export DATABASE_USER="postgres"
export DATABASE_PASSWORD="your-database-password"
```

### Option 2: application.yml

Update `backend/gateway/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://db.xxxxx.supabase.co:5432/postgres
    username: postgres
    password: your-database-password
```

**Note**: Never commit passwords to version control. Use environment variables or secrets management.

## Running Migrations

### Automatic Migration on Startup

By default, migrations run automatically when the application starts. This is controlled by:

```yaml
database:
  migration:
    enabled: true
    run-on-startup: true
```

To disable automatic migrations:

```bash
export DATABASE_MIGRATION_ENABLED=false
export DATABASE_MIGRATION_RUN_ON_STARTUP=false
```

### Manual Migration via API

You can trigger migrations manually via REST API:

```bash
POST http://localhost:8080/api/admin/migrations/run
```

**Note**: In production, secure this endpoint with proper authentication/authorization.

### Manual Migration via Code

You can also trigger migrations programmatically:

```java
@Autowired
private DatabaseMigrationService migrationService;

public void runMigrations() {
    migrationService.runMigrations();
}
```

## Migration Files

Migration files are located in:
- Source: `database/migrations/`
- Resources: `backend/gateway/src/main/resources/database/migrations/`

The service automatically:
1. Loads all SQL files matching pattern `###_*.sql`
2. Sorts them by number (001, 002, etc.)
3. Executes them in order
4. Handles transactions automatically
5. Skips already-existing objects (idempotent)

## Migration Execution Order

1. `001_create_patients.sql` - Creates PATIENTS table
2. `002_create_encounters.sql` - Creates ENCOUNTERS table
3. `003_create_symptom_payloads.sql` - Creates SYMPTOM_PAYLOADS table
4. `004_create_triage_results.sql` - Creates TRIAGE_RESULTS table
5. `005_create_clinician_reviews.sql` - Creates CLINICIAN_REVIEWS table
6. `006_create_encounter_events.sql` - Creates ENCOUNTER_EVENTS table
7. `007_create_indexes.sql` - Creates additional indexes

## Verifying Migrations

After running migrations, verify the schema:

```sql
-- List all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check a specific table structure
\d patients
\d encounters
```

## Troubleshooting

### Connection Issues

1. **Check firewall**: Ensure your IP is whitelisted in Supabase dashboard
2. **Verify credentials**: Double-check username and password
3. **Test connection**: Use a PostgreSQL client to verify connectivity

### Migration Errors

1. **Check logs**: Look for detailed error messages in application logs
2. **Verify SQL syntax**: Ensure migration files are valid PostgreSQL
3. **Check permissions**: Ensure database user has CREATE/ALTER permissions

### Migration Already Run

The migration service is idempotent - it uses `IF NOT EXISTS` clauses. Running migrations multiple times is safe.

## Security Best Practices

1. **Never commit credentials**: Use environment variables or secrets management
2. **Use connection pooling**: Supabase handles this automatically
3. **Enable SSL**: Supabase connections use SSL by default
4. **Restrict access**: Use Supabase's IP allowlist feature
5. **Rotate passwords**: Regularly update database passwords

## Supabase Connection String Format

For Supabase, the connection string format is:

```
jdbc:postgresql://db.[project-ref].supabase.co:5432/postgres
```

Where `[project-ref]` is your Supabase project reference ID.

## Example: Docker Compose with Supabase

```yaml
services:
  gateway:
    environment:
      - SUPABASE_DB_URL=${SUPABASE_DB_URL}
      - SUPABASE_DB_USER=${SUPABASE_DB_USER}
      - SUPABASE_DB_PASSWORD=${SUPABASE_DB_PASSWORD}
```

## Next Steps

1. Set up your Supabase project
2. Configure connection details
3. Start the application - migrations will run automatically
4. Verify tables are created in Supabase dashboard
