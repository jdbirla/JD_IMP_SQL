set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/CLRRPF.sql;
select /*+ paralle(10) */'"'||SYS_STSTOXMJPZKQ3MLMLAV7A9HC0W||'","'||CLNTCOY||'","'||CLNTNUM||'","'||CLRRROLE||'","'||FOREPFX||'","'||FORECOY||'","'||FORENUM||'","'||USED2B||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||UNIQUE_NUMBER||'","'||CLNTPFX||'"' from  VM1DTA.CLRRPF;
spool off;
