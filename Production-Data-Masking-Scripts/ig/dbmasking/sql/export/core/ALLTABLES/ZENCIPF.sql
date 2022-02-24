set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZENCIPF.sql;
select /*+ paralle(10) */'"'||ZENDCDE||'","'||ZBNKFLAG||'","'||ZCCFLAG||'","'||ZCIFFLAG||'","'||ZENFLG1||'","'||ZENFLG2||'","'||BILLIND01||'","'||BILLIND02||'","'||BILLIND03||'","'||BILLIND04||'","'||BILLIND05||'","'||ZJPBFLG||'","'||ZMBRNOID||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZENCIPF;
spool off;
