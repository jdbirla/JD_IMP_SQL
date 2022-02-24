set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AUDIT_CLEXPF_TEMP.sql;
select /*+ paralle(10) */'"'||OLDFAXNO||'","'||NEWFAXNO||'","'||NEWRMBLPHONE||'","'||UNIQUE_NUMBER||'"' from  VM1DTA.AUDIT_CLEXPF_TEMP;
spool off;
