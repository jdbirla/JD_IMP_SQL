create or replace type APM_DBMASK_TOTPAMVALCHKD_obj as object(
RECIDXVALCHK        NUMBER(38,0),
MEMIDNUM             VARCHAR2(70 CHAR), 
KANANME               VARCHAR2(121 CHAR),
ZENSPCD01             VARCHAR2(70 CHAR), 
ZENSPCD02             VARCHAR2(70 CHAR),
KANJINME              VARCHAR2(121 CHAR),
CLTPHONE01            VARCHAR2(16 CHAR),
CLTPHONE02            VARCHAR2(16 CHAR),
KANJICLTADDR          VARCHAR2(150 CHAR)
);
/  
create or replace type APM_DBMASK_TOTPAMVALCHKD_tab as table of APM_DBMASK_TOTPAMVALCHKD_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TOTPAMVALCHKD_pipe return  APM_DBMASK_TOTPAMVALCHKD_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
RECIDXVALCHK,
MEMIDNUM, 
KANANME,
ZENSPCD01, 
ZENSPCD02,
KANJINME,
CLTPHONE01,
CLTPHONE02,
KANJICLTADDR           
  from TOTPAMVALCHKD@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TOTPAMVALCHKD_obj( 
idx.RECIDXVALCHK,
idx.MEMIDNUM,
idx.KANANME,
idx.ZENSPCD01,
idx.ZENSPCD02,
idx.KANJINME,
idx.CLTPHONE01,
idx.CLTPHONE02,
idx.KANJICLTADDR     
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_TOTPAMVCKD(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TOTPAMVALCHKD_pipe)) loop
    v_sql_res := '"'||i.RECIDXVALCHK||'","' ||i.MEMIDNUM ||'","' ||i.KANANME||'","' ||i.ZENSPCD01||'","'||i.ZENSPCD02||'","' ||i.KANJINME||'","' ||i.CLTPHONE01||'","'||i.CLTPHONE02||'","' ||i.KANJICLTADDR||'"';	
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/