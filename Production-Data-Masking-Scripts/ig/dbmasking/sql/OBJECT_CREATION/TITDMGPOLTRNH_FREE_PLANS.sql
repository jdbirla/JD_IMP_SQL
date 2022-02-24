drop table TITDMGPOLTRNH_FREE_PLANS_TEMP;
/
CREATE TABLE "TITDMGPOLTRNH_FREE_PLANS_TEMP" 
(
"RECIDXPHIST"		NUMBER(38)			,
"CRDTCARD"			VARCHAR2(16 CHAR) ,
"BNKACCKEY01"			VARCHAR2(20 CHAR)  
 );
/	  
create index TITDMGPOLTRNH_FP_TEMP on TITDMGPOLTRNH_FREE_PLANS_TEMP(RECIDXPHIST); 
/
create or replace procedure  APM_DBMASK_MERG_TITDMGPOLTH_FP
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin
select count(1) into cont1 from TITDMGPOLTRNH_FREE_PLANS_TEMP;
if(cont1 >0)then
SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE','VM1DTA','TITDMGPOLTRNH_FREE_PLANS_TEMP','RECIDXPHIST',40000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITDMGPOLTRNH_FREE_PLANS_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITDMGPOLTRNH_FREEPLAN@stagedblink a USING 
    (select * from TITDMGPOLTRNH_FREE_PLANS_TEMP where RECIDXPHIST between :start_id and :end_id) b
    ON (a.RECIDXPHIST = b.RECIDXPHIST)
    WHEN MATCHED THEN UPDATE SET					
       A.CRDTCARD=B.CRDTCARD,
        A.BNKACCKEY01=B.BNKACCKEY01  ';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGPOLTRNH_FREE_PLANS_MERGE');
    commit;
end if;
end;
/

--exec   APM_DBMASK_MERG_TITDMGPOLTH_FP


