set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZBCCDJT.sql;
select /*+ paralle(10) */'"'||ZBINCD||'","'||ZFDRANGEFRM||'","'||ZFDRANGETO||'","'||ZFDCOUNT||'","'||ZCDNAME||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZBCCDJT;
spool off;
