set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/RAPA_GMHI.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||PLANCODE||'","'||EFFDATE||'","'||DTETRM||'","'||CLIENTIP||'","'||LOAD_DTM||'"' from  VM1DTA.RAPA_GMHI;
spool off;
