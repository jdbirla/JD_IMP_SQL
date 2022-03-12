#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">RNWL_AS_IS.LOG


echo "RENEWAL DET TRANSFORMATION" >>RNWL_AS_IS.LOG
echo "SOURCE TABLE(s) : RENEW_AS_IS,P2_REN_RECORDS " >>RNWL_AS_IS.LOG

sqlplus -s $DM_dbconnection << EOF >> RNWL_AS_IS.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON



execute dm_data_trans_renew_det.dm_rnwasis_renew_det(1000);
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE SOURCE_TABLE IN ('RENEW_AS_IS','P2_REN_RECORDS') AND TARGET_TABLE IN('TITDMGRNWDT1','TITDMGRNWDT2');
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Renwal Det RENEW_AS_IS TRANSFORM Procedure executed successfully." >> RNWL_AS_IS.LOG 
else
   echo "Renwal Det RENEW_AS_IS TRANSFORM Procedure executed With errors check the log table in DB." >> RNWL_AS_IS.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: $timeStamp" >> RNWL_AS_IS.LOG
cat RNWL_AS_IS.LOG > "${DM_logfilepath}STAGE2_RNWL_AS_IS${timeStamp}.LOG"

exit 0

