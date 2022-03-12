#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">Policytran_transform.log

echo "POLICY TRANSACTION  REPORT    Stage 4 Movement " >> Policytran_transform.log
echo "SOURCE TABLE(s) : TITDMGPOLTRNH" >>Policytran_transform.log

sqlplus -s $DM_dbconnection << EOF >> Policytran_transform.log


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.dm_Policytran_transform_to_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_polhis.dm_Policytran_transform_to_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGPOLTRNH_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "POLICY TRANSACTION Procedure executed successfully." >> Policytran_transform.log
else
   echo "POLICY TRANSACTION Procedure executed With errors check the log table in DB." >> Policytran_transform.log
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> Policytran_transform.log
cat Policytran_transform.log > "${DM_logfilepath}/STAGE4_POLTRNH_REPORT${timeStamp}.LOG"

exit 0

