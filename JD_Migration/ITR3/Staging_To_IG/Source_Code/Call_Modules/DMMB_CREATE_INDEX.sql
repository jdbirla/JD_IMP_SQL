---------------------------------------------------------------------------------------
-- File Name	: PRE_DM_STEP.sql
-- Description	: Insert into all DMIGTIT* tables
-- Author       : Jitendra Birla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\PRE_DMMB_INDEX_&log_date_text..txt"


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
  TAB_NAME  varchar2(200);
  ROW_COUNT number;
    v_sqlQuery2       VARCHAR2(500);
	SCHEDULE_NAME VARCHAR2(200 CHAR) := '&1';

BEGIN  

dbms_output.put_line('******************PRE_DMMB_INDEX : START******************************');

  
execute IMMEDIATE 'CREATE INDEX pazdclpf_idx1 ON Jd1dta.pazdclpf (zentity)';
execute IMMEDIATE 'CREATE INDEX pazdrppf_idx1 ON Jd1dta.pazdrppf (chdrnum)';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx1 ON Jd1dta.zclepf ( RTRIM(zenspcd01))';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx2 ON Jd1dta.zclepf ( RTRIM(zenspcd02))';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx3 ON Jd1dta.zclepf ( RTRIM(zcifcode))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx1 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zenspcd01))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx2 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zenspcd02))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx3 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zcifcode))';

COMMIT;
dbms_output.put_line('******************PRE_DMMB_INDEX : END******************************');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'PRE_DMMB_INDEX : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('PRE_DMMB_INDEX', 000, p_exitcode, p_exittext, sysdate);
    commit;
     raise;

COMMIT;
  

END;
--@DM2_POST_VAL_STATS.sql '&I_SCHEDULENAME' '&v_schedulenumber';
--/
--exit;

