set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZESHPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDSCID||'","'||ZESYEAR||'","'||ZESSTAT||'","'||ZESAPPDTE||'","'||ZESDATE||'","'||ZESJOBNO||'","'||ZACSHED||'","'||ZSYSIMP01||'","'||ZSYSIMP02||'","'||ZSYSIMP03||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZESHPF;
spool off;
