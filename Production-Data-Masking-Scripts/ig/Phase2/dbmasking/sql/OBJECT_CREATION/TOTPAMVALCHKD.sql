drop table TOTPAMVALCHKD_TEMP;
/
CREATE TABLE "TOTPAMVALCHKD_TEMP" 
(
	"RECIDXVALCHK"        NUMBER(38,0),
	"MEMIDNUM"             VARCHAR2(70 CHAR), 
	"KANANME"               VARCHAR2(121 CHAR),
	"ZENSPCD01"             VARCHAR2(70 CHAR), 
	"ZENSPCD02"             VARCHAR2(70 CHAR),
	"KANJINME"              VARCHAR2(121 CHAR),
	"CLTPHONE01"            VARCHAR2(16 CHAR),
	"CLTPHONE02"            VARCHAR2(16 CHAR),
	"KANJICLTADDR"          VARCHAR2(150 CHAR)	
);
/
create index TOTPAMVALCHKD_tempIDX on TOTPAMVALCHKD_temp(RECIDXVALCHK); 
/
create or replace procedure  APM_DBMASK_MERG_TOTPAMVALCHKD
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TOTPAMVALCHKD_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TOTPAMVALCHKD_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMVALCHKD_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TOTPAMVALCHKD_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TOTPAMVALCHKD_MERGE','VM1DTA','TOTPAMVALCHKD_TEMP','RECIDXVALCHK',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TOTPAMVALCHKD_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TOTPAMVALCHKD_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TOTPAMVALCHKD@stagedblink a USING 
    (select * from TOTPAMVALCHKD_TEMP where RECIDXVALCHK between :start_id and :end_id) b
    ON (a.RECIDXVALCHK = b.RECIDXVALCHK)
    WHEN MATCHED THEN UPDATE SET					
       A.MEMIDNUM = B.MEMIDNUM,
	A.KANANME=B.KANANME,
	A.ZENSPCD01=B.ZENSPCD01,
	A.ZENSPCD02=B.ZENSPCD02,
	A.KANJINME=B.KANJINME,
	A.CLTPHONE01=B.CLTPHONE01,
	A.CLTPHONE02=B.CLTPHONE02,
	A.KANJICLTADDR=B.KANJICLTADDR';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TOTPAMVALCHKD_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TOTPAMVALCHKD_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TOTPAMVALCHKD_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TOTPAMVALCHKD_MERGE');
    commit;
end if;
end;
/