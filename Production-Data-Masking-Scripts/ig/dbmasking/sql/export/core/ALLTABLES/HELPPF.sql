set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/HELPPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||HELPPFX||'","'||HELPCOY||'","'||HELPLANG||'","'||HELPTYPE||'","'||HELPPROG||'","'||HELPITEM||'","'||HELPSEQ||'","'||TRANID||'","'||VALIDFLAG||'","'||HELPLINE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.HELPPF;
spool off;
