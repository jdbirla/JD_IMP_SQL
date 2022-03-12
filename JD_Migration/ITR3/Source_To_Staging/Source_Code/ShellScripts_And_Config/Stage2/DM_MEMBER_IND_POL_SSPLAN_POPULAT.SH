#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">MEM_IND_POL_SSPLAN_INTMDT.LOG


echo "$timeStamp" >MEM_IND_POL_HIST_INTMDT.LOG
echo "MEM_IND_POLHIST_SSPLAN_INTRMDT" >>MEM_IND_POL_SSPLAN_INTMDT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, zmris00, zmrrs00, STAGEDBUSR2.SPPLANCONVERTION" >>MEM_IND_POL_SSPLAN_INTMDT.LOG

sqlplus -s $DM_dbconnection << EOF >> MEM_IND_POL_SSPLAN_INTMDT.LOG


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON


--execute DM_data_transform.dm_polhis_cov(1000,'Y');
execute DM_SSPLAN_POPULAT(1000,'Y');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='MEM_IND_POLHIST_SSPLAN_INTRMDT';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "MEM_IND_POLHIST_SSPLAN_INTRMDT Procedure executed successfully." >> MEM_IND_POL_SSPLAN_INTMDT.LOG 
else
   echo "MEM_IND_POLHIST_SSPLAN_INTRMDT Procedure executed With errors check the log table in DB." >> MEM_IND_POL_SSPLAN_INTMDT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> MEM_IND_POL_SSPLAN_INTMDT.LOG
cat MEM_IND_POL_SSPLAN_INTMDT.LOG > "${DM_logfilepath}STAGE2_POLICY_History_Cov${timeStamp}.LOG"
