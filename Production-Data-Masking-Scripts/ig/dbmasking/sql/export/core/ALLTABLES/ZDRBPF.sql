set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDRBPF.sql;
select /*+ paralle(10) */'"'||RECIDXBILLING||'","'||RECSTATUS||'","'||ZENTITY||'","'||CHDRNUM||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'","'||PREFIX||'","'||PRBILFDT||'","'||PRBILTDT||'","'||ZPDATATXFLG||'"' from  VM1DTA.ZDRBPF;
spool off;
