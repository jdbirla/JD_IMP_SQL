drop table AUDIT_CLNT_TEMP;
/
CREATE TABLE "AUDIT_CLNT_TEMP" 
(
        "UNIQUE_NUMBER"			NUMBER(  18,0)			,
		"OLDSURNAME"			VARCHAR2(60 CHAR) ,
		"OLDGIVNAME"			VARCHAR2(60 CHAR) ,
		"OLDCLTPHONE01"		    VARCHAR2(16 BYTE)         ,
		"OLDCLTPHONE02"	        VARCHAR2(16 BYTE)             ,
		"NEWSURNAME"			VARCHAR2(60 CHAR) ,
		"NEWGIVNAME"		    VARCHAR2(60 CHAR)     ,
		"NEWCLTPHONE01"	        VARCHAR2(16 BYTE)             ,
		"NEWCLTPHONE02"	        VARCHAR2(16 BYTE)     ,
		"OLDCLTADDR01"       VARCHAR2(50),         
		"OLDCLTADDR02"       VARCHAR2(50),         
		"OLDCLTADDR03"       VARCHAR2(50),         
		"OLDCLTADDR04"       VARCHAR2(50),         
		"OLDCLTADDR05"       VARCHAR2(50),     
		"NEWCLTADDR01"       VARCHAR2(50),         
		"NEWCLTADDR02"       VARCHAR2(50),         
		"NEWCLTADDR03"       VARCHAR2(50),         
		"NEWCLTADDR04"       VARCHAR2(50),         
		"NEWCLTADDR05"       VARCHAR2(50)         
);
/			  
create index AUDIT_CLNT_tempIDX on AUDIT_CLNT_temp(unique_number); 
/
create or replace procedure  APM_DBMASK_MERG_AUDIT_CLNT
authid current_user
as 

l_sql_stmt varchar2(4000 char);
l_status NUMBER;
l_chunk_stmt varchar2(2000 char);
cont number;
cont1 number;


begin

select count(1) into cont1 from AUDIT_CLNT_TEMP;

if(cont1 >0)Then

Delete from audit_clnt_temp a where rowid not in (select max(rowid) from audit_clnt_temp b where b.unique_number=a.unique_number);
SELECT COUNT(*)
INTO cont
FROM user_parallel_execute_tasks
WHERE task_name = 'UPDATE_AUDIT_CLNT_MERGE';

IF cont > 0 THEN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_AUDIT_CLNT_MERGE');
END  IF;
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('UPDATE_AUDIT_CLNT_MERGE');
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('UPDATE_AUDIT_CLNT_MERGE','VM1DTA','AUDIT_CLNT_TEMP','UNIQUE_NUMBER',5000);
        
    /*l_chunk_stmt:= 'SELECT start_id, end_id FROM AUDIT_CLNT_CHUNKS';
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL (
    task_name => 'UPDATE_AUDIT_CLNT_MERGE'
   , sql_stmt        => l_chunk_stmt
   , by_rowid       => FALSE
                      ); */
        
    l_sql_stmt := 'MERGE  INTO AUDIT_CLNT a USING 
    (select * from AUDIT_CLNT_TEMP where unique_number between :start_id and :end_id) b
    ON (a.UNIQUE_NUMBER = b.UNIQUE_NUMBER)
    WHEN MATCHED THEN UPDATE SET					
    		A.OLDSURNAME=B.OLDSURNAME,
        A.OLDGIVNAME=B.OLDGIVNAME,
        A.OLDCLTPHONE01=B.OLDCLTPHONE01,
        A.OLDCLTPHONE02=B.OLDCLTPHONE02,
        A.NEWSURNAME=B.NEWSURNAME,
        A.NEWGIVNAME=B.NEWGIVNAME,
        A.NEWCLTPHONE01=B.NEWCLTPHONE01,
        A.NEWCLTPHONE02=B.NEWCLTPHONE02,
		A.OLDCLTADDR01=B.OLDCLTADDR01,
		A.OLDCLTADDR02=B.OLDCLTADDR02,
		A.OLDCLTADDR03=B.OLDCLTADDR03,
		A.OLDCLTADDR04=B.OLDCLTADDR04,
		A.OLDCLTADDR05=B.OLDCLTADDR05,
		A.NEWCLTADDR01=B.NEWCLTADDR01,
		A.NEWCLTADDR02=B.NEWCLTADDR02,
		A.NEWCLTADDR03=B.NEWCLTADDR03,
		A.NEWCLTADDR04=B.NEWCLTADDR04,
		A.NEWCLTADDR05=B.NEWCLTADDR05';
    
    dbms_parallel_execute.run_task(
        task_name        =>'UPDATE_AUDIT_CLNT_MERGE',
        sql_stmt         => l_sql_stmt,
        language_flag    => dbms_sql.native,
        parallel_level   => 24); ---Keep this number low may be 2 or max 5.
    
    l_status := dbms_parallel_execute.task_status('UPDATE_AUDIT_CLNT_MERGE');
    DBMS_OUTPUT.PUT_LINE('UPDATE_AUDIT_CLNT_MERGE completed! Status:'||l_status);
    DBMS_PARALLEL_EXECUTE.DROP_TASK('UPDATE_AUDIT_CLNT_MERGE');
    commit;
end if;
end;
/