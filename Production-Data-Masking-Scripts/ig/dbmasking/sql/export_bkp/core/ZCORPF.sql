set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZCORPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||LSURNAME||'","'||LGIVNAME||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTPHONE01||'"' from VM1DTA.ZCORPF;
spool off;
