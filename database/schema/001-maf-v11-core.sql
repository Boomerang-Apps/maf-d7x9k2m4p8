-- ════════════════════════════════════════════════════════════════════════════
-- MAF V11.0.0 DATABASE SCHEMA
-- Core Tables for Framework Tracking and Validation
-- ════════════════════════════════════════════════════════════════════════════
-- 
-- SOURCE TRACEABILITY:
--   - /mnt/project/workflow-3_1-migration.sql (patterns)
--   - /mnt/project/WORKFLOW-V3_2-DATABASE-SOURCE-OF-TRUTH.md
--
-- PURPOSE:
--   Track test executions, document versions, and framework validation
--   Enable queries like:
--     - "Show me all V11 test results"
--     - "What changed between V10 and V11?"
--     - "Which test validated feature X?"
--
-- TABLES:
--   1. maf_versions      - Framework version registry
--   2. maf_documents     - Documentation with SHA-256 tracking
--   3. maf_tests         - Test execution history
--   4. maf_test_stories  - Stories executed in each test
--   5. maf_test_agents   - Agent performance per test
--   6. maf_test_gates    - Gate pass/fail per test
--
-- ════════════════════════════════════════════════════════════════════════════

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 1: MAF_VERSIONS
-- Registry of all MAF framework versions with validation status
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Version identification
    version VARCHAR(20) NOT NULL UNIQUE,      -- '11.0.0', '10.0.7'
    version_major INTEGER NOT NULL,            -- 11
    version_minor INTEGER NOT NULL,            -- 0
    version_patch INTEGER NOT NULL,            -- 0
    
    -- Metadata
    name VARCHAR(100),                         -- 'Bulletproof Framework'
    description TEXT,
    release_notes TEXT,
    
    -- Validation status
    is_validated BOOLEAN DEFAULT FALSE,
    validated_at TIMESTAMPTZ,
    validated_by VARCHAR(100),
    validation_test_id UUID,                   -- Reference to maf_tests
    
    -- Repository info
    git_tag VARCHAR(50),                       -- 'v11.0.0'
    git_commit_sha VARCHAR(40),
    repository_url VARCHAR(255),
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN (
        'draft',          -- Being developed
        'testing',        -- Under validation
        'validated',      -- Passed validation
        'deprecated',     -- Superseded by newer version
        'archived'        -- No longer supported
    )),
    
    -- Feature flags
    features JSONB DEFAULT '{}',
    /*
    {
        "locked_configurable_pattern": true,
        "8_gate_system": true,
        "fmea_analysis": true,
        "external_safety_enforcement": true
    }
    */
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for version queries
CREATE INDEX idx_maf_versions_status ON maf_versions(status);
CREATE INDEX idx_maf_versions_validated ON maf_versions(is_validated);

-- Insert V11.0.0
INSERT INTO maf_versions (version, version_major, version_minor, version_patch, name, description, status, features)
VALUES (
    '11.0.0', 11, 0, 0,
    'Bulletproof Framework',
    'Clean slate implementation with LOCKED/CONFIGURABLE pattern, aerospace-grade safety, and 8-gate validation',
    'testing',
    '{
        "locked_configurable_pattern": true,
        "8_gate_system": true,
        "fmea_analysis": true,
        "external_safety_enforcement": true,
        "forbidden_operations": 109,
        "failure_modes_analyzed": 17
    }'::jsonb
);

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 2: MAF_DOCUMENTS
-- Documentation tracking with SHA-256 change detection
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Document identification
    doc_code VARCHAR(50) NOT NULL,            -- 'SAFETY-PROTOCOL', 'GATE-SYSTEM'
    doc_path VARCHAR(255) NOT NULL,           -- 'core/SAFETY-PROTOCOL.md'
    version_id UUID REFERENCES maf_versions(id),
    
    -- Content tracking
    content_hash VARCHAR(64),                  -- SHA-256 hash for change detection
    content_size_bytes INTEGER,
    line_count INTEGER,
    
    -- Document metadata
    title VARCHAR(200),
    category VARCHAR(50) CHECK (category IN (
        'core',           -- Framework core (LOCKED)
        'template',       -- Reusable templates
        'validation',     -- Validation tools
        'operations',     -- Operations guides
        'project'         -- Project-specific
    )),
    
    -- Extraction metadata
    source_files TEXT[],                       -- Original source files
    extracted_at TIMESTAMPTZ DEFAULT NOW(),
    extracted_by VARCHAR(100),
    
    -- Validation
    is_validated BOOLEAN DEFAULT FALSE,
    validated_at TIMESTAMPTZ,
    validation_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Unique constraint per version
    UNIQUE(doc_code, version_id)
);

-- Indexes
CREATE INDEX idx_maf_documents_version ON maf_documents(version_id);
CREATE INDEX idx_maf_documents_category ON maf_documents(category);
CREATE INDEX idx_maf_documents_hash ON maf_documents(content_hash);

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 3: MAF_TESTS
-- Test execution history with costs and results
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Test identification
    test_code VARCHAR(50) NOT NULL UNIQUE,    -- 'V11-TEST-001', 'V10-TEST-014'
    test_name VARCHAR(200),                    -- 'First V11 Validation Test'
    version_id UUID REFERENCES maf_versions(id),
    
    -- Configuration
    config JSONB DEFAULT '{}',
    /*
    {
        "wave_count": 2,
        "agents_per_wave": 4,
        "model_dev": "claude-sonnet-4-20250514",
        "model_qa": "claude-haiku-4-5-20251001",
        "max_iterations": 25,
        "token_budget": 200000
    }
    */
    
    -- Execution
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending',        -- Created, not started
        'running',        -- In progress
        'completed',      -- Finished successfully
        'failed',         -- Finished with failures
        'aborted',        -- Manually stopped
        'timeout'         -- Exceeded time limit
    )),
    
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- Results
    stories_total INTEGER DEFAULT 0,
    stories_passed INTEGER DEFAULT 0,
    stories_failed INTEGER DEFAULT 0,
    gates_passed INTEGER DEFAULT 0,
    gates_failed INTEGER DEFAULT 0,
    
    -- Cost tracking
    total_input_tokens INTEGER DEFAULT 0,
    total_output_tokens INTEGER DEFAULT 0,
    total_cost_usd DECIMAL(10,4) DEFAULT 0,
    
    -- Infrastructure
    vm_count INTEGER DEFAULT 1,
    docker_containers INTEGER DEFAULT 0,
    
    -- Validation outcome
    is_validation_test BOOLEAN DEFAULT FALSE,
    validation_passed BOOLEAN,
    validation_notes TEXT,
    
    -- Artifacts
    artifacts JSONB DEFAULT '{}',
    /*
    {
        "report_path": "VALIDATION-REPORT-20260108.md",
        "log_files": ["agent-1.log", "agent-2.log"],
        "signal_directory": "/signals",
        "git_branch": "test/v11-test-001"
    }
    */
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_maf_tests_version ON maf_tests(version_id);
CREATE INDEX idx_maf_tests_status ON maf_tests(status);
CREATE INDEX idx_maf_tests_validation ON maf_tests(is_validation_test, validation_passed);

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 4: MAF_TEST_STORIES
-- Stories executed in each test with individual results
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_test_stories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    test_id UUID NOT NULL REFERENCES maf_tests(id) ON DELETE CASCADE,
    
    -- Story identification
    story_code VARCHAR(50) NOT NULL,          -- 'AUTH-FE-001'
    story_title VARCHAR(200),
    domain VARCHAR(50),                        -- 'auth', 'client'
    wave_number INTEGER,
    
    -- Assignment
    dev_agent VARCHAR(50),                     -- 'fe-auth'
    qa_agent VARCHAR(50),                      -- 'qa-auth'
    
    -- Execution
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending',
        'in_progress',
        'qa_review',
        'passed',
        'failed',
        'rejected',
        'skipped'
    )),
    
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- Results
    gates_completed INTEGER DEFAULT 0,
    qa_rejections INTEGER DEFAULT 0,
    
    -- Quality metrics
    test_coverage DECIMAL(5,2),               -- 85.50%
    tests_written INTEGER DEFAULT 0,
    tests_passed INTEGER DEFAULT 0,
    
    -- Cost
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    cost_usd DECIMAL(10,4) DEFAULT 0,
    
    -- Details
    details JSONB DEFAULT '{}',
    /*
    {
        "files_created": ["src/components/auth/LoginForm.tsx"],
        "commits": 5,
        "acceptance_criteria_met": ["AC-1", "AC-2", "AC-3"],
        "qa_feedback": "All criteria validated"
    }
    */
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Unique constraint
    UNIQUE(test_id, story_code)
);

-- Indexes
CREATE INDEX idx_maf_test_stories_test ON maf_test_stories(test_id);
CREATE INDEX idx_maf_test_stories_status ON maf_test_stories(status);
CREATE INDEX idx_maf_test_stories_domain ON maf_test_stories(domain);

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 5: MAF_TEST_AGENTS
-- Agent performance metrics per test
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_test_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    test_id UUID NOT NULL REFERENCES maf_tests(id) ON DELETE CASCADE,
    
    -- Agent identification
    agent_code VARCHAR(50) NOT NULL,          -- 'fe-auth', 'qa-core'
    agent_type VARCHAR(20) CHECK (agent_type IN ('dev', 'qa', 'pm', 'cto')),
    domain VARCHAR(50),
    model VARCHAR(100),
    
    -- Execution
    status VARCHAR(20) DEFAULT 'pending',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- Workload
    stories_assigned INTEGER DEFAULT 0,
    stories_completed INTEGER DEFAULT 0,
    stories_rejected INTEGER DEFAULT 0,
    
    -- Performance
    stuck_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    restart_count INTEGER DEFAULT 0,
    
    -- Cost
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    cost_usd DECIMAL(10,4) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Unique constraint
    UNIQUE(test_id, agent_code)
);

-- Indexes
CREATE INDEX idx_maf_test_agents_test ON maf_test_agents(test_id);
CREATE INDEX idx_maf_test_agents_type ON maf_test_agents(agent_type);

-- ════════════════════════════════════════════════════════════════════════════
-- TABLE 6: MAF_TEST_GATES
-- Gate pass/fail tracking per test
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS maf_test_gates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    test_id UUID NOT NULL REFERENCES maf_tests(id) ON DELETE CASCADE,
    story_id UUID REFERENCES maf_test_stories(id) ON DELETE CASCADE,
    agent_id UUID REFERENCES maf_test_agents(id),
    
    -- Gate identification
    gate_number INTEGER NOT NULL CHECK (gate_number >= 0 AND gate_number <= 7),
    gate_name VARCHAR(50) NOT NULL,           -- 'Research', 'Planning', etc.
    
    -- Result
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending',
        'in_progress',
        'passed',
        'failed',
        'skipped'
    )),
    
    -- Timing
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- Details
    details JSONB DEFAULT '{}',
    /*
    {
        "approver": "qa-auth",
        "criteria_checked": 5,
        "criteria_passed": 5,
        "notes": "All acceptance criteria validated"
    }
    */
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_maf_test_gates_test ON maf_test_gates(test_id);
CREATE INDEX idx_maf_test_gates_status ON maf_test_gates(status);
CREATE INDEX idx_maf_test_gates_number ON maf_test_gates(gate_number);

-- ════════════════════════════════════════════════════════════════════════════
-- VIEWS
-- Useful queries as reusable views
-- ════════════════════════════════════════════════════════════════════════════

-- View: Test summary with success rate
CREATE OR REPLACE VIEW maf_test_summary AS
SELECT 
    t.id,
    t.test_code,
    t.test_name,
    v.version,
    t.status,
    t.started_at,
    t.completed_at,
    t.duration_minutes,
    t.stories_total,
    t.stories_passed,
    t.stories_failed,
    CASE 
        WHEN t.stories_total > 0 
        THEN ROUND((t.stories_passed::decimal / t.stories_total) * 100, 1)
        ELSE 0 
    END AS success_rate_percent,
    t.total_cost_usd,
    t.is_validation_test,
    t.validation_passed
FROM maf_tests t
LEFT JOIN maf_versions v ON t.version_id = v.id
ORDER BY t.started_at DESC;

-- View: Cost breakdown by model
CREATE OR REPLACE VIEW maf_cost_by_model AS
SELECT 
    t.test_code,
    a.model,
    COUNT(DISTINCT a.agent_code) as agent_count,
    SUM(a.input_tokens) as total_input_tokens,
    SUM(a.output_tokens) as total_output_tokens,
    SUM(a.cost_usd) as total_cost
FROM maf_test_agents a
JOIN maf_tests t ON a.test_id = t.id
GROUP BY t.test_code, a.model
ORDER BY t.test_code, total_cost DESC;

-- View: Gate success rates
CREATE OR REPLACE VIEW maf_gate_success_rates AS
SELECT 
    gate_number,
    gate_name,
    COUNT(*) as total_attempts,
    SUM(CASE WHEN status = 'passed' THEN 1 ELSE 0 END) as passed,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
    ROUND(
        (SUM(CASE WHEN status = 'passed' THEN 1 ELSE 0 END)::decimal / 
        NULLIF(COUNT(*), 0)) * 100, 1
    ) as success_rate_percent
FROM maf_test_gates
WHERE status IN ('passed', 'failed')
GROUP BY gate_number, gate_name
ORDER BY gate_number;

-- ════════════════════════════════════════════════════════════════════════════
-- TRIGGERS
-- Automatic timestamp updates
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_maf_versions_updated_at
    BEFORE UPDATE ON maf_versions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maf_documents_updated_at
    BEFORE UPDATE ON maf_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maf_tests_updated_at
    BEFORE UPDATE ON maf_tests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maf_test_stories_updated_at
    BEFORE UPDATE ON maf_test_stories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maf_test_agents_updated_at
    BEFORE UPDATE ON maf_test_agents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ════════════════════════════════════════════════════════════════════════════
-- END OF SCHEMA
-- ════════════════════════════════════════════════════════════════════════════
