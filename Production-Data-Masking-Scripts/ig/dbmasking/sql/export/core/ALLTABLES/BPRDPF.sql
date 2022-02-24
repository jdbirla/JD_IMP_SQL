set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BPRDPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||COMPANY||'","'||BPROCESNAM||'","'||BERLSTRTIM||'","'||BLATSTRTIM||'","'||BPROGRAM||'","'||BCOMANDSTG||'","'||BTHRDSTPRC||'","'||BTHRDSSPRC||'","'||BPARPPROG||'","'||RRULE||'","'||BAUTHCODE||'","'||BCHCLSFLG||'","'||BDEFBRANCH||'","'||BSCHEDPRTY||'","'||BSYSJOBPTY||'","'||BSYSJOBTIM||'","'||BPSYSPAR01||'","'||BPSYSPAR02||'","'||BPSYSPAR03||'","'||BPSYSPAR04||'","'||BPSYSPAR05||'","'||BCYCPERCMT||'","'||BPRCRUNLIB||'","'||BPRESTMETH||'","'||BCRITLPROC||'","'||BMAXCYCTIM||'","'||MULBRN||'","'||MULBRNTP||'","'||PRODCODE||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BPRDPF;
spool off;
