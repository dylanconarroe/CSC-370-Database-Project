-- ============================================================
-- Sprint 5: Simplifying SQL
-- CSC370_hobby_platform
--
-- Three queries from query_plan.sql, rewritten where the
-- operator count allows. Each rewrite is checked against its
-- original in both directions, so a rewrite that changed the
-- answer cannot pass unnoticed. The analysis is in
-- docs/simplifying_sql.md.
--
-- Run after setup_01.sql and seed_data.sql.
-- Re-runnable: this file only reads.
-- ============================================================

USE CSC370_hobby_platform;


-- ============================================================
-- DEMO 1: Query 5, NOT IN rewritten as a set difference
-- ------------------------------------------------------------
-- NOT IN is not a relational algebra operator. The operation
-- wanted here is set difference, written in MySQL as an
-- anti-join, since there is no EXCEPT.
-- ============================================================

SELECT '===== DEMO 1 ORIGINAL: NOT IN =====' AS marker;

SELECT h.name AS hobby_name, c.name AS category_name
FROM Hobbies h
JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
JOIN Category c ON ca.category_id = c.category_id
WHERE h.hobby_id NOT IN (
    SELECT hobby_id FROM EnrolledIn WHERE user_id = 1
)
ORDER BY hobby_name;


SELECT '===== DEMO 1 REWRITE: anti-join =====' AS marker;

SELECT h.name AS hobby_name, c.name AS category_name
FROM Hobbies h
JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
JOIN Category c ON ca.category_id = c.category_id
LEFT JOIN EnrolledIn ei
       ON ei.hobby_id = h.hobby_id
      AND ei.user_id = 1
WHERE ei.hobby_id IS NULL
ORDER BY hobby_name;


SELECT '===== DEMO 1 CHECK (expect 0 and 0) =====' AS marker;

SELECT
  (SELECT COUNT(*) FROM (
     SELECT h.name AS a, c.name AS b
     FROM Hobbies h
     JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
     JOIN Category c ON ca.category_id = c.category_id
     WHERE h.hobby_id NOT IN (SELECT hobby_id FROM EnrolledIn WHERE user_id = 1)
   ) o
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT h.name AS a, c.name AS b
       FROM Hobbies h
       JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
       JOIN Category c ON ca.category_id = c.category_id
       LEFT JOIN EnrolledIn ei ON ei.hobby_id = h.hobby_id AND ei.user_id = 1
       WHERE ei.hobby_id IS NULL
     ) n WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_original_only,
  (SELECT COUNT(*) FROM (
     SELECT h.name AS a, c.name AS b
     FROM Hobbies h
     JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
     JOIN Category c ON ca.category_id = c.category_id
     LEFT JOIN EnrolledIn ei ON ei.hobby_id = h.hobby_id AND ei.user_id = 1
     WHERE ei.hobby_id IS NULL
   ) n
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT h.name AS a, c.name AS b
       FROM Hobbies h
       JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
       JOIN Category c ON ca.category_id = c.category_id
       WHERE h.hobby_id NOT IN (SELECT hobby_id FROM EnrolledIn WHERE user_id = 1)
     ) o WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_rewrite_only;


-- ============================================================
-- DEMO 2: Query 13, correlated scalar subquery becomes a join
-- ------------------------------------------------------------
-- The original re-runs its subquery once per hobby. The rewrite
-- pushes the is_required selection into the join condition and
-- covers every hobby in one aggregation. LEFT JOIN is required,
-- since the original returns 0 for hobbies with no equipment.
-- ============================================================

SELECT '===== DEMO 2 ORIGINAL: correlated scalar subquery =====' AS marker;

SELECT h.name AS hobby_name,
       (SELECT COALESCE(SUM(e.cost), 0)
        FROM Requires_tools rt
        JOIN Equipment e ON rt.tool_id = e.tool_id
        WHERE rt.hobby_id = h.hobby_id
          AND rt.is_required = TRUE) AS required_equipment_cost
FROM Hobbies h
ORDER BY required_equipment_cost DESC, hobby_name;


SELECT '===== DEMO 2 REWRITE: one join, one aggregation =====' AS marker;

SELECT h.name AS hobby_name,
       COALESCE(SUM(e.cost), 0) AS required_equipment_cost
FROM Hobbies h
LEFT JOIN Requires_tools rt
       ON rt.hobby_id = h.hobby_id
      AND rt.is_required = TRUE
LEFT JOIN Equipment e ON rt.tool_id = e.tool_id
GROUP BY h.hobby_id, h.name
ORDER BY required_equipment_cost DESC, hobby_name;


SELECT '===== DEMO 2 CHECK (expect 0 and 0) =====' AS marker;

SELECT
  (SELECT COUNT(*) FROM (
     SELECT h.name AS a,
            (SELECT COALESCE(SUM(e.cost), 0) FROM Requires_tools rt
             JOIN Equipment e ON rt.tool_id = e.tool_id
             WHERE rt.hobby_id = h.hobby_id AND rt.is_required = TRUE) AS b
     FROM Hobbies h
   ) o
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT h.name AS a, COALESCE(SUM(e.cost), 0) AS b
       FROM Hobbies h
       LEFT JOIN Requires_tools rt ON rt.hobby_id = h.hobby_id AND rt.is_required = TRUE
       LEFT JOIN Equipment e ON rt.tool_id = e.tool_id
       GROUP BY h.hobby_id, h.name
     ) n WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_original_only,
  (SELECT COUNT(*) FROM (
     SELECT h.name AS a, COALESCE(SUM(e.cost), 0) AS b
     FROM Hobbies h
     LEFT JOIN Requires_tools rt ON rt.hobby_id = h.hobby_id AND rt.is_required = TRUE
     LEFT JOIN Equipment e ON rt.tool_id = e.tool_id
     GROUP BY h.hobby_id, h.name
   ) n
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT h.name AS a,
              (SELECT COALESCE(SUM(e.cost), 0) FROM Requires_tools rt
               JOIN Equipment e ON rt.tool_id = e.tool_id
               WHERE rt.hobby_id = h.hobby_id AND rt.is_required = TRUE) AS b
       FROM Hobbies h
     ) o WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_rewrite_only;


-- ============================================================
-- DEMO 3: Query 14, derived table flattened into HAVING
-- ------------------------------------------------------------
-- The outer WHERE filters an aggregate, which is what HAVING is
-- for, so the derived table does no work and can be flattened.
-- ============================================================

SELECT '===== DEMO 3 ORIGINAL: derived table + outer WHERE =====' AS marker;

SELECT category_name, hobby_count
FROM (
    SELECT c.name AS category_name, COUNT(*) AS hobby_count
    FROM ClassifiedAs ca
    JOIN Category c ON ca.category_id = c.category_id
    GROUP BY c.name
) AS category_counts
WHERE hobby_count > 1
ORDER BY hobby_count DESC, category_name;


SELECT '===== DEMO 3 REWRITE: HAVING =====' AS marker;

SELECT c.name AS category_name, COUNT(*) AS hobby_count
FROM ClassifiedAs ca
JOIN Category c ON ca.category_id = c.category_id
GROUP BY c.name
HAVING COUNT(*) > 1
ORDER BY hobby_count DESC, category_name;


SELECT '===== DEMO 3 CHECK (expect 0 and 0) =====' AS marker;

SELECT
  (SELECT COUNT(*) FROM (
     SELECT category_name AS a, hobby_count AS b
     FROM (SELECT c.name AS category_name, COUNT(*) AS hobby_count
           FROM ClassifiedAs ca JOIN Category c ON ca.category_id = c.category_id
           GROUP BY c.name) AS cc
     WHERE hobby_count > 1
   ) o
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT c.name AS a, COUNT(*) AS b
       FROM ClassifiedAs ca JOIN Category c ON ca.category_id = c.category_id
       GROUP BY c.name HAVING COUNT(*) > 1
     ) n WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_original_only,
  (SELECT COUNT(*) FROM (
     SELECT c.name AS a, COUNT(*) AS b
     FROM ClassifiedAs ca JOIN Category c ON ca.category_id = c.category_id
     GROUP BY c.name HAVING COUNT(*) > 1
   ) n
   WHERE NOT EXISTS (
     SELECT 1 FROM (
       SELECT category_name AS a, hobby_count AS b
       FROM (SELECT c.name AS category_name, COUNT(*) AS hobby_count
             FROM ClassifiedAs ca JOIN Category c ON ca.category_id = c.category_id
             GROUP BY c.name) AS cc
       WHERE hobby_count > 1
     ) o WHERE n.a <=> o.a AND n.b <=> o.b)
  ) AS in_rewrite_only;


-- ============================================================
-- DEMO 4: Query 8, already optimal
-- ------------------------------------------------------------
-- One aggregation and one projection, which is exactly what the
-- question needs. Nothing to push, reorder or flatten.
--
-- DEMO 3's rewrite is also optimal now: HAVING cannot be pushed
-- below GROUP BY, because selection does not distribute over
-- aggregation. MySQL enforces this directly, rejecting
-- WHERE COUNT(*) > 1 with ERROR 1111 Invalid use of group
-- function.
-- ============================================================

SELECT '===== DEMO 4: already optimal, left unchanged =====' AS marker;

SELECT skill_level, AVG(progress) AS avg_progress
FROM EnrolledIn
GROUP BY skill_level
ORDER BY skill_level;
