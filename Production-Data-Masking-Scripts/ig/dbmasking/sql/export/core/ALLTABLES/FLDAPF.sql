set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/FLDAPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||FDID||'","'||ATTRIB||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.FLDAPF;
spool off;
