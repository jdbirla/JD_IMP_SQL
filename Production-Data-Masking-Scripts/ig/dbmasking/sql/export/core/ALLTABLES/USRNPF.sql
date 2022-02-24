set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USRNPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||KEYCODE||'","'||ALLOCNO||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.USRNPF;
spool off;
