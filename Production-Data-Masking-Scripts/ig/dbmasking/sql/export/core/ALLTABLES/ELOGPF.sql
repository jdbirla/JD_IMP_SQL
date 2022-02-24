set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ELOGPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ERRNUM||'","'||TERMINALID||'","'||FLOGDATA||'","'||WSSPCOMN||'","'||WSSPUSER||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ELOGPF;
spool off;
