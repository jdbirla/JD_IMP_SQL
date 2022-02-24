#!/bin/bash
##################################################################################
# File Name		: extractCoreDBData.sh
# Author		: Sharad VIRESH KUMAR
# Description	: Extract data from IG Core DB
#
##################################################################################
# Change log:
#
##################################################################################

/usr/bin/echo "========================================================================"
/usr/bin/echo "============== Cleanup of Old Core Table files Begin ==================="
/usr/bin/echo "========================================================================"

if [ -f '${HITOKU_USER_INPUT}/AUDIT_ASRDPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/AUDIT_ASRDPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/AUDIT_ASRDPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/AUDIT_CLEXPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/AUDIT_CLEXPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/AUDIT_CLEXPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/AUDIT_CLNT.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/AUDIT_CLNT.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/AUDIT_CLNT.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/AUDIT_CLNTPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/AUDIT_CLNTPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/AUDIT_CLNTPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/BABRPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/BABRPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/BABRPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/CLBAPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/CLBAPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/CLBAPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/CLNTQY.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/CLNTQY.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/CLNTQY.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/GMHIPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/GMHIPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/GMHIPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/MIOKPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/MIOKPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/MIOKPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/MV_ZMCIPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/MV_ZMCIPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/MV_ZMCIPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/MV_ZMCIPF_CRDT.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/MV_ZMCIPF_CRDT.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/MV_ZMCIPF_CRDT.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/NAME.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/NAME.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/NAME.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/POLDATATEMP.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/POLDATATEMP.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/POLDATATEMP.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZALTPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZALTPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZALTPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZCLNPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZCLNPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZCLNPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZCORPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZCORPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZCORPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZMCIPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZMCIPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZMCIPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZMIEPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZMIEPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZMIEPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZMUPPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZMUPPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZMUPPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZPDAPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZPDAPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZPDAPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZREPPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZREPPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZREPPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZSTGPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZSTGPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZSTGPF.csv"
		exit 1
	fi
fi

if [ -f '${HITOKU_USER_INPUT}/ZVCHPF.csv' ] ; then
	/usr/bin/rm'${HITOKU_USER_INPUT}/ZVCHPF.csv'
	if [ $? != 0 ]; then
		/usr/bin/echo "Unable to delete ${HITOKU_USER_INPUT}/ZVCHPF.csv"
		exit 1
	fi
fi

/usr/bin/echo "========================================================================"
/usr/bin/echo "=============== Cleanup of Old Core Table files End ===================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo "===================== IG Core DB Extraction Begin. ====================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "

# Extract AUDIT_ASRDPF
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/AUDIT_ASRDPF.sql" ${HITOKU_USER_INPUT} &
pids[0]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/AUDIT_CLEXPF.sql" ${HITOKU_USER_INPUT} &
pids[1]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/AUDIT_CLNT.sql" ${HITOKU_USER_INPUT} &
pids[2]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/AUDIT_CLNTPF.sql" ${HITOKU_USER_INPUT} &
pids[3]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/BABRPF.sql" ${HITOKU_USER_INPUT} &
pids[4]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/CLBAPF.sql" ${HITOKU_USER_INPUT} &
pids[5]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/CLEXPF.sql" ${HITOKU_USER_INPUT} &
pids[6]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/CLNTPF.sql" ${HITOKU_USER_INPUT} &
pids[7]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/CLNTQY.sql" ${HITOKU_USER_INPUT} &
pids[8]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/GMHIPF.sql" ${HITOKU_USER_INPUT} &
pids[9]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/MIOKPF.sql" ${HITOKU_USER_INPUT} &
pids[10]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/MV_ZMCIPF.sql" ${HITOKU_USER_INPUT} &
pids[11]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/MV_ZMCIPF_CRDT.sql" ${HITOKU_USER_INPUT} &
pids[12]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/NAME.sql" ${HITOKU_USER_INPUT} &
pids[13]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/POLDATATEMP.sql" ${HITOKU_USER_INPUT} &
pids[14]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZALTPF.sql" ${HITOKU_USER_INPUT} &
pids[15]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZCLNPF.sql" ${HITOKU_USER_INPUT} &
pids[16]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZCORPF.sql" ${HITOKU_USER_INPUT} &
pids[17]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZMCIPF.sql" ${HITOKU_USER_INPUT} &
pids[18]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZMIEPF.sql" ${HITOKU_USER_INPUT} &
pids[19]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZMUPPF.sql" ${HITOKU_USER_INPUT} &
pids[20]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZPDAPF.sql" ${HITOKU_USER_INPUT} &
pids[21]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZREPPF.sql" ${HITOKU_USER_INPUT} &
pids[22]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZSTGPF.sql" ${HITOKU_USER_INPUT} &
pids[23]=$!
${ORACLE_SQLPLUS} -silent ${ORACLE_IG_CORE_SCHEMA_NAME}/${ORACLE_IG_CORE_SCHEMA_PASSWORD}@${ORACLE_IG_CORE_SID} "@${DTMSK_SQL_CORE_DIR}/ZVCHPF.sql" ${HITOKU_USER_INPUT} &
pids[24]=$!

/usr/bin/echo " "
/usr/bin/echo "Core DB Sql's for extraction launched. Will wait for their completion"
/usr/bin/echo " "

# Wait for all pids
for pid in ${pids[*]}; do
	while kill -0 "$pid"; do
		sleep 1
	done
done

/usr/bin/echo "========================================================================"
/usr/bin/echo "=================== IG Core DB Extraction Completed. ==================="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "
/usr/bin/echo "AUDIT_ASRDPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/AUDIT_ASRDPF.csv`" lines."
/usr/bin/echo "AUDIT_CLEXPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/AUDIT_CLEXPF.csv`" lines."
/usr/bin/echo "AUDIT_CLNT extracted with "`wc -l < ${HITOKU_USER_INPUT}/AUDIT_CLNT.csv`" lines."
/usr/bin/echo "AUDIT_CLNTPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/AUDIT_CLNTPF.csv`" lines."
/usr/bin/echo "BABRPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/BABRPF.csv`" lines."
/usr/bin/echo "CLBAPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/CLBAPF.csv`" lines."
/usr/bin/echo "CLNTQY extracted with "`wc -l < ${HITOKU_USER_INPUT}/CLNTQY.csv`" lines."
/usr/bin/echo "GMHIPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/GMHIPF.csv`" lines."
/usr/bin/echo "MIOKPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/MIOKPF.csv`" lines."
/usr/bin/echo "MV_ZMCIPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/MV_ZMCIPF.csv`" lines."
/usr/bin/echo "MV_ZMCIPF_CRDT extracted with "`wc -l < ${HITOKU_USER_INPUT}/MV_ZMCIPF_CRDT.csv`" lines."
/usr/bin/echo "NAME extracted with "`wc -l < ${HITOKU_USER_INPUT}/NAME.csv`" lines."
/usr/bin/echo "POLDATATEMP extracted with "`wc -l < ${HITOKU_USER_INPUT}/POLDATATEMP.csv`" lines."
/usr/bin/echo "ZALTPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZALTPF.csv`" lines."
/usr/bin/echo "ZCLNPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZCLNPF.csv`" lines."
/usr/bin/echo "ZCORPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZCORPF.csv`" lines."
/usr/bin/echo "ZMCIPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZMCIPF.csv`" lines."
/usr/bin/echo "ZMIEPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZMIEPF.csv`" lines."
/usr/bin/echo "ZMUPPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZMUPPF.csv`" lines."
/usr/bin/echo "ZPDAPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZPDAPF.csv`" lines."
/usr/bin/echo "ZREPPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZREPPF.csv`" lines."
/usr/bin/echo "ZSTGPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZSTGPF.csv`" lines."
/usr/bin/echo "ZVCHPF extracted with "`wc -l < ${HITOKU_USER_INPUT}/ZVCHPF.csv`" lines."
/usr/bin/echo " "
/usr/bin/echo " "

exit 0