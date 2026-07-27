-- Seed Data for CSC370_hobby_platform

USE CSC370_hobby_platform;


-- Category

INSERT INTO Category (category_id, name, category_type) VALUES
(1, 'Outdoor Sports', 'Physical'),
(2, 'Arts & Crafts', 'Indoor'),
(3, 'Music', 'Indoor'),
(4, 'Fitness', 'Physical'),
(5, 'Culinary', 'Indoor');

-- Hobbies

INSERT INTO Hobbies (hobby_id, name, description, difficulty) VALUES
(1, 'Rock Climbing', 'Climbing natural or artificial rock formations/walls', 'Intermediate'),
(2, 'Watercolor Painting', 'Painting using water-based pigments', 'Beginner'),
(3, 'Guitar', 'Learning to play acoustic or electric guitar', 'Beginner'),
(4, 'Bouldering', 'Climbing short routes without a rope', 'Beginner'),
(5, 'Pottery', 'Shaping clay into functional or decorative objects', 'Intermediate'),
(6, 'Running', 'Distance running for fitness or competition', 'Beginner'),
(7, 'Bread Baking', 'Baking artisan breads from scratch', 'Beginner'),
(8, 'Photography', 'Capturing images using a camera', 'Intermediate');

-- ClassifiedAs (Hobby <-> Category)
INSERT INTO ClassifiedAs (hobby_id, category_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 1), (5, 2), (6, 4), (7, 5), (8, 2);


-- Equipment

INSERT INTO Equipment (name, tool_id, cost) VALUES
('Climbing Harness', 1, 60),
('Climbing Shoes', 2, 90),
('Watercolor Paint Set', 3, 25),
('Watercolor Paper', 4, 15),
('Acoustic Guitar', 5, 150),
('Guitar Tuner', 6, 10),
('Bouldering Crash Pad', 7, 120),
('Pottery Wheel', 8, 200),
('Clay (5lb)', 9, 20),
('Running Shoes', 10, 80),
('Dutch Oven', 11, 45),
('Digital Camera', 12, 400);

-- Requires_tools (Hobby <-> Equipment, with is_required)
INSERT INTO Requires_tools (is_required, tool_id, hobby_id) VALUES
(TRUE, 1, 1),
(TRUE, 2, 1),
(TRUE, 3, 2),
(TRUE, 4, 2),
(TRUE, 5, 3),
(FALSE, 6, 3),
(TRUE, 2, 4),
(FALSE, 7, 4),
(TRUE, 8, 5),
(TRUE, 9, 5),
(TRUE, 10, 6),
(FALSE, 11, 7),
(TRUE, 12, 8);


-- Resources

INSERT INTO Resources (resource_id, title, resource_type, url) VALUES
(1, 'Intro to Rock Climbing Technique', 'Video', 'https://example.com/climbing-intro'),
(2, 'Watercolor Basics for Beginners', 'Tutorial', 'https://example.com/watercolor-basics'),
(3, 'Learn Guitar in 30 Days', 'Article', 'https://example.com/guitar-30-days'),
(4, 'Bouldering Fundamentals', 'Video', 'https://example.com/bouldering-fundamentals'),
(5, 'Wheel Throwing for Beginners', 'Tutorial', 'https://example.com/pottery-wheel-throwing'),
(6, 'Couch to 5K Guide', 'Article', 'https://example.com/couch-to-5k'),
(7, 'Artisan Bread at Home', 'Video', 'https://example.com/artisan-bread'),
(8, 'Manual Camera Settings Explained', 'Article', 'https://example.com/manual-camera-settings');

-- HasResource (Hobby <-> Resource)
INSERT INTO HasResource (hobby_id, resource_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8);


-- Users

INSERT INTO Users (user_id, username, email, password, date_joined) VALUES
(1, 'alex_climbs', 'alex@example.com', 'hashed_pw_1', '2026-01-15'),
(2, 'maria_paints', 'maria@example.com', 'hashed_pw_2', '2026-02-03'),
(3, 'sam_strums', 'sam@example.com', 'hashed_pw_3', '2026-02-20'),
(4, 'jordan_runs', 'jordan@example.com', 'hashed_pw_4', '2026-03-10'),
(5, 'priya_bakes', 'priya@example.com', 'hashed_pw_5', '2026-04-01');


-- EnrolledIn (User <-> Hobby, with progress/skill_level)

INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level) VALUES
(1, 1, 40, 'Intermediate'),
(1, 4, 70, 'Beginner'),
(2, 2, 85, 'Beginner'),
(3, 3, 20, 'Beginner'),
(4, 6, 60, 'Beginner'),
(5, 7, 90, 'Beginner'),
(2, 8, 10, 'Beginner');


-- Communities (1:1 with hobby -- only some hobbies have one)

INSERT INTO Communities (community_id, hobby_id, name, platform, invite_link) VALUES
(1, 1, 'Rock Climbers United', 'Discord', 'https://example.com/invite/climbers'),
(2, 2, 'Watercolor Circle', 'Discord', 'https://example.com/invite/painters'),
(3, 3, 'Guitar Hub', 'Discord', 'https://example.com/invite/guitarists');

-- Joins (User <-> Hobby's community; must already be enrolled in that hobby)
INSERT INTO Joins (user_id, hobby_id) VALUES
(1, 1),
(2, 2),
(3, 3);
