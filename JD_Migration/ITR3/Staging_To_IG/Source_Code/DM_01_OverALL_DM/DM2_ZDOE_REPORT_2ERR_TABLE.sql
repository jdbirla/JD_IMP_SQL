
  /**************************************************************************************************************************
  * File Name        : DM2_ZDOE_REPORT_2ERR_TABLE
  * Author           : Halake Jayadip
  * Creation Date    : Jan 27, 2021
  * Project          : IGGROUP Jdrich Jdpan
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This SQL will generate Pre-Validation report
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMBL-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0127     JAY   RD1   Modify from DM2_ZDOE_REPORT to cater for 2 Error table 
  
  ********************************************************************************************************************************/
/*
  PA Data Migration pre-validation report:DM2_ZDOE_REPORT_2TAB
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Report"
-- DEFINE SQL_LOG_PATH = "C:\ZurichDM\Execution\Report"
column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head off
set echo off
set feed off
set termout on

spool "&SQL_LOG_PATH.\&1 _&2 _PRE_VAL_REPORT.txt"

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

	I_SCHEDULENAME 	VARCHAR2(50 CHAR) := '&1';
	I_SCHEDULE_NO 	number := '&2';
	v_filenametemp1 VARCHAR2(30) := '&3';
	v_filenametemp2 VARCHAR2(30) := '&4';
	v_prefix_1    	VARCHAR2(2) := '&5';
	v_prefix_2    	VARCHAR2(2) := '&6';

	v_tableNametemp_1 VARCHAR2(10 char) := 'ZDOE' || v_prefix_1 || LPAD(TRIM(I_SCHEDULE_NO), 4, '0');
	v_tableNametemp_2 VARCHAR2(10 char) := 'ZDOE' || v_prefix_2 || LPAD(TRIM(I_SCHEDULE_NO), 4, '0');
	o_ztotOk        NUMBER(16) DEFAULT 0;
	o_ztotNprc      NUMBER(16) DEFAULT 0;
	o_ztotErr       NUMBER(16) DEFAULT 0;
	o_zTotal        NUMBER(16) DEFAULT 0;
	v_fileName      VARCHAR2(30);

	v_sqlQuery1     VARCHAR2(500);
	v_sqlQuery2     VARCHAR2(500);
	v_sqlQuery3     VARCHAR2(500);
  
BEGIN
	   		
	dbms_output.put_line('*************************************************************************');
	dbms_output.put_line('**********************Pre-Validation Stats:******************************');
	dbms_output.put_line('*************************************************************************');

	dbms_output.put_line(CHR(10));

	dbms_output.put_line('******************Pre-Validation Stats for table 1: START *************************');
	
	v_fileName := '''' || v_filenametemp1 || '''';

	v_sqlQuery1 := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNametemp_1 ||
				   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
				   ' AND TRIM(INDIC) = ''S''';

	EXECUTE IMMEDIATE v_sqlQuery1
	  into o_ztotOk;

	v_sqlQuery2 := 'SELECT COUNT(*) FROM ' || v_tableNametemp_1 ||
				   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
				   ' AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL)';

	EXECUTE IMMEDIATE v_sqlQuery2
	  into o_ztotErr;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNametemp_1 ||
                   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
                   ' AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL)';
    
	EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprc;

    o_ztotNprc := 0;
    o_zTotal := o_ztotOk + o_ztotErr + o_ztotNprc;

	dbms_output.put_line('Schedule Name   :' ||I_SCHEDULENAME );
	dbms_output.put_line('Schedule Number :' ||LPAD(TRIM(I_SCHEDULE_NO), 4, '0'));
	dbms_output.put_line('Stage Table Name:' ||v_fileName);
	dbms_output.put_line('Error Count     :' ||o_ztotErr);
	dbms_output.put_line('Success Count   :' ||o_ztotOk);
	dbms_output.put_line('Total Count     :' ||o_zTotal);

	dbms_output.put_line('******************Pre-Validation Stats for table 1: END ****************************');
	    
	dbms_output.put_line(CHR(10));

	dbms_output.put_line('******************Pre-Validation Stats for table 2: START *************************');
	
	v_fileName := '''' || v_filenametemp2 || '''';

	v_sqlQuery1 := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNametemp_2 ||
				   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
				   ' AND TRIM(INDIC) = ''S''';

	EXECUTE IMMEDIATE v_sqlQuery1
	  into o_ztotOk;

	v_sqlQuery2 := 'SELECT COUNT(*) FROM ' || v_tableNametemp_2 ||
				   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
				   ' AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL)';

	EXECUTE IMMEDIATE v_sqlQuery2
	  into o_ztotErr;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNametemp_2 ||
                   ' WHERE TRIM(zfilenme) = ' || v_fileName ||
                   ' AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL)';
    
	EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprc;

    o_ztotNprc := 0;
    o_zTotal := o_ztotOk + o_ztotErr + o_ztotNprc;

	dbms_output.put_line('Schedule Name   :' ||I_SCHEDULENAME );
	dbms_output.put_line('Schedule Number :' ||LPAD(TRIM(I_SCHEDULE_NO), 4, '0'));
	dbms_output.put_line('Stage Table Name:' ||v_fileName);
	dbms_output.put_line('Error Count     :' ||o_ztotErr);
	dbms_output.put_line('Success Count   :' ||o_ztotOk);
	dbms_output.put_line('Total Count     :' ||o_zTotal);

	dbms_output.put_line('******************Pre-Validation Stats for table 2: END ****************************');
			
END;

