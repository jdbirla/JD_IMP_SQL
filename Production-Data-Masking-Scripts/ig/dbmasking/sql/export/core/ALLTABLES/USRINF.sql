set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USRINF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||USERID||'","'||LASTLOGON_TIME||'","'||LOGOUT_TIME||'","'||SNAME||'","'||DATIME||'","'||MESSAGE||'","'||SESSIONID||'"' from  VM1DTA.USRINF;
spool off;
