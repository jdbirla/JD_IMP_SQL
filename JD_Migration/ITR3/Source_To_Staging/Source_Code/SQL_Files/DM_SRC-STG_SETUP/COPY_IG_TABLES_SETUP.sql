  /**************************************************************************************************************************
  * File Name        : IG_TABLE_COPY_SETUP
  * Author           : Mark Kevin Sarmiento
  * Creation Date    : Feb. 5, 2021
  * Project          : -----
  -----
  * Description      : This SQL will setup all DDL and DML scripts
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMSRC-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   STG#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * FEB05    MKS   STG1   New Designed and developed
  ********************************************************************************************************************************/

DEFINE CODE_HOME = "";

--Stagedbusr TABLES/Grants setup
@&CODE_HOME\Source_Code\SQL_Files\Table_DDLs_For_Stagedbusr2\DDL_Table_STAGEDBUSR.sql;

--Stagedbusr Copy/Insert Script
@&CODE_HOME\Source_Code\SQL_Files\Table_DDLs_For_Stagedbusr2\TRUNCATE_INSERT_STAGEDBUSR_FROM_VM1DTA.sql;



