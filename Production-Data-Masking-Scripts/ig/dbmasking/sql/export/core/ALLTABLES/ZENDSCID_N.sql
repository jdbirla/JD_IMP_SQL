set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZENDSCID_N.sql;
select /*+ paralle(10) */'"'||ZENDSCID||'","'||ZENDSCID_N||'"' from  VM1DTA.ZENDSCID_N;
spool off;
