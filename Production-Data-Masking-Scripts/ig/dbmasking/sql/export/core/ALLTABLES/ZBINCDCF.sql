set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZBINCDCF.sql;
select /*+ paralle(10) */'"'||ZBINCD||'","'||ZNUMCHKFRM||'","'||ZNUMCHKTO||'","'||ZNUMCHKFLG||'","'||ZDSC||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZBINCDCF;
spool off;
