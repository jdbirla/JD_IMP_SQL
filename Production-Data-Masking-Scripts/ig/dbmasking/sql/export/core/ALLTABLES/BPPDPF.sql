set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BPPDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BPARPSEQNO||'","'||COMPANY||'","'||BPARPPROG||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BPPDPF;
spool off;
