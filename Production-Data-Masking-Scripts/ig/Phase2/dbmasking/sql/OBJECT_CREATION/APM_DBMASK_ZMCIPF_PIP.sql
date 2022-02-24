create or replace type APM_DBMASK_ZMCIPF_obj as object(
 UNIQUE_NUMBER      NUMBER(18,0), 
 CRDTCARD            VARCHAR2(20 CHAR),
BANKACCKEY01      VARCHAR2(20 CHAR),
BANKACCDSC01           VARCHAR2(30 CHAR),
BANKACCDSC02           VARCHAR2(30 CHAR) 
);
/  
create or replace type APM_DBMASK_ZMCIPF_tab as table of APM_DBMASK_ZMCIPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_ZMCIPF_pipeline return  APM_DBMASK_ZMCIPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
UNIQUE_NUMBER,
CRDTCARD,
BANKACCKEY01,
BANKACCDSC01,
BANKACCDSC02            
  from ZMCIPF fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_ZMCIPF_obj( 
idx.UNIQUE_NUMBER,
idx.CRDTCARD,
idx.BANKACCKEY01,
idx.BANKACCDSC01,
idx.BANKACCDSC02          
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_write_to_ZMCIPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_ZMCIPF_pipeline)) loop
    v_sql_res := '"'||i.UNIQUE_NUMBER||'","' ||i.CRDTCARD ||'","' ||i.BANKACCKEY01||'","' ||i.BANKACCDSC01||'","'||i.BANKACCDSC02||'"';	
   -- UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/