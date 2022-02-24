set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BATCFPF_20180511_1.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BATCPFX||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCDE||'","'||BATCBATCH||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BATCFPF_20180511_1;
spool off;
