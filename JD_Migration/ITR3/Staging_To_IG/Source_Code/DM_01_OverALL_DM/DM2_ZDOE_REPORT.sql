
  /**************************************************************************************************************************
  * File Name        : DM2_ZDOE_REPORT
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This SQL will generate Pre-Validation report
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0316     JDB   ZD1   New Designed and developed
  
  ********************************************************************************************************************************/
/*
  PA Data Migration pre-validation report:DM2_ZDOE_REPORT
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Report"
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
I_SCHEDULENAME VARCHAR2(50 CHAR) := '&1';
I_SCHEDULE_NO number:= '&2';
v_filenametemp    VARCHAR2(30):='&3';
v_prefix    VARCHAR2(2):='&4';

  v_tableNametemp  VARCHAR2(10 char):= 'ZDOE' || v_prefix || LPAD(TRIM(I_SCHEDULE_NO), 4, '0');
  o_ztotOk          NUMBER;
  o_ztotNprc        NUMBER;
  o_ztotErr         NUMBER;
  o_zTotal          NUMBER;
   o_ztotOkIN        NUMBER(16) DEFAULT 0;
  o_ztotNprcIN      NUMBER(16) DEFAULT 0;
  o_ztotErrIN       NUMBER(16) DEFAULT 0;
  o_zTotalIN        NUMBER(16) DEFAULT 0;
  o_ztotOkMB        NUMBER(16) DEFAULT 0;
  o_ztotNprcMB      NUMBER(16) DEFAULT 0;
  o_ztotErrMB       NUMBER(16) DEFAULT 0;
  o_zTotalMB        NUMBER(16) DEFAULT 0;
 v_errorCount NUMBER :=0;
   v_fileName        VARCHAR2(30);

v_sqlQuery1       VARCHAR2(500);
  v_sqlQuery2       VARCHAR2(500);
  v_sqlQuery3       VARCHAR2(500);
  v_sqlQuery4       VARCHAR2(500);
BEGIN
	   
	    IF (TRIM(I_SCHEDULENAME) != 'G1ZDMBRIND') THEN
		
	       v_fileName      := '''' || v_filenametemp || '''';

	    dbms_output.put_line('*************************************************************************');
	    dbms_output.put_line('**********************Pre-Validation Stats:******************************');
	    dbms_output.put_line('*************************************************************************');

	    dbms_output.put_line(CHR(10));

	    dbms_output.put_line('******************Pre-Validation Stats: : START *************************');
 v_sqlQuery1     := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNametemp ||
                       '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                       ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOk;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErr;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprc;
    o_ztotNprc := 0;
    /*  v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableName;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotal;*/
    o_zTotal := o_ztotOk + o_ztotErr + o_ztotNprc;

else
  v_tableNametemp:= 'ZDOE' || 'MB' || LPAD(TRIM(I_SCHEDULE_NO), 4, '0');


  v_fileName      := '''' || v_filenametemp || '''';

	    dbms_output.put_line('*************************************************************************');
	    dbms_output.put_line('**********************Pre-Validation Stats:******************************');
	    dbms_output.put_line('*************************************************************************');

	    dbms_output.put_line(CHR(10));

	    dbms_output.put_line('******************Pre-Validation Stats: : START *************************');
 v_sqlQuery1     := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNametemp ||
                       '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                       ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOkMB;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErrMB;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprcMB;
    o_ztotNprcMB := 0;
    /*  v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableName;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotal;*/
	o_zTotalMB   := o_ztotOkMB + o_ztotErrMB + o_ztotNprcMB;
	
	
	  v_tableNametemp:= 'ZDOE' || 'IN' || LPAD(TRIM(I_SCHEDULE_NO), 4, '0');

 v_sqlQuery1     := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNametemp ||
                       '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                       ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOkIN;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErrIN;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNametemp ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprcIN;
    o_ztotNprcIN := 0;
    /*  v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableName;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotal;*/
	o_zTotalIN   := o_ztotOkIN + o_ztotErrIN + o_ztotNprcIN;


   o_ztotOk   := o_ztotOkIN + o_ztotOkMB;
    o_ztotNprc := o_ztotNprcIN + o_ztotNprcMB;
    o_ztotErr  := o_ztotErrIN + o_ztotErrMB;
    o_zTotal   := o_zTotalIN + o_zTotalMB;


end if;

	    dbms_output.put_line('Schedule Name   :' ||I_SCHEDULENAME );
	    dbms_output.put_line('Schedule Number :' ||LPAD(TRIM(I_SCHEDULE_NO), 4, '0'));
	    dbms_output.put_line('Stage Table Name:' ||v_fileName);
	    dbms_output.put_line('Error Count     :' ||o_ztotErr);
	    dbms_output.put_line('Success Count   :' ||o_ztotOk);
	    dbms_output.put_line('Total Count     :' ||o_zTotal);



	    dbms_output.put_line('******************Pre-Validation Stats: : END ****************************');
	    
			


END;

