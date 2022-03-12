#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini

timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">MASTER_POLICY_REPORT.LOG

echo "MASTER POLICY TRANSFORMATION" >>MASTER_POLICY_REPORT.LOG
echo "SOURCE TABLE(s) : MSTPOLDB,MSTPOLGRP,TITDMGMASPOL" >>MASTER_POLICY_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> MASTER_POLICY_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_transform.DM_MSTPOL_TRANSFROM(1000,'N');
execute DM_data_trans_mastpol.DM_MSTPOL_TRANSFROM(1000,'N');


PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGMASPOL';
--SPOOL OFF
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Master Policy Procedure executed successfully." >> MASTER_POLICY_REPORT.LOG 
else
   echo "Master Policy Procedure executed With errors check the log table in DB." >> MASTER_POLICY_REPORT.LOG 
fi



timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> MASTER_POLICY_REPORT.LOG
cat MASTER_POLICY_REPORT.LOG > "${DM_logfilepath}STAGE2_MSTPOOL_REPORT${timeStamp}.LOG"

exit 0
