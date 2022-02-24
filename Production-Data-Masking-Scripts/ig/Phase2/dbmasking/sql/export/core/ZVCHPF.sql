set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool /opt/ig/hitoku/user/input/ZVCHPF.csv;
select /*+ paralle(10) */ '"'||UNIQUE_NUMBER||'","'||CLTPHONE01||'","'||CLTPHONE02||'","'||KANJINME||'","'||CLTDOBJP||'","'||KANJICLTADDR||'","'||BANKKEY||'","'||CLTPHONE01||'","'||KANANME||'","'||MEMIDNUM||'","'||CLTDOB||'","'||CLTPCODE||'","'||ZENSPCD01||'","'||ZENSPCD02||'","'||ZCIFCODE||'"' from VM1DTA.ZVCHPF;
spool off;
