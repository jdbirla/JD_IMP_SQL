set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/QRTZ_G_FIRED_TRIGGERS.sql;
select /*+ paralle(10) */'"'||SCHED_NAME||'","'||ENTRY_ID||'","'||TRIGGER_NAME||'","'||TRIGGER_GROUP||'","'||INSTANCE_NAME||'","'||FIRED_TIME||'","'||SCHED_TIME||'","'||PRIORITY||'","'||STATE||'","'||JOB_NAME||'","'||JOB_GROUP||'","'||IS_NONCONCURRENT||'","'||REQUESTS_RECOVERY||'"' from  VM1DTA.QRTZ_G_FIRED_TRIGGERS;
spool off;
