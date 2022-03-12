  /**************************************************************************************************************************
  * File Name        : 99_DM2_Main
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This SQL will call each module for migration
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0316     JDB   DM1   New Designed and developed
  
  ********************************************************************************************************************************/

/*
   PA Data Migration Main script
*/

DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"
DEFINE CALL_MODULES_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Call_Modules"

column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\99_DM_Main&log_date_text..txt"

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

---Pre-requisite steps:Start---------
-----------------------------------Stageing copy tables insertion for parallelL:Start-----------------
----Personal client and history
DELETE FROM Jd1dta.DMIGTITDMGCLTRNHIS;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGCLTRNHIS SELECT * FROM TITDMGCLTRNHIS@DMSTAGEDBLINK;
COMMIT;
-------Agency
delete from Jd1dta.DMIGTITDMGAGENTPJ;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGAGENTPJ SELECT * FROM TITDMGAGENTPJ@DMSTAGEDBLINK;
COMMIT;

---Client bank
delete from Jd1dta.DMIGTITDMGCLNTBANK;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGCLNTBANK SELECT * FROM TITDMGCLNTBANK@DMSTAGEDBLINK;
COMMIT;

----Insert data in IGtable for Nayose processing---
@&CALL_MODULES_PATH\INSRT_INTO_DMIGTITNYCLT.sql;
/
COMMIT;
---------------------------Stageing copy tables insertion for parallelL:END---------------------------------------


----Triggers disabled-------
ALTER TRIGGER Jd1dta.TR_AUDIT_CLEXPF DISABLE;
ALTER TRIGGER Jd1dta.TR_CLEXPF DISABLE;
ALTER TRIGGER Jd1dta.TR_CLRRPF DISABLE;
ALTER TRIGGER Jd1dta.TR_AUDIT_CLRRPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNT DISABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNTPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GCHPPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GMHDPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GMHIPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GXHIPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_CLBAPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF DISABLE;
ALTER trigger VM1DTA_AUDIT_CLNTPF DISABLE;
ALTER trigger VM1DTA_AUDIT_CLEXPF DISABLE;

----Triggers disabled-------

----------------------------Pre-requisite steps:END---------------------

--------------Calling modules in sequnce:Start-----------------------
--@&CALL_MODULES_PATH\G1ZDAGENCY_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDNAYCLT_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDPERCLT_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDPCLNHIS_CALL.sql N;
@&CALL_MODULES_PATH\G1ZDCLTBNK_CALL.sql N;


--------------Calling modules in sequnce:END-----------------------

-------------------------------Post-requisite steps:start------------------

/*
ALTER TRIGGER Jd1dta.TR_AUDIT_CLEXPF ENABLE;
ALTER TRIGGER Jd1dta.TR_CLEXPF ENABLE;
ALTER TRIGGER Jd1dta.TR_CLRRPF ENABLE;
ALTER TRIGGER Jd1dta.TR_AUDIT_CLRRPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNT ENABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNTPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GCHPPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GMHDPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GMHIPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GXHIPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_CLBAPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF ENABLE;
ALTER trigger VM1DTA_AUDIT_CLNTPF ENABLE;
ALTER trigger VM1DTA_AUDIT_CLEXPF ENABLE; */


----------------------------Post-requisite steps:END---------------------------


