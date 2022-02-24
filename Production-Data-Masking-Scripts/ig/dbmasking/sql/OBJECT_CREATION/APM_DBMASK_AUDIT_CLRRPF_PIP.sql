create or replace type APM_DBMASK_AUDIT_CLRRPF_obj as object(
	   UNIQUE_NUMBER	   NUMBER(18,0)				,
            OLDBANKKEY	     		VARCHAR2(10 CHAR),
    	 OLDFORENUM	     		VARCHAR2(20 CHAR),
NEWBANKKEY	     		VARCHAR2(10 CHAR),
  NEWFORENUM			VARCHAR2(20 CHAR)        
     );
/   
create or replace type APM_DBMASK_AUDIT_CLRRPF_tab as table of APM_DBMASK_AUDIT_CLRRPF_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_AUDIT_CLRRPF_pip return  APM_DBMASK_AUDIT_CLRRPF_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 UNIQUE_NUMBER	,
substr(OLDFORENUM,1,10) as OLDBANKKEY,
  	  substr(OLDFORENUM,11)as OLDFORENUM,
      substr(NEWFORENUM,1,10) as NEWBANKKEY,
  	  substr(NEWFORENUM,11)as NEWFORENUM
 from AUDIT_CLRRPF where TRIM(OLDCLRRROLE) = 'CB' or TRIM(newCLRRROLE) = 'CB' fetch first 100 percent rows only 
)loop
    pipe row(
      APM_DBMASK_AUDIT_CLRRPF_obj( 
 
  idx.UNIQUE_NUMBER	,
  idx.OLDBANKKEY,
 idx.OLDFORENUM		,
 idx.NEWBANKKEY,
 idx.NEWFORENUM		
 )
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASK_writetoAUDIT_CLRRPF(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_AUDIT_CLRRPF_pip)) loop
    v_sql_res := '"' 	||i.UNIQUE_NUMBER	||'","' 	||i.OLDBANKKEY	||'","' 	||i.OLDFORENUM		||'","' 	||i.NEWBANKKEY||'","' 	||i.NEWFORENUM		|| '"';

    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/



