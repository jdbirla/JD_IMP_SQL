---------------------------------------------------------------------------------------
-- File Name	: UPDATE_ZCLNPF_EFFDT
-- Description	: Update effdate in zclnpf for migration
-- Author       : jbirla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "H:\SIT_STAGE_DATA\Phase-2\Exec_Rehersal\Execution\Code\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\UPDATE_ZCLNPF_EFFDT&log_date_text..txt"


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
 cnt number(2,1) :=0;
   p_exitcode      number;
  p_exittext      varchar2(200);
BEGIN  






DELETE FROM Jd1dta.ZDMBKPZTRA;
INSERT /*+ APPEND */ INTO Jd1dta.ZDMBKPZTRA
 ( select TAB1.UNIQUE_NUMBER,tab1.UNIQUE_NUMBER_01  from ztraPf TAB1,DMUNIQUENOUPDT TAB2  where TAB2.TABLE_NAME='ZTRAPF' and TAB1.UNIQUE_NUMBER = TAB2.TAB_UNIQUE);
COMMIT;


MERGE INTO Jd1dta.ZTRAPF  TAB1 
USING (
(select ZCLN_UNIQUE ,TAB_UNIQUE from DMUNIQUENOUPDT where TABLE_NAME='ZTRAPF' and IS_UPDATED = 'N')) TAB2
ON (TAB1.UNIQUE_NUMBER = TAB2.TAB_UNIQUE)
WHEN MATCHED THEN
UPDATE SET tab1.unique_number_01 = tab2.ZCLN_UNIQUE;

 
COMMIT;

MERGE INTO Jd1dta.DMUNIQUENOUPDT  TAB1 
USING (
(select ZTRA_UNIQUE_NUMBER  from ZDMBKPZTRA)) TAB2
ON (TAB1.TAB_UNIQUE = TAB2.ZTRA_UNIQUE_NUMBER and TAB1.TABLE_NAME='ZTRAPF')
WHEN MATCHED THEN
UPDATE SET tab1.is_updated = 'Y' WHERE tab1.IS_UPDATED = 'N';

 
COMMIT;





DELETE FROM Jd1dta.zdmbkpzins;
INSERT /*+ APPEND */ INTO Jd1dta.zdmbkpzins
 ( select TAB1.UNIQUE_NUMBER,tab1.UNIQUE_NUMBER_02  from zinsdtlspf TAB1,DMUNIQUENOUPDT TAB2  where TAB2.TABLE_NAME='ZINSDTLSPF' and TAB1.UNIQUE_NUMBER = TAB2.TAB_UNIQUE);
COMMIT;

MERGE INTO Jd1dta.zinsdtlspf  TAB1 
USING (
select ZCLN_UNIQUE,TAB_UNIQUE  from DMUNIQUENOUPDT where TABLE_NAME='ZINSDTLSPF'  and IS_UPDATED = 'N') TAB2
ON (TAB1.UNIQUE_NUMBER = TAB2.TAB_UNIQUE)
WHEN MATCHED THEN
UPDATE SET tab1.unique_number_02 = tab2.ZCLN_UNIQUE;

 
COMMIT;

 
MERGE INTO Jd1dta.DMUNIQUENOUPDT  TAB1 
USING (
select ZINS_UNIQUE_NUMBER  from zdmbkpzins) TAB2
ON (TAB1.TAB_UNIQUE = TAB2.ZINS_UNIQUE_NUMBER and TAB1.TABLE_NAME='ZINSDTLSPF')
WHEN MATCHED THEN
UPDATE SET tab1.is_updated = 'Y' WHERE tab1.IS_UPDATED = 'N';

COMMIT;




EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'UPDATE_ZCLNPF_EFFDT : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('G1ZDNAYCLT', 000, p_exitcode, p_exittext, sysdate);
    commit;
     raise;

COMMIT;
  
END;
/
