set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BNWCOM.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZBNWREC||'","'||MEMBER_NAME||'"' from  VM1DTA.BNWCOM;
spool off;
