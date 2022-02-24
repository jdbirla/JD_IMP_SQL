set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZALTPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CRDTCARD||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||KANJISURNAME||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTPHONE01||'","'||ZWORKPLCE1||'","'||ZWORKPLCE2||'","'||BNKACCKEY01||'","'||BNKACCKEY02||'","'||KANJIGIVNAME||'","'||KANJICLTADDR01||'","'||KANJICLTADDR02||'","'||KANJICLTADDR03||'","'||KANJICLTADDR04||'"' from  VM1DTA.ZALTPF_TEMP;
spool off;
