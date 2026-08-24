-- ============================================================
-- Sprint 4: Weak Entity Set
-- CSC370_hobby_platform
--
-- Review is a weak entity identified through EnrolledIn.
--
-- EnrolledIn has primary key:
--      (user_id, hobby_id)
--
-- Review borrows this key and adds its partial key:
--      review_date
--
-- Therefore Review's full primary key is:
--      (user_id, hobby_id, review_date)
-- ============================================================

USE CSC370_hobby_platform;


-- ============================================================
-- REVIEW WEAK ENTITY
-- ============================================================

-- Review is declared in setup_01.sql alongside the rest of the
-- schema, with exactly the key structure described above:
--     PRIMARY KEY (user_id, hobby_id, review_date)
--     FOREIGN KEY (user_id, hobby_id) -> EnrolledIn ON DELETE CASCADE
--     CHECK (rating BETWEEN 1 AND 5)
-- It is not re-created here, because seed_data.sql already loaded
-- its rows and this file only demonstrates the weak entity.


-- ============================================================
-- DEMO 1: Show Review weak entity data
-- ------------------------------------------------------------
-- Review is identified by the key:
--     (user_id, hobby_id, review_date)
--
-- user_id and hobby_id come from the owning EnrolledIn
-- relationship, while review_date is Review's partial key.
-- ============================================================

SELECT *
FROM Review
ORDER BY user_id, hobby_id, review_date;


-- ============================================================
-- DEMO 2: Multiple reviews for the same enrollment
-- ------------------------------------------------------------
-- User 1 is enrolled in Hobby 1 and has two reviews.
-- The same (user_id, hobby_id) can appear more than once
-- because review_date is the partial key that distinguishes
-- each Review.
-- ============================================================

SELECT *
FROM Review
WHERE user_id = 1
    AND hobby_id = 1
ORDER BY review_date;


-- ============================================================
-- DEMO 3: Show Review depends on EnrolledIn
-- ------------------------------------------------------------
-- Join Review to the EnrolledIn relationship that identifies it.
-- Every Review must correspond to an existing enrollment.
-- ============================================================

SELECT
    r.user_id,
    r.hobby_id,
    e.progress,
    e.skill_level,
    r.review_date,
    r.rating,
    r.comment
FROM Review r
JOIN EnrolledIn e
    ON r.user_id = e.user_id
   AND r.hobby_id = e.hobby_id
ORDER BY r.user_id, r.hobby_id, r.review_date;


-- ============================================================
-- DEMO 4: Review cannot exist without its EnrolledIn owner
-- ------------------------------------------------------------
-- User 1 exists.
-- Hobby 22 exists.
-- However, the pair (1, 22) does NOT exist in EnrolledIn.
--
-- Because Review has the composite foreign key:
--     (user_id, hobby_id) -> EnrolledIn(user_id, hobby_id)
--
-- this INSERT should FAIL with a foreign-key constraint error.
-- This demonstrates the existence dependency of the weak entity.
-- ============================================================

INSERT INTO Review (
    user_id,
    hobby_id,
    review_date,
    rating,
    comment
)
VALUES (
    1,
    22,
    '2026-08-17',
    5,
    'This review should fail.'
);