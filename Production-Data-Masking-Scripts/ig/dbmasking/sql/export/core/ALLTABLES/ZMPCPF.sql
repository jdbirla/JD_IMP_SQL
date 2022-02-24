set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZMPCPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||ZAGPTNUM||'","'||EFFDATE||'","'||GPST01||'","'||GPST02||'","'||ZCOLLFEE01||'","'||ZCOLLFEE02||'","'||ZCTAXRAT||'","'||ZCTAXAMT||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZINSTYPE||'","'||EXTRFLAG||'","'||ENTITY||'","'||KEY||'","'||STATUSTYP||'","'||MCOLFEE||'","'||MCOLFCTAX||'"' from  VM1DTA.ZMPCPF;
spool off;
