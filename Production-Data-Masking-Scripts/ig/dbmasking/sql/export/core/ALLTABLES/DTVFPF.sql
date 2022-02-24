set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVFPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||VIEWNAME||'","'||RECFORMAT||'","'||FIELDSEQ||'","'||FLDNAME||'","'||JOINSEQ||'","'||KEYWORDS||'","'||JOBNM||'","'||USRPRF||'","'||DATIME||'","'||TYPE_T||'","'||LENF||'","'||DECIMALS||'"' from  VM1DTA.DTVFPF;
spool off;
