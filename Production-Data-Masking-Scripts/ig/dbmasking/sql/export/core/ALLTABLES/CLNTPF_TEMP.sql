set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/CLNTPF_TEMP.sql;
select /*+ paralle(10) */'"'||CLTPHONE01||'","'||CLTPHONE02||'","'||FAXNO||'","'||LSURNAME||'","'||LGIVNAME||'","'||KANJISURNAME||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||ZKANADDR05||'","'||ZADDRCD||'","'||ZKANASNMNOR||'","'||ZKANAGNMNOR||'","'||ZWORKPLCE||'","'||KANJIGIVNAME||'","'||UNIQUE_NUMBER||'","'||SURNAME||'","'||GIVNAME||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTADDR05||'"' from  VM1DTA.CLNTPF_TEMP;
spool off;
