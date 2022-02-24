set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZRLEPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZKANASNM||'","'||ZKANAGNM||'"' from VM1DTA.ZRLEPF;
spool off;
