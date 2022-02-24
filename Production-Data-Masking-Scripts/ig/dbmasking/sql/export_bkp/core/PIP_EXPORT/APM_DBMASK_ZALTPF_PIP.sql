create or replace type APM_DBMASK_ZALTPF_obj as object(
UNIQUE_NUMBER	NUMBER(18,0),
CRDTCARD		VARCHAR2(20 CHAR)       ,
ZKANASNM		VARCHAR2(60 CHAR)       ,
ZKANAGNM		VARCHAR2(60 CHAR)       ,
KANJISURNAME	VARCHAR2(60 CHAR)   ,
ZKANADDR01			VARCHAR2(60 CHAR)       ,
ZKANADDR02		VARCHAR2(60 CHAR)       ,
ZKANADDR03		VARCHAR2(60 CHAR)       ,
ZKANADDR04		VARCHAR2(60 CHAR)       ,
CLTPHONE01		VARCHAR2(16 CHAR)       ,
ZWORKPLCE1		VARCHAR2(25 CHAR)       ,
ZWORKPLCE2		VARCHAR2(25 CHAR)       
	
);
/  
create or replace type APM_DBMASK_ZALTPF_tab as table of APM_DBMASK_ZALTPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_ZALTPF_pipeline return  APM_DBMASK_ZALTPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
 UNIQUE_NUMBER	,
 CRDTCARD		,
 ZKANASNM		,
 ZKANAGNM		,
 KANJISURNAME	,
 ZKANADDR01		,
 ZKANADDR02		,
 ZKANADDR03		,
 ZKANADDR04		,
 CLTPHONE01		,
 ZWORKPLCE1		,
 ZWORKPLCE2		
 
  from ZALTPF fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_ZALTPF_obj( 
  idx.UNIQUE_NUMBER	,
  idx.CRDTCARD		,
  idx.ZKANASNM		,
  idx.ZKANAGNM		,
  idx.KANJISURNAME	,
  idx.ZKANADDR01	,	
  idx.ZKANADDR02	,	
  idx.ZKANADDR03	,	
  idx.ZKANADDR04	,	
  idx.CLTPHONE01	,	
  idx.ZWORKPLCE1	,	
  idx.ZWORKPLCE2	
   
	 
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_ZALTPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_ZALTPF_pipeline)) loop
    v_sql_res := '"'||i.UNIQUE_NUMBER||'","'
||i.CRDTCARD||'","'
||i.ZKANASNM||'","'
||i.ZKANAGNM||'","'
||i.KANJISURNAME||'","'
||i.ZKANADDR01||'","'
||i.ZKANADDR02||'","'
||i.ZKANADDR03||'","'
||i.ZKANADDR04||'","'
||i.CLTPHONE01||'","'
||i.ZWORKPLCE1||'","'
||i.ZWORKPLCE2||'"';
    UTL_FILE.PUT_LINE(v_file, v_sql_res );
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/
--exec APM_DBMASK_write_to_ZALTPF('IMP_DATA_DIR','ZALTPF.csv');