set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCSVBK0003.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LINEDATA||'","'||MEMBER_NAME||'"' from  VM1DTA.ZCSVBK0003;
spool off;
