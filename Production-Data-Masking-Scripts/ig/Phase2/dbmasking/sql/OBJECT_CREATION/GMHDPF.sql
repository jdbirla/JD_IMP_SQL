drop table GMHDPF_TEMP;
/
CREATE TABLE "GMHDPF_TEMP" 
(
		"UNIQUE_NUMBER"	      NUMBER(18,0),
		"BANKACCKEY"		VARCHAR2(20 CHAR)
              );
/
create index GMHDPF_tempIDX on GMHDPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_GMHDPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from GMHDPF_TEMP;

if(cont1 > 0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_GMHDPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_GMHDPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_GMHDPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_GMHDPF_MERGE','VM1DTA','GMHDPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM GMHDPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_GMHDPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO GMHDPF a USING 
    (select * from GMHDPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
        A.BANKACCKEY=B.BANKACCKEY';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_GMHDPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_GMHDPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_GMHDPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_GMHDPF_MERGE');
    commit;
end if;
end;
/