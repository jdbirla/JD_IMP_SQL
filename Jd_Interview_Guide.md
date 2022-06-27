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
## SQL ANY and ALL Operators
ANY 
```sql
SELECT column_name(s)
FROM table_name
WHERE column_name operator ANY
  (SELECT column_name
  FROM table_name
  WHERE condition);
  Note: The operator must be a standard comparison operator (=, <>, !=, >, >=, <, or <=).
SELECT ProductName
FROM Products
WHERE ProductID = ANY
  (SELECT ProductID
  FROM OrderDetails
  WHERE Quantity = 10);

  ```
  ALL
  ```sql
  SELECT column_name(s)
FROM table_name
WHERE column_name operator ALL
  (SELECT column_name
  FROM table_name
  WHERE condition);
  
  SELECT ProductName
FROM Products
WHERE ProductID = ALL
  (SELECT ProductID
  FROM OrderDetails
  WHERE Quantity = 10);
  ```
  ## SQL SELECT INTO same as Create as table in oracle
  ```sql
  SELECT * INTO newtable
FROM oldtable
WHERE 1 = 0;
```

## SQL IFNULL(), ISNULL(), COALESCE(), and NVL() Functions

```sql
MySQL : IFNULL() ,COALESCE() 
SQL Server: ISNULL() ,COALESCE() 
Oracle:NVL(),COALESCE()
```
## Stored Procedure 
```sql
DELIMITER //
CREATE PROCEDURE stored_proc_tutorial.spGetMaxMarks(OUT highestMarks INT)
BEGIN
    SELECT MAX(total_marks) INTO highestMarks FROM studentMarks;
END //
DELIMITER
 
-- calling procedure
CALL stored_proc_tutorial.spGetMaxMarks(@highestMarks);
 
-- obtaining value of the OUT parameter
SELECT @highestMarks;
```
SQL Injection
SQL injection is a code injection technique that might destroy your database.

SQL injection is one of the most common web hacking techniques.

SQL injection is the placement of malicious code in SQL statements, via web page input.



