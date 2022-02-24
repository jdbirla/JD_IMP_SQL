drop table ZERRPF_TEMP;
/
CREATE TABLE "ZERRPF_TEMP" 
(
"UNIQUE_NUMBER"		NUMBER(18)			,
"CLTNAME"			VARCHAR2(20 CHAR) 
 );
/	  
create index ZERRPF_TEMPIDX on ZERRPF_TEMP(UNIQUE_NUMBER); 
/
create or replace procedure  APM_DBMASK_MERG_ZERRPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin
select count(1)into cont1 from ZERRPF_TEMP;

if(cont1>0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_ZERRPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZERRPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_ZERRPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_ZERRPF_MERGE','VM1DTA','ZERRPF_TEMP','UNIQUE_NUMBER',40000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM ZERRPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_ZERRPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO ZERRPF a USING 
    (select * from ZERRPF_TEMP where UNIQUE_NUMBER between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
        A.CLTNAME=B.CLTNAME  ';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_ZERRPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_ZERRPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_ZERRPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZERRPF_MERGE');
    commit;
end if;
end;
/

--exec   APM_DBMASK_MERG_ZERRPF


