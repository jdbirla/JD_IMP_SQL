set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/QRTZ_P_JOB_DETAILS.sql;
select /*+ paralle(10) */'"'||SCHED_NAME||'","'||JOB_NAME||'","'||JOB_GROUP||'","'||DESCRIPTION||'","'||JOB_CLASS_NAME||'","'||IS_DURABLE||'","'||IS_NONCONCURRENT||'","'||IS_UPDATE_DATA||'","'||REQUESTS_RECOVERY||'","'||JOB_DATA||'"' from  VM1DTA.QRTZ_P_JOB_DETAILS;
spool off;
