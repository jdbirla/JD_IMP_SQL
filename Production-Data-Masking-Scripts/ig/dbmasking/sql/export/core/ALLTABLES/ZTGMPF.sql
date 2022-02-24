set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZTGMPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANNO||'","'||EFFDATE||'","'||COWNNUM||'","'||ZAGPTNUM||'","'||PETNAME||'","'||ZTRXSTAT||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZTGMPF;
spool off;
