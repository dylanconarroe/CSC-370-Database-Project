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


-- Allows us to rerun this file while testing
DROP TABLE IF EXISTS Video;
DROP TABLE IF EXISTS Article;
DROP TABLE IF EXISTS Tutorial;


-- ============================================================
-- VIDEO SUBTYPE
-- ============================================================

CREATE TABLE Video (
    resource_id INT PRIMARY KEY,
    duration_minutes INT,
    platform VARCHAR(64),

    FOREIGN KEY (resource_id)
        REFERENCES Resources(resource_id)
        ON DELETE CASCADE
);


-- ============================================================
-- ARTICLE SUBTYPE
-- ============================================================

CREATE TABLE Article (
    resource_id INT PRIMARY KEY,
    word_count INT,
    author VARCHAR(128),

    FOREIGN KEY (resource_id)
        REFERENCES Resources(resource_id)
        ON DELETE CASCADE
);


-- ============================================================
-- TUTORIAL SUBTYPE
-- ============================================================

CREATE TABLE Tutorial (
    resource_id INT PRIMARY KEY,
    steps_count INT,
    estimated_completion_minutes INT,

    FOREIGN KEY (resource_id)
        REFERENCES Resources(resource_id)
        ON DELETE CASCADE
);



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

SELECT
    (SELECT COUNT(*) FROM Video) AS videos,
    (SELECT COUNT(*) FROM Article) AS articles,
    (SELECT COUNT(*) FROM Tutorial) AS tutorials,
    (SELECT COUNT(*) FROM Resources) AS total_resources;


-- ============================================================
-- DEMO 3: FOREIGN KEY DEPENDENCY
-- ============================================================


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
