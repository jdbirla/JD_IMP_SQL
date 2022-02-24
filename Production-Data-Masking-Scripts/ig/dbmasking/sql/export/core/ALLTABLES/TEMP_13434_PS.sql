set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TEMP_13434_PS.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||ZTRATRN||'","'||STATCODE||'","'||CHDRSTAT||'","'||ZPOLTDATE||'","'||GBHITRN||'","'||BILLNO||'","'||MAXTRNCHDR||'","'||NEWZTRATRANNO||'"' from  VM1DTA.TEMP_13434_PS;
spool off;
