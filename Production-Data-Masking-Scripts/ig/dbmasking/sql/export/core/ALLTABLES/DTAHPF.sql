set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTAHPF.sql;
select /*+ paralle(10) */'"'||FILD||'","'||SUBSYS||'","'||JRNL||'","'||QRYF||'","'||AUTOSTAMP||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||DSLG||'","'||UNIQUE_NUMBER||'","'||FILN||'"' from  VM1DTA.DTAHPF;
spool off;
