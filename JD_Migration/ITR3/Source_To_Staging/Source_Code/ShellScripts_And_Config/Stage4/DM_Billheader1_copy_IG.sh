#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">BILL1_REPORT.LOG

echo "BILLING HEADER REPORT    Stage 4 Movement " >> BILL1_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGBILL1" >>BILL1_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> BILL1_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.DM_Billheader1_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_billhis.DM_Billheader1_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGBILL1_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "BILLING HEADER  Procedure executed successfully." >> BILL1_REPORT.LOG
else
   echo "BILLING HEADER  Procedure executed With errors check the log table in DB." >> BILL1_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> BILL1_REPORT.LOG
cat BILL1_REPORT.LOG > "${DM_logfilepath}/STAGE4_BILL1_REPORT${timeStamp}.LOG"

exit 0
