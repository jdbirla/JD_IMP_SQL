set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZIIAPF.sql;
select /*+ paralle(10) */'"'||SYS_STSELL$MSDTQPRZ$CTF3MP9T1X||'","'||BILLNO||'","'||CHDRNUM||'","'||ZAGNTSEQ||'","'||AGNTNUM||'","'||CMRATE||'","'||SPLITC||'","'||ZCONSTAX||'","'||ZCOMMAMT||'","'||ZSPLTPRM||'","'||ZENDCDE||'","'||CNTTYPE||'","'||ZRPTYPE||'","'||ZPOLCLAS||'","'||ZINSTYPE||'","'||ACYR||'","'||ACMN||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||NOCOMNFLG||'","'||MTOTPREM||'"' from  VM1DTA.ZIIAPF;
spool off;
