set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/QRTZ_G_TRIGGERS.sql;
select /*+ paralle(10) */'"'||SCHED_NAME||'","'||TRIGGER_NAME||'","'||TRIGGER_GROUP||'","'||JOB_NAME||'","'||JOB_GROUP||'","'||DESCRIPTION||'","'||NEXT_FIRE_TIME||'","'||PREV_FIRE_TIME||'","'||PRIORITY||'","'||TRIGGER_STATE||'","'||TRIGGER_TYPE||'","'||START_TIME||'","'||END_TIME||'","'||CALENDAR_NAME||'","'||MISFIRE_INSTR||'","'||JOB_DATA||'"' from  VM1DTA.QRTZ_G_TRIGGERS;
spool off;
