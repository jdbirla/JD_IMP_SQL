set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GSTTPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||CHDRCOY||'","'||CNTTYPE||'","'||PRODTYP||'","'||ACCTYP||'","'||AFUND||'","'||GSTTYPE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.GSTTPF;
spool off;
