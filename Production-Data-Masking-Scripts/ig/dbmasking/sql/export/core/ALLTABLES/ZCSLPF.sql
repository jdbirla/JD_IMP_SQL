set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCSLPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZCMPCODE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZSALPLAN||'"' from  VM1DTA.ZCSLPF;
spool off;
