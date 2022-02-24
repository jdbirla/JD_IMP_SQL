set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/PRINTLNG.sql;
select /*+ paralle(10) */'"'||DATAAREA_ID||'","'||DATAAREA_DATA||'","'||DATAAREA_TYPE||'","'||DATAAREA_LENGTH||'","'||DATAAREA_DECS||'"' from  VM1DTA.PRINTLNG;
spool off;
