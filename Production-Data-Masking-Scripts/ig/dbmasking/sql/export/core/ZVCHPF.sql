set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZVCHPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CLTPHONE01||'","'||CLTPHONE02||'"' from VM1DTA.ZVCHPF;
spool off;
