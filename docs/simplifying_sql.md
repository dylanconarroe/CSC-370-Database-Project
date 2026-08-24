# Simplifying SQL

The queries in `sql/query_plan.sql` were written in Sprint 2 for correctness and never reviewed for simplicity. This document counts the relational algebra operators each one requires and rewrites where the count allows. The runnable version is `sql/simplifying_sql.sql`.

Notation: π projection, σ selection, ⋈ join, ⟕ left outer join, γ aggregation.

| Query | Required | Used | Action |
|---|---|---|---|
| 5. Hobbies a user has not started | 2 ⋈, 1 anti-join, 1 π | 2 ⋈, 1 σ, 2 π, `NOT IN` | Rewritten as set difference |
| 13. Required equipment cost per hobby | 2 ⟕, 1 σ, 1 γ, 1 π | same, plus 22 re-evaluations | Rewritten as one join, one aggregation |
| 14. Categories with more than one hobby | 1 ⋈, 1 γ, 1 σ, 1 π | same, plus 1 extra π | Flattened into `HAVING` |
| 8. Average progress per skill level | 1 γ, 1 π | 1 γ, 1 π | Already optimal |

Four operators removed in total: a σ and a π from Query 5, a π from Query 14, and 21 redundant re-evaluations from Query 13.

## Query 5: NOT IN becomes a set difference

`NOT IN` is not a relational algebra operator, and the lesson flags set-theory operators as a smell. The operation actually wanted is set difference: all hobbies, minus the ones this user is enrolled in. MySQL has no `EXCEPT`, so the pattern is an anti-join:

```sql
LEFT JOIN EnrolledIn ei
       ON ei.hobby_id = h.hobby_id AND ei.user_id = 1
WHERE ei.hobby_id IS NULL
```

This drops the nested σ and π that built the subquery's result.

The stronger argument is correctness. **`NOT IN` returns no rows at all if its subquery yields one NULL**, because `x NOT IN (S)` needs every `x <> s` to be TRUE and `x <> NULL` is UNKNOWN. Our query is safe only because `EnrolledIn.hobby_id` is part of a primary key. That safety is accidental, not designed. The anti-join has no such trap. This is the same three-valued logic documented in `docs/nulls.md`, in a different disguise.

## Query 13: a correlated scalar subquery becomes a join

The original computes each hobby's equipment cost with a subquery in the `SELECT` list. It references `h.hobby_id`, so it re-runs once per hobby: 22 times.

The rewrite pushes the selection `rt.is_required = TRUE` into the join condition, which is the distributive law, and covers every hobby in a single aggregation:

```sql
LEFT JOIN Requires_tools rt
       ON rt.hobby_id = h.hobby_id AND rt.is_required = TRUE
LEFT JOIN Equipment e ON rt.tool_id = e.tool_id
GROUP BY h.hobby_id, h.name
```

The join must be `LEFT`. An inner join would drop hobbies with no required equipment, which the original returns with a cost of 0.

## Query 14: a derived table flattens into HAVING

The original groups inside a `FROM` subquery, then filters from outside with `WHERE hobby_count > 1`. That is a selection applied after an aggregation, which is what `HAVING` is for, so the derived table does no work and flattens by associativity. One projection removed.

**The rewrite cannot be simplified further.** Pushing `HAVING COUNT(*) > 1` below the `GROUP BY` is illegal: selection does not distribute over aggregation, because the predicate describes a value that does not exist until the aggregation runs. MySQL enforces this, rejecting `WHERE COUNT(*) > 1` with `ERROR 1111 Invalid use of group function`.

## Query 8: already optimal

```sql
SELECT skill_level, AVG(progress) FROM EnrolledIn GROUP BY skill_level;
```

One aggregation, one projection, which is exactly what it uses. No join to reorder, no selection to push, no subquery to flatten. Arguing from the operator laws that a query is finished is what stops an optimisation pass from changing things that did not need changing.

## Verification

Each rewrite is compared to its original in both directions using `NOT EXISTS` with the NULL-safe operator `<=>`. All three pairs return `in_original_only = 0` and `in_rewrite_only = 0`. Comparing as sets is what makes these simplifications rather than changes of meaning.

The harness itself uses `NOT EXISTS`, which the lesson calls a smell. That is deliberate: it is test scaffolding comparing two result sets, not a query whose shape we are optimising.

## Note on query_plan.sql

Query 3 still selects `r.resource_type`, dropped from `Resources` when the specialization was built. It fails with `ERROR 1054` until that column is removed from its select list.