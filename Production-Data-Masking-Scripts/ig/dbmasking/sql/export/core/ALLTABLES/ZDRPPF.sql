set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDRPPF.sql;
select /*+ paralle(10) */'"'||RECIDXPOLICY||'","'||RECSTATUS||'","'||CHDRNUM||'","'||PREFIX||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.ZDRPPF;
spool off;
