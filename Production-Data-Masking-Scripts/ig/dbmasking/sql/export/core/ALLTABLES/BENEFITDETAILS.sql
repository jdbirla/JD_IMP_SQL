set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BENEFITDETAILS.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||BNFTDESC||'","'||BNFTCDE||'","'||MAXDAY||'","'||MAXVIST||'","'||MAXSI||'","'||TOTSI||'","'||CHDRNUM||'","'||PREMCLS||'","'||SITYPE||'"' from  VM1DTA.BENEFITDETAILS;
spool off;
