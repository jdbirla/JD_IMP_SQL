create or replace type APM_DBMASK_AUDIT_CLEXPF_obj as object(
UNIQUE_NUMBER      NUMBER(18)  ,
OLDFAXNO           CHAR(16)    ,
NEWFAXNO           CHAR(16) ,
NEWRMBLPHONE       CHAR(16)
);
/  
create or replace type APM_DBMASK_AUDIT_CLEXPF_tab as table of APM_DBMASK_AUDIT_CLEXPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_AUDIT_CLEXPF_pip return  APM_DBMASK_AUDIT_CLEXPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
    select 
    UNIQUE_NUMBER,
		OLDFAXNO     ,
		NEWFAXNO    ,
		NEWRMBLPHONE
    from AUDIT_CLEXPF fetch first 100 percent rows only 
 )loop
    pipe row(
      APM_DBMASK_AUDIT_CLEXPF_obj( 
      idx.UNIQUE_NUMBER,
      idx.OLDFAXNO     ,
      idx.NEWFAXNO,
	  idx.NEWRMBLPHONE
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_writetoAUDIT_CLEXPF(p_dir in VARCHAR2, p_fn in varchar2)  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(2000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w');
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_AUDIT_CLEXPF_pip)) loop
    v_sql_res := '"'||i.UNIQUE_NUMBER||'","'||i.OLDFAXNO||'","'||i.NEWFAXNO||'","'||i.NEWRMBLPHONE||'"';
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res);
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASK_writetoAUDIT_CLEXPF('IMP_DATA_DIR','AUDIT_CLEXPF.csv');