set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZINSDTLSPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZWORKPLCE2||'"' from VM1DTA.ZINSDTLSPF;
spool off;
