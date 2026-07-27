# CSC 370 – Database Systems — Progress Report, Sprint #1

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael — V01016196
2. Dylan Conarroe — V00897073
3. Layan Hazmi — V00049978



## Recap of Previous Sprint Goals 

Our initial goals for this sprint were largely organizational rather than technical: form our project team, settle on a project concept, and confirm the scope was appropriate for a MySQL-backed information system. We didn't set formal technical success criteria going into this sprint, since group formation was still in progress at the kick-off stage.

## Evidence of Completion 

- Team formed and settled on our project concept: a hobby-discovery platform where users filter hobbies by category and difficulty, see the equipment and learning resources per hobby, track their own progress, and join communities built around hobbies.
- Designed and pushed a complete ERD covering six entities: User, Hobby, Equipment, Resource, Community, and Category. They are connected through relationships including Joins, EnrolledIn, HasCommunity, Requires, HasResource, and ClassifiedAs.
- Wrote the initial database schema (`setup_01.sql`): CREATE TABLE statements for all six entity relations plus the relationship tables, with primary keys and foreign keys that map the ERD directly onto MySQL.
- Captured the relational-model essentials in the schema: every table has a primary key; `EnrolledIn` is an associative relation carrying `progress` and `skill_level`; `Requires_tools`, `HasResource`, and `ClassifiedAs` implement many-to-many links; and `Joins` enforces referential integrity, requiring a user to be enrolled in a hobby before joining that hobby's community, via a foreign key to `EnrolledIn`.
- Populated the database with representative sample data (users, hobbies, categories, equipment, resources, and communities) so the schema holds realistic data.
- The ERD already extends past our original core scope by incorporating a Community entity, laying groundwork for the social / connecting-with-users feature we'd flagged as a later extension.

## Missed Goals 
Because we received the Sprint 1 outline late in the window, our technical work was compressed into the back half of the sprint. Even so, we completed the core implementation this sprint. We scoped ourselves up to the relational model, and completed that: the schema and sample data, the ERD, and the keys and referential-integrity constraints the design relies on. Two things remain for next sprint, in line with the course order: the formal normalization (BCNF) analysis, and complex SQL querying, which is the section that follows the relational model. We are treating this as an expected ramp-up rather than a scope failure, and we are adjusting our next-sprint velocity expectations accordingly. Next sprint's goals are scoped to what's realistically achievable starting from a finished ERD rather than from scratch. 

## Next Sprint Plan

With the schema, sample data, and a working query set already in place, next sprint focuses on the remaining topics up to and including the normalization and query-optimization material. Each goal below has a measurable success criterion so progress can be checked objectively at the end of the sprint.

1. **Complete the relational model (Normalize to BCNF).** List the functional dependencies and a key for each relation, confirm each is in Boyce-Codd Normal Form, and show one worked decomposition of a deliberately denormalized example.
   *Success:* an FD-and-key list for every table plus a short BCNF argument.

2. **Complex SQL queries (grouping, aggregation, and sub-queries).** Scale the sample data (target: ≥20 hobbies) and write queries covering filtering, multi-table joins, `GROUP BY` aggregates, and at least one subquery.
   *Success:* at least eight queries that run correctly on the loaded database.

3.**Indexes.** Add an index on a frequently filtered column and compare `EXPLAIN` output before and after.
   *Success:* `EXPLAIN` confirms the query uses the new index, with the access type improving from a full table scan (type `ALL`) to an index lookup (type `ref` or `range`).

4. **Basic security (if time permits).** Add a view for a common need (for example a public hobby catalogue) and sketch role permissions with `GRANT`/`REVOKE`, including a view that hides the `password` column.
   *Success:* at least one working view plus a short `GRANT`/`REVOKE` example.

Holistically, these tasks follow the course order: Relational Data Model, then Complex SQL Queries, then Basic Security, and advance the Data Architecture course-level competency. The BCNF work maps to the Relational Data Model lessons, the queries to Grouping & Aggregation and Sub-queries, the indexing to Using Indexes, and the views and permissions to the Basic Security lessons.
