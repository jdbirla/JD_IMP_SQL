  /**************************************************************************************************************************
  * File Name        : DM2_POST_VAL_STATS
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This SQL will generate Post-Validation report
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0316     JDB   PV1   New Designed and developed
  
  ********************************************************************************************************************************/
/*
  PA Data Migration Post-validation report:DM2_POST_VAL_STATS
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Report"
column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head off
set echo off
set feed off
set termout on


spool "&SQL_LOG_PATH.\&1 _&2 _POST_VAL_REPORT.txt"


set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed off
set echo off
set termout on

DECLARE
I_SCHEDULENAME VARCHAR2(50 CHAR) := '&1';
I_SCHEDULE_NO number:= '&2';
 cursor C_BATCH_POST is  
select reftab,schedule_num,schedule_Name , count(1) as nocount from dmpvalpf where schedule_Name = I_SCHEDULENAME and  schedule_num =I_SCHEDULE_NO group by reftab,schedule_num,schedule_Name ;
 
BEGIN
 		

		dbms_output.put_line('*************************************************************************');
	    dbms_output.put_line('**********************Post-Validation Stats:*****************************');
	    dbms_output.put_line('*************************************************************************');
	   

	   dbms_output.put_line(CHR(10));

	   
	    dbms_output.put_line('******************Post-Validation Stats: : Start ************************');


		dbms_output.put_line(' Schedule Name   :' || I_SCHEDULENAME);
		dbms_output.put_line(' Schedule num    :' || I_SCHEDULE_NO);

FOR REC_POST IN C_BATCH_POST LOOP

	    
		dbms_output.put_line(' Reference table :' || REC_POST.reftab);
	    dbms_output.put_line(' Error count     :' || REC_POST.nocount);
		



    END LOOP;
	    dbms_output.put_line('******************Post-Validation Stats: : END ************************');
	    



	    
			


END;

