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

--************************MATERIALIZED Alter on demand:START*******************************************************
/*
ALTER MATERIALIZED VIEW MV_ZENCIPF 
REFRESH 
ON DEMAND;

ALTER MATERIALIZED VIEW MV_ZENDRPF 
REFRESH 
ON DEMAND;

ALTER MATERIALIZED VIEW MV_ZMCIPF 
REFRESH 
ON DEMAND;

ALTER MATERIALIZED VIEW MV_ZMCIPF 
REFRESH COMPLETE
ON DEMAND;


ALTER MATERIALIZED VIEW MV_ZMCIPF_CRDT 
REFRESH 
ON DEMAND;
*/
--************************MATERIALIZED Alter on demand:END*******************************************************

--************************Triggers disabled:START*******************************************************
ALTER session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
Commit;
ALTER SESSION ENABLE PARALLEL DML;

Select 'START_TIME  :=>  '  ||  to_char(sysdate, 'dd-mm-yy hh24:mi:ss') from dual;
/*
ALTER TRIGGER Jd1dta.TR_AUDIT_CLEXPF DISABLE;
ALTER TRIGGER Jd1dta.TR_CLEXPF DISABLE;
ALTER TRIGGER Jd1dta.TR_CLRRPF DISABLE;
ALTER TRIGGER Jd1dta.TR_AUDIT_CLRRPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNT DISABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNTPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GXHIPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_CLBAPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF DISABLE;
ALTER trigger VM1DTA_AUDIT_CLNTPF DISABLE;
ALTER trigger VM1DTA_AUDIT_CLEXPF DISABLE;
ALTER trigger Jd1dta.TR_CHDRPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GCHPPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GMHDPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GMHIPF DISABLE;
ALTER trigger Jd1dta.TR_ZUCLPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GBIHPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF DISABLE;
ALTER TRIGGER  Jd1dta.TR_GBIDPF DISABLE;
ALTER TRIGGER Jd1dta.TR_ZMCIPF DISABLE;
ALTER TRIGGER Jd1dta.TR_GXHIPF DISABLE;
ALTER TRIGGER Jd1dta.TR_GCHIPF DISABLE;
ALTER TRIGGER Jd1dta.TR_CLNTPF DISABLE;
ALTER TRIGGER Jd1dta.TR_ZCSLPF DISABLE;
ALTER TRIGGER Jd1dta.TR_VERSIONPF DISABLE;
ALTER TRIGGER Jd1dta.VM1DTA_AUDIT_CLRRPF DISABLE;
ALTER TRIGGER Jd1dta.TR_ZCLEPF DISABLE;
*/
-----------------MIS TRIGGERS:START----------------------
/*
ALTER TRIGGER Jd1dta.TR_GCHD_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_GCHIPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_GCHPPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_GXHIPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZTRAPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZALTPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZINSDTLSPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZAPIRNOPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZTEMPCOVPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZSMANDTLPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZTIERPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZTGMPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZBENFDTLSPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_GMHDPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_GMHIPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZCLNPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZADRPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_AGNTPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZACRPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZAGPPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZAACPF_AUDIT DISABLE;
ALTER TRIGGER Jd1dta.TR_ZCPNPF_AUDIT DISABLE;*/
-----------------MIS TRIGGERS:END----------------------

--************************Triggers disabled:END*******************************************************


---One time activity :start------------
/*
begin
  -- Call the procedure
  incr_seq(p_seq_name => 'SEQANUMPF',
           p_incr_val => '100');
end;
*/
---One time activity :end------------
---DMIGTIT*_Insertion:START-------

--;
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql;
--COMMIT;
--DMIGTIT*_Insertion:END-------

PROMPT  ********************************* Migration start ********************************************

---------CORPORATE_CLEINT:START------------------
--ENABLE TRIGGERS
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDCOPCLT;
--@&CALL_MODULES_PATH\G1ZDCOPCLT_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDCOPCLT_POST_VAL.sql;
--DISABLE TRIGGERS

---------CORPORATE_CLEINT:END----------------------


---------AGENCY:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDAGENCY;
--@&CALL_MODULES_PATH\G1ZDAGENCY_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDAGENCY_POST_VAL.sql;
---------AGENCY:END------------------



---------MASTER_POL:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDMSTPOL;
--@&CALL_MODULES_PATH\G1ZDMSTPOL_CALL.sql Y;
--@&CALL_MODULES_PATH\G1ZDMSTPOL_POST_VAL.sql;

---------MASTER_POL:END------------------

---------CAMP:START--------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDCAMPCD;
---@&CALL_MODULES_PATH\G1ZDCAMPCD_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDCAMPCD_POST_VAL.sql;
---RQY9: this is warning message please ignore

---------CAMP:END------------------


---------NAYOSE_AND_CLIENT:START------------------
--@&CALL_MODULES_PATH\PRE_NAYOSE_STEP.sql;
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDNAYCLT;
--@&CALL_MODULES_PATH\G1ZDNAYCLT_CALL.sql N;

-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDPERCLT;
--@&CALL_MODULES_PATH\G1ZDPERCLT_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDPERCLT;
--@&CALL_MODULES_PATH\G1ZDPERCLT_POST_VAL.sql;

-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDPCLNHIS;
--@&CALL_MODULES_PATH\G1ZDPCLNHIS_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDPCLNHIS;
--@&CALL_MODULES_PATH\G1ZDPCLNHIS_POST_VAL.sql;

-----Update effdate update effdate 19010101 for all tables
--@&CALL_MODULES_PATH\UPDATE_ZCLNPF_EFFDT.sql;

---UPDATE_UNIQUE_NO insert into DMUNIQUENOUPDT
--@&CALL_MODULES_PATH\UPDATE_UNIQUE_NO.sql;

---UPDATE_ZTRA_ZINS_Unique no update unieuqe no in ztra dn zins from DMUNIQUENOUPDT
--@&CALL_MODULES_PATH\UPDATE_ZTRA_ZINS_UNI.sql;

---------NAYOSE_AND_CLIENT:END------------------

---------CLNT_BANK:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDCLTBNK;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDCLTBNK;
--@&CALL_MODULES_PATH\G1ZDCLTBNK_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDCLTBNK;
--@&CALL_MODULES_PATH\G1ZDCLTBNK_POST_VAL.sql;

---------CLNT_BANK:END------------------

---------MEM_IND_POL:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDMBRIND;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDMBRIND;--its taking too much time --
--@&CALL_MODULES_PATH\G1ZDMBRIND_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDMBRIND;
--@&CALL_MODULES_PATH\DMMB_CREATE_INDEX.sql;
--@&CALL_MODULES_PATH\G1ZDMBRIND_POST_VAL.sql;

---------MEM_IND_POL:END------------------

-----Masert Pol Patch :START------------

--@&CALL_MODULES_PATH\BQ9EC_MP01_MSTRPL_DataPatch.sql;
------Master Pol Patch : END-----

---------POL_HIS:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDPOLHST;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDPOLHST;
--@&CALL_MODULES_PATH\G1ZDPOLHST_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDPOLHST;
--@&CALL_MODULES_PATH\CORR_ADDR_PATCHING.sql;


--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDPOLCOV;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDPOLCOV;
--@&CALL_MODULES_PATH\G1ZDPOLCOV_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDPOLCOV;
--@&CALL_MODULES_PATH\G1ZDPOLCOV_POST_VAL.sql;


--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDAPIRNO;
--@&CALL_MODULES_PATH\G1ZDAPIRNO_CALL.sql N;
---------POL_HIS:END------------------

---------BILL_HIS:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDBILLIN;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDBILLIN;
--@&CALL_MODULES_PATH\G1ZDBILLIN_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDBILLIN;
--@&CALL_MODULES_PATH\G1ZDBILLIN_POST_VAL.sql;

---------BILL_HIS:END------------------

---------BILL_DISHONOR:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDPOLDSH;
--@&CALL_MODULES_PATH\G1ZDPOLDSH_CALL.sql Y;
--@&CALL_MODULES_PATH\G1ZDPOLDSH_POST_VAL.sql;

---------BILL_DISHONOR:END------------------

---------BILL_COLRES:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDCOLRES;
--@&CALL_MODULES_PATH\G1ZDCOLRES_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDCOLRES_POST_VAL.sql;

---------BILL_COLRES:END------------------

---------BILL_REFUND:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDBILLRF;
-----------@&CALL_MODULES_PATH\DMDROPINDEX.sql G1ZDBILLRF;--no need if data less
--@&CALL_MODULES_PATH\G1ZDBILLRF_CALL.sql N;
-----------@&CALL_MODULES_PATH\DMCREATEINDEX.sql G1ZDBILLRF;
--@&CALL_MODULES_PATH\G1ZDBILLRF_POST_VAL.sql;

---------BILL_REFUND:END------------------


-------Superman_Patch:START-----------------
--@&CALL_MODULES_PATH\Superman_validation.sql;
--@&CALL_MODULES_PATH\Superman_Patch.sql;
-------Superman_Patch:END-----------------

---------LETTER:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDLETR;
--@&CALL_MODULES_PATH\G1ZDLETR_CALL.sql N;
--@&CALL_MODULES_PATH\G1ZDLETR_POST_VAL.sql;

---------LETTER:END------------------

---------RENEWAL_DETERMINATION:START------------------
--@&CALL_MODULES_PATH\PRE_DM_STEP.sql G1ZDRNWDTM;
--@&CALL_MODULES_PATH\G1ZDRNWDTM_CALL.sql Y;
---------RENEWAL_DETERMINATION:END------------------

---------JOBCODE_Patching------------------
--@&CALL_MODULES_PATH\VM1_JOBCODE_Patching.sql;
---------JOBCODE_Patching------------------



PROMPT  ********************************* Migration END ********************************************

--************************Triggers enabled:START*******************************************************


/*
ALTER TRIGGER Jd1dta.TR_AUDIT_CLEXPF ENABLE;
ALTER TRIGGER Jd1dta.TR_CLEXPF ENABLE;
ALTER TRIGGER Jd1dta.TR_CLRRPF ENABLE;
ALTER TRIGGER Jd1dta.TR_AUDIT_CLRRPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNT ENABLE;
ALTER TRIGGER  Jd1dta.TR_AUDIT_CLNTPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GXHIPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_CLBAPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF ENABLE;
ALTER trigger VM1DTA_AUDIT_CLNTPF ENABLE;
ALTER trigger VM1DTA_AUDIT_CLEXPF ENABLE;
ALTER trigger Jd1dta.TR_CHDRPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GCHPPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GMHDPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GMHIPF ENABLE;
ALTER trigger Jd1dta.TR_ZUCLPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_LETCPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GBIHPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GPMDPF ENABLE;
ALTER TRIGGER  Jd1dta.TR_GBIDPF ENABLE;
ALTER TRIGGER Jd1dta.TR_ZMCIPF ENABLE;
ALTER TRIGGER Jd1dta.TR_GXHIPF ENABLE;
ALTER TRIGGER Jd1dta.TR_GCHIPF ENABLE;
ALTER TRIGGER Jd1dta.TR_CLNTPF ENABLE;
ALTER TRIGGER Jd1dta.TR_ZCSLPF ENABLE;
ALTER TRIGGER Jd1dta.TR_VERSIONPF ENABLE;
ALTER TRIGGER Jd1dta.VM1DTA_AUDIT_CLRRPF ENABLE;
ALTER TRIGGER Jd1dta.TR_ZCLEPF ENABLE;
*/
--************************Triggers enabled:START*******************************************************

--************************MATERIALIZED Alter on commit:START*******************************************************
/*
@&CALL_MODULES_PATH\Refresh_MV.sql;

ALTER MATERIALIZED VIEW MV_ZENCIPF 
REFRESH 
ON COMMIT;

ALTER MATERIALIZED VIEW MV_ZENDRPF 
REFRESH 
ON COMMIT;

ALTER MATERIALIZED VIEW MV_ZMCIPF 
REFRESH 
ON COMMIT;

ALTER MATERIALIZED VIEW MV_ZMCIPF_CRDT 
REFRESH 
ON COMMIT;
*/

--************************MATERIALIZED Alter on commit:END*******************************************************
--************************Drop DM releasted objects:START****************************************

--drop index DM_gchd_I_1;


--************************Drop DM releasted objects:END****************************************

Select 'END_TIME  :=>  '  ||  to_char(sysdate, 'dd-mm-yy hh24:mi:ss') from dual;
