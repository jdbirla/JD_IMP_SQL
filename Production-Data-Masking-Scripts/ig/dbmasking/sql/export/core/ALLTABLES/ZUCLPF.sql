set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZUCLPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRPFX||'","'||CHDRCOY||'","'||CHDRNUM||'","'||ZCHDRPFX||'","'||ZCHDRCOY||'","'||ZCHDRNUM||'","'||ZNOSHFT||'","'||ZENDPGP||'","'||ZCOMBILL||'","'||VALIDFLAG||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZSTRTPGP||'"' from  VM1DTA.ZUCLPF;
spool off;
