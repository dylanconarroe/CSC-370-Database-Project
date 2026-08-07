-- ============================================================
-- Atomicity: CSC370_hobby_platform  (Sprint 3, Goal 1)
-- A transaction is all-or-nothing: COMMIT keeps every change,
-- ROLLBACK keeps none. Needs InnoDB tables.
-- ============================================================
USE CSC370_hobby_platform;

-- Tables must be InnoDB (MyISAM ignores ROLLBACK).
SELECT '===== Engine check (want InnoDB) =====' AS marker;
SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = 'CSC370_hobby_platform'
  AND table_name IN ('EnrolledIn', 'Joins');


-- ============================================================
-- SCENARIO A: success -> COMMIT
-- Enroll user 6 in hobby 1 AND add the community-join row together.
-- ============================================================
SELECT '===== A: before =====' AS marker;
SELECT COUNT(*) AS enrolled_6_1 FROM EnrolledIn WHERE user_id = 6 AND hobby_id = 1;
SELECT COUNT(*) AS joined_6_1   FROM Joins      WHERE user_id = 6 AND hobby_id = 1;

START TRANSACTION;
    INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level)
    VALUES (6, 1, 0, 'Beginner');
    INSERT INTO Joins (user_id, hobby_id)
    VALUES (6, 1);
COMMIT;

SELECT '===== A: after COMMIT (both should be 1) =====' AS marker;
SELECT COUNT(*) AS enrolled_6_1 FROM EnrolledIn WHERE user_id = 6 AND hobby_id = 1;
SELECT COUNT(*) AS joined_6_1   FROM Joins      WHERE user_id = 6 AND hobby_id = 1;


-- ============================================================
-- SCENARIO B: failure -> ROLLBACK
-- First insert works; second points at a hobby that doesn't exist
-- (FK error). ROLLBACK undoes BOTH, so nothing is left behind.
-- ============================================================
SELECT '===== B: before (want 0) =====' AS marker;
SELECT COUNT(*) AS enrolled_7_5 FROM EnrolledIn WHERE user_id = 7 AND hobby_id = 5;

START TRANSACTION;
    INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level)
    VALUES (7, 5, 0, 'Beginner');           -- ok
    INSERT INTO Joins (user_id, hobby_id)
    VALUES (7, 999);                         -- FAILS: ERROR 1452 (bad FK)
ROLLBACK;

SELECT '===== B: after ROLLBACK (still 0 = atomic) =====' AS marker;
SELECT COUNT(*) AS enrolled_7_5 FROM EnrolledIn WHERE user_id = 7 AND hobby_id = 5;


-- Run:  mysql --force -u root -t CSC370_hobby_platform < transactions.sql
-- Demo: A goes 0,0 -> 1,1;  B shows ERROR 1452 then stays 0.
-- Re-run cleanup (Scenario A rows):
--   DELETE FROM Joins      WHERE user_id = 6 AND hobby_id = 1;
--   DELETE FROM EnrolledIn WHERE user_id = 6 AND hobby_id = 1;
-- mysql -u root CSC370_hobby_platform -e "DELETE FROM Joins WHERE user_id=6 AND hobby_id=1; DELETE FROM EnrolledIn WHERE user_id=6 AND hobby_id=1;"
