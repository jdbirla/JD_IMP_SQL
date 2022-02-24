set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/LF_SELECT_OMIT.sql;
select /*+ paralle(10) */'"'||VIEWNAME||'","'||RECORDFORMAT||'","'||SELECTSEQ||'","'||AND_OR||'","'||FIELDA||'","'||COMPARISION||'","'||FIELDB||'","'||OINSEQ||'","'||OMIT_SEL||'"' from  VM1DTA.LF_SELECT_OMIT;
spool off;
