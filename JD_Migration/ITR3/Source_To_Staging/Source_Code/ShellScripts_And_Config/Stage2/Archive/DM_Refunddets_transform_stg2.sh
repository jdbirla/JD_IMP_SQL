#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">REFNDETS_REPORT.LOG
echo "REFUND DETAILS TRANSFORMATION" >>REFNDETS_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, DMPR" >>REFNDETS_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> REFNDETS_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--delete from error_log where jobname='TITDMGREF2';
--commit;
--execute DM_data_transform.DM_Refunddets_transform(1000,'Y');
execute DM_data_trans_billref.DM_Refunddets_transform(1000,'Y');
--execute DM_Refunddets_transform(1000,'Y');

SPOOL DM__REFNDETS_STG2_REPORT.TXT
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGREF2';
SPOOL OFF
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "REFUND HEADER Procedure execution Completed." >> REFNDETS_REPORT.LOG 
else
   echo "REFUND HEADER Procedure executed With errors check the log table in DB." >> REFNDETS_REPORT.LOG 
fi

timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Job Execution End: "$timeStamp
echo "Job Execution END: $timeStamp" >> REFNDETS_REPORT.LOG

cat REFNDETS_REPORT.LOG > $DM_logfilepath/"STAGE2_REFNDETS_REPORT"$timeStamp".LOG"

exit 0
