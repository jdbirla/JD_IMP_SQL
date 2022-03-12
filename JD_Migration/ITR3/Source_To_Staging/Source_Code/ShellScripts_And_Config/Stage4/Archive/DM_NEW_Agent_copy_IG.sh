#!/usr/bin/bash

. /home/jpacst/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">AGENCY_REPORT.LOG

echo "AGENCY  Stage 4 Movement " >>AGENCY_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGAGENTPJ" >>AGENCY_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> AGENCY_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
execute DM_data_bulkcopy_IG.DM_New_Agency_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE         INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============         =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGAGENTPJ_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "AGENCY Procedure executed successfully." >> AGENCY_REPORT.LOG
else
   echo "AGENCY Procedure executed With errors check the log table in DB." >> AGENCY_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> AGENCY_REPORT.LOG
cat AGENCY_REPORT.LOG > $DM_logfilepath/"STAGE4_AGENCY_REPORT"$timeStamp".LOG"

exit 0
