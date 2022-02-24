set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USESPF.sql;
select /*+ paralle(10) */'"'||USERID||'","'||COMPANY||'","'||BRANCH||'"' from  VM1DTA.USESPF;
spool off;
