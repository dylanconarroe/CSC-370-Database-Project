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
    `resource_type` varchar(32),
    `url` varchar(500)
);

CREATE TABLE Category (
    `category_id` int PRIMARY KEY,
    `name` varchar(128),
    `category_type` varchar(128)
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



