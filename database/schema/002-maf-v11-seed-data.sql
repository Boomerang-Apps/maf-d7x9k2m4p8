-- ════════════════════════════════════════════════════════════════════════════
-- MAF V11.0.0 SEED DATA
-- Initial data for framework tracking
-- ════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════
-- SEED: Historical MAF Versions
-- ════════════════════════════════════════════════════════════════════════════

-- V10.0.7 (previous version)
INSERT INTO maf_versions (version, version_major, version_minor, version_patch, name, description, status, features)
VALUES (
    '10.0.7', 10, 0, 7,
    'Mature Framework',
    'Final V10 version with 14 validated tests, evolved from V8 through iterative improvements',
    'deprecated',
    '{
        "gate_system": true,
        "pm_validator": true,
        "merge_watcher": true,
        "slack_notifications": true,
        "cost_tracking": true,
        "tests_completed": 14
    }'::jsonb
)
ON CONFLICT (version) DO NOTHING;

-- V10.0.3 (100% success rate test)
INSERT INTO maf_versions (version, version_major, version_minor, version_patch, name, description, status, features)
VALUES (
    '10.0.3', 10, 0, 3,
    'Docker Multi-Agent',
    'Docker-based multi-agent execution with 100% success rate',
    'validated',
    '{
        "docker_orchestration": true,
        "multi_wave_execution": true,
        "success_rate": 100
    }'::jsonb
)
ON CONFLICT (version) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════════════
-- SEED: MAF V11 Documents (Day 1-3 created)
-- ════════════════════════════════════════════════════════════════════════════

-- Get V11 version ID
DO $$
DECLARE
    v11_id UUID;
BEGIN
    SELECT id INTO v11_id FROM maf_versions WHERE version = '11.0.0';
    
    -- Core documents (Day 1)
    INSERT INTO maf_documents (doc_code, doc_path, version_id, title, category, source_files)
    VALUES 
        ('SAFETY-PROTOCOL', 'core/SAFETY-PROTOCOL.md', v11_id, 'Safety Protocol - 109 Forbidden Operations', 'core', 
         ARRAY['/mnt/project/COMPLETE-SAFETY-REFERENCE.md']),
        ('GATE-SYSTEM', 'core/GATE-SYSTEM.md', v11_id, 'Gate System - 8 Quality Gates', 'core',
         ARRAY['/mnt/project/WORKFLOW-V4_3-COMPLETE.md', '/mnt/project/workflow-3.0-protocol.md']),
        ('APPROVAL-LEVELS', 'core/APPROVAL-LEVELS.md', v11_id, 'Approval Levels - L0 to L5 Matrix', 'core',
         ARRAY['/mnt/project/COMPLETE-SAFETY-REFERENCE.md']),
        ('EMERGENCY-LEVELS', 'core/EMERGENCY-LEVELS.md', v11_id, 'Emergency Levels - E1 to E5 Procedures', 'core',
         ARRAY['/mnt/project/COMPLETE-SAFETY-REFERENCE.md']),
        ('FMEA', 'core/FMEA.md', v11_id, 'FMEA - 17 Failure Modes Analyzed', 'core',
         ARRAY['/mnt/project/AEROSPACE-GRADE-SAFETY-RECOMMENDATIONS.md'])
    ON CONFLICT (doc_code, version_id) DO NOTHING;
    
    -- Template documents (Day 2)
    INSERT INTO maf_documents (doc_code, doc_path, version_id, title, category, source_files)
    VALUES 
        ('STORY-TEMPLATE', 'templates/story.template.json', v11_id, 'AI Story Schema Template', 'template',
         ARRAY['/mnt/project/ai-story_schema.json']),
        ('CLAUDE-MD', 'templates/test-template/LOCKED/CLAUDE.md', v11_id, 'Agent Instructions Template', 'template',
         ARRAY['/mnt/project/CLAUDE-CODE-PROTOCOL-V1_3.md']),
        ('DOCKER-COMPOSE', 'templates/test-template/LOCKED/docker-compose.yml', v11_id, 'Docker Orchestration Template', 'template',
         ARRAY['/mnt/project/DOCKER-MULTI-AGENT-IMPLEMENTATION-GUIDE.md'])
    ON CONFLICT (doc_code, version_id) DO NOTHING;
    
    -- Validation tools (Day 3)
    INSERT INTO maf_documents (doc_code, doc_path, version_id, title, category, source_files)
    VALUES 
        ('PM-VALIDATOR', 'validation/pm-validator-v6.0.sh', v11_id, 'Pre-Flight Validator V6.0', 'validation',
         ARRAY['/mnt/project/pm-validator-v5_5.sh']),
        ('SMOKE-TEST', 'validation/smoke-test.sh', v11_id, 'Quick System Verification', 'validation',
         ARRAY['/mnt/project/SIGNAL-FLOW-SMOKE-TEST-PROTOCOL.md']),
        ('SAFETY-DETECTOR', 'validation/safety-detector.sh', v11_id, 'Real-Time Forbidden Operation Monitor', 'validation',
         ARRAY['/mnt/project/COMPLETE-SAFETY-REFERENCE.md'])
    ON CONFLICT (doc_code, version_id) DO NOTHING;
    
    -- Operations documents (Day 3)
    INSERT INTO maf_documents (doc_code, doc_path, version_id, title, category, source_files)
    VALUES 
        ('DEPLOYMENT', 'operations/DEPLOYMENT.md', v11_id, 'Docker & VM Setup Guide', 'operations',
         ARRAY['/mnt/project/DOCKER-MULTI-AGENT-IMPLEMENTATION-GUIDE.md', '/mnt/project/AUTONOMOUS-AGENT-SETUP-GUIDE.md']),
        ('AUTHENTICATION', 'operations/AUTHENTICATION.md', v11_id, 'Claude Code Authentication Guide', 'operations',
         ARRAY['/mnt/project/CLAUDE-CODE-VM-AUTHENTICATION-PLAN.md', '/mnt/project/BYPASS-MODE-AUTOMATION-GUIDE.md']),
        ('MONITORING', 'operations/MONITORING.md', v11_id, 'Dashboards and Alerts Guide', 'operations',
         ARRAY['/mnt/project/PRODUCTION-MONITORING-STACK.md', '/mnt/project/ALERTING-RULES-MATRIX.md'])
    ON CONFLICT (doc_code, version_id) DO NOTHING;
    
    -- Project documents
    INSERT INTO maf_documents (doc_code, doc_path, version_id, title, category, source_files)
    VALUES 
        ('AIRVIEW-AGENTS', 'projects/airview/AGENTS.md', v11_id, 'AirView Agent Definitions - 29 Agents', 'project',
         ARRAY['https://raw.githubusercontent.com/Boomerang-Apps/maf-d7x9k2m4p8/main/core/AGENTS.md']),
        ('AIRVIEW-DOMAINS', 'projects/airview/DOMAINS.md', v11_id, 'AirView Domain Definitions - 11 Domains', 'project',
         ARRAY['https://raw.githubusercontent.com/Boomerang-Apps/maf-d7x9k2m4p8/main/core/DOMAINS.md'])
    ON CONFLICT (doc_code, version_id) DO NOTHING;
    
END $$;

-- ════════════════════════════════════════════════════════════════════════════
-- SEED: Historical Tests Import (14 tests from V8-V10)
-- ════════════════════════════════════════════════════════════════════════════

-- Get version IDs
DO $$
DECLARE
    v10_id UUID;
    v103_id UUID;
BEGIN
    SELECT id INTO v10_id FROM maf_versions WHERE version = '10.0.7';
    SELECT id INTO v103_id FROM maf_versions WHERE version = '10.0.3';
    
    -- Test 8.4 - Content Rich Protocol
    INSERT INTO maf_tests (test_code, test_name, version_id, status, is_validation_test, validation_passed, config)
    VALUES (
        'V8-TEST-004', 'Content Rich Protocol Test', v10_id, 'completed', true, true,
        '{"wave_count": 2, "pattern": "content-rich"}'::jsonb
    )
    ON CONFLICT (test_code) DO NOTHING;
    
    -- Test 8.6 - 80% failure rate discovery
    INSERT INTO maf_tests (test_code, test_name, version_id, status, is_validation_test, validation_passed, config)
    VALUES (
        'V8-TEST-006', 'Wave Cycling Discovery Test', v10_id, 'completed', true, false,
        '{"wave_count": 3, "failure_rate": 80, "lesson": "Claude CLI asking questions breaks automation"}'::jsonb
    )
    ON CONFLICT (test_code) DO NOTHING;
    
    -- Test 10.0.3 - 100% success rate
    INSERT INTO maf_tests (test_code, test_name, version_id, status, is_validation_test, validation_passed, 
                          stories_total, stories_passed, success_rate_percent, config)
    VALUES (
        'V10-TEST-003', 'Docker Multi-Agent 100% Success', v103_id, 'completed', true, true,
        4, 4, 100.0,
        '{"wave_count": 2, "agents_per_wave": 2, "pattern": "docker-orchestration", "success_rate": 100}'::jsonb
    )
    ON CONFLICT (test_code) DO NOTHING;

END $$;

-- ════════════════════════════════════════════════════════════════════════════
-- USEFUL QUERIES
-- ════════════════════════════════════════════════════════════════════════════

-- Query: Show all versions and their validation status
-- SELECT version, status, is_validated, features FROM maf_versions ORDER BY version_major DESC, version_minor DESC;

-- Query: Show all documents for V11
-- SELECT doc_code, title, category FROM maf_documents d 
-- JOIN maf_versions v ON d.version_id = v.id WHERE v.version = '11.0.0';

-- Query: Show test success rates by version
-- SELECT * FROM maf_test_summary;

-- Query: Show cost breakdown by model
-- SELECT * FROM maf_cost_by_model;

-- Query: Show gate success rates
-- SELECT * FROM maf_gate_success_rates;

-- ════════════════════════════════════════════════════════════════════════════
-- END OF SEED DATA
-- ════════════════════════════════════════════════════════════════════════════
