set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GMHDPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BANKACCKEY||'"' from  VM1DTA.GMHDPF_TEMP;
spool off;
