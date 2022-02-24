set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/NREFPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||SCREEN||'","'||FLDNAME01||'","'||FLDNAME02||'","'||FLDNAME03||'","'||FLDNAME04||'","'||FLDNAME05||'","'||NOTETYPE||'","'||TERMID||'","'||USER_T||'","'||TRDT||'","'||TRTM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.NREFPF;
spool off;
