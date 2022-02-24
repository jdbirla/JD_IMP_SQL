set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCERPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||KEYFMT||'","'||ENTVAL||'","'||ERORDESCER||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||EFFDATE||'","'||EROR||'"' from  VM1DTA.ZCERPF;
spool off;
