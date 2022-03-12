#!/bin/sh
#########################################################################
#UNIX SCRIPT FOR DATA MIGRATION						#
#IN THIS SCRIPT WE WILL CREATE TABLE FOR STAGE 1 AND STAGE 3	        #
#UNIX SCRIPT DEVELOPED BY JD					#
#DATE : 03 DEC 2017							#
# USAGE : sh DM_DDL_Index_create.sh <<SQL file name>>                     #
#VERSION : 0.1								#
#########################################################################
. /home/jpacst/Datamigration/config/DM_Config.ini
#Two input parameters USER_ID and Password
echo "`date` :Starting DM_DDL_Index_create run script." 
echo "`date` :Starting DM_DDL_Index_create run script." >> Index_create.log
sqlInfile=$1
if [[ -f ./"${sqlInfile}" ]]
then
  if [[ -s ./"${sqlInfile}" ]]
  then
       #DB_USER=$1
       #echo "$DB_USER"
       #DB_SCHEMA=$2
       #echo "$DB_SCHEMA"
       #DB_PWD=$3
       #echo "$DB_PWD"
result=`sqlplus -s $DM_dbconnect >> Index_create.log <<EOF
  spool $DM_logfilepath/IndexDDL_spool_log.txt
  @./$sqlInfile
  spool off
EOF`

  if [ "$result" -eq "0" ]
  then
     echo "IndexDDL SQL Script Completed" >>Index_create.log
  else
     echo "`date` : Script failed.">> Index_create.log
  fi
  else 
     echo "`date` :File $sqlInfile is empty in present working directory.">> Index_create.log
  fi
else
    echo "`date` :File $sqlInfile not found in present working directory.">> Index_create.log
fi
echo "`date` :DM_DDL_Index_create run script execution completed." >> Index_create.log
echo "`date` :DM_DDL_Index_create run script execution completed." 
