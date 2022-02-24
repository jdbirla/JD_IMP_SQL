set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSNRPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BLASTSCHNO||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BSNRPF;
spool off;
