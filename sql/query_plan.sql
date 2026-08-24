-- Query Plan: CSC370_hobby_platform
-- Matches actual schema in sql/setup_01.sql


USE CSC370_hobby_platform;

-- 1. Filter hobbies by category type and difficulty
SELECT h.hobby_id, h.name, h.difficulty, c.name AS category_name
FROM Hobbies h
JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
JOIN Category c ON ca.category_id = c.category_id
WHERE c.category_type = 'Physical'
  AND h.difficulty = 'Beginner';

-- 2. Get all tools/equipment required for a specific hobby
SELECT h.name AS hobby_name, e.name AS tool_name, e.cost, rt.is_required
FROM Hobbies h
JOIN Requires_tools rt ON h.hobby_id = rt.hobby_id
JOIN Equipment e ON rt.tool_id = e.tool_id
WHERE h.hobby_id = 1;

-- 2b. Total cost to get started in each hobby (required equipment only)
SELECT h.name AS hobby_name, SUM(e.cost) AS total_required_cost
FROM Hobbies h
JOIN Requires_tools rt ON h.hobby_id = rt.hobby_id
JOIN Equipment e ON rt.tool_id = e.tool_id
WHERE rt.is_required = TRUE
GROUP BY h.hobby_id, h.name;

-- 3. Get all resources/tutorials for a specific hobby
--    resource_type was dropped from Resources in Sprint 4: subtype membership
--    now carries that information, so storing the string too would duplicate it.
--    We derive the label back from which subtype the resource belongs to.
SELECT h.name AS hobby_name, r.title,
       CASE
           WHEN v.resource_id IS NOT NULL THEN 'Video'
           WHEN a.resource_id IS NOT NULL THEN 'Article'
           WHEN t.resource_id IS NOT NULL THEN 'Tutorial'
       END AS resource_type,
       r.url
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
LEFT JOIN Video    v ON r.resource_id = v.resource_id
LEFT JOIN Article  a ON r.resource_id = a.resource_id
LEFT JOIN Tutorial t ON r.resource_id = t.resource_id
WHERE h.hobby_id = 3;

-- 4. Get a user's enrolled hobbies with progress and skill level
SELECT u.username, h.name AS hobby_name, ei.progress, ei.skill_level
FROM EnrolledIn ei
JOIN Users u ON ei.user_id = u.user_id
JOIN Hobbies h ON ei.hobby_id = h.hobby_id
WHERE u.user_id = 1;

-- 5. Find hobbies a user hasn't started yet, filtered by category
SELECT h.name AS hobby_name, c.name AS category_name
FROM Hobbies h
JOIN ClassifiedAs ca ON h.hobby_id = ca.hobby_id
JOIN Category c ON ca.category_id = c.category_id
WHERE h.hobby_id NOT IN (
    SELECT hobby_id FROM EnrolledIn WHERE user_id = 1
);

-- 6. Get community info + members for a given hobby
--    (note: Communities is 1:1 with hobby_id in this schema)
SELECT c.name AS community_name, c.platform, u.username
FROM Joins j
JOIN Users u ON j.user_id = u.user_id
JOIN Communities c ON j.hobby_id = c.hobby_id
WHERE c.hobby_id = 1;

-- 7. Most popular hobbies by enrollment count
SELECT h.name AS hobby_name, COUNT(ei.user_id) AS enrolled_count
FROM Hobbies h
LEFT JOIN EnrolledIn ei ON h.hobby_id = ei.hobby_id
GROUP BY h.hobby_id, h.name
ORDER BY enrolled_count DESC;

-- 8. Average progress per skill level across all users
SELECT skill_level, AVG(progress) AS avg_progress
FROM EnrolledIn
GROUP BY skill_level;

-- 9. Hobbies that have an active community (join Hobbies to Communities)
SELECT h.name AS hobby_name, c.name AS community_name, c.invite_link
FROM Hobbies h
JOIN Communities c ON h.hobby_id = c.hobby_id;

-- ============================================================
-- Sprint 2 additions: subquery examples
-- ============================================================

-- 10. Correlated subquery: users whose progress on any hobby is
--     above their own average progress across all their hobbies
SELECT u.username, h.name AS hobby_name, ei.progress
FROM EnrolledIn ei
JOIN Users u ON ei.user_id = u.user_id
JOIN Hobbies h ON ei.hobby_id = h.hobby_id
WHERE ei.progress > (
    SELECT AVG(ei2.progress)
    FROM EnrolledIn ei2
    WHERE ei2.user_id = ei.user_id
);

-- 11. EXISTS subquery: hobbies that have at least one required
--     piece of equipment (as opposed to none required)
SELECT h.name AS hobby_name
FROM Hobbies h
WHERE EXISTS (
    SELECT 1
    FROM Requires_tools rt
    WHERE rt.hobby_id = h.hobby_id
      AND rt.is_required = TRUE
);

-- 12. NOT EXISTS subquery: hobbies with no community yet
--     (candidates for starting one)
SELECT h.name AS hobby_name, h.difficulty
FROM Hobbies h
WHERE NOT EXISTS (
    SELECT 1
    FROM Communities c
    WHERE c.hobby_id = h.hobby_id
);

-- 13. Scalar subquery in SELECT: each hobby alongside the total
--     cost of its required equipment
SELECT h.name AS hobby_name,
       (SELECT COALESCE(SUM(e.cost), 0)
        FROM Requires_tools rt
        JOIN Equipment e ON rt.tool_id = e.tool_id
        WHERE rt.hobby_id = h.hobby_id
          AND rt.is_required = TRUE) AS required_equipment_cost
FROM Hobbies h
ORDER BY required_equipment_cost DESC;

-- 14. Subquery in FROM (derived table): categories with their
--     average hobby difficulty rank, only showing categories
--     with more than one hobby
SELECT category_name, hobby_count
FROM (
    SELECT c.name AS category_name, COUNT(*) AS hobby_count
    FROM ClassifiedAs ca
    JOIN Category c ON ca.category_id = c.category_id
    GROUP BY c.name
) AS category_counts
WHERE hobby_count > 1
ORDER BY hobby_count DESC;
