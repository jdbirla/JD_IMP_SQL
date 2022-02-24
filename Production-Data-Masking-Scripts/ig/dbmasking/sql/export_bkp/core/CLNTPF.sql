set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/CLNTPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||SURNAME||'","'||GIVNAME||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTADDR05||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||FAXNO||'","'||LSURNAME||'","'||LGIVNAME||'","'||KANJISURNAME||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||ZKANADDR05||'","'||ZADDRCD||'","'||ZKANASNMNOR||'","'||ZKANAGNMNOR||'","'||ZWORKPLCE||'"' from VM1DTA.CLNTPF;
spool off;
