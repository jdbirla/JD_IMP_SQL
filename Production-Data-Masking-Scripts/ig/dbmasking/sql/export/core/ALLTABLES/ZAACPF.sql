set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZAACPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||ZAGPTPFX||'","'||ZAGPTCOY||'","'||ZAGPTNUM||'","'||AGNTPFX||'","'||AGNTCOY||'","'||GAGNTSEL||'","'||EFFDATE||'","'||ZINSTYP01||'","'||ZINSTYP02||'","'||ZINSTYP03||'","'||ZINSTYP04||'","'||ZINSTYP05||'","'||CMRATE01||'","'||CMRATE02||'","'||CMRATE03||'","'||CMRATE04||'","'||CMRATE05||'","'||VALIDFLAG||'","'||TERDATE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ZCMPRCNT||'"' from  VM1DTA.ZAACPF;
spool off;
