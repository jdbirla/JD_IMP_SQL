set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TMPIRPOLNM.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||THREADNO||'"' from  VM1DTA.TMPIRPOLNM;
spool off;
