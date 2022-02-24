set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/AUDIT_ASRDPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||OLDSURNAME||'","'||OLDGIVNAME||'","'||NEWSURNAME||'","'||NEWGIVNAME||'"' from VM1DTA.AUDIT_ASRDPF;
spool off;
