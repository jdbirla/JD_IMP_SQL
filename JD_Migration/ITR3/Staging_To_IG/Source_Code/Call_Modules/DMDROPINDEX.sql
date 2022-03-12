/*
  PA Data Migration DMDROPINDEX_CALL.sql
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"

column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;
column SCHEDULENAME new_value I_SCHEDULENAME noprint
select 'DMDROPINDEX' as SCHEDULENAME from dual;
column schedulenumber new_value v_schedulenumber noprint



set head off
set echo off
set feed off
set termout on


spool "&SQL_LOG_PATH.\DMDROPINDEX_CALL_&log_date_text..txt"


PROMPT  ******** 
PROMPT  ******** Migration start ********
PROMPT  ******** 

set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed on
set echo on
set termout on


DECLARE
 
  P_DETAIL_BATCH_ID VARCHAR2(200 CHAR) := '&1';

BEGIN

  DM_SAVE_DROP_INDEX(
    P_DETAIL_BATCH_ID => P_DETAIL_BATCH_ID
  );
--rollback; 
END;

/
--@DM2_POST_VAL_STATS.sql '&I_SCHEDULENAME' '&v_schedulenumber';
--/
--exit;

