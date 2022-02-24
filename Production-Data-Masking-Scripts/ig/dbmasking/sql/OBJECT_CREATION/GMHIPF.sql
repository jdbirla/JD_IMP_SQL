drop table GMHIPF_TEMP;
/
CREATE TABLE "GMHIPF_TEMP" 
(
	     "UNIQUE_NUMBER"	NUMBER(18,0),
		"ZWORKPLCE1"	  VARCHAR2(25 CHAR),
		"ZWORKPLCE2"	  VARCHAR2(25 CHAR)
);
/
create index GMHIPF_tempIDX on GMHIPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_GMHIPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from GMHIPF_TEMP;

if(cont1 > 0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_GMHIPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_GMHIPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_GMHIPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_GMHIPF_MERGE','VM1DTA','GMHIPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM GMHIPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_GMHIPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO GMHIPF a USING 
    (select * from GMHIPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET						
		A.ZWORKPLCE1=B.ZWORKPLCE1,
        A.ZWORKPLCE2=B.ZWORKPLCE2';
        
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_GMHIPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_GMHIPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_GMHIPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_GMHIPF_MERGE');
    commit;
end if;
end;
/