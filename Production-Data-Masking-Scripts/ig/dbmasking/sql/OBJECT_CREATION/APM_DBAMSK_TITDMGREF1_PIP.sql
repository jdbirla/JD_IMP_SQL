create or replace type APM_DBMASK_TITDMGREF1_obj as object(
RECIDXREFB1		NUMBER(38)			,
BANKACOUNT			VARCHAR2(20 CHAR) 

);
/  
create or replace type APM_DBMASK_TITDMGREF1_tab as table of APM_DBMASK_TITDMGREF1_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TITDMGREF1_pip return  APM_DBMASK_TITDMGREF1_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 
 RECIDXREFB1  ,
 BANKACOUNT	
	
  from TITDMGREF1@stagedblink fetch first 100 percent rows only 
  
 
 )loop
    pipe row(
      APM_DBMASK_TITDMGREF1_obj( 
idx.RECIDXREFB1    ,
idx.BANKACOUNT	     
		  )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASKwritetoTITDMGREF1(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TITDMGREF1_pip)) loop
v_sql_res := '"'||i.RECIDXREFB1  ||'","'||i.BANKACOUNT	 ||'"';
 	
	

    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASKwritetoTITDMGREF1('IMP_DATA_DIR','TITDMGREF1.csv');