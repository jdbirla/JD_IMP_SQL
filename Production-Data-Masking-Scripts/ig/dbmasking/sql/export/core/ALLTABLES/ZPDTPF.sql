set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZPDTPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDCDE||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANNO||'","'||BPRCOCCNO||'","'||EFFDATE||'","'||EFDATE||'","'||ZGPORIPCLS||'"' from  VM1DTA.ZPDTPF;
spool off;
