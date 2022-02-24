set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZENDRPF.sql;
select /*+ paralle(10) */'"'||ZENDCDE||'","'||ZENDCDST||'","'||ZENCDEDT||'","'||ZENCDSDT||'","'||ZFACTHUS||'","'||ZPRMFQ||'","'||ZBINCD||'","'||ZENDSCID||'","'||ZENDFH||'","'||ZCOLM||'","'||ZCCDE||'","'||ZPPCDE||'","'||CRUSER||'","'||ZAPPUSR||'","'||ZCLNTID||'","'||ZPODEXT||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||SYS_STS##8HIN9FNGGFCOVHTE7QBGQ||'","'||SYS_STST6#W9223EOWZI7Z8WENP#FR||'"' from  VM1DTA.ZENDRPF;
spool off;
