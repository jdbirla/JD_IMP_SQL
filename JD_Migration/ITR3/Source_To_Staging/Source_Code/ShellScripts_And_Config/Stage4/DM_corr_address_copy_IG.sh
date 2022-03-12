#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">Corr_Addr_Copy_to_IG.log

echo "Policy History Apirno REPORT Stage 4 Movement " >> Corr_Addr_Copy_to_IG.log
echo "SOURCE TABLE(s) : TITDMGCORADDR" >>Corr_Addr_Copy_to_IG.log

sqlplus -s $DM_dbconnection << EOF >> Corr_Addr_Copy_to_IG.log


SET PAGESIZE 80
SET LINESIZE 100
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

execute DM_bulkcopy_corr_address.dm_corraddr_to_ig($DM_IGSchema,1000,'N');
PROMPT TARGET_TABLE    INPUT_CNT  OUTPUT_CNT STATUS ERRORMSG ;
PROMPT ============    =========  ========== ====== ========;
SELECT LPAD(REPLACE(TARGET_TABLE,'_IG',''),15,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERROR_MSG FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCORADDR_IG';
EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Correspondence Address Procedure executed successfully." >> Corr_Addr_Copy_to_IG.log
else
   echo "Correspondence Address Procedure executed With errors check the log table in DB." >> Corr_Addr_Copy_to_IG.log
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution completed: "$timeStamp
echo "Job Execution END: $timeStamp" >> Corr_Addr_Copy_to_IG.log
cat Corr_Addr_Copy_to_IG.log > "${DM_logfilepath}/STAGE4_CORR_ADDR_REPORT${timeStamp}.LOG"

exit 0