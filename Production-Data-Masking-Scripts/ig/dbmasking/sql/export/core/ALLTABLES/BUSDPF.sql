set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BUSDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BUSDKEY||'","'||BUSDATE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||COMPANY||'"' from  VM1DTA.BUSDPF;
spool off;
