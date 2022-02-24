set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GIBLGI0006.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||MBRNO||'","'||DPNTNO||'","'||CCDATE||'","'||CRDATE||'","'||STATCODE||'","'||BILLFREQ||'","'||BTDATE||'","'||GADJFREQ||'","'||ADJDATE||'","'||DATETO||'","'||TRDT||'","'||FUPFLG01||'","'||FUPFLG02||'","'||THREADNO||'","'||MEMBER_NAME||'"' from  VM1DTA.GIBLGI0006;
spool off;
