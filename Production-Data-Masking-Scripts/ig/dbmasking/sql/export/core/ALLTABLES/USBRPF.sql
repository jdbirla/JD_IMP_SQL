set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USBRPF.sql;
select /*+ paralle(10) */'"'||SYS_STSRQMBUCN7898IJTZGV4HMFCW||'","'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||BRANCH||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.USBRPF;
spool off;
