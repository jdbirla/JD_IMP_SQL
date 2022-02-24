set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TITDMGMBRINDP1_TEMP.sql;
select /*+ paralle(10) */'"'||RECIDXMBINP1||'","'||CRDTCARD||'","'||BNKACCKEY01||'"' from  VM1DTA.TITDMGMBRINDP1_TEMP;
spool off;
