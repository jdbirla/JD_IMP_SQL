#!/bin/bash
#echo "This script is about to run another script."
export NLS_LANG=japanese_japan.ja16sjis
echo $NLS_LANG
sh Vm1dta.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus
#echo "V1mdta is done"
#sh Stage.sh | /opt/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus
#echo "STAGEDBUSR is done"
