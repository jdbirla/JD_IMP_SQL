set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDROPF.sql;
select /*+ paralle(10) */'"'||RECIDXOTHERS||'","'||RECSTATUS||'","'||PREFIX||'","'||ZENTITY||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.ZDROPF;
spool off;
