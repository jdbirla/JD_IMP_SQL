#!/bin/bash
##################################################################################
# File Name		: extractDataForMasking.sh
# Author		: Sharad VIRESH KUMAR
# Description	: Extract data from IG Core and Stage tables for masking data.
#					The extracted data will be fed as input for hitoku tool, which
#					will mask the information such as Client Name, Credit Card, etc.
#
##################################################################################
# Change log:
#
##################################################################################

# Environment Variables section
export DTMSK_HOME_DIR=/opt/ig/dbmasking
export DTMSK_CMD_DIR=${DTMSK_HOME_DIR}/cmd
export DTMSK_SQL_DIR=${DTMSK_HOME_DIR}/sql/export
export DTMSK_SQL_CORE_DIR=${DTMSK_SQL_DIR}/core
export DTMSK_SQL_STAGE_DIR=${DTMSK_SQL_DIR}/stage
export DTMSK_MOVE_DATA_DIR=${DTMSK_SQL_DIR}/move_data
export DTMSK_CTL_DIR=${DTMSK_HOME_DIR}/ctl
export DTMSK_CTL_CORE_DIR=${DTMSK_CTL_DIR}/core
export DTMSK_CTL_STAGE_DIR=${DTMSK_CTL_DIR}/stage

export ORACLE_HOME=/opt/app/oracle/product/12.1.0/dbhome_1
export ORACLE_BIN=${ORACLE_HOME}/bin
export ORACLE_SQLPLUS=${ORACLE_BIN}/sqlplus
export ORACLE_IG_CORE_SID=igprd22
export ORACLE_IG_CORE_SCHEMA_NAME=vm1dta
export ORACLE_IG_CORE_SCHEMA_PASSWORD=XXXXXX
export ORACLE_IG_STAGE_SID=stgprd22
export ORACLE_IG_STAGE_SCHEMA_NAME=stagedbusr
export ORACLE_IG_STAGE_SCHEMA_PASSWORD=XXXXXXXX

export HITOKU_HOME=/opt/ig/hitoku
export HITOKU_USER_INPUT=${HITOKU_HOME}/user/input
export HITOKU_USER_OUTPUT=${HITOKU_HOME}/user/output

# Set the NLS_LANG to Shift-JIS
export NLS_LANG=japanese_japan.ja16sjis

/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo " extractCoreDBData.sh execution begins at `date`. "
/usr/bin/echo "========================================================================"
/usr/bin/echo " "

# Execute the Core DB Data
extractCoreDBData.sh

/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo "= extractCoreDBData.sh execution ends at `date`. ="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "

/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo " extractStageDBData.sh execution begins at `date`. "
/usr/bin/echo "========================================================================"
/usr/bin/echo " "

# Extract the Stage DB Data
extractStageDBData.sh

/usr/bin/echo " "
/usr/bin/echo " "
/usr/bin/echo "========================================================================"
/usr/bin/echo "= extractStageDBData.sh execution ends at `date`. ="
/usr/bin/echo "========================================================================"
/usr/bin/echo " "
