# CSC 370 – Database Systems — Progress Report, Sprint #2

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael — V01016196
2. Dylan Conarroe — V00897073
3. Layan Hazmi — V00049978



## Recap of Previous Sprint Goals

Sprint 1 finished the relational model foundation: the ERD, the schema, the keys, and the referential integrity constraints. Coming out of it we set four measurable goals for this sprint, following the course order from the relational model into complex SQL and basic security:

* Complete the relational model by normalizing to BCNF: list the functional dependencies and a key for every relation, confirm each is in Boyce-Codd Normal Form, and show one worked decomposition of a deliberately denormalized example.
* Write complex SQL queries: scale the sample data to at least 20 hobbies and cover filtering, multi-table joins, GROUP BY aggregates, and at least one subquery, with a target of at least eight queries that run correctly.
* Add indexes: index a frequently filtered column and compare EXPLAIN output before and after, showing the access type improve from a full table scan to an index lookup.
* Basic security (if time permitted): add a view for a common need and sketch role permissions with GRANT and REVOKE, including a view that hides the password column.

## Evidence of Completion

* Normalized the schema to BCNF (normalization.md). We listed the functional dependencies and a key for all eleven relations, argued that every one is already in BCNF (no non-trivial dependency has a non-key determinant), and worked a full decomposition of a deliberately denormalized EnrolmentWide table to show the process and to justify why the production schema keeps Users separate from EnrolledIn.
* Scaled the sample data and wrote 14 complex queries (seed\_data.sql, query\_plan.sql).
* Demonstrated an index speedup with EXPLAIN (indexes.sql). We built a 50,000-row ActivityLog table so the optimiser has a realistic table to work with, then showed three indexes chosen the way the Accelerating SQL Queries material teaches, each with a before-and-after EXPLAIN.

  * A selective single-column index on hobby\_id takes the filter query from a full table scan (type ALL, about 50,000 rows) to an index lookup (type ref, key idx\_log\_hobby, about 2,273 rows).
  * A foreign-key index on user\_id turns a join to Users from a full scan into a lookup, which is why foreign-key columns are prime index targets.
  * And a composite, covering index on (hobby\_id, action) lets the query be answered from the index alone, shown by Using index in the EXPLAIN Extra column.
We also noted the trade-off: indexes speed reads at the cost of writes and storage, so we index the columns our real queries filter and join on rather than every column.



## Missed Goals

The only goal not completed this sprint was the optional basic security work. We prioritized completing and testing the other goals such as normalization and indexing first, which ended up taking longer than expected due to us expanding the dataset, verifying fourteen queries, and having to create a large enough benchmarking table so that the effects of the indexes were visible when calling EXPLAIN. 



Rather than include the security design untested/incomplete, we decided to defer this goal to Sprint 3, where we will create a view that hides the password column, define restricted roles, and verify the permissions using GRANT SHOWS and attempted unauthorized operations. 

## Next Sprint Plan

We plan on completing the missed basic security work and completing all of the ACID competencies.



1. **Ensure Atomicity -** create at least one operation involving multiple related SQL statements such as enrolling a user in a hobby and adding the corresponding related record. This will be done using START TRANSACTION, COMMIT, ROLLBACK. Success can be demonstrated by completing a successful transaction where every required change is committed and a failed transaction where no partial changes remain. 
2. **Enforce Consistency -** identify invariants that must always be true, enforcing them using constraints. For example restricting progress of a hobby to an appropriate range. Success can be verified by adding two CHECK constraints and demonstrating that valid values are accepted and invalid values are rejected. 
3. **Isolate Transactions -** (if time permits) Analyze concurrent operations, identify an anomaly that could occur, then choose and set appropriate isolation level. Success can be verified by demonstrating the behaviour of SQL sessions after explaining and setting isolation levels. 
4. **Preserve Durability -** (if time permits) We will create a recoverable starting point, perform a transaction, simulate data loss, and manually restored committed changes using log. Success can be verified by recovering the data using log and verifying the recovered records using SELECT queries. 

