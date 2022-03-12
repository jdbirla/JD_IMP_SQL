#########################################################################
#UNIX SCRIPT FOR DATA MIGRATION						#
#IN THIS SCRIPT WE WILL LOAD THE DATA FROM TMP table TO STAGE 1 TABLES	#
#    FOR RE-RUN                                                         #
#UNIX SCRIPT DEVELOPED BY JD					#
#DATE : 12 FEB 2018            						#
#VERSION : 0.1								#
#########################################################################
#!/bin/sh

. /opt/ig/Datamigration/config/DM_Config.ini

if [ $# -ne 1 ] 
then
  echo "Invalid Arguments !!! "
  echo "USAGE [ DM_loader.sh <<TABLE NAME>> ]" 
  exit 1
fi

DM_tmptablename=`echo $1|sed s/^TMP_//g`
echo $DM_tmptablename


timeStamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "RE-run Started Job Execution: "$timeStamp >> $1"_loader.log"
echo "DATA COPY for RE-RUN For Table name:"$DM_tmptablename  >> $1"_loader.log"

retcd=`sqlplus -s $DM_dbconnection >> $1"_loader.log" << EOF 
set feed off veri off head off 
SET SERVEROUTPUT ON;
execute create_bkup('$DM_tmptablename');
EXIT
EOF`

if [ "$?" -eq "0" ] 
then
   echo "SQL LOADER completed successfully" >> $1"_loader.log"
else 
   echo "SQL Loader Re-run Errors during data copy from TMP" >> $1"_loader.log"
fi

echo "RE-run  Job Execution END : "$timeStamp >> $1"_loader.log"
exit 0
