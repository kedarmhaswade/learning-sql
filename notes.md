# Notes from Alan Beaulieu's Book 

## Chapter 8 Grouping and Aggregates

Data is generally stored at the lowest level of granularity needed by any of a database's users.
Sometimes for instance, one needs to take a look at each record of a table. But that does not
mean you _have to_ look at it at that granularity. The ```group by``` construct and the _aggregate functions_ allow you to examine data at a different granularity.

### Grouping Concepts

If you look at a table like ``employee``, then you will see that it has a number of columns like ``emp_id``, ``dept_id``, ``title`` etc. Thus, each employee has some value for these fields. Sometimes, it may so happen that you want to _form the groups_ of employees based on these criteria like ``title``. Doing this may help us answer questions like how many _different titles_ of employees are there? It is almost like asking each employee her/his title and putting her/him in a bucket labeled with that title. 

This will enable us to first of all, find the buckets with distinct labels. Each bucket is a group that is unique **with respect to the criterion chosen** (this means they may differ with respect to otherwise). In a small table with 18 employees each one of which have a department we see the following:
```` sql
mysql> select emp_id, lname, dept_id from employee;
+--------+-----------+---------+
| emp_id | lname     | dept_id |
+--------+-----------+---------+
|      1 | Smith     |       3 |
|      2 | Barker    |       3 |
|      3 | Tyler     |       3 |
|      4 | Hawthorne |       1 |
|      5 | Gooding   |       2 |
|      6 | Fleming   |       1 |
|      7 | Tucker    |       1 |
|      8 | Parker    |       1 |
|      9 | Grossman  |       1 |
|     10 | Roberts   |       1 |
|     11 | Ziegler   |       1 |
|     12 | Jameson   |       1 |
|     13 | Blake     |       1 |
|     14 | Mason     |       1 |
|     15 | Portman   |       1 |
|     16 | Markham   |       1 |
|     17 | Fowler    |       1 |
|     18 | Tulman    |       1 |
+--------+-----------+---------+
18 rows in set (0.00 sec
````

If we make the dept_id as a bucket or group, then each of these employees has to fall in one of the three buckets, where the dept_id is either 1, 2, or 3. There is quite some insight that we may get about these groups, if we were actually able to create these buckets. This is exactly what the ``group by`` construct is designed for. See for example, the output of the following query:
```` sql
mysql> select dept_id from employee group by dept_id;
+---------+
| dept_id |
+---------+
|       1 |
|       2 |
|       3 |
+---------+
3 rows in set (0.00 sec)
````
This output is to be expected as we have three buckets as far as dept_id's are concerned and **each employee is in _exactly_ one of these buckets**.

Note that each member of the group is still a full-fledged record from the table. Thus, each member of a group has all the characteristics (e.g. title, emp_id, lname, fname etc.) that are of interest.

### Aggregate Functions

Once the groups are made, what is of interest? Perhaps doing some operations on the group as a whole! The most straightforward of those is the size of each group. For now, it does not matter how we count the members of each group -- we just see how many _things_ are in a bucket. The way to do that in SQL is the famous _count(*)_. Thus, to count the number of members in each bucket (i.e. the size of each group), we do:

```` sql
mysql> select dept_id, count(*) from employee group by dept_id;
+---------+----------+
| dept_id | count(*) |
+---------+----------+
|       1 |       14 |
|       2 |        1 |
|       3 |        3 |
+---------+----------+
3 rows in set (0.00 sec)
````
or, more descriptively:

```sql
mysql> select dept_id, count(dept_id) 'size of group with this dept_id' from employee group by dept_id;
+---------+---------------------------------+
| dept_id | size of group with this dept_id |
+---------+---------------------------------+
|       1 |                              14 |
|       2 |                               1 |
|       3 |                               3 |
+---------+---------------------------------+
3 rows in set (0.00 sec)
```
The criterion for grouping used in the above example is the dept_id of each employee record. This criterion can be expressed as: Group the employees by their departments.

This is what aggregate functions are for: doing _some operation_ on all the records in a group. Thus, if a particular characteristic of every record in the group is numeric, we could _sum_ the records on that characteristic, find the _max_ or _min_ of all the records for that characteristic and so on.

And the database server does that operation for all the groups formed by the column/criterion specified by the ``group by`` clause. In the above example, the ``count`` aggregate function is used to count the number of records in each group of employees in the same department.

The number of aggregate functions provided by a database varies, but the following functions are provided by a majority of the databases:

2. Avg(): Finds the average value of a particular column (numeric) of all the records in a group.
1. Count(): Counts the number of records in a group, based on a column (asterisk means any column).
3. Max(): Returns the maximum (numeric) value of a column for all the records in a group.
3. Min(): Returns the minimum (numeric) value of a column for all the records in a group.
5. Sum(): Returns the sum of a (numeric) value of a column for all the records in a group.

With the ``count()`` function, there is an additional option called ``DISTINCT``. Remember that each record is a full-fledged record with all the characteristics of the given table (or relation). This means, when we are counting the members of a group, we can specify whether counting is affected by whether or not the value of a particular column for each member in the group is distinct.

Thus, ``count(role)`` will count __all__ the records in a group that have some role, whereas ``count(DISTINCT role)`` will count only those records in a group that have unique value for role. So, for example, in a group formed based on departments (i.e. ``group by dept_id``), if we have 10 members, 8 of which are ``TELLERs`` and 2 are ``HEAD TELLERs``, then ``count(role)`` would return 10, whereas ``count(DISTINCT role)`` would return 2 since there are only two distinct roles in the entire group.

#### Handling of NULLs

We now explore how counting is affected by NULL values. Simply speaking, ``count(*)`` counts the number of records in a group, whereas ``count(column_name)`` counts the elements that have some non NULL value for ``column_name``. The NULL values are also ignored by other aggregate functions.

#### The HAVING Clause

When the groups are formed, __certain__ filtering conditions are to be specified using the ``having`` clause, rather than the ``where`` clause:

```sql
mysql> select count(*) c from account group by product_cd having c >= 10;
+----+
| c  |
+----+
| 10 |
+----+
1 row in set (0.00 sec)

```

#### Implicit and Explicit Groups

An _implicit_ group is formed in the _absence of the ``group by`` clause_. The aggregate functions can be applied to the group thus formed. But it is not always possible to create groups without the explicit ``group by`` clause. If you see an error like ``invalid use of aggregate function`` or ``mixing of group columns with no group columns is illegal if there no GROUP BY clause`` then you are running into this problem of database being unable to create explicit groups to run the aggregate functions on. Sometimes, without the essential ``group by``, the database may actually return incorrect values without throwing any error!

### Generating Groups

We have already seen that choosing a column name in the ``group by`` clause groups all the records by the value of that column for each record. Nothing prevents us from grouping records by their values of more than one column. For instance, it is possible to group students in a school by their grade and favorite sport. In our example, we may want to group the accounts by their type _and_ the branch where they were opened: 
```sql
mysql> select product_cd, open_branch_id, count(*) from account group by product_cd, open_branch_id;
+------------+----------------+----------+
| product_cd | open_branch_id | count(*) |
+------------+----------------+----------+
| BUS        |              2 |        1 |
| BUS        |              4 |        1 |
| CD         |              1 |        2 |
| CD         |              2 |        2 |
| CHK        |              1 |        3 |
| CHK        |              2 |        2 |
| CHK        |              3 |        1 |
| CHK        |              4 |        4 |
| MM         |              1 |        2 |
| MM         |              3 |        1 |
| SAV        |              1 |        1 |
| SAV        |              2 |        2 |
| SAV        |              4 |        1 |
| SBL        |              3 |        1 |
+------------+----------------+----------+
14 rows in set (0.00 sec)

```
Thus, the above example shows the __multicolumn grouping__. The idea is like 
this: We look at the available number of products (say ``m``) and available
number of branches where an account could be opened (say ``n``). From the
[rule of product](http://en.wikipedia.org/wiki/Rule_of_product), we know the 
number of groups thus formed is ``m ⨉ n``. So, we form these groups, go through
our records one by one and place each one of them in one of the groups. Thus,
for an account if the product type is BUS (business) and the branch is Woburn
(open_branch_id = 2), then we place it in that group.

In our present example, there are __6__ different types of products (``select count(*) 
from account group by product_cd;``) and __4__ different branches (``select count(*) 
from branch``), which means we have __6 ⨉ 4__ groups formed that way. Over these
24 groups, we can apply:

1. Several aggregate functions, and
2. A few options

We have seen aggregate functions like avg, max, min, sum, count etc. but the 
options are something new. There are two options that are of interest:

#### With rollup

The dictionary meaning of rollup is accumulation. A few actual runs of this option
will clarify what this option does.

The dictionary meaning of rollup is __accumulation__. A few actual runs of this option
will clarify what this option does.

##### With rollup: Run 1

Consider the following output:

```sql
mysql> select count(*), product_cd, open_branch_id, sum(avail_balance) from account group by product
_cd, open_branch_id with rollup;
+----------+------------+----------------+--------------------+
| count(*) | product_cd | open_branch_id | sum(avail_balance) |
+----------+------------+----------------+--------------------+
|        1 | BUS        |              2 |            9345.55 |
|        1 | BUS        |              4 |               0.00 |
|        2 | BUS        |           NULL |            9345.55 |
|        2 | CD         |              1 |           11500.00 |
|        2 | CD         |              2 |            8000.00 |
|        4 | CD         |           NULL |           19500.00 |
|        3 | CHK        |              1 |             782.16 |
|        2 | CHK        |              2 |            3315.77 |
|        1 | CHK        |              3 |            1057.75 |
|        4 | CHK        |              4 |           67852.33 |
|       10 | CHK        |           NULL |           73008.01 |
|        2 | MM         |              1 |           14832.64 |
|        1 | MM         |              3 |            2212.50 |
|        3 | MM         |           NULL |           17045.14 |
|        1 | SAV        |              1 |             767.77 |
|        2 | SAV        |              2 |             700.00 |
|        1 | SAV        |              4 |             387.99 |
|        4 | SAV        |           NULL |            1855.76 |
|        1 | SBL        |              3 |           50000.00 |
|        1 | SBL        |           NULL |           50000.00 |
|       24 | NULL       |           NULL |          170754.46 |
+----------+------------+----------------+--------------------+
21 rows in set (0.01 sec)
```

Results would be have clearer if the NULL in the above output were replaced with ANY.

Here is an output from another (perhaps more complicated) run:




##### With rollup: Run 2
```sql
mysql> select count(*), product_cd, open_branch_id, year(open_date), sum(avail_balance) from accou
 group by product_cd, open_branch_id, year(open_date) with rollup;
+----------+------------+----------------+-----------------+--------------------+
| count(*) | product_cd | open_branch_id | year(open_date) | sum(avail_balance) |
+----------+------------+----------------+-----------------+--------------------+
|        1 | BUS        |              2 |            2004 |            9345.55 |
|        1 | BUS        |              2 |            NULL |            9345.55 |
|        1 | BUS        |              4 |            2002 |               0.00 |
|        1 | BUS        |              4 |            NULL |               0.00 |
|        2 | BUS        |           NULL |            NULL |            9345.55 |
|        2 | CD         |              1 |            2004 |           11500.00 |
|        2 | CD         |              1 |            NULL |           11500.00 |
|        2 | CD         |              2 |            2004 |            8000.00 |
|        2 | CD         |              2 |            NULL |            8000.00 |
|        4 | CD         |           NULL |            NULL |           19500.00 |
|        1 | CHK        |              1 |            2002 |             122.37 |
|        2 | CHK        |              1 |            2003 |             659.79 |
|        3 | CHK        |              1 |            NULL |             782.16 |
|        1 | CHK        |              2 |            2000 |            1057.75 |
|        1 | CHK        |              2 |            2001 |            2258.02 |
|        2 | CHK        |              2 |            NULL |            3315.77 |
|        1 | CHK        |              3 |            2002 |            1057.75 |
|        1 | CHK        |              3 |            NULL |            1057.75 |
|        1 | CHK        |              4 |            2001 |            3487.19 |
|        1 | CHK        |              4 |            2002 |           23575.12 |
|        1 | CHK        |              4 |            2003 |           38552.05 |
|        1 | CHK        |              4 |            2004 |            2237.97 |
|        4 | CHK        |              4 |            NULL |           67852.33 |
|       10 | CHK        |           NULL |            NULL |           73008.01 |
|        2 | MM         |              1 |            2004 |           14832.64 |
|        2 | MM         |              1 |            NULL |           14832.64 |
|        1 | MM         |              3 |            2002 |            2212.50 |
|        1 | MM         |              3 |            NULL |            2212.50 |
|        3 | MM         |           NULL |            NULL |           17045.14 |
|        1 | SAV        |              1 |            2000 |             767.77 |
|        1 | SAV        |              1 |            NULL |             767.77 |
|        1 | SAV        |              2 |            2000 |             500.00 |
|        1 | SAV        |              2 |            2001 |             200.00 |
|        2 | SAV        |              2 |            NULL |             700.00 |
|        1 | SAV        |              4 |            2001 |             387.99 |
|        1 | SAV        |              4 |            NULL |             387.99 |
|        4 | SAV        |           NULL |            NULL |            1855.76 |
|        1 | SBL        |              3 |            2004 |           50000.00 |
|        1 | SBL        |              3 |            NULL |           50000.00 |
|        1 | SBL        |           NULL |            NULL |           50000.00 |
|       24 | NULL       |           NULL |            NULL |          170754.46 |
+----------+------------+----------------+-----------------+--------------------+
41 rows in set (0.00 sec)
```
The second run brings out the ideas behind 'rollup' more clearly. As we said
before, rollup is accumulation. The rollup output is clearest when the select
clause (sort of) matches the group by clause. For instance, in the last output,
we are listing product_cd, open_branch_id and year(open_date) and grouping
the records by the same order with rollup. The rollup option then starts with
the same basic idea of grouping. It looks at all the groups formed by the
``group by`` constraint and then starts accumulating from the end of that list
and outputs a row for every accumulation it increasingly performs.

To further illustrate, let us zoom in on the first 'group' in the previous output:

```sql
+------------+----------------+------+--------------------+
| product_cd | open_branch_id | year | sum(avail_balance) |
+------------+----------------+------+--------------------+
| BUS        |              2 | 2004 |            9345.55 |1)
| BUS        |              2 | NULL |            9345.55 |2)
| BUS        |              4 | 2002 |               0.00 |3)
| BUS        |              4 | NULL |               0.00 |4)
| BUS        |           NULL | NULL |            9345.55 |5)
+---------------------------------------------------------+
```
This is the __group__ of business accounts. Based on our records, these accounts are
created in either branch 2 or branch 4 and in those branches they were created 
in either 2002 or 2004. We choose to display the sum of available balances in
all those accounts with rollup on product_cd, open_branch_id, and year, in that
order.

Thus, it looks at the first group. It contains two members:

1. BUS, 2, 2004 (a business a/c set up at branch 2 in 2004)
2. BUS, 4, 2002 (a business a/c set up at branch 4 in 2002)

The rollup (accumulation) of sum of the available balance occurs in that order. First,
it accumulates over all the years, given the other two are the same (product_cd and
open_branch_id). For that line (line 2) it chooses to show NULL for the year column
(I'd have much preferred ANY here making it easier to understand). If we had another
year, say 2006, when a BUS account was opened at branch 2, then the output would have
looked like:

```sql
+------------+----------------+------+--------------------+
| product_cd | open_branch_id | year | sum(avail_balance) |
+------------+----------------+------+--------------------+
| BUS        |              2 | 2004 |            9345.55 |1)
| BUS        |              2 | 2006 |            1234.67 |2)
| BUS        |              2 | NULL |           10580.22 |3)
| BUS        |              4 | 2002 |               0.00 |4)
| BUS        |              4 | NULL |               0.00 |5)
| BUS        |           NULL | NULL |           10580.22 |6)
+---------------------------------------------------------+
```

Then the rollup happens for all the open_branch_id's and then
finally for everything. The last line is always the mega rollup.

##### With cube

### Exercises

#### Exercise 8-1

Construct a query to that counts the number of rows in the ``account`` table.

#### Solution 8-1
```sql
mysql> select count(*) from account;
+----------+
| count(*) |
+----------+
|       24 |
+----------+
1 row in set (0.00 sec)
```

#### Exercise 8-2

Modify the query in 8-1 to count the number of accounts held by each customer. Show the cu ID and number of accounts for each cu.

#### Solution 8-2

```sql
mysql> select cust_id, count(*) c from account group by cust_id;
+---------+---+
| cust_id | c |
+---------+---+
|       1 | 3 |
|       2 | 2 |
|       3 | 2 |
|       4 | 3 |
|       5 | 1 |
|       6 | 2 |
|       7 | 1 |
|       8 | 2 |
|       9 | 3 |
|      10 | 2 |
|      11 | 1 |
|      12 | 1 |
|      13 | 1 |
+---------+---+
13 rows in set (0.00 sec)
```

#### Exercise 8-3

Modify the query in 8-2 to include only those customers who have at least two accounts.

#### Solution 8-3

```sql
mysql> select cust_id, count(*) c from account group by cust_id having c >=2 ;
+---------+---+
| cust_id | c |
+---------+---+
|       1 | 3 |
|       2 | 2 |
|       3 | 2 |
|       4 | 3 |
|       6 | 2 |
|       8 | 2 |
|       9 | 3 |
|      10 | 2 |
+---------+---+
8 rows in set (0.01 sec)
```

#### Exercise 8-4

Find the total available balance by product and branch where there is more than one account per product and branch. Order the result by total balance (highest to lowest).

#### Solution 8-4
```sql
mysql> select sum(avail_balance) s, product_cd p, open_branch_id b from account group by product_cd,
 open_branch_id having count(cust_id) > 1 order by s desc;
+----------+-----+------+
| s        | p   | b    |
+----------+-----+------+
| 67852.33 | CHK |    4 |
| 14832.64 | MM  |    1 |
| 11500.00 | CD  |    1 |
|  8000.00 | CD  |    2 |
|  3315.77 | CHK |    2 |
|   782.16 | CHK |    1 |
|   700.00 | SAV |    2 |
+----------+-----+------+
7 rows in set (0.00 sec)

```

## Chapter 9 Subqueries

### What is a Subquery?

A subquery is a query contained _within_ another query (containing statement). 
It leverages the fact that a query returns a set (a table) of results which 
can be used as an intermediate result by another (bigger) query.

A subquery is enclosed in a pair of parentheses. 

Like a query, a subquery returns a result set that may consist of:

* A single row with a single column (just one 'value' or 'scalar')
* Multiple rows with single column (just a single 'vector')
* Multiple rows with multiple columns (a matrix)

The _type_ of the result set of the subquery determines:

1. How it may be used
2. What operators the _containing statement_ may use to interact with it

Since a subquery can be executed as a query, you may wonder about the why
to use subqueries. The main reason to use them is efficiency; instead of
executing two independent queries, you execute _one_ query, thereby saving time.
Subqueries are useful in other situations as well.

#### <a name="elemex"></a>An Elementary Subquery

Given the ``employee`` table, what is the start_date, id, last name and first
name of the earliest employee (assuming there is only one such employee)?

Since SQL is a declarative language, we can attempt to simply write a query
that answers the above query thus:

    select start_date, id, lname, fname from employee where 
           start_date = min(start_date)

This sounds good but what is ``min(start_date)``?

If you enter the query as is, here's what MySQL will return:

    ERROR 1111 (HY000): Invalid use of group function

and that is understandable, because ``min`` is an aggregate function, supposed
to be used over an implicit or explicit group! In our example, the employee table
itself is the implicit group whose start_date column is required to have a minimum!
We an make use of that fact in a query by itself:

    select min(start_date) from employee;

which returns:
```text
+-----------------+
| min(start_date) |
+-----------------+
| 2000-02-09      |
+-----------------+
1 row in set (0.00 sec)
```

And then, we can make use of this fact as a subquery by combining the two:
```sql
select start_date, emp_id, lname, fname from employee where 
       start_date = (select min(start_date) from employee);
+------------+--------+-------+--------+
| start_date | emp_id | lname | fname  |
+------------+--------+-------+--------+
| 2000-02-09 |      3 | Tyler | Robert |
+------------+--------+-------+--------+
1 row in set (0.00 sec)
```
and getting the result as expected.

## Subquery Types (Based on Relationship with Containing Statement)

Based on the type of the sets a subquery returns, we have already seen how
it is classified (scalar, vector, matrix). Based on the columns subqueries
use, they can also be classified as:

1. Non-correlated 
2. Correlated

Most of the usual select queries are non-correlated, whereas correlated queries
are used in ``update`` and ``delete`` scenarios.

### Non-correlated Subqueries Returning Scalars

(one row and one column)

When the subquery returns a single row and single column, you can use usual
_scalar comparison operators_ like:

* =
* <>
* <
* >
* <=
* >=

If you use a subquery in an equality condition, but the subquery returns more
than one row, you will receive an error. For the scalar comparison operators to
be applicable, returned result set (of the subquery) should be scalar. Otherwise
you will receive an error:

```sql
Error 1242 (21000): Subquery returns more than one row
```

We already saw [an example of this above](#elemex) where we used the ``=`` 
operator.

### Non-correlated Subqueries Returning Vectors

(multiple rows and one column)

To compare the subquery results in this case, we have the following additional
operators in SQL:

1. IN
2. NOT IN
3. ALL
4. ANY

#### The IN and NOT IN Operators

These two are straightforward: When you are expecting a large set of unknown
values, you can and should use these two operators. These operators determine
the _set membership_. An additional wrinkle however, is with the NULLs and we'll
come back to that issue.

Consider this requirement: __Find all the employees that supervise other employees__.

In our employee table (`emp_id, fname, lname, start_date, end_date,
superior_emp_id, dept_id, title, assigned_branch_id`), some employees supervise
other employees, whereas other do not. We are asked to find those employees
that do. 

Employee that _is_ an employee's supervisor is denoted as superior_emp_id of
that employee's record. So, we can find (the set of) all the superior_emp_id's and then
check if the emp_id of every record is _IN_ that set:

```sql
mysql> select emp_id, fname, lname from employee where emp_id IN 
       (select distinct superior_emp_id from employee);
+--------+---------+-----------+
| emp_id | fname   | lname     |
+--------+---------+-----------+
|      1 | Michael | Smith     |
|      3 | Robert  | Tyler     |
|      4 | Susan   | Hawthorne |
|      6 | Helen   | Fleming   |
|     10 | Paula   | Roberts   |
|     13 | John    | Blake     |
|     16 | Theresa | Markham   |
+--------+---------+-----------+
7 rows in set (0.00 sec)
```

The use of `distinct` in above query is optional, but denotes a good practice.

Thus, we come to know that the employees with id ``1, 3, 4, 5, 6, 10, 13, 16``
are __supervisors__. 

A simple observation we'd make is that the other employees 
``2, 7, 8, 9, 11, 12, 14, 15`` must be non supervisors since an employee is 
either a supervisor or not. We readily convert that observation into a query 
that _negates_ the above query:

```sql
mysql> select emp_id, fname, lname from employee where emp_id NOT IN 
       (select distinct superior_emp_id from employee);
```

This query returns a rather unexpected response however:

```sql
Empty set (0.00 sec)
```

### Non-correlated Subqueries Returning Matrices

(multiple rows and multiple columns)
