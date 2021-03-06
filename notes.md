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
from branch``), which means we _can_ have __6 ⨉ 4__ groups (at most) formed that way. Over these
24 groups, we can apply:

1. Several aggregate functions, and
2. A few options

(Some of the groups will be empty and removed from the output. For instance, the
group of BUS accounts opened at the Headquarters (open_branch_id = 1) is empty).
We have seen aggregate functions like avg, max, min, sum, count etc. but the 
options are something new. There are two options that are of interest:

#### With rollup

The dictionary meaning of rollup is accumulation. A few actual runs of this option
will clarify what this option does.

The dictionary meaning of rollup is __accumulation__. A few actual runs of this option
will clarify what it does.

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

<a name="7sup"></a>Thus, we come to know that the employees with id ``1, 3, 4, 5, 6, 10, 13, 16``
are __supervisors__. 

A simple observation we'd make is that the other employees 
``2, 7, 8, 9, 11, 12, 14, 15`` must be non supervisors since an employee is 
either a supervisor or not. We readily convert that observation into a query 
that _negates_ the above query:

```sql
mysql> select emp_id, fname, lname from employee where emp_id NOT IN 
       (select distinct superior_emp_id from employee);
```

__This query returns a rather unexpected response however__:

```sql
Empty set (0.00 sec)
```

So, why does this happen? And that too specifically with __NOT IN__?
The reason has to do with how SQL handles NULLs. Much has been said about the
[problem of NULLs](p23.grant.pdf) and their handling by SQL.

Let's run the subquery as an independent query:

```sql
mysql> select distinct superior_emp_id from employee;
+-----------------+
| superior_emp_id |
+-----------------+
|            NULL |
|               1 |
|               3 |
|               4 |
|               6 |
|              10 |
|              13 |
|              16 |
+-----------------+
8 rows in set (0.00 sec)
```

So, we get an additional `superior_emp_id` we did not consider before: NULL.
How does it change anything, you say.

Consider the following output from MySQL:

```sql
mysql> select 2 in (1, 3);
+-------------+
| 2 in (1, 3) |
+-------------+
|           0 |
+-------------+
1 row in set (0.00 sec)

mysql> select 2 in (1, NULL);
+----------------+
| 2 in (1, NULL) |
+----------------+
|           NULL |
+----------------+
1 row in set (0.00 sec)

mysql> select 2 not in (1, NULL);
+--------------------+
| 2 not in (1, NULL) |
+--------------------+
|               NULL |
+--------------------+
1 row in set (0.00 sec)


```
Thus, 2 is definitely NOT IN the set {1, 3} whose members are well-known. But is
2 IN or NOT IN {1, NULL}? Well, SQL thinks it can't say either way and denotes the result
as NULL which implies __UNKNOWN__. 

This is compounded by how SQL determines the truth values of complex expressions
that are joined by connectives like OR, NOT, AND.

So, let's see how SQL chooses to perform the NOT IN operation when it looks at the
record with emp_id is 2 and the set is ``1, 3, 4, 6, 10, 13, 16, NULL`` (the set
of all superior_emp_id's). Clearly, 2 does not equal 1 (comparion operator returns
0 i.e. false), neither does 2 equal any of ``3, 4, 6, 10, 13, and 16``. But when it
comes to compare 2 with NULL, an unknown value and the result of comparison is
'unknown'. Thus, the truth value of the complex expression becomes
``false or false or ...`` unknown and the result of that expression is well,
__unknown__. So, 

__It is unknown whether the emp_id 2 is NOT in  
``1, 3, 4, 6, 10, 13, 16, NULL`` -- the real set of all id's of superiors__.

To further illustrate this point, note that the three-valued logic that SQL implements
follows Kleene's logic and the truth table for ``A ∨ B (A OR B)`` is:

<table class="wikitable" style="text-align: center;">
<tbody><tr>
<th rowspan="2" colspan="2"><i>A</i> ∨ <i>B</i></th>
<th colspan="3"><i>B</i></th>
</tr>
<tr>
<th colspan="1">F</th>
<th colspan="1">U</th>
<th colspan="1">T</th>
</tr>
<tr>
<th scope="row" rowspan="3" style="padding: 0px 10px;"><i>A</i></th>
<th scope="row" width="25">F</th>
<td align="center">F</td>
<td align="center">U</td>
<td align="center">T</td>
</tr>
<tr>
<th scope="row" width="25">U</th>
<td align="center">*U*</td>
<td align="center">U</td>
<td align="center">T</td>
</tr>
<tr>
<th scope="row" width="25">T</th>
<td align="center">T</td>
<td align="center">T</td>
<td align="center">T</td>
</tr>
</tbody></table>

<table>
<th>
Thus, a (FALSE OR UNDEFINED) produces an UNDEFINED and SQL can't determine
if 2 is in that set. Thus, with three-valued logic, 2 is neither in the
set {1, 3, 4, 6, 10, 13, 16, NULL} nor is it not in the set.
</th>
</table>

And this is why we must be aware of handling the NULL values specially. 


The correct query to return the id's of the employees that are non-supervisors
is:

```sql
mysql> select emp_id from employee where emp_id not in 
    (select distinct superior_emp_id  from employee where superior_emp_id is not null);
+--------+
| emp_id |
+--------+
|      2 |
|      5 |
|      7 |
|      8 |
|      9 |
|     11 |
|     12 |
|     14 |
|     15 |
|     17 |
|     18 |
+--------+
11 rows in set (0.03 sec)
```

### Non-correlated Subqueries Returning Matrices

(multiple rows and multiple columns)

This is an extension of the above. Just like you can check whether a scalar is
a member of set of scalars, you can check whether an n-tuple (a _sequence_ of
_n_ scalars) is a member of set of n-tuples:

```sql
mysql> select (1,2) in ((2, 3), (1, 2));
+---------------------------+
| (1,2) in ((2, 3), (1, 2)) |
+---------------------------+
|                         1 |
+---------------------------+
1 row in set (0.00 sec)
```
Note that (1,2) is not the same as (2,1), the order matters.

It can be observed that you could always replace a subquery that returns and checks
for n columns by n subqueries that each compare one column. It usually is more efficient
to run minimum number of subqueries to get the same result. The following illustrates
the point.

Consider that you want to find out the avail_balance and account_id's of the
accounts that were opened by employees who were either Teller or Head Teller
in the Woburn branch.

One way to deal with this is to separately consider two subqueries, each handling
one of the required parts with an IN operator:
```sql
mysql> select account_id, avail_balance from account where open_branch_id IN 
       (select branch_id from branch where city = 'Woburn') and open_emp_id IN 
       (select emp_id from employee where title IN ('Teller', 'Head Teller'));
+------------+---------------+
| account_id | avail_balance |
+------------+---------------+
|          1 |       1057.75 |
|          2 |        500.00 |
|          3 |       3000.00 |
|          4 |       2258.02 |
|          5 |        200.00 |
|         17 |       5000.00 |
|         27 |       9345.55 |
+------------+---------------+
7 rows in set (0.00 sec)
```

This query uses two subqueries. It could be replaced by just one subquery
involving a join of two tables thus:
```sql
mysql> select account_id, avail_balance from account where 
       (open_branch_id, open_emp_id) IN 
       (select b.branch_id, e.emp_id from branch b INNER JOIN employee e ON 
       b.branch_id = e.assigned_branch_id where b.city = 'Woburn' and 
       e.title IN ('Teller', 'Head Teller'));
+------------+---------------+
| account_id | avail_balance |
+------------+---------------+
|          1 |       1057.75 |
|          2 |        500.00 |
|          3 |       3000.00 |
|          4 |       2258.02 |
|          5 |        200.00 |
|         17 |       5000.00 |
|         27 |       9345.55 |
+------------+---------------+
7 rows in set (0.00 sec)
```

There could be yet another way to do this using SQL joins of three tables. The
thing to remember is that with SQL, [many ways][1] can get you there.

## Correlated Subqueries

A non-correlated subquery is independent of the containing statement. Thus,
the non-correlated subquery can be executed and inspected separately. A correlated
subquery, on the other hand, is __dependent on its containing statement__ from 
which it references one or more columns.

A non-correlated subquery is executed once for the containing query, prior to the 
execution of the containing statement.

A correlated subquery is executed once for _each candidate row_ (a row that might
be included in the final results).

Consider the problem of finding out the customer id, type (business or indiv),
and the city (address) for each customer that has exactly two accounts: 

If we knew the id of a customer, we can easily find out the number of accounts
that customer has. This number can be compared with 2 in a subquery which borrows
the customer id from the containing statement:
```sql
select c.cust_id, c.cust_type_cd, c.city from customer c where 
(select count(*) from account a where a.cust_id = c.cust_id) = 2;

+---------+--------------+---------+
| cust_id | cust_type_cd | city    |
+---------+--------------+---------+
|       2 | I            | Woburn  |
|       3 | I            | Quincy  |
|       6 | I            | Waltham |
|       8 | I            | Salem   |
|      10 | B            | Salem   |
+---------+--------------+---------+
5 rows in set (0.00 sec)
```

The correlated subquery, in a way, acts like a filter that is executed
for each candidate record which, in this case, happens to be each customer.

The operator BETWEEN can be used with scalars returned by subqueries.

## The exists operator
While you will often see correlated subqueries used in equality and range
conditions, the most common operator used to build conditions that utilize
correlated subqueries is the __exists__ operator which simply checks if
subquery returned any rows.

Convention is to use `select 1` (the literal 1) or `select (*)` when using
the exists operator, although select 1 is probably easiest and the most 
efficient because what is of essence is the filter condition, we are not
interested the actual data that is returned, only whether it contained any 
records.

Like there exists __exists__, there exists  __not exists__ as well :-).

### Data Manipulation Using Correlated Subqueries

## When to Use Subqueries

Subqueries are versatile. They can be used to

1. Construct custom tables
2. Build filter conditions
3. Generate column values

### Subqueries as Data Sources
#### Data Fabrication
#### Task-oriented Subqueries
### Subqueries in Filter Conditions
### Subqueries as Expression Generators

## Subquery Wrap-up

Subqueries have some really useful applications and they are a great tool in your arsenal.

1. Subqueries return single row single column (scalar), single row multiple columns (vectors) or multiple rows and multiple columns (matrices).
2. Non-correlated subqueries are independent of containing statements and are executed _once_ for the entire containing statement.
3. Correlated subqueries are dependent on columns from containing statement and are executed once for each _candidate record_ returned by the containing statement.
4. Scalar subqueries, (since they return scalars) can utilize comparison operators (`=, <>, <=, >=`). Vector subqueries can utilize special purpose operators (`IN, NOT IN, EXISTS, NOT EXISTS`) and vector and matrix subqueries can utilize (`EXISTS, NOT EXISTS`). The EXISTS and NOT EXISTS operators are useful for efficiently checking if a result set is non-empty.
5. Subqueries can be found in `select, update, delete and insert` statements although MySQL behaves rather weirdly with `delete`s.
6. Since the result sets of subqueries are tables, they can be used in joins with other tables. This makes subqueries _data sources_.
7. The subqueries returning scalars can become useful values that can be placed where a value is needed.

This chapter covers a lot of ground. One will need to come back and refer to this chapter time and again.

## Exercises

### Exercise 9-1
Find all the loan accounts (`product.product_type_cd = 'LOAN'`). Hint: Use a non-correlated subquery. 

The product_cd can have a few possibilities for the product_type_cd to be 'LOAN' which we can find out from a subquery. The subquery will return multiple rows with single column (each row representing that product_cd for which product_type_cd is 'LOAN'. And then we can examine for each account if the product_cd is in that 'vector'.

```sql
mysql> select account_id, product_cd, cust_id, avail_balance from account 
     where product_cd in (select product_cd from product where product_type_cd = 'LOAN');
+------------+------------+---------+---------------+
| account_id | product_cd | cust_id | avail_balance |
+------------+------------+---------+---------------+
|         25 | BUS        |      10 |          0.00 |
|         27 | BUS        |      11 |       9345.55 |
|         29 | SBL        |      13 |      50000.00 |
+------------+------------+---------+---------------+
3 rows in set (0.00 sec)

```
### Exercise 9-2
Find all the loan accounts (`product.product_type_cd = 'LOAN'`). Hint: Use a correlated subquery. 

Given a product_cd of an account, we can easily verify if its product_type_cd from the product table is 'LOAN'. We can then select an account that satisfies that condition. This requires the product_cd from account to be correlated with the subquery:

```sql
mysql> select account_id, product_cd, cust_id, avail_balance from account 
     where (select product_type_cd from product where product_cd = account.product_cd) 
     = 'LOAN';
+------------+------------+---------+---------------+
| account_id | product_cd | cust_id | avail_balance |
+------------+------------+---------+---------------+
|         25 | BUS        |      10 |          0.00 |
|         27 | BUS        |      11 |       9345.55 |
|         29 | SBL        |      13 |      50000.00 |
+------------+------------+---------+---------------+
3 rows in set (0.00 sec)
```
### Exercise 9-3

```sql
mysql> select e.fname, e.lname, levels.name, e.start_date from employee e inner join 
   (select 'trainee' name, '2004-01-01' start_date, '2005-12-31' end_date UNION ALL 
    select 'worker' name, '2002-01-01' start_date, '2003-12-31' end_date UNION ALL 
    select 'mentor' name, '2000-01-01' start_date, '2001-12-31' end_date) levels 
    on e.start_date >= levels.start_date and e.start_date <= levels.end_date 
    order by levels.name;
+----------+-----------+---------+------------+
| fname    | lname     | name    | start_date |
+----------+-----------+---------+------------+
| Thomas   | Ziegler   | mentor  | 2000-10-23 |
| Michael  | Smith     | mentor  | 2001-06-22 |
| Theresa  | Markham   | mentor  | 2001-03-15 |
| John     | Blake     | mentor  | 2000-05-11 |
| Robert   | Tyler     | mentor  | 2000-02-09 |
| Helen    | Fleming   | trainee | 2004-03-17 |
| Chris    | Tucker    | trainee | 2004-09-15 |
| Rick     | Tulman    | worker  | 2002-12-12 |
| Susan    | Hawthorne | worker  | 2002-04-24 |
| Frank    | Portman   | worker  | 2003-04-01 |
| Sarah    | Parker    | worker  | 2002-12-02 |
| Samantha | Jameson   | worker  | 2003-01-08 |
| John     | Gooding   | worker  | 2003-11-14 |
| Jane     | Grossman  | worker  | 2002-05-03 |
| Susan    | Barker    | worker  | 2002-09-12 |
| Beth     | Fowler    | worker  | 2002-06-29 |
| Paula    | Roberts   | worker  | 2002-07-27 |
| Cindy    | Mason     | worker  | 2002-08-09 |
+----------+-----------+---------+------------+
18 rows in set (0.00 sec)

```
### Exercise 9-4
Retrieve employee ID, first name, last name and names of department and assigned branch of each employee. Do _not join_ any tables.

```sql
mysql> select e.fname, e.lname, e.emp_id, (select name from department where dept_id = e.dept_id) department, (select name from branch where branch_id = e.assigned_branch_id) branch from employee e; 
+----------+-----------+--------+----------------+---------------+
| fname    | lname     | emp_id | department     | branch        |
+----------+-----------+--------+----------------+---------------+
| Michael  | Smith     |      1 | Administration | Headquarters  |
| Susan    | Barker    |      2 | Administration | Headquarters  |
| Robert   | Tyler     |      3 | Administration | Headquarters  |
| Susan    | Hawthorne |      4 | Operations     | Headquarters  |
| John     | Gooding   |      5 | Loans          | Headquarters  |
| Helen    | Fleming   |      6 | Operations     | Headquarters  |
| Chris    | Tucker    |      7 | Operations     | Headquarters  |
| Sarah    | Parker    |      8 | Operations     | Headquarters  |
| Jane     | Grossman  |      9 | Operations     | Headquarters  |
| Paula    | Roberts   |     10 | Operations     | Woburn Branch |
| Thomas   | Ziegler   |     11 | Operations     | Woburn Branch |
| Samantha | Jameson   |     12 | Operations     | Woburn Branch |
| John     | Blake     |     13 | Operations     | Quincy Branch |
| Cindy    | Mason     |     14 | Operations     | Quincy Branch |
| Frank    | Portman   |     15 | Operations     | Quincy Branch |
| Theresa  | Markham   |     16 | Operations     | So. NH Branch |
| Beth     | Fowler    |     17 | Operations     | So. NH Branch |
| Rick     | Tulman    |     18 | Operations     | So. NH Branch |
+----------+-----------+--------+----------------+---------------+
18 rows in set (0.00 sec)
```

# Chapter 10 Joins Revisited

In _inner joins_, the records are rejected if there is a value for the join column in one
of the tables is missing. Thus, if you perform an inner join between the employee table and department table on the dept_id column and for a record if dept_id is missing, then that record will be removed from the join.

Outer Joins, on the other hand, are different.

## Outer Joins

A helpful way to think of utility of an outer join is by an example. Consider the employee table. What will you do if you want to come up with a list of employees and their supervisors?

A self-inner-join of the employee table on the supervisor_id of first table and emp_id of the second, you say? Let's see:

```sql
mysql> select e.fname employee_first, e.lname employee_last, m.fname manager_first, 
       m.lname manager_last from employee e inner join employee m 
       on e.superior_emp_id = m.emp_id;
+----------------+---------------+---------------+--------------+
| employee_first | employee_last | manager_first | manager_last |
+----------------+---------------+---------------+--------------+
| Susan          | Barker        | Michael       | Smith        |
| Robert         | Tyler         | Michael       | Smith        |
| Susan          | Hawthorne     | Robert        | Tyler        |
| John           | Gooding       | Susan         | Hawthorne    |
| Helen          | Fleming       | Susan         | Hawthorne    |
| Chris          | Tucker        | Helen         | Fleming      |
| Sarah          | Parker        | Helen         | Fleming      |
| Jane           | Grossman      | Helen         | Fleming      |
| Paula          | Roberts       | Susan         | Hawthorne    |
| Thomas         | Ziegler       | Paula         | Roberts      |
| Samantha       | Jameson       | Paula         | Roberts      |
| John           | Blake         | Susan         | Hawthorne    |
| Cindy          | Mason         | John          | Blake        |
| Frank          | Portman       | John          | Blake        |
| Theresa        | Markham       | Susan         | Hawthorne    |
| Beth           | Fowler        | Theresa       | Markham      |
| Rick           | Tulman        | Theresa       | Markham      |
+----------------+---------------+---------------+--------------+
17 rows in set (0.00 sec)
```
This looks correct. However, we have 18 employees (`select count(*) from employee`) but the above query returns only 17 records. Either an employee has a manager or not, so if an employee does _not_ have a manager, we should acknowledge that and this is exactly what this query does not
do. It does not acknowledge that Michael Smith, the president of the company, does not have a manager.

Michael Smith would have been chosen from the _left_ table if we were not to care what the _right_ table returns for the join condition. When the join is being performed and the Michael Smith record from the _left_ table becomes a candidate, the _right_ table reutrns m.emp_id as 1 in exactly one case (i.e. when the record from the right table is also that of Michael Smith). The point however is that for Michael Smith to occur in the result set, we do want to choose this record even when the right table has the join condition missing. Thus, when the _left table_ brings in the record with emp_id = 1, we ignore everything (columns) that the _right table_ brings in. This effectively makes the record from the _left table_ to fall through into the result set with the specified right table fields fetching NULL's.

This effect is achieved when we do a __left outer join instead of the inner join__ of the employee table (employee) with itself (manager):

```sql
mysql> select e.fname employee_first, e.lname employee_last, 
              m.fname manager_first, m.lname manager_last 
              from employee e left outer join employee m 
              on e.superior_emp_id = m.emp_id;
+----------------+---------------+---------------+--------------+
| employee_first | employee_last | manager_first | manager_last |
+----------------+---------------+---------------+--------------+
| Michael        | Smith         | NULL          | NULL         |
| Susan          | Barker        | Michael       | Smith        |
| Robert         | Tyler         | Michael       | Smith        |
| Susan          | Hawthorne     | Robert        | Tyler        |
| John           | Gooding       | Susan         | Hawthorne    |
| Helen          | Fleming       | Susan         | Hawthorne    |
| Chris          | Tucker        | Helen         | Fleming      |
| Sarah          | Parker        | Helen         | Fleming      |
| Jane           | Grossman      | Helen         | Fleming      |
| Paula          | Roberts       | Susan         | Hawthorne    |
| Thomas         | Ziegler       | Paula         | Roberts      |
| Samantha       | Jameson       | Paula         | Roberts      |
| John           | Blake         | Susan         | Hawthorne    |
| Cindy          | Mason         | John          | Blake        |
| Frank          | Portman       | John          | Blake        |
| Theresa        | Markham       | Susan         | Hawthorne    |
| Beth           | Fowler        | Theresa       | Markham      |
| Rick           | Tulman        | Theresa       | Markham      |
+----------------+---------------+---------------+--------------+
18 rows in set (0.00 sec)

```
This correctly reflects the situation as the NULL values for manager's first and last name for Michael Smith denote that that employee has no manager, which is correct.

In an outer join, the table whose records _fall through into the result set_ is specified using the words _left_ and _right_:

1. __left__ outer join: fields from the left table are chosen
2. __right__ outer join: fields from the right table are chosen

To illustrate this point, let's run the following query and before you see the results, think of what it would actually return:

```sql
mysql> select e.fname employee_first, e.lname employee_last, 
              m.fname manager_first, m.lname manager_last 
              from employee e right outer join employee m 
              on e.superior_emp_id = m.emp_id;
```

The only difference between this query and the previous one is that the previous query took a _left_ outer join, whereas this one takes the _right_ outer join of the employee table with itself.

Note that:

1. We are interested in employees from the left table.
2. We are interested in managers from the right table.
3. When the employee's superior_emp_id matches manager's emp_id, we choose that record. This chooses employees and their managers.
4. We let the records from the __right table to fall through__ into the result set even when the left table brings nothing. Thus, for a certain emp_id in employee table, even if we don't have any other employee whose superior_emp_id matches that emp_id, we choose the first and last name from the second table. This lets ... 

Yes, the non-managers also to show up in the result set.

Thus, this one query chooses all the employees and their managers and all the non-managers:
```sql
+----------------+---------------+---------------+--------------+
| employee_first | employee_last | manager_first | manager_last |
+----------------+---------------+---------------+--------------+
| Susan          | Barker        | Michael       | Smith        |
| Robert         | Tyler         | Michael       | Smith        |
| NULL           | NULL          | Susan         | Barker       |
| Susan          | Hawthorne     | Robert        | Tyler        |
| John           | Gooding       | Susan         | Hawthorne    |
| Helen          | Fleming       | Susan         | Hawthorne    |
| Paula          | Roberts       | Susan         | Hawthorne    |
| John           | Blake         | Susan         | Hawthorne    |
| Theresa        | Markham       | Susan         | Hawthorne    |
| NULL           | NULL          | John          | Gooding      |
| Chris          | Tucker        | Helen         | Fleming      |
| Sarah          | Parker        | Helen         | Fleming      |
| Jane           | Grossman      | Helen         | Fleming      |
| NULL           | NULL          | Chris         | Tucker       |
| NULL           | NULL          | Sarah         | Parker       |
| NULL           | NULL          | Jane          | Grossman     |
| Thomas         | Ziegler       | Paula         | Roberts      |
| Samantha       | Jameson       | Paula         | Roberts      |
| NULL           | NULL          | Thomas        | Ziegler      |
| NULL           | NULL          | Samantha      | Jameson      |
| Cindy          | Mason         | John          | Blake        |
| Frank          | Portman       | John          | Blake        |
| NULL           | NULL          | Cindy         | Mason        |
| NULL           | NULL          | Frank         | Portman      |
| Beth           | Fowler        | Theresa       | Markham      |
| Rick           | Tulman        | Theresa       | Markham      |
| NULL           | NULL          | Beth          | Fowler       |
| NULL           | NULL          | Rick          | Tulman       |
+----------------+---------------+---------------+--------------+
28 rows in set (0.00 sec)
```
Thus, when the 'manager' is 'Susan Barker' (for instance), the employee is NULL NULL, which means there is no employee that reports to 'Susan Barker' and the chosen record will accept nothing from left table and everything we need (m.fname, m.lname) from the right table.

Note that we chose the above __right outer join__ because we wanted both managers and non-managers to show up in the result set of _a single query_. If we just needed to find the names of non-managers, we'd rather resort to subquery (although there are other ways):
```sql
mysql> select fname, lname from employee where emp_id not in 
    (select distinct superior_emp_id from employee where superior_emp_id is not null);
+----------+----------+
| fname    | lname    |
+----------+----------+
| Susan    | Barker   |
| John     | Gooding  |
| Chris    | Tucker   |
| Sarah    | Parker   |
| Jane     | Grossman |
| Thomas   | Ziegler  |
| Samantha | Jameson  |
| Cindy    | Mason    |
| Frank    | Portman  |
| Beth     | Fowler   |
| Rick     | Tulman   |
+----------+----------+
11 rows in set (0.00 sec)
```
In case of outer join the candidate record for which the other table does not satisfy the join condition is included in the result set only once. 

Thus, though inner joins are more common, outer joins are useful too.

## Cross Joins

Cross Joins are the Cartesian product of the two tables. They return all combinations of the rows of the two tables and hence the [rule of product](http://en.wikipedia.org/wiki/Rule_of_product) applies. 

An interesting use case occurs when you need to fabricate data with numbers. This is where the Cross Joins are useful, although they are generally considered not so useful. See [Exercise 10-4](#exercise-10-4).

## Exercises 

### Exercise 10-1
select p.name, p.product_cd, a.account_id from product p left outer join account a
  on p.product_cd = a.product_cd;
  
### Exercise 10-2
select p.name, p.product_cd, a.account_id from account a right outer join product p
  on p.product_cd = a.product_cd;

### Exercise 10-3
select ab.account_id, ab.product_cd, i.fname, i.lname, ab.name from (select a.cust_id, a.account_id, a.product_cd, b.name from account a left outer join business b 
 on a.cust_id = b.cust_id) ab left outer join individual i on
 ab.cust_id = i.cust_id order by ab.account_id;
  
### Exercise 10-4
Generate a table of numbers {1..100} using Cross Join.

The two fabricated tables each have 10 records: first from 0 to 9 (counting by 1) and the second from 0 to 90 (counting by 10):
```text
units  tens
  0      0
  1     10
  2     20
  3     30
  ...
  9     90
```
The sets are generated then by cross join:
```text
{0, 0}
{1, 0}
{2, 0}
...
{9, 0}
{0, 10}
{1, 10}
...
{9, 10}
...
{7, 90}
{8, 90}
{9, 90}
```
Thus, the first number changes 10 times for each second number and we have 10 second numbers. The [rule of product](http://en.wikipedia.org/wiki/Rule_of_product) readily applies, since these are disjoint sets. 

Now, __we can do what we want with the numbers thus obtained__. In this case, we simply add them up and increment that sum to get a sequence from 1 to 100:

```sql
mysql> select (units.num + tens.num + 1) one_to_hundred from
     (select 0 num union all select 1 num union all 
     select 2 num union all select 3 num union all 
     select 4 num union all select 5 num union all 
     select 6 num union all select 7 num union all 
     select 8 num union all select 9 num) units
     cross join 
     (select 0 num union all select 10 num union all select 20 num union all 
     select 30 num union all select 40 num union all 
     select 50 num union all select 60 num union all 
     select 70 num union all select 80 num union all select 90 num) tens;
+----------------+
| one_to_hundred |
+----------------+
|              1 |
|              2 |
|              3 |
|              4 |
|              5 |
|              6 |
|              7 |
|              8 |
|              9 |
|             10 |
|             11 |
|             12 |
....
|             88 |
|             89 |
|             90 |
|             91 |
|             92 |
|             93 |
|             94 |
|             95 |
|             96 |
|             97 |
|             98 |
|             99 |
|            100 |
+----------------+
100 rows in set (0.02 sec)

```

## Chapter 11: Conditional Logic

In certain cases, you may want your SQL logic to branch in one direction or another __depending on the values of certain columns or expressions__. This chapter focuses on how to write __statements that can behave differently depending on the data encountered during the statement execution__.

### What is Conditional Logic?

Conditional Logic is simply the __ability to take one of several paths during program execution__. For example, when querying customer information, you may want to retrieve:

1. Either the __fname/lname__ columns from the _individual_ table, 
2. Or, the __name__ column from the _business_ table,

__depending on what type of customer is encountered.__

This is different from using either subquery or joins where there is no conditional execution based on dynamic values is involved.

Let's say that we want to create a report that shows every customer's id, fed_id and _name_: __if__ the customer is an individual, show the first and last name, __otherwise__ show the name of the business. (Assume that a customer is either an individual or a business). For further clarity, show the type of the customer ('Individual', 'Business')

A clear statement like that can _hint at_ conditional logic (if, otherwise ...). In our first attempt, let's say we don't know how to _write_ the conditional logic. Knowing what we already do, we may come up first with a statement like this:
```sql
mysql> select cust_id, fed_id, cust_type_cd from customer;
+---------+-------------+--------------+
| cust_id | fed_id      | cust_type_cd |
+---------+-------------+--------------+
|       1 | 111-11-1111 | I            |
|       2 | 222-22-2222 | I            |
|       3 | 333-33-3333 | I            |
|       4 | 444-44-4444 | I            |
|       5 | 555-55-5555 | I            |
|       6 | 666-66-6666 | I            |
|       7 | 777-77-7777 | I            |
|       8 | 888-88-8888 | I            |
|       9 | 999-99-9999 | I            |
|      10 | 04-1111111  | B            |
|      11 | 04-2222222  | B            |
|      12 | 04-3333333  | B            |
|      13 | 04-4444444  | B            |
+---------+-------------+--------------+
13 rows in set (0.00 sec)
```
This lacks to expand the cust_type_cd. So, in the next iteration, we make a small improvement using the conditional logic:
```sql
mysql> select cust_id, fed_id, (
     case 
     when cust_type_cd = 'I' then 'Individual'
     when cust_type_cd = 'B' then 'Business'
     else 'Error!'
     end
     ) cust_type_cd
     from customer;
+---------+-------------+--------------+
| cust_id | fed_id      | cust_type_cd |
+---------+-------------+--------------+
|       1 | 111-11-1111 | Individual   |
|       2 | 222-22-2222 | Individual   |
|       3 | 333-33-3333 | Individual   |
|       4 | 444-44-4444 | Individual   |
|       5 | 555-55-5555 | Individual   |
|       6 | 666-66-6666 | Individual   |
|       7 | 777-77-7777 | Individual   |
|       8 | 888-88-8888 | Individual   |
|       9 | 999-99-9999 | Individual   |
|      10 | 04-1111111  | Business     |
|      11 | 04-2222222  | Business     |
|      12 | 04-3333333  | Business     |
|      13 | 04-4444444  | Business     |
+---------+-------------+--------------+
13 rows in set (0.00 sec)

```
And this is how the basic case construct works. There are two types:

### Searched Case

This type is the more versatile of the two:

```sql
case
  when C1 then E1
  when C2 then E2
  ...
  when Cn then En
  [else Ed]
end
```
where,
`C1, C2, ..., Cn` are the _conditions_, each of which evaluates to either true or false
and
`E1, E2, ..., En` are the _expressions_. An expression is just something that returns some value. If a condition is true, then the value of associated expression is that of the entire case statement.

A special optional expression `Ed` is the default expression. If the else clause is present and all other conditions evaluate to false, then Ed is returned. If all of `C1, C2, ..., Cn` evaluate to false and else clause is absent, then a NULL is returned.
### Simple Case

Here the control is assumed by an 'equality operator' and the conditions become values that are compared to a value of interest:

```sql
case V0
  when V1 then E1
  when V2 then E2
  ...
  when Vn then En
  [else Ed]
end
```

Thus, we are interested in seeing if V0 is _equal to_ any of `V1, V2,...,Vn` and if it is, then the value of the associated expression is the value of the case statement.

### Transforming Result Set 

Interestingly, since the case statements get evaluated to values, they can be used in projections (i.e. select clause)! One use of this is to create/fabricate some columns in the result sets. 

Consider the query to display the number of accounts grouped by their open_date:
```sql
mysql> select YEAR(open_date) year, count(*) how_many from account group by year(open_date);
+------+----------+
| year | how_many |
+------+----------+
| 2000 |        3 |
| 2001 |        4 |
| 2002 |        5 |
| 2003 |        3 |
| 2004 |        9 |
+------+----------+
5 rows in set (0.00 sec)
```
What if you wanted these to be printed as one single row with as many columns as there are _open years_ as long as those years are between 2000 and 2005?

In this case, you could use conditional logic combined with aggregate function. Since an account is opened in exactly one year, an account is 'fixed' to one _open year_. So, for each record in the account table, we can get exactly one year, the year in which it was opened. We can then compare that year with each of the years between 2000 and 2005 and we can choose additional columns:
```sql
mysql> select SUM(CASE 
     WHEN YEAR(a.open_date) = '2000' THEN 1
     ELSE 0
     END) year_2000,
     SUM(CASE 
     WHEN YEAR(a.open_date) = '2001' THEN 1
     ELSE 0
     END) year_2001,
     SUM(CASE 
     WHEN YEAR(a.open_date) = '2002' THEN 1
     ELSE 0
     END) year_2002,
     SUM(CASE 
     WHEN YEAR(a.open_date) = '2003' THEN 1
     ELSE 0
     END) year_2003,
     SUM(CASE 
     WHEN YEAR(a.open_date) = '2004' THEN 1
     ELSE 0
     END) year_2004,
     SUM(CASE 
     WHEN YEAR(a.open_date) = '2005' THEN 1
     ELSE 0
     END) year_2005
     from account a;

+-----------+-----------+-----------+-----------+-----------+-----------+
| year_2000 | year_2001 | year_2002 | year_2003 | year_2004 | year_2005 |
+-----------+-----------+-----------+-----------+-----------+-----------+
|         3 |         4 |         5 |         3 |         9 |         0 |
+-----------+-----------+-----------+-----------+-----------+-----------+
1 row in set (0.00 sec)

```

### Selective Aggregation

### Checking for Existence

Write a query that displays cust_id, fed_id, cust_type_cd, whether the customer has a checking account and whether the customer has a savings account.

We know how to create/fabricate additional columns using conditional logic (also look at the suggestive words like 'whether'): ``select cust_id, fed_id, cust_type_cd, () has_checking, () has_savings`` seems straightforward. All we have got to do is provide an appropriate case statement for each customer that correctly evaluates to a 'Y' or an 'N' (thus, we need to fulfil the pairs of parentheses:
```sql
select c.cust_id, fed_id, cust_type_cd, 
       (CASE  
            WHEN EXISTS (select product_cd from account where product_cd = 'SAV' and cust_id = c.cust_id) 
            THEN 'Y'  
            ELSE 'N' 
        END) has_savings,
       (CASE  
            WHEN EXISTS (select product_cd from account where product_cd = 'CHK' and cust_id = c.cust_id) 
            THEN 'Y'  
            ELSE 'N' 
        END) has_checking
from customer c;
+---------+-------------+--------------+-------------+--------------+
| cust_id | fed_id      | cust_type_cd | has_savings | has_checking |
+---------+-------------+--------------+-------------+--------------+
|       1 | 111-11-1111 | I            | Y           | Y            |
|       2 | 222-22-2222 | I            | Y           | Y            |
|       3 | 333-33-3333 | I            | N           | Y            |
|       4 | 444-44-4444 | I            | Y           | Y            |
|       5 | 555-55-5555 | I            | N           | Y            |
|       6 | 666-66-6666 | I            | N           | Y            |
|       7 | 777-77-7777 | I            | N           | N            |
|       8 | 888-88-8888 | I            | Y           | Y            |
|       9 | 999-99-9999 | I            | N           | Y            |
|      10 | 04-1111111  | B            | N           | Y            |
|      11 | 04-2222222  | B            | N           | N            |
|      12 | 04-3333333  | B            | N           | Y            |
|      13 | 04-4444444  | B            | N           | N            |
+---------+-------------+--------------+-------------+--------------+
13 rows in set (0.00 sec)
```
### Division by Zero Errors

Note that MySQL sets the _result_ of dividing by zero to NULL instead of throwing an error. 

### Handling Null Values

While null values are appropriate to store in a table if the value of a column _is_ unknown. But null values are not usually appropriate for display. They are also problematic in expressions. 

__When performing calculations, case expressions are useful for translating a null value into a number (usually 0 or 1)__.

[1]: http://en.wikipedia.org/wiki/There%27s_more_than_one_way_to_do_it
