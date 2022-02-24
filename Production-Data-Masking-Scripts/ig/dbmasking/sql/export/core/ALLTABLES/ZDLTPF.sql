set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDLTPF.sql;
select /*+ paralle(10) */'"'||RECIDXLETTERS||'","'||RECSTATUS||'","'||CHDRNUM||'","'||HLETTYPE||'","'||LREQDATE||'","'||ZLETVERN||'","'||JOBNUM||'","'||JOBNAME||'"' from  VM1DTA.ZDLTPF;
spool off;
