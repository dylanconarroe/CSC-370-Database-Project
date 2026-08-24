DROP DATABASE IF EXISTS CSC370_hobby_platform;
CREATE DATABASE CSC370_hobby_platform;
USE CSC370_hobby_platform;

-- Entity Relations

CREATE TABLE Users (
    `user_id` int PRIMARY KEY,
    `username` varchar(64),
    `email` varchar(128),
    `password` varchar(255),
    `date_joined` date
);

CREATE TABLE Hobbies (
    `hobby_id` int PRIMARY KEY,
    `name` varchar(128),
    `description` varchar(500),
    `difficulty` varchar(32)
);

CREATE TABLE Communities (
    `community_id` int PRIMARY KEY,
    `hobby_id` int UNIQUE,
    `name` varchar(128),
    `platform` varchar(32),
    `invite_link` varchar(500),

    -- One community per hobby
    FOREIGN KEY (hobby_id) REFERENCES Hobbies (hobby_id)
);

CREATE TABLE Equipment (
    `name` varchar(32),
    `tool_id` int PRIMARY KEY,
    `cost` int 
);

CREATE TABLE Resources (
    `resource_id` int PRIMARY KEY,
    `title` varchar(128),
    `url` varchar(500)
);

CREATE TABLE Category (
    `category_id` int PRIMARY KEY,
    `name` varchar(128),
    `category_type` varchar(128)
);


-- Resource Subtypes

CREATE TABLE Video (
    `resource_id` int PRIMARY KEY,
    `duration_minutes` int NOT NULL,
    `platform` varchar(64) NOT NULL,

    FOREIGN KEY (resource_id) REFERENCES Resources (resource_id)
        ON DELETE CASCADE
);

CREATE TABLE Article (
    `resource_id` int PRIMARY KEY,
    `word_count` int NOT NULL,
    `author` varchar(128) NOT NULL,

    FOREIGN KEY (resource_id) REFERENCES Resources (resource_id)
        ON DELETE CASCADE
);

CREATE TABLE Tutorial (
    `resource_id` int PRIMARY KEY,
    `steps_count` int NOT NULL,
    `estimated_completion_minutes` int NOT NULL,

    FOREIGN KEY (resource_id) REFERENCES Resources (resource_id)
        ON DELETE CASCADE
);


-- Realationship Realtions

CREATE TABLE EnrolledIn (
    `user_id` int,
    `hobby_id` int,
    `progress` int,
    `skill_level` varchar(32),
    PRIMARY KEY (user_id, hobby_id),

    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (hobby_id) REFERENCES Hobbies (hobby_id)
);

CREATE TABLE Joins (
    `user_id` int,
    `hobby_id` int,
    PRIMARY KEY (user_id, hobby_id),

    -- User must be enrolled in hobby to join the community chat
    FOREIGN KEY (user_id, hobby_id) REFERENCES EnrolledIn (user_id, hobby_id),

    FOREIGN KEY (hobby_id) REFERENCES Communities (hobby_id)
);

-- Review: weak entity identified through EnrolledIn.
-- Borrows (user_id, hobby_id) and adds its partial key review_date.

CREATE TABLE Review (
    `user_id` int,
    `hobby_id` int,
    `review_date` date,
    `rating` int NOT NULL,
    `comment` varchar(500),

    PRIMARY KEY (user_id, hobby_id, review_date),

    FOREIGN KEY (user_id, hobby_id)
        REFERENCES EnrolledIn (user_id, hobby_id)
        ON DELETE CASCADE,

    CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE HasResource (
    `hobby_id` int,
    `resource_id` int,
    PRIMARY KEY (hobby_id, resource_id),

    FOREIGN KEY (hobby_id) REFERENCES Hobbies (hobby_id),
    FOREIGN KEY (resource_id) REFERENCES Resources (resource_id)
);

CREATE TABLE Requires_tools (
    `is_required` boolean,
    `tool_id` int,
    `hobby_id` int,
    PRIMARY KEY (tool_id, hobby_id),

    FOREIGN KEY (hobby_id) REFERENCES Hobbies (hobby_id),
    FOREIGN KEY (tool_id) REFERENCES Equipment (tool_id)
);

CREATE TABLE ClassifiedAs (
    `category_id` int,
    `hobby_id` int,
    PRIMARY KEY (hobby_id, category_id),

    FOREIGN KEY (hobby_id) REFERENCES Hobbies (hobby_id),
    FOREIGN KEY (category_id) REFERENCES Category (category_id)

);



