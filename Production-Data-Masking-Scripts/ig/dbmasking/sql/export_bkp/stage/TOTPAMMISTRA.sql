set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMMISTRA.csv;
select '"'||RECIDXACTPOLTRA||'","'||ZADDRCD||'"' from STAGEDBUSR.TOTPAMMISTRA;
spool off;
