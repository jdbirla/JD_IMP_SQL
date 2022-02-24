set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMRFDPREM.csv;
select '"'||RECIDXRFDPRM||'","'||BANKACCKEY||'","'||BANKACCDSC||'"' from STAGEDBUSR.TOTPAMRFDPREM;
spool off;
