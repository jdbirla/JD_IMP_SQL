set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZAGPPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZAGPTPFX||'","'||ZAGPTCOY||'","'||ZAGPTNUM||'","'||VALIDFLAG||'","'||PROVSTAT||'","'||EFFDATE||'","'||ZCOLRATE||'","'||CRTUSER||'","'||DTECRT||'","'||AUTHBY||'","'||AUTHDATE||'","'||TERDATE||'","'||AGNTPFX||'","'||AGNTCOY||'","'||GAGNTSEL01||'","'||GAGNTSEL02||'","'||GAGNTSEL03||'","'||GAGNTSEL04||'","'||GAGNTSEL05||'","'||SPLITC01||'","'||SPLITC02||'","'||SPLITC03||'","'||SPLITC04||'","'||SPLITC05||'","'||ADMNOPER01||'","'||ADMNOPER02||'","'||ADMNOPER03||'","'||ADMNOPER04||'","'||ADMNOPER05||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZAGPPF;
spool off;
