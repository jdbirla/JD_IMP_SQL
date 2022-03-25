# 900_Tool for Oracle
- This tool can be used to generate txt file from DB, using specific column value and we can create select query for important table which can generate a report for analysis any bug or put all information together in one txt file rather go and select for all different tables.

### How to use this tool

 1. Create a folder in local system
 2. Put all this files and log folder inside that folder where txt file will generate
 3. Open 000_Check_Masking.sql file in SQL developer.
 4. Change the path of local folder inside this file
  ```sql
  @H:\SIT_STAGE_DATA\Phase-2\Mig_Guide\900_Tools\Dump_IG_Database\Dump_Member_Policy.sql 06449948
```
5. Give where column value and execute.
6. Common_Headings.sql : This file is for formatting table column names 
7. Dump_Member_Policy.sql : This is the main file from where spool file will generate , form this file we can call any specific SQL using @@ like hese we used @@Member_Policy_Summary.sql
8. Member_Policy_Summary.sql : This file contains select queries based on the parameter which we passed from step 4 (000_Check_Masking).