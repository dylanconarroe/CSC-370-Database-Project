-- ============================================================
-- Sprint 5: NULLs
-- CSC370_hobby_platform
--
-- Worked case: Hobbies and their Video resources (from the
-- Sprint 4 Resource specialization). Not every hobby's resource
-- is a Video -- some are Articles or Tutorials -- so joining
-- Hobbies through Resources into Video behaves differently
-- depending on join type.
--
-- Run after setup_01.sql, seed_data.sql, and inheritance.sql.
-- ============================================================

USE CSC370_hobby_platform;

-- ============================================================
-- DEMO 1: INNER JOIN drops hobbies whose resource isn't a Video
-- ============================================================

SELECT '===== INNER JOIN: hobbies with a Video resource only =====' AS marker;

SELECT h.hobby_id, h.name, v.platform, v.duration_minutes
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
INNER JOIN Video v ON r.resource_id = v.resource_id
ORDER BY h.hobby_id;

SELECT COUNT(*) AS inner_join_row_count
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
INNER JOIN Video v ON r.resource_id = v.resource_id;

-- ============================================================
-- DEMO 2: LEFT OUTER JOIN keeps every hobby, NULL where its
-- resource isn't a Video. Compare this count to Demo 1's.
-- ============================================================

SELECT '===== LEFT OUTER JOIN: every hobby, Video columns NULL where n/a =====' AS marker;

SELECT h.hobby_id, h.name, v.platform, v.duration_minutes
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id
ORDER BY h.hobby_id;

SELECT COUNT(*) AS left_join_row_count
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id;

-- Why the counts differ: the ON condition r.resource_id = v.resource_id
-- can only be TRUE when a matching Video row exists. When a hobby's
-- resource is an Article or Tutorial, there is no row in Video with
-- that resource_id at all -- the predicate isn't FALSE, there's simply
-- nothing on the right side to compare against. INNER JOIN keeps only
-- rows where the predicate evaluated TRUE, so those hobbies are
-- silently dropped. LEFT OUTER JOIN keeps every row from Hobbies
-- regardless, filling the Video-side columns with NULL when no match
-- exists.

-- ============================================================
-- DEMO 3: COALESCE to replace the NULLs the outer join introduces
-- ============================================================

SELECT '===== COALESCE: friendly report instead of raw NULLs =====' AS marker;

SELECT
    h.hobby_id,
    h.name,
    COALESCE(v.platform, 'No video available') AS platform,
    COALESCE(v.duration_minutes, 0)            AS duration_minutes
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id
ORDER BY h.hobby_id;

-- ============================================================
-- DEMO 4: three-valued logic -- a filter on the NULL-producing
-- side does NOT behave like "not a video". WHERE clauses treat
-- UNKNOWN the same as FALSE, so rows are dropped, not kept as
-- "not equal".
-- ============================================================

SELECT '===== Three-valued logic: platform <> YouTube excludes NULLs too =====' AS marker;

-- Intent: "hobbies whose video is not on YouTube". This silently
-- also drops every hobby with NO video at all (platform IS NULL),
-- because platform <> 'YouTube' evaluates to UNKNOWN, not TRUE,
-- when platform is NULL -- and WHERE only keeps rows where the
-- condition is TRUE.
SELECT h.hobby_id, h.name, v.platform
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id
WHERE v.platform <> 'YouTube';

-- The correct way to also catch the NULLs, if that was the intent:
SELECT h.hobby_id, h.name, v.platform
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id
WHERE v.platform <> 'YouTube' OR v.platform IS NULL;

-- ============================================================
-- DEMO 5: GROUP BY treats NULL as its own group, unlike a join
-- predicate, which never matches NULL to NULL.
-- ============================================================

SELECT '===== GROUP BY: all NULL platforms land in one group =====' AS marker;

SELECT v.platform, COUNT(*) AS resource_count
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT OUTER JOIN Video v ON r.resource_id = v.resource_id
GROUP BY v.platform;

-- Contrast with DEMO 1/2: a join predicate (r.resource_id = v.resource_id)
-- never groups or matches NULLs to each other -- NULL = NULL is
-- UNKNOWN, not TRUE, so it can't satisfy an equality join. GROUP BY
-- is different: it groups all NULL values of the grouping column
-- together into a single group, treating them as "the same" for
-- grouping purposes even though NULL = NULL is not true in a WHERE
-- or ON clause. This is a real inconsistency in how SQL treats NULL
-- depending on context.
