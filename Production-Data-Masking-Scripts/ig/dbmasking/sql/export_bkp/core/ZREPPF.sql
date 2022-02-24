set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZREPPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||BANKACCDSC||'"' from VM1DTA.ZREPPF;
spool off;
