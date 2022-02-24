set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSCDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BNOFTHREDS||'","'||BUNIQINSYS||'","'||BDEBUGMODE||'","'||BAUTHCODE||'","'||JOBQ||'","'||BJOBQPRTY||'","'||BJOBDESC||'","'||PRODCODE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||DROPTEMP||'"' from  VM1DTA.BSCDPF;
spool off;
