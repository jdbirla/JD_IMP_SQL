drop table ZCLNPF_TEMP;
/
CREATE TABLE "ZCLNPF_TEMP" 
(
          "UNIQUE_NUMBER"  NUMBER(18,0), 
	"LSURNAME"	     VARCHAR2(60 CHAR), 
        "LGIVNAME"	     VARCHAR2(60 CHAR), 
        "ZKANASNM"	     VARCHAR2(60 CHAR), 
        "ZKANAGNM"	     VARCHAR2(60 CHAR), 
        "ZKANADDR01"	 VARCHAR2(60 CHAR), 
        "ZKANADDR02"	 VARCHAR2(60 CHAR), 
        "ZKANADDR03"	 VARCHAR2(60 CHAR), 
        "ZKANADDR04"	 VARCHAR2(60 CHAR), 
        "CLTADDR01"	     VARCHAR2(50 CHAR), 
        "CLTADDR02"	     VARCHAR2(50 CHAR), 
        "CLTADDR03"	     VARCHAR2(50 CHAR), 
        "CLTADDR04"	     VARCHAR2(50 CHAR), 
        "CLTPHONE01"	 VARCHAR2(16 CHAR),
        "CLTPHONE02"	 VARCHAR2(16 CHAR),
        "ZWORKPLCE"	     VARCHAR2(25 CHAR)
 );
/		  
create index ZCLNPF_tempIDX on ZCLNPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_ZCLNPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;



begin

select count(1) into cont1 from ZCLNPF_TEMP;

if(cont1 >0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_ZCLNPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZCLNPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_ZCLNPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_ZCLNPF_MERGE','VM1DTA','ZCLNPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM ZCLNPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_ZCLNPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO ZCLNPF a USING 
    (select * from ZCLNPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
       A.LSURNAME=B.LSURNAME,
        A.LGIVNAME=B.LGIVNAME,
        A.ZKANASNM=B.ZKANASNM,
        A.ZKANAGNM=B.ZKANAGNM,
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
        A.ZWORKPLCE=B.ZWORKPLCE';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_ZCLNPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_ZCLNPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_ZCLNPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZCLNPF_MERGE');
    commit;
end if;
end;
/