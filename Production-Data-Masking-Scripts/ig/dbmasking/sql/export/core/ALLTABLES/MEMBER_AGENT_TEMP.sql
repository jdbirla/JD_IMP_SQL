set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/MEMBER_AGENT_TEMP.sql;
select /*+ paralle(10) */'"'||CHDRNUM||'","'||MASTEREFFDATE||'","'||MEMBEREFFDATE||'","'||MPLNUM||'","'||ZAGPTNUM||'","'||GAGNTSEL||'"' from  VM1DTA.MEMBER_AGENT_TEMP;
spool off;
