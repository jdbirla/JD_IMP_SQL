set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TITPAMMONTRF.csv;
select '"'||RECIDXMONTRF||'","'||BANKACCKEY||'","'||CBANKACKEY||'"' from STAGEDBUSR.TITPAMMONTRF;
spool off;
