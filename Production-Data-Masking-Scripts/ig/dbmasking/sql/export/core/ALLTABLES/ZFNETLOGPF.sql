set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZFNETLOGPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||FK_ZFNETREQPF||'","'||INFO||'","'||SEND_COUNT||'"' from  VM1DTA.ZFNETLOGPF;
spool off;
