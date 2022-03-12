#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini

timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">CLNTBNK_REPORT.LOG

echo "CLIENT BANK TRANSFORMATION" >>CLNTBNK_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, DMPR" >>CLNTBNK_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> CLNTBNK_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_clntbnk_transform(1000,'N');
--execute DM_data_transform.DM_clntbnk_transform(1000,'N');
execute DM_data_trans_clntbnk.DM_clntbnk_transform(1000,'N');
--SPOOL DM__CLNTBANK_STG2_REPORT.TXT
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCLNTBANK';
--SPOOL OFF
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Client Bank Procedure executed successfully." >> CLNTBNK_REPORT.LOG 
else
   echo "Client Bank Procedure executed With errors check the log table in DB." >> CLNTBNK_REPORT.LOG 
fi



timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> CLNTBNK_REPORT.LOG
cat CLNTBNK_REPORT.LOG > "${DM_logfilepath}STAGE2_CLNTBNK_REPORT${timeStamp}.LOG"

exit 0
