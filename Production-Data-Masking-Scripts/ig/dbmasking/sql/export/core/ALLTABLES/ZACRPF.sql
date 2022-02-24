set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZACRPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||AGNTPFX||'","'||AGNTCOY||'","'||GAGNTSEL||'","'||VALIDFLAG||'","'||EFFDATE||'","'||ZINSTYP01||'","'||ZINSTYP02||'","'||ZINSTYP03||'","'||ZINSTYP04||'","'||ZINSTYP05||'","'||ZINSTYP06||'","'||ZINSTYP07||'","'||ZINSTYP08||'","'||ZINSTYP09||'","'||ZINSTYP10||'","'||CMRATE01||'","'||CMRATE02||'","'||CMRATE03||'","'||CMRATE04||'","'||CMRATE05||'","'||CMRATE06||'","'||CMRATE07||'","'||CMRATE08||'","'||CMRATE09||'","'||CMRATE10||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ZACRPF;
spool off;
