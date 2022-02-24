set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZPJERPF.sql;
select /*+ paralle(10) */'"'||ZSCHDID||'","'||ZENDSCID||'","'||CHDRNUM||'","'||ZPOLDTADT||'","'||NZACMCLDT||'","'||BILLNO||'","'||ERORDESC||'"' from  VM1DTA.ZPJERPF;
spool off;
