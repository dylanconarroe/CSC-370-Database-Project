CREATE DATABASE CSC370_hobby_platform;
USE CSC370_hobby_platform;

-- Entity Relations

    CREATE TABLE Users (
        'user_id' int AUTO_INCREMENT PRIMARY KEY,
        'username' varchar(64),
        'email' varchar(128),
        'password' varchar(255),
        'date_joined' date
    );

    CREATE TABLE Hobbies (
        'hobby_id' int PRIMARY KEY,
        'name' varchar(128),
        'description' varchar(500),
        'difficulty' varchar(32)
    );

    CREATE TABLE Communities (
        'community_id' int PRIMARY KEY,
        'name' varchar(128),
        'platform' varchar(32),
        'invite_link' varchar(500)
    );

    CREATE TABLE Equipment (
        'name' varchar(32),
        'tool_id' int PRIMARY KEY,
        'cost' int 
    );

    CREATE TABLE Resources (
        'resource_id' int PRIMARY KEY,
        'title' varchar(128),
        'resource_type' varchar(32),
        'url' varchar(500)
    );

    CREATE TABLE Category (
        'category_id' int PRIMARY KEY,
        'name' varchar(128),
        'category_type' varchar(128)
    );