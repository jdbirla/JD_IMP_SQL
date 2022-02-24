set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZPCMPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||EFFDATE||'","'||GPST||'","'||GAGNTSEL||'","'||ZINSTYPE||'","'||SPLITC||'","'||CMRATE||'","'||COMMN||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCD||'","'||BATCBATCH||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZAGTGPRM||'","'||ZAGTRPRM||'","'||ZCTAXRAT||'","'||ZCTAXAMT||'","'||BATCPFX||'","'||EXTRFLAG||'","'||ENTITY||'","'||KEY||'","'||STATUSTYP||'","'||MCOMMN||'","'||MCOMCTAX||'","'||NOCOMNFLG||'","'||MTOTPREM||'"' from  VM1DTA.ZPCMPF;
spool off;
