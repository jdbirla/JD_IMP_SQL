create or replace type APM_DBMASK_TOTPAMMISCLN_obj as object(
 RECIDXCLNT     NUMBER(38,0),
ZKANASNM               VARCHAR2(60 CHAR),
ZKANAGNM               VARCHAR2(60 CHAR),
LSURNAME              VARCHAR2(60 CHAR),
LGIVNAME            VARCHAR2(60 CHAR),
ZKANADDR01            VARCHAR2(60 CHAR),
ZKANADDR02            VARCHAR2(60 CHAR),
ZKANADDR03            VARCHAR2(60 CHAR),
ZKANADDR04             VARCHAR2(60 CHAR),
CLTADDR01             VARCHAR2(50 CHAR),
CLTADDR02             VARCHAR2(50 CHAR),
CLTADDR03             VARCHAR2(50 CHAR),
CLTADDR04            VARCHAR2(50 CHAR),
CLTPHONE01             VARCHAR2(16 CHAR),
CLTPHONE02             VARCHAR2(16 CHAR),
WORKPLCE               VARCHAR2(25 CHAR)	
);
/  
create or replace type APM_DBMASK_TOTPAMMISCLN_tab as table of APM_DBMASK_TOTPAMMISCLN_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TOTPAMMISCLN_pipe return  APM_DBMASK_TOTPAMMISCLN_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
RECIDXCLNT,
ZKANASNM,
ZKANAGNM,
LSURNAME,
LGIVNAME,
ZKANADDR01,
ZKANADDR02,
ZKANADDR03,
ZKANADDR04,
CLTADDR01,
CLTADDR02,
CLTADDR03,
CLTADDR04,
CLTPHONE01, 
CLTPHONE02,
WORKPLCE             
  from TOTPAMMISCLN@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TOTPAMMISCLN_obj( 
idx.RECIDXCLNT,
idx.ZKANASNM,
idx.ZKANAGNM,
idx.LSURNAME,
idx.LGIVNAME,
idx.ZKANADDR01,
idx.ZKANADDR02,
idx.ZKANADDR03,
idx.ZKANADDR04,
idx.CLTADDR01,
idx.CLTADDR02,
idx.CLTADDR03,
idx.CLTADDR04,
idx.CLTPHONE01,
idx.CLTPHONE02,
idx.WORKPLCE        
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_TOTPAMSCLN(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TOTPAMMISCLN_pipe)) loop
    v_sql_res := '"'||i.RECIDXCLNT||'","' ||i.ZKANASNM ||'","' ||i.ZKANAGNM||'","' ||i.LSURNAME||'","'||i.LGIVNAME||'","'||i.ZKANADDR01||'","' ||i.ZKANADDR02||'","' ||i.ZKANADDR03||'","' ||i.ZKANADDR04||'","'||i.CLTADDR01||'","'||i.CLTADDR02||'","'||i.CLTADDR03||'","' ||i.CLTADDR04||'","' ||i.CLTPHONE01||'","' ||i.CLTPHONE02||'","'||i.WORKPLCE||'"';	
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/