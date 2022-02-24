set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZESRSPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZENDSCID||'","'||SEQNO||'","'||ZESRULE||'","'||ZFIXDATE||'","'||ZNOFMONTH||'","'||ZPMMONTH||'","'||ZNOFDAY||'","'||ZBUZFLG||'","'||ZPMDAY||'","'||ZPMWEHO||'","'||VALIDFLAG||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZESRSPF;
spool off;
