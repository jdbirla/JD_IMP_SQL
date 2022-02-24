set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZTDCPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||ZDESPER||'","'||LETTYPE||'","'||PRBILFDT||'","'||PRBILTDT||'","'||ZSTATC||'"' from  VM1DTA.ZTDCPF;
spool off;
