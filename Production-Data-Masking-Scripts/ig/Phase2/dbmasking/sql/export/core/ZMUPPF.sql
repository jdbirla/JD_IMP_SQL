set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZMUPPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||LSURNAME||'","'||OWNERKANASURNAME||'"' from VM1DTA.ZMUPPF;
spool off;
