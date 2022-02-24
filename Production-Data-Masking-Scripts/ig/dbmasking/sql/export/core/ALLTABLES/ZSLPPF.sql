set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZSLPPF.sql;
select /*+ paralle(10) */'"'||ZSALPLAN||'","'||ZINSTYPE||'","'||PRODTYP||'","'||SUMINS||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZCOVRID||'","'||ZIMBRPLO||'"' from  VM1DTA.ZSLPPF;
spool off;
