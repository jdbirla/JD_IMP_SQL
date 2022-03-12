  /**************************************************************************************************************************
  * File Name        : PA_DM_STAGEDBUSR2_SETUP
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
  * MMMDD    XXX   SRC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * FEB05     MKS   SRC1   New Designed and developed
  ********************************************************************************************************************************/

DEFINE CODE_HOME = "C:\Users\JPAFSN\ITR3_FT_Migration\Source_To_Staging_feb08_1pmJST";

--Stagedbusr2 TABLES\INDEX\INSERT setup
@&CODE_HOME\Source_Code\SQL_Files\Table_DDLs_For_Stagedbusr2\DM_table_create.sql;
@&CODE_HOME\Source_Code\SQL_Files\Table_DDLs_For_Stagedbusr2\DDL_Index_create.sql;

--Stagedbusr2 VIEWS setup
@&CODE_HOME\Source_Code\views\Stagedbusr2_Views_DDL.sql;

--Stagedbusr2 INSERT constant data from Jdrich
@&CODE_HOME\Source_Code\SQL_Files\Table_DDLs_For_Stagedbusr2\DM_Insert_Scripts.sql;