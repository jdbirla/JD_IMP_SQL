set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TOTPAMBILDAT.csv;
select '"'||RECIDXBILDAT||'","'||CCARD||'","'||BANKACCKEY||'","'||MBRNAM||'","'||CRDNAM||'"' from STAGEDBUSR.TOTPAMBILDAT;
spool off;
