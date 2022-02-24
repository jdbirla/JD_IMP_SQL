set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCDNAMES.sql;
select /*+ paralle(10) */'"'||ZCDNAME||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZCDNAMES;
spool off;
