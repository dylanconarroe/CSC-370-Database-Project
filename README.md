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
      indexes.sql      Index speedup shown with EXPLAIN (before/after)
      security.sql     Views, a restricted account, and GRANT/REVOKE
      transactions.sql Atomicity: COMMIT vs ROLLBACK
      constraints.sql  Consistency: CHECK constraints
      isolation.sql    Isolation: dirty read across two sessions
      durability.sql   Durability: committed data survives a crash (redo log)
    docs/
      CSC_370_ERD.png  Entity-Relationship Diagram
      normalization.md BCNF normalization analysis
      sprint_1.md      Sprint 1 progress report
      sprint_2.md      Sprint 2 progress report
      sprint_3.md      Sprint 3 progress report
      
      

## How to run

Requires a running MySQL (or MariaDB) server. Commands below use `-t` for nicely
formatted table output. If your MySQL root account has a password, add `-p` after
`-u root` and it will prompt you for it.

### 1. Build and load the database (run these first, in order)

    mysql -u root -t < sql/setup_01.sql     # creates the database + all tables
    mysql -u root -t < sql/seed_data.sql    # loads the sample data

`setup_01.sql` drops and recreates the database, so it wipes any existing data.
Always run it before `seed_data.sql`. To reset to a clean state at any time, just
run those two commands again.

### 2. Sprint 2: queries and indexes
 
    mysql -u root -t < sql/query_plan.sql   # demonstration queries
    mysql -u root -t < sql/indexes.sql      # builds a large table, shows EXPLAIN before/after an index
 
### 3. Sprint 3: security and ACID
 
    mysql -u root -t < sql/security.sql              # views + restricted account + GRANT/REVOKE
    mysql -u root -t --force < sql/transactions.sql  # Atomicity
    mysql -u root -t --force < sql/constraints.sql   # Consistency
 
`transactions.sql` and `constraints.sql` need the `--force` flag. They trigger a
few errors *on purpose* (a failed transaction, rejected invalid values), and
without `--force` MySQL stops at the first error before the rest of the demo runs.
 
Two Sprint 3 demos are interactive and are **not** run with `mysql < file`:
 
* **security.sql: deny test.** After running `security.sql`, open a second
  terminal logged in as the restricted account to prove access is blocked:
      mysql -u hobby_app -p        # password: app_pw_demo
 
  then `SELECT * FROM Users;` fails with ERROR 1142, while
  `SELECT * FROM PublicHobbyCatalogue;` still works.
* **isolation.sql.** Demonstrates a dirty read using two MySQL sessions side by
  side. Open two terminals and follow the step-by-step, session-by-session
  instructions in the comments at the top of the file.
* **durability.sql.** Shows committed data surviving a server crash. It has
  three parts (commit rows in mysql, then `kill -9` the server and restart it in
  the terminal, then verify the rows are still there in mysql). Follow the
  PART 1 / PART 2 / PART 3 steps in the file.
### Re-running the demos
 
The demos change data (for example, `transactions.sql` enrolls a test user and
`constraints.sql` adds constraints). The simplest way to get a clean slate before
re-running is to reload the database:
 
    mysql -u root -t < sql/setup_01.sql
    mysql -u root -t < sql/seed_data.sql
