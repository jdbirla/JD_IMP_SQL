set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVIPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||VIEWNAME||'","'||RECFORMAT||'","'||KEYSEQ||'","'||FLDNAME||'","'||SORTSEQ||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||JOINSEQ||'","'||TYPE_T||'"' from  VM1DTA.DTVIPF;
spool off;
