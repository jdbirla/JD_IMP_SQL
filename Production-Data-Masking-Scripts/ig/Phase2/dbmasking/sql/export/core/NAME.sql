set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/NAME.csv;
select /*+ paralle(10) */ '"'||ZRPTYPE||'","'||CRDTCARD||'","'||BANKACCKEY||'"' from VM1DTA.NAME;
spool off;
