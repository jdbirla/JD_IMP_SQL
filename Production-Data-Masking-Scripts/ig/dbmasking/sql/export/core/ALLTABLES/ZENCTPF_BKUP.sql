set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZENCTPF_BKUP.sql;
select /*+ paralle(10) */'"'||ZPOLNMBR||'","'||ZENDCDE||'","'||ZCRDTYPE||'","'||ZCNBRFRM||'","'||ZCNBRTO||'","'||ZMSTID||'","'||ZMSTSNME||'","'||ZCCDE||'","'||ZCONSGNM||'","'||UNIQUE_NUMBER||'","'||ZPREFIX||'","'||SEQNO||'","'||ZMSTIDV||'","'||ZMSTSNMEV||'","'||ZCARDDC||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZENCTPF_BKUP;
spool off;
