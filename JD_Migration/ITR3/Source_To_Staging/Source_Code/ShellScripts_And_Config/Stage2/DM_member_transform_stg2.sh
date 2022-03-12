#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">MEMBERPOLICY_REPORT.LOG

#if [ "$#" -eq "0" ]
#then
#   echo "Invalid Arguments..Exiting .. check the MEMBERPOLICY_REPORT.LOG" 
#   echo "Invalid Arguments.." >>MEMBERPOLICY_REPORT.LOG
#   echo "Usage: <sh DM_member_transform_stg2.sh date in <YYYYMMDD>>.." >>MEMBERPOLICY_REPORT.LOG
#   echo "Example: <sh DM_member_transform_stg2.sh 20160101>" >>MEMBERPOLICY_REPORT.LOG
#cat MEMBERPOLICY_REPORT.LOG > $DM_logfilepath/"STAGE2_MEMBERPOLICY_REPORT"$timeStamp".LOG"
#   exit 1
#fi

echo "$timeStamp" >MEMBERPOLICY_REPORT.LOG
echo "MEMBER POLICY TRANSFORMATION" >>MEMBERPOLICY_REPORT.LOG
echo "SOURCE TABLE(s) : ZMRAP00, MEMPOL, ZMRIS00  , ZMRFCT00, mempol_view, GRP_POL_FREE" >>MEMBERPOLICY_REPORT.LOG

sqlplus -s $DM_dbconnection << EOF >> MEMBERPOLICY_REPORT.LOG


SET PAGESIZE 80
SET LINESIZE 800
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

--DELETE FROM ERROR_LOG where jobname = 'TITDMGMBRINDP2';
--commit;

PROMPT "***********************************************"

PROMPT "Started Grup pol free  Execution: "$timeStamp

--execute DM_data_transform.DM_Mempol_grp_pol(1000,'Y');
execute DM_data_trans_mempol.DM_Mempol_grp_pol(1000,'Y');

PROMPT "Ended Grup pol free  Execution: "$timeStamp
PROMPT "***********************************************"

PROMPT "Started Old Policy Execution: "$timeStamp
--execute DM_data_transform.DM_Mempol_oldpol(1000,'Y');
execute DM_data_trans_mempol.DM_Mempol_oldpol(1000,'Y');
PROMPT "Ended  Old Policy Execution  : "$timeStamp
PROMPT "***********************************************"
PROMPT "Started Member  Policy Execution: "$timeStamp
--execute DM_data_transform.DM_MEMPOL_transform(1000,'Y',$1);
execute DM_data_trans_mempol.DM_MEMPOL_transform(1000,'Y');
PROMPT "Ended Member Policy Execution: "$timeStamp
PROMPT "***********************************************"
PROMPT "Started BTDATE,PTDATE Update Execution: "$timeStamp
--execute DM_data_transform.DM_MEMPOL_BTPTUPDATE(1000,'Y');
PROMPT "Ended BTDATE,PTDATE Update Execution: "$timeStamp
PROMPT "***********************************************"







PROMPT     			 	 SOURCE_TABLE                                                      		 TARGET_TABLE          INPUT_CNT   OUTPUT_CNT STATUS   ERRORMSG ;	
PROMPT     				 ============                                                       		 =========             ========== ==========  ======== ========;
SELECT LPAD(SOURCE_TABLE,100,' ')||LPAD(TARGET_TABLE,15,' ')||lpad(to_char(INPUT_CNT),15,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      '
|| ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE IN ('GRPPOL_ZMRAP00','MEMPOL','TITDMGMBRINDP1','BTDT_MBRINDP1');

EXIT




EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "MEMBER POLICY Procedure executed successfully." >> MEMBERPOLICY_REPORT.LOG
else
   echo "MEMBER POLICY Procedure executed With errors check the log table in DB." >> MEMBERPOLICY_REPORT.LOG
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'` 
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> MEMBERPOLICY_REPORT.LOG
cat MEMBERPOLICY_REPORT.LOG > "${DM_logfilepath}STAGE2_MEMBERPOLICY_REPORT${timeStamp}.LOG"
exit 0
