set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ANUMPF_11222018_DONOTDELETE.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||PREFIX||'","'||COMPANY||'","'||GENKEY||'","'||AUTONUM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ANUMPF_11222018_DONOTDELETE;
spool off;
