set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZSTGPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||KANJISURNAME from VM1DTA.ZSTGPF fetch first 5 rows only;
spool off;


spool /opt/ig/hitoku/user/input/abc.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||KANJISURNAME from VM1DTA.ZSTGPF fetch first 5 rows only;
spool off;

