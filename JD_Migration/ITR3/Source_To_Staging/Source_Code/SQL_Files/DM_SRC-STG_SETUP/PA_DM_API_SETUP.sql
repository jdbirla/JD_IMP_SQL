  /**************************************************************************************************************************
  * File Name        : PA_DM_API_SETUP
  * Author           : Mark Kevin Sarmiento
  * Creation Date    : Feb. 5, 2021
  * Project          : -----
  -----
  * Description      : This SQL will setup all API objects
  **************************************************************************************************************************/a
   /***************************************************************************************************
  * Amenment History: DMSRC-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   SRC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * FEB05    MKS   SRC1   New Designed and developed
  ********************************************************************************************************************************/

DEFINE CODE_HOME = "";

--COMMON PKG/FNC/PROC
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_gen_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\Create_bkp_proc.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_RE_RUN_TMP_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\FUNCTION_minnbage.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\FUNCTION_VALIDATE_DATE.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\HALFBYTEKATAKANANORMALIZED_FUN.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\UPDATE_TITDMGCAMPCDE_Procedure.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\validation_billing.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_LOAD_POLICY_RECON.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\post_validation_billing.sql;


--BULK COPY PKGS
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_agncy_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_bildishnr_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_billcolrs_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_billhis_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_billref_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_clntbnk_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_cmp_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_corpclnt_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_letter_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_mempol_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_mstpol_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_perclnthis_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_polhis_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_rnwdet_package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_bulkcopy_corr_address.sql;


--TRANSFORMATION LOGIG
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\dm_persnl_clnt_flg_Procedure.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_POLICY_STATUS_CODE.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_MEMBER_IND_POL_SSPLAN_POPULAT_PROC.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_billcol_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_billhis_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_billref_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_clntbnk_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_cmpc_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_letter_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_mastpol_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_mempol_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_perclnthis_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_polhis_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_data_trans_renw_det_Package.sql;
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\dm_data_trans_corraddress_package.sql;


--TRANNO PKG
@&CODE_HOME\Source_Code\SQL_Files\Packages_And_Procedures\DM_PA_TRANNO_Package.sql;


--Recompile Script
@&CODE_HOME\Source_Code\SQL_Files\DM_SRC-STG_SETUP\Recomplie_Objects.sql;
