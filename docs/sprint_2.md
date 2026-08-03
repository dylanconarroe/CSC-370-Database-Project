# CSC 370 – Database Systems — Progress Report, Sprint #2

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael — V01016196
2. Dylan Conarroe — V00897073
3. Layan Hazmi — V00049978



## Recap of Previous Sprint Goals 

Sprint 1 finished the relational model foundation: the ERD, the schema, the keys, and the referential integrity constraints. Coming out of it we set four measurable goals for this sprint, following the course order from the relational model into complex SQL and basic security:

- Complete the relational model by normalizing to BCNF: list the functional dependencies and a key for every relation, confirm each is in Boyce-Codd Normal Form, and show one worked decomposition of a deliberately denormalized example.
- Write complex SQL queries: scale the sample data to at least 20 hobbies and cover filtering, multi-table joins, GROUP BY aggregates, and at least one subquery, with a target of at least eight queries that run correctly.
- Add indexes: index a frequently filtered column and compare EXPLAIN output before and after, showing the access type improve from a full table scan to an index lookup.
- Basic security (if time permitted): add a view for a common need and sketch role permissions with GRANT and REVOKE, including a view that hides the password column.

## Evidence of Completion 
- Normalized the schema to BCNF (normalization.md). We listed the functional dependencies and a key for all eleven relations, argued that every one is already in BCNF (no non-trivial dependency has a non-key determinant), and worked a full decomposition of a deliberately denormalized EnrolmentWide table to show the process and to justify why the production schema keeps Users separate from EnrolledIn.
- Scaled the sample data and wrote 14 complex queries (seed_data.sql, query_plan.sql).
- Demonstrated an index speedup with EXPLAIN (indexes.sql). We built a 50,000-row ActivityLog table so the optimiser has a realistic table to work with, then showed three indexes chosen the way the Accelerating SQL Queries material teaches, each with a before-and-after EXPLAIN. 
  - A selective single-column index on hobby_id takes the filter query from a full table scan (type ALL, about 50,000 rows) to an index lookup (type ref, key idx_log_hobby, about 2,273 rows). 
  - A foreign-key index on user_id turns a join to Users from a full scan into a lookup, which is why foreign-key columns are prime index targets. 
  - And a composite, covering index on (hobby_id, action) lets the query be answered from the index alone, shown by Using index in the EXPLAIN Extra column. 
We also noted the trade-off: indexes speed reads at the cost of writes and storage, so we index the columns our real queries filter and join on rather than every column.


## Missed Goals 

## Next Sprint Plan
