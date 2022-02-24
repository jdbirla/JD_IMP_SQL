set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZMCIPF_TEMP.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CRDTCARD||'","'||BANKACCKEY01||'","'||BANKACCDSC01||'","'||BANKACCDSC02||'"' from  VM1DTA.ZMCIPF_TEMP;
spool off;
