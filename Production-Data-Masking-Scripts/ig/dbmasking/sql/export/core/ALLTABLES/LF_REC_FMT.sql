set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/LF_REC_FMT.sql;
select /*+ paralle(10) */'"'||VIEWNAME||'","'||RECORDFORMAT||'","'||FILENAME||'","'||FORMATSEQ||'","'||FIELDPREFIX||'"' from  VM1DTA.LF_REC_FMT;
spool off;
