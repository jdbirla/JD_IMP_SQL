set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GBIH_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRNUM||'","'||BILLNO||'","'||BILLTYP||'","'||ZPOSBDSY||'","'||ZPOSBDSM||'","'||GBIH_ACD||'","'||ZESD_ACD||'"' from  VM1DTA.GBIH_TEMP;
spool off;
