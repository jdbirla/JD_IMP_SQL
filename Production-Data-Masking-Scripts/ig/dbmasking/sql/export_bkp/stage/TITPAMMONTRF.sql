set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TITPAMMONTRF.csv;
select '"'||RECIDXMONTRF||'","'||BANKACCKEY||'","'||CBANKACKEY||'"' from STAGEDBUSR.TITPAMMONTRF;
spool off;
