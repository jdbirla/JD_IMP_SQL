set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/INT_MIS_ACTTRA_AGENCY_COMM.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||MEMBEREFFDATE||'","'||GAGNTSEL||'","'||COMMISSION||'","'||SYSTIME||'"' from  VM1DTA.INT_MIS_ACTTRA_AGENCY_COMM;
spool off;
