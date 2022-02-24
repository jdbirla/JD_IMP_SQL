set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/AUDIT_CLEXPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||OLDFAXNO||'","'||NEWFAXNO||'"' from VM1DTA.AUDIT_CLEXPF;
spool off;
