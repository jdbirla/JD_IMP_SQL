set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/SWNDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||FDID||'","'||SCRNAME||'","'||WNTP||'","'||WNST||'","'||CFID||'","'||TABW||'","'||TCOY||'","'||ERRCD||'","'||PROG01||'","'||PROG02||'","'||PROG03||'","'||PROG04||'","'||ADDF01||'","'||ADDF02||'","'||ADDF03||'","'||ADDF04||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.SWNDPF;
spool off;
