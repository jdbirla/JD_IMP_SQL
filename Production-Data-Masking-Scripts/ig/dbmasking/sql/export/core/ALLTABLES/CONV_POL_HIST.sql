set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/CONV_POL_HIST.sql;
select /*+ paralle(10) */'"'||PH_CHDRNUM||'","'||GC_CHDRNUM||'","'||ZPRVCHDR||'"' from  VM1DTA.CONV_POL_HIST;
spool off;
