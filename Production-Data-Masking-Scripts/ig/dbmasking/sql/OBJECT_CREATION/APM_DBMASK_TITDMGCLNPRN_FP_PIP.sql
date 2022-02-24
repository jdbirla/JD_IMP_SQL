create or replace type APM_DBMASK_TITDMGCLPRSN_FP_obj as object(
UNIQUE_NUMBER		NUMBER(18)			,
LSURNAME       VARCHAR2(60 CHAR) ,
LGIVNAME       VARCHAR2(60 CHAR) ,
ZKANAGIVNAME   VARCHAR2(60 CHAR) ,
ZKANASURNAME   VARCHAR2(60 CHAR) ,
CLTADDR01      VARCHAR2(60 CHAR) ,
CLTADDR02      VARCHAR2(60 CHAR) ,
CLTADDR03              VARCHAR2(60 CHAR), 
CLTADDR04              VARCHAR2(60 CHAR) ,
ZKANADDR01     VARCHAR2(30 CHAR) ,
ZKANADDR02             VARCHAR2(30 CHAR), 
ZKANADDR03             VARCHAR2(30 CHAR) ,
ZKANADDR04             VARCHAR2(30 CHAR) ,
CLTPHONE01             VARCHAR2(16 CHAR) ,
CLTPHONE02             VARCHAR2(16 CHAR)
);
/  
create or replace type APM_DBMASK_TITDMGCLPRSN_FP_tab as table of APM_DBMASK_TITDMGCLPRSN_FP_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TITDMGCLPRSN_FP_pip return  APM_DBMASK_TITDMGCLPRSN_FP_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
 UNIQUE_NUMBER	,
 LSURNAME     ,
 LGIVNAME     ,
 ZKANAGIVNAME ,
 ZKANASURNAME ,
 CLTADDR01    ,
 CLTADDR02    ,
 CLTADDR03    ,
 CLTADDR04    ,
 ZKANADDR01   ,
 ZKANADDR02   ,
 ZKANADDR03   ,
 ZKANADDR04   ,
 CLTPHONE01   ,
 CLTPHONE02   
from TITDMGCLNTPRSN_FREEPLAN@stagedblink fetch first 100 percent rows only 
  )loop
    pipe row(
      APM_DBMASK_TITDMGCLPRSN_FP_obj( 
 idx.UNIQUE_NUMBER	,
 idx.LSURNAME     ,
 idx.LGIVNAME     ,
 idx.ZKANAGIVNAME ,
 idx.ZKANASURNAME ,
 idx.CLTADDR01    ,
 idx.CLTADDR02    ,
 idx.CLTADDR03    ,
 idx.CLTADDR04    ,
 idx.ZKANADDR01   ,
 idx.ZKANADDR02   ,
 idx.ZKANADDR03   ,
 idx.ZKANADDR04   ,
 idx.CLTPHONE01   ,
 idx.CLTPHONE02   
		)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASKwritetoTITDMGCLPRNFP(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TITDMGCLPRSN_FP_pip)) loop
  
v_sql_res := '"' ||i.UNIQUE_NUMBER	||'","' ||i.LSURNAME     ||'","' ||i.LGIVNAME     ||'","' ||i.ZKANAGIVNAME ||'","' ||i.ZKANASURNAME ||'","' ||i.CLTADDR01    ||'","' ||i.CLTADDR02    ||'","' ||i.CLTADDR03    ||'","' ||i.CLTADDR04    ||'","' ||i.ZKANADDR01   ||'","' ||i.ZKANADDR02   ||'","' ||i.ZKANADDR03   ||'","' ||i.ZKANADDR04   ||'","' ||i.CLTPHONE01   ||'","' ||i.CLTPHONE02   ||'"';	


    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASKwritetoTITDMGCLPRNFP('IMP_DATA_DIR','TITDMGCLPRSN_FP.csv');



