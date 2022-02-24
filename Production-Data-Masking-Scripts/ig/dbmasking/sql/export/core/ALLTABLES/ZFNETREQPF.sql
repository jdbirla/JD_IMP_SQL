set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZFNETREQPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||LABEL_NUM||'","'||STATUS||'","'||USRPRF||'","'||DATIME||'","'||SEND_COUNT||'","'||LAST_SEND_TIME||'"' from  VM1DTA.ZFNETREQPF;
spool off;
