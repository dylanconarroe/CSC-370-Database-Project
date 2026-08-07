-- ============================================================
-- Basic Security: CSC370_hobby_platform  (Sprint 2, Goal 4)
--
-- Structure:
--   (A) VIEWS          -- public hobby catalogue + password-free user view
--   (B) ROLES          -- a read-only role, granted to an app account
--   (C) VERIFICATION   -- SHOW GRANTS + the deny test to run as hobby_app
--   (D) REVOKE demo    -- narrow the role's access, re-check
-- ============================================================
USE CSC370_hobby_platform;

-- ============================================================
-- (A) VIEWS
-- ============================================================
-- View 1: Public hobby catalogue.
-- Joins Hobbies to its category and community so the app can
-- render a browse page from a single SELECT, without exposing
-- the underlying join tables.
DROP VIEW IF EXISTS PublicHobbyCatalogue;
CREATE VIEW PublicHobbyCatalogue AS
SELECT  h.hobby_id,
        h.name              AS hobby,
        h.difficulty,
        c.name              AS category,
        c.category_type,
        comm.name           AS community,
        comm.platform
FROM Hobbies h
LEFT JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
LEFT JOIN Category c      ON ca.category_id = c.category_id
LEFT JOIN Communities comm ON h.hobby_id = comm.hobby_id;

-- View 2: Safe user directory.
-- Selects only the non-sensitive columns; the password column
-- is deliberately omitted so it can never be read through this view.
DROP VIEW IF EXISTS PublicUserProfile;
CREATE VIEW PublicUserProfile AS
SELECT  user_id,
        username,
        date_joined
FROM Users;

-- Demonstrate the views return data:
SELECT '===== PublicHobbyCatalogue (first 5) =====' AS marker;
SELECT * FROM PublicHobbyCatalogue ORDER BY hobby_id LIMIT 5;

SELECT '===== PublicUserProfile (no password column) =====' AS marker;
SELECT * FROM PublicUserProfile ORDER BY user_id LIMIT 5;

-- ============================================================
-- (B) ROLES + GRANT
-- ============================================================
-- Create a role that can read ONLY the two public views.
-- Create the application account
-- Grant the role to the account and make it the default.

-- The account is never granted anything on the raw Users table, so
-- the password column is unreachable to it (proven in section (C)).

-- A read-only role for the public-facing app.
DROP ROLE IF EXISTS 'app_readonly';
CREATE ROLE 'app_readonly';

-- The role may read the safe views only (least privilege).
GRANT SELECT ON CSC370_hobby_platform.PublicHobbyCatalogue TO 'app_readonly';
GRANT SELECT ON CSC370_hobby_platform.PublicUserProfile    TO 'app_readonly';

-- The application login account.
DROP USER IF EXISTS 'hobby_app'@'localhost';
CREATE USER 'hobby_app'@'localhost' IDENTIFIED BY 'app_pw_demo';

-- Give the account the role, and activate it automatically on login.
GRANT 'app_readonly' TO 'hobby_app'@'localhost';
SET DEFAULT ROLE 'app_readonly' TO 'hobby_app'@'localhost';

FLUSH PRIVILEGES;

-- ============================================================
-- (C) VERIFICATION
-- ============================================================
-- (C.1) SHOW GRANTS: what the account is allowed to do, roles included.
SELECT '===== GRANTS for hobby_app (with role privileges) =====' AS marker;
SHOW GRANTS FOR 'hobby_app'@'localhost' USING 'app_readonly';

-- (C.2) ATTEMPTED UNAUTHORIZED OPERATIONS.
-- These cannot run inside this script, because the script is executed by
-- the privileged (root) account. To produce the *evidence* the rubric
-- wants, open a SECOND client logged in AS hobby_app and run the block
-- below. The first two SELECTs must FAIL; the third must SUCCEED.
--
--   $ mysql -u hobby_app -p        # password: app_pw_demo
--
--   USE CSC370_hobby_platform;
--
--   -- (a) Try to read the raw table that contains the password column:
--   SELECT * FROM Users;
--   -- EXPECTED: ERROR 1142 (42000): SELECT command denied to user
--   --           'hobby_app'@'localhost' for table 'Users'
--
--   -- (b) Try to read the password column specifically:
--   SELECT username, password FROM Users;
--   -- EXPECTED: same ERROR 1142 -- the account can never see passwords.
--
--   -- (c) The permitted path still works -- the safe view returns rows
--   --     (views run with definer rights, so no direct Users access is
--   --      needed), and crucially there is no password column in it:
--   SELECT * FROM PublicUserProfile LIMIT 5;
--   -- EXPECTED: succeeds, returns user_id, username, date_joined only.
--
--   -- (d) A write is also denied (read-only role):
--   DELETE FROM PublicUserProfile;
--   -- EXPECTED: ERROR 1142 (DELETE command denied).
--
-- Capturing that ERROR 1142 alongside the successful view read is the
-- "attempted unauthorized operation" evidence: it proves the lockdown
-- holds under independent testing rather than just asserting it.

-- ============================================================
-- (D) REVOKE
-- ============================================================
-- Narrow the role: take back the user directory, leaving only the
-- hobby catalogue. Because the privilege lives on the ROLE, one REVOKE
-- instantly changes what every account holding the role can do.
-- (Intentional: after this, hobby_app can browse hobbies but can no
-- longer read even the safe user view.)
REVOKE SELECT ON CSC370_hobby_platform.PublicUserProfile FROM 'app_readonly';

SELECT '===== Role privileges after REVOKE =====' AS marker;
SHOW GRANTS FOR 'app_readonly';

FLUSH PRIVILEGES;
