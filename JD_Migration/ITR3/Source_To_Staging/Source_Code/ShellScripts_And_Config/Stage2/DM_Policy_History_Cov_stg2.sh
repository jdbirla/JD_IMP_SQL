#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">POLICY_History_Cov.LOG


echo "$timeStamp" >POLICY_History_Cov.LOG
echo "Policy History  Coverage Transformation" >>POLICY_History_Cov.LOG
echo "SOURCE TABLE(s) : ZMRAP00, ZMRIE00, ALTER_REASON_CODE" >>POLICY_History_Cov.LOG

sqlplus -s $DM_dbconnection << EOF >> POLICY_History_Cov.LOG


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON


--execute DM_data_transform.dm_polhis_cov(1000,'Y');
execute DM_data_trans_polhis.dm_polhis_cov(1000,'Y');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGMBRINDP2';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Policy History Coverage Procedure executed successfully." >> POLICY_History_Cov.LOG 
else
   echo "Policy History Coverage Procedure executed With errors check the log table in DB." >> POLICY_History_Cov.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> POLICY_History_Cov.LOG
cat POLICY_History_Cov.LOG > "${DM_logfilepath}STAGE2_POLICY_History_Cov${timeStamp}.LOG"
