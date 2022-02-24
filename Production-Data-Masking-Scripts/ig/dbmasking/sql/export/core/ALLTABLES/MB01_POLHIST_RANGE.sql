set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MB01_POLHIST_RANGE.sql;
select /*+ paralle(10) */'"'||CHDRNUM_FROM||'","'||CHDRNUM_TO||'"' from  VM1DTA.MB01_POLHIST_RANGE;
spool off;
