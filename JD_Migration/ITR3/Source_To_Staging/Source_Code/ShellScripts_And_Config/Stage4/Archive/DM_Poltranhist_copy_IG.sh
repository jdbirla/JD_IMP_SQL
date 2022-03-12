#!/usr/bin/bash

. /home/jpacst/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">POLTRNH_REPORT.LOG

echo "POLICY TRANSACTION HISTORY REPORT    Stage 4 Movement " >> POLTRNH_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGPOLTRNH" >>POLTRNH_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> POLTRNH_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
execute DM_data_bulkcopy_IG.DM_Poltranhist_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGPOLTRNH_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "POLICY TRANSACTION HISTORY  Procedure executed successfully." >> POLTRNH_REPORT.LOG
else
   echo "POLICY TRANSACTION HISTORY  Procedure executed With errors check the log table in DB." >> POLTRNH_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> POLTRNH_REPORT.LOG
cat POLTRNH_REPORT.LOG > $DM_logfilepath/"STAGE4_POLTRNH_REPORT"$timeStamp".LOG"

exit 0

