set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/QRTZ_P_SIMPLE_TRIGGERS.sql;
select /*+ paralle(10) */'"'||SCHED_NAME||'","'||TRIGGER_NAME||'","'||TRIGGER_GROUP||'","'||REPEAT_COUNT||'","'||REPEAT_INTERVAL||'","'||TIMES_TRIGGERED||'"' from  VM1DTA.QRTZ_P_SIMPLE_TRIGGERS;
spool off;
