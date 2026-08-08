-- ============================================================
-- Consistency: CSC370_hobby_platform  (Sprint 3, Goal 2)
-- CHECK constraints enforce rules that must always hold, so bad
-- data can never be saved.
-- ============================================================
USE CSC370_hobby_platform;

-- Rules on EnrolledIn:
--   progress must be 0-100
--   skill_level must be Beginner / Intermediate / Advanced
ALTER TABLE EnrolledIn
    ADD CONSTRAINT chk_progress_range
    CHECK (progress >= 0 AND progress <= 100);

ALTER TABLE EnrolledIn
    ADD CONSTRAINT chk_skill_level
    CHECK (skill_level IN ('Beginner', 'Intermediate', 'Advanced'));

SELECT '===== Constraints on EnrolledIn =====' AS marker;
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'CSC370_hobby_platform'
  AND table_name = 'EnrolledIn';

-- TEST 1: valid values -> accepted
SELECT '===== TEST 1: valid (should work) =====' AS marker;
INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level)
VALUES (1, 22, 50, 'Beginner');
SELECT * FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 22;
DELETE FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 22;   -- keep re-runnable

-- TEST 2: progress 150 -> rejected (ERROR 3819)
SELECT '===== TEST 2: progress 150 (should fail) =====' AS marker;
INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level)
VALUES (1, 22, 150, 'Beginner');

-- TEST 3: bad skill_level -> rejected (ERROR 3819)
SELECT '===== TEST 3: skill Expert (should fail) =====' AS marker;
INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level)
VALUES (1, 22, 30, 'Expert');

-- TEST 4: rule also blocks UPDATEs -> rejected (ERROR 3819)
SELECT '===== TEST 4: update to 999 (should fail) =====' AS marker;
UPDATE EnrolledIn SET progress = 999 WHERE user_id = 1 AND hobby_id = 1;
SELECT user_id, hobby_id, progress FROM EnrolledIn WHERE user_id = 1 AND hobby_id = 1;

-- Run: mysql --force -u root -t < constraints.sql
-- Demo: TEST 1 works; TESTS 2-4 each raise ERROR 3819.
-- Re-run cleanup (drop constraints first):
--   ALTER TABLE EnrolledIn DROP CHECK chk_progress_range;
--   ALTER TABLE EnrolledIn DROP CHECK chk_skill_level;