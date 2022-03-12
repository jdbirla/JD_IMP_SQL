#########################################################################
#UNIX SCRIPT FOR DATA MIGRATION						#
#IN THIS SCRIPT WE WILL LOAD THE DATA FROM CSV FILE TO STAGE 3 TABLES	#
#UNIX SCRIPT DEVELOPED BY JD					#
#DATE : 29 DEC 2017							#
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
DM_tablename=$1
run_time=`date '+%Y-%m-%d%H%M%S'`
echo "SQL Loader process started :"`date '+%Y-%m-%d%H%M%S'` >> $1"_loader.log"
tr -d $'\r' < $DM_inIIIcsvpath/$DM_tablename.CSV > temp_file.CSV
if [ $? -ne 0 ]
then
  echo "CONTROL M character removal fail !!! ">> $1"_loader.log"
  exit 1
fi
mv temp_file.CSV $DM_inIIIcsvpath/$DM_tablename.CSV
if [ $? -ne 0 ]
then
  echo "Dummy file movement removal fail !!! ">> $1"_loader.log"
  exit 1
fi

#if [[ -f $DM_badfilepath/$DM_tablename.bad ]]
#then
#  rm -f $DM_badfilepath/$DM_tablename.bad 
#fi

sqlldr USERID=$DM_dbconnection  CONTROL=$DM_ctlfilepath/$DM_tablename.ctl ROWS=500 ERRORS=1000 LOG=$DM_logfilepath/$DM_tablename$run_time.log BAD=$DM_badfilepath/$DM_tablename$run_time.bad DATA=$DM_inIIIcsvpath/$DM_tablename.CSV DISCARD=$DM_dicfilepath/$DM_tablename.dis

retcode=`echo $?` 
case "$retcode" in 
    0 ) 
         unset oraerr
         oraerr=`grep -c "ORA-" $DM_logfilepath/$DM_tablename$run_time.log`
         if [ "$oraerr" -ne 0 ]
         then
            echo "LOADING Failed. ORA ERROR exists in the LOG File. !!! ">> $1"_loader.log"
            echo "SQL*Loader execution Failed" >> $1"_loader.log"
         awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt  
            exit 1
         fi
         if [[ -f $DM_badfilepath/$DM_tablename$run_time".bad" ]]
         then
              v_bad=`wc -l $DM_badfilepath/$DM_tablename$run_time".bad"`
         else 
              v_bad=0
         fi
              if [ "$v_bad" -ne 0 ]
              then
                  #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
                  awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt

                  mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt
	          echo " BAD Records found while loading data into staging table" >> $1"_loader.log"
                  echo "SQL*Loader execution Failed" >> $1"_loader.log"
              else
                  #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="S"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
                  awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="S"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
                  mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt
                  echo " SQL Loader successfuly loaded into staging table" >> $1"_loader.log"
              fi ;; 
    1 )    
         echo "SQL*Loader execution exited with EX_FAIL, see logfile" >> $1"_loader.log"
           
         #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
          awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt ;; 
    2 ) 
         echo "SQL*Loader execution exited with EX_WARN, see logfile" >>  $1"_loader.log"
         #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt ;; 
    3 ) 
         echo "SQL*Loader execution encountered a fatal error" >> $1"_loader.log"
         #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt ;; 
    * )
         echo "unknown return code" >> $1"_loader.log"
         #awk -v var="$DM_tablename.CSV" '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         awk -v var=`echo "$DM_tablename.CSV"|sed s/^TMP_//g` '{if($1==var) {$2="F"} print $0}' $DM_inputstageIII/DM_Inputlist_stg3.txt >test3.txt
         mv test3.txt $DM_inputstageIII/DM_Inputlist_stg3.txt ;; 
esac

if [ "$?" -ne 0 ] 
then
#   echo "SQL LOADER completed successfully" >> $1"_loader.log"
#else 
   echo "SQL LOADER Errors" >> $1"_loader.log"
fi
echo "SQL Loader process end :"`date '+%Y-%m-%d%H%M%S'` >> $1"_loader.log"
exit 0
