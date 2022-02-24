set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TOTPAMPOSTTGTD.csv;
select '"'||RECIDXPOSTTGTD||'","'||CCARD||'","'||BANKACCKEY||'"' from STAGEDBUSR.TOTPAMPOSTTGTD;
spool off;
