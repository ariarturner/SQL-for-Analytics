# SQL for Analytics

## SQL Query Logical Processing Order
1. `FROM` (Source data)  
  a. Full data set  
2. `WHERE` (Row filter)  
  a. Each row is evaluated, rows that fail are removed  
3. `GROUP BY` (Grouping)  
  a. Changes rows into row groups; now dealing with groups rather than rows  
4. `HAVING` (Group filter)  
  a. Each row *group* is evaluated, groups that fail are removed  
5. `SELECT` (Return expressions)  
  a. Each expression is evaluated for each row group, but the "shape" of the data is not altered (other than `DISTINCT`)  
  b. The scope of each expression is limited to same row or row group  
6. `ORDER BY` (Presentation Order)  
  a. Sorts the data  
7. `OFFSET` / `FETCH` (Paging)  
  a. Limits records returned  

## Common Table Expressions
- A temporary named result set created from a `SELECT `statement that can be used in subsequent `SELECT` statements; acts like a named query, whose result is stored in a virtual table that is eliminated after query execution
<pre>
WITH <i>CTE_Name</i> AS (
  SELECT <i>Expressions</i>
  FROM <i>Table</i>
  [<i>Join Type</i> JOIN <i>Table2</i> 
  ON <i>Table.Expressions</i> = <i>Table2.Expressions</i>]
  [WHERE <i>Predicates</i>]
  [GROUP BY <i>Expressions</i>]
  [HAVING <i>Predicates</i>]
  [ORDER BY <i>Expressions</i>]
)
</pre>

## Window Functions
- Purpose: eliminate subqueries that are created to access other rows in the same table; the subquery needs to be executed for every row, causing performance issues
- Can be used in `SELECT` clause and `ORDER BY` clause of a SQL query
  - because of query processing, has to be in clauses after dataset takes its final form (summarized data); otherwise there would be logic errors because of how expressions are evaluated &mdash; would be looking at data at "different points of time"
  - Note: the `WHERE` clause also filters the window

**Basic Syntax**
<pre>
FUNCTION(<i>Expressions</i>)
[<a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#filter-clause">FILTER</a> (WHERE <i>Predicates</i>)]
<a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#over-clause">OVER</a> (
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#partition-by-clause">PARITION BY</a> <i>Expressions</i>]
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#order-by-clause">ORDER BY</a> <i>Expressions</i> [NULLS FIRST | LAST]]
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#framing"><i>Frame Type</i></a> BETWEEN <i>Frame Start</i> AND <i>Frame End</i>]
  [EXCLUDE <a href="https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#framing"><i>Frame Exclusion</i></a>]
  );
</pre>

**Single Use in Query**
<pre>
SELECT [<i>Expressions</i>,]
FUNCTION(<i>Expressions</i>)
  [FILTER (WHERE <i>Predicates</i>)]
  OVER (
    [PARITION BY <i>Expressions</i>]
    [ORDER BY <i>Expressions</i> [NULLS FIRST | LAST]]
    [<i>Frame Type</i> BETWEEN <i>Frame Start</i> AND <i>Frame End</i>]
    [EXCLUDE <i>Frame Exclusion</i>]
  )
FROM <i>Table</i>
[WHERE <i>Predicates</i>]
[GROUP BY <i>Expressions</i>]
[HAVING <i>Predicates</i>]
[ORDER BY <i>Expressions</i>];
</pre>

**Multi Use in Query**
<pre>
SELECT [<i>Expressions</i>,]
FUNCTION(<i>Expressions</i>), FUNCTION(<i>Expressions</i>)[, FUNCTION(<i>Expressions</i>)]
FROM <i>Table</i>
[FILTER (WHERE <i>Predicates</i>)]
WINDOW W AS (
  [PARITION BY <i>Expressions</i>]
  [ORDER BY <i>Expressions</i> [NULLS FIRST | LAST]]
  [<i>Frame Type</i> BETWEEN <i>Frame Start</i> AND <i>Frame End</i>]
  [EXCLUDE <i>Frame Exclusion</i>]
  )
[WHERE <i>Predicates</i>]
[GROUP BY <i>Expressions</i>]
[HAVING <i>Predicates</i>]
[ORDER BY <i>Expressions</i>];
</pre>

### OVER Clause
- Defines window over the data

### FILTER Clause
- `FILTER` only affects the window, but a `WHERE` clause in the main query affects the window as well  &mdash; so there is no need to duplicate the `WHERE` clause in the `FILTER`
- Acts as a `WHERE` for the window only
<pre>
FUNCTION(<i>Expressions</i>)
FILTER (WHERE <i>Predicates</i>)
OVER ();
</pre>

### PARTITION BY Clause
- Acts as a WHERE for the window, but where the value is the same as current row
<pre>
FUNCTION(<i>Expressions</i>)
OVER (
  [PARITION BY <i>Expressions</i>]
  );
</pre>

### ORDER BY Clause
- Dual Purpose
  - Purpose: [framing](https://github.com/ariarturner/SQL-for-Analytics/tree/main/README.md#framing)
    - Note: if frame definition is not specified, default is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`; not recommended
  <pre>
  FUNCTION(<i>Expressions</i>)
  OVER (
    ORDER BY <i>Expressions</i> [<i>Frame Definition</i>]
    );
  </pre>

- Other purpose
  <pre>
  FUNCTION(<i>Expressions</i>)
  OVER (
    ORDER BY <i>Expressions</i>
    );
  </pre>

### Framing
- Allows window to shift for each row
- In order to frame, the data must be sorted otherwise "first", "previous", "next", and "last" hold no meaning
- Frame Definitions
  - `BETWEEN` is inclusive; some databases support an `EXCLUDE` clause &emdash; default is `EXCLUDE NO OTHERS` if not specified
  - Note: if frame definition is not specified, default is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`; not recommended
    - Frame Start (`UNBOUNDED PRECEDING` | <code><i>N</i> PRECEDING</code> | <code><i>N</i> FOLLOWING</code> | `CURRENT ROW`)
      - These operate differently depending on frame type
    - Frame End (`UNBOUNDED FOLLOWING` | <code><i>N</i> PRECEDING</code> | <code><i>N</i> FOLLOWING</code> | `CURRENT ROW`)
      - These operate differently depending on frame type
    - Frame Exclusions
      - `NO OTHERS`: nothing is excluded, default
      - `GROUP`: excludes both the current row and its peers
      - `TIES`: keeps current row, but excludes its peers
      - `CURRENT ROW`: excludes current row, but keeps its peers
    - Frame boundaries respect `NULLS`, but not all databases sort `NULLS` the same way or allow specifying how `NULLS` are sorted

<pre>
FUNCTION(<i>Expressions</i>)
OVER (
  PARITION BY <i>Expressions</i>
  ORDER BY <i>Expressions</i>
  [NULLS { FIRST | LAST}]
  <i>Frame Type</i>
  BETWEEN 
    <i>Frame Start</i>
  AND
    <i>Frame End</i>
  [EXCLUDE <i>Frame Exclusions</i>]
);
</pre>  
- Frame Types (`ROWS` | `RANGE` | `GROUPS`):
  - `ROWS`: frame boundaries are specified by row position count; values don't matter  
    <pre>
    FUNCTION(<i>Expressions</i>)
    OVER (
      PARITION BY <i>Expressions</i>
      ORDER BY <i>Expressions</i>
      ROWS
      BETWEEN 
        UNBOUNDED PRECEDING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      AND
        UNBOUNDED FOLLOWING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      [EXCLUDE 
        NO OTHERS | GROUP | TIES | CURRENT ROW]
      );
    </pre>  
    - Frame Definition
      - Frame Start
        - `UNBOUNDED PRECEDING`: starting at the very first row
        - <code><i>N</i> PRECEDING</code>: starting at the <i>N</i>-th row before current row (current row - N)
        - <code><i>N</i> FOLLOWING</code>: starting at the <i>N</i>-th row after current row (current row + N)
        - `CURRENT ROW`: starting at the current row
      - Frame End
        - `UNBOUNDED FOLLOWING`: ending at the very last row
        - <code><i>N</i> PRECEDING</code>: ending at the <i>N</i>-th row before current row (current row - N)
        - <code><i>N</i> FOLLOWING</code>: ending at the <i>N</i>-th row after current row (current row + N)
        - `CURRENT ROW`: ending at the current row
  - `RANGE`: frame boundaries are specified by value ranges that precede or follow current row's value, regardless of number of rows  
    - range is data type dependent  
    - can only use one sorting expression    
    <pre>
    FUNCTION(<i>Expressions</i>)
    OVER (
      PARITION BY <i>Expressions</i>
      ORDER BY <i>Expressions</i>
      RANGE
      BETWEEN 
        UNBOUNDED PRECEDING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      AND
        UNBOUNDED FOLLOWING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      [EXCLUDE 
        NO OTHERS | GROUP | TIES | CURRENT ROW]
      );
    </pre>  
    - Frame Definition
      - Frame Start
        - `UNBOUNDED PRECEDING`: starting at the very first row's value
        - <code><i>N</i> PRECEDING</code>: starting at the <i>N</i>-th units before current row's value (current row's value - N)
        - <code><i>N</i> FOLLOWING</code>: starting at the <i>N</i>-th units after current row's value (current row's value + N)
        - `CURRENT ROW`: starting at the current row's value
      - Frame End
        - `UNBOUNDED FOLLOWING`: ending at the very last row's value
        - <code><i>N</i> PRECEDING</code>: ending at the <i>N</i>-th units before current row's value (current row's value - N)
        - <code><i>N</i> FOLLOWING</code>: ending at the <i>N</i>-th row after current row's value (current row's value + N)
        - `CURRENT ROW`: ending at the current row's value
  - `GROUPS`: frame boundaries are specified by the peer group preceding or following the current row's row group  
    - a peer group is set of rows that share the same sorting values  
    <pre>
    FUNCTION(<i>Expressions</i>)
    OVER (
      PARITION BY <i>Expressions</i>
      ORDER BY <i>Expressions</i>
      GROUPS
      BETWEEN 
        UNBOUNDED PRECEDING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      AND
        UNBOUNDED FOLLOWING | <i>N</i> PRECEDING | <i>N</i> FOLLOWING | CURRENT ROW
      [EXCLUDE 
        NO OTHERS | GROUP | TIES | CURRENT ROW]
      );
    </pre>  
    - Frame Definition
      - Frame Start
        - `UNBOUNDED PRECEDING`: starting at the very first row's group
        - <code><i>N</i> PRECEDING</code>: starting at the <i>N</i>-th group before current row's group (current row's group - N)
        - <code><i>N</i> FOLLOWING</code>: starting at the <i>N</i>-th group after current row's group (current row's group + N)
        - `CURRENT ROW`: starting at the current row's group
      - Frame End
        - `UNBOUNDED FOLLOWING`: ending at the very last row's group
        - <code><i>N</i> PRECEDING</code>: ending at the <i>N</i>-th group before current row's group (current row's group - N)
        - <code><i>N</i> FOLLOWING</code>: ending at the <i>N</i>-th group after current row's group (current row's group + N)
        - `CURRENT ROW`: ending at the current row's group
