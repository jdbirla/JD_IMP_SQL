set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/BABRPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'"' from VM1DTA.BABRPF;
spool off;
