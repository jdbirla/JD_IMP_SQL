set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZPDAPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||ZKANASNM01||'","'||ZKANAGNM01||'","'||LSURNAME01||'","'||LGIVNAME01||'","'||CLNTPHONE01||'","'||CLNTPHONE02||'","'||FAXNO01||'","'||RMBLPHONE01||'","'||ZKANADDR01||'","'||CLTADDR01||'","'||ZKANADDR02||'","'||CLTADDR02||'","'||ZKANADDR03||'","'||CLTADDR03||'","'||ZKANADDR04||'","'||CLTADDR04||'","'||BANKACCKEY01||'","'||BANKACCDSC01||'","'||ZKANASNM02||'","'||ZKANAGNM02||'","'||LSURNAME02||'","'||LGIVNAME02||'","'||CLNTPHONE03||'","'||CLNTPHONE04||'","'||FAXNO02||'","'||RMBLPHONE02||'","'||ZKANADDR05||'","'||CLTADDR05||'","'||ZKANADDR06||'","'||CLTADDR06||'","'||ZKANADDR07||'","'||CLTADDR07||'","'||ZKANADDR08||'","'||CLTADDR08||'"' from VM1DTA.ZPDAPF;
spool off;
