# CSC 370 Database Systems: Progress Report, Sprint #5

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael (V01016196)
2. Dylan Conarroe (V00897073)
3. Layan Hazmi (V00049978)



## Recap of Previous Sprint Goals

Sprint 4 completed the Advanced Conceptual Design work: a disjoint total specialization of `Resource` into `Video`, `Article` and `Tutorial`, `Review` as a weak entity identified through `EnrolledIn`, the design quality checklist, and the transform classification. Coming out of it we set four goals for this sprint, one per lesson in the window up to and including Advanced SQL:

* **Third Normal Form and dependency preservation.** Compute a minimal basis using the full procedure, run 3NF synthesis, and compare against our existing BCNF decomposition. Success: `docs/3nf.md` with the minimal basis, the synthesized relations, a dependency-preservation verdict, one worked example of an FD whose left side is prime but not a full key, and the BCNF versus 3NF trade-off stated as a decision.
* **NULLs, using the Resource specialization as the worked case.** Create the three subtype tables, then demonstrate NULL behaviour rather than describe it. Success: the tables load; one query returning strictly more rows under `LEFT OUTER JOIN` than `INNER JOIN` with both counts recorded; at least one use of `COALESCE`; and a written note on three-valued logic and the `GROUP BY` asymmetry.
* **Constraints and triggers.** Add one attribute-level `CHECK`, one tuple-level `CHECK`, and one trigger, showing the failure modes rather than only the happy path. Success: a script producing, with the error code recorded for each, an `ADD CHECK` rejected by existing data, the same statement succeeding after cleaning, an insert rejected by each check, an attribute-level attempt at a two-column rule failing, and a before-and-after proving the trigger updated derived columns the insert never mentioned.
* **Simplifying SQL (if time permits).** Decompose Sprint 2 queries into relational algebra primitives and rewrite where the operator count allows. Success: `docs/simplifying_sql.md` with the operators required per query, at least one rewrite with the law named, the `NOT IN` test re-expressed as a set difference, one query argued already optimal, and every rewrite verified to return an identical result set.

## Evidence of Completion

All four goals are complete, including the one marked optional, each with a saved terminal transcript rather than a claim.

**1. Third Normal Form and dependency preservation** (`docs/3nf.md`)

We analysed the seven relations this sprint's changes touched, listing the FDs, candidate keys and prime attributes for each, and confirmed all seven are in BCNF and therefore in 3NF. We then computed a minimal basis and ran the synthesis algorithm in its strict form, one relation per FD, checking in each case whether a resulting relation already contains a candidate key of the original. It always did, so no extra key relation was needed.

The dependency-preservation verdict is that the production schema preserves every dependency trivially, because no relation in it is the product of a decomposition. It was designed normalized from the ERD rather than derived by splitting a wide relation, so every FD sits inside one relation and is checkable without a join.

Because there was no dependency loss to find in our own schema, we constructed one, as we did with `EnrolmentWide` in Sprint 2. For `R(A, B, C)` with `A,B -> C` and `C -> B`, the candidate keys are `{A,B}` and `{A,C}`, making all three attributes prime. `C -> B` therefore fails BCNF but passes 3NF, and the offending left side `{C}` is prime without being a full key, which is the diagnostic for dependency loss. Decomposing to BCNF gives `R1(C,B)` and `R2(A,C)`, which is lossless but strands `A,B -> C` across both relations where no single relation can check it. We stated the trade-off as a decision rather than a rule: for our schema the choice is free, since every relation is already in BCNF with every FD local.

The document also records something the normal forms cannot see. `Hobbies.review_count` and `Hobbies.avg_rating`, added by this sprint's trigger work, are determined by `hobby_id` and so pass both conditions, but they duplicate information held in `Review`. Normal forms only constrain dependencies inside one relation, so this redundancy is invisible to them. We named it as a deliberate trade of write cost for read cost, maintained procedurally by a trigger because MySQL has no assertions to declare it with.

**2. NULLs and the Resource specialization** (`sql/setup_01.sql`, `sql/inheritance.sql`, `sql/nulls_demo.sql`, `docs/nulls.md`)

The three subtype tables are built, keyed on `resource_id` with a foreign key to `Resources` and `ON DELETE CASCADE`, and every subtype attribute is declared `NOT NULL`. That constraint is the Sprint 4 integrity argument made real: a video cannot exist without a duration, and there is no column on `Video` in which an article's `word_count` could be stored. (The Sprint 4 plan called this file `sql/subclasses.sql`; it is committed as `sql/inheritance.sql`.)

`sql/inheritance.sql` does more than display the tables, it tests the two properties Sprint 4 asserted. The transcript in `inheritance_output.txt` shows 8 videos, 8 articles, 6 tutorials and 22 resources; a disjointness test that stacks all three memberships and looks for any `resource_id` appearing twice, returning zero rows; a totality test that left-joins all three subtypes and filters on `IS NULL`, returning zero rows; and a deliberate insert for a resource that does not exist, rejected with `ERROR 1452`. Together the two empty results prove the subtypes partition `Resources`, which is what makes dropping the old `resource_type` column lossless rather than merely convenient.

`sql/nulls_demo.sql` then demonstrates NULL behaviour. The same join returns **8 rows under `INNER JOIN` and 22 under `LEFT OUTER JOIN`**, and the 14-row gap is exactly what the inner join discards, silently, with no error or warning. `COALESCE` replaces those NULLs with a readable value without changing which rows return. The three-valued-logic demo is the sharpest piece: `WHERE v.platform <> 'YouTube'`, meant to read "videos not on YouTube," returns **0 rows**, because for a hobby with no video the comparison evaluates to `UNKNOWN` rather than `TRUE` and `WHERE` keeps only `TRUE`. Adding `OR v.platform IS NULL` returns **14 rows**. Finally `GROUP BY v.platform` puts all 14 NULLs into a single group, which is the asymmetry the lesson is about: `GROUP BY` treats NULLs as equal to each other while a join predicate never does.

`docs/nulls.md` also separates two mechanisms that are easy to conflate. Our demo shows dangling tuples, where no matching row exists on the right. A NULL sitting in the join attribute itself is a different failure, and our schema cannot produce it, because `resource_id` is part of the primary key in `Resources`, `HasResource` and all three subtype tables and can never be NULL. The design rules that anomaly out by construction.

**3. Constraints and triggers** (`sql/constraints_triggers.sql`, `constraints_triggers_output.txt`)

The transcript contains four errors, and all four are the deliverable rather than defects:

* `ERROR 3819` on `ALTER TABLE Equipment ADD CHECK (cost >= 0)`, because a row with cost -50 already violates it. After the row is cleaned the identical statement succeeds. A constraint cannot be attached to a table already in a state it forbids.
* `ERROR 3819` on a subsequent insert of a negative cost, showing the rule is now enforced by the database rather than by whichever application is writing.
* `ERROR 3813`, `Column check constraint references other column`, on an attempt to write `estimated_completion_minutes >= steps_count` at the attribute level. This is the concrete demonstration that a two-column rule cannot live on a single column definition, shown rather than asserted.
* `ERROR 3819` on an insert of a 20-step tutorial claiming to take 5 minutes, rejected by the tuple-level `CHECK` that the previous error justified.

The trigger evidence is the three-table sequence at the end: `review_count` and `avg_rating` read **2 and 4.50** after being backfilled from the eight seeded reviews, then **3 and 4.67** after one review rated 5, then **4 and 4.25** after one rated 3. The average rising and then falling is the proof that the value is genuinely recomputed rather than incremented, and neither `INSERT` statement mentions either column. We also documented why this rule has to be a trigger: it spans `Review` and `Hobbies`, and MySQL has no assertions.

The backfill step is worth calling out separately. A derived column has to be seeded from existing data at the moment it is added, or it starts out misreporting every row that predates the trigger. That is the same "sanitize before you constrain" problem as the first `CHECK`, applied to a derived value.

**4. Simplifying SQL** (`sql/simplifying_sql.sql`, `docs/simplifying_sql.md`)

This was the goal marked "if time permits," and we completed it. We counted the relational algebra operators each Sprint 2 query genuinely requires against what it actually uses, and rewrote three of them, removing four operators in total.

Query 5 used `NOT IN`, which is a set-theory operator rather than a relational one and which the lesson flags as a smell. The operation actually wanted is set difference, written as an anti-join since MySQL has no `EXCEPT`. That removed the nested selection and projection that built the subquery's result. The stronger argument turned out to be correctness: `NOT IN` returns no rows at all if its subquery yields a single NULL, because `x <> NULL` is `UNKNOWN` and `NOT IN` needs every comparison to be `TRUE`. Our query is safe only because `EnrolledIn.hobby_id` is part of a primary key, which is accidental rather than designed. This is the same three-valued logic from goal 2 appearing in a different disguise.

Query 13 computed each hobby's equipment cost with a correlated scalar subquery that re-ran once per hobby, twenty-two times. The rewrite pushes the `is_required` selection into the join condition, which is the distributive law, and covers every hobby in a single aggregation. Query 14 wrapped a `GROUP BY` in a derived table and then filtered the aggregate from outside, which is what `HAVING` exists for, so the derived table flattened away by associativity.

We also argued one query to be already optimal. Query 8 is one aggregation and one projection, which is exactly what it uses, and the rewritten Query 14 cannot be improved further because selection does not distribute over aggregation. MySQL enforces that directly, rejecting `WHERE COUNT(*) > 1` with `ERROR 1111 Invalid use of group function`. Recognising when a query is finished is as much a part of the lesson as rewriting the ones that are not.

Every rewrite is compared against its original in both directions using `NOT EXISTS` with the NULL-safe `<=>` operator. All three pairs return `in_original_only = 0` and `in_rewrite_only = 0`, which is what makes these simplifications rather than changes of meaning.

## Missed Goals

No goals were missed this sprint. All four were completed, including Simplifying SQL, which we had written as "if time permits" and had expected to defer.

Two integration problems did consume most of our slack, and they are worth naming precisely because the causes were technical rather than organisational. First, the subtype tables were originally declared inside `sql/inheritance.sql` while their data lived in `sql/seed_data.sql`, which runs earlier. A clean rebuild therefore failed: the seed had nowhere to insert, and every downstream file that touched `Tutorial` or `Review` died with `ERROR 1146`. The fix was to move all fifteen `CREATE TABLE` statements into `sql/setup_01.sql` so the schema file declares the schema and the seed file fills it, but diagnosing it meant tracing a failure that surfaced three files away from its cause. Second, the trigger demonstration collided with the seed data: the review it inserted used a `review_date` already present, so the primary key rejected it with `ERROR 1062` and the trigger never fired, producing a transcript in which a working trigger looked broken.

Both are the kind of ordering and state problem that only appears once several sprints of scripts have to run together as one pipeline, and neither was visible while each file was developed on its own.

The useful lesson for velocity is that our estimate treated four goals as four independent units, when in practice three of them depended on a working end-to-end rebuild that did not exist until late in the sprint. A more honest plan would have scheduled the integration itself as a goal rather than assuming it for free.

## Hypothetical Next Sprint Plan

This is the final submission, so what follows is what we would build with another two weeks. Each goal names a limitation that exists in HobbyQuest today, not in databases generally, and states how we would measure the improvement in this project's own terms.

**1. Performance evaluation on the real schema.** Our TA suggested this in the Sprint 4 feedback and we agree it is our weakest area. The index evidence from Sprint 2 came from a synthetic 50,000-row `ActivityLog` that no application query touches. Our actual tables are 22 hobbies and 22 resources, small enough that the optimiser will ignore any index we add. Worse, two things we built since have never been measured: the Sprint 4 specialization added a join to every type-specific resource read, which we argued was the price of the design, and this sprint's trigger runs two correlated aggregate subqueries on every review insert.
*Success:* a generator scaling the seed to 100,000 hobbies and 500,000 reviews, then three measurements. First, `EXPLAIN FORMAT=TRADITIONAL` on the `Hobbies -> HasResource -> Resources -> Video` chain at scale, recording rows examined before and after adding a covering index, with the goal of moving at least one step from `ALL` to `ref`. Second, timing 1,000 review inserts with the trigger enabled and with it dropped, reporting milliseconds per insert and the percentage overhead, then deciding from that number whether the denormalization actually pays for itself. Third, applying the External Memory model to the scaled `Review` table: compute the expected B+-tree height and I/Os per lookup by hand, then compare against the measured value and account for any gap. The last one connects the Accelerating SQL work from Sprint 2 to the B+-tree and external memory lessons we never applied to our own data.

**2. Closing the trigger's known gaps.** `docs/3nf.md` names two ways our derived columns can fall out of sync, and both are real today. The trigger fires only on `INSERT`, so editing or deleting a review leaves `avg_rating` stale, and MySQL triggers do not fire for rows removed by a foreign-key cascade, which `Review` is subject to through `EnrolledIn`. In HobbyQuest terms: a user who un-enrols from Rock Climbing has their reviews cascade away, and the hobby keeps advertising a review count that includes them.
*Success:* a test script with three assertions that all fail today and must all pass: update a review's rating and assert `avg_rating` changes; delete a review and assert `review_count` decrements; delete an `EnrolledIn` row that has reviews and assert `review_count` equals `COUNT(*)` over the remaining reviews. Implementation is `AFTER UPDATE` and `AFTER DELETE` triggers on `Review` plus recomputation driven from the `EnrolledIn` side, since the cascade cannot be caught on `Review` itself. A currently-failing test that must pass is the most objective criterion we can write.

**3. Isolation under genuine concurrency.** Sprint 3 demonstrated a dirty read by hand across two terminals, which proves we understand the anomaly but not that our schema survives real concurrent load. The specific risk HobbyQuest now has is created by this sprint's trigger: two users reviewing the same hobby at the same moment each cause a recomputation of `review_count` from their own snapshot, so under `REPEATABLE READ` one can overwrite the other and leave the count permanently one short. This is a lost update, and it is our own design that introduced it.
*Success:* a harness spawning 50 concurrent clients each inserting a review for the same hobby, then asserting `Hobbies.review_count` equals `COUNT(*)` over `Review`. Run at `READ COMMITTED`, `REPEATABLE READ` and `SERIALIZABLE`, recording the failure rate and the transactions per second at each level. Target: identify the lowest isolation level at which the invariant holds, with numbers for what that level costs in throughput, so the choice is made from evidence rather than from caution.

### Course-level competencies and where they go after this course

Our course-level thread all term has been **Data Architecture**, and the honest limitation now is this: we can design a schema that is provably correct, and we have never validated one against a workload. Every claim we have made about our design has been about its structure, never about its behaviour under load. Goals 1 and 3 above are the direct fix, and the reason they matter beyond marks is that in practice a schema is judged by the queries it has to serve, not by its normal form.

Three concrete extensions beyond this course:

* **An application layer** (SENG 265 and SENG 275). HobbyQuest has no client. Every query we have written, we wrote by hand. Building a REST API over it with an ORM would let us compare the SQL an ORM generates against the SQL we would write, using the operator-counting method from this sprint as the measure. Our prediction, worth testing, is that the ORM will produce the `IN`-heavy shape the Simplifying SQL lesson warns about.
* **Systems below the database** (CSC 360). We used InnoDB's redo log for the durability demo in Sprint 3 and treated it as a black box. Buffer management, write-ahead logging and MVCC are operating systems material, and understanding them would let us explain *why* our isolation results in goal 3 come out the way they do rather than only reporting them.
* **Algorithms and analysis** (CSC 226 and CSC 320). The External Memory model and B+-tree analysis in goal 1 are algorithm-analysis skills applied to storage. Doing the hand calculation and then checking it against a real measurement is the part that turns a formula into intuition.

**How we would evaluate our own growth outside this course's structure.** Three things we can check without an assignment telling us to:

1. **Keep the repository alive with migrations.** This course taught us to design a schema, never to change one that already has data in it. We would deploy HobbyQuest publicly and require every future schema change to ship as a versioned, reversible migration with a rollback tested against a copy of production data. The measure is simple and binary: can we roll a change forward and back without losing a row.
2. **Apply the analysis to a schema we did not write.** The real test of the FD and normalization work is doing it on someone else's system. Our target for the next co-op term is to take an unfamiliar production schema, produce its FD and key analysis, and identify at least one anomaly or missing constraint that the owning team agrees is real. That is the design exam skill, without the exam.
3. **Peer review each other's SQL.** We each wrote queries in isolation this term. Going forward, each of us reviews another's SQL against the operator-count method, with the standard being that a reviewer can name the relational algebra expression a query implements. If we cannot, the query is probably doing more than it needs to.
