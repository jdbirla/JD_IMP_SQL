set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AUDIT_CLNT_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||OLDSURNAME||'","'||OLDGIVNAME||'","'||OLDCLTPHONE01||'","'||OLDCLTPHONE02||'","'||NEWSURNAME||'","'||NEWGIVNAME||'","'||NEWCLTPHONE01||'","'||NEWCLTPHONE02||'","'||OLDCLTADDR01||'","'||OLDCLTADDR02||'","'||OLDCLTADDR03||'","'||OLDCLTADDR04||'","'||OLDCLTADDR05||'","'||NEWCLTADDR01||'","'||NEWCLTADDR02||'","'||NEWCLTADDR03||'","'||NEWCLTADDR04||'","'||NEWCLTADDR05||'"' from  VM1DTA.AUDIT_CLNT_TEMP;
spool off;
