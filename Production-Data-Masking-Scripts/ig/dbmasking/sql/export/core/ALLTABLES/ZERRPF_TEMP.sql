set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZERRPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CLTNAME||'"' from  VM1DTA.ZERRPF_TEMP;
spool off;
