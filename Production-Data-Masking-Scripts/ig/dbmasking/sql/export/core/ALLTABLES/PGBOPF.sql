set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/PGBOPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BOBJECT||'","'||IMPLMTAS||'","'||SUBSYS||'","'||BOBJDESC||'","'||BOALIAS||'","'||BOINSSRC||'","'||BOTYPE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.PGBOPF;
spool off;
