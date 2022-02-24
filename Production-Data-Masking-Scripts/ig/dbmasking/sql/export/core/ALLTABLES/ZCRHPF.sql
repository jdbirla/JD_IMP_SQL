set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZCRHPF.sql;
select /*+ paralle(10) */'"'||SYS_STSJRVCIJ531ZOWNBLOG0POOXZ||'","'||SYS_STSYQFCWU#$5716L05RXRLVW91||'","'||SYS_STSZRH9EPA05$O18JNX$RF7T8M||'","'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CHDRPFX||'","'||CHDRNUM||'","'||BILLNO||'","'||TFRDATE||'","'||DSHCDE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||LNBILLNO||'"' from  VM1DTA.ZCRHPF;
spool off;
