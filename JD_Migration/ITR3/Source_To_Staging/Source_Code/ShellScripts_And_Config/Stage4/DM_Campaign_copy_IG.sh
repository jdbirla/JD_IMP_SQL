#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">CAMPCODE_REPORT.LOG

echo "CAMPAIGN CODE REPORT    Stage 4 Movement " >> CAMPCODE_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGCAMPCDE" >>CAMPCODE_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> CAMPCODE_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.DM_Campaign_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_cmp.DM_Campaign_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCAMPCDE_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "CAMPAIGN CODE  Procedure executed successfully." >> CAMPCODE_REPORT.LOG
else
   echo "CAMPAIGN CODE  Procedure executed With errors check the log table in DB." >> CAMPCODE_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> CAMPCODE_REPORT.LOG
cat CAMPCODE_REPORT.LOG > "${DM_logfilepath}/STAGE4_CAMPCODE_REPORT${timeStamp}.LOG"

exit 0
