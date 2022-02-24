set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZPIDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRPFX||'","'||CHDRNUM||'","'||ZPAYINDT||'","'||ENTITY||'","'||ZPYINAMT||'","'||ZREFNO||'","'||DESCRIP||'","'||ZXCESSYN||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZPIDPF;
spool off;
