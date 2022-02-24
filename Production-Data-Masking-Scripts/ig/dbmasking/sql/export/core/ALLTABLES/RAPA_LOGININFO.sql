set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/RAPA_LOGININFO.sql;
select /*+ paralle(10) */'"'||USERID||'","'||VALIDFLG||'","'||AUTHPASS||'","'||CLIENTIP||'","'||LOAD_DTM||'"' from  VM1DTA.RAPA_LOGININFO;
spool off;
