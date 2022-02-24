set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZCLEPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZENSPCD01||'","'||ZENSPCD02||'","'||ZCIFCODE||'"' from VM1DTA.ZCLEPF;
spool off;

