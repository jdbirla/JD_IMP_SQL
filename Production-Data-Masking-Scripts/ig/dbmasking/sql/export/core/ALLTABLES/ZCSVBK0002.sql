set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCSVBK0002.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LINEDATA||'","'||MEMBER_NAME||'"' from  VM1DTA.ZCSVBK0002;
spool off;
