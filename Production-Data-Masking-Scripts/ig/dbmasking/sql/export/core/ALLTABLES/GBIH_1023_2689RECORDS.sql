set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/GBIH_1023_2689RECORDS.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BILLNO||'","'||CHDRCOY||'","'||CHDRNUM||'","'||SUBSCOY||'","'||SUBSNUM||'","'||BILLTYP||'","'||PRBILFDT||'","'||PRBILTDT||'","'||TERMID||'","'||USER_T||'","'||TRDT||'","'||TRTM||'","'||TRANNO||'","'||INSTNO||'","'||PBILLNO||'","'||GRPGST||'","'||GRPSDUTY||'","'||VALIDFLAG||'","'||BILFLAG||'","'||RDOCPFX||'","'||RDOCCOY||'","'||RDOCNUM||'","'||NRFLG||'","'||TGTPCNT||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||MBRNO||'","'||PREMOUT||'","'||BILLDUEDT||'","'||REVFLAG||'","'||ZGSTCOM||'","'||ZGSTAFEE||'","'||ZACMCLDT||'","'||ZBKTRFDT||'","'||ZCOLFLAG||'","'||ZPOSBDSM||'","'||ZPOSBDSY||'","'||ZSTPBLYN||'","'||PAYDATE||'"' from  VM1DTA.GBIH_1023_2689RECORDS;
spool off;
