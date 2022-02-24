set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BUPAPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||COMPANY||'","'||BPARPPROG||'","'||BPRCACCYR||'","'||BPRCACCMTH||'","'||BPRCEFFDAT||'","'||BRANCH||'","'||PARMAREA||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BUPAPF;
spool off;
