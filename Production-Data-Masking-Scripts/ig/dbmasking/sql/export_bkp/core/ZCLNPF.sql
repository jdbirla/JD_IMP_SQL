set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZCLNPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||LSURNAME||'","'||LGIVNAME||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||ZWORKPLCE||'"' from VM1DTA.ZCLNPF;
spool off;
