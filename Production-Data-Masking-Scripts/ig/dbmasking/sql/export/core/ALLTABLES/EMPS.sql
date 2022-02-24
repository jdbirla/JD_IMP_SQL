set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/EMPS.sql;
select /*+ paralle(10) */'"'||EMP_NO||'","'||EMP_NAME||'","'||TEL_NO||'"' from  VM1DTA.EMPS;
spool off;
