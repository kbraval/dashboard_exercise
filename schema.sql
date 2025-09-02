-- ========================
-- Project Dashboard (base)
-- ========================
CREATE TABLE project_dashboard (
    unit_id INTEGER PRIMARY KEY,        -- each row = one RTL unit in the project
    unit_name TEXT NOT NULL UNIQUE,     -- e.g., "alu", "fpu", etc.
    FOREIGN KEY (unit_id) REFERENCES unit_rtl(id) ON DELETE CASCADE
);

-- ========================
-- RTL Units
-- ========================
CREATE TABLE unit_rtl (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    git_commit TEXT NOT NULL,    -- the commit where the unit rtl was first added
    rtl_path TEXT NOT NULL
);

-- ========================
-- Unit Tests
-- ========================
CREATE TABLE unit_tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_id INTEGER NOT NULL,
    status BOOLEAN NOT NULL,
    FOREIGN KEY (unit_id) REFERENCES unit_rtl(id) ON DELETE CASCADE
);
CREATE INDEX idx_unit_tests_unit_id ON unit_tests(unit_id);

-- ========================
-- Unit Test Names
-- ========================
CREATE TABLE unit_test_names (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    unit_tests_ref INTEGER NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (unit_tests_ref) REFERENCES unit_tests(id) ON DELETE CASCADE
);
CREATE INDEX idx_unit_test_names_ref ON unit_test_names(unit_tests_ref);

-- ========================
-- Test Runs
-- ========================
CREATE TABLE test_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    git_commit TEXT NOT NULL,
    log_url TEXT,
    start_time TIMESTAMP NOT NULL,
    stop_time TIMESTAMP,
    status INTEGER,
    unit_rtl_id INTEGER NOT NULL,
    FOREIGN KEY (git_commit) REFERENCES project_dashboard(git_commit) ON DELETE CASCADE,
    FOREIGN KEY (unit_rtl_id) REFERENCES unit_rtl(id) ON DELETE CASCADE
);
CREATE INDEX idx_test_runs_commit ON test_runs(git_commit);
CREATE INDEX idx_test_runs_unit_rtl_id ON test_runs(unit_rtl_id);

-- ========================
-- Signoff Runs
-- ========================
CREATE TABLE signoff_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    git_commit TEXT NOT NULL,
    log_url TEXT,
    start_time TIMESTAMP NOT NULL,
    stop_time TIMESTAMP,
    status INTEGER,
    unit_rtl_id INTEGER NOT NULL,
    FOREIGN KEY (git_commit) REFERENCES project_dashboard(git_commit) ON DELETE CASCADE,
    FOREIGN KEY (unit_rtl_id) REFERENCES unit_rtl(id) ON DELETE CASCADE
);
CREATE INDEX idx_signoff_runs_commit ON signoff_runs(git_commit);
CREATE INDEX idx_signoff_runs_unit_rtl_id ON signoff_runs(unit_rtl_id);

-- ========================
-- Bugs
-- ========================
CREATE TABLE bugs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    test_run_id INTEGER NOT NULL,
    details TEXT,
    status TEXT NOT NULL DEFAULT 'opened'
        CHECK (status IN ('opened','assigned','not-a-bug','closed')),
    FOREIGN KEY (test_run_id) REFERENCES test_runs(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_bugs_test_run_id ON bugs(test_run_id);
CREATE INDEX IF NOT EXISTS idx_bugs_status ON bugs(status);


--- Example Data:
-- ===========
-- Units
-- ===========
INSERT INTO unit_rtl (rtl_path, git_commit) VALUES
  ('alu', 'cmt_001'),
  ('fpu', 'cmt_002'),
  ('instruction_fetch', 'cmt_002'),
  ('instruction_decode', 'cmt_003'),
  ('cache', 'cmt_004'),
  ('mmu', 'cmt_006');

-- ===========
-- Project Dashboard (keyed by unit, with introduced_commit as metadata)
-- ===========
INSERT INTO project_dashboard (unit_id, unit_name) VALUES
  (1, 'ALU'),
  (2, 'FPU'),
  (3, 'Instruction Fetch'),
  (4, 'Instruction Decode'),
  (5, 'Cache'),
  (6, 'MMU');

-- ===========
-- Test Runs (status: 1 = pass, 0 = fail)
-- Assume we care about commits cmt_001 .. cmt_006
-- ===========

-- cmt_001: ALU introduced, tests pass
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_001', 'http://logs/alu/1', '2025-09-01 10:00', '2025-09-01 10:10', 1, 1);

-- cmt_002: FPU & IFetch added; FPU failing, IFetch passing; ALU remains green
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_002', 'http://logs/alu/2', '2025-09-02 09:00', '2025-09-02 09:08', 1, 1),
  ('cmt_002', 'http://logs/fpu/1', '2025-09-02 09:10', '2025-09-02 09:25', 0, 2),
  ('cmt_002', 'http://logs/ifetch/1', '2025-09-02 09:30', '2025-09-02 09:50', 1, 3);

-- cmt_003: I-Decode added; still failing; FPU still failing; IFetch & ALU passing
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_003', 'http://logs/alu/3', '2025-09-03 09:00', '2025-09-03 09:07', 1, 1),
  ('cmt_003', 'http://logs/fpu/2', '2025-09-03 09:10', '2025-09-03 09:28', 0, 2),
  ('cmt_003', 'http://logs/ifetch/2', '2025-09-03 09:30', '2025-09-03 09:47', 1, 3),
  ('cmt_003', 'http://logs/idecode/1', '2025-09-03 10:00', '2025-09-03 10:20', 0, 4);

-- cmt_004: Cache added; Cache passing; others unchanged
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_004', 'http://logs/alu/4', '2025-09-04 09:00', '2025-09-04 09:06', 1, 1),
  ('cmt_004', 'http://logs/fpu/3', '2025-09-04 09:10', '2025-09-04 09:27', 0, 2),
  ('cmt_004', 'http://logs/ifetch/3', '2025-09-04 09:30', '2025-09-04 09:45', 1, 3),
  ('cmt_004', 'http://logs/idecode/2', '2025-09-04 09:50', '2025-09-04 10:10', 0, 4),
  ('cmt_004', 'http://logs/cache/1', '2025-09-04 10:15', '2025-09-04 10:30', 1, 5);

-- cmt_005: Cache stays green; IFetch green; ALU green; FPU still red; I-Decode still red
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_005', 'http://logs/alu/5', '2025-09-05 09:00', '2025-09-05 09:05', 1, 1),
  ('cmt_005', 'http://logs/fpu/4', '2025-09-05 09:10', '2025-09-05 09:25', 0, 2),
  ('cmt_005', 'http://logs/ifetch/4', '2025-09-05 09:30', '2025-09-05 09:45', 1, 3),
  ('cmt_005', 'http://logs/idecode/3', '2025-09-05 09:50', '2025-09-05 10:10', 0, 4),
  ('cmt_005', 'http://logs/cache/2', '2025-09-05 10:15', '2025-09-05 10:30', 1, 5);

-- cmt_006: MMU added; FPU & I-Decode finally green; MMU failing initially
INSERT INTO test_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_006', 'http://logs/alu/6', '2025-09-06 09:00', '2025-09-06 09:05', 1, 1),
  ('cmt_006', 'http://logs/fpu/5', '2025-09-06 09:10', '2025-09-06 09:25', 1, 2),
  ('cmt_006', 'http://logs/ifetch/5', '2025-09-06 09:30', '2025-09-06 09:45', 1, 3),
  ('cmt_006', 'http://logs/idecode/4', '2025-09-06 09:50', '2025-09-06 10:10', 1, 4),
  ('cmt_006', 'http://logs/cache/3', '2025-09-06 10:15', '2025-09-06 10:30', 1, 5),
  ('cmt_006', 'http://logs/mmu/1', '2025-09-06 10:35', '2025-09-06 10:55', 0, 6);

-- ===========
-- Signoff Runs (status: 1 = pass, 0 = fail)
-- ===========
-- Early: ALU passes signoff at cmt_002; Cache at cmt_005; FPU fails at cmt_003 then passes at cmt_006
INSERT INTO signoff_runs (git_commit, log_url, start_time, stop_time, status, unit_rtl_id) VALUES
  ('cmt_002', 'http://signoff/alu/1', '2025-09-02 14:00', '2025-09-02 14:10', 1, 1),
  ('cmt_003', 'http://signoff/fpu/1', '2025-09-03 14:00', '2025-09-03 14:20', 0, 2),
  ('cmt_005', 'http://signoff/cache/1', '2025-09-05 14:00', '2025-09-05 14:12', 1, 5),
  ('cmt_006', 'http://signoff/fpu/2', '2025-09-06 14:00', '2025-09-06 14:15', 0, 2),
  ('cmt_006', 'http://signoff/cache/2', '2025-09-06 14:00', '2025-09-06 14:12', 1, 5),
  ('cmt_006', 'http://signoff/alu/2', '2025-09-06 14:00', '2025-09-06 14:10', 1, 1);

-- ===========
-- Bugs (with statuses)
--   Open bugs: status IN ('opened','assigned')
--   Closed / Not-a-bug are ignored by the report's "open bugs" tally
-- ===========
-- FPU has an open precision bug from its failing run at cmt_002
INSERT INTO bugs (test_run_id, details, status)
SELECT id, 'Floating-point precision mismatch', 'assigned'
FROM test_runs WHERE git_commit='cmt_002' AND unit_rtl_id=2;

-- I-Decode has an open pipeline stall bug from cmt_003
INSERT INTO bugs (test_run_id, details, status)
SELECT id, 'Instruction decode pipeline stall', 'opened'
FROM test_runs WHERE git_commit='cmt_003' AND unit_rtl_id=4;

-- Later, that I-Decode bug is determined "not-a-bug" (separate report)
INSERT INTO bugs (test_run_id, details, status)
SELECT id, 'False positive due to test harness', 'not-a-bug'
FROM test_runs WHERE git_commit='cmt_004' AND unit_rtl_id=4;

-- FPU accumulates another bug that gets fixed (closed) at a later commit
INSERT INTO bugs (test_run_id, details, status)
SELECT id, 'Denormal handling edge-case', 'closed'
FROM test_runs WHERE git_commit='cmt_003' AND unit_rtl_id=2;

-- MMU has an open TLB invalidation bug from initial failing run
INSERT INTO bugs (test_run_id, details, status)
SELECT id, 'TLB invalidation timing issue', 'opened'
FROM test_runs WHERE git_commit='cmt_006' AND unit_rtl_id=6;