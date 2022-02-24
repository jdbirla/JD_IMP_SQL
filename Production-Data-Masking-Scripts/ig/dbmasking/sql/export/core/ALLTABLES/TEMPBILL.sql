set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TEMPBILL.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||BILLNO||'","'||POSYEAR||'","'||POSMONTH||'"' from  VM1DTA.TEMPBILL;
spool off;
