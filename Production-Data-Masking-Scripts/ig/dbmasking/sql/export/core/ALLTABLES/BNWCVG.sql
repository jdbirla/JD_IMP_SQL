set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BNWCVG.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZBNWREC||'","'||MEMBER_NAME||'"' from  VM1DTA.BNWCVG;
spool off;
