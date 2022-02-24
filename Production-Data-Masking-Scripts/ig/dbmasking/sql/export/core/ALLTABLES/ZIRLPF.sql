set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZIRLPF.sql;
select /*+ paralle(10) */'"'||ACYR||'","'||ACMN||'","'||ZENDCDE||'","'||CHDRNUM||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||DATIME||'","'||USRPRF||'","'||JOBNM||'"' from  VM1DTA.ZIRLPF;
spool off;
