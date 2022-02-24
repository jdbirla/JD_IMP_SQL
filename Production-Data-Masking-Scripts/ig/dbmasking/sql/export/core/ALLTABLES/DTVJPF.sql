set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVJPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||VIEWNAME||'","'||JOINSEQ||'","'||FILN||'","'||JOINFLD01||'","'||JOINFLD02||'","'||JOINFLD03||'","'||JOINFLD04||'","'||JOINFLD05||'","'||JOINFLD06||'","'||JOINFLD07||'","'||JOINFLD08||'","'||JOINFLD09||'","'||JOINFLD10||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.DTVJPF;
spool off;
