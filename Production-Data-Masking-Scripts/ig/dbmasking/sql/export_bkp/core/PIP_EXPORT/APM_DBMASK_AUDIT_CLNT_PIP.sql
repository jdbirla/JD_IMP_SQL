create or replace type APM_DBMASK_AUDIT_CLNT_obj as object(
UNIQUE_NUMBER		NUMBER(18,0)			,
OLDSURNAME			VARCHAR2(60 CHAR) ,
OLDGIVNAME			VARCHAR2(60 CHAR) ,
OLDCLTPHONE01		VARCHAR2(16 BYTE)         ,
OLDCLTPHONE02	  VARCHAR2(16 BYTE)             ,
NEWSURNAME			VARCHAR2(60 CHAR) ,
NEWGIVNAME		VARCHAR2(60 CHAR)     ,
NEWCLTPHONE01	VARCHAR2(16 BYTE)             ,
NEWCLTPHONE02	VARCHAR2(16 BYTE)             
	
);
/  
create or replace type APM_DBMASK_AUDIT_CLNT_tab as table of APM_DBMASK_AUDIT_CLNT_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_AUDIT_CLNT_pipeline return  APM_DBMASK_AUDIT_CLNT_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
 UNIQUE_NUMBER    ,
OLDSURNAME	     ,
OLDGIVNAME	     ,
OLDCLTPHONE01    ,
OLDCLTPHONE02    ,
NEWSURNAME	     ,
NEWGIVNAME	     ,
NEWCLTPHONE01    ,
NEWCLTPHONE02    
 
  from AUDIT_CLNT fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_AUDIT_CLNT_obj( 
idx.UNIQUE_NUMBER    ,
idx.OLDSURNAME	     ,
idx.OLDGIVNAME	     ,
idx.OLDCLTPHONE01    ,
idx.OLDCLTPHONE02    ,
idx.NEWSURNAME	     ,
idx.NEWGIVNAME	     ,
idx.NEWCLTPHONE01    ,
idx.NEWCLTPHONE02    
   
	 
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_AUDIT_CLNT(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_AUDIT_CLNT_pipeline)) loop
    v_sql_res := '"'

	||i.UNIQUE_NUMBER    ||'","'
||i.OLDSURNAME	     ||'","'
||i.OLDGIVNAME	     ||'","'
||i.OLDCLTPHONE01    ||'","'
||i.OLDCLTPHONE02    ||'","'
||i.NEWSURNAME	     ||'","'
||i.NEWGIVNAME	     ||'","'
||i.NEWCLTPHONE01    ||'","'
||i.NEWCLTPHONE02    ||'"';

    UTL_FILE.PUT_LINE(v_file, v_sql_res );
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASK_write_to_AUDIT_CLNT('IMP_DATA_DIR','AUDIT_CLNT.csv');