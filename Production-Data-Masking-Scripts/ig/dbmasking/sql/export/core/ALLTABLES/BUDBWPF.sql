set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BUDBWPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||VALIDFLAG||'","'||DATIME||'"' from  VM1DTA.BUDBWPF;
spool off;
