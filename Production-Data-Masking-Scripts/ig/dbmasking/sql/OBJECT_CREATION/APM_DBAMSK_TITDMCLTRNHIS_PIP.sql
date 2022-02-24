create or replace type APM_DBMASK_TITDMGCLTRNHIS_obj as object(
RECIDXCLHIS		NUMBER(38)			,
LSURNAME      VARCHAR2(60 CHAR) ,
LGIVNAME      VARCHAR2(60 CHAR) ,
ZKANAGIVNAME  VARCHAR2(60 CHAR) ,
ZKANASURNAME  VARCHAR2(60 CHAR) ,
CLTADDR01     VARCHAR2(60 CHAR) ,
CLTADDR02     VARCHAR2(60 CHAR) ,
CLTADDR03     VARCHAR2(60 CHAR) ,
ZKANADDR01    VARCHAR2(30 CHAR) ,
ZKANADDR02            VARCHAR2(30 CHAR),
CLTPHONE01            VARCHAR2(16 CHAR) ,
CLTPHONE02            VARCHAR2(16 CHAR) ,
ZWORKPLCE             VARCHAR2(25 CHAR) 
);
/  
create or replace type APM_DBMASK_TITDMGCLTRNHIS_tab as table of APM_DBMASK_TITDMGCLTRNHIS_obj;
/
/***************** Pipeline approach*******************************************/
create or replace function APM_DBMASK_TITDMGCLTRNHIS_pip return  APM_DBMASK_TITDMGCLTRNHIS_tab pipelined
PARALLEL_ENABLE
as
  begin
  for idx in (
  select
RECIDXCLHIS	  ,
LSURNAME      ,
LGIVNAME      ,
ZKANAGIVNAME  ,
ZKANASURNAME  ,
CLTADDR01     ,
CLTADDR02     ,
CLTADDR03     ,
ZKANADDR01    ,
ZKANADDR02    ,
CLTPHONE01 ,
CLTPHONE02 ,
ZWORKPLCE  
from TITDMGCLTRNHIS@stagedblink fetch first 100 percent rows only 
  )loop
    pipe row(
      APM_DBMASK_TITDMGCLTRNHIS_obj( 
idx.RECIDXCLHIS	  ,
idx.LSURNAME      ,
idx.LGIVNAME      ,
idx.ZKANAGIVNAME  ,
idx.ZKANASURNAME  ,
idx.CLTADDR01     ,
idx.CLTADDR02     ,
idx.CLTADDR03     ,
idx.ZKANADDR01    ,
idx.ZKANADDR02    ,
idx.CLTPHONE01 ,
idx.CLTPHONE02 ,
idx.ZWORKPLCE  
)
    );
  end loop;
  return;
end;
/

/*******************************************************************************
*A METHOD TO CALL TableFunction CALL with PARALLEL HINT.
*******************************************************************************/
create or replace procedure APM_DBMASKwritetoTITDMCLTRNHIS(p_dir in VARCHAR2, p_fn in varchar2 )  as
  v_file  UTL_FILE.FILE_TYPE;
  v_sql_res   VARCHAR2(4000);
begin
  v_file := UTL_FILE.FOPEN(p_dir, p_fn, 'w',32767);
  for i in (select/*+parallel(4)*/ * from table(APM_DBMASK_TITDMGCLTRNHIS_pip)) loop
  

v_sql_res := '"' ||i.RECIDXCLHIS	||'","' || i.LSURNAME      ||'","' || i.LGIVNAME      ||'","' || i.ZKANAGIVNAME  ||'","' || i.ZKANASURNAME  ||'","' || i.CLTADDR01     ||'","' || i.CLTADDR02     ||'","' || i.CLTADDR03     ||'","' || i.ZKANADDR01    ||'","' || i.ZKANADDR02    ||'","' || i.CLTPHONE01 ||'","' ||  i.CLTPHONE02  ||'","' || i.ZWORKPLCE     ||'"';


    --UTL_FILE.PUT_LINE(v_file, v_sql_res );
UTL_FILE.put_line(v_file,convert(v_sql_res,'JA16SJIS','AL32UTF8'));
  end loop;
  UTL_FILE.FCLOSE(v_file);
end;
/

--exec APM_DBMASKwritetoTITDMGCLPRNFP('IMP_DATA_DIR','TITDMGCLTRNHIS.csv');



