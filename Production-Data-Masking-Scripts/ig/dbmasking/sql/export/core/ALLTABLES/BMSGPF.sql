set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BMSGPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||COMPANY||'","'||BPROCESNAM||'","'||BPRCOCCNO||'","'||BPROCMESS||'","'||DATAKEY||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BMSGPF;
spool off;
