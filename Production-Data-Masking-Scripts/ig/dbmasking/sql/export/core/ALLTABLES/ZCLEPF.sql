set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCLEPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CLNTNUM||'","'||ZENDCDE||'","'||ZENSPCD01||'","'||ZENSPCD02||'","'||ZCIFCODE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZCLEPF;
spool off;
