-- ============================================================
-- Basic Security: CSC370_hobby_platform  (Sprint 2, Goal 4)
--
-- Two parts:
--   (A) Views  -- a public hobby catalogue, and a safe user
--       view that hides the password column.
--   (B) Roles + GRANT / REVOKE  -- a read-only "app" account
--       that can read the public views but never the raw
--       Users table (so passwords are never exposed).
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
-- (B) ROLES + GRANT / REVOKE
-- ============================================================
-- Create a read-only application account. It may read the two
-- public views but is never granted access to the raw Users
-- table, so it cannot see the password column.

DROP USER IF EXISTS 'hobby_app'@'localhost';
CREATE USER 'hobby_app'@'localhost' IDENTIFIED BY 'app_pw_demo';

-- Grant SELECT only on the safe views (least privilege).
GRANT SELECT ON CSC370_hobby_platform.PublicHobbyCatalogue TO 'hobby_app'@'localhost';
GRANT SELECT ON CSC370_hobby_platform.PublicUserProfile    TO 'hobby_app'@'localhost';

-- Show what the account is allowed to do:
SELECT '===== GRANTS for hobby_app =====' AS marker;
SHOW GRANTS FOR 'hobby_app'@'localhost';

-- REVOKE example: take back access to the user directory,
-- leaving only the hobby catalogue.
REVOKE SELECT ON CSC370_hobby_platform.PublicUserProfile FROM 'hobby_app'@'localhost';

SELECT '===== GRANTS after REVOKE =====' AS marker;
SHOW GRANTS FOR 'hobby_app'@'localhost';

FLUSH PRIVILEGES;
