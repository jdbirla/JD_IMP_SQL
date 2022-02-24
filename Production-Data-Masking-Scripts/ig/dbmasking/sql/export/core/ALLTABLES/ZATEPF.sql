set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZATEPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BANKKEY01||'","'||BANKACTYP01||'","'||BANKACCKEY01||'","'||BANKKEY02||'","'||BANKACTYP02||'","'||BANKACCKEY02||'","'||EROR||'","'||ERORDSC||'","'||FIELDID||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZATEPF;
spool off;
