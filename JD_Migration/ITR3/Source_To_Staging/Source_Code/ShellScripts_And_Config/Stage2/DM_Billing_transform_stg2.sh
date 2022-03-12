#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">BILLTRANSFM_REPORT.LOG


echo "BILLING TRANSFORMATION" >>BILLTRANSFM_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00,ZMRAT00,ZMRIC00 " >>BILLTRANSFM_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> BILLTRANSFM_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname IN ('TITDMGBILL1','TITDMGBILL2');
--commit;

--execute DM_billing_transform(1000,'Y');
--execute DM_data_transform.DM_billing_transform(1000,'Y',$1);
execute DM_data_trans_billhis.DM_billing_transform(1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE IN('TITDMGBILL1','TITDMGBILL2');
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "BILLING TRANSFORM Procedure executed successfully." >> BILLTRANSFM_REPORT.LOG 
else
   echo "BILLING TRANSFORM Procedure executed With errors check the log table in DB." >> BILLTRANSFM_REPORT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: $timeStamp" >> BILLTRANSFM_REPORT.LOG
cat BILLTRANSFM_REPORT.LOG > "${DM_logfilepath}STAGE2_BILLTRANSFM_REPORT${timeStamp}.LOG"

exit 0

