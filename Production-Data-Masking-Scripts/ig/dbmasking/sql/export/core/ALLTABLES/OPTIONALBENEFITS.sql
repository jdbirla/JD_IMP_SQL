set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/OPTIONALBENEFITS.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||PREMCLS||'","'||BNFTDESC||'","'||BNFTCDE||'","'||SI||'","'||RATE||'","'||PREMIUM||'","'||RSKNO||'","'||TRANNO||'","'||RSKCOY||'","'||USRPRF||'","'||JOBNME||'","'||DATIME||'"' from  VM1DTA.OPTIONALBENEFITS;
spool off;
