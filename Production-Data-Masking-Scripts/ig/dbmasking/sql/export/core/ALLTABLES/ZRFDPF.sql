set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZRFDPF.sql;
select /*+ paralle(10) */'"'||SYS_STSWTUA#2TOESK3$LE$ZDQE4_J||'","'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||TRANNO||'","'||BILLNO||'","'||EFFDATE||'","'||ZREFMTCD||'","'||ZREFUNDAM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZRFDPF;
spool off;
