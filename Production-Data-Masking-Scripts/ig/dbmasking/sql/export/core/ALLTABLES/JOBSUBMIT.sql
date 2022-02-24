set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/JOBSUBMIT.sql;
select /*+ paralle(10) */'"'||JOBPARA5||'","'||JOBPARA6||'","'||JOBPARA7||'","'||JOBPARA8||'","'||BATCHCONTY||'","'||JOBSUBTIM||'","'||JOBSTRTIM||'","'||JOBENDTIM||'","'||JOBNAME||'","'||JOBDESC||'","'||JOBQUEUE||'","'||JOBPRITY||'","'||RTGDTA||'","'||LOGOPTION||'","'||LOGCLPGM||'","'||HOLD||'","'||USERNAME||'","'||INGMSGRPY||'","'||MSGQ||'","'||SYSLIBL||'","'||CURLIB||'","'||INLLIBL||'","'||RQSDTA||'","'||COMPANY||'","'||UNIQUE_NUMBER||'","'||JOBCOMMAND||'","'||JOBSTATUS||'","'||JOBPARANUM||'","'||JOBPARA1||'","'||JOBPARA2||'","'||JOBPARA3||'","'||JOBPARA4||'"' from  VM1DTA.JOBSUBMIT;
spool off;
