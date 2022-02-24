set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/USRDPF.sql;
select /*+ paralle(10) */'"'||'","'||UNIQUE_NUMBER||'","'||USERID||'","'||USERNUM||'","'||GROUPNAME||'","'||USTRDATE||'","'||UENDDATE||'","'||VALIDFLAG||'","'||LANGUAGE||'","'||COMPANY||'","'||BRANCH||'","'||PROFTYPE||'","'||ACTIVEFLAG||'","'||RFLAG||'","'||PASSWORD||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||MLOGIN||'","'||CONCUSERS||'","'||LONGUSERID||'"' from  VM1DTA.USRDPF;
spool off;
