-- ============================================================
-- Sprint 5: Constraints and Triggers
-- CSC370_hobby_platform
--
-- Demonstrates, with error codes recorded for each step:
--   1. An attribute-level CHECK (Equipment.cost >= 0), including
--      the ADD CHECK being rejected while a bad row exists, and
--      succeeding once that row is fixed.
--   2. An insert rejected by that attribute-level check.
--   3. An attempt to express a two-column condition at the
--      attribute (column) level, and why it fails.
--   4. A tuple-level CHECK spanning two columns of the same row
--      (Tutorial.estimated_completion_minutes >= Tutorial.steps_count).
--   5. An insert rejected by that tuple-level check.
--   6. A trigger that maintains Hobby.review_count and
--      Hobby.avg_rating whenever a row is inserted into Review,
--      with a before/after SELECT proving it worked.
--
-- Run after setup_01.sql, seed_data.sql, and inheritance.sql
-- (Tutorial must already exist).
-- ============================================================

USE CSC370_hobby_platform;

-- ============================================================
-- PART 1: ATTRIBUTE-LEVEL CHECK  --  Equipment.cost >= 0
-- ============================================================

-- Insert a bad row on purpose, so the table already violates the
-- constraint we're about to add.
INSERT INTO Equipment (name, tool_id, cost) VALUES ('Broken Sensor', 999, -50);

-- This is rejected: existing data (the row above) violates the
-- condition before the constraint even exists. A CHECK cannot be
-- attached to a table that is already in a state it forbids.
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_equipment_cost'
-- is violated.
ALTER TABLE Equipment
    ADD CONSTRAINT chk_equipment_cost CHECK (cost >= 0);

-- Fix the offending row.
UPDATE Equipment SET cost = 50 WHERE tool_id = 999;

-- Now the same ALTER succeeds, because no row violates it anymore.
ALTER TABLE Equipment
    ADD CONSTRAINT chk_equipment_cost CHECK (cost >= 0);

-- ============================================================
-- PART 2: INSERT REJECTED BY THE ATTRIBUTE-LEVEL CHECK
-- ============================================================

-- With the constraint now in place, a new negative-cost row is
-- rejected outright.
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_equipment_cost'
-- is violated.
INSERT INTO Equipment (name, tool_id, cost) VALUES ('Cursed Sensor', 998, -1);

-- ============================================================
-- PART 3: WHY THE TWO-COLUMN RULE CAN'T BE ATTRIBUTE-LEVEL
--
-- Tutorial's rule is: estimated_completion_minutes must be >=
-- steps_count. That condition needs two columns from the same
-- row, so it cannot be attached to a single column definition.
-- An attribute-level CHECK may only reference the column it is
-- attached to. MySQL parses the whole CREATE TABLE before resolving
-- names, so it does find estimated_completion_minutes and then
-- rejects the constraint for referencing a second column. That is
-- the signal the rule belongs at the tuple level instead.
-- ============================================================

DROP TABLE IF EXISTS Tutorial_BadAttempt;

-- Expected: ERROR 3813 (HY000): Column check constraint
-- 'tutorial_badattempt_chk_1' references other column.
CREATE TABLE Tutorial_BadAttempt (
    resource_id INT PRIMARY KEY,
    steps_count INT CHECK (estimated_completion_minutes >= steps_count),
    estimated_completion_minutes INT
);

-- ============================================================
-- PART 4: TUPLE-LEVEL CHECK  --  written at the table level,
-- after every column it needs already exists.
-- ============================================================

ALTER TABLE Tutorial
    ADD CONSTRAINT chk_tutorial_time
    CHECK (estimated_completion_minutes >= steps_count);

-- ============================================================
-- PART 5: INSERT REJECTED BY THE TUPLE-LEVEL CHECK
-- ============================================================

-- Insert a resource + tutorial where the completion time is less
-- than the step count -- violates the tuple-level rule.
INSERT INTO Resources (resource_id, title, url)
VALUES (999, 'Impossible Tutorial', 'https://example.com/impossible');

-- Expected: ERROR 3819 (HY000): Check constraint 'chk_tutorial_time'
-- is violated.
INSERT INTO Tutorial (resource_id, steps_count, estimated_completion_minutes)
VALUES (999, 20, 5);

-- Clean up the resource row from the failed attempt.
DELETE FROM Resources WHERE resource_id = 999;

-- ============================================================
-- PART 6: TRIGGER  --  maintain Hobby.review_count and
-- Hobby.avg_rating whenever a Review is inserted.
--
-- MySQL has no assertions (a cross-table, always-checked rule),
-- so a rule that spans Review and Hobby has to be enforced with
-- a trigger instead -- there is no declarative way to say
-- "Hobby.avg_rating must always equal AVG(Review.rating) for its
-- reviews" the way a CHECK constraint can express a single-row or
-- single-table rule.
-- ============================================================

ALTER TABLE Hobbies
    ADD COLUMN review_count INT NOT NULL DEFAULT 0,
    ADD COLUMN avg_rating DECIMAL(3,2) DEFAULT NULL;

    -- Initialize the derived columns with their initial values.
    UPDATE Hobbies h SET
        review_count = (SELECT COUNT(*)    FROM Review r WHERE r.hobby_id = h.hobby_id),
        avg_rating   = (SELECT AVG(rating) FROM Review r WHERE r.hobby_id = h.hobby_id);

DROP TRIGGER IF EXISTS trg_review_insert_update_hobby;

DELIMITER $$

CREATE TRIGGER trg_review_insert_update_hobby
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    UPDATE Hobbies
    SET review_count = (
            SELECT COUNT(*) FROM Review WHERE hobby_id = NEW.hobby_id
        ),
        avg_rating = (
            SELECT AVG(rating) FROM Review WHERE hobby_id = NEW.hobby_id
        )
    WHERE hobby_id = NEW.hobby_id;
END$$

DELIMITER ;

-- BEFORE: backfilled from the seeded reviews. Expect 2 and 4.50.
SELECT hobby_id, name, review_count, avg_rating
FROM Hobbies
WHERE hobby_id = 1;

-- Insert a review for an existing enrolment (user_id 1, hobby_id 1
-- is already in EnrolledIn from seed_data.sql). The insert
-- statement itself never mentions review_count or avg_rating.
INSERT INTO Review (user_id, hobby_id, review_date, rating, comment)
VALUES (1, 1, '2026-08-20', 5, 'Great intro route, well worth the harness rental.');

-- AFTER: the trigger updated both derived columns on Hobbies
-- without the INSERT statement above ever touching them.
SELECT hobby_id, name, review_count, avg_rating
FROM Hobbies
WHERE hobby_id = 1;

-- One more review on the same hobby, to show the average recompute
-- correctly rather than just incrementing a counter.
INSERT INTO Review (user_id, hobby_id, review_date, rating, comment)
VALUES (1, 1, '2026-08-21', 3, 'Second visit, harder route, knees disagreed.');

SELECT hobby_id, name, review_count, avg_rating
FROM Hobbies
WHERE hobby_id = 1;
