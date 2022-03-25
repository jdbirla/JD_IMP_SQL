


spool JD_Spool_Practice.txt


SET ECHO OFF

set pages 1000
set lines 1000
set feedback on
set timing off
set trimspool on 
SET TRIMOUT ON
--SET AUTOTRACE off
SET COLSEP '|'
SET ERRORLOGGING ON
SET HEADING ON
SET NULL 'NULL'
SET SERVEROUTPUT OFF
SET TERMOUT OFF
SET VERIFY off
--COLUMN CHDRCOY        HEADING 'CHDRCOY|company'

SET ECHO ON
--select * from zinsdtlspf where chdrnum in ('06449930','06449948','06455034') ;

@H:\SIT_STAGE_DATA\Phase-2\Mig_Guide\900_Tools\Dump_IG_Database\Group_Master_Policy_Summary.sql 06449930
SET ECHO OFF
spool off



