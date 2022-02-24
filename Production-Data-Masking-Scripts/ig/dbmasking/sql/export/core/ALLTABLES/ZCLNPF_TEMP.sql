set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCLNPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LSURNAME||'","'||LGIVNAME||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||ZWORKPLCE||'"' from  VM1DTA.ZCLNPF_TEMP;
spool off;
