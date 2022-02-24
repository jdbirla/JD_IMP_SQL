set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZIRHPF.csv;
select /*+ paralle(10) */ '"'||BILLNO||'","'||CRDTCARD||'","'||BANKACCKEY||'"'  from VM1DTA.ZIRHPF;
spool off;
