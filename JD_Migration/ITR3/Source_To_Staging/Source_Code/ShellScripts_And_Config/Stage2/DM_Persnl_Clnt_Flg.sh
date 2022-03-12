#!/usr/bin/bash

. /opt/ig/Datamigration/config/DM_Config.ini


timeStamp=`date +'%Y-%m-%d_%H:%M:%S'`

echo "Started Job Execution: "$timeStamp
echo "Started Job Execution: $timeStamp">PERSNL_CLNT_FLG.log


echo "$timeStamp" >PERSNL_CLNT_FLG.log
echo "PERSNL_CLNT_FLG Insert Transformation" >>PERSNL_CLNT_FLG.log
echo "SOURCE TABLE(s) : " >>PERSNL_CLNT_FLG.log

sqlplus -s $DM_dbconnection << EOF >> PERSNL_CLNT_FLG.log


SET PAGESIZE 80

SET LINESIZE 1000
SET WRAP ON
SET HEADING OFF
SET FEEDBACK OFF
SET TAB ON

execute dm_persnl_clnt_flg(1000,'Y');
column SOURCE_TABLE format a40
PROMPT                  SOURCE TABLE                                                                                    TARGET_TABLE    INPUT_CNT       OUTPUT_CNT       STATUS ERRORMSG ;
PROMPT                  ============                                                                                     =========       ==========     ============     ====== ========;
SELECT                 SOURCE_TABLE || LPAD(TARGET_TABLE,20,' ')||lpad(to_char(INPUT_CNT),10,' ')||LPAD(to_char(OUTPUT_CNT),10,' ')||LPAD(STATUS,6,' ')||'      ' || ERRORMSG FROM DM_TRANSFM_CNTL_TABLE WHERE TARGET_TABLE='PERSNL_CLNT_FLG';

EXIT
EOF
retcd=$?

if [ "$?" -eq 0 ]
then
   echo "PERSNL_CLNT_FLG Insert Procedure executed successfully." >> PERSNL_CLNT_FLG.log
else
   echo "PERSNL_CLNT_FLG Insert Procedure executed With errors check the log table in DB." >> PERSNL_CLNT_FLG.log
fi


timeStamp=`date +'%Y-%m-%d %H:%M:%S'`
echo " Job Execution END: "$timeStamp
echo " Job Execution END: "$timeStamp >> PERSNL_CLNT_FLG.log
cat PERSNL_CLNT_FLG.log > "${DM_logfilepath}STAGE2_PERSNL_CLNT_FLG${timeStamp}.LOG"