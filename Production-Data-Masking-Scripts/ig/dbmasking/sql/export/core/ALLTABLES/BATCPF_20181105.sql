set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BATCPF_20181105.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BATCPFX||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCDE||'","'||BATCBATCH||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BATCPF_20181105;
spool off;
