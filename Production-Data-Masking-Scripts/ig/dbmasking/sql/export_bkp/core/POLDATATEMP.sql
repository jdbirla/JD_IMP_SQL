set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/POLDATATEMP.csv;
select /*+ paralle(10) */ '"'||CHDRNUM||'","'||TRANNO||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||LSURNAME||'","'||LGIVNAME||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||FAXNO||'","'||CLTADDR05||'","'||ZKANADDR05||'","'||CRDTCARD||'"' from VM1DTA.POLDATATEMP;
spool off;
