drop table TITDMGREF1_TEMP;
/
CREATE TABLE "TITDMGREF1_TEMP" 
(
"RECIDXREFB1"		NUMBER(38)			,
"BANKACOUNT"			VARCHAR2(20 CHAR) 
 );
/	  
create index TITDMGREF1_TEMPIDX on TITDMGREF1_TEMP(RECIDXREFB1); 
/
create or replace procedure  APM_DBMASK_MERG_TITDMGREF1
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITDMGREF1_TEMP;

if(cont1 >0)then 

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITDMGREF1_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGREF1_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITDMGREF1_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITDMGREF1_MERGE','VM1DTA','TITDMGREF1_TEMP','RECIDXREFB1',40000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITDMGREF1_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITDMGREF1_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITDMGREF1@stagedblink a USING 
    (select * from TITDMGREF1_TEMP where RECIDXREFB1 between :start_id and :end_id) b
    ON (a.RECIDXREFB1 = b.RECIDXREFB1)
    WHEN MATCHED THEN UPDATE SET					
        A.BANKACOUNT=B.BANKACOUNT  ';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITDMGREF1_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITDMGREF1_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITDMGREF1_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGREF1_MERGE');
    commit;
end if;
end;
/

--exec   APM_DBMASK_MERG_TITDMGREF1


