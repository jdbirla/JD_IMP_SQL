set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/UTRCPF.sql;
select /*+ paralle(10) */'"'||SYS_STS$44#JIWZOM0W0TC6B3O#XJ_||'","'||SYS_STSN57I3K#WT#WKN87UW##B2PH||'","'||UNIQUE_NUMBER||'","'||USERID||'","'||COMPANY||'","'||TRANSCD||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.UTRCPF;
spool off;
