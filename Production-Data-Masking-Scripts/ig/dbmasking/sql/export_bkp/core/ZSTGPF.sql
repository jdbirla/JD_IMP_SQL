set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/ZSTGPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||KANJISURNAME||'","'||LSURNAME||'","'||LGIVNAME||'","'||ZKANASNM||'","'||ZKANAGNM||'","'||CLTADDR01||'","'||CLTADDR02||'","'||CLTADDR03||'","'||CLTADDR04||'","'||ZKANADDR01||'","'||ZKANADDR02||'","'||ZKANADDR03||'","'||ZKANADDR04||'","'||CLTPHONE01||'","'||ZIKANSNM||'","'||ZIKANGNM||'","'||ZIKJADR1||'","'||ZIKJADR2||'","'||ZIKJADR3||'","'||ZIKJADR4||'","'||ZIKAADR1||'","'||ZIKAADR2||'","'||ZIKAADR3||'","'||ZIKAADR4||'","'||CRDTCARD||'","'||BANKACCKEY01||'","'||BANKACCKEY02||'","'||BANKACCDSC01||'","'||ZFINAMKJ||'","'||KANJIGIVNAME||'"' from VM1DTA.ZSTGPF;
spool off;
