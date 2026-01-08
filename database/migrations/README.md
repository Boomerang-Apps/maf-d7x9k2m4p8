# MAF V11.0.0 Database Migrations

## Overview

This directory contains database migrations for the MAF V11.0.0 framework.

## Schema Files

| File | Purpose |
|------|---------|
| `schema/001-maf-v11-core.sql` | Core tables: versions, documents, tests, stories, agents, gates |
| `schema/002-maf-v11-seed-data.sql` | Initial data: V11 version, documents, historical tests |

## Tables

### Core Tables

| Table | Purpose |
|-------|---------|
| `maf_versions` | Framework version registry with validation status |
| `maf_documents` | Documentation tracking with SHA-256 change detection |
| `maf_tests` | Test execution history with costs |
| `maf_test_stories` | Stories executed in each test |
| `maf_test_agents` | Agent performance per test |
| `maf_test_gates` | Gate pass/fail tracking |

### Views

| View | Purpose |
|------|---------|
| `maf_test_summary` | Test results with success rate |
| `maf_cost_by_model` | Cost breakdown by AI model |
| `maf_gate_success_rates` | Gate pass/fail statistics |

## How to Apply

### Using Supabase Dashboard

1. Go to your Supabase project
2. Navigate to SQL Editor
3. Copy contents of `001-maf-v11-core.sql`
4. Run the query
5. Copy contents of `002-maf-v11-seed-data.sql`
6. Run the query

### Using Supabase CLI

```bash
# Install Supabase CLI if needed
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push
```

### Using psql

```bash
# Connect to your database
psql $DATABASE_URL

# Run migrations
\i schema/001-maf-v11-core.sql
\i schema/002-maf-v11-seed-data.sql
```

## Example Queries

### Show all versions
```sql
SELECT version, status, is_validated, features 
FROM maf_versions 
ORDER BY version_major DESC, version_minor DESC;
```

### Show V11 documents
```sql
SELECT doc_code, title, category 
FROM maf_documents d 
JOIN maf_versions v ON d.version_id = v.id 
WHERE v.version = '11.0.0';
```

### Show test results
```sql
SELECT * FROM maf_test_summary;
```

### Show cost by model
```sql
SELECT * FROM maf_cost_by_model;
```

### Show gate success rates
```sql
SELECT * FROM maf_gate_success_rates;
```

## Rollback

To rollback, run:

```sql
-- Drop views first
DROP VIEW IF EXISTS maf_gate_success_rates;
DROP VIEW IF EXISTS maf_cost_by_model;
DROP VIEW IF EXISTS maf_test_summary;

-- Drop tables (in order due to foreign keys)
DROP TABLE IF EXISTS maf_test_gates;
DROP TABLE IF EXISTS maf_test_agents;
DROP TABLE IF EXISTS maf_test_stories;
DROP TABLE IF EXISTS maf_tests;
DROP TABLE IF EXISTS maf_documents;
DROP TABLE IF EXISTS maf_versions;

-- Drop triggers
DROP FUNCTION IF EXISTS update_updated_at_column;
```

## Schema Updates

When updating the schema:

1. Create new migration file: `003-description.sql`
2. Use `ALTER TABLE` for modifications
3. Include rollback instructions
4. Update this README
