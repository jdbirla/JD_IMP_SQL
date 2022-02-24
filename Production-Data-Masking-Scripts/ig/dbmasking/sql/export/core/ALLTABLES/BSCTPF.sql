set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSCTPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LANGUAGE||'","'||BSCHEDNAM||'","'||DESC_T||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BSCTPF;
spool off;
