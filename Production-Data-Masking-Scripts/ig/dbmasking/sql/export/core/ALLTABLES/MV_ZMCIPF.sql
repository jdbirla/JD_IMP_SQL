set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MV_ZMCIPF.sql;
select /*+ paralle(10) */'"'||ZENSPCD02||'","'||ZCIFCODE||'","'||CRDTCARD||'","'||BANKACCKEY01||'","'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||ZENDCDE||'","'||ZENSPCD01||'"' from  VM1DTA.MV_ZMCIPF;
spool off;
