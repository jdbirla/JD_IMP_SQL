drop table ZMCIPF_TEMP;
/
CREATE TABLE "ZMCIPF_TEMP" 
(
		"UNIQUE_NUMBER"       NUMBER(18,0), 
		"CRDTCARD"            VARCHAR2(20 CHAR),
		"BANKACCKEY01"           VARCHAR2(20 CHAR),
		"BANKACCDSC01"           VARCHAR2(30 CHAR),
		"BANKACCDSC02"           VARCHAR2(30 CHAR) 		
);
/
create index ZMCIPF_tempIDX on ZMCIPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_ZMCIPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from ZMCIPF_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_ZMCIPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZMCIPF_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_ZMCIPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_ZMCIPF_MERGE','VM1DTA','ZMCIPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM ZMCIPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_ZMCIPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO ZMCIPF a USING 
    (select * from ZMCIPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
       A.CRDTCARD = B.CRDTCARD,
	A.BANKACCKEY01=B.BANKACCKEY01,
	A.BANKACCDSC01=B.BANKACCDSC01,
	A.BANKACCDSC02=B.BANKACCDSC02';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_ZMCIPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_ZMCIPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_ZMCIPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZMCIPF_MERGE');
    commit;
end if;
end;
/