# HobbyQuest — CSC 370 Database Project

A MySQL-backed hobby-discovery platform where users find hobbies to learn, filter
them by category and difficulty, see the equipment and learning resources each
hobby needs, track their own progress, and join communities built around hobbies.

**Course:** CSC 370 – Database Systems (Summer 2026), University of Victoria
**Team:** Matthias Prael (V01016196), Dylan Conarroe (V00897073), Layan Hazmi (V00049978)

## Repository structure

    sql/
      setup_01.sql     Schema (CREATE DATABASE + all tables and keys)
      seed_data.sql    Sample data to populate the database
      query_plan.sql   Demonstration queries against the schema
    docs/
      CSC_370_ERD.png  Entity-Relationship Diagram
      sprint_1.md      Sprint 1 progress report

## How to run

Requires a running MySQL (or MariaDB) server. From the repo root, run in order:

    mysql -u root -p < sql/setup_01.sql
    mysql -u root -p < sql/seed_data.sql
    mysql -u root -p CSC370_hobby_platform < sql/query_plan.sql

The third command prints the query results to your terminal. To re-run from
scratch, drop the database first (DROP DATABASE CSC370_hobby_platform;).
