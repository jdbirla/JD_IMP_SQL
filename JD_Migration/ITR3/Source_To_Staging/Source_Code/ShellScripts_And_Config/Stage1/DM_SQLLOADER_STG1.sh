#!/bin/sh
#########################################################################
#UNIX SCRIPT FOR DATA MIGRATION						#
#IN THIS SCRIPT WE WILL LOAD THE DATA FROM CSV FILE TO STAGE 1 TABLES	#
#UNIX SCRIPT DEVELOPED BY JD					#
#DATE : 29 DEC 2017							#
#VERSION : 0.1								#
######################################################################### 
. /opt/ig/Datamigration/config/DM_Config.ini

logFileDate=`date +"%Y%m%d%H:%M:%S"`
logFilename=$DM_logfilepath$0$logFileDate".LOG."

echo "Stage 1 Loading started at:[ " `date`" ]">> $logFilename

# Loop for reading input file for STAGE 1 Loaders

for filename in `cat $DM_inputfilepath/DM_Inputlist_stg1.txt|grep -v ".CSV S" |cut -d " " -f1`
do 

  unset rerunflg
  rerunflg=`cat $DM_inputfilepath/DM_Inputlist_stg1.txt|grep $filename |cut -d " " -f2` 
  if [ "${rerunflg}" = "F" ]
  then
    cp $DM_inputcsvpath/$filename $DM_inputcsvpath/"TMP_"$filename
      if [ "$?" -ne 0 ] 
      then
        echo "Copy failure for TMP" $filename >> $logFilename
      fi
    table_name="TMP_"`basename $filename ".CSV"`
  else
    table_name=`basename $filename ".CSV"`
  fi
    echo $table_name

  if [[  -f $DM_inputcsvpath/$filename ]]
  then

    if [[  -s $DM_inputcsvpath/$filename ]]
    then 

      echo "Loading process started for - "$filename " at ["`date`"] " >> $logFilename   

      # Loader script calling
      sh DM_Loader.sh $table_name

      if [ "$?" -eq 0 ] 
      then
        echo "success for" $filename >> $logFilename
      else
        echo "Fail for" $filename
        awk -v var="$filename" '{if($1==var) {$2="F"} print $0}' $DM_inputfilepath/DM_Inputlist_stg1.txt >test3.txt
        mv test3.txt $DM_inputfilepath/DM_Inputlist_stg1.txt
      fi
         
#### add the script call for TMP data population package to maintable
  if [ $rerunflg = 'F' ]
  then
      sh DM_rerunstagecp.sh $table_name
      if [ "$?" -eq 0 ]
      then
        echo "Re-run copy success for" $filename >> $logFilename
      else
        echo " Re-run copy Fail for" $filename
        awk -v var="$filename" '{if($1==var) {$2="F"} print $0}' $DM_inputfilepath/DM_Inputlist_stg1.txt >test3.txt
        mv test3.txt $DM_inputfilepath/DM_Inputlist_stg1.txt
      fi
   fi

    else
      echo "ERROR : "$filename" is EMPTY. Continuing with the next file." >> $logFilename

    fi
  else
      echo "ERROR : "$filename" is NOT EXISTS in the ["$DM_inputcsvpath"]. continuing with the next file." >> $logFilename
  fi

     echo "Loading process End for - "$filename " at ["`date`"] " >> $logFilename

done
echo "Ending of the script" `date` >>$logFilename
