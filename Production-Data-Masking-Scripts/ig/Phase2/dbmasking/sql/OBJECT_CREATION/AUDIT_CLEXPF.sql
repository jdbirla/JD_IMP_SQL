drop table AUDIT_CLEXPF_TEMP;
/
CREATE TABLE "AUDIT_CLEXPF_TEMP" 
(
       "UNIQUE_NUMBER"     		  NUMBER(18,0), 			
		"OLDFAXNO"		VARCHAR2(16 BYTE),
		"NEWFAXNO"		VARCHAR2(16 BYTE),
		"NEWRMBLPHONE"       VARCHAR2(16 char),
                "OLDRMBLPHONE"       VARCHAR2(16 char)
);
/			  
create index AUDIT_CLEXPF_tempIDX on AUDIT_CLEXPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_AUDIT_CLEXPF
authid current_user
as

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from AUDIT_CLEXPF_TEMP;

if(cont1>0)then
Delete from AUDIT_CLEXPF_TEMP a where rowid not in (select max(rowid) from AUDIT_CLEXPF_TEMP b where b.unique_number=a.unique_number);
SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_AUDIT_CLEXPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_AUDIT_CLEXPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_AUDIT_CLEXPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_AUDIT_CLEXPF_MERGE','VM1DTA','AUDIT_CLEXPF_TEMP','UNIQUE_NUMBER',41000);

   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM AUDIT_CLEXPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_AUDIT_CLEXPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */

    l_sql_stmt := 'MERGE  INTO AUDIT_CLEXPF a USING
    (select * from AUDIT_CLEXPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET
    	A.OLDFAXNO=B.OLDFAXNO,
        A.NEWFAXNO=B.NEWFAXNO,
	A.NEWRMBLPHONE=B.NEWRMBLPHONE,
        A.OLDRMBLPHONE=B.OLDRMBLPHONE';

    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_AUDIT_CLEXPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.

    l_status := dbms_parallel_execute.task_status('UPDATE_AUDIT_CLEXPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_AUDIT_CLEXPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_AUDIT_CLEXPF_MERGE');
    commit;
end if;
end;
/
