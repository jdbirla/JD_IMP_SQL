set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZWARPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||ZWARNING||'","'||ZIGNFLAG||'","'||ZINSTYPE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||EROR||'"' from  VM1DTA.ZWARPF;
spool off;
