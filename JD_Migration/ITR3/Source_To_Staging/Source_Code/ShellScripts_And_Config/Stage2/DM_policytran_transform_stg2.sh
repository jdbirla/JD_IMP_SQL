#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">POLTRNH_REPORT.LOG

#if [ "$#" -eq "0" ]
#then
#   echo "Invalid Arguments..Exiting .. check the POLTRNH_REPORT.LOG"
#   echo "Invalid Arguments.." >>POLTRNH_REPORT.LOG
#   echo "Usage: <sh DM_policytran_transform_stg2.sh date in <YYYYMMDD>>.." >>POLTRNH_REPORT.LOG
#   echo "Example: <sh DM_policytran_transform_stg2.sh 20160101>" >>POLTRNH_REPORT.LOG
#cat POLTRNH_REPORT.LOG > $DM_logfilepath/"STAGE2_POLTRNH_REPORT"$timeStamp".LOG"
#   exit 1
#fi


echo "$timeStamp" >POLTRNH_REPORT.LOG
echo "Policy Transaction History TRANSFORMATION" >>POLTRNH_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, ZMRIE00, ALTER_REASON_CODE" >>POLTRNH_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> POLTRNH_REPORT.LOG


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGPOLTRNH';
--commit;

--execute DM_data_transform.DM_policytran_transform(1000,'Y',$1);
execute DM_data_trans_polhis.DM_policytran_transform(1000,'Y');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGPOLTRNH';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Policy Transaction History Procedure executed successfully." >> POLTRNH_REPORT.LOG 
else
   echo "Policy Transaction History Procedure executed With errors check the log table in DB." >> POLTRNH_REPORT.LOG 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> POLTRNH_REPORT.LOG
cat POLTRNH_REPORT.LOG > "${DM_logfilepath}STAGE2_POLTRNH_REPORT${timeStamp}.LOG"
