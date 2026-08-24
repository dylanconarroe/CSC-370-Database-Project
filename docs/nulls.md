# NULLs: Worked Case Using the Resource Specialization

This document works through NULL behaviour using the `Video` / `Article` /
`Tutorial` specialization from Sprint 4 as the concrete example, per
`sql/nulls_demo.sql`.

## The setup

In the current seed each hobby has exactly one resource attached through
`HasResource`, and every resource is exactly one of `Video`, `Article`, or
`Tutorial` (the disjoint, total specialization from Sprint 4, verified by the
tests in `sql/inheritance.sql`). Note that the one-resource-per-hobby part is
a property of the seed, not of the schema: `HasResource` has primary key
`(hobby_id, resource_id)`, so the relationship is many-to-many and a hobby
could carry several resources.

Joining `Hobbies` through `Resources` into `Video` specifically means that for
hobbies whose resource is an `Article` or a `Tutorial`, there is no row in
`Video` with a matching `resource_id` at all.

## INNER JOIN vs LEFT OUTER JOIN

`sql/nulls_demo.sql` runs the same join twice:

- **INNER JOIN** keeps only rows where `Resources.resource_id =
  Video.resource_id` evaluates to `TRUE`. A hobby whose resource is an Article
  or Tutorial has no corresponding `Video` row, so there is no right-hand row
  to satisfy the predicate, and the hobby is dropped from the result entirely.
  Result: **8 rows**, one per video.
- **LEFT OUTER JOIN** keeps every row from `Hobbies` regardless of whether a
  matching `Video` row exists, filling `v.platform` and `v.duration_minutes`
  with `NULL` when it does not. Result: **22 rows**, one per hobby.

The gap of 14 rows is exactly what a plain `INNER JOIN` discards, silently,
with no error or warning. Those 14 rows are called **dangling tuples**, and
retaining them is the reason outer joins exist.

### Two different things that both lose rows

It is worth separating two mechanisms the lesson covers, because they are
easy to conflate:

1. **A dangling tuple**, which is what our demo shows. There is simply no
   matching row on the right-hand side, so nothing satisfies the join
   predicate.
2. **A NULL in the join attribute itself.** A row whose join column is `NULL`
   can never satisfy an equality predicate, because `NULL = anything`
   evaluates to `UNKNOWN` rather than `TRUE`. Such a row is excluded even from
   a relation that does have matching rows.

Our schema cannot produce the second case. `resource_id` is part of the
primary key in `Resources`, `HasResource`, and all three subtype tables, so it
can never be NULL on either side of the join. The design rules the anomaly out
by construction, which is worth stating rather than leaving implicit.

## Three-valued logic

SQL comparisons involving `NULL` evaluate to `UNKNOWN`, not `TRUE` or `FALSE`.
A `WHERE` clause keeps only rows where the condition is `TRUE`, so `UNKNOWN`
behaves like `FALSE` for filtering purposes without raising an error.

| Expression | Result |
|---|---|
| `'Vimeo' <> 'YouTube'` | TRUE |
| `NULL <> 'YouTube'` | UNKNOWN |
| `NULL = NULL` | UNKNOWN |
| `TRUE OR NULL` | TRUE |
| `FALSE AND NULL` | FALSE |

The last two matter: not every expression containing a NULL becomes UNKNOWN.
If one operand already decides the result, the NULL never gets consulted.

Demo 4 shows the practical consequence. The filter `WHERE v.platform <>
'YouTube'` is meant to read "hobbies whose video is not on YouTube." For a
hobby with no video, `v.platform` is `NULL`, so the comparison returns
`UNKNOWN` and the row is dropped. The query returns **0 rows**. Adding
`OR v.platform IS NULL` returns **14 rows**, the hobbies with no video at all,
which arguably are also "not on YouTube."

That gap between 0 and 14 is the anomaly. The query looked correct, ran without
complaint, and threw away every row it was ambiguous about.

## COALESCE

`COALESCE(v.platform, 'No video available')` replaces a NULL with a fallback
value. This is useful precisely because the `LEFT OUTER JOIN` above introduces
NULLs for hobbies without a video. It changes how an already-included row
displays, not which rows are returned.

## GROUP BY vs join predicates: NULL is treated inconsistently

`GROUP BY v.platform` puts every row with `v.platform IS NULL` into one group
together, as if all those NULLs were equal for grouping purposes. Demo 5
returns two groups: `NULL` with 14 and `YouTube` with 8.

This is a different rule from the one governing joins. The join predicate
`r.resource_id = v.resource_id` can never match two NULL values to each other,
because `NULL = NULL` is `UNKNOWN`, not `TRUE`. So the same value is treated as
"the same as other NULLs" by `GROUP BY` and "never equal to another NULL" by a
join or a `WHERE` equality test. Both are standard SQL, and they do not agree
with each other.

## Why the Sprint 4 specialization avoids creating NULLs

A naive alternative would put every type-specific attribute directly on a
single `Resources` table: `duration_minutes`, `platform`, `word_count`,
`author`, `steps_count`, and `estimated_completion_minutes` all as columns on
one row. Every resource would then carry NULLs in whichever columns did not
apply to its type. A video's `word_count` and `steps_count` would be NULL, an
article's `duration_minutes` would be NULL, and so on: roughly two-thirds of
the type-specific columns NULL on every row.

The specialization avoids this. `Video`, `Article`, and `Tutorial` are separate
tables and a resource has a row in only the one matching its type. There is no
`Video` row with a NULL `word_count`, because `word_count` is not a column on
`Video` at all. The attribute does not exist where it would not apply, rather
than existing and being unset. Every subtype attribute is declared `NOT NULL`
in `sql/setup_01.sql`, which enforces that.

So the NULLs in this sprint's demo come entirely from the **join**, from asking
"give me every hobby, whether or not it has a video," and not from the table
design. That is the point of working this lesson with the Sprint 4 tables: the
specialization is a case study in avoiding NULLs by design, and the outer join
is a case study in where NULLs legitimately have to appear because the question
being asked requires them.
