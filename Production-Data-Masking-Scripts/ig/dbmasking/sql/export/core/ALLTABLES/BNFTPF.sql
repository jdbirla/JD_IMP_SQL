set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BNFTPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||BENCDE||'","'||PROCCLS||'","'||DRUGCLS||'","'||DIAGCLS||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BNFTPF;
spool off;
