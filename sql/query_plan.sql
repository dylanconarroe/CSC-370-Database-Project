-- ============================================================
-- Query Plan: CSC370_hobby_platform
-- Matches actual schema in sql/setup_01.sql
-- ============================================================

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
SELECT h.name AS hobby_name, r.title, r.resource_type, r.url
FROM Hobbies h
JOIN HasResource hr ON h.hobby_id = hr.hobby_id
JOIN Resources r ON hr.resource_id = r.resource_id
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
