set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZESRPF.sql;
select /*+ paralle(10) */'"'||SYS_STS8KVGJBIEM_EQ8VDQ6AQJGFT||'","'||UNIQUE_NUMBER||'","'||ZENDSCID||'","'||ZACSHED||'","'||ZSYSIMP01||'","'||ZSYSIMP02||'","'||ZSYSIMP03||'","'||VALIDFLAG||'","'||BNKACCTYP||'","'||STRTDT||'","'||LASTYY||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZESRPF;
spool off;
