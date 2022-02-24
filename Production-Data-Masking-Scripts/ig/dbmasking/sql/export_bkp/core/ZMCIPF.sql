set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZMCIPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CRDTCARD||'"' from VM1DTA.ZMCIPF;
spool off;
