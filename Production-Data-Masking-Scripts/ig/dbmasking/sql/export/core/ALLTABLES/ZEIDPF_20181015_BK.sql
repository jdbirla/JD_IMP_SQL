set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZEIDPF_20181015_BK.sql;
select /*+ paralle(10) */'"'||ZENDSCID||'","'||ZPOLDTADT||'","'||ZINSTBILDT||'","'||ZBTDATE||'","'||ZBILTRDT||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZLTMIRDT||'","'||ZLFNIRDT||'","'||UNIQUE_NUMBER||'","'||ZPOLDDDT||'"' from  VM1DTA.ZEIDPF_20181015_BK;
spool off;
