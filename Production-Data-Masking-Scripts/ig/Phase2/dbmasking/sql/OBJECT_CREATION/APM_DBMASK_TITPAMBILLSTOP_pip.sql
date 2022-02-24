create or replace type APM_DBMASK_TITPAMBILLSTOP_obj as object(
RECIDXBILLSTOP       NUMBER(38,0), 
MEMSHIPNO            VARCHAR2(70 CHAR)
);
/  
create or replace type APM_DBMASK_TITPAMBILLSTOP_tab as table of APM_DBMASK_TITPAMBILLSTOP_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TITPAMBILLSTOP_pipe return  APM_DBMASK_TITPAMBILLSTOP_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
RECIDXBILLSTOP,
MEMSHIPNO          
  from TITPAMBILLSTOP@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TITPAMBILLSTOP_obj( 
idx.RECIDXBILLSTOP,
idx.MEMSHIPNO        
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_writeto_TITPAMBLSTP(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TITPAMBILLSTOP_pipe)) loop
    v_sql_res := '"'||i.RECIDXBILLSTOP||'","' ||i.MEMSHIPNO ||'"';	
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/