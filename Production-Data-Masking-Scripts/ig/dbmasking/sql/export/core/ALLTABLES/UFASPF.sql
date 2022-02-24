set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/UFASPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||RCPTSANC||'","'||SECLEVEL||'","'||UNDWRLIM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.UFASPF;
spool off;
