# CSC 370 Database Systems: Progress Report, Sprint #4

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael (V01016196)
2. Dylan Conarroe (V00897073)
3. Layan Hazmi (V00049978)



## Recap of Previous Sprint Goals

Sprint 3 finished the deferred security work and all four ACID competencies. Coming out of it we set two goals for this sprint, covering the core competencies of Advanced Conceptual Design:

* **Use inheritance notations.** Revise the ERD to include at least one meaningful inheritance relationship and at least one weak entity set. Success: explain why each was used, and give the advantages and disadvantages of modelling them this way instead of as ordinary entities.
* **Evaluate quality.** Evaluate the updated ERD against the design principles from class: completeness, correctness, minimality, expressiveness, self-explanation, readability, extensibility, and normality. If time permitted, also classify each significant ERD transform by how it changes the information the schema represents.

## Evidence of Completion

We completed both goals, including the transform classification that was marked optional.

**1. Inheritance: Resource specialized into Video, Article, and Tutorial**
Files: `CSC_370_ERD.png`, `sprint_4_conceptual_design.md`

The old design used a single `Resource` entity with a free-form `Resource_Type` string. The problem is that a resource's meaningful attributes depend on its type, and the schema had no way to say so. Nothing stopped an article from being given a duration.

The new ERD replaces that string with a **disjoint, total specialization**. `Title` and `URL` stay on the superclass. Each subclass carries only what applies to it:

* Video: `Duration_minutes`, `Platform`
* Article: `Word_count`, `Author`
* Tutorial: `Steps_count`, `Estimated_completion_minutes`

It is disjoint because a resource is exactly one type, and total because there is no untyped resource. That is how `Resource_Type` was already being used, so the change affects how the schema represents the fact, not what it represents.

The write-up argues both sides. We gain integrity, since a video cannot exist without a duration and an article can never be given one. We gain extensibility, since adding a Podcast type means one new subclass table rather than more nullable columns. We gain self-documentation. The cost is a join to reach type-specific detail, and two inserts per new resource instead of one. `HasResource` stays on the superclass on purpose, because a hobby's resource list should not care about type.

**2. Weak entity: Review identified through EnrolledIn**
Files: `CSC_370_ERD.png`, `sprint_4_conceptual_design.md`

A review has no identity of its own. It only means something in the context of one user's enrolment in one hobby. So it is drawn as a weak entity set (double rectangle), connected by the identifying relationship `Writes` (double diamond) to `EnrolledIn`, with `Review_Date` as the partial key (dashed underline). Its full key is the borrowed key plus the partial key: (`user_id`, `hobby_id`, `Review_Date`).

This is a case of a relationship acting as the identifying owner, since `EnrolledIn` already has a composite key and its own attributes `Progress` and `Skill_Level`.

Advantages: the dependency is enforced by the schema instead of by convention. An ordinary `Review` entity with its own `Review_ID` and separate foreign keys to `User` and `Hobby` would accept a review for a pair the user was never enrolled in. Cascading deletion also falls out naturally, and no meaningless surrogate key is needed.

Disadvantages, stated honestly: any future foreign key to `Review` would carry three columns instead of one, and using `Review_Date` as the partial key limits the design to one review per enrolment per day.

**3. The weak entity was implemented, not just drawn**
File: `weak_entity.sql`

This goes past the goal as written, which was ERD-level only. The script creates `Review` with:

* primary key (`user_id`, `hobby_id`, `review_date`)
* a **composite foreign key** on (`user_id`, `hobby_id`) referencing `EnrolledIn`, with `ON DELETE CASCADE`
* `CHECK (rating BETWEEN 1 AND 5)`

It then runs four demos. The first shows the key structure, with the borrowed key and the partial key side by side. The second shows two reviews on the same enrolment, separated only by `review_date`, which is exactly what the partial key is for. The third joins back to `EnrolledIn` so every review appears next to the enrolment that identifies it. The fourth inserts a review for user 1 on hobby 22. That user exists and that hobby exists, but the pair is not in `EnrolledIn`, so the composite foreign key rejects it. That last demo is the important one: it is the existence dependency being enforced by the database rather than asserted in a document.

**4. Quality evaluation**
File: `sprint_4_conceptual_design.md`

We worked the checklist rather than just stating a verdict.

* **Completeness.** The old ERD could not represent type-specific resource information or reviews at all. Both are now representable.
* **Correctness.** The subclasses share the superclass attributes and add their own, which is what a specialization is for. `Review` depends on the `EnrolledIn` relationship, which is what a weak entity is for.
* **Minimality.** `Resource_Type` was removed, because subtype membership now carries that information. The fact is stored once instead of twice. `Title` and `URL` each appear once, on the superclass.
* **Expressiveness.** "A Video is a Resource" and "a Review belongs to an EnrolledIn" are now said by the notation itself, not by a string value or a loose ID.
* **Readability.** The three subclasses sit directly below their superclass, and `Review` sits next to `EnrolledIn`. No crossing or bent lines.
* **Self-explanation.** The diagram can be read without extra rules or notes.
* **Extensibility.** A new resource type is one added subclass, with no change to the existing subclasses or relationships.
* **Normality.** The relational mapping keeps subtype-specific attributes in their own relations, which continues the BCNF work from Sprint 2 rather than undoing it.

**5. Transform classification (the optional half of goal two)**
File: `sprint_4_conceptual_design.md`

* Replacing `Resource_Type = 'Video'` with membership in the `Video` subclass is **information preserving**. The same fact, represented differently.
* Adding the three subclasses with their own attributes is **information augmenting**. Duration, platform, word count, and author did not exist anywhere before.
* Adding `Review` is **information augmenting**. Ratings and comments are facts the old schema had nowhere to put.

Nothing was removed, and nothing that used to be representable stopped being representable. So no change this sprint is information reducing or incomparable. The rest of the ERD (`User`, `Hobby`, `Equipment`, `Community`, `Category`, and their original relationships) is untouched.

## Missed Goals

No goals were missed. Both were completed, and in two places we went past what was set. The weak entity was implemented and tested in MySQL rather than only drawn, and the transform classification written as "if time permits" was delivered.

One piece of scope is worth naming so it does not look like a silent gap. The Resource specialization exists in the ERD and in the write-up, but only `Review` has been created in the running database. The `Video`, `Article`, and `Tutorial` tables have not been written yet.

That is not a miss against this sprint's goal, which was explicitly an ERD and justification goal. We spent the extra time on the weak entity instead, because it is the construct with the more interesting integrity behaviour to show. It is the first item scoped into Sprint 5, where it also serves as the worked example for the NULLs lesson.

## Next Sprint Plan

Sprint 5 covers the lessons since Advanced Conceptual Design, up to and including Advanced SQL: Third Normal Form, NULLs, Constraints and Triggers, and Simplifying SQL. There is one goal per lesson, so every module competency from this period is covered, and each goal says what will count as success.

The course-level competency we are still building is **Data Architecture**. This sprint the limitation is specific. Our design work has run ahead of our schema, and our claims about design quality are currently stronger than our evidence:

* Three of the four relations we designed in Sprint 4 do not exist in MySQL yet.
* Our normalization argument stops at BCNF. We have never checked whether our decompositions preserve their functional dependencies.
* The ten queries from Sprint 2 were written for correctness and have never been reviewed for simplicity.

Each goal below closes one of those gaps and produces something the teaching team can re-run rather than take on our word.

**1. Third Normal Form and dependency preservation.**
Compute a minimal basis for the functional dependencies over the relations this sprint's design changes touch, using the full procedure from the lesson: every FD reduced to a single attribute on the right, no FD removable without changing the closing set, no attribute removable from a left-hand side. Then run the 3NF synthesis algorithm and compare the result to our existing BCNF decomposition.

*Success:* `docs/3nf.md` containing the minimal basis, the relations produced by synthesis (including the added candidate-key relation if none of them already holds a superkey), a dependency-preservation verdict for each decomposition, and one worked example of the case where an FD's left side contains a prime attribute but is not itself a key. That case is the diagnostic for when a BCNF split loses a constraint. If our schema turns out to be dependency preserving already, we will show the loss on a constructed example, as we did with `EnrolmentWide` in Sprint 2, and state the BCNF versus 3NF trade-off as a design decision rather than a rule.

**2. NULLs, using the Resource specialization as the worked case.**
Write `sql/subclasses.sql` creating `Video`, `Article`, and `Tutorial`, keyed on `resource_id` with a foreign key to `Resource` and `ON DELETE CASCADE`. This lands the second half of the Sprint 4 ERD in the database. Then use it to demonstrate NULL behaviour rather than describe it.

*Success:* the three tables create and load; one report query that returns strictly more rows under `LEFT OUTER JOIN` than under `INNER JOIN`, with both counts recorded, showing that a NULL join attribute can never satisfy an equality test and that those rows are dropped silently without the outer join; at least one use of `COALESCE` to replace the NULLs the outer join introduces; and a short `docs/nulls.md` giving the three-valued-logic result for the comparison that causes the drop, noting that `GROUP BY` puts NULLs in their own group while a join predicate never matches them, and explaining why the Sprint 4 specialization removes NULLs from the schema instead of creating them.

**3. Constraints and triggers.**
Add one attribute-level `CHECK`, one tuple-level `CHECK`, and one trigger, and show the failure modes the lesson emphasises, not just the happy path. The attribute-level check constrains a single column, for example `Equipment.cost >= 0`. The tuple-level check spans two columns of the same row and therefore cannot be written at attribute level, for example a tutorial's estimated completion time cannot be less than its step count. The trigger maintains a derived review count and average rating on `Hobby` from `NEW.hobby_id` when a row is inserted into `Review`, so clients do not each have to write that transaction.

*Success:* `sql/constraints_triggers.sql` runs top to bottom and produces, with the error code recorded for each: an `ALTER TABLE ... ADD CHECK` rejected because existing rows violate it; the same statement succeeding once those rows are fixed; an insert rejected by the attribute-level check; an insert rejected by the tuple-level check; an attempt to write the two-column condition at attribute level failing, so the need for a tuple-level check is shown rather than claimed; and a before-and-after `SELECT` on `Hobby` proving the trigger updated the derived columns without the inserting statement mentioning them. We will also note why a cross-table rule like this has to be a trigger in MySQL, which does not support assertions.

**4. Simplifying SQL (if time permits).**
Take three queries from Sprint 2's `sql/query_plan.sql`. Break each into the relational algebra operators it actually requires, count them, and rewrite where the count says we can.

*Success:* `docs/simplifying_sql.md` listing, per query, the operators required and the count; at least one query rewritten to remove an operator, naming the law used (associativity to flatten a nested subquery, or distributivity to push a selection below a join); our Sprint 2 `NOT IN` test re-expressed as a set-difference pattern, since MySQL has no `EXCEPT`; and one query argued to be already optimal, on the grounds that selection does not distribute over aggregation, so a `HAVING` clause can never be pushed below its `GROUP BY`. Every rewritten query verified to return the same result set as the original, which is what makes it a simplification rather than a change of meaning.

**How this connects to the course.**
These goals continue the **Data Architecture** competency along the line the project has followed all term. We move from a schema we can query, index, secure, and keep consistent under concurrent writes, to one whose normalization, null handling, invariants, and query quality are all backed by evidence that can be re-run. The mapping to modules is one to one: goal 1 to Third Normal Form, goal 2 to NULLs (which also finishes the Advanced Conceptual Design work from Sprint 4), goal 3 to Constraints and Triggers, and goal 4 to Simplifying SQL. As in previous sprints we are following the course order rather than building ahead, and the optional goal is last so the three core lessons are fully evidenced even if our velocity comes in lower than planned.
