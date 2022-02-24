set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GIDTPF.sql;
select /*+ paralle(10) */'"'||GRPSDUTY||'","'||GSTFLAG||'","'||ISSDATE||'","'||JOBNM||'","'||JOBNOUD||'","'||REFTRANNO||'","'||TERMID||'","'||TODOCNO||'","'||TRANNO||'","'||TRDT||'","'||TRTM||'","'||USER_T||'","'||USRPRF||'","'||ISSUEOPT||'","'||ZPOLEXTDT||'","'||ZEXTFLAG||'","'||UNIQUE_NUMBER||'","'||BATCACTMN||'","'||BATCACTYR||'","'||BATCBATCH||'","'||BATCBRN||'","'||BATCCOY||'","'||BATCPFX||'","'||BATCTRCDE||'","'||CHDRCOY||'","'||CHDRNUM||'","'||DATIME||'","'||FRDOCNO||'","'||GFNFLAG||'"' from  VM1DTA.GIDTPF;
spool off;
