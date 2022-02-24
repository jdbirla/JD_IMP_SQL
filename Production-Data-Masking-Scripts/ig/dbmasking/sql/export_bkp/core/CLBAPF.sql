set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/CLBAPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||BANKACCKEY||'","'||BANKACCDSC||'"' from VM1DTA.CLBAPF;
spool off;
