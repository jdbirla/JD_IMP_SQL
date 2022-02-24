set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ERORPF.sql;
select /*+ paralle(10) */'"'||SYS_STSWK$Q1_MTSOMAQGVW5_85G$D||'","'||UNIQUE_NUMBER||'","'||ERORPFX||'","'||ERORCOY||'","'||ERORLANG||'","'||ERORPROG||'","'||EROREROR||'","'||ERORDESC||'","'||TRDT||'","'||TRTM||'","'||USERID||'","'||TERMINALID||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||ERORFILE||'"' from  VM1DTA.ERORPF;
spool off;
