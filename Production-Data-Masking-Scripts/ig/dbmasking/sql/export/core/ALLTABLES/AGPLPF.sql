set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/AGPLPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||AGNTPFX||'","'||AGNTCOY||'","'||AGNTNUM||'","'||ARCON||'","'||CRLIMIT||'","'||CREDTERM||'","'||EXPNOT||'","'||LICENCE||'","'||RIDESC||'","'||RLRPFX||'","'||RLRCOY||'","'||RLRACC||'","'||STLBASIS||'","'||STREQ||'","'||SRDATE||'","'||DATEEND||'","'||ZSTMTOSIND||'","'||ZTOFLG||'","'||ACCSRC||'","'||AGTLICNO||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||GSTREG||'","'||LICNEXDT||'","'||LOB||'","'||VALIDFLAG||'","'||AGNTSTATUS||'","'||AGSTDATE||'","'||TMPCRLMT||'","'||STRTDATE||'","'||ENDDATE||'","'||VMAXCOM||'","'||Z6SLFINV||'","'||APRVDATE||'","'||VATFLG||'"' from  VM1DTA.AGPLPF;
spool off;
