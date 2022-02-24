set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/MV_ZMCIPF_CRDT.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CRDTCARD||'"' from VM1DTA.MV_ZMCIPF_CRDT;
spool off;
