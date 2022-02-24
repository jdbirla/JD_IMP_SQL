set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AUDIT_BRUPPF.sql;
select /*+ paralle(10) */'"'||NEWZLSTUPDT||'","'||NEWUSRPRF||'","'||NEWJOBNM||'","'||NEWDATIME||'","'||NEWVALIDFLAG||'","'||USERID||'","'||ACTION||'","'||TRANNO||'","'||SYSTEMDATE||'","'||UNIQUE_NUMBER||'","'||OLDCLNTCOY||'","'||OLDCLNTNUM||'","'||OLDBRUPDTE||'","'||OLDDISCHDT||'","'||OLDCRTUSER||'","'||OLDDTECRT||'","'||OLDLSTUPUSER||'","'||OLDZLSTUPDT||'","'||OLDUSRPRF||'","'||OLDJOBNM||'","'||OLDDATIME||'","'||OLDVALIDFLAG||'","'||NEWCLNTCOY||'","'||NEWCLNTNUM||'","'||NEWBRUPDTE||'","'||NEWDISCHDT||'","'||NEWCRTUSER||'","'||NEWDTECRT||'","'||NEWLSTUPUSER||'"' from  VM1DTA.AUDIT_BRUPPF;
spool off;
