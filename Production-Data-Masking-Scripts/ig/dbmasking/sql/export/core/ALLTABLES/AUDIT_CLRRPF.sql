set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AUDIT_CLRRPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||OLDCLNTPFX||'","'||OLDCLNTCOY||'","'||OLDCLNTNUM||'","'||OLDCLRRROLE||'","'||OLDFOREPFX||'","'||OLDFORECOY||'","'||OLDFORENUM||'","'||OLDUSED2B||'","'||OLDUSRPRF||'","'||OLDJOBNM||'","'||OLDDATIME||'","'||NEWCLNTPFX||'","'||NEWCLNTCOY||'","'||NEWCLNTNUM||'","'||NEWCLRRROLE||'","'||NEWFOREPFX||'","'||NEWFORECOY||'","'||NEWFORENUM||'","'||NEWUSED2B||'","'||NEWUSRPRF||'","'||NEWJOBNM||'","'||NEWDATIME||'","'||USERID||'","'||ACTION||'","'||TRANNO||'","'||SYSTEMDATE||'"' from  VM1DTA.AUDIT_CLRRPF;
spool off;
