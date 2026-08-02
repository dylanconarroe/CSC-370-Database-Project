-- ============================================================
-- Indexes: CSC370_hobby_platform  (Sprint 2, Goal 3)
--
-- Goal: show that a well-chosen index changes the query plan
-- from a full table scan (type ALL) to an index lookup
-- (type ref), and explain WHY each index is a good choice.
--
-- Following the Accelerating SQL Queries material, a good index is:
--   * on a SELECTIVE column (one that filters out most rows),
--   * on FOREIGN-KEY columns, to speed up joins, and
--   * sometimes COMPOSITE and COVERING: several columns,
--     ordered by selectivity, holding every column the query
--     needs so the table itself never has to be read.
--
-- We demonstrate all three below on a large ActivityLog table.
-- ============================================================
USE CSC370_hobby_platform;

DROP TABLE IF EXISTS ActivityLog;

CREATE TABLE ActivityLog (
    log_id    INT PRIMARY KEY AUTO_INCREMENT,
    user_id   INT,        -- references Users.user_id  (a foreign-key column)
    hobby_id  INT,        -- references Hobbies.hobby_id (a foreign-key column)
    action    VARCHAR(32),
    logged_at DATETIME
);

-- ------------------------------------------------------------
-- Populate ~50,000 rows.
-- A cross join of a 10-row seed table against itself gives us
-- powers of ten (10 x 10 x 10 x 10 x 10 = 100,000); we cap it
-- at 50,000 with a LIMIT.
-- ------------------------------------------------------------
-- NOTE: this is a regular table, not a TEMPORARY one. MySQL will not let a
-- TEMPORARY table be referenced more than once in the same query, and the
-- generator below joins it to itself five times. A regular table works in
-- both MySQL and MariaDB. We drop it again once the rows are generated.
DROP TABLE IF EXISTS digits;
CREATE TABLE digits (d INT);
INSERT INTO digits (d) VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

INSERT INTO ActivityLog (user_id, hobby_id, action, logged_at)
SELECT
    1 + (n MOD 7)                       AS user_id,   -- user_id in 1..7
    1 + (n MOD 22)                      AS hobby_id,  -- hobby_id in 1..22
    ELT(1 + (n MOD 4), 'view','enrol','complete','join') AS action,
    TIMESTAMP('2026-01-01') + INTERVAL n MINUTE         AS logged_at
FROM (
    SELECT a.d + b.d*10 + c.d*100 + e.d*1000 + f.d*10000 AS n
    FROM digits a, digits b, digits c, digits e, digits f
) AS numbers
WHERE n < 50000
LIMIT 50000;

DROP TABLE digits;   -- generator no longer needed

SELECT COUNT(*) AS rows_loaded FROM ActivityLog;


-- ============================================================
-- DEMO 1: single-column index on a SELECTIVE filter column
-- ------------------------------------------------------------
-- hobby_id is the column we filter on most often, and any one
-- hobby is a small slice of the table, so the predicate
-- hobby_id = 7 is selective. That makes it a strong index
-- candidate. Without the index the query must scan all rows.
-- ------------------------------------------------------------
SELECT '===== DEMO 1: BEFORE INDEX (filter on hobby_id) =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM ActivityLog WHERE hobby_id = 7;
-- Expect: type = ALL, key = NULL, rows ~= 50000.

CREATE INDEX idx_log_hobby ON ActivityLog (hobby_id);

SELECT '===== DEMO 1: AFTER INDEX =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM ActivityLog WHERE hobby_id = 7;
-- Expect: type = ref, key = idx_log_hobby, rows scanned drops sharply.


-- ============================================================
-- DEMO 2: FOREIGN-KEY index to accelerate a JOIN
-- ------------------------------------------------------------
-- user_id is a foreign-key column (it references Users). Joining
-- ActivityLog to Users and filtering to one user must, with no
-- index, scan every log row to find that user's rows. An index
-- on the foreign-key column lets MySQL look them up directly,
-- which is exactly why FK columns are prime index targets.
-- ------------------------------------------------------------
SELECT '===== DEMO 2: BEFORE INDEX (join on user_id) =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT u.username, a.action, a.logged_at
FROM ActivityLog a
JOIN Users u ON a.user_id = u.user_id
WHERE a.user_id = 3;
-- Expect: ActivityLog is accessed with type = ALL (full scan).

CREATE INDEX idx_log_user ON ActivityLog (user_id);

SELECT '===== DEMO 2: AFTER INDEX =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT u.username, a.action, a.logged_at
FROM ActivityLog a
JOIN Users u ON a.user_id = u.user_id
WHERE a.user_id = 3;
-- Expect: ActivityLog now uses type = ref on idx_log_user.


-- ============================================================
-- DEMO 3: COMPOSITE, COVERING index
-- ------------------------------------------------------------
-- This query filters on hobby_id AND action and returns only
-- those two columns. A composite index on (hobby_id, action),
-- most-selective column first, contains every column the query
-- touches, so MySQL can answer it from the index alone without
-- reading the table. In EXPLAIN, "Using index" in the Extra
-- column is the signal that the index fully covered the query.
-- ------------------------------------------------------------
SELECT '===== DEMO 3: BEFORE composite index =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT hobby_id, action FROM ActivityLog WHERE hobby_id = 7 AND action = 'view';
-- Uses idx_log_hobby (hobby_id only), then reads rows to test action:
-- Extra shows "Using where" (the table still has to be read).

CREATE INDEX idx_log_hobby_action ON ActivityLog (hobby_id, action);

SELECT '===== DEMO 3: AFTER composite (covering) index =====' AS marker;
EXPLAIN FORMAT=TRADITIONAL
SELECT hobby_id, action FROM ActivityLog WHERE hobby_id = 7 AND action = 'view';
-- Expect: key = idx_log_hobby_action, and Extra contains "Using index",
-- meaning the query was answered from the index alone (covering).


-- ============================================================
-- Trade-off note (why we do not index everything):
-- Every index must be kept up to date on INSERT/UPDATE/DELETE
-- and takes disk space, so indexes speed up reads at the cost
-- of writes. A highly specific index (like DEMO 3) helps only
-- queries shaped like it, whereas an index on a foreign-key
-- column (DEMO 2) helps every join over that column. You index
-- the columns your real queries filter and join on, not all of
-- them.
-- ============================================================
