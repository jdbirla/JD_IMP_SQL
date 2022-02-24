set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TOTPAMMISTRA.csv;
select '"'||RECIDXACTPOLTRA||'","'||ZADDRCD||'"' from STAGEDBUSR.TOTPAMMISTRA;
spool off;
