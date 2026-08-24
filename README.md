# HobbyQuest — CSC 370 Database Project

A MySQL-backed hobby-discovery platform where users find hobbies to learn, filter
them by category and difficulty, see the equipment and learning resources each
hobby needs, track their own progress, and join communities built around hobbies.

**Course:** CSC 370 – Database Systems (Summer 2026), University of Victoria
**Team:** Matthias Prael (V01016196), Dylan Conarroe (V00897073), Layan Hazmi (V00049978)

## Repository structure

    sql/
      setup_01.sql                Schema: CREATE DATABASE + all 15 tables, keys and constraints
      seed_data.sql               Sample data for every table
      query_plan.sql              Demonstration queries against the schema
      indexes.sql                 Index speedup shown with EXPLAIN (before/after)
      security.sql                Views, a restricted account, and GRANT/REVOKE
      transactions.sql            Atomicity: COMMIT vs ROLLBACK
      constraints.sql             Consistency: CHECK constraints
      isolation.sql               Isolation: dirty read across two sessions
      durability.sql              Durability: committed data survives a crash (redo log)
      inheritance.sql             Resource specialization: subtype demos, plus disjointness and totality tests
      weak_entity.sql             Weak entity: Review identified through EnrolledIn, with demos
      nulls_demo.sql              NULLs: inner vs outer join, COALESCE, three-valued logic, GROUP BY
      constraints_triggers.sql    Attribute- and tuple-level CHECK, plus a derived-value trigger
      simplifying_sql.sql         Query rewrites with both-direction equivalence checks

      
    docs/
      CSC_370_ERD.png                  Entity-Relationship Diagram
      normalization.md                 BCNF normalization analysis
      3nf.md                           3NF synthesis and dependency preservation
      nulls.md                         NULL semantics, worked on the Resource specialization
      simplifying_sql.md               Relational algebra operator counts and rewrites
      sprint_1.md                      Sprint 1 progress report
      sprint_2.md                      Sprint 2 progress report
      sprint_3.md                      Sprint 3 progress report
      sprint_4.md                      Sprint 4 progress report
      sprint_4_conceptual_design.md    Inheritance and weak entity justification, quality evaluation, transforms
      sprint_5.md                      Sprint 5 progress report (final)
      
      

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

### 4. Sprint 4: advanced conceptual design

    mysql -u root -t --force < sql/inheritance.sql   # Resource specialization: Video, Article, Tutorial subtypes
    mysql -u root -t --force < sql/weak_entity.sql   # Review weak entity, identified through EnrolledIn

Both scripts need the `--force` flag: the last demo in each triggers an error
*on purpose*, the same intended-error pattern as `transactions.sql` and
`constraints.sql` in Sprint 3, and without `--force` MySQL stops before the
rest of the script finishes.


### 5. Sprint 5: 3NF, NULLs, constraints and triggers, Advanced SQL
 
    mysql -u root -t --force < sql/nulls_demo.sql
    mysql -u root -t --force < sql/constraints_triggers.sql
    mysql -u root -t --force < sql/simplifying_sql.sql
 
`nulls_demo.sql` produces no errors. The same join returns **8 rows** under
`INNER JOIN` and **22** under `LEFT OUTER JOIN`, and the 14-row gap is what the
inner join silently discards. Demo 4 is the sharp one: filtering
`platform <> 'YouTube'` returns **0 rows**, because for a hobby with no video the
comparison is `UNKNOWN` rather than `TRUE`. Adding `OR platform IS NULL` returns
**14**. Markers label the buggy and fixed versions, since the buggy one prints
nothing.
 
`constraints_triggers.sql` is *supposed* to fail four times, and those failures
are the point:
 
| Expected error | What it shows |
|---|---|
| `3819` | A CHECK cannot be added to a table that already violates it |
| `3819` | Once added, the constraint rejects a bad insert |
| `3813` | A column-level CHECK may not reference a second column, so the rule belongs at tuple level |
| `3819` | The tuple-level CHECK rejects a tutorial that claims to take less time than it has steps |
 
Then the trigger: `Hobbies.review_count` and `avg_rating` read `2 / 4.50` after
being backfilled from the seeded reviews, `3 / 4.67` after one review rated 5,
and `4 / 4.25` after one rated 3. The average rising then falling is the evidence
the value is recomputed rather than incremented, and neither `INSERT` mentions
those columns.
 
`simplifying_sql.sql` rewrites three queries from `query_plan.sql` and checks each
rewrite against its original in both directions. All three checks return
`in_original_only = 0` and `in_rewrite_only = 0`.


### Re-running the demos
 
The demos change data (for example, `transactions.sql` enrolls a test user and
`constraints.sql` adds constraints). The simplest way to get a clean slate before
re-running is to reload the database:
 
    mysql -u root -t < sql/setup_01.sql
    mysql -u root -t < sql/seed_data.sql
