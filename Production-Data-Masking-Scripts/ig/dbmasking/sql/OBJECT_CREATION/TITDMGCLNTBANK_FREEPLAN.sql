drop table TITDMGCLNTBANK_FREEPLAN_TEMP;
/
CREATE TABLE "TITDMGCLNTBANK_FREEPLAN_TEMP" 
(
		"RECIDXCLBK"       NUMBER(38,0), 
		"BANKACCKEY"           VARCHAR2(20 CHAR),
"CRDTCARD"            VARCHAR2(20 CHAR)	
);
/
create index TITDMGCLNTBANK_FREEPLAN_tempIDX on TITDMGCLNTBANK_FREEPLAN_temp(RECIDXCLBK); 
/
create or replace procedure  APM_DBMASK_MERG_TITDMGCLTBK_FP
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITDMGCLNTBANK_FREEPLAN_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE');
END  IF;

update TITDMGCLNTBANK_FREEPLAN_TEMP set BANKACCKEY = ' ' where  TRIM(BANKACCKEY) IS NULL;
update TITDMGCLNTBANK_FREEPLAN_TEMP set CRDTCARD = ' ' where  TRIM(CRDTCARD) IS NULL;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE','VM1DTA','TITDMGCLNTBANK_FREEPLAN_TEMP','RECIDXCLBK',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITDMGCLNTBANK_FREEPLAN_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITDMGCLNTBANK_FREEPLAN@stagedblink a USING 
    (select * from TITDMGCLNTBANK_FREEPLAN_TEMP where RECIDXCLBK between :start_id and :end_id) b
    ON (a.RECIDXCLBK = b.RECIDXCLBK)
    WHEN MATCHED THEN UPDATE SET					
       A.CRDTCARD = B.CRDTCARD,
	A.BANKACCKEY=B.BANKACCKEY';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGCLNTBANK_FREEPLAN_MERGE');
    commit;
end if;
end;
/