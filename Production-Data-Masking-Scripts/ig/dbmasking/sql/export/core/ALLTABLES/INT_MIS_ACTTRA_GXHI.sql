set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/INT_MIS_ACTTRA_GXHI.sql;
select /*+ paralle(10) */'"'||Z_CHDRNUM||'","'||Z_EFDATE||'","'||Z_DTETRM||'","'||CHDRNUM||'","'||MBRNO||'","'||EFFDATE||'","'||DTETRM||'","'||PRODTYP||'","'||ZINSTYPE||'","'||ZWAITPEDT||'","'||SYSTIME||'"' from  VM1DTA.INT_MIS_ACTTRA_GXHI;
spool off;
