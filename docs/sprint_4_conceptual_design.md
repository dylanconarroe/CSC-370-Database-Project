# Advanced Conceptual Design: Inheritance and Weak Entity

This document explains the two advanced ER constructs added to the schema this sprint, a specialization hierarchy under `Resource`, and a weak entity (`Review`) identified through the `EnrolledIn` relationship, and argues why each was modeled this way rather than as an ordinary entity.

## 1\. Inheritance: Resource → Video / Article / Tutorial

### Why inheritance?

The original schema modeled every learning resource as a single `Resource` entity with a `Resource\_Type` attribute (a free-form string like "Video", "Article", "Tutorial"). This flattened design has a structural problem: the attributes that are actually meaningful depend on which type a resource is, but the schema had no way to express that. A video's duration and platform make no sense for an article; an article's word count and author make no sense for a tutorial. Cramming all of these into one table would mean every resource carries several always-empty columns depending on its type, and nothing in the schema stops a "Video" row from having an `Author` value or missing a `Duration\_minutes`.

Specialization solves this by giving each type its own subclass with only the attributes that apply to it, while attributes common to every resource (`Title`, `URL`) stay on the shared superclass.

### Disjoint, total specialization

The specialization is disjoint (a resource is exactly one of Video, Article, or Tutorial, never more than one) and total (every resource must belong to one of the three subclasses; there is no "plain" resource with no type). This matches how `Resource\_Type` was actually used in the original design (it always held exactly one value) so the specialization doesn't change what the schema represents, only how it represents it.

### Advantages vs. an ordinary entity (the original design)

* Integrity: a video is guaranteed to have a duration because `Duration\_minutes` only exists on the `Video` table; there is no way to insert a video without it (given a NOT NULL constraint), and no way to accidentally give an article a `Duration\_minutes` value.
* Extensibility: adding a fourth resource type (e.g., `Podcast`) means adding one new subclass table, not adding more nullable columns to a single, ever-widening Resource table.
* Self-documentation: the schema itself communicates that resources come in distinct types with distinct shapes, rather than that information living only in application code that interprets the `Resource\_Type` string.
* 

### Disadvantages vs. an ordinary entity

* Query overhead: getting all resources of one type now requires a join between `Resource` and the relevant subclass table, instead of a single `SELECT ... WHERE Resource\_Type = 'Video'`. For a small dataset like this project's, the cost is negligible, but it is a real trade-off at scale.
* More tables to maintain: three subclass tables plus the superclass is four tables doing the job one table did before. Every insert of a new resource now requires two coordinated inserts (superclass row, then subclass row) instead of one.
* Relationships stay on the superclass, which can hide detail: `HasResource` (Hobby–Resource) still points at `Resource`, not at the subclasses. This is correct and intentional (a hobby's resource list shouldn't care about type), but it means a query that wants type-specific detail alongside the hobby link has to join through the superclass into whichever subclass applies.

On balance, since resource type is a meaningful, stable distinction with real type-specific attributes attached to it (not just a label), inheritance was the better fit here than a single flattened entity.

## 2\. Weak Entity: Review

### Why a weak entity

A review only makes sense in the context of a specific user's enrollment in a specific hobby — it has no identity independent of that enrollment. A review is not a property of a `User` alone (a user can review the same hobby differently at different points in their progress) and not a property of a `Hobby` alone (different users' reviews of the same hobby are distinct). Its identity is inherently tied to the pairing of the two, which is exactly what `EnrolledIn` already represents.

### Identified through EnrolledIn, not through User or Hobby directly

Because `EnrolledIn` is itself a relationship with a composite key (`user\_id`, `hobby\_id`) and its own attributes (`Progress`, `Skill\_Level`), `Review` is identified through `EnrolledIn` via the `Writes` identifying relationship. This is an example of relationship aggregation, where a relationship is treated as the identifying "owner" for a dependent weak entity. `Review`'s key is the full borrowed key from `EnrolledIn` (`user\_id`, `hobby\_id`) plus its own partial key, `Review\_Date`, which distinguishes multiple reviews left against the same enrollment over time.

### Advantages vs. an ordinary entity

* Correct dependency is enforced structurally: `Review` cannot exist without a corresponding `EnrolledIn` row, because its key is built from the identifying relationship. An ordinary entity with its own `Review\_ID` and separate foreign keys to `User` and `Hobby` would allow the same relationship to be expressed, but nothing would stop a review from being inserted for a user/hobby pair the user was never actually enrolled in.
* Cascading deletion is natural: if an enrollment is removed, its reviews should go with it (a review about a hobby you're no longer tracked as having enrolled in is meaningless). `ON DELETE CASCADE` on the identifying relationship expresses this directly.
* No arbitrary surrogate key needed: since the natural key (`user\_id`, `hobby\_id`, `Review\_Date`) is already meaningful and available, a weak entity avoids inventing a `Review\_ID` that carries no information.

### Disadvantages vs. an ordinary entity

* Composite keys are more cumbersome downstream: every foreign key reference to `Review` (if one were ever needed) would have to carry three columns instead of one surrogate ID, which is more verbose in queries and in application code.
* Assumes at most one review per enrollment per day: using `Review\_Date` as the partial key means two reviews on the same enrollment on the same date would collide on the primary key. An ordinary entity with its own surrogate `Review\_ID` would not have this limitation. In practice this is an acceptable constraint for this application (one review update per day is reasonable), but it is a real limitation introduced by the weak-entity design.

On balance, the weak entity design better reflects the actual dependency (a review cannot outlive its enrollment) and enforces that dependency through the schema itself rather than relying on application logic to maintain it.

## 3\. Classification of Change

Both additions are information augmenting: no existing entity, attribute, or relationship was removed, and no previously representable fact became unrepresentable. The specialization replaces `Resource\_Type` (a string) with equivalent-or-richer structural information (which subclass a row belongs to, plus type-specific attributes that did not exist before), and `Review` adds an entirely new fact the schema previously had no way to record. The rest of the ERD (`User`, `Hobby`, `Equipment`, `Community`, `Category`, and their original relationships) is unchanged.





# Quality Evaluation



**Completeness -** The previous iteration of our ERD represented resources, but not the type specific information that the new ERD represents such as video duration, author, or tutorial steps. The new ERD now also has a way to store reviews, which are implemented through Resource subsets and Review. 



**Correctness -** Video, Article, and Tutorial are modelled as subsets of the more general entity, Resource, as they share common attributes but also have type-specific attributes. Review is modeled as a weak entity set due to it depending on the EnrolledIn relationship.



**Minimality -** We removed resource\_type, as subtype membership now identifies the resource type. This avoids duplication. Other attributes only occur once, such as Title and URL.



**Expressiveness -** The inheritance structure shows that a Video is a Resource, while the weak entity structure shows Review belongs to EnrolledIn, which is a more natural way compared to using strings or independent IDs.



**Readability -** The three subsets of resource are shown directly below their more general class Resource and Review is next to EnrolledIn, with no crossing or bending of lines. 



**Self Explanation -** The new ERD is easily explained by looking at it, with video, article, and tutorial being subsets of Resource and showing that Review is dependent on EnrolledIn without needing written rules or notes. 



**Extensibility -** New resource types could be added, such as Podcast as another subset of Resource, which can be done without needing to change the current subsets and relationships. 



**Normality -** The relational mapping keeps the subtype specific attributes in their appropriate relations and continues the normalization work from the earlier sprint.



## 

## Transforms



1. Each replacement of resource\_type = 'Video' -> Video subset of Resource are **Information Preserving**, since the same type of fact is still represented, just in a new way. 



2\. Resource redesign to having the 3 new subsets is **Information Augmenting** due to new information being added such as duration, platform, word\_count, author, etc. 



3\. Adding the new Review entity set is **Information Augmenting** since new information such as ratings and comments were added in the new ERD. 

