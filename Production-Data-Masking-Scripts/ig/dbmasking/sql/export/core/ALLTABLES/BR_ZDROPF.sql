set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BR_ZDROPF.sql;
select /*+ paralle(10) */'"'||RECIDXOTHERS||'","'||RECSTATUS||'","'||PREFIX||'","'||ZENTITY||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.BR_ZDROPF;
spool off;
