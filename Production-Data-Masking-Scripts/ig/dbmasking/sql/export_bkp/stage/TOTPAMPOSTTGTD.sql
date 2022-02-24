set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMPOSTTGTD.csv;
select '"'||RECIDXPOSTTGTD||'","'||CCARD||'","'||BANKACCKEY||'"' from STAGEDBUSR.TOTPAMPOSTTGTD;
spool off;
