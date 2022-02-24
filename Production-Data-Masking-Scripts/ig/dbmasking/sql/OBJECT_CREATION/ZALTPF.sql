drop table ZALTPF_TEMP;
/
CREATE TABLE "ZALTPF_TEMP" 
(  
		"UNIQUE_NUMBER"		  NUMBER(18,0)	,
		"CRDTCARD"			VARCHAR2(20 CHAR),
		"ZKANASNM"			VARCHAR2(60 CHAR),
		"ZKANAGNM"			VARCHAR2(60 CHAR),
		"KANJISURNAME"	    VARCHAR2(60 CHAR)    ,
		"ZKANADDR01"		VARCHAR2(60 CHAR),
		"ZKANADDR02"		VARCHAR2(60 CHAR),
		"ZKANADDR03"		VARCHAR2(60 CHAR),
		"ZKANADDR04"		VARCHAR2(60 CHAR),
		"CLTPHONE01"		VARCHAR2(16 CHAR),
		"ZWORKPLCE1"		VARCHAR2(25 CHAR),
		"ZWORKPLCE2"		VARCHAR2(25 CHAR),
		"BNKACCKEY01"             VARCHAR2(20 CHAR),
		"BNKACCKEY02"             VARCHAR2(20 CHAR),
		"KANJIGIVNAME"            VARCHAR2(60 CHAR) ,
		"KANJICLTADDR01"          VARCHAR2(60 CHAR) ,
		"KANJICLTADDR02"          VARCHAR2(60 CHAR) ,
		"KANJICLTADDR03"          VARCHAR2(60 CHAR) ,
		"KANJICLTADDR04"          VARCHAR2(60 CHAR)
);
/
create index ZALTPF_tempIDX on ZALTPF_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_ZALTPF
authid current_user
as 

l_sql_stmt varchar2(2000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from ZALTPF_TEMP;

if(cont1>0)then

SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_ZALTPF_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZALTPF_MERGE');
END  IF;

    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_ZALTPF_MERGE');
   DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_ZALTPF_MERGE','VM1DTA','ZALTPF_TEMP','UNIQUE_NUMBER',41000);
        
   /* l_chunk_stmt:= 'SELECT start_id, end_id FROM ZALTPF_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_ZALTPF_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      );  */
        
    l_sql_stmt := 'MERGE  INTO ZALTPF a USING 
    (select * from ZALTPF_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET						
		A.CRDTCARD=B.CRDTCARD,
        A.ZKANASNM=B.ZKANASNM,
        A.ZKANAGNM=B.ZKANAGNM,
        A.KANJISURNAME=B.KANJISURNAME,
        A.ZKANADDR01=B.ZKANADDR01,
        A.ZKANADDR02=B.ZKANADDR02,
        A.ZKANADDR03=B.ZKANADDR03,
        A.ZKANADDR04=B.ZKANADDR04,
        A.CLTPHONE01=B.CLTPHONE01,
        A.ZWORKPLCE1=B.ZWORKPLCE1,
        A.ZWORKPLCE2=B.ZWORKPLCE2,
	A.BNKACCKEY01 =B.BNKACCKEY01,
	A.BNKACCKEY02 = B.BNKACCKEY02,
	A.KANJIGIVNAME  =B.KANJIGIVNAME,
	A.KANJICLTADDR01=B.KANJICLTADDR01,
	A.KANJICLTADDR02=B.KANJICLTADDR02,
	A.KANJICLTADDR03=B.KANJICLTADDR03,
	A.KANJICLTADDR04=B.KANJICLTADDR04';
        
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_ZALTPF_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_ZALTPF_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_ZALTPF_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_ZALTPF_MERGE');
    commit;
end if;
end;
/