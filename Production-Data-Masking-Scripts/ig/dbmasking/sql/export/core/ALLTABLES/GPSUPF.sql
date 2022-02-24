set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GPSUPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRNUM||'","'||SUBSCOY||'","'||SUBSNUM||'","'||DTEATT||'","'||DTETRM||'","'||REASONTRM||'","'||LNBILLNO||'","'||LABILLNO||'","'||LPBILLNO||'","'||PTDATE||'","'||PTDATEAB||'","'||TERMID||'","'||USER_T||'","'||TRDT||'","'||TRTM||'","'||TRANNO||'","'||SCHDFLG||'","'||MANDREF||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||SINFDTE||'"' from  VM1DTA.GPSUPF;
spool off;
