set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZBDTBD0011.sql;
select /*+ paralle(10) */'"'||CNTTYPE||'","'||PTDATE||'","'||STATCODE||'","'||REASONCD||'","'||MPLNUM||'","'||PAYPLAN||'","'||SINSTNO||'","'||ZMSTID||'","'||ZMSTSNME||'","'||CRDCDE||'","'||CRDNAM||'","'||ZDDRECNO||'","'||THREADNO||'","'||MEMBER_NAME||'","'||UNIQUE_NUMBER||'","'||ZCOLM||'","'||ZFACTHUS||'","'||TFRDATE||'","'||BTDATE||'","'||BATCACTMN||'","'||BATCACTYR||'","'||CHDRNUM||'","'||INSTFROM||'","'||INSTTO||'","'||SUMINSU||'","'||APREM||'","'||PPREM||'","'||DPREM||'","'||ZNOSHFT||'","'||ZCRDTYPE||'","'||CRDTCARD||'","'||BANKKEY||'","'||BANKACCKEY||'","'||BNKACTTYP||'","'||ZENDCDE||'"' from  VM1DTA.ZBDTBD0011;
spool off;
