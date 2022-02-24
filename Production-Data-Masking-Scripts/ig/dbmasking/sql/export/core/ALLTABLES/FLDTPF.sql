set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/FLDTPF.sql;
select /*+ paralle(10) */'"'||JOBNM||'","'||DATIME||'","'||CHDRCOY||'","'||CHDRPFX||'","'||CHDRNUM||'","'||EFFDATE||'","'||CCDATE||'","'||CNTBRANCH||'","'||ZAGPTPFX||'","'||ZAGPTCOY||'","'||ZAGPTNUM||'","'||UNIQUE_NUMBER||'","'||FDID||'","'||LANG||'","'||FDTX||'","'||COLH01||'","'||COLH02||'","'||COLH03||'","'||TERMID||'","'||USER_T||'","'||TRDT||'","'||TRTM||'","'||USRPRF||'"' from  VM1DTA.FLDTPF;
spool off;
