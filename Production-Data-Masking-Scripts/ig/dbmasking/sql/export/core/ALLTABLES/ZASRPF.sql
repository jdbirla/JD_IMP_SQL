set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZASRPF.sql;
select /*+ paralle(10) */'"'||UNIQUENUMBER||'","'||CLNTCOY||'","'||CLNTPFX||'","'||CLNTNUM||'","'||ZASRFTYP||'","'||VALIDFLAG||'","'||ZINSTYPE||'","'||TRDTP||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANCDE||'"' from  VM1DTA.ZASRPF;
spool off;
