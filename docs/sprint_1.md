# CSC 370 – Database Systems — Progress Report, Sprint #1

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael — V01016196
2. Dylan Conarroe — V00897073
3. Layan Hazmi — V00049978



## Recap of Previous Sprint Goals 

Our initial goals for this sprint were largely organizational rather than technical: form our project team, settle on a project concept, and confirm the scope was appropriate for a MySQL-backed information system. We didn't set formal technical success criteria going into this sprint, since group formation was still in progress at the kick-off stage.

## Evidence of Completion 

- Team formed and settled on our project concept: a hobby-discovery platform where users filter hobbies by attributes (category and difficulty), see required tools and learning resources per hobby, and track their own progress.
- Designed and pushed a complete ERD covering six entities: User, Hobby, Equipment, Resource, Community, and Category. They are connected through relationships including Joins, EnrolledIn, HasCommunity, Requires, HasResource, and ClassifiedAs.
- Wrote the initial database schema (`setup_01.sql`): CREATE TABLE statements for all six entity relations plus the relationship tables, with primary keys and foreign keys that map the ERD directly onto MySQL.
- Notable design choices captured in the schema: EnrolledIn is an associative relation carrying `progress` and `skill_level`; Requires_tools, HasResource, and ClassifiedAs implement many-to-many links; and Joins enforces that a user must be enrolled in a hobby before joining that hobby's community, via a foreign key to EnrolledIn.
- Populated the database with representative sample data (users, hobbies, categories, equipment, resources, and communities) so the design can be exercised end-to-end.
- Wrote and ran an initial query set (`query_plan.sql`) covering the app's core features: filtering hobbies by category and difficulty, listing a hobby's required equipment and its total startup cost, resources per hobby, a user's enrolments, and community membership, plus aggregate queries such as enrolment counts per hobby and average progress by skill level, and a subquery for hobbies a user has not started. Every query runs correctly against the schema.
- The ERD already extends past our original core scope by incorporating a Community entity, laying groundwork for the social / connecting-with-users feature we'd flagged as a later extension.

## Missed Goals 
Because we received the Sprint 1 outline late in the window, our technical work was compressed into the back half of the sprint. Even so, we completed the core implementation this sprint. The late start did shape how far we could push, though: we have not yet done a formal normalization (BCNF) analysis, database views, or indexing. Rather than rush those in at the end of a short window, we are giving them proper focus next sprint so we can do them justice. We are treating this as an expected ramp-up rather than a scope failure, and we are adjusting our next-sprint velocity expectations accordingly. Next sprint's goals are scoped to what's realistically achievable starting from a finished ERD rather than from scratch. 

## Next Sprint Plan

With the schema, sample data, and a working query set already in place, next sprint focuses on the remaining topics up to and including the normalization and query-optimization material. Each goal below has a measurable success criterion so progress can be checked objectively at the end of the sprint.

1. **Normalize to BCNF.** List the functional dependencies and a key for each relation, confirm each is in Boyce-Codd Normal Form, and show one worked decomposition of a deliberately denormalized example.
   *Success:* an FD-and-key list for every table plus a short BCNF argument.

2. **Add database views.** Create views for common needs, for example a public hobby catalogue and a per-user dashboard.
   *Success:* at least two working views, each demonstrated with a `SELECT` that returns the expected rows.

3. **Grow the dataset and extend the query set.** Scale the sample data (target: ≥20 hobbies) and add subquery examples.
   *Success:* the larger dataset loads with no foreign-key errors and all queries still return correct results.

4. **Indexes.** Add an index on a frequently filtered column and compare `EXPLAIN` output before and after.
   *Success:* `EXPLAIN` confirms the query uses the new index, with the access type improving from a full table scan (type `ALL`) to an index lookup (type `ref` or `range`).

5. **Access control (if time permits).** Sketch database-level permissions for the social side, such as a member who can read the catalogue and manage only their own enrolments versus a curator who can edit shared content, plus a view that hides the `password` column.
   *Success:* a short `GRANT`/`REVOKE` example plus one view that omits `password`.

Holistically, these tasks advance the Data Architecture course-level competency: we move from a working query-driven database to one we can prove is well-normalized and can optimize. The normalization work maps to the FDs & Keys and BCNF lessons, the views to the Views lesson, and the indexing to Accelerating SQL Queries. Access control maps to the User Authorisation lesson and is included as a stretch goal above.
