set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/CLEXPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||FAXNO||'","'||RINTERNET||'","'||RINTERNET2||'","'||RMBLPHONE||'"' from  VM1DTA.CLEXPF_TEMP;
spool off;
