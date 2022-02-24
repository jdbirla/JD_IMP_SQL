set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TOTPAMVALCHKD.csv;
select '"'||RECIDXVALCHK||'","'||ZMSTSNME||'","'||KANANME||'","'||KANJINME||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||KANJICLTADDR||'"' from STAGEDBUSR.TOTPAMVALCHKD;
spool off;
