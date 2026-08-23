# NULLs: Worked Case Using the Resource Specialization

This document works through NULL behaviour using the `Video`/`Article`/
`Tutorial` specialization from Sprint 4 as the concrete example, per
`sql/nulls_demo.sql`.

## The setup

Every hobby has exactly one resource attached (`HasResource`), and every
resource is exactly one of `Video`, `Article`, or `Tutorial` (the disjoint,
total specialization from Sprint 4). Joining `Hobbies` through `Resources`
into `Video` specifically means: for hobbies whose resource is an `Article`
or a `Tutorial`, there is no row in `Video` with a matching `resource_id` at
all.

## INNER JOIN vs LEFT OUTER JOIN

`sql/nulls_demo.sql` runs the same join twice:

- **INNER JOIN** keeps only rows where `Resources.resource_id =
  Video.resource_id` evaluates to `TRUE`. A hobby whose resource is an
  Article or Tutorial has no corresponding `Video` row, so the join
  predicate has nothing to compare against for that hobby -- it is not that
  the predicate is `FALSE`, there is simply no right-hand row to evaluate it
  against -- and the hobby is dropped from the result entirely.
- **LEFT OUTER JOIN** keeps every row from `Hobbies` regardless of whether a
  matching `Video` row exists, filling `v.platform` and `v.duration_minutes`
  with `NULL` when it doesn't.

Both queries record a row count (`inner_join_row_count`,
`left_join_row_count`). The `LEFT OUTER JOIN` count equals the total number
of hobbies with a resource attached; the `INNER JOIN` count is strictly
smaller, equal to only the hobbies whose resource happens to be a video.
The gap between the two counts is exactly the set of rows a plain
`INNER JOIN` would have silently dropped -- a NULL join attribute can never
satisfy an equality test, and rows on the wrong side of that are removed
without any error or warning.

## Three-valued logic

SQL comparisons involving `NULL` don't evaluate to `TRUE` or `FALSE` -- they
evaluate to `UNKNOWN`. A `WHERE` clause only keeps rows where the condition
is `TRUE`; `UNKNOWN` is treated the same as `FALSE` for that purpose (it does
not raise an error, and it does not count as a match either way).

This matters in a case like `WHERE v.platform <> 'YouTube'`, intended to mean
"hobbies whose video isn't on YouTube." For a hobby with no video at all,
`v.platform` is `NULL`, so `v.platform <> 'YouTube'` evaluates to `UNKNOWN`,
not `TRUE` -- and the row is silently excluded, even though "no video" is
arguably also "not on YouTube." Demo 4 in `sql/nulls_demo.sql` shows this
directly, then shows the fix: explicitly adding `OR v.platform IS NULL` to
also catch the rows the plain inequality drops. This is the general lesson:
`<>`, `=`, and most comparisons against `NULL` never behave as "not equal"
or "equal" in the way someone might expect -- they behave as "unknown,"
which a plain `WHERE` treats as a silent exclusion.

## COALESCE

`COALESCE(v.platform, 'No video available')` replaces a `NULL` result with a
fallback value, which is useful specifically because the `LEFT OUTER JOIN`
above introduces NULLs for hobbies without a video. This turns a raw `NULL`
in a report into a readable value without changing which rows are returned
-- it only affects how a value already-included row displays.

## GROUP BY vs. join predicates: NULL is treated inconsistently

`GROUP BY v.platform` puts every row with `v.platform IS NULL` into a single
group together, as if all those NULLs were "equal" for grouping purposes.
This is a genuinely different rule than the one governing joins: the join
predicate `r.resource_id = v.resource_id` can never match two `NULL` values
to each other, because `NULL = NULL` evaluates to `UNKNOWN`, not `TRUE`. So
the same value (`NULL`) is treated as "the same as other NULLs" by
`GROUP BY`, but "never equal to another NULL" by a join or `WHERE` equality
test. Both rules are standard SQL behaviour, but they don't agree with each
other, which is exactly the kind of inconsistency this lesson is about.

## Why the Sprint 4 specialization avoids creating NULLs, rather than causing them

A naive alternative design would have put every type-specific attribute
directly on a single `Resources` table -- `duration_minutes`, `platform`,
`word_count`, `author`, `steps_count`, `estimated_completion_minutes` all as
columns on one row. Under that design, every resource row would have NULLs
in whichever columns didn't apply to its type: a video's `word_count` and
`steps_count` would be NULL, an article's `duration_minutes` and
`steps_count` would be NULL, and so on. Every row would carry NULLs for
roughly two-thirds of its type-specific columns.

The specialization from Sprint 4 avoids this. `Video`, `Article`, and
`Tutorial` are separate tables, and a resource only has a row in the one
table matching its actual type. There is no `Video` row with a NULL
`word_count`, because `word_count` isn't a column on `Video` at all -- the
attribute simply doesn't exist for a row where it wouldn't apply, rather
than existing and being unset. The NULLs that do show up in this sprint's
demo (`sql/nulls_demo.sql`) come entirely from the *join* -- from asking
"give me every hobby, whether or not it has a video" -- not from the
underlying table design itself. That distinction is the point of doing this
lesson with the Sprint 4 tables specifically: the specialization is a case
study in avoiding NULLs by design, while the outer join is a case study in
where NULLs legitimately have to appear because the question being asked
("every hobby" including ones without a video) requires it.
