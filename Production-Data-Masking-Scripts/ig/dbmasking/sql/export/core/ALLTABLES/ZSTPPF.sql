set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZSTPPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||RUNID||'","'||CHDRNUM||'","'||MEMSHIPNO||'","'||JOBNUM||'","'||ERROR||'","'||ERRORDSC||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZSTPPF;
spool off;
