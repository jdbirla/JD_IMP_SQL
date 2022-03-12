#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">SALES_CAMPAIGN_REPORT.LOG

echo "SALESPLAN and CAMPAIGN CODE TRANSFORMATION" >> SALES_CAMPAIGN_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRCP00, ZMRRP00" >>SALES_CAMPAIGN_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> SALES_CAMPAIGN_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGSALEPLN2';
--commit;

--execute dm_saleplan_camp_transform (1000,'Y');
--execute DM_data_transform.dm_saleplan_camp_transform(1000,'Y');
execute DM_data_trans_cmpc.dm_saleplan_camp_transform(1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGZCSLPF';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "SALESPLAN and CAMPAIGN Procedure executed successfully." >> SALES_CAMPAIGN_REPORT.LOG 
else
   echo "SALESPLAN and CAMPAIGN Procedure executed With errors check the log table in DB." >> SALES_CAMPAIGN_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo "Job Execution END: $timeStamp" >> SALES_CAMPAIGN_REPORT.LOG
cat SALES_CAMPAIGN_REPORT.LOG > "${DM_logfilepath}STAGE2_SALESPLAN_CAMPAIGN_REPORT${timeStamp}.LOG"

exit 0
