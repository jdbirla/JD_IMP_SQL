/*
  PA Data Migration G1ZDPOLDSH_CALL
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"

column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;
column SCHEDULENAME new_value I_SCHEDULENAME noprint
select 'G1ZDPOLDSH' as SCHEDULENAME from dual;
column schedulenumber new_value v_schedulenumber noprint

SELECT 
      lpad(substr(table_name, 7, 4) , 4, 0) as schedulenumber
      FROM (SELECT table_name
              FROM all_tables
             WHERE owner = 'Jd1dta'
               AND table_name LIKE 'ZDOEPD%'
             ORDER BY table_name DESC)
     WHERE ROWNUM = 1;

set head on
set echo off
set feed on
set termout on


spool "&SQL_LOG_PATH.\G1ZDPOLDSH_POST_VAL_&log_date_text..txt"


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
 I_SCHEDULENAME VARCHAR2(50 CHAR) := 'G1ZDPOLDSH';
  v_last_table_name VARCHAR2(10);
    v_schedulenumber  VARCHAR2(10 CHAR);
BEGIN
 SELECT table_name
      INTO v_last_table_name
      FROM (SELECT table_name
              FROM all_tables
             WHERE owner = 'Jd1dta'
               AND table_name LIKE 'ZDOEPD%'
             ORDER BY table_name DESC)
     WHERE ROWNUM = 1;
	   v_schedulenumber := lpad(substr(v_last_table_name, 7, 4) , 4, 0);
 
 Jd1dta.PV_PD_G1ZDPOLDSH(i_schedulename =>I_SCHEDULENAME,
                  i_schedulenumber => V_SCHEDULENUMBER);
END;
/
@DM2_POST_VAL_STATS.sql '&I_SCHEDULENAME' '&v_schedulenumber';
/


