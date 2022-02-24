set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDCHPF.sql;
select /*+ paralle(10) */'"'||RECIDXCLNTHIS||'","'||RECSTATUS||'","'||ZENTITY||'","'||ZIGVALUE||'","'||JOBNUM||'","'||JOBNAME||'","'||EFFDATE||'","'||ZSEQNO||'"' from  VM1DTA.ZDCHPF;
spool off;
