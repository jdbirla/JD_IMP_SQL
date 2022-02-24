create or replace type APM_DBMASK_GMHIPF_obj as object(

UNIQUE_NUMBER	NUMBER(18,0),
ZWORKPLCE1		VARCHAR2(25 CHAR),
ZWORKPLCE2		VARCHAR2(25 CHAR)
	
);
/  
create or replace type APM_DBMASK_GMHIPF_tab as table of APM_DBMASK_GMHIPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_GMHIPF_pipeline return  APM_DBMASK_GMHIPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 UNIQUE_NUMBER	,
 ZWORKPLCE1	,	
 ZWORKPLCE2		

  from GMHIPF fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_GMHIPF_obj( 
	  
 idx.UNIQUE_NUMBER	,
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
create or replace procedure APM_DBMASK_write_to_GMHIPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_GMHIPF_pipeline)) loop
    v_sql_res := '"'
	
||i.UNIQUE_NUMBER	||'","'
||i.ZWORKPLCE1	||'","'
||i.ZWORKPLCE2	||'"';
	
    UTL_FILE.PUT_LINE(v_file, v_sql_res );
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/
--exec APM_DBMASK_write_to_GMHIPF('IMP_DATA_DIR','GMHIPF.csv');