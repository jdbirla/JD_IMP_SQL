set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZPIHPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRPFX||'","'||CHDRNUM||'","'||ZPAYINDT||'","'||ZTOTPAYN||'","'||TRANNO||'","'||BANKCODE||'","'||ZPYINMTD||'","'||DOCNUM||'","'||QUOTENO||'","'||MARRYFLAG||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||DTECLAM||'","'||MNTH||'"' from  VM1DTA.ZPIHPF;
spool off;
