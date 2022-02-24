set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/AUDIT_CLNT.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||OLDSURNAME||'","'||OLDGIVNAME||'","'||OLDCLTPHONE01||'","'||OLDCLTPHONE02||'","'||NEWSURNAME||'","'||NEWGIVNAME||'","'||NEWCLTPHONE01||'","'||NEWCLTPHONE02||'"' from VM1DTA.AUDIT_CLNT;
spool off;
