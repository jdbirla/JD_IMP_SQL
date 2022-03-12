#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">RENEWAL_DET_2.LOG

echo "Renewal Determination 2 Report  Stage 4 Movement " >> RENEWAL_DET_2.LOG
echo "SOURCE TABLE(s) : TITDMGRNWDT2" >> RENEWAL_DET_2.LOG

sqlplus -s $DM_dbconnection << EOF >> RENEWAL_DET_2.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

execute DM_bulkcopy_rnwdet.DM_rnwdet2_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGRNWDT2_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Renewal Determination 2  Procedure executed successfully." >> RENEWAL_DET_2.LOG
else
   echo "Renewal Determination 2  Procedure executed With errors check the log table in DB." >> RENEWAL_DET_2.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> RENEWAL_DET_2.LOG
cat RENEWAL_DET_2.LOG > "${DM_logfilepath}/STAGE4_RNWL_DET_2_REPORT${timeStamp}.LOG"

exit 0
