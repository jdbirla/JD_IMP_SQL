set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSSJPF.sql;
select /*+ paralle(10) */'"'||SYS_STSLSQJE8J0RNJDX$G1D$2ZYN3||'","'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||BSHDTHRDNO||'","'||BSJOBUSER||'","'||BSJOBJOB||'","'||BSJOBNO||'","'||COMPANY||'","'||BPROCESNAM||'","'||BPRCOCCNO||'","'||VALIDFLAG||'","'||BSJOBQIND||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BSSJPF;
spool off;
