  /**************************************************************************************************************************
  * File Name        : DM2_BATCH_MONITOR
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This SQL will generate Batch Monitoring report
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0316     JDB   BM1   New Designed and developed
  
  ********************************************************************************************************************************/
/*
  PA Data Migration Batch monitor
*/

--DEFINE SQL_LOG_PATH = "/opt/ig/Datamigration/jpafsn/workspace/logs"
column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head off
set echo off
set feed off
set termout on


spool "BATCH_MONITOR.txt"


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
 v_errorCount NUMBER :=0;
 cursor C_BATCH_MON is  
   select * from DMBMONPF where BATCH_NAME=I_SCHEDULENAME and JOB_NUM=I_SCHEDULE_NO ;
   
 cursor C_BATCH_ERR is  
   select * from DMBERPF where SCHEDULE_NAME=I_SCHEDULENAME and JOB_NUM=I_SCHEDULE_NO;

BEGIN
	   
	    dbms_output.put_line('*************************************************************************');
	    dbms_output.put_line('**********************Batch Monitoring Report***************************');
	    dbms_output.put_line('*************************************************************************');


	    dbms_output.put_line(CHR(10)); 

	    dbms_output.put_line('******************Batch Monitoring : START ******************************');

	   dbms_output.put_line(CHR(13)); 

FOR REC_MON IN C_BATCH_MON LOOP

          
	        dbms_output.put_line(' BATCH_NAME :' || REC_MON.BATCH_NAME);
		dbms_output.put_line(' JOB_NUM    :' || REC_MON.JOB_NUM);
		dbms_output.put_line(' START_TIME :' || REC_MON.START_TIMESTAMP);
	        dbms_output.put_line(' END_TIME   :' || REC_MON.END_TIMESTAMP);
		dbms_output.put_line(' TOTAL_TIME :' || REC_MON.TOTAL_TIME);
		dbms_output.put_line(' ZPRVALDYN  :' || REC_MON.ZPRVALDYN);
		dbms_output.put_line(' SCHD_STATUS:' || REC_MON.SCHD_STATUS);
		dbms_output.put_line(' USRPRF     :' || REC_MON.USRPRF);
		dbms_output.put_line(' REMARKS    :' || REC_MON.REMARKS);



    END LOOP;
	    dbms_output.put_line(CHR(13)); 
		dbms_output.put_line('******************Batch Monitoring : END *******************************');
	    
				    dbms_output.put_line(CHR(10));


		dbms_output.put_line('******************Ora Error : START ************************************');

 FOR REC_ERR IN C_BATCH_ERR LOOP
	    dbms_output.put_line(' SCHEDULE_NAME :' || REC_ERR.SCHEDULE_NAME);
		dbms_output.put_line(' JOB_NUM       :' || REC_ERR.JOB_NUM);
		dbms_output.put_line(' ERROR_CODE    :' || REC_ERR.ERROR_CODE);
		dbms_output.put_line(' ERROR_TEXT    :' || REC_ERR.ERROR_TEXT);
		dbms_output.put_line(' DATIME        :' || REC_ERR.DATIME);


v_errorCount := v_errorCount+1;
    END LOOP;
	if(v_errorCount = 0)then
			dbms_output.put_line('No Ora error');
	end if;
		dbms_output.put_line('******************Ora Error : END **************************************');

END;

/

exit 0
