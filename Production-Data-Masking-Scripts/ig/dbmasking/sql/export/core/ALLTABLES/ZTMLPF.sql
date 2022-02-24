set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZTMLPF.sql;
select /*+ paralle(10) */'"'||ZENDCDE||'","'||CHDRNUM||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||DATTIME||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZTMLPF;
spool off;
