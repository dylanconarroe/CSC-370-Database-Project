-- Seed Data for CSC370_hobby_platform

USE CSC370_hobby_platform;


-- Category

INSERT INTO Category (category_id, name, category_type) VALUES
(1, 'Outdoor Sports', 'Physical'),
(2, 'Arts & Crafts', 'Indoor'),
(3, 'Music', 'Indoor'),
(4, 'Fitness', 'Physical'),
(5, 'Culinary', 'Indoor'),
(6, 'Games & Strategy', 'Indoor'),
(7, 'Nature & Outdoors', 'Physical'),
(8, 'Technology', 'Indoor');

-- Hobbies (22 total)

INSERT INTO Hobbies (hobby_id, name, description, difficulty) VALUES
(1, 'Rock Climbing', 'Climbing natural or artificial rock formations/walls', 'Intermediate'),
(2, 'Watercolor Painting', 'Painting using water-based pigments', 'Beginner'),
(3, 'Guitar', 'Learning to play acoustic or electric guitar', 'Beginner'),
(4, 'Bouldering', 'Climbing short routes without a rope', 'Beginner'),
(5, 'Pottery', 'Shaping clay into functional or decorative objects', 'Intermediate'),
(6, 'Running', 'Distance running for fitness or competition', 'Beginner'),
(7, 'Bread Baking', 'Baking artisan breads from scratch', 'Beginner'),
(8, 'Photography', 'Capturing images using a camera', 'Intermediate'),
(9,  'Chess', 'Strategic board game for two players', 'Beginner'),
(10, 'Woodworking', 'Building and shaping objects out of wood', 'Intermediate'),
(11, 'Yoga', 'Practicing physical postures and breathing techniques', 'Beginner'),
(12, 'Kayaking', 'Paddling a small boat on rivers, lakes, or the ocean', 'Intermediate'),
(13, 'Knitting', 'Creating fabric from yarn using needles', 'Beginner'),
(14, 'Birdwatching', 'Observing and identifying wild birds', 'Beginner'),
(15, '3D Printing', 'Designing and printing physical objects from digital models', 'Advanced'),
(16, 'Calligraphy', 'Artistic writing using specialized pens and lettering styles', 'Beginner'),
(17, 'Cycling', 'Riding a bicycle for fitness, commuting, or sport', 'Beginner'),
(18, 'Fishing', 'Catching fish using a rod, line, and bait or lures', 'Beginner'),
(19, 'Board Game Design', 'Designing and prototyping original tabletop games', 'Advanced'),
(20, 'Home Brewing', 'Brewing beer or cider at home', 'Intermediate'),
(21, 'Video Editing', 'Editing raw footage into finished video content', 'Intermediate'),
(22, 'Gardening', 'Growing plants, vegetables, or flowers', 'Beginner');

-- ClassifiedAs (Hobby <-> Category)
INSERT INTO ClassifiedAs (hobby_id, category_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 1), (5, 2), (6, 4), (7, 5), (8, 2),
(9, 6), (10, 2), (11, 4), (12, 1), (13, 2), (14, 7), (15, 8), (16, 2),
(17, 4), (18, 7), (19, 6), (20, 5), (21, 8), (22, 7);


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
('Digital Camera', 12, 400),
('Chess Set', 13, 25),
('Table Saw', 14, 350),
('Wood Chisel Set', 15, 40),
('Yoga Mat', 16, 30),
('Kayak', 17, 600),
('Paddle', 18, 70),
('Knitting Needles', 19, 12),
('Yarn (Bundle)', 20, 18),
('Binoculars', 21, 90),
('Bird Field Guide', 22, 20),
('3D Printer', 23, 500),
('Calligraphy Pen Set', 24, 22),
('Road Bike', 25, 450),
('Fishing Rod', 26, 65),
('Tackle Box', 27, 35),
('Board Game Prototype Kit', 28, 40),
('Home Brew Kit', 29, 100),
('Video Editing Software License', 30, 60),
('Garden Trowel Set', 31, 15);

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
(TRUE, 12, 8),
(TRUE, 13, 9),
(TRUE, 14, 10), 
(TRUE, 15, 10),
(TRUE, 16, 11),
(TRUE, 17, 12), 
(TRUE, 18, 12),
(TRUE, 19, 13), 
(TRUE, 20, 13),
(TRUE, 21, 14), 
(FALSE, 22, 14),
(TRUE, 23, 15),
(TRUE, 24, 16),
(TRUE, 25, 17),
(TRUE, 26, 18), 
(TRUE, 27, 18),
(TRUE, 28, 19),
(TRUE, 29, 20),
(TRUE, 30, 21),
(TRUE, 31, 22);

-- Resources

INSERT INTO Resources (resource_id, title, resource_type, url) VALUES
(1, 'Intro to Rock Climbing Technique', 'Video', 'https://example.com/climbing-intro'),
(2, 'Watercolor Basics for Beginners', 'Tutorial', 'https://example.com/watercolor-basics'),
(3, 'Learn Guitar in 30 Days', 'Article', 'https://example.com/guitar-30-days'),
(4, 'Bouldering Fundamentals', 'Video', 'https://example.com/bouldering-fundamentals'),
(5, 'Wheel Throwing for Beginners', 'Tutorial', 'https://example.com/pottery-wheel-throwing'),
(6, 'Couch to 5K Guide', 'Article', 'https://example.com/couch-to-5k'),
(7, 'Artisan Bread at Home', 'Video', 'https://example.com/artisan-bread'),
(8, 'Manual Camera Settings Explained', 'Article', 'https://example.com/manual-camera-settings'),
(9,  'Chess Openings for Beginners', 'Video', 'https://example.com/chess-openings'),
(10, 'Basic Woodworking Joints', 'Tutorial', 'https://example.com/woodworking-joints'),
(11, 'Beginner Yoga Flow', 'Video', 'https://example.com/beginner-yoga'),
(12, 'Kayaking Safety and Basics', 'Article', 'https://example.com/kayaking-basics'),
(13, 'How to Knit a Scarf', 'Tutorial', 'https://example.com/knit-a-scarf'),
(14, 'Birdwatching for Beginners', 'Article', 'https://example.com/birdwatching-beginners'),
(15, 'Intro to 3D Modeling and Printing', 'Video', 'https://example.com/3d-printing-intro'),
(16, 'Modern Calligraphy Basics', 'Tutorial', 'https://example.com/calligraphy-basics'),
(17, 'Cycling for Beginners', 'Article', 'https://example.com/cycling-beginners'),
(18, 'Freshwater Fishing 101', 'Video', 'https://example.com/fishing-101'),
(19, 'Designing Your First Board Game', 'Article', 'https://example.com/board-game-design'),
(20, 'Home Brewing Step by Step', 'Tutorial', 'https://example.com/home-brewing'),
(21, 'Video Editing Fundamentals', 'Video', 'https://example.com/video-editing-fundamentals'),
(22, 'Starting a Vegetable Garden', 'Article', 'https://example.com/vegetable-garden');

-- HasResource (Hobby <-> Resource)
INSERT INTO HasResource (hobby_id, resource_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8),
(9, 9), (10, 10), (11, 11), (12, 12), (13, 13), (14, 14), (15, 15), 
(16, 16), (17, 17), (18, 18), (19, 19), (20, 20), (21, 21), (22, 22);


-- Users

INSERT INTO Users (user_id, username, email, password, date_joined) VALUES
(1, 'alex_climbs', 'alex@example.com', 'hashed_pw_1', '2026-01-15'),
(2, 'maria_paints', 'maria@example.com', 'hashed_pw_2', '2026-02-03'),
(3, 'sam_strums', 'sam@example.com', 'hashed_pw_3', '2026-02-20'),
(4, 'jordan_runs', 'jordan@example.com', 'hashed_pw_4', '2026-03-10'),
(5, 'priya_bakes', 'priya@example.com', 'hashed_pw_5', '2026-04-01'),
(6, 'evan_carves', 'evan@example.com', 'hashed_pw_6', '2026-04-12'),
(7, 'nina_knits', 'nina@example.com', 'hashed_pw_7', '2026-04-20');


-- EnrolledIn (User <-> Hobby, with progress/skill_level)

INSERT INTO EnrolledIn (user_id, hobby_id, progress, skill_level) VALUES
(1, 1, 40, 'Intermediate'),
(1, 4, 70, 'Beginner'),
(2, 2, 85, 'Beginner'),
(3, 3, 20, 'Beginner'),
(4, 6, 60, 'Beginner'),
(5, 7, 90, 'Beginner'),
(2, 8, 10, 'Beginner'),
(2, 16, 50, 'Beginner'),
(3, 3, 20, 'Beginner'),
(3, 9, 65, 'Intermediate'),
(4, 6, 60, 'Beginner'),
(4, 17, 30, 'Beginner'),
(5, 7, 90, 'Beginner'),
(5, 20, 25, 'Beginner'),
(6, 10, 45, 'Intermediate'),
(6, 15, 5, 'Beginner'),
(7, 13, 80, 'Beginner'),
(7, 22, 35, 'Beginner');


-- Communities (1:1 with hobby -- only some hobbies have one)

INSERT INTO Communities (community_id, hobby_id, name, platform, invite_link) VALUES
(1, 1, 'Rock Climbers United', 'Discord', 'https://example.com/invite/climbers'),
(2, 2, 'Watercolor Circle', 'Discord', 'https://example.com/invite/painters'),
(3, 3, 'Guitar Hub', 'Discord', 'https://example.com/invite/guitarists');
(4, 9, 'Chess Club Online', 'Discord', 'https://example.com/invite/chess'),
(5, 17, 'Cycling Crew', 'Discord', 'https://example.com/invite/cycling');

-- Joins (User <-> Hobby's community; must already be enrolled in that hobby)
INSERT INTO Joins (user_id, hobby_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(3, 9),
(4, 17);
