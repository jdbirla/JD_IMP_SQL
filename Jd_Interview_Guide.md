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

---
### ER Daigram
for ER daigram creation : http://www.lucidchart.com
![image](https://user-images.githubusercontent.com/69948118/176556252-c9270c49-0c4f-43be-8053-c560c1416ba6.png)
![image](https://user-images.githubusercontent.com/69948118/176556358-e4178535-80ce-4fed-94c3-bffaa9eefd71.png)
![image](https://user-images.githubusercontent.com/69948118/176556607-179bbefb-c40c-433d-b857-9186ac480dab.png)
![image](https://user-images.githubusercontent.com/69948118/176556645-55367dab-1bcb-4d5f-9327-d0dff7ba9f0b.png)
![image](https://user-images.githubusercontent.com/69948118/176556817-c26f7cba-ad4e-4187-a3ab-cc1b9ea2891e.png)
![image](https://user-images.githubusercontent.com/69948118/176556856-f930415c-7d2f-4907-bf47-ba77de7f41b3.png)
![image](https://user-images.githubusercontent.com/69948118/176556928-547a882b-faac-4c5a-a7a1-6c3ec22e6b0b.png)
![image](https://user-images.githubusercontent.com/69948118/176556962-f75ecd94-2d34-42c5-96a9-2e15dca7180a.png)

![image](https://user-images.githubusercontent.com/69948118/176557394-172f6e2c-9e14-4909-ab1c-f5c5cbf95e5e.png)

![image](https://user-images.githubusercontent.com/69948118/176557496-5eb29da4-7e16-4b5d-bbb7-2d7339a9c558.png)
![image](https://user-images.githubusercontent.com/69948118/176558175-e3cbae92-5a75-49d1-b732-54bc9ec669f9.png)
![image](https://user-images.githubusercontent.com/69948118/176558245-bb0c412b-9050-41c1-8529-94ba40cc3b4a.png)

![image](https://user-images.githubusercontent.com/69948118/176558214-ede2f0da-1530-4e79-9493-245a11c49f2a.png)

![image](https://user-images.githubusercontent.com/69948118/176558527-8cd544b7-ab80-465a-bfab-4e0d46f729d7.png)

- Export into DB scripts using lucid chart

![image](https://user-images.githubusercontent.com/69948118/176558606-e5439941-9509-4fd4-a135-1f05f3e4e56e.png)

- Import DB to create ER daigram using lucidchart
![image](https://user-images.githubusercontent.com/69948118/176558729-13a3cc5f-1e1a-4dbd-a3e2-df7283ce0c8f.png)

---
### Grouping SETS
```sql
SELECT
    warehouse,
    product, 
    SUM (quantity) qty
FROM
    inventory
GROUP BY
    GROUPING SETS(
        (warehouse,product),
        (warehouse),
        (product),
        ()
    );
```
![image](https://user-images.githubusercontent.com/69948118/176564235-e2bd039c-63a8-4934-8380-9093af4ebdab.png)

![image](https://user-images.githubusercontent.com/69948118/176566119-6afc00fc-edb9-4b80-8252-a7cba938800f.png)

![image](https://user-images.githubusercontent.com/69948118/176566336-dc473766-5246-41c7-abc0-982e29ddc917.png)

### Window function https://www.sqltutorial.org/sql-window-functions/
![image](https://user-images.githubusercontent.com/69948118/176566450-d267cf1c-d9f6-4ec4-906b-9382b7c04f66.png)
![image](https://user-images.githubusercontent.com/69948118/176566528-10175cde-b046-4bda-9e17-e5eb93141999.png)
![image](https://user-images.githubusercontent.com/69948118/176566812-42136470-a7ea-4b66-b66f-7f5dfeddb13f.png)





