set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TITDMGPOLTRNH_FREE_PLANS_TEMP.sql;
select /*+ paralle(10) */'"'||RECIDXPHIST||'","'||CRDTCARD||'","'||BNKACCKEY01||'"' from  VM1DTA.TITDMGPOLTRNH_FREE_PLANS_TEMP;
spool off;
