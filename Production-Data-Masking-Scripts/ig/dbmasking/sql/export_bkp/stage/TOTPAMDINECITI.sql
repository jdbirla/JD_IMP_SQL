set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMDINECITI.csv;
select '"'||RECIDXDINCIT||'","'||CLTPHONE01||'","'||PHZKANASNM||'","'||PHZKANAGNM||'","'||INSZKANASNM||'","'||INSZKANAGNM||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||LSURNAME||'","'||LGIVNAME||'","'||CRDTCARD||'"' from STAGEDBUSR.TOTPAMDINECITI;
spool off;
