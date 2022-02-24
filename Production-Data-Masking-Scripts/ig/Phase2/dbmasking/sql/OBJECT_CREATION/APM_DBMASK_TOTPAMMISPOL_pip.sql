create or replace type APM_DBMASK_TOTPAMMISPOL_obj as object(
RECIDXMEMPOL       NUMBER(38,0),
BANKACCKEY01       VARCHAR2(20 CHAR),
BANKACCKEY02       VARCHAR2(20 CHAR),
ZENSPCD01       VARCHAR2(70 CHAR),
ZENSPCD02       VARCHAR2(70 CHAR)
);
/  
create or replace type APM_DBMASK_TOTPAMMISPOL_tab as table of APM_DBMASK_TOTPAMMISPOL_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TOTPAMMISPOL_pipe return  APM_DBMASK_TOTPAMMISPOL_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
RECIDXMEMPOL,
BANKACCKEY01,
BANKACCKEY02,
ZENSPCD01,
ZENSPCD02            
  from TOTPAMMISPOL@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TOTPAMMISPOL_obj( 
idx.RECIDXMEMPOL,
idx.BANKACCKEY01,
idx.BANKACCKEY02,
idx.ZENSPCD01,
idx.ZENSPCD02          
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_TOTPAMSPOL(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TOTPAMMISPOL_pipe)) loop
    v_sql_res := '"'||i.RECIDXMEMPOL||'","' ||i.BANKACCKEY01 ||'","' ||i.BANKACCKEY02||'","' ||i.ZENSPCD01||'","'||i.ZENSPCD02||'"';	
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/