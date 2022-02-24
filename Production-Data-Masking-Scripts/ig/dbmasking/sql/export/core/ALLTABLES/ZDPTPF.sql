set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDPTPF.sql;
select /*+ paralle(10) */'"'||RECIDXPOLTRNH||'","'||RECSTATUS||'","'||ZENTITY||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.ZDPTPF;
spool off;
