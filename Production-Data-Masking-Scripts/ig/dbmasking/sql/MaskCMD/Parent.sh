#!/bin/bash
#echo "This script is about to run another script."
export NLS_LANG=japanese_japan.ja16sjis
echo "******************************************************************************"
echo "*****************************Encoding****************************************"
echo "******************************************************************************"
echo $NLS_LANG
echo $NLS_LANG
echo $NLS_LANG

echo "******************************************************************************"
echo "*****************************Compile Started**********************************"
echo "******************************************************************************"
sh CREATE_OBJ.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus

echo "******************************************************************************"
echo "*************************Normal VM1DTA Export Started*************************"
echo "******************************************************************************"
sh Vm1dta.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus

echo "******************************************************************************"
echo "************************PIPELINE PARALLEL VM1DTA Export Started***************"
echo "******************************************************************************"
sh CallProcedures.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus

echo "******************************************************************************"
echo "************************Stage DB export Export Started***************"
echo "******************************************************************************"

sh Stagedbusr.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus

echo "******************************************************************************"
echo "********************************COMPLETED************************************"
echo "******************************************************************************"

#echo "V1mdta is done"
#sh Stage.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus
#echo "STAGEDBUSR is done"
