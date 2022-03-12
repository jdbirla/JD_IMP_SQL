#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">CLNTCORP_REPORT.LOG

echo "CLIENT CORP Stage 4 Movement " >>CLNTCORP_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGCLNTCORP" >>CLNTCORP_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> CLNTCORP_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_clntbnk_transform(1000,'N');
--execute DM_data_bulkcopy_IG.DM_Clntcorp_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_corpclnt.DM_Clntcorp_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE         INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============         =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCLNTCORP_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Client corp Procedure executed successfully." >> CLNTCORP_REPORT.LOG
else
   echo "Client corp Procedure executed With errors check the log table in DB." >> CLNTCORP_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> CLNTCORP_REPORT.LOG
cat CLNTCORP_REPORT.LOG > "${DM_logfilepath}/STAGE4_CLNTCORP_REPORT${timeStamp}.LOG"

exit 0
