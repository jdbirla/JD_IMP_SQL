set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MTRNPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||PRODTYP||'","'||MBRNO||'","'||DPNTNO||'","'||TRANNO||'","'||RLDPNTNO||'","'||ISSDATE||'","'||CHGTYPE||'","'||EFFDATE||'","'||JOBNOTPA||'","'||JOBNORIE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.MTRNPF;
spool off;
