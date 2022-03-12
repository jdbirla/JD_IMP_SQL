#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">BILLCOLLECT_REPORT.LOG

echo "BILLING COLLECTION TRANSFORMATION" >>BILLCOLLECT_REPORT.LOG
echo "SOURCE TABLE(s) : DSH_CODE_REF, PJ_TIDMDGCOLRES" >>BILLCOLLECT_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> BILLCOLLECT_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGCOLRES';
--commit;

--execute DM_Billing_collectres(1000,'Y');
--execute DM_data_transform.DM_Billing_collectres(1000,'Y');
execute DM_data_trans_billcol.DM_Billing_collectres(1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCOLRES';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "BILLING COLLECTION RESULT Procedure executed successfully." >> BILLCOLLECT_REPORT.LOG 
else
   echo "BILLING COLLECTION RESULT Procedure executed With errors check the log table in DB." >> BILLCOLLECT_REPORT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> BILLCOLLECT_REPORT.LOG
cat BILLCOLLECT_REPORT.LOG > "${DM_logfilepath}STAGE2_BILLCOLLECT_REPORT${timeStamp}.LOG"

exit 0
