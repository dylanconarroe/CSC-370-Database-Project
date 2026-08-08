-- ============================================================
-- Isolation: CSC370_hobby_platform  (Sprint 3, Goal 3:optional)
-- Dirty read = one session reads another's UNCOMMITTED change.
-- Needs TWO mysql terminals open at once:
--   Terminal 1 = SESSION A (writer)
--   Terminal 2 = SESSION B (reader)
-- Run the steps in the labelled session, top to bottom.
-- ============================================================


-- ############## PART 1: the anomaly (READ UNCOMMITTED) ##############

-- STEP 1 (B): weakest level, start reading. Value starts at 40.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT progress AS b_sees_before FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;  -- 40

-- STEP 2 (A): change it but DON'T commit.
START TRANSACTION;
UPDATE EnrolledIn SET progress = 95 WHERE user_id = 1 AND hobby_id = 1;

-- STEP 3 (B): read again -> sees 95 = the DIRTY READ.
SELECT progress AS b_sees_dirty FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;   -- 95

-- STEP 4 (A): roll back -> the 95 never really happened.
ROLLBACK;

-- STEP 5 (B): read again -> back to 40. B acted on a value that never existed.
SELECT progress AS b_sees_after FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;   -- 40
COMMIT;


-- ############## PART 2: the fix (READ COMMITTED) ##############
-- READ COMMITTED only shows committed data, so no dirty read.

-- STEP 6 (B):
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT progress AS b_sees_before FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;  -- 40

-- STEP 7 (A):
START TRANSACTION;
UPDATE EnrolledIn SET progress = 95 WHERE user_id = 1 AND hobby_id = 1;

-- STEP 8 (B): read again -> still 40. Anomaly prevented.
SELECT progress AS b_sees_no_dirty FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;-- 40

-- STEP 9 (A):
ROLLBACK;

-- STEP 10 (B): finish, back to default level.
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- Demo: STEP 3 shows 95 (anomaly), STEP 8 shows 40 (fixed).
