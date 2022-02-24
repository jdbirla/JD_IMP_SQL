drop table CLRRPF_TEMP;
/
CREATE TABLE "CLRRPF_TEMP" 
(
       "UNIQUE_NUMBER"     		  NUMBER(18,0), 			
		"FORENUM"	    		VARCHAR2(30 CHAR)     
  );
/
create index CLRRPF_tempIDX on CLRRPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_CLRRPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin
execute immediate 'alter trigger VM1DTA.TR_CLRRPF disable';
execute immediate 'alter trigger VM1DTA.TR_AUDIT_CLRRPF disable';
select count(1) into cont1 from CLRRPF_TEMP;

if(cont1 > 0) then
SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_CLRRPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_CLRRPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_CLRRPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_CLRRPF_MERGE','VM1DTA','CLRRPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM CLRRPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_CLRRPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO CLRRPF a USING 
    (select * from CLRRPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
    	A.FORENUM=B.FORENUM';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_CLRRPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_CLRRPF_MERGE');
	execute immediate 'alter trigger VM1DTA.TR_CLRRPF enable';
    execute immediate 'alter trigger VM1DTA.TR_AUDIT_CLRRPF enable';
    DBMS_OUTPUT.PUT_LINE('UPDATE_CLRRPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_CLRRPF_MERGE');
    commit;
end if;
end;
/