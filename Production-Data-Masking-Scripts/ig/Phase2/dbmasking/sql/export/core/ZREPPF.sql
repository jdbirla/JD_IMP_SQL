set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZREPPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||BANKKEY||'","'||BANKACCDSC||'","'||BANKACOUNT||'"' from VM1DTA.ZREPPF;
spool off;
