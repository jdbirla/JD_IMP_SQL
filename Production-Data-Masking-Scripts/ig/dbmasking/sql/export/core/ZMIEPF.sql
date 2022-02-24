set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZMIEPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||LSURNAME||'","'||OWNERKANASURNAME||'"' from VM1DTA.ZMIEPF;
spool off;
