set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/RAPA_TIERINFO.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||PRODTYP||'","'||EFFDATE||'","'||DTEATT||'","'||DTETRM||'","'||SUMINSU||'","'||DPREM||'","'||TRANNO||'","'||ZTIERNO||'","'||PLANCODE||'","'||BTDATE||'","'||RECSTATUS||'","'||CUTOFDT||'","'||MONCNT||'","'||CAL_PREM||'","'||LREFDATE||'","'||CLIENTIP||'","'||LOAD_DTM||'"' from  VM1DTA.RAPA_TIERINFO;
spool off;
