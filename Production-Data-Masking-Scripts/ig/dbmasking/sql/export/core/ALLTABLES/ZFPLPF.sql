set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZFPLPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDCDE||'","'||CHDRNUM||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||DATIME||'","'||USRPRF||'","'||JOBNM||'"' from  VM1DTA.ZFPLPF;
spool off;
