set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/LF_FIELDS.sql;
select /*+ paralle(10) */'"'||VIEWNAME||'","'||RECORDFORMAT||'","'||FIELDSEQ||'","'||FIELDNAME||'","'||JOINSEQ||'","'||KEYWORDS||'","'||FIELDTYPE||'","'||FIELDLENGTH||'"' from  VM1DTA.LF_FIELDS;
spool off;
