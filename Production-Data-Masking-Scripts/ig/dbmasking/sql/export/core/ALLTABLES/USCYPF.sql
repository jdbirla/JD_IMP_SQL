set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USCYPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.USCYPF;
spool off;
