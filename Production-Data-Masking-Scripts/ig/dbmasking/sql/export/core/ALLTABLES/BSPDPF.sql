set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSPDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||COMPANY||'","'||BPROCESNAM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BSPDPF;
spool off;
