#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">LETTERHIS_REPORT.LOG

echo "LETTER HISTORY TRANSFORMATION" >>LETTERHIS_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRLH00, LETTER_CODE" >>LETTERHIS_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> LETTERHIS_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGLETTER';
--commit;

--execute DM_LETTERHIST_TRANSFORM(1000,'Y');
--execute DM_data_transform.DM_LETTERHIST_TRANSFORM(1000,'Y');
execute DM_data_trans_letter.DM_LETTERHIST_TRANSFORM(1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGLETTER';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "LETTER HISTORY Procedure executed successfully." >> LETTERHIS_REPORT.LOG 
else
   echo "LETTER HISTORY History Procedure executed With errors check the log table in DB." >> LETTERHIS_REPORT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> LETTERHIS_REPORT.LOG
cat LETTERHIS_REPORT.LOG > "${DM_logfilepath}STAGE2_LETTERHIS_REPORT${timeStamp}.LOG"

exit 0
