set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/CLNTQY.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||SURNAME||'","'||GIVNAME||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTADDR05||'"' from VM1DTA.CLNTQY;
spool off;
