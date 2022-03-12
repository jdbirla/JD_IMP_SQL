#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">RNWL_ZMRHR.LOG


echo "RENEWAL DET TRANSFORMATION" >>RNWL_ZMRHR.LOG
echo "SOURCE TABLE(s) : ZMRHR00,P2_RECORDS " >>RNWL_ZMRHR.LOG

sqlplus -s $DM_dbconnection << EOF >> RNWL_ZMRHR.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON



execute dm_data_trans_renew_det.dm_zmrhr_renew_det(1000);
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE SOURCE_TABLE IN ('ZMRHR00','P2_RECORDS') AND TARGET_TABLE IN('TITDMGRNWDT1','TITDMGRNWDT2');
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Renwal Det ZMRHR00 TRANSFORM Procedure executed successfully." >> RNWL_ZMRHR.LOG 
else
   echo "Renwal Det ZMRHR00 TRANSFORM Procedure executed With errors check the log table in DB." >> RNWL_ZMRHR.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: $timeStamp" >> RNWL_ZMRHR.LOG
cat RNWL_ZMRHR.LOG > "${DM_logfilepath}STAGE2_RNWL_ZMRHR${timeStamp}.LOG"

exit 0

