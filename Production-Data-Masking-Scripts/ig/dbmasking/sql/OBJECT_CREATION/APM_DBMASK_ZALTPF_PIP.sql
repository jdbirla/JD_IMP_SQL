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
ZWORKPLCE2		VARCHAR2(25 CHAR)       ,
BNKACCKEY01             VARCHAR2(20 CHAR) ,
BNKACCKEY02             VARCHAR2(20 CHAR) ,
KANJIGIVNAME            VARCHAR2(60 CHAR) ,
KANJICLTADDR01          VARCHAR2(60 CHAR) ,
KANJICLTADDR02          VARCHAR2(60 CHAR) ,
KANJICLTADDR03          VARCHAR2(60 CHAR) ,
KANJICLTADDR04          VARCHAR2(60 CHAR)
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
 ZWORKPLCE2		,
 BNKACCKEY01	,
 BNKACCKEY02    ,
 KANJIGIVNAME  ,
 KANJICLTADDR01,
 KANJICLTADDR02,
 KANJICLTADDR03,
 KANJICLTADDR04
 
 
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
  idx.ZWORKPLCE2	,
  idx.BNKACCKEY01    ,
  idx.BNKACCKEY02 ,
  idx.KANJIGIVNAME  ,
  idx.KANJICLTADDR01,
  idx.KANJICLTADDR02,
  idx.KANJICLTADDR03,
  idx.KANJICLTADDR04
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
||i.ZWORKPLCE2||'","'
||i.BNKACCKEY01||'","'
||i.BNKACCKEY02||'","'
||i.KANJIGIVNAME||'","'  
||i.KANJICLTADDR01||'","'
||i.KANJICLTADDR02||'","'
||i.KANJICLTADDR03||'","'
||i.KANJICLTADDR04||'"';

    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/
--exec APM_DBMASK_write_to_ZALTPF('IMP_DATA_DIR','ZALTPF.csv');