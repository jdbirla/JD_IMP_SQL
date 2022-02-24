drop table TITDMGMBRINDP1_FREEPLAN_TEMP;
/
CREATE TABLE "TITDMGMBRINDP1_FREEPLAN_TEMP" 
(
		"RECIDXMBINP1"       NUMBER(38,0), 
		"CRDTCARD"            VARCHAR2(16 CHAR),
		"BANKACCKEY01"           VARCHAR2(20 CHAR) 		
);
/
create index TITDMGMBRINDP1_FREEPLAN_tempIDX on TITDMGMBRINDP1_FREEPLAN_temp(RECIDXMBINP1); 
/
create or replace procedure  APM_DBMASK_MERG_TITDMGMBIN1_FP
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITDMGMBRINDP1_FREEPLAN_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE','VM1DTA','TITDMGMBRINDP1_FREEPLAN_TEMP','RECIDXMBINP1',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITDMGMBRINDP1_FREEPLAN_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITDMGMBRINDP1_FREEPLAN@stagedblink a USING 
    (select * from TITDMGMBRINDP1_FREEPLAN_TEMP where RECIDXMBINP1 between :start_id and :end_id) b
    ON (a.RECIDXMBINP1 = b.RECIDXMBINP1)
    WHEN MATCHED THEN UPDATE SET					
       A.CRDTCARD = B.CRDTCARD,
	A.BNKACCKEY01=B.BANKACCKEY01';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGMBRINDP1_FREEPLAN_MERGE');
    commit;
end if;
end;
/