#!/usr/bin/bash

. /home/jpacst/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">PERSONALCLIENT_REPORT.LOG

echo "PERSONAL CLIENT TRANSFORMATION" >>PERSONALCLIENT_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, ZMRIS00" >>PERSONALCLIENT_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> PERSONALCLIENT_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGCLNTPRSN';
--commit;

--execute DM_LETTERHIST_TRANSFORM(1000,'Y');
--execute DM_data_transform.DM_prsnclnt_transform(1000,'Y');
execute DM_data_trans_perclnthis.DM_prsnclnt_transform(1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCLNTPRSN';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "PERSONAL CLIENT Procedure executed successfully." >> PERSONALCLIENT_REPORT.LOG 
else
   echo "PERSONAL CLIENT Procedure executed With errors check the log table in DB." >> PERSONALCLIENT_REPORT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> PERSONALCLIENT_REPORT.LOG
cat PERSONALCLIENT_REPORT.LOG > $DM_logfilepath/"STAGE2_PERSONALCLIENT_REPORT"$timeStamp".LOG"

exit 0
