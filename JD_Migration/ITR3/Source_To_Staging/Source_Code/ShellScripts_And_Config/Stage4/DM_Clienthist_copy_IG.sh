#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">CLIENTHIST_REPORT.LOG

echo "CLIENT HISTORY REPORT    Stage 4 Movement " >> CLIENTHIST_REPORT.LOG
echo "SOURCE TABLE(s) : TITDMGCLTRNHIS" >>CLIENTHIST_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> CLIENTHIST_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.DM_Clienthist_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_perclnthis.DM_Clienthist_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCLTRNHIS_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "CLIENT HISTORY  Procedure executed successfully." >> CLIENTHIST_REPORT.LOG
else
   echo "CLIENT HISTORY  Procedure executed With errors check the log table in DB." >> CLIENTHIST_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> CLIENTHIST_REPORT.LOG
cat CLIENTHIST_REPORT.LOG > "${DM_logfilepath}/STAGE4_CLIENTHIST_REPORT${timeStamp}.LOG"

exit 0
