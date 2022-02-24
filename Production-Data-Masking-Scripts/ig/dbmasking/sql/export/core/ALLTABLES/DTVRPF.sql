set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVRPF.sql;
select /*+ paralle(10) */'"'||RECFORMAT||'","'||FILN||'","'||FORMATSEQ||'","'||FLDPFX||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||UNIQUE_NUMBER||'","'||VIEWNAME||'"' from  VM1DTA.DTVRPF;
spool off;
