#!/bin/sh
#########################################################################
#UNIX SCRIPT FOR DATA MIGRATION                                         #
# THIS SCRIPT IS USED TO REMOVE ONTROL M CHARS FOR FILES/SCRIPTS IN THE #
#                 INPUTTED DIRECTORY                                    #
# USAGE : sh DM_ctrlm_replace.sh <INPUT DIRECTORY>                      #
#UNIX SCRIPT DEVELOPED BY JD                                       #
#DATE : 06 MAR 2018                                                     #
#VERSION : 0.1                                                          #
#########################################################################
controllog="CONTROL_M_LOG_"`date +"%Y%m%d%H:%M:%S"`
inputdir=$1
if [[ -z $inputdir && "$#" -eq "0" ]]
then
  inputdir=`pwd`
fi

echo "Control M removal script started at :"`date +"%Y%m%d%H:%M:%S"` 
echo "Control M removal script started at :"`date +"%Y%m%d%H:%M:%S"` >> $controllog
echo "Control M Replacement for the Inputted directory : ["$inputdir"]" >> $controllog
for file in $(find $inputdir -type f); do
echo "Started control M removal for :["$file"]" >> $controllog
   tr -d '\r' <$file > temp.$$ && mv temp.$$ $file
#   tr -d '\32' <$file > tmp.$$ && mv tmp.$$ $file
echo "Completed control M removal for :["$file"]" >> $controllog
done
echo "Control M removal script completed at :"`date +"%Y%m%d%H:%M:%S"` >> $controllog
echo "Control M removal script end at :"`date +"%Y%m%d%H:%M:%S"` 
exit 0
