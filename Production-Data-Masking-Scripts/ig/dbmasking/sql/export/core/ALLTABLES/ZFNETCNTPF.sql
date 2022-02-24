set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZFNETCNTPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||FK_ZFNETREQPF||'","'||REQUEST_DATA||'"' from  VM1DTA.ZFNETCNTPF;
spool off;
