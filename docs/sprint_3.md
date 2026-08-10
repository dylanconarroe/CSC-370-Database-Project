# CSC 370 – Database Systems — Progress Report, Sprint #3

**University of Victoria · Department of Computer Science**

**Names:**

1. Matthias Prael — V01016196
* Dylan Conarroe — V00897073
1. Layan Hazmi — V00049978



## Recap of Previous Sprint Goals

Sprint 2 completed the relational model normalization, a set of complex SQL queries, and an index speedup demonstration. The one goal we deferred was the optional basic security work, which we chose not to submit untested. Coming into Sprint 3 we set two goals, carrying that deferred work forward and moving into the ACID competencies:

* Complete the basic security work: add a view that hides the password column, define a restricted role with GRANT and REVOKE, and verify the permissions using both SHOW GRANTS and attempted unauthorized operations.
* Complete the ACID competencies:

  * **Atomicity**: a multi-statement operation run with START TRANSACTION, COMMIT, and ROLLBACK, showing one transaction that commits in full and one that fails and leaves no partial changes.
  * **Consistency**: enforce invariants with CHECK constraints, demonstrating valid values accepted and invalid values rejected.
  * **Isolation** (if time permitted): identify a concurrency anomaly and set an appropriate isolation level to prevent it.
  * **Durability** (if time permitted): create a recoverable starting point, commit a transaction, simulate data loss, and recover the committed changes using the log.

## Evidence of Completion

We completed both goals, including both of the optional ACID competencies.

* **Basic security (security.sql).** We built two views: a public hobby catalogue that renders a browse page from a single SELECT, and a safe user view that omits the password column so it can never be read through the view. We then created a restricted, read-only application account, granted it SELECT on only those two views, and never gave it access to the raw Users table. We verified the permissions two ways: SHOW GRANTS lists exactly the allowed privileges, and a deny test run from a second session logged in as the restricted account shows `SELECT \* FROM Users` failing with ERROR 1142 while the safe view still returns rows. Finally, a REVOKE takes back access to the user view to demonstrate privileges being removed. The denied ERROR 1142 is the evidence that the lockdown holds under independent testing.
* **Atomicity (transactions.sql).** We wrote one operation made of two related statements, enrolling a user in a hobby and adding the corresponding community-membership record, and ran it as a single unit. The successful scenario commits both inserts, and the counts go from zero to one for each. The failing scenario runs a valid first insert followed by a second insert that violates a foreign key (ERROR 1452); the ROLLBACK then undoes both, and the row count returns to zero, proving no partial changes remain. This required the tables to be on the InnoDB engine, which the script checks first.
* **Consistency (constraints.sql).** We added two CHECK constraints on EnrolledIn: progress must be between 0 and 100, and skill\_level must be one of Beginner, Intermediate, or Advanced. We then demonstrated that a valid row is accepted, an out-of-range progress is rejected (ERROR 3819), an invalid skill\_level is rejected, and an UPDATE that would push progress past 100 is also rejected, showing the invariant is protected on both inserts and updates.
* **Isolation (isolation.sql).** We demonstrated a dirty read across two concurrent sessions. Under READ UNCOMMITTED, the reader sees the writer's uncommitted change; when the writer rolls back, that value is shown never to have been real. We then chose READ COMMITTED as the appropriate level and repeated the experiment, showing the reader no longer sees the uncommitted value and the anomaly is prevented.
* **Durability (durability.sql).** We committed three rows, then simulated a server crash by hard-killing the MySQL process (kill -9) so it had no chance to shut down cleanly. After restarting the server, a SELECT showed all three committed rows still present. This demonstrates durability: on COMMIT, InnoDB writes each change to its redo log on disk (write-ahead logging) before acknowledging the commit, so on restart it replays that log and recovers every committed change even though the crash happened before the table's data pages were flushed.



## Missed Goals

No goals were missed this sprint. We completed the deferred security work and all four ACID competencies, including the two (Isolation and Durability) that were originally marked as optional for this sprint.



## Next Sprint Plan

For Sprint 4 we plan on completing all core competencies from Advanced Conceptual Design as follows:



1. **Use Inheritance Notations -** we will revise our original ERD to include at least one meaningful inheritance relationship and weak entity set for our database design. This includes identifying a subclass structure and inherited attributes. Success will be demonstrated by explaining why inheritance(s) and weak entity set(s) were used and the advantages/disadvantages of implementing them this way vs modeling them as ordinary entities. 
2. **Evaluate Quality -** we will evaluate our updated ERD using as many of the design principles discussed in class, which include: completeness, correctness, minimality, extensibility, normality, readability, and self-explanation. If time permits we will also evaluate each significant ERD transform of how it affects the information represented by the schema. Success will be demonstrated for each quality criteria we implement using a check list as follows:

   * Completeness - verify all requirements are represented
   * Correctness - ensure ERD concepts are used properly
   * Minimality - ensure no duplicated or unnecessary elements
   * Expressiveness \& Self-Explanation - requirements are represented naturally and clearly
   * Readability - layout, line crossings, hierarchy placement and organization improved
   * Extensibility - could future requirements be incorporated with localized changes
   * Normality - relational representation remains in appropriate normal forms

Significant ERD changes will be classified under one of the following transformations:

   * Information Preserved - no information is gained or lost
   * Information Augmenting - new schema represents additional information
   * Information Reducing - some information from original schema is lost
   * Incomparable - schema represents different information not classified as more or less



