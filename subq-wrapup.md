
1. Subqueries return single row single column (scalar), single row multiple columns (vectors) or multiple rows and multiple columns (matrices).
2. Noncorrelated subqueries are independent of containing statements and are executed _once_ for the entire containing statement.
3. Correlated subqueries are dependent on columns from containing statement and are executed once for each _candidate record_ returned by the containing statement.
4. Scalar subqueries, (since they return scalars) can utilize comparison operators (`=, <>, <=, >=`). Vector subqueries can utilize special purpose operators (`IN, NOT IN, EXISTS, NOT EXISTS`) and vector and matrix subqueries can utilize (`EXISTS, NOT EXISTS`). The EXISTS and NOT EXISTS operators are useful for efficiently checking if a result set is non-empty.
5. Subqueries can be found in `select, update, delete and insert` statements although MySQL behaves rather weirdly with `delete`s.
6. Since the result sets of subqueries are tables, they can be used in joins with other tables. This makes subqueries _data sources_.
7. The subqueries returning scalars can become useful values that can be placed where a value is needed.
