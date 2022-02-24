set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDCLPF.sql;
select /*+ paralle(10) */'"'||RECIDXCLIENT||'","'||RECSTATUS||'","'||PREFIX||'","'||ZENTITY||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.ZDCLPF;
spool off;
