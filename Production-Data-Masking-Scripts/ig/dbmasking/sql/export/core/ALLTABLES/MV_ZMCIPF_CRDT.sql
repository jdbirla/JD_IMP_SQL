set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MV_ZMCIPF_CRDT.sql;
select /*+ paralle(10) */'"'||YEARTO||'","'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||EFFDATE||'","'||TRANNO||'","'||CRDTCARD||'","'||MTHTO||'"' from  VM1DTA.MV_ZMCIPF_CRDT;
spool off;
