set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MV_ZENCIPF.sql;
select /*+ paralle(10) */'"'||ZMBRNOID||'","'||ZENDCDE||'"' from  VM1DTA.MV_ZENCIPF;
spool off;
