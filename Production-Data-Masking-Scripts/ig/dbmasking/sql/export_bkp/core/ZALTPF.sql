set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZALTPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CRDTCARD||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||KANJISURNAME||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTPHONE01||'","'||ZWORKPLCE1||'","'||ZWORKPLCE2||'"' from VM1DTA.ZALTPF;
spool off;
