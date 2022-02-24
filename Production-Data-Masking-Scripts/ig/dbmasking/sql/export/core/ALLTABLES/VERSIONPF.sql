set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/VERSIONPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||TRANNO||'","'||CLNTNUM||'"' from  VM1DTA.VERSIONPF;
spool off;
