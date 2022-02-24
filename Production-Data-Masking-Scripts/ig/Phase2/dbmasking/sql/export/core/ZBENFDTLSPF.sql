set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZBENFDTLSPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||ZKNJFULNM||'"' from VM1DTA.ZBENFDTLSPF;
spool off;

