set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCELINKPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CLNTCOY||'","'||CLNTPFX||'","'||CLNTNUM||'","'||ZENDCDE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZCELINKPF;
spool off;
