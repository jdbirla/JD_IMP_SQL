set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZENARPF.sql;
select /*+ paralle(10) */'"'||ZENDCDE||'","'||ZALTRECD||'","'||ZRQBKRDF||'","'||ZREFMTCD||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZENARPF;
spool off;
