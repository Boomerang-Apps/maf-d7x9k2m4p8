/**
 * ═══════════════════════════════════════════════════════════════════════════════
 * MAF SIGNAL HELPERS - Agent Communication Library
 * Version: 1.0.0
 * Date: January 7, 2026
 * For: AirView Multi-Agent Framework
 * 
 * This module provides TypeScript helpers for:
 *   - Sending signals between agents
 *   - Receiving and processing signals
 *   - Gate transitions
 *   - Session management
 *   - QA reporting
 *   - Error recording
 * ═══════════════════════════════════════════════════════════════════════════════
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js'

// ═══════════════════════════════════════════════════════════════════════════════
// TYPES
// ═══════════════════════════════════════════════════════════════════════════════

export type SignalType =
  | 'story_assigned'
  | 'ready_for_qa'
  | 'qa_approved'
  | 'qa_rejected'
  | 'ready_for_merge'
  | 'merge_complete'
  | 'merge_rejected'
  | 'blocked'
  | 'help_needed'
  | 'stuck_escalation'
  | 'gate_0_approved'
  | 'gate_1_complete'
  | 'gate_2_complete'
  | 'gate_3_complete'
  | 'gate_4_complete'
  | 'gate_5_complete'
  | 'gate_6_complete'
  | 'gate_7_complete'
  | 'emergency_stop'
  | 'wave_start'
  | 'wave_complete'

export type AgentType = 'cto' | 'pm' | 'frontend' | 'backend' | 'qa' | 'devops' | 'security'

export type StoryStatus = 
  | 'backlog' 
  | 'ready' 
  | 'assigned' 
  | 'in_progress' 
  | 'qa_review' 
  | 'pm_review' 
  | 'completed' 
  | 'failed' 
  | 'blocked'

export type QAVerdict = 'PASS' | 'FAIL' | 'BLOCKED' | 'PARTIAL'

export interface Signal {
  id: string
  signal_type: SignalType
  from_agent: string
  to_agent: string | null
  story_id: string | null
  wave_id: string | null
  payload: Record<string, any>
  status: 'pending' | 'acknowledged' | 'processed' | 'expired'
  priority: 'low' | 'normal' | 'high' | 'critical'
  created_at: string
}

export interface Story {
  id: string
  story_code: string
  title: string
  domain: string
  status: StoryStatus
  current_gate: number
  assigned_agent: string | null
  wave_id: string | null
}

export interface AgentSession {
  id: string
  agent_id: string
  agent_type: AgentType
  domain: string | null
  status: string
  current_story_id: string | null
  current_gate: number | null
  iteration_count: number
  max_iterations: number
}

export interface QAReport {
  story_id: string
  qa_agent: string
  verdict: QAVerdict
  test_coverage: number
  tests_passed: number
  tests_total: number
  bugs_found?: Array<{ id: string; description: string; severity: string }>
  failed_criteria?: string[]
  notes?: string
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUPABASE CLIENT
// ═══════════════════════════════════════════════════════════════════════════════

let supabaseClient: SupabaseClient | null = null

export function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    const url = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL
    const key = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    
    if (!url || !key) {
      throw new Error('Missing Supabase environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)')
    }
    
    supabaseClient = createClient(url, key)
  }
  return supabaseClient
}

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL SENDING
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Send a signal to another agent
 */
export async function sendSignal(params: {
  signalType: SignalType
  fromAgent: string
  toAgent: string | null
  storyId?: string
  payload?: Record<string, any>
  priority?: 'low' | 'normal' | 'high' | 'critical'
}): Promise<string> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase.rpc('send_signal', {
    p_signal_type: params.signalType,
    p_from_agent: params.fromAgent,
    p_to_agent: params.toAgent,
    p_story_id: params.storyId || null,
    p_payload: params.payload || {},
    p_priority: params.priority || 'normal'
  })
  
  if (error) {
    console.error('❌ Failed to send signal:', error)
    throw error
  }
  
  console.log(`✅ Signal sent: ${params.signalType} → ${params.toAgent || 'broadcast'}`)
  return data
}

/**
 * Signal that work is ready for QA
 */
export async function signalReadyForQA(
  fromAgent: string,
  toQAAgent: string,
  storyId: string,
  data: {
    branch: string
    coverage: number
    testsPassed: number
    testsTotal: number
  }
): Promise<string> {
  return sendSignal({
    signalType: 'ready_for_qa',
    fromAgent,
    toAgent: toQAAgent,
    storyId,
    payload: {
      branch: data.branch,
      coverage: data.coverage,
      tests_passed: data.testsPassed,
      tests_total: data.testsTotal,
      timestamp: new Date().toISOString()
    }
  })
}

/**
 * Signal QA approval to PM
 */
export async function signalQAApproved(
  qaAgent: string,
  storyId: string,
  report: {
    coverage: number
    testsPassed: number
    testsTotal: number
    notes?: string
  }
): Promise<string> {
  return sendSignal({
    signalType: 'qa_approved',
    fromAgent: qaAgent,
    toAgent: 'pm',
    storyId,
    payload: {
      verdict: 'PASS',
      coverage: report.coverage,
      tests_passed: report.testsPassed,
      tests_total: report.testsTotal,
      notes: report.notes || 'All acceptance criteria validated',
      approved_at: new Date().toISOString()
    }
  })
}

/**
 * Signal QA rejection back to Dev
 */
export async function signalQARejected(
  qaAgent: string,
  devAgent: string,
  storyId: string,
  report: {
    failedCriteria: string[]
    bugs: Array<{ id: string; description: string }>
    requiredFixes: string[]
  }
): Promise<string> {
  return sendSignal({
    signalType: 'qa_rejected',
    fromAgent: qaAgent,
    toAgent: devAgent,
    storyId,
    payload: {
      verdict: 'FAIL',
      failed_criteria: report.failedCriteria,
      bugs: report.bugs,
      required_fixes: report.requiredFixes,
      rejected_at: new Date().toISOString()
    },
    priority: 'high'
  })
}

/**
 * Signal ready for merge to CTO
 */
export async function signalReadyForMerge(
  pmAgent: string,
  storyId: string,
  data: {
    qaApproval: string
    reviewNotes?: string
  }
): Promise<string> {
  return sendSignal({
    signalType: 'ready_for_merge',
    fromAgent: pmAgent,
    toAgent: 'cto',
    storyId,
    payload: {
      pm_approved: true,
      qa_approval: data.qaApproval,
      review_notes: data.reviewNotes || 'All checks passed',
      ready_at: new Date().toISOString()
    }
  })
}

/**
 * Signal merge complete (broadcast)
 */
export async function signalMergeComplete(
  storyId: string,
  data: {
    branch: string
    commitSha: string
    mergedBy: string
  }
): Promise<string> {
  return sendSignal({
    signalType: 'merge_complete',
    fromAgent: 'cto',
    toAgent: null, // Broadcast
    storyId,
    payload: {
      branch: data.branch,
      commit_sha: data.commitSha,
      merged_by: data.mergedBy,
      merged_at: new Date().toISOString()
    }
  })
}

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL RECEIVING
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Get pending signals for an agent
 */
export async function getPendingSignals(agentId: string): Promise<Signal[]> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase
    .from('signals')
    .select('*')
    .or(`to_agent.eq.${agentId},to_agent.is.null`)
    .eq('status', 'pending')
    .order('priority', { ascending: false })
    .order('created_at', { ascending: true })
  
  if (error) {
    console.error('❌ Failed to get pending signals:', error)
    throw error
  }
  
  return data || []
}

/**
 * Acknowledge a signal
 */
export async function acknowledgeSignal(signalId: string): Promise<void> {
  const supabase = getSupabaseClient()
  
  const { error } = await supabase
    .from('signals')
    .update({
      status: 'acknowledged',
      acknowledged_at: new Date().toISOString()
    })
    .eq('id', signalId)
  
  if (error) {
    console.error('❌ Failed to acknowledge signal:', error)
    throw error
  }
}

/**
 * Mark a signal as processed
 */
export async function processSignal(signalId: string): Promise<void> {
  const supabase = getSupabaseClient()
  
  const { error } = await supabase
    .from('signals')
    .update({
      status: 'processed',
      processed_at: new Date().toISOString()
    })
    .eq('id', signalId)
  
  if (error) {
    console.error('❌ Failed to process signal:', error)
    throw error
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GATE MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Advance story to next gate
 */
export async function advanceGate(
  storyId: string,
  agentId: string,
  notes?: string
): Promise<number> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase.rpc('advance_gate', {
    p_story_id: storyId,
    p_agent_id: agentId,
    p_notes: notes || null
  })
  
  if (error) {
    console.error('❌ Failed to advance gate:', error)
    throw error
  }
  
  console.log(`✅ Advanced to Gate ${data}`)
  return data
}

/**
 * Update story status
 */
export async function updateStoryStatus(
  storyCode: string,
  status: StoryStatus,
  gate?: number
): Promise<void> {
  const supabase = getSupabaseClient()
  
  const updateData: Record<string, any> = { status }
  if (gate !== undefined) {
    updateData.current_gate = gate
  }
  
  const { error } = await supabase
    .from('stories')
    .update(updateData)
    .eq('story_code', storyCode)
  
  if (error) {
    console.error('❌ Failed to update story status:', error)
    throw error
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// QA REPORTING
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Submit QA report
 */
export async function submitQAReport(report: QAReport): Promise<string> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase
    .from('qa_reports')
    .insert({
      story_id: report.story_id,
      qa_agent: report.qa_agent,
      verdict: report.verdict,
      test_coverage: report.test_coverage,
      tests_passed: report.tests_passed,
      tests_total: report.tests_total,
      bugs_found: report.bugs_found || [],
      failed_criteria: report.failed_criteria || [],
      notes: report.notes
    })
    .select('id')
    .single()
  
  if (error) {
    console.error('❌ Failed to submit QA report:', error)
    throw error
  }
  
  console.log(`✅ QA Report submitted: ${report.verdict}`)
  return data.id
}

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Register agent session
 */
export async function registerSession(params: {
  agentId: string
  agentType: AgentType
  domain?: string
  waveId?: string
}): Promise<string> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase
    .from('agent_sessions')
    .upsert({
      agent_id: params.agentId,
      agent_type: params.agentType,
      domain: params.domain || null,
      wave_id: params.waveId || null,
      status: 'active',
      started_at: new Date().toISOString(),
      last_heartbeat: new Date().toISOString()
    }, {
      onConflict: 'agent_id'
    })
    .select('id')
    .single()
  
  if (error) {
    console.error('❌ Failed to register session:', error)
    throw error
  }
  
  console.log(`✅ Session registered: ${params.agentId}`)
  return data.id
}

/**
 * Send heartbeat
 */
export async function sendHeartbeat(agentId: string): Promise<void> {
  const supabase = getSupabaseClient()
  
  const { error } = await supabase
    .from('agent_sessions')
    .update({ last_heartbeat: new Date().toISOString() })
    .eq('agent_id', agentId)
  
  if (error) {
    console.error('❌ Failed to send heartbeat:', error)
  }
}

/**
 * Increment iteration count
 */
export async function incrementIteration(sessionId: string): Promise<void> {
  const supabase = getSupabaseClient()
  
  const { error } = await supabase.rpc('increment_iteration', {
    p_session_id: sessionId
  })
  
  if (error) {
    console.error('❌ Failed to increment iteration:', error)
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STORY QUERIES
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Get assigned stories for an agent
 */
export async function getAssignedStories(agentId: string): Promise<Story[]> {
  const supabase = getSupabaseClient()
  
  const { data, error } = await supabase
    .from('stories')
    .select('*')
    .eq('assigned_agent', agentId)
    .in('status', ['assigned', 'in_progress', 'qa_review'])
    .order('priority', { ascending: false })
  
  if (error) {
    console.error('❌ Failed to get assigned stories:', error)
    throw error
  }
  
  return data || []
}

/**
 * Get stories ready for assignment
 */
export async function getReadyStories(domain?: string): Promise<Story[]> {
  const supabase = getSupabaseClient()
  
  let query = supabase
    .from('stories')
    .select('*')
    .eq('status', 'ready')
    .is('assigned_agent', null)
    .order('priority', { ascending: false })
  
  if (domain) {
    query = query.eq('domain', domain)
  }
  
  const { data, error } = await query
  
  if (error) {
    console.error('❌ Failed to get ready stories:', error)
    throw error
  }
  
  return data || []
}

// ═══════════════════════════════════════════════════════════════════════════════
// POLLING HELPER
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Start polling for signals
 */
export function startSignalPolling(
  agentId: string,
  onSignal: (signal: Signal) => Promise<void>,
  intervalMs: number = 30000
): () => void {
  let isRunning = true
  
  const poll = async () => {
    while (isRunning) {
      try {
        const signals = await getPendingSignals(agentId)
        
        for (const signal of signals) {
          await acknowledgeSignal(signal.id)
          await onSignal(signal)
          await processSignal(signal.id)
        }
      } catch (error) {
        console.error('❌ Polling error:', error)
      }
      
      await new Promise(resolve => setTimeout(resolve, intervalMs))
    }
  }
  
  poll()
  
  // Return stop function
  return () => { isRunning = false }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════════════════════════

export default {
  // Client
  getSupabaseClient,
  
  // Sending signals
  sendSignal,
  signalReadyForQA,
  signalQAApproved,
  signalQARejected,
  signalReadyForMerge,
  signalMergeComplete,
  
  // Receiving signals
  getPendingSignals,
  acknowledgeSignal,
  processSignal,
  
  // Gate management
  advanceGate,
  updateStoryStatus,
  
  // QA
  submitQAReport,
  
  // Session
  registerSession,
  sendHeartbeat,
  incrementIteration,
  
  // Queries
  getAssignedStories,
  getReadyStories,
  
  // Polling
  startSignalPolling
}
