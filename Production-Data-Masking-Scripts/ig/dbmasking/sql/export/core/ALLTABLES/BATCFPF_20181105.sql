set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BATCFPF_20181105.sql;
select /*+ paralle(10) */'"'||DATIME||'","'||UNIQUE_NUMBER||'","'||BATCPFX||'","'||BATCCOY||'","'||BATCBRN||'","'||BATCACTYR||'","'||BATCACTMN||'","'||BATCTRCDE||'","'||BATCBATCH||'","'||USRPRF||'","'||JOBNM||'"' from  VM1DTA.BATCFPF_20181105;
spool off;
