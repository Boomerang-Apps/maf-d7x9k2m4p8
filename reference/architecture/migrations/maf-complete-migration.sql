-- ═══════════════════════════════════════════════════════════════════════════════
-- MULTI-AGENT FRAMEWORK (MAF) - COMPLETE DATABASE MIGRATION
-- Version: 3.2
-- Date: January 7, 2026
-- For: AirView Multi-Agent Autonomous Development
-- 
-- This migration includes:
--   - Core orchestration tables (waves, stories, signals)
--   - Agent management tables (agent_sessions, agent_activity)
--   - Rollback system (rollback_history, agent_errors)
--   - QA reporting (qa_reports, gate_transitions)
--   - Stuck detection and emergency functions
--   - Dashboard views for monitoring
-- ═══════════════════════════════════════════════════════════════════════════════

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: CORE TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1.1 WAVES TABLE (Project Phases)
CREATE TABLE IF NOT EXISTS waves (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wave_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'planning'
        CHECK (status IN ('planning', 'active', 'paused', 'completed', 'failed')),
    priority INTEGER DEFAULT 1,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    paused_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.2 STORIES TABLE (Work Items)
CREATE TABLE IF NOT EXISTS stories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wave_id UUID REFERENCES waves(id),
    story_code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    acceptance_criteria JSONB DEFAULT '[]',
    domain VARCHAR(50) NOT NULL
        CHECK (domain IN ('auth', 'layout', 'core', 'client', 'pilot', 'project', 
                         'proposal', 'payment', 'deliverables', 'messaging', 
                         'admin', 'notifications')),
    story_type VARCHAR(50) DEFAULT 'feature'
        CHECK (story_type IN ('feature', 'bug', 'refactor', 'infrastructure')),
    priority INTEGER DEFAULT 1,
    story_points INTEGER DEFAULT 1,
    
    -- Assignment
    assigned_agent VARCHAR(100),
    assigned_at TIMESTAMPTZ,
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'backlog'
        CHECK (status IN ('backlog', 'ready', 'assigned', 'in_progress', 
                         'qa_review', 'pm_review', 'completed', 'failed', 'blocked')),
    current_gate INTEGER DEFAULT 0 CHECK (current_gate >= 0 AND current_gate <= 7),
    
    -- Git tracking
    branch_name VARCHAR(255),
    worktree_path VARCHAR(255),
    
    -- Timestamps
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.3 SIGNALS TABLE (Agent Communication)
CREATE TABLE IF NOT EXISTS signals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    signal_type VARCHAR(100) NOT NULL
        CHECK (signal_type IN (
            'story_assigned', 'ready_for_qa', 'qa_approved', 'qa_rejected',
            'ready_for_merge', 'merge_complete', 'merge_rejected',
            'blocked', 'help_needed', 'stuck_escalation',
            'gate_0_approved', 'gate_1_complete', 'gate_2_complete', 
            'gate_3_complete', 'gate_4_complete', 'gate_5_complete',
            'gate_6_complete', 'gate_7_complete',
            'emergency_stop', 'wave_start', 'wave_complete'
        )),
    from_agent VARCHAR(100) NOT NULL,
    to_agent VARCHAR(100), -- NULL means broadcast
    story_id UUID REFERENCES stories(id),
    wave_id UUID REFERENCES waves(id),
    payload JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'pending'
        CHECK (status IN ('pending', 'acknowledged', 'processed', 'expired')),
    priority VARCHAR(20) DEFAULT 'normal'
        CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    expires_at TIMESTAMPTZ,
    acknowledged_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.4 AGENT_SESSIONS TABLE (Active Agents)
CREATE TABLE IF NOT EXISTS agent_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id VARCHAR(100) UNIQUE NOT NULL,
    agent_type VARCHAR(50) NOT NULL
        CHECK (agent_type IN ('cto', 'pm', 'frontend', 'backend', 'qa', 'devops', 'security')),
    domain VARCHAR(50),
    model VARCHAR(100),
    vm_identifier VARCHAR(100),
    worktree_path VARCHAR(255),
    
    -- Status
    status VARCHAR(50) DEFAULT 'starting'
        CHECK (status IN ('starting', 'active', 'idle', 'working', 'blocked', 'stuck', 'terminated')),
    current_story_id UUID REFERENCES stories(id),
    current_gate INTEGER,
    wave_id UUID REFERENCES waves(id),
    
    -- Health tracking
    last_heartbeat TIMESTAMPTZ DEFAULT NOW(),
    total_tokens_used INTEGER DEFAULT 0,
    total_stories_completed INTEGER DEFAULT 0,
    
    -- Stuck detection
    iteration_count INTEGER DEFAULT 0,
    max_iterations INTEGER DEFAULT 25,
    consecutive_same_error INTEGER DEFAULT 0,
    last_error_type VARCHAR(50),
    last_error TEXT,
    stuck_detected_at TIMESTAMPTZ,
    stuck_reason TEXT,
    
    -- Checkpoint tracking
    last_checkpoint JSONB,
    rollback_checkpoints JSONB DEFAULT '[]'::JSONB,
    
    -- Session info
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

-- 1.5 AGENT_ACTIVITY TABLE (Audit Log)
CREATE TABLE IF NOT EXISTS agent_activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id VARCHAR(100) NOT NULL,
    wave_id UUID REFERENCES waves(id),
    story_id UUID REFERENCES stories(id),
    activity_type VARCHAR(100) NOT NULL,
    message TEXT,
    severity VARCHAR(20) DEFAULT 'info'
        CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),
    details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: GATE SYSTEM TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

-- 2.1 GATE_TRANSITIONS TABLE (Gate History)
CREATE TABLE IF NOT EXISTS gate_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID REFERENCES stories(id) NOT NULL,
    from_gate INTEGER,
    to_gate INTEGER NOT NULL CHECK (to_gate >= 0 AND to_gate <= 7),
    agent_id VARCHAR(100) NOT NULL,
    transition_type VARCHAR(50) NOT NULL
        CHECK (transition_type IN ('advance', 'reject', 'reset', 'skip')),
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.2 QA_REPORTS TABLE (QA Validation Results)
CREATE TABLE IF NOT EXISTS qa_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID REFERENCES stories(id) NOT NULL,
    qa_agent VARCHAR(100) NOT NULL,
    verdict VARCHAR(20) NOT NULL
        CHECK (verdict IN ('PASS', 'FAIL', 'BLOCKED', 'PARTIAL')),
    test_coverage DECIMAL(5,2),
    tests_passed INTEGER,
    tests_total INTEGER,
    bugs_found JSONB DEFAULT '[]',
    failed_criteria JSONB DEFAULT '[]',
    security_issues JSONB DEFAULT '[]',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: ROLLBACK SYSTEM TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

-- 3.1 ROLLBACK_HISTORY TABLE (Git Checkpoints)
CREATE TABLE IF NOT EXISTS rollback_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES agent_sessions(id) ON DELETE SET NULL,
    story_id VARCHAR(50),
    story_code VARCHAR(50),
    wave_id UUID REFERENCES waves(id) ON DELETE SET NULL,
    agent_id VARCHAR(50) NOT NULL,
    
    -- Git state
    commit_before VARCHAR(40) NOT NULL,
    commit_after VARCHAR(40),
    branch_name VARCHAR(100),
    worktree_path VARCHAR(255),
    
    -- Files affected
    files_created TEXT[] DEFAULT '{}',
    files_modified TEXT[] DEFAULT '{}',
    files_deleted TEXT[] DEFAULT '{}',
    
    -- Rollback command
    rollback_command TEXT NOT NULL,
    
    -- Rollback execution
    rolled_back_at TIMESTAMPTZ,
    rolled_back_by VARCHAR(50),
    rollback_reason TEXT,
    rollback_type VARCHAR(20) DEFAULT 'standard'
        CHECK (rollback_type IN ('standard', 'emergency', 'qa_rejection', 'manual')),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active'
        CHECK (status IN ('active', 'rolled_back', 'superseded', 'completed')),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.2 AGENT_ERRORS TABLE (Error Memory)
CREATE TABLE IF NOT EXISTS agent_errors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES agent_sessions(id) ON DELETE CASCADE,
    story_id VARCHAR(50),
    story_code VARCHAR(50),
    wave_id UUID REFERENCES waves(id) ON DELETE SET NULL,
    agent_id VARCHAR(50) NOT NULL,
    checkpoint_id UUID REFERENCES rollback_history(id) ON DELETE SET NULL,
    
    -- Error classification
    error_type VARCHAR(50) NOT NULL
        CHECK (error_type IN (
            'syntax', 'type_error', 'test_failure', 'runtime', 'import',
            'timeout', 'build', 'lint', 'coverage', 'validation', 'unknown'
        )),
    
    -- Error details
    error_message TEXT NOT NULL,
    error_stack TEXT,
    file_path VARCHAR(500),
    line_number INTEGER,
    
    -- Approach tracking
    approach_used TEXT,
    approach_hash VARCHAR(64),
    
    -- Retry tracking
    retry_attempt INTEGER DEFAULT 1,
    max_retries INTEGER DEFAULT 3,
    
    -- Resolution
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    resolution_approach TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: INDEXES
-- ═══════════════════════════════════════════════════════════════════════════════

-- Stories indexes
CREATE INDEX IF NOT EXISTS idx_stories_status ON stories(status);
CREATE INDEX IF NOT EXISTS idx_stories_domain ON stories(domain);
CREATE INDEX IF NOT EXISTS idx_stories_assigned_agent ON stories(assigned_agent);
CREATE INDEX IF NOT EXISTS idx_stories_wave ON stories(wave_id);
CREATE INDEX IF NOT EXISTS idx_stories_gate ON stories(current_gate);

-- Signals indexes
CREATE INDEX IF NOT EXISTS idx_signals_to_agent ON signals(to_agent);
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_story_id ON signals(story_id);
CREATE INDEX IF NOT EXISTS idx_signals_type ON signals(signal_type);
CREATE INDEX IF NOT EXISTS idx_signals_pending ON signals(to_agent, status) WHERE status = 'pending';

-- Agent sessions indexes
CREATE INDEX IF NOT EXISTS idx_agent_sessions_status ON agent_sessions(status);
CREATE INDEX IF NOT EXISTS idx_agent_sessions_wave ON agent_sessions(wave_id);
CREATE INDEX IF NOT EXISTS idx_agent_sessions_stuck ON agent_sessions(stuck_detected_at) 
    WHERE stuck_detected_at IS NOT NULL;

-- Activity indexes
CREATE INDEX IF NOT EXISTS idx_agent_activity_agent ON agent_activity(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_activity_created ON agent_activity(created_at DESC);

-- Rollback indexes
CREATE INDEX IF NOT EXISTS idx_rollback_history_session ON rollback_history(session_id);
CREATE INDEX IF NOT EXISTS idx_rollback_history_story ON rollback_history(story_code);
CREATE INDEX IF NOT EXISTS idx_rollback_history_active ON rollback_history(status) WHERE status = 'active';

-- Error indexes
CREATE INDEX IF NOT EXISTS idx_agent_errors_session ON agent_errors(session_id);
CREATE INDEX IF NOT EXISTS idx_agent_errors_story ON agent_errors(story_code);
CREATE INDEX IF NOT EXISTS idx_agent_errors_type ON agent_errors(error_type);
CREATE INDEX IF NOT EXISTS idx_agent_errors_unresolved ON agent_errors(session_id, error_type) 
    WHERE resolved = FALSE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER update_waves_updated_at
    BEFORE UPDATE ON waves
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_stories_updated_at
    BEFORE UPDATE ON stories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_rollback_history_updated_at
    BEFORE UPDATE ON rollback_history
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: CORE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 6.1 Send signal between agents
CREATE OR REPLACE FUNCTION send_signal(
    p_signal_type VARCHAR(100),
    p_from_agent VARCHAR(100),
    p_to_agent VARCHAR(100),
    p_story_id UUID DEFAULT NULL,
    p_payload JSONB DEFAULT '{}'::JSONB,
    p_priority VARCHAR(20) DEFAULT 'normal'
)
RETURNS UUID AS $$
DECLARE
    v_signal_id UUID;
    v_wave_id UUID;
BEGIN
    -- Get wave_id from story if provided
    IF p_story_id IS NOT NULL THEN
        SELECT wave_id INTO v_wave_id FROM stories WHERE id = p_story_id;
    END IF;
    
    -- Insert signal
    INSERT INTO signals (
        signal_type, from_agent, to_agent, story_id, wave_id, payload, priority
    ) VALUES (
        p_signal_type, p_from_agent, p_to_agent, p_story_id, v_wave_id, p_payload, p_priority
    )
    RETURNING id INTO v_signal_id;
    
    -- Log activity
    INSERT INTO agent_activity (agent_id, story_id, wave_id, activity_type, message, details)
    VALUES (
        p_from_agent, p_story_id, v_wave_id, 'signal_sent',
        format('Signal %s sent to %s', p_signal_type, COALESCE(p_to_agent, 'broadcast')),
        jsonb_build_object('signal_id', v_signal_id, 'signal_type', p_signal_type, 'payload', p_payload)
    );
    
    RETURN v_signal_id;
END;
$$ LANGUAGE plpgsql;

-- 6.2 Advance story gate
CREATE OR REPLACE FUNCTION advance_gate(
    p_story_id UUID,
    p_agent_id VARCHAR(100),
    p_notes TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_current_gate INTEGER;
    v_new_gate INTEGER;
BEGIN
    -- Get current gate
    SELECT current_gate INTO v_current_gate FROM stories WHERE id = p_story_id;
    
    IF v_current_gate >= 7 THEN
        RAISE EXCEPTION 'Story already at final gate (7)';
    END IF;
    
    v_new_gate := v_current_gate + 1;
    
    -- Update story
    UPDATE stories SET current_gate = v_new_gate WHERE id = p_story_id;
    
    -- Record transition
    INSERT INTO gate_transitions (story_id, from_gate, to_gate, agent_id, transition_type, notes)
    VALUES (p_story_id, v_current_gate, v_new_gate, p_agent_id, 'advance', p_notes);
    
    RETURN v_new_gate;
END;
$$ LANGUAGE plpgsql;

-- 6.3 Create rollback checkpoint
CREATE OR REPLACE FUNCTION create_rollback_checkpoint(
    p_session_id UUID,
    p_story_id VARCHAR(50),
    p_story_code VARCHAR(50),
    p_commit_hash VARCHAR(40),
    p_branch_name VARCHAR(100) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_checkpoint_id UUID;
    v_wave_id UUID;
    v_agent_id VARCHAR(50);
    v_worktree_path VARCHAR(255);
BEGIN
    -- Get session info
    SELECT wave_id, agent_id, worktree_path 
    INTO v_wave_id, v_agent_id, v_worktree_path
    FROM agent_sessions WHERE id = p_session_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Session not found: %', p_session_id;
    END IF;
    
    -- Mark previous checkpoints as superseded
    UPDATE rollback_history
    SET status = 'superseded', updated_at = NOW()
    WHERE session_id = p_session_id AND status = 'active';
    
    -- Create new checkpoint
    INSERT INTO rollback_history (
        session_id, story_id, story_code, wave_id, agent_id,
        commit_before, branch_name, worktree_path, rollback_command, status
    ) VALUES (
        p_session_id, p_story_id, p_story_code, v_wave_id, v_agent_id,
        p_commit_hash, p_branch_name, v_worktree_path,
        format('git reset --hard %s', p_commit_hash), 'active'
    )
    RETURNING id INTO v_checkpoint_id;
    
    -- Update session
    UPDATE agent_sessions
    SET last_checkpoint = jsonb_build_object(
        'checkpointId', v_checkpoint_id,
        'storyCode', p_story_code,
        'commitBefore', p_commit_hash,
        'createdAt', NOW()
    )
    WHERE id = p_session_id;
    
    RETURN v_checkpoint_id;
END;
$$ LANGUAGE plpgsql;

-- 6.4 Check if agent is stuck
CREATE OR REPLACE FUNCTION check_agent_stuck(p_session_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_session RECORD;
    v_is_stuck BOOLEAN := FALSE;
    v_stuck_reason TEXT;
BEGIN
    SELECT * INTO v_session FROM agent_sessions WHERE id = p_session_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('isStuck', FALSE, 'reason', 'Session not found');
    END IF;
    
    -- Check stuck conditions
    IF v_session.iteration_count >= v_session.max_iterations THEN
        v_is_stuck := TRUE;
        v_stuck_reason := format('Max iterations reached (%s/%s)', 
            v_session.iteration_count, v_session.max_iterations);
    ELSIF v_session.consecutive_same_error >= 3 THEN
        v_is_stuck := TRUE;
        v_stuck_reason := format('Same error repeated %s times: %s',
            v_session.consecutive_same_error, v_session.last_error_type);
    END IF;
    
    -- Update session if stuck
    IF v_is_stuck AND v_session.stuck_detected_at IS NULL THEN
        UPDATE agent_sessions
        SET stuck_detected_at = NOW(), stuck_reason = v_stuck_reason, status = 'stuck'
        WHERE id = p_session_id;
        
        -- Send escalation signal
        INSERT INTO signals (signal_type, story_id, wave_id, from_agent, to_agent, payload, priority)
        VALUES (
            'stuck_escalation', v_session.current_story_id, v_session.wave_id,
            v_session.agent_id, 'pm',
            jsonb_build_object(
                'sessionId', p_session_id,
                'agentId', v_session.agent_id,
                'reason', v_stuck_reason,
                'iterationCount', v_session.iteration_count,
                'consecutiveSameError', v_session.consecutive_same_error
            ),
            'high'
        );
    END IF;
    
    RETURN jsonb_build_object(
        'isStuck', v_is_stuck,
        'reason', v_stuck_reason,
        'iterationCount', v_session.iteration_count,
        'maxIterations', v_session.max_iterations,
        'consecutiveSameError', v_session.consecutive_same_error,
        'lastErrorType', v_session.last_error_type
    );
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: DASHBOARD VIEWS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 7.1 Active agents view
CREATE OR REPLACE VIEW active_agents AS
SELECT 
    s.id as session_id,
    s.agent_id,
    s.agent_type,
    s.domain,
    s.status,
    s.current_gate,
    st.story_code,
    st.title as story_title,
    w.name as wave_name,
    s.iteration_count,
    s.max_iterations,
    s.last_heartbeat,
    EXTRACT(EPOCH FROM (NOW() - s.last_heartbeat)) / 60 as minutes_since_heartbeat,
    s.total_tokens_used,
    s.total_stories_completed
FROM agent_sessions s
LEFT JOIN stories st ON st.id = s.current_story_id
LEFT JOIN waves w ON w.id = s.wave_id
WHERE s.status NOT IN ('terminated')
ORDER BY s.agent_type, s.domain;

-- 7.2 Story progress view
CREATE OR REPLACE VIEW story_progress AS
SELECT 
    s.story_code,
    s.title,
    s.domain,
    s.status,
    s.current_gate,
    s.assigned_agent,
    w.name as wave_name,
    s.started_at,
    s.completed_at,
    CASE 
        WHEN s.completed_at IS NOT NULL THEN 
            EXTRACT(EPOCH FROM (s.completed_at - s.started_at)) / 3600
        ELSE 
            EXTRACT(EPOCH FROM (NOW() - s.started_at)) / 3600
    END as hours_elapsed,
    (SELECT COUNT(*) FROM qa_reports qr WHERE qr.story_id = s.id) as qa_report_count
FROM stories s
LEFT JOIN waves w ON w.id = s.wave_id
ORDER BY 
    CASE s.status 
        WHEN 'in_progress' THEN 1 
        WHEN 'qa_review' THEN 2 
        WHEN 'pm_review' THEN 3 
        ELSE 4 
    END,
    s.current_gate DESC;

-- 7.3 Stuck agents summary
CREATE OR REPLACE VIEW stuck_agents_summary AS
SELECT 
    s.id as session_id,
    s.agent_id,
    s.current_story_id,
    st.story_code,
    s.stuck_reason,
    s.stuck_detected_at,
    s.iteration_count,
    s.max_iterations,
    s.consecutive_same_error,
    s.last_error_type,
    w.name as wave_name,
    rh.commit_before as rollback_commit,
    rh.rollback_command
FROM agent_sessions s
LEFT JOIN stories st ON st.id = s.current_story_id
LEFT JOIN waves w ON w.id = s.wave_id
LEFT JOIN rollback_history rh ON rh.session_id = s.id AND rh.status = 'active'
WHERE s.stuck_detected_at IS NOT NULL
   OR s.consecutive_same_error >= 3
   OR s.iteration_count >= s.max_iterations
ORDER BY s.stuck_detected_at DESC NULLS LAST;

-- 7.4 Signal queue view
CREATE OR REPLACE VIEW signal_queue AS
SELECT 
    sig.id,
    sig.signal_type,
    sig.from_agent,
    sig.to_agent,
    sig.status,
    sig.priority,
    st.story_code,
    w.name as wave_name,
    sig.payload,
    sig.created_at,
    EXTRACT(EPOCH FROM (NOW() - sig.created_at)) / 60 as minutes_pending
FROM signals sig
LEFT JOIN stories st ON st.id = sig.story_id
LEFT JOIN waves w ON w.id = sig.wave_id
WHERE sig.status = 'pending'
ORDER BY 
    CASE sig.priority 
        WHEN 'critical' THEN 1 
        WHEN 'high' THEN 2 
        WHEN 'normal' THEN 3 
        ELSE 4 
    END,
    sig.created_at;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE waves ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE gate_transitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE rollback_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_errors ENABLE ROW LEVEL SECURITY;

-- Allow all operations with anon key (for agents)
CREATE POLICY "Allow all for anon" ON waves FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON stories FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON signals FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON agent_sessions FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON agent_activity FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON gate_transitions FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON qa_reports FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON rollback_history FOR ALL USING (true);
CREATE POLICY "Allow all for anon" ON agent_errors FOR ALL USING (true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- MIGRATION COMPLETE
-- ═══════════════════════════════════════════════════════════════════════════════
