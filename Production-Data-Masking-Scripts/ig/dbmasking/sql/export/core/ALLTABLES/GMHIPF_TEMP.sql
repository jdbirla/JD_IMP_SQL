set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GMHIPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZWORKPLCE1||'","'||ZWORKPLCE2||'"' from  VM1DTA.GMHIPF_TEMP;
spool off;
