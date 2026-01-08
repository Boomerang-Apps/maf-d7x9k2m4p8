-- ════════════════════════════════════════════════════════════════════════════
-- V11-TEST-001 DATABASE RECORD
-- Records the first MAF V11.0.0 validation test
-- ════════════════════════════════════════════════════════════════════════════
-- 
-- Run this SQL after applying the core schema (001, 002) to record the test.
--
-- ════════════════════════════════════════════════════════════════════════════

-- Get V11 version ID and create test
DO $$
DECLARE
    v11_id UUID;
    test_id UUID;
    story_id UUID;
    dev_agent_id UUID;
    qa_agent_id UUID;
BEGIN
    -- Get V11.0.0 version
    SELECT id INTO v11_id FROM maf_versions WHERE version = '11.0.0';
    
    IF v11_id IS NULL THEN
        RAISE EXCEPTION 'V11.0.0 not found. Run seed data first.';
    END IF;
    
    -- ════════════════════════════════════════════════════════════════════════
    -- INSERT TEST RECORD
    -- ════════════════════════════════════════════════════════════════════════
    INSERT INTO maf_tests (
        test_code,
        test_name,
        version_id,
        status,
        config,
        started_at,
        completed_at,
        duration_minutes,
        stories_total,
        stories_passed,
        stories_failed,
        gates_passed,
        gates_failed,
        total_input_tokens,
        total_output_tokens,
        total_cost_usd,
        is_validation_test,
        validation_passed,
        validation_notes,
        artifacts
    ) VALUES (
        'V11-TEST-001',
        'First MAF V11.0.0 Validation Test',
        v11_id,
        'completed',
        '{
            "waves": 1,
            "parallel_agents_per_wave": 2,
            "model_dev": "claude-sonnet-4-20250514",
            "model_qa": "claude-haiku-4-5-20251001",
            "max_iterations": 25,
            "token_budget": 200000,
            "execution_type": "simulation"
        }'::jsonb,
        '2026-01-08T14:09:00Z',
        '2026-01-08T14:54:00Z',
        45,
        1,  -- stories_total
        1,  -- stories_passed
        0,  -- stories_failed
        8,  -- gates_passed
        0,  -- gates_failed
        53000,   -- total_input_tokens (45000 + 8000)
        14000,   -- total_output_tokens (12000 + 2000)
        0.3195,  -- total_cost_usd
        TRUE,    -- is_validation_test
        TRUE,    -- validation_passed
        'First successful V11.0.0 validation. All 8 gates passed. LOCKED/CONFIGURABLE pattern validated.',
        '{
            "report_path": "tests/V11-TEST-001/reports/TEST-REPORT-20260108-140953.md",
            "signal_files": 12,
            "git_branch": "test/v11-test-001"
        }'::jsonb
    )
    RETURNING id INTO test_id;
    
    RAISE NOTICE 'Created test: %', test_id;
    
    -- ════════════════════════════════════════════════════════════════════════
    -- INSERT STORY RECORD
    -- ════════════════════════════════════════════════════════════════════════
    INSERT INTO maf_test_stories (
        test_id,
        story_code,
        story_title,
        domain,
        wave_number,
        dev_agent,
        qa_agent,
        status,
        started_at,
        completed_at,
        duration_minutes,
        gates_completed,
        qa_rejections,
        test_coverage,
        tests_written,
        tests_passed,
        input_tokens,
        output_tokens,
        cost_usd,
        details
    ) VALUES (
        test_id,
        'AUTH-FE-001',
        'Create LoginForm component with email validation',
        'auth',
        1,
        'fe-auth-dev',
        'qa-auth',
        'passed',
        '2026-01-08T14:09:00Z',
        '2026-01-08T14:54:00Z',
        45,
        8,   -- gates_completed
        0,   -- qa_rejections
        87.5, -- test_coverage
        5,   -- tests_written
        5,   -- tests_passed
        45000, -- input_tokens (dev only)
        12000, -- output_tokens (dev only)
        0.3150, -- cost_usd (dev only)
        '{
            "files_created": ["src/components/auth/LoginForm.tsx", "src/components/auth/LoginForm.test.tsx"],
            "commits": 5,
            "acceptance_criteria_met": ["AC-1", "AC-2", "AC-3", "AC-4"],
            "qa_feedback": "All acceptance criteria validated. Good test coverage."
        }'::jsonb
    )
    RETURNING id INTO story_id;
    
    RAISE NOTICE 'Created story: %', story_id;
    
    -- ════════════════════════════════════════════════════════════════════════
    -- INSERT AGENT RECORDS
    -- ════════════════════════════════════════════════════════════════════════
    
    -- Dev agent
    INSERT INTO maf_test_agents (
        test_id,
        agent_code,
        agent_type,
        domain,
        model,
        status,
        started_at,
        completed_at,
        duration_minutes,
        stories_assigned,
        stories_completed,
        stories_rejected,
        stuck_count,
        error_count,
        restart_count,
        input_tokens,
        output_tokens,
        cost_usd
    ) VALUES (
        test_id,
        'fe-auth-dev',
        'dev',
        'auth',
        'claude-sonnet-4-20250514',
        'completed',
        '2026-01-08T14:09:00Z',
        '2026-01-08T14:44:00Z',
        35,
        1,  -- stories_assigned
        1,  -- stories_completed
        0,  -- stories_rejected
        0,  -- stuck_count
        0,  -- error_count
        0,  -- restart_count
        45000,  -- input_tokens
        12000,  -- output_tokens
        0.3150  -- cost_usd
    )
    RETURNING id INTO dev_agent_id;
    
    -- QA agent
    INSERT INTO maf_test_agents (
        test_id,
        agent_code,
        agent_type,
        domain,
        model,
        status,
        started_at,
        completed_at,
        duration_minutes,
        stories_assigned,
        stories_completed,
        stories_rejected,
        stuck_count,
        error_count,
        restart_count,
        input_tokens,
        output_tokens,
        cost_usd
    ) VALUES (
        test_id,
        'qa-auth',
        'qa',
        'auth',
        'claude-haiku-4-5-20251001',
        'completed',
        '2026-01-08T14:44:00Z',
        '2026-01-08T14:54:00Z',
        10,
        1,  -- stories_assigned
        1,  -- stories_completed
        0,  -- stories_rejected
        0,  -- stuck_count
        0,  -- error_count
        0,  -- restart_count
        8000,   -- input_tokens
        2000,   -- output_tokens
        0.0045  -- cost_usd
    )
    RETURNING id INTO qa_agent_id;
    
    RAISE NOTICE 'Created agents: dev=%, qa=%', dev_agent_id, qa_agent_id;
    
    -- ════════════════════════════════════════════════════════════════════════
    -- INSERT GATE RECORDS
    -- ════════════════════════════════════════════════════════════════════════
    INSERT INTO maf_test_gates (test_id, story_id, agent_id, gate_number, gate_name, status, started_at, completed_at, duration_minutes, details) VALUES
        (test_id, story_id, dev_agent_id, 0, 'Architecture', 'passed', '2026-01-08T14:09:00Z', '2026-01-08T14:14:00Z', 5, '{"approver": "cto-agent"}'::jsonb),
        (test_id, story_id, dev_agent_id, 1, 'Planning', 'passed', '2026-01-08T14:14:00Z', '2026-01-08T14:22:00Z', 8, '{"tasks_created": 5}'::jsonb),
        (test_id, story_id, dev_agent_id, 2, 'Implementation', 'passed', '2026-01-08T14:22:00Z', '2026-01-08T14:37:00Z', 15, '{"files_created": 2, "lines_written": 450}'::jsonb),
        (test_id, story_id, dev_agent_id, 3, 'Self-Test', 'passed', '2026-01-08T14:37:00Z', '2026-01-08T14:44:00Z', 7, '{"tests_run": 5, "tests_passed": 5}'::jsonb),
        (test_id, story_id, qa_agent_id, 4, 'QA Review', 'passed', '2026-01-08T14:44:00Z', '2026-01-08T14:49:00Z', 5, '{"criteria_checked": 4, "criteria_passed": 4}'::jsonb),
        (test_id, story_id, NULL, 5, 'PM Validation', 'passed', '2026-01-08T14:49:00Z', '2026-01-08T14:51:00Z', 2, '{"approver": "pm-agent"}'::jsonb),
        (test_id, story_id, NULL, 6, 'Merge Ready', 'passed', '2026-01-08T14:51:00Z', '2026-01-08T14:53:00Z', 2, '{"ci_passed": true}'::jsonb),
        (test_id, story_id, NULL, 7, 'Deployed', 'passed', '2026-01-08T14:53:00Z', '2026-01-08T14:54:00Z', 1, '{"environment": "simulation"}'::jsonb);
    
    RAISE NOTICE 'Created 8 gate records';
    
    -- ════════════════════════════════════════════════════════════════════════
    -- UPDATE V11 VERSION AS VALIDATED
    -- ════════════════════════════════════════════════════════════════════════
    UPDATE maf_versions
    SET 
        is_validated = TRUE,
        validated_at = NOW(),
        validated_by = 'V11-TEST-001',
        validation_test_id = test_id,
        status = 'validated'
    WHERE id = v11_id;
    
    RAISE NOTICE 'V11.0.0 marked as validated';
    
END $$;

-- ════════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES
-- ════════════════════════════════════════════════════════════════════════════

-- Show test summary
SELECT 
    t.test_code,
    t.test_name,
    v.version,
    t.status,
    t.stories_passed || '/' || t.stories_total as stories,
    t.gates_passed || '/' || (t.gates_passed + t.gates_failed) as gates,
    t.total_cost_usd,
    t.validation_passed
FROM maf_tests t
JOIN maf_versions v ON t.version_id = v.id
WHERE t.test_code = 'V11-TEST-001';

-- Show V11 validation status
SELECT version, status, is_validated, validated_at, validated_by
FROM maf_versions
WHERE version = '11.0.0';

-- ════════════════════════════════════════════════════════════════════════════
-- END OF V11-TEST-001 RECORD
-- ════════════════════════════════════════════════════════════════════════════
