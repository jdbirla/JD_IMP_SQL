#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">Polhis_Apirno.log


echo "$timeStamp" >Polhis_Apirno.log
echo "Policy History Aprino Transformation" >>Polhis_Apirno.log
echo "SOURCE TABLE(s) : " >>Polhis_Apirno.log

sqlplus -s $DM_dbconnection << EOF >> Polhis_Apirno.log


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON


--execute DM_data_transform.dm_polhis_apirno(1000,'Y');
execute DM_data_trans_polhis.dm_polhis_apirno(1000,'Y');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGAPIRNO';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Policy History Apirno Procedure executed successfully." >> Polhis_Apirno.log 
else
   echo "Policy History Apirno Procedure executed With errors check the log table in DB." >> Polhis_Apirno.log 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> Polhis_Apirno.log
cat Polhis_Apirno.log > "${DM_logfilepath}STAGE2_Policy_History_Apirno${timeStamp}.LOG"
