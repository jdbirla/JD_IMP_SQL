set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDDVPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANNO||'","'||EFFDATE||'","'||EFDATE||'","'||BTDATE||'","'||ZPLANCDE||'","'||ZVIOLTYP||'","'||PRODTYP||'","'||ZRFDDATE||'","'||ZDEFDATE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZDDVPF;
spool off;
