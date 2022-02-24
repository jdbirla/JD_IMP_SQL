set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/GMHIPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZWORKPLCE1||'","'||ZWORKPLCE2||'"' from VM1DTA.GMHIPF;
spool off;
