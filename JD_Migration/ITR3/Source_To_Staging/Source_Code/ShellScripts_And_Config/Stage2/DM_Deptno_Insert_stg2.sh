#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">DPTNO_Insert.log


echo "$timeStamp" >DPTNO_Insert.log
echo "DPNTNO Insert Transformation" >>DPTNO_Insert.log
echo "SOURCE TABLE(s) : " >>DPTNO_Insert.log

sqlplus -s $DM_dbconnection << EOF >> DPTNO_Insert.log


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON


--execute DM_data_transform.dm_DPNTNO_INSERT(1000,'Y');
execute DM_data_trans_polhis.dm_DPNTNO_INSERT(1000,'Y');
column SOURCE_TABLE format a40
PROMPT 			SOURCE TABLE											TARGET_TABLE    INPUT_CNT  	OUTPUT_CNT	 STATUS ERRORMSG ;
PROMPT 			============   											 ========= 	 ========== 	============     ====== ========;
SELECT 		       SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='TITDMGMBRINDP2';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "DPNTNO Insert Procedure executed successfully." >> DPTNO_Insert.log 
else
   echo "DPNTNO Insert Procedure executed With errors check the log table in DB." >> DPTNO_Insert.log 
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> DPTNO_Insert.log
cat DPTNO_Insert.log > "${DM_logfilepath}STAGE2_DPNTNO_Insert${timeStamp}.LOG"
