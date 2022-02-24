set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/PRODCODE_REF.sql;
select /*+ paralle(10) */'"'||PRODCODE||'","'||PRODCODETYPE||'"' from  VM1DTA.PRODCODE_REF;
spool off;
