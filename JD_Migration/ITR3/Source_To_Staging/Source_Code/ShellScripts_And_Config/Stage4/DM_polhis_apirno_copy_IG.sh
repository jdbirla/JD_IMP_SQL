#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">Polhis_Apirno_transform.log

echo "Policy History Apirno REPORT Stage 4 Movement " >> Polhis_Apirno_transform.log
echo "SOURCE TABLE(s) : TITDMGAPIRNO" >>Polhis_Apirno_transform.log

sqlplus -s $DM_dbconnection << EOF >> Polhis_Apirno_transform.log


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON
--execute DM_data_bulkcopy_IG.dm_polhis_apirno_ig($DM_IGSchema,1000,'Y');
execute DM_bulkcopy_polhis.dm_polhis_apirno_ig($DM_IGSchema,1000,'Y');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGAPIRNO_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "POLICY HISTORY Apirno Procedure executed successfully." >> Polhis_Apirno_transform.log
else
   echo "POLICY HISTORY Apirno Procedure executed With errors check the log table in DB." >> Polhis_Apirno_transform.log
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> Polhis_Apirno_transform.log
cat Polhis_Apirno_transform.log > "${DM_logfilepath}/STAGE4_POLTHIS_Apirno_REPORT${timeStamp}.LOG"

exit 0

