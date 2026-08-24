-- ============================================================
-- Sprint 4: Inheritance
-- CSC370_hobby_platform
--
-- Resources is the general entity set.
-- Video, Article, and Tutorial are subsets of Resources.
--
-- Each subtype uses resource_id as both:
--   - its primary key
--   - a foreign key to Resources
-- ============================================================

USE CSC370_hobby_platform;


-- ============================================================
-- DEMO 1: SHOW EACH RESOURCE SUBTYPE
-- ============================================================

SELECT '===== VIDEO RESOURCES =====' AS marker;

SELECT
    r.resource_id,
    r.title,
    v.duration_minutes,
    v.platform
FROM Resources r
JOIN Video v
    ON r.resource_id = v.resource_id
ORDER BY r.resource_id;


SELECT '===== ARTICLE RESOURCES =====' AS marker;

SELECT
    r.resource_id,
    r.title,
    a.word_count,
    a.author
FROM Resources r
JOIN Article a
    ON r.resource_id = a.resource_id
ORDER BY r.resource_id;


SELECT '===== TUTORIAL RESOURCES =====' AS marker;

SELECT
    r.resource_id,
    r.title,
    t.steps_count,
    t.estimated_completion_minutes
FROM Resources r
JOIN Tutorial t
    ON r.resource_id = t.resource_id
ORDER BY r.resource_id;


-- ============================================================
-- DEMO 2: VERIFY DISJOINT SUBTYPE MEMBERSHIP
-- ============================================================

SELECT '===== SUBTYPE COUNTS =====' AS marker;

SELECT
    (SELECT COUNT(*) FROM Video) AS videos,
    (SELECT COUNT(*) FROM Article) AS articles,
    (SELECT COUNT(*) FROM Tutorial) AS tutorials,
    (SELECT COUNT(*) FROM Resources) AS total_resources;


-- ============================================================
-- DEMO 3: VERIFY THE SPECIALIZATION IS DISJOINT
-- ============================================================

SELECT '===== DISJOINTNESS TEST (expect 0 rows) =====' AS marker;

SELECT resource_id, COUNT(*) AS subtype_memberships
FROM (
    SELECT resource_id FROM Video
    UNION ALL
    SELECT resource_id FROM Article
    UNION ALL
    SELECT resource_id FROM Tutorial
) AS all_memberships
GROUP BY resource_id
HAVING COUNT(*) > 1;


-- ============================================================
-- DEMO 4: VERIFY THE SPECIALIZATION IS TOTAL
-- ============================================================

SELECT '===== TOTALITY TEST (expect 0 rows) =====' AS marker;

SELECT r.resource_id, r.title
FROM Resources r
LEFT JOIN Video    v ON r.resource_id = v.resource_id
LEFT JOIN Article  a ON r.resource_id = a.resource_id
LEFT JOIN Tutorial t ON r.resource_id = t.resource_id
WHERE v.resource_id IS NULL
  AND a.resource_id IS NULL
  AND t.resource_id IS NULL;


-- ============================================================
-- DEMO 5: FOREIGN KEY DEPENDENCY
-- ============================================================

SELECT '===== FK TEST (expect ERROR 1452) =====' AS marker;

INSERT INTO Video (
    resource_id,
    duration_minutes,
    platform
)
VALUES (
    999,
    20,
    'YouTube'
);
