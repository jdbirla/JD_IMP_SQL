create or replace type APM_DBMASK_CLEXPF_obj as object(

UNIQUE_NUMBER	   NUMBER(18,0),
FAXNO	        VARCHAR2(16 CHAR),
RINTERNET		VARCHAR2(50 CHAR),
RINTERNET2			VARCHAR2(50 CHAR),
RMBLPHONE              VARCHAR2(16 CHAR)
);
/  
create or replace type APM_DBMASK_CLEXPF_tab as table of APM_DBMASK_CLEXPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_CLEXPF_pipeline return  APM_DBMASK_CLEXPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
 UNIQUE_NUMBER	,
 FAXNO	        ,
 RINTERNET		,
 RINTERNET2	,
 RMBLPHONE 
 
 
 
  from CLEXPF fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_CLEXPF_obj( 
	  
	  
	   idx.UNIQUE_NUMBER	,
	   idx.FAXNO	        ,
	   idx.RINTERNET		,
	   idx.RINTERNET2	,	
	   idx.RMBLPHONE
	 
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_CLEXPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_CLEXPF_pipeline)) loop
    v_sql_res := '"'
||i.UNIQUE_NUMBER	||'","'
||i.FAXNO	        ||'","'
||i.RINTERNET		||'","'
||i.RINTERNET2		||'","'
||i.RMBLPHONE || '"';

  --  UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASK_write_to_CLEXPF('IMP_DATA_DIR','CLEXPF.csv');