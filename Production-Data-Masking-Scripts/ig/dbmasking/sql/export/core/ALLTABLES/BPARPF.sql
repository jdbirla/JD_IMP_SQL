set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BPARPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||COMPANY||'","'||BPRCEFFDAT||'","'||BPARPPROG||'","'||BRUNTYPE||'","'||BRUNOCCUR||'","'||PARMAREA||'","'||BSCHEDNUM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ACCTMONTH||'","'||ACCTYEAR||'"' from  VM1DTA.BPARPF;
spool off;
