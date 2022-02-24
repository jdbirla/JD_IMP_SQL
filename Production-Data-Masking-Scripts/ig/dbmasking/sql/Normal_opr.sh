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
echo "*************************Normal VM1DTA external Started*************************"
echo "******************************************************************************"
sh /opt/ig/dbmasking/sql/Vm1dtaLoader.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus

echo "******************************************************************************"
echo "*************************Normal VM1DTA external Started*************************"
echo "******************************************************************************"
sh /opt/ig/dbmasking/sql/StgLoader.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus


echo "******************************************************************************"
echo "********************************COMPLETED Normal************************************"
echo "******************************************************************************"

#echo "V1mdta is done"
#sh Stage.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus
#echo "STAGEDBUSR is done"

exit 0