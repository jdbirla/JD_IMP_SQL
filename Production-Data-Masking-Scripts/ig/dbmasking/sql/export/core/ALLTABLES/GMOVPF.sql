set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GMOVPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||EFFDATE||'","'||TRANNO||'","'||USER_T||'","'||TRDT||'","'||TRTM||'","'||TERMID||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCDE||'","'||BATCBATCH||'","'||OLDDTA||'","'||NEWDTA||'","'||FUNCCODE||'","'||REFKEY||'","'||RFMT||'","'||CHGTYPE||'","'||RIPRIOR||'","'||ONPREFLG||'","'||FACHOLD||'","'||PLANVFLG||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||THREADNO||'"' from  VM1DTA.GMOVPF;
spool off;
