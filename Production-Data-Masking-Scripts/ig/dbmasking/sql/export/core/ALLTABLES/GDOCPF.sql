set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GDOCPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||DOCTYP||'","'||CHDRCOY||'","'||LDOCNO||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.GDOCPF;
spool off;
