drop table TITPAMBILLSTOP_TEMP;
/
CREATE TABLE "TITPAMBILLSTOP_TEMP" 
(
		"RECIDXBILLSTOP"       NUMBER(38,0), 
		"MEMSHIPNO"            VARCHAR2(70 CHAR)		
);
/
create index TITPAMBILLSTOP_tempIDX on TITPAMBILLSTOP_temp(RECIDXBILLSTOP); 
/
create or replace procedure  APM_DBMASK_MERG_TITPAMBILLSTOP
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITPAMBILLSTOP_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITPAMBILLSTOP_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITPAMBILLSTOP_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITPAMBILLSTOP_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITPAMBILLSTOP_MERGE','VM1DTA','TITPAMBILLSTOP_TEMP','RECIDXBILLSTOP',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITPAMBILLSTOP_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITPAMBILLSTOP_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITPAMBILLSTOP@stagedblink a USING 
    (select * from TITPAMBILLSTOP_TEMP where RECIDXBILLSTOP between :start_id and :end_id) b
    ON (a.RECIDXBILLSTOP = b.RECIDXBILLSTOP)
    WHEN MATCHED THEN UPDATE SET					
       A.MEMSHIPNO = B.MEMSHIPNO';
	
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITPAMBILLSTOP_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITPAMBILLSTOP_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITPAMBILLSTOP_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITPAMBILLSTOP_MERGE');
    commit;
end if;
end;
/