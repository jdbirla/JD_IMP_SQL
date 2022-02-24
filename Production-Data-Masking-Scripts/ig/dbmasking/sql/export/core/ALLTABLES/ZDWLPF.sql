set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDWLPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDCDE||'","'||ACYR||'","'||ACMN||'","'||AGNTNUM||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||DATIME||'","'||USRPRF||'","'||JOBNM||'"' from  VM1DTA.ZDWLPF;
spool off;
