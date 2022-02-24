set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZMIEPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||LSURNAME||'"' from VM1DTA.ZMIEPF;
spool off;
