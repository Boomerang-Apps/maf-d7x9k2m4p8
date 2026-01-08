/**
 * MAF V11.0.0 Database Helpers
 * 
 * TypeScript utilities for interacting with the MAF database.
 * 
 * SOURCE TRACEABILITY:
 *   - /mnt/project/02-rollback-helpers.ts (patterns)
 *   - /mnt/project/index.ts (Supabase client)
 * 
 * Usage:
 *   import { MafDb } from './maf-db';
 *   const db = new MafDb(supabaseClient);
 *   const tests = await db.getTests();
 */

import { SupabaseClient } from '@supabase/supabase-js';

// ════════════════════════════════════════════════════════════════════════════
// TYPES
// ════════════════════════════════════════════════════════════════════════════

export interface MafVersion {
  id: string;
  version: string;
  version_major: number;
  version_minor: number;
  version_patch: number;
  name: string;
  description: string;
  status: 'draft' | 'testing' | 'validated' | 'deprecated' | 'archived';
  is_validated: boolean;
  features: Record<string, any>;
  created_at: string;
}

export interface MafDocument {
  id: string;
  doc_code: string;
  doc_path: string;
  version_id: string;
  title: string;
  category: 'core' | 'template' | 'validation' | 'operations' | 'project';
  content_hash: string;
  source_files: string[];
  is_validated: boolean;
  created_at: string;
}

export interface MafTest {
  id: string;
  test_code: string;
  test_name: string;
  version_id: string;
  status: 'pending' | 'running' | 'completed' | 'failed' | 'aborted' | 'timeout';
  config: Record<string, any>;
  stories_total: number;
  stories_passed: number;
  stories_failed: number;
  total_cost_usd: number;
  is_validation_test: boolean;
  validation_passed: boolean;
  started_at: string;
  completed_at: string;
}

export interface MafTestStory {
  id: string;
  test_id: string;
  story_code: string;
  story_title: string;
  domain: string;
  wave_number: number;
  dev_agent: string;
  qa_agent: string;
  status: 'pending' | 'in_progress' | 'qa_review' | 'passed' | 'failed' | 'rejected' | 'skipped';
  test_coverage: number;
  cost_usd: number;
}

export interface CreateTestInput {
  test_code: string;
  test_name: string;
  version?: string;
  config?: Record<string, any>;
  is_validation_test?: boolean;
}

export interface RecordStoryInput {
  test_id: string;
  story_code: string;
  story_title: string;
  domain: string;
  wave_number: number;
  dev_agent: string;
  qa_agent: string;
}

// ════════════════════════════════════════════════════════════════════════════
// DATABASE CLASS
// ════════════════════════════════════════════════════════════════════════════

export class MafDb {
  private supabase: SupabaseClient;

  constructor(supabaseClient: SupabaseClient) {
    this.supabase = supabaseClient;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VERSIONS
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Get all MAF versions
   */
  async getVersions(): Promise<MafVersion[]> {
    const { data, error } = await this.supabase
      .from('maf_versions')
      .select('*')
      .order('version_major', { ascending: false })
      .order('version_minor', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  /**
   * Get version by version string
   */
  async getVersion(version: string): Promise<MafVersion | null> {
    const { data, error } = await this.supabase
      .from('maf_versions')
      .select('*')
      .eq('version', version)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  /**
   * Get current (latest) version
   */
  async getCurrentVersion(): Promise<MafVersion | null> {
    const { data, error } = await this.supabase
      .from('maf_versions')
      .select('*')
      .eq('status', 'testing')
      .order('version_major', { ascending: false })
      .limit(1)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DOCUMENTS
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Get all documents for a version
   */
  async getDocuments(version: string): Promise<MafDocument[]> {
    const versionRecord = await this.getVersion(version);
    if (!versionRecord) return [];

    const { data, error } = await this.supabase
      .from('maf_documents')
      .select('*')
      .eq('version_id', versionRecord.id)
      .order('category')
      .order('doc_code');

    if (error) throw error;
    return data || [];
  }

  /**
   * Get documents by category
   */
  async getDocumentsByCategory(version: string, category: string): Promise<MafDocument[]> {
    const versionRecord = await this.getVersion(version);
    if (!versionRecord) return [];

    const { data, error } = await this.supabase
      .from('maf_documents')
      .select('*')
      .eq('version_id', versionRecord.id)
      .eq('category', category)
      .order('doc_code');

    if (error) throw error;
    return data || [];
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TESTS
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Get all tests
   */
  async getTests(): Promise<MafTest[]> {
    const { data, error } = await this.supabase
      .from('maf_tests')
      .select('*')
      .order('started_at', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  /**
   * Get tests for a specific version
   */
  async getTestsForVersion(version: string): Promise<MafTest[]> {
    const versionRecord = await this.getVersion(version);
    if (!versionRecord) return [];

    const { data, error } = await this.supabase
      .from('maf_tests')
      .select('*')
      .eq('version_id', versionRecord.id)
      .order('started_at', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  /**
   * Get test by code
   */
  async getTest(testCode: string): Promise<MafTest | null> {
    const { data, error } = await this.supabase
      .from('maf_tests')
      .select('*')
      .eq('test_code', testCode)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  /**
   * Create a new test
   */
  async createTest(input: CreateTestInput): Promise<MafTest> {
    let version_id: string | null = null;

    if (input.version) {
      const versionRecord = await this.getVersion(input.version);
      if (versionRecord) {
        version_id = versionRecord.id;
      }
    } else {
      const currentVersion = await this.getCurrentVersion();
      if (currentVersion) {
        version_id = currentVersion.id;
      }
    }

    const { data, error } = await this.supabase
      .from('maf_tests')
      .insert({
        test_code: input.test_code,
        test_name: input.test_name,
        version_id,
        config: input.config || {},
        is_validation_test: input.is_validation_test || false,
        status: 'pending'
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Start a test
   */
  async startTest(testCode: string): Promise<MafTest> {
    const { data, error } = await this.supabase
      .from('maf_tests')
      .update({
        status: 'running',
        started_at: new Date().toISOString()
      })
      .eq('test_code', testCode)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Complete a test
   */
  async completeTest(testCode: string, passed: boolean): Promise<MafTest> {
    const { data, error } = await this.supabase
      .from('maf_tests')
      .update({
        status: passed ? 'completed' : 'failed',
        completed_at: new Date().toISOString(),
        validation_passed: passed
      })
      .eq('test_code', testCode)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Update test metrics
   */
  async updateTestMetrics(
    testCode: string,
    metrics: {
      stories_total?: number;
      stories_passed?: number;
      stories_failed?: number;
      total_input_tokens?: number;
      total_output_tokens?: number;
      total_cost_usd?: number;
    }
  ): Promise<MafTest> {
    const { data, error } = await this.supabase
      .from('maf_tests')
      .update(metrics)
      .eq('test_code', testCode)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TEST STORIES
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Get stories for a test
   */
  async getTestStories(testCode: string): Promise<MafTestStory[]> {
    const test = await this.getTest(testCode);
    if (!test) return [];

    const { data, error } = await this.supabase
      .from('maf_test_stories')
      .select('*')
      .eq('test_id', test.id)
      .order('wave_number')
      .order('story_code');

    if (error) throw error;
    return data || [];
  }

  /**
   * Record a story in a test
   */
  async recordStory(input: RecordStoryInput): Promise<MafTestStory> {
    const { data, error } = await this.supabase
      .from('maf_test_stories')
      .insert({
        test_id: input.test_id,
        story_code: input.story_code,
        story_title: input.story_title,
        domain: input.domain,
        wave_number: input.wave_number,
        dev_agent: input.dev_agent,
        qa_agent: input.qa_agent,
        status: 'pending'
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Update story status
   */
  async updateStoryStatus(
    testCode: string,
    storyCode: string,
    status: MafTestStory['status'],
    metrics?: {
      test_coverage?: number;
      cost_usd?: number;
    }
  ): Promise<MafTestStory> {
    const test = await this.getTest(testCode);
    if (!test) throw new Error(`Test not found: ${testCode}`);

    const updates: Record<string, any> = { status };
    if (metrics) {
      Object.assign(updates, metrics);
    }
    if (status === 'passed' || status === 'failed') {
      updates.completed_at = new Date().toISOString();
    }

    const { data, error } = await this.supabase
      .from('maf_test_stories')
      .update(updates)
      .eq('test_id', test.id)
      .eq('story_code', storyCode)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // STATISTICS
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Get test summary (from view)
   */
  async getTestSummary(): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('maf_test_summary')
      .select('*');

    if (error) throw error;
    return data || [];
  }

  /**
   * Get cost breakdown by model (from view)
   */
  async getCostByModel(): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('maf_cost_by_model')
      .select('*');

    if (error) throw error;
    return data || [];
  }

  /**
   * Get gate success rates (from view)
   */
  async getGateSuccessRates(): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('maf_gate_success_rates')
      .select('*');

    if (error) throw error;
    return data || [];
  }

  /**
   * Get success rate for a version
   */
  async getVersionSuccessRate(version: string): Promise<number> {
    const tests = await this.getTestsForVersion(version);
    if (tests.length === 0) return 0;

    const completedTests = tests.filter(t => t.status === 'completed' || t.status === 'failed');
    if (completedTests.length === 0) return 0;

    const passedTests = completedTests.filter(t => t.validation_passed);
    return (passedTests.length / completedTests.length) * 100;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// USAGE EXAMPLE
// ════════════════════════════════════════════════════════════════════════════

/*
import { createClient } from '@supabase/supabase-js';
import { MafDb } from './maf-db';

// Initialize
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);
const db = new MafDb(supabase);

// Get all V11 tests
const tests = await db.getTestsForVersion('11.0.0');

// Create a new test
const test = await db.createTest({
  test_code: 'V11-TEST-001',
  test_name: 'First V11 Validation',
  is_validation_test: true
});

// Start the test
await db.startTest('V11-TEST-001');

// Record a story
await db.recordStory({
  test_id: test.id,
  story_code: 'AUTH-FE-001',
  story_title: 'Create LoginForm component',
  domain: 'auth',
  wave_number: 1,
  dev_agent: 'fe-auth',
  qa_agent: 'qa-auth'
});

// Update story status
await db.updateStoryStatus('V11-TEST-001', 'AUTH-FE-001', 'passed', {
  test_coverage: 85.5,
  cost_usd: 0.25
});

// Complete the test
await db.completeTest('V11-TEST-001', true);

// Get summary
const summary = await db.getTestSummary();
console.log(summary);
*/
