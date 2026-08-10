-- ============================================================
-- Durability: CSC370_hobby_platform  (Sprint 3, Goal 4: optional)
--
-- Durability = once a transaction COMMITs, its changes survive a
-- crash. On COMMIT, InnoDB writes each change to its REDO LOG on
-- disk (write-ahead logging) before confirming the commit, so even
-- if the server crashes before the table itself is written, the
-- data is recovered from the log when the server restarts.
--
-- This file has THREE parts. It is NOT run all at once with
-- "mysql < durability.sql". PART 2 deliberately crashes the
-- server, so you run the parts by hand:
--   PART 1  (in mysql)     : commit data that must survive
--   PART 2  (in the TERMINAL): crash the server, then restart it
--   PART 3  (in mysql)     : show the data is still there
-- ============================================================


-- ============================================================
-- PART 1  (run inside mysql): commit rows before the crash
-- ============================================================
USE CSC370_hobby_platform;

DROP TABLE IF EXISTS DurabilityDemo;
CREATE TABLE DurabilityDemo (
    entry_id INT PRIMARY KEY AUTO_INCREMENT,
    note     VARCHAR(64),
    saved_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

START TRANSACTION;
INSERT INTO DurabilityDemo (note) VALUES ('committed row 1');
INSERT INTO DurabilityDemo (note) VALUES ('committed row 2');
INSERT INTO DurabilityDemo (note) VALUES ('committed row 3');
COMMIT;

SELECT '===== PART 1: three committed rows (BEFORE crash) =====' AS marker;
SELECT * FROM DurabilityDemo ORDER BY entry_id;


-- ============================================================
-- PART 2  (run in the TERMINAL, not in mysql): crash + restart
-- ------------------------------------------------------------
-- Hard-kill the server (a real crash, not a clean shutdown):
--     kill -9 $(pgrep -x mysqld)
--
-- Bring it back up. First check if it auto-restarted:
--     mysql -u root -e "SELECT 1;"
-- If that cannot connect, start it (Homebrew):
--     brew services start mysql
-- then wait a few seconds and re-check with SELECT 1.
--
-- The kill happens AFTER the COMMIT in PART 1, so the rows are
-- already flushed to the redo log even though the crash gave the
-- server no chance to shut down cleanly.
-- ============================================================


-- ============================================================
-- PART 3  (run inside mysql, after the restart):  verify
-- ============================================================
USE CSC370_hobby_platform;

SELECT '===== PART 3: same three rows AFTER crash + restart =====' AS marker;
SELECT * FROM DurabilityDemo ORDER BY entry_id;
-- All three rows are still here. On restart InnoDB replayed its
-- redo log to recover every committed change, that recovery from
-- the log is durability.
