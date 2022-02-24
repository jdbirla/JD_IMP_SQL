set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/CLBAPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BANKACCKEY||'","'||BANKACCDSC||'"' from  VM1DTA.CLBAPF_TEMP;
spool off;
