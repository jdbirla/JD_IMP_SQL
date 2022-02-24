set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ANUMPF.sql;
select /*+ paralle(10) */'"'||SYS_STS2KM9VK_9ZQONJR#YF7QTGFN||'","'||SYS_STSPGU2FTC8IWRPH1H8NV7$_QK||'","'||SYS_STSTO$HB#ODOT7V6SVNBN0CCM0||'","'||SYS_STSUPRK5_XYOVQ4U1AA30VWX0O||'","'||UNIQUE_NUMBER||'","'||PREFIX||'","'||COMPANY||'","'||GENKEY||'","'||AUTONUM||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.ANUMPF;
spool off;
