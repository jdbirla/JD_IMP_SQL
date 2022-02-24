set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDRFPF.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'","'||ZREFMTCD||'","'||ZPDATATXFLG||'","'||RECIDXBILLING||'","'||RECSTATUS||'","'||ZENTITY||'"' from  VM1DTA.ZDRFPF;
spool off;
