drop table TITPAMVALCHKDR_TEMP;
/
CREATE TABLE "TITPAMVALCHKDR_TEMP" 
(
		"RECIDXVLDRSL"        NUMBER(38,0),
		"CURMEMIDNUM"            VARCHAR2(70 CHAR),
		"KANANME"                VARCHAR2(51 CHAR),
		"NWMEMIDNUM"             VARCHAR2(70 CHAR)
);
/
create index TITPAMVALCHKDR_tempIDX on TITPAMVALCHKDR_temp(RECIDXVLDRSL); 
/
create or replace procedure  APM_DBMASK_MERG_TITPAMVALCHKDR
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITPAMVALCHKDR_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITPAMVALCHKDR_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITPAMVALCHKDR_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITPAMVALCHKDR_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITPAMVALCHKDR_MERGE','VM1DTA','TITPAMVALCHKDR_TEMP','RECIDXVLDRSL',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITPAMVALCHKDR_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITPAMVALCHKDR_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITPAMVALCHKDR@stagedblink a USING 
    (select * from TITPAMVALCHKDR_TEMP where RECIDXVLDRSL between :start_id and :end_id) b
    ON (a.RECIDXVLDRSL = b.RECIDXVLDRSL)
    WHEN MATCHED THEN UPDATE SET					
       A.CURMEMIDNUM = B.CURMEMIDNUM,
	A.KANANME=B.KANANME,
	A.NWMEMIDNUM=B.NWMEMIDNUM';
	   
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITPAMVALCHKDR_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITPAMVALCHKDR_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITPAMVALCHKDR_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITPAMVALCHKDR_MERGE');
    commit;
end if;
end;
/