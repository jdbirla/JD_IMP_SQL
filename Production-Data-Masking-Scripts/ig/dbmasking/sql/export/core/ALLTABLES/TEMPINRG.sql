set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/TEMPINRG.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDSCID||'","'||ZLTMIRDT||'","'||ZLFNIRDT||'","'||ZPOSBDSY||'","'||ZPOSBDSM||'","'||ZALTRNDTAL||'","'||ZTEMIRDT||'","'||ZFNLIRDT||'","'||ZPPCDE||'","'||ZFACTHUS||'","'||ZENDCDE||'","'||ZPOLTDATE||'","'||GCHPCHDRCOY||'","'||GCHPCHDRNUM||'","'||ZPLANCLS||'","'||ZPGPFRDT||'","'||ZCOLMCLS||'","'||ZPENDDT||'","'||ZPGPTODT||'","'||MPLNUM||'","'||GCHDCHDRNUM||'","'||STATCODE||'","'||EFFDCLDT||'","'||CNTTYPE||'","'||BTDATE||'","'||PTDATE||'","'||GCHDCHDRCOY||'","'||OCCDATE||'","'||TRANNO||'"' from  VM1DTA.TEMPINRG;
spool off;
