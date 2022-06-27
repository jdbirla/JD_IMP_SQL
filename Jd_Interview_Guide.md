# JD_SQL_PLSQ_MySQL_Oracle_Interview_Guide

## SQL TOP, LIMIT, FETCH FIRST or ROWNUM Clause
SQL Server / MS Access Syntax:
```sql
SELECT TOP number|percent column_name(s)
FROM table_name
WHERE condition;

SELECT TOP 3 * FROM Customers;
```
MySQL Syntax:

```sql
SELECT column_name(s)
FROM table_name
WHERE condition
LIMIT number;

SELECT * FROM Customers
LIMIT 3;
```
Oracle 12 Syntax:

```sql
SELECT column_name(s)
FROM table_name
ORDER BY column_name(s)
FETCH FIRST number ROWS ONLY;

SELECT * FROM Customers
FETCH FIRST 3 ROWS ONLY;
```
