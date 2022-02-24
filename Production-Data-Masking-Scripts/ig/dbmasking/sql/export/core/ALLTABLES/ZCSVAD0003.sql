set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCSVAD0003.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LINEDATA||'","'||MEMBER_NAME||'"' from  VM1DTA.ZCSVAD0003;
spool off;
