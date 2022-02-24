set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZIRDPF.csv;
select /*+ paralle(10) */ '"'||CLNTNUM||'","'||CLNTNME||'"' from VM1DTA.ZIRDPF;
spool off;

