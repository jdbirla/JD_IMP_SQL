#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">SALESPL2_REPORT.LOG

echo "SALES PLAN 2 REPORT    Stage 4 Movement " >> SALESPL2_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGSALEPLN2" >>SALESPL2_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> SALESPL2_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.DM_Salesplan2_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_cmp.DM_Salesplan2_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGZCSLPF_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "SALES PLAN 2  Procedure executed successfully." >> SALESPL2_REPORT.LOG
else
   echo "SALES PLAN 2  Procedure executed With errors check the log table in DB." >> SALESPL2_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> SALESPL2_REPORT.LOG
cat SALESPL2_REPORT.LOG > "${DM_logfilepath}/STAGE4_SALESPL2_REPORT${timeStamp}.LOG"

exit 0

