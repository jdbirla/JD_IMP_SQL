set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TEMP_13434_PS_2.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||MAXTRANNO||'"' from  VM1DTA.TEMP_13434_PS_2;
spool off;
