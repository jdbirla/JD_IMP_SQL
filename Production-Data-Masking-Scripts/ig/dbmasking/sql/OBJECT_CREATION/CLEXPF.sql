drop table CLEXPF_TEMP;
/
CREATE TABLE "CLEXPF_TEMP" 
(
	         "UNIQUE_NUMBER"	     NUMBER(18,0),
		"FAXNO"	           VARCHAR2(16 CHAR),
		"RINTERNET"		   VARCHAR2(50 CHAR),
		"RINTERNET2"	   VARCHAR2(50 CHAR),
		"RMBLPHONE"   	VARCHAR2(16 CHAR)
);
/
create index CLEXPF_tempIDX on CLEXPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_CLEXPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from CLEXPF_TEMP;

if(cont1 > 0)Then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_CLEXPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_CLEXPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_CLEXPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_CLEXPF_MERGE','VM1DTA','CLEXPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM CLEXPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_CLEXPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO CLEXPF a USING 
    (select * from CLEXPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
       A.FAXNO=B.FAXNO,
        A.RINTERNET=B.RINTERNET,
        A.RINTERNET2=B.RINTERNET2,
	A.RMBLPHONE=B.RMBLPHONE';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_CLEXPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_CLEXPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_CLEXPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_CLEXPF_MERGE');
    commit;

end if;
end;
/