#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">Corr_Addr.log


echo "$timeStamp" >Corr_Addr.log
echo "Correspondence Address Transformation" >>Corr_Addr.log
echo "SOURCE TABLE(s) : " >>Corr_Addr.log

sqlplus -s $DM_dbconnection << EOF >> Corr_Addr.log


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON



execute dm_data_trans_corraddress.dm_corraddr_transformation(1000,'N');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGCORADDR';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "Correspondence Address Procedure executed successfully." >> Corr_Addr.log 
else
   echo "Correspondence Address Procedure executed With errors check the log table in DB." >> Corr_Addr.log 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> Corr_Addr.log
cat Corr_Addr.log > "${DM_logfilepath}STAGE2_Correspondence_Address${timeStamp}.LOG"
