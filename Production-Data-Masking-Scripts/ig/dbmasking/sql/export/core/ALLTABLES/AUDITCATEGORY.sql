set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AUDITCATEGORY.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||PARENT||'","'||FUNCTION_NAME||'"' from  VM1DTA.AUDITCATEGORY;
spool off;
