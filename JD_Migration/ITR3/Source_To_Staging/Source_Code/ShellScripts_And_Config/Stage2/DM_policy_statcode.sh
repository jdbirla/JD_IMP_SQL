#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">DM_POLICY_STATUS_CODE.LOG
echo "REFUND HEADER TRANSFORMATION" >>DM_POLICY_STATUS_CODE.LOG
echo "SOURCE TABLE(s) : ZMRAP00, zmrrpt00, btdate_ptdate_list" >>DM_POLICY_STATUS_CODE.LOG

sqlplus -s $DM_dbconnection << EOF >> DM_POLICY_STATUS_CODE.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--delete from error_log where jobname='TITDMGREF1';
--commit;
--execute DM_data_transform.DM_Refundhdr_transform(1000,'Y');
execute DM_POLICY_STATUS_CODE(1000,'Y');
--execute DM_Refundhdr_transform(1000,'Y');

SPOOL DM__REFNDHDR_STG2_REPORT.TXT
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='POLICY_STATCODE';
SPOOL OFF
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Policy Status Code procedure execution Completed." >> DM_POLICY_STATUS_CODE.LOG 
else
   echo "Policy Status Code procedure  executed With errors check the log table in DB." >> DM_POLICY_STATUS_CODE.LOG 
fi

timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Job Execution End: "$timeStamp
echo " Job Execution END: $timeStamp" >> DM_POLICY_STATUS_CODE.LOG

cat DM_POLICY_STATUS_CODE.LOG > "${DM_logfilepath}STAGE2_DM_POLICY_STATUS_CODE${timeStamp}.LOG"

exit 0

