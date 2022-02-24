set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TITDMGREF1_TEMP.sql;
select /*+ paralle(10) */'"'||RECIDXREFB1||'","'||BANKACOUNT||'"' from  VM1DTA.TITDMGREF1_TEMP;
spool off;
