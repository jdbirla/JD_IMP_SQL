drop table TITDMGCLTRNHIS_TEMP;
/
CREATE TABLE "TITDMGCLTRNHIS_TEMP" 
(
"RECIDXCLHIS"		NUMBER(38)			,
"LSURNAME"      VARCHAR2(60 CHAR) ,
"LGIVNAME"     VARCHAR2(60 CHAR) ,
"ZKANAGIVNAME"  VARCHAR2(60 CHAR) ,
"ZKANASURNAME"  VARCHAR2(60 CHAR) ,
"CLTADDR01"     VARCHAR2(60 CHAR) ,
"CLTADDR02"     VARCHAR2(60 CHAR) ,
"CLTADDR03"     VARCHAR2(60 CHAR) ,
"ZKANADDR01"    VARCHAR2(30 CHAR) ,
"ZKANADDR02"           VARCHAR2(30 CHAR),
"CLTPHONE01"            VARCHAR2(16 CHAR) ,
"CLTPHONE02"            VARCHAR2(16 CHAR) ,
"ZWORKPLCE"             VARCHAR2(25 CHAR) 
);
/
create index TITDMGCLTRNHIS_tempIDX on TITDMGCLTRNHIS_temp(RECIDXCLHIS); 
/
create or replace procedure  APM_DBMASK_MERG_TITDMGCLTRNHIS
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from TITDMGCLTRNHIS_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_TITDMGCLTRNHIS_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGCLTRNHIS_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_TITDMGCLTRNHIS_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_TITDMGCLTRNHIS_MERGE','VM1DTA','TITDMGCLTRNHIS_TEMP','RECIDXCLHIS',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM TITDMGCLTRNHIS_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_TITDMGCLTRNHIS_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO TITDMGCLTRNHIS@stagedblink a USING 
    (select * from TITDMGCLTRNHIS_TEMP where RECIDXCLHIS between :start_id and :end_id) b
    ON (a.RECIDXCLHIS = b.RECIDXCLHIS)
    WHEN MATCHED THEN UPDATE SET	
A.LSURNAME      = B.LSURNAME,    
A.LGIVNAME      = B.LGIVNAME ,   
A.ZKANAGIVNAME  = B.ZKANAGIVNAME,
A.ZKANASURNAME  = B.ZKANASURNAME,
A.CLTADDR01     = B.CLTADDR01,   
A.CLTADDR02     = B.CLTADDR02 ,  
A.CLTADDR03     = B.CLTADDR03  , 
A.ZKANADDR01    = B.ZKANADDR01  ,
A.ZKANADDR02    = B.ZKANADDR02  ,
A.CLTPHONE01 = B.CLTPHONE01,
A.CLTPHONE02=  B.CLTPHONE02 ,
A.ZWORKPLCE  = B.ZWORKPLCE' ;
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_TITDMGCLTRNHIS_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_TITDMGCLTRNHIS_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_TITDMGCLTRNHIS_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_TITDMGCLTRNHIS_MERGE');
    commit;
end if;
end;
/