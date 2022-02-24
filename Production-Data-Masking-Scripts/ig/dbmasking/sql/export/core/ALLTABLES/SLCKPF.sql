set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/SLCKPF.sql;
select /*+ paralle(10) */'"'||SYS_STS4EKNLRJQS#ASNIZ75SIBH7P||'","'||PROCTRANCD||'","'||USER_T||'","'||TERMID||'","'||TRTM||'","'||TRDT||'","'||SYSJOB||'","'||SYSUSER||'","'||SYSNBR||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||SCHNOTHRDNO||'","'||UNIQUE_NUMBER||'","'||ENTTYP||'","'||COMPANY||'","'||ENTITY||'","'||LCKSTS||'"' from  VM1DTA.SLCKPF;
spool off;
