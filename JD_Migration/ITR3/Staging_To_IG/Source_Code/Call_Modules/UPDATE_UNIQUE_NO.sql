/*
  PA Data Migration UPDATE_UNIQUE_NO_CALL
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"
column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;
column SCHEDULENAME new_value I_SCHEDULENAME noprint
select 'UPDATE_UNIQUE_NO' as SCHEDULENAME from dual;
column schedulenumber new_value v_schedulenumber noprint

set head on
set echo off
set feed on
set termout on


spool "&SQL_LOG_PATH.\UPDATE_UNIQUE_NO_CALL_&log_date_text..txt"


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
  I_SCHEDULENAME VARCHAR2(200);
  I_SCHEDULENUMBER VARCHAR2(200);
  I_ZPRVALDYN VARCHAR2(200);
  I_COMPANY VARCHAR2(200);
  I_USRPRF VARCHAR2(200);
  I_BRANCH VARCHAR2(200);
  I_TRANSCODE VARCHAR2(200);
  I_VRCMTERMID VARCHAR2(200);
  START_ID NUMBER;
  END_ID NUMBER;
BEGIN
  I_SCHEDULENAME := NULL;
  I_SCHEDULENUMBER := NULL;
  I_ZPRVALDYN := NULL;
  I_COMPANY := NULL;
  I_USRPRF := NULL;
  I_BRANCH := NULL;
  I_TRANSCODE := NULL;
  I_VRCMTERMID := NULL;
  START_ID := NULL;
  END_ID := NULL;

  DM_NAYOSE_UPDATE_UNIQUE_NUMBER(
    I_SCHEDULENAME => I_SCHEDULENAME,
    I_SCHEDULENUMBER => I_SCHEDULENUMBER,
    I_ZPRVALDYN => I_ZPRVALDYN,
    I_COMPANY => I_COMPANY,
    I_USRPRF => I_USRPRF,
    I_BRANCH => I_BRANCH,
    I_TRANSCODE => I_TRANSCODE,
    I_VRCMTERMID => I_VRCMTERMID,
    START_ID => START_ID,
    END_ID => END_ID
  );
--rollback; 
END;
/


