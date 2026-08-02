# BCNF Normalization Analysis: CSC370_hobbyQuest_platform

This document lists the functional dependencies (FDs) and a key for every relation in the schema, argues that each relation is already in Boyce-Codd Normal Form (BCNF), and then works through one deliberately denormalized example to show the decomposition process.

A relation is in **BCNF** when, for every non-trivial functional dependency `X → Y`, the left-hand side `X` is a superkey. In practice this means: the only thing allowed to determine other attributes is a key (or something containing a key).

## Notation

We write `A, B → C` to mean "A and B together functionally determine C". A **candidate key** is a minimal set of attributes that determines every attribute in the relation. A relation whose primary key is its *entire* set of attributes (a pure junction table) is trivially in BCNF, because it has no non-trivial FDs at all.

## FDs and keys, relation by relation

### Entity relations

**Users(user_id, username, email, password, date_joined)**
FD: `user_id → username, email, password, date_joined`
Key: `{user_id}`
The only determinant is `user_id`, which is the key. BCNF.

**Hobbies(hobby_id, name, description, difficulty)**
FD: `hobby_id → name, description, difficulty`
Key: `{hobby_id}`
Single determinant is the key. BCNF.

**Communities(community_id, hobby_id, name, platform, invite_link)**
FDs: `community_id → hobby_id, name, platform, invite_link` and, because `hobby_id` is declared `UNIQUE`, also `hobby_id → community_id, name, platform, invite_link`.
Keys: `{community_id}` and `{hobby_id}` (two candidate keys).
Every determinant is a candidate key, so BCNF holds even though there are two of them.

**Equipment(tool_id, name, cost)**
FD: `tool_id → name, cost`
Key: `{tool_id}`
`name` is not declared unique, so it does not determine `tool_id`. The only determinant is the key. BCNF.

**Resources(resource_id, title, resource_type, url)**
FD: `resource_id → title, resource_type, url`
Key: `{resource_id}`
BCNF.

**Category(category_id, name, category_type)**
FD: `category_id → name, category_type`
Key: `{category_id}`
BCNF.

### Relationship relations

**EnrolledIn(user_id, hobby_id, progress, skill_level)**
FD: `user_id, hobby_id → progress, skill_level`
Key: `{user_id, hobby_id}`
The determinant is the full composite key, so BCNF holds. Note that `progress` and `skill_level` depend on the *pair* (a user's progress is specific to one hobby), not on `user_id` or `hobby_id` alone, which is why they live here and not on `Users` or `Hobbies`.

**Requires_tools(tool_id, hobby_id, is_required)**
FD: `tool_id, hobby_id → is_required`
Key: `{tool_id, hobby_id}`
Whether a tool is required is a property of the tool-and-hobby pair, determined by the full key. BCNF.

**Joins(user_id, hobby_id)**
No non-trivial FDs. Key: `{user_id, hobby_id}` (the whole relation).
Pure junction table, trivially BCNF.

**HasResource(hobby_id, resource_id)**
No non-trivial FDs. Key: `{hobby_id, resource_id}`.
Pure junction table, trivially BCNF.

**ClassifiedAs(hobby_id, category_id)**
No non-trivial FDs. Key: `{hobby_id, category_id}`.
Pure junction table, trivially BCNF.

## Summary

All eleven relations are in BCNF. Every non-trivial FD in the schema has a key on its left-hand side, so there are no partial or transitive dependencies to remove. This is a consequence of the ER-driven design: each entity got its own relation keyed on its identifier, and each relationship got a relation keyed on the participating identifiers, with descriptive attributes attached to the exact key they depend on.

## Worked decomposition of a denormalized example

To show the process (and to justify why the schema separates `Users` from `EnrolledIn`), suppose a teammate had instead built a single wide table that folds a user's contact details into each enrolment row:

```
EnrolmentWide(user_id, hobby_id, progress, skill_level, username, email)
```

**Functional dependencies**

```
user_id, hobby_id  →  progress, skill_level      (a user's progress in a specific hobby)
user_id            →  username, email            (contact details belong to the user alone)
```

**Candidate key**

Taking the closure of the composite key: `{user_id, hobby_id}+` reaches `progress, skill_level` directly, and reaches `username, email` through `user_id`, so `{user_id, hobby_id}` determines every attribute and is the candidate key.

**Why this violates BCNF**

The FD `user_id → username, email` is non-trivial, but its left-hand side `{user_id}` is only *part* of the key, not a superkey. That fails the BCNF condition. Concretely, it causes an update anomaly: a user enrolled in five hobbies has their `username` and `email` copied across five rows, and changing their email means updating all five or risking inconsistency.

**Decomposition**

Split the relation on the violating dependency `user_id → username, email`. Put the determinant and the attributes it determines in one relation, and leave the rest with a copy of the determinant to preserve the join:

```
R1 = Users(user_id, username, email)
       key: {user_id}
       FD:  user_id → username, email

R2 = EnrolledIn(user_id, hobby_id, progress, skill_level)
       key: {user_id, hobby_id}
       FD:  user_id, hobby_id → progress, skill_level
```

**Check the result**

In `R1` the only determinant is `user_id`, which is its key. In `R2` the only determinant is the full composite key `{user_id, hobby_id}`. Both relations are now in BCNF. The decomposition is lossless because the shared attribute `user_id` is a key of `R1`, so joining `R1` and `R2` on `user_id` reconstructs `EnrolmentWide` exactly with no spurious rows. This is precisely the split the production schema already uses, which is why the shipped design never had the anomaly in the first place.
