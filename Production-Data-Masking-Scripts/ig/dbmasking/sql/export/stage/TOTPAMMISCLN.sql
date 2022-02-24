set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/TOTPAMMISCLN.csv;
select '"'||RECIDXCLNT||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||LSURNAME||'","'||LGIVNAME||'","'||ZADDRCD||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||RINTERNET||'"' from STAGEDBUSR.TOTPAMMISCLN;
spool off;
