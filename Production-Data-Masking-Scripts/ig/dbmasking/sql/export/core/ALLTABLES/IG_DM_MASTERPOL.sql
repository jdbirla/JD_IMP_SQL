set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/IG_DM_MASTERPOL.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||ZPLANCLS||'","'||ZCOLMCLS||'","'||POLANV||'","'||ZAGPTNUM||'"' from  VM1DTA.IG_DM_MASTERPOL;
spool off;
