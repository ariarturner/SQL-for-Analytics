# SQL for Analytics

## SQL Environment
- Catalog: set of schemas that constitute the description of a database  
- Schema: the structure that contains descriptions of objects created by a user (base tables, views, constraints)  
- [Data Definition Language (DDL)](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#Data-Definition-Language-DDL): commands that define a database, including creating, altering, and dropping tables and establishing constraints  
- [Data Manipulation Language (DML)](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#Data-Manipulation-Language-DML): commands that maintain and query a database  
- [Data Control Language (DCL)](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#Data-Control-Language-DCL): commands that control a database, including administering priviledges and committing data  

## SQL Query Logical Processing Order
1. `FROM` (Source data)  
  a. Full data set  
2. `ON` (Join attribute(s))  
  a. The join attribute(s) define(s) the relationship between the joining data sets; source data sets are ordered by the join attribute(s) and then compared  
  b. This clause can also be used as a filter for each individual source data set *before* they are joined  
3. `JOIN` (Source data)  
  a. A cartesian product of the source tables is evaluated based on the join attribute(s) and only matching rows are returned for the join type  
4. `WHERE` (Row filter)  
  a. Each row is evaluated, rows that fail are removed  
  b. In a join, each row of the *joined* data set is evaluated  
5. `GROUP BY` (Grouping)  
  a. Changes rows into row groups; now dealing with groups rather than rows; result is one row per group  
6. `HAVING` (Group filter)  
  a. Each row *group* is evaluated, groups that fail are removed  
7. `SELECT` (Return expressions)  
  a. Each expression is evaluated for each row group, but the "shape" of the data is not altered (other than `DISTINCT`)  
  b. The scope of each expression is limited to same row or row group  
8. `ORDER BY` (Presentation Order)  
  a. Sorts the data  
9. `OFFSET` / `FETCH` (Paging)  
  a. Limits records returned  

## Data Types
The names and datatypes will vary slightly based on query engine.  
- Boolean
  - `BOOLEAN`: captures boolean values `true` and `false`
- String
  - `VARCHAR(n)` / `VARCHAR2(n)`: stores a variable length character data with an optional maximum length, where n is the maximum number of characters for column length if specified (max length is 4000 characters)
  - `CHAR(n)`: stores a fixed length character string, where n is number of characters for column length (max length is 2000 characters)
- Numeric
  - `REAL`: stores a 32-bit inexact, variable-precision implementing the IEEE Standard 754 for Binary Floating-Point Arithmetic
  - `DOUBLE`: stores a 64-bit inexact, variable-precision implementing the IEEE Standard 754 for Binary Floating-Point Arithmetic
  - `DECIMAL(p,s)` / `NUMBER(p,s)`: an exact decimal number with precision up to 38 digits, where p is precision (total number of digits) and s is the scale (number of digits to the right of the decimal point)
  - `TINYINT`: stores an integer with a minimum value of `-2^7` and a maximum value of `2^7 - 1`
  - `SMALLINT`: stores an integer with a minimum value of `-2^15` and a maximum value of `2^15 - 1`
  - `INT`/`INTEGER`: stores an integer with a minimum value of `-2^31` and a maximum value of `2^31 - 1`
  - `BIGINT`: stores an integer with a minimum value of `-2^63` and a maximum value of `2^63 - 1`
  - `INTEGER(p)`: stores exact numbers with no decimals, p is number of digits
- Temporal
  - `DATE`: stores century, year, month, day, hour, minute, and second
  - `TIME(p)`: stores time of day (hour, minute, second) without a time zone with p digits of precision for the fraction of seconds, if p is not specified the default is 3 millisecond precision
  - `TIME(p) WITH TIME ZONE`: stores time of day (hour, minute, second) with a time zone with p digits of precision for the fraction of seconds, if p is not specified the default is 3 millisecond precision
  - `TIMESTAMP(p)` / `TIMESTAMP(p) WITHOUT TIME ZONE`: stores calendar date and time of day without a time zone with p digits of precision for the fraction of seconds, if p is not specified the default is 3 millisecond precision
  - `TIMESTAMP(p) WITH TIME ZONE`: stores calendar date and time of day with a time zone with p digits of precision for the fraction of seconds, if p is not specified the default is 3 millisecond precision
  - `TIMESTAMP(p) WITH LOCAL TIME ZONE`: stores calendar date and time of day with the local time zone with p digits of precision for the fraction of seconds, if p is not specified the default is 3 millisecond precision
  - `INTERVAL YEAR TO MONTH`: stores difference between dates and times
  - `INTERVAL DAY TO SECOND`: stores difference between dates and times

## Aliasing
SQL aliases are temporary names given to a table or a column in a table. They are used to make a query more readable.  

A column alias is created with the `AS` keyword.
<pre>
SELECT <i>Expression</i> AS <i>Alias</i>
FROM <i>Table</i>
[<i>Join Type</i> JOIN <i>Table2</i> 
ON <i>Table.Expressions</i> = <i>Table2.Expressions</i>]
[WHERE <i>Predicates</i>]
[GROUP BY <i>Expressions</i>]
[HAVING <i>Predicates</i>]
[ORDER BY <i>Expressions</i>]
</pre>

How a table alias is created depends on the query engine. Some query engines create a table alias using the `AS` keyword, but others just follow the table name with the alias.
<pre>
SELECT <i>Expressions</i>
FROM <i>Table</i> AS <i>Alias</i>
[<i>Join Type</i> JOIN <i>Table2</i> AS <i>Alias2</i>
ON <i>Alias.Expressions</i> = <i>Alias2.Expressions</i>]
[WHERE <i>Predicates</i>]
[GROUP BY <i>Expressions</i>]
[HAVING <i>Predicates</i>]
[ORDER BY <i>Expressions</i>]
</pre>

<pre>
SELECT <i>Expressions</i>
FROM <i>Table</i> <i>Alias</i>
[<i>Join Type</i> JOIN <i>Table2</i> <i>Alias2</i>
ON <i>Alias.Expressions</i> = <i>Alias2.Expressions</i>]
[WHERE <i>Predicates</i>]
[GROUP BY <i>Expressions</i>]
[HAVING <i>Predicates</i>]
[ORDER BY <i>Expressions</i>]
</pre>


## Aggregate Functions
Not all functions are supported by all databases
- Arithmetic
  - `COUNT`: returns the number of records of an expression
  - `SUM`: returns the sum of the values of an expression
  - `MIN`: returns the minimum value of an expression
  - `MAX`: returns the maximum value of an expression
  - `AVG`: returns the average value of an expression
- Boolean
  - `ALL` | `EVERY` : returns TRUE if ALL of the subquery values meet the condition; can be used in `SELECT`, `WHERE`, and `HAVING` clauses and window functions
  - `ANY` | `SOME`: returns TRUE if ANY of the subquery values meet the condition; can be used in `WHERE` clauses and window functions
- Array Aggregation
- Statistical
  - Variance
  - Deviation
  - Regression
  - Inverse Distribution
  - Hypothetical
- Proprietary
### Group Aggregate
A group aggregate function returns a single value from multiple rows that make up a group; visibility into all rows of group
### [Window Aggregate](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#window-functions)
- See groups as defined by window &emdash; do not see individual rows, but can see other window groups
- Most group aggregate functions work with windows

## Common Table Expressions
- A temporary named result set created from a `SELECT` statement that can be used in subsequent `SELECT` statements; acts like a named query, whose result is stored in a virtual table that is eliminated after query execution
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
- Window functions cannot be nested; if nested queries with window functions are required, use [CTEs]("https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#common-table-expressions") instead
- [Window Functions Examples](https://github.com/ariarturner/SQL-for-Analytics/tree/main/Animal%20Shelter)

**Basic Syntax**
<pre>
FUNCTION(<i>Expressions</i>)
[<a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#filter-clause">FILTER</a> (WHERE <i>Predicates</i>)]
<a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#over-clause">OVER</a> (
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#partition-by-clause">PARITION BY</a> <i>Expressions</i>]
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#order-by-clause">ORDER BY</a> <i>Expressions</i> [NULLS FIRST | LAST]]
  [<a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#framing"><i>Frame Type</i></a> BETWEEN <i>Frame Start</i> AND <i>Frame End</i>]
  [EXCLUDE <a href="https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#framing"><i>Frame Exclusion</i></a>]
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
  - Purpose: [framing](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#framing)
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
  [PARITION BY <i>Expressions</i>]
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
      [PARITION BY <i>Expressions</i>]
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
      [PARITION BY <i>Expressions</i>]
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
      [PARITION BY <i>Expressions</i>]
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

### [Window Aggregate Functions](https://github.com/ariarturner/SQL-for-Analytics/blob/main/README.md#aggregate-functions)
- See groups as defined by window &emdash; do not see individual rows, but can see other window groups
- Most group aggregate functions work with windows

### Rank Window Functions
- ranks define a relationship between a set of elements; in mathematics: weak order/ total preorder of elements  
- `RANK` & `DENSE_RANK` are true rank functions, but `ROW_NUMBER` and `NTILE` can also be  
<pre>
RANK FUNCTION()
OVER (
  [PARITION BY <i>Expressions</i>]
  ORDER BY <i>Expressions</i>
  );
</pre>  
- Rank Functions
  - `ROW_NUMBER` assigns each record in a partition a number out of a sequence of monotonically increasing integers, beginning with one and up to the number of partition rows
      - Common use case: top N per group, with only N records per group (in case of tie, rows chosen arbitrarily)
      <pre>
      ROW_NUMBER()
      OVER (
        [PARITION BY <i>Expressions</i>]
        ORDER BY <i>Expressions</i>
        );
      </pre>  
  - `NTILE` assigns each record an integer number out of a monotonically increasing sequence starting with one and ending at either n or the number of rows within the partition in case there are fewer of those; NTILE segments a partition into as equal as possible n or less segments, each called a tile
    - Not very common
    <pre>
    NTILE(<i>N</i>)
    OVER (
      [PARITION BY <i>Expressions</i>]
      ORDER BY <i>Expressions</i>
      );
    </pre>  
  - `RANK` assigns each record a number between 1 and the number of distinct values in a partition; when a partition has tied sorting value expression rows, they are all assigned the same rank (which is why it differs from row number); the next value receives its rank disregarding the ties, introducing gaps in the sequence
      - Common use case: top N per group, where we want all rows that tie
      <pre>
      RANK()
      OVER (
        [PARITION BY <i>Expressions</i>]
        ORDER BY <i>Expressions</i>
        );
      </pre> 
  - `DENSE_RANK` assigns each record a number between 1 and the number of distinct values in a partition; when a partition has tied sorting value expression rows, they are all assigned the same rank (which is why it differs from row number); the next value receives the next consecutive rank, so there are no gaps in the sequence
      - Common use case: top distinct N per group, where we want all rows that tie
      <pre>
      DENSE_RANK()
      OVER (
        [PARITION BY <i>Expressions</i>]
        ORDER BY <i>Expressions</i>
        );
      </pre> 
 
 ### Distribution Window Functions
 - Distribution window functions compute a relative rank over a row R, within a window partition of R, expressed as an approximate numeric ratio between 0 and 1.
  - `PERCENT_RANK`
       - A percent rank function describes the probability that our random variable X evaluated at n, will take a value that is less than n.
      - first row in each partition has a probability of 0
      - <code> PERCENT_RANK(R<sub>n</sub>) &rarr; (Rk(R<sub>n</sub>)-1) / (N<sub>R</sub>-1)</code>
    <pre>
    PERCENT_RANK()
    OVER (
      [PARITION BY <i>Expressions</i>]
      ORDER BY <i>Expressions</i>
      );
    </pre> 
  - `CUME_DIST`
   - A cumulative distribution function describes the probability that our random variable X evaluated at n, will take a value that is less than or equal to n.
      - no rows have a probability of 0
      - <code> CUME_DIST(R<sub>n</sub>) &rarr; N<sub>P(n)</sub> / N<sub>R</sub></code>
    <pre>
    CUME_DIST()
    OVER (
      [PARITION BY <i>Expressions</i>]
      ORDER BY <i>Expressions</i>
      );
    </pre> 

### Offset Window Functions  
- Look at rows "offset" from a specified origin
- Two optional parameters: offset value and a default value replacement if the offset is out of partition bounds or does the row does not exist 
  - if offset is not specified: 1 is assumed; if default is not specified: `NULL` is assumed 
  - Optional clause to determine how `NULLS` are processed 
    - IGNORE does not include `NULLS` in count towards offset 
    - RESPECT includes `NULLS` in count towards offset 
- Two major types of offset 
  - Offset from current row 
    - Partitioning is optional; frame is unncessary 
      - `LEAD` 
      - `LAG` 
    <pre>
    ROW OFFSET FUNCTION(<i>Expression</i>[, <i>Offset</i>, <i>Default</i>])
    [{IGNORE | RESPECT} NULLS]
    OVER (
      [PARITION BY <i>Expressions</i>]
      ORDER BY <i>Expressions</i>
      );
    </pre> 
  - Offset from frame boundaries 
    - Partitioning is optional; frame is mandatory (if frame is not specified, it is same default as defined above) 
      - `FIRST_VALUE`: always points to first value of partition 
      - `LAST_VALUE`: always points to last value of partition 
      - `NTH_VALUE`: always points to the nth value from specified start (either first or last) 
    <pre>
    FRAME OFFSET FUNCTION(<i>Expression</i>, <i>Offset<span style="color:red">*</span></i>)
    [FROM {FIRST | LAST}]<i><span style="color:red">*</span></i>
    [{IGNORE | RESPECT} NULLS]
    OVER (
      [PARITION BY <i>Expressions</i>]
      ORDER BY <i>Expressions</i>
      <i>Frame Specifications</i>
      );
    </pre> 
    <span style="color:red"><i>*</i> NTH_VALUE only</span> 

##  Data Definition Language (DDL)  
Define the database: create tables, indexes, views, etc.; establish foreign keys; drop or truncate tables  

### CREATE Statements  
- `CREATE SCHEMA`: defines a portion of the database owned by a particular user  
- `CREATE TABLE`: defines a new table and its columns  
- `CREATE VIEW`: defines a logical table from one or more tables or views  
- Others: `CREATE CHARACTER SET`, `CREATE COLLATION`, `CREATE TRANSLATION`, `CREATE ASSERTION`, `CREATE DOMAIN`  

#### CREATE TABLE  
<pre>
CREATE TABLE <i>Table Name</i> (
  {<i>Column Name</i>  <i>Data Type</i>  [<i>Column Constraint</i>]}.,..
  [CONSTRAINT <i>Table Constraint</i> PRIMARY KEY (<i>Column Name</i>)].,..
  [CONSTRAINT <i>Table Constraint</i> FOREIGN KEY (<i>Column Name</i>) REFERENCES <i>Reference Table</i>(<i>Reference Column</i>)].,..
  [ON COMMIT {DELETE | PRESERVE} ROWS]
);
</pre>  

##### Example  
<pre>
CREATE TABLE ExampleOffice (
    ID          BIGINT          NOT NULL,
    Name        VARCHAR2(20)    NOT NULL,
    Street      VARCHAR2(50),
    City        VARCHAR2(50),
    State       VARCHAR2(20),
    Country     VARCHAR2(50)    DEFAULT 'United States',
  CONSTRAINT ExampleOffice_PK PRIMARY KEY (ID)
);
CREATE TABLE ExampleEmp (
    ID          BIGINT          NOT NULL,
    Name        VARCHAR2(30)    NOT NULL,
    HireDate    DATE,
    Active      BOOLEAN,
    Salary      DOUBLE,
    LastShift   TIMESTAMP,
    Office      VARCHAR2(20)
  CONSTRAINT ExampleEmp_PK PRIMARY KEY (ID)
  CONSTRAINT ExampleEmp_FK FOREIGN KEY (Office) REFERENCES ExampleOffice(Name)
);
</pre>  

### ALTER Statements  
Make changes to an existing table  

<pre>  
ALTER TABLE <i>Table Name</i> <i>Alter Table Action</i> ;  
</pre>  

Alter Table Actions:  
- `ADD COLUMN <i>Column Name</i> <i>Data Type</i> [<i>Column Contraints</i>]`  
- `ALTER COLUMN <i>Column Name</i> [<i>Date Type</i>] [<i>Column Constraints</i>]`  
- `DROP COLUMN <i>Column Name</i>`  

### DROP Statements  
Remove a table from schema  

`DROP TABLE <i>Table Name</i>`  

## Data Manipulation Language (DML)  
Load the database: insert data; update the database  
Manipulate the database: select (querying)  

### Load the database  

#### INSERT Statement  
Adds one or more rows to a table  

- Insert complete record:
<pre>
  INSERT INTO <i>Table Name</i> VALUES (<i>Value</i>.,..);
</pre>
- Insert partial record (some null attributes):
<pre>
  INSERT INTO <i>Table Name</i> (<i>Column Name</i>.,..) VALUES (<i>Value</i>.,..);
</pre>
- Insert from query:
<pre>
  INSERT INTO <i>Table Name</i> SELECT <i>Expressions</i> FROM <i>Table</i>
  [<i>Join Type</i> JOIN <i>Table2</i> 
  ON <i>Table.Expressions</i> = <i>Table2.Expressions</i>]
  [WHERE <i>Predicates</i>]
  [GROUP BY <i>Expressions</i>]
  [HAVING <i>Predicates</i>]
  [ORDER BY <i>Expressions</i>];
</pre>

### Update the database  

#### DELETE Statement  
Remove rows from a table  

- Delete all rows: `DELETE FROM <i>Table Name</i>;`
- Delete rows based on condition: `DELETE FROM <i>Table Name</i> WHERE <i>Predicates</i>;`

#### UPDATE Statement
Modify data in existing rows

<pre>
  UPDATE <i>Table Name</i>
  SET <i>Column Name</i> = <i>Value</i>
  [WHERE <i>Predicates</i>];
</pre>

#### MERGE Statement
Combination of insert and update in one statement  

<pre>
  MERGE INTO <i>Table Name</i> AS <i>Destination Alias</i>
  USING (SELECT <i>Column(s)</i> FROM <i>Source Table</i> AS <i>Source Alias</i>
    ON (<i>Destination Alias</i>.<i>Column Name</i> = <i>Source Alias</i>.<i>Column Name</i>)
  WHEN MATCHED THEN UPDATE
    <i>Destination Alias</i>.<i>Column Name</i> = <i>Source Alias</i>.<i>Column Name</i>
  WHEN NOT MATCHED THEN INSERT
  (<i>Column(s)</i>) VALUES (<i>Source Alias</i>.<i>Column(s)</i>)
  ;
</pre>

## Data Control Language (DCL)
Control the database: grant, add, revoke  
