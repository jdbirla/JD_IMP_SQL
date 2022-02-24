set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCPNPF.sql;
select /*+ paralle(10) */'"'||SYS_STS2MVYNZC17G0DFVL3VA8N3J7||'","'||SYS_STS7DO##OC5UT7SLHD1$$Y6U$S||'","'||SYS_STSY7UI_ZY$Z0FRDV2H3EUY8W8||'","'||UNIQUE_NUMBER||'","'||ZCMPCODE||'","'||ZPETNAME||'","'||ZENDCDE||'","'||CHDRNUM||'","'||GPLOTYP||'","'||ZAGPTID||'","'||RCDATE||'","'||ZCMPFRM||'","'||ZCMPTO||'","'||ZMAILDAT||'","'||ZACLSDAT||'","'||ZDLVCDDT||'","'||ZVEHICLE||'","'||ZSTAGE||'","'||ZSCHEME01||'","'||ZSCHEME02||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZPOLCLS||'","'||EFFDATE||'","'||ZCRTUSR||'","'||ZAPPDATE||'","'||ZCCODIND||'","'||STATUS||'"' from  VM1DTA.ZCPNPF;
spool off;
