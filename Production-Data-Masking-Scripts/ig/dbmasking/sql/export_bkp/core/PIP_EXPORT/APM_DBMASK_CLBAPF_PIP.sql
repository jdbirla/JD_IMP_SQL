create or replace type APM_DBMASK_CLBAPF_obj as object(
UNIQUE_NUMBER	NUMBER(18,0)  ,
BANKACCKEY		VARCHAR2(20 CHAR),
BANKACCDSC		VARCHAR2(30 CHAR)      
	
);
/  
create or replace type APM_DBMASK_CLBAPF_tab as table of APM_DBMASK_CLBAPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_CLBAPF_pipeline return  APM_DBMASK_CLBAPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
  
  UNIQUE_NUMBER,	
  BANKACCKEY	,	
  BANKACCDSC		
  
 
  from CLBAPF fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_CLBAPF_obj(

  idx.UNIQUE_NUMBER,	
  idx.BANKACCKEY	,	
  idx.BANKACCDSC		
  

	  
 
   
	 
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_CLBAPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_CLBAPF_pipeline)) loop
    v_sql_res := '"'
	
||i.UNIQUE_NUMBER||'","'
||i.BANKACCKEY	||'","'
||i.BANKACCDSC	||'"';
    UTL_FILE.PUT_LINE(v_file, v_sql_res );
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASK_write_to_CLBAPF('IMP_DATA_DIR','CLBAPF.csv');