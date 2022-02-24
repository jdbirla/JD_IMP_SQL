drop table TOTPAMMISPOL_TEMP;
/
CREATE TABLE "TOTPAMMISPOL_TEMP" 
(
		"RECIDXMEMPOL"       NUMBER(38,0),
		"BANKACCKEY01"       VARCHAR2(20 CHAR),
		"BANKACCKEY02"       VARCHAR2(20 CHAR),
		"ZENSPCD01"       VARCHAR2(70 CHAR),
		"ZENSPCD02"       VARCHAR2(70 CHAR)		
);
/
create index TOTPAMMISPOL_tempIDX on TOTPAMMISPOL_temp(RECIDXMEMPOL); 
/
create or replace procedure  APM_DBMASK_MERG_TOTPAMMISPOL
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TOTPAMMISPOL_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TOTPAMMISPOL_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMMISPOL_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TOTPAMMISPOL_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TOTPAMMISPOL_MERGE','VM1DTA','TOTPAMMISPOL_TEMP','RECIDXMEMPOL',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TOTPAMMISPOL_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TOTPAMMISPOL_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TOTPAMMISPOL@stagedblink a USING 
    (select * from TOTPAMMISPOL_TEMP where RECIDXMEMPOL between :start_id and :end_id) b
    ON (a.RECIDXMEMPOL = b.RECIDXMEMPOL)
    WHEN MATCHED THEN UPDATE SET					
       A.BANKACCKEY02 = B.BANKACCKEY02,
	A.BANKACCKEY01=B.BANKACCKEY01,
	A.ZENSPCD01=B.ZENSPCD01,
	A.ZENSPCD02=B.ZENSPCD02';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TOTPAMMISPOL_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TOTPAMMISPOL_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TOTPAMMISPOL_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMMISPOL_MERGE');
    commit;
end if;
end;
/