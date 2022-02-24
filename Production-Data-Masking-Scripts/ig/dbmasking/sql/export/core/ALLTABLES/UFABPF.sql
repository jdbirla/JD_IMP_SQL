set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/UFABPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||BANKCODE||'","'||MAXALW01||'","'||MAXALW02||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.UFABPF;
spool off;
