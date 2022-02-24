set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMBILDAT.csv;
select '"'||RECIDXBILDAT||'","'||CCARD||'","'||BANKACCKEY||'","'||MBRNAM||'","'||CRDNAM||'"' from STAGEDBUSR.TOTPAMBILDAT;
spool off;
