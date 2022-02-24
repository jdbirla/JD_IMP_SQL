create or replace type APM_DBMASK_TITDMGPOL_obj as object(
RECIDXPHIST		NUMBER(38)			,
CRDTCARD			VARCHAR2(16 CHAR) ,
BNKACCKEY01			VARCHAR2(20 CHAR)  
);
/  
create or replace type APM_DBMASK_TITDMGPOL_tab as table of APM_DBMASK_TITDMGPOL_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TITDMGPOL_pip return  APM_DBMASK_TITDMGPOL_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
 RECIDXPHIST  ,
 CRDTCARD	,
 BNKACCKEY01	
 
  from TITDMGPOLTRNH@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TITDMGPOL_obj( 
idx.RECIDXPHIST    ,
idx.CRDTCARD	     ,
idx.BNKACCKEY01	     

		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASKwritetoTITDMGPOL(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TITDMGPOL_pip)) loop
    v_sql_res := '"'	||i.RECIDXPHIST  ||'","' ||i.CRDTCARD	 ||'","' ||i.BNKACCKEY01||'"';		
	

    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASKwritetoTITDMGPOL('IMP_DATA_DIR','TITDMGPOL.csv');