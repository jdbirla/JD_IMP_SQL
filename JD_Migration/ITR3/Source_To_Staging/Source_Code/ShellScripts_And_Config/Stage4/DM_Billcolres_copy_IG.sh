#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">BILLCOLRES_REPORT.LOG

echo "BILL COLLECTION RESULTS REPORT    Stage 4 Movement " >>BILLCOLRES_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGCOLRES" >>BILLCOLRES_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> BILLCOLRES_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.DM_Billcolres_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_billcolrs.DM_Billcolres_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCOLRES_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "BILL COLLECTION RESULTS REPORT  Procedure executed successfully." >> BILLCOLRES_REPORT.LOG
else
   echo "BILL COLLECTION RESULT Procedure executed With errors check the log table in DB." >> BILLCOLRES_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> BILLCOLRES_REPORT.LOG
cat BILLCOLRES_REPORT.LOG > "${DM_logfilepath}/STAGE4_BILLCOLRES_REPORT${timeStamp}.LOG"

exit 0
