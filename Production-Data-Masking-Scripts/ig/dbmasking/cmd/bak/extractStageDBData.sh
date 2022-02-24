#!/bin/bash
##################################################################################
# File Name		: extractStageDBData.sh
# Author		: Sharad VIRESH KUMAR
# Description	: Extract data from IG Stage DB
#
##################################################################################
# Change log:
#
##################################################################################

/usr/bin/echo "========================================================================"
/usr/bin/echo "============== Cleanup of Old Stage Table files Begin =================="
/usr/bin/echo "========================================================================"

if [ -f '${HITOKU_USER_INPUT}/TITPAMCAMPAIGN.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TITPAMCAMPAIGN.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TITPAMCAMPAIGN.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TITPAMMONTRF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TITPAMMONTRF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TITPAMMONTRF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMBILDAT.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMBILDAT.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMBILDAT.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMDINECITI.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMDINECITI.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMDINECITI.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMMISCLN.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMMISCLN.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMMISCLN.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMMISTRA.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMMISTRA.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMMISTRA.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMPOLDATA.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMPOLDATA.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMPOLDATA.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMPOSTTGTD.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMPOSTTGTD.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMPOSTTGTD.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMRFDPREM.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMRFDPREM.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMRFDPREM.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/TOTPAMVALCHKD.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/TOTPAMVALCHKD.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/TOTPAMVALCHKD.csv"
		exit 1
	fi
fi

/usr/bin/echo "========================================================================"
/usr/bin/echo "=============== Cleanup of Old Stage Table files End ==================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo "==================== IG Stage DB Extraction Begin. ====================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "

${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TITPAMCAMPAIGN.sql" ${HITOKU_USER_INPUT} &
pids[0]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TITPAMMONTRF.sql" ${HITOKU_USER_INPUT} &
pids[1]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMBILDAT.sql" ${HITOKU_USER_INPUT} &
pids[2]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMDINECITI.sql" ${HITOKU_USER_INPUT} &
pids[3]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMMISCLN.sql" ${HITOKU_USER_INPUT} &
pids[4]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMMISTRA.sql" ${HITOKU_USER_INPUT} &
pids[5]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMPOLDATA.sql" ${HITOKU_USER_INPUT} &
pids[6]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMPOSTTGTD.sql" ${HITOKU_USER_INPUT} &
pids[7]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMRFDPREM.sql" ${HITOKU_USER_INPUT} &
pids[8]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_STAGE_SCHEMA_NAME}/${ORACLE_IG_STAGE_SCHEMA_PASSWORD}@${ORACLE_IG_STAGE_SID} "@${DTMSK_SQL_STAGE_DIR}/TOTPAMVALCHKD.sql" ${HITOKU_USER_INPUT} &
pids[9]=$!

/usr/bin/echo " "
/usr/bin/echo "Stage DB Sql's for extraction launched. Will wait for their completion"
/usr/bin/echo " "

# Wait for all pids
for pid in ${pids[*]}; do
	while kill -0 "$pid"; do
		sleep 1
	done
done

/usr/bin/echo "========================================================================"
/usr/bin/echo "================== IG Stage DB Extraction Completed. ==================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "
/usr/bin/echo "TITPAMCAMPAIGN extracted with "`wc -l < ${HITOKU_USER_INPUT}/TITPAMCAMPAIGN.csv`" lines."
/usr/bin/echo "TITPAMMONTRF extracted with "`wc -l < ${HITOKU_USER_INPUT}/TITPAMMONTRF.csv`" lines."
/usr/bin/echo "TOTPAMBILDAT extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMBILDAT.csv`" lines."
/usr/bin/echo "TOTPAMDINECITI extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMDINECITI.csv`" lines."
/usr/bin/echo "TOTPAMMISCLN extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMMISCLN.csv`" lines."
/usr/bin/echo "TOTPAMMISTRA extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMMISTRA.csv`" lines."
/usr/bin/echo "TOTPAMPOLDATA extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMPOLDATA.csv`" lines."
/usr/bin/echo "TOTPAMPOSTTGTD extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMPOSTTGTD.csv`" lines."
/usr/bin/echo "TOTPAMRFDPREM extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMRFDPREM.csv`" lines."
/usr/bin/echo "TOTPAMVALCHKD extracted with "`wc -l < ${HITOKU_USER_INPUT}/TOTPAMVALCHKD.csv`" lines."
/usr/bin/echo " "
/usr/bin/echo " "

exit 0