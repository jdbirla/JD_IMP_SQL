set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GMVX3A0690.sql;
select /*+ paralle(10) */'"'||CHGTYPE||'","'||RIPRIOR||'","'||ONPREFLG||'","'||MEMBER_NAME||'","'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANNO||'","'||REFKEY||'","'||FUNCCODE||'","'||RFMT||'","'||EFFDATE||'","'||GMOVTDT||'","'||OLDDTA||'","'||NEWDTA||'","'||RESNCD||'"' from  VM1DTA.GMVX3A0690;
spool off;