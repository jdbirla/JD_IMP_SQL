set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVSPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||VIEWNAME||'","'||RECFORMAT||'","'||SLTSEQ||'","'||ANDOR||'","'||FIELDA||'","'||COMPARISON||'","'||FIELDB||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||JOINSEQ||'","'||OMITSEL||'"' from  VM1DTA.DTVSPF;
spool off;
