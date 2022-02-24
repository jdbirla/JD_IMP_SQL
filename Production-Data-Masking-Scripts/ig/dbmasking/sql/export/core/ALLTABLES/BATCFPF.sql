set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BATCFPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BATCPFX||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCDE||'","'||BATCBATCH||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BATCFPF;
spool off;
