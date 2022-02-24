set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZBOPPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||TRANNO||'","'||BILLNOFR||'","'||PRBILFDT||'","'||PRBILTDT||'","'||DPREM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZBOPPF;
spool off;
