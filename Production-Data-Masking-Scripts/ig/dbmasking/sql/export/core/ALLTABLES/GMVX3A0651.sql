set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GMVX3A0651.sql;
select /*+ paralle(10) */'"'||OLDDTA||'","'||NEWDTA||'","'||RESNCD||'","'||CHGTYPE||'","'||RIPRIOR||'","'||ONPREFLG||'","'||MEMBER_NAME||'","'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||TRANNO||'","'||REFKEY||'","'||FUNCCODE||'","'||RFMT||'","'||EFFDATE||'","'||GMOVTDT||'"' from  VM1DTA.GMVX3A0651;
spool off;
