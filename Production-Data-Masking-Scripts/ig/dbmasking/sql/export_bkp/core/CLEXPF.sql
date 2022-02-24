set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/CLEXPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||FAXNO||'","'||RINTERNET||'","'||RINTERNET2||'"' from VM1DTA.CLEXPF;
spool off;
