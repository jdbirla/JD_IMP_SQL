drop table TOTPAMMISCLN_TEMP;
/
CREATE TABLE "TOTPAMMISCLN_TEMP" 
(
	"RECIDXCLNT"     NUMBER(38,0),
	"ZKANASNM"               VARCHAR2(60 CHAR),
	"ZKANAGNM"               VARCHAR2(60 CHAR),
	"LSURNAME"              VARCHAR2(60 CHAR),
	"LGIVNAME"            VARCHAR2(60 CHAR),
	"ZKANADDR01"            VARCHAR2(60 CHAR),
	"ZKANADDR02"            VARCHAR2(60 CHAR),
	"ZKANADDR03"            VARCHAR2(60 CHAR),
	"ZKANADDR04"             VARCHAR2(60 CHAR),
	"CLTADDR01"             VARCHAR2(50 CHAR),
	"CLTADDR02"             VARCHAR2(50 CHAR),
	"CLTADDR03"             VARCHAR2(50 CHAR),
	"CLTADDR04"            VARCHAR2(50 CHAR),
	"CLTPHONE01"             VARCHAR2(16 CHAR),
	"CLTPHONE02"             VARCHAR2(16 CHAR),
	"WORKPLCE"               VARCHAR2(25 CHAR)		
);
/
create index TOTPAMMISCLN_tempIDX on TOTPAMMISCLN_temp(RECIDXCLNT); 
/
create or replace procedure  APM_DBMASK_MERG_TOTPAMMISCLN
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TOTPAMMISCLN_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TOTPAMMISCLN_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMMISCLN_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TOTPAMMISCLN_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TOTPAMMISCLN_MERGE','VM1DTA','TOTPAMMISCLN_TEMP','RECIDXCLNT',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TOTPAMMISCLN_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TOTPAMMISCLN_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TOTPAMMISCLN@stagedblink a USING 
    (select * from TOTPAMMISCLN_TEMP where RECIDXCLNT between :start_id and :end_id) b
    ON (a.RECIDXCLNT = b.RECIDXCLNT)
    WHEN MATCHED THEN UPDATE SET					
       A.ZKANASNM = B.ZKANASNM,
	A.ZKANAGNM=B.ZKANAGNM,
	A.LSURNAME=B.LSURNAME,
	A.LGIVNAME=B.LGIVNAME,
	A.ZKANADDR01=B.ZKANADDR01,
	A.ZKANADDR02=B.ZKANADDR02,
	A.ZKANADDR03=B.ZKANADDR03,
	A.ZKANADDR04=B.ZKANADDR04,
	A.CLTADDR01=B.CLTADDR01,
	A.CLTADDR02=B.CLTADDR02,
	A.CLTADDR03=B.CLTADDR03,
	A.CLTADDR04=B.CLTADDR04,
	A.CLTPHONE01=B.CLTPHONE01,
	A.CLTPHONE02=B.CLTPHONE02,
	A.WORKPLCE=B.WORKPLCE';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TOTPAMMISCLN_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TOTPAMMISCLN_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TOTPAMMISCLN_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMMISCLN_MERGE');
    commit;
end if;
end;
/