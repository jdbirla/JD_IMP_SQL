#!/usr/bin/bash

hm=`pwd`
cd vm1dta_config
. vm1_db_config.ini

cd $hm

batchid=`sqlplus -s $DM_dbconnect << EOF
set head off 
select A.BATCH_NAME || ':' ||  A.JOB_NUM || ':' || A.SCHD_STATUS from Jd1dta.dmbmonpf A inner join Jd1dta.dm_mail_alert B on a.batch_name = b.batch_name order by A.DATIME desc, A.job_num desc FETCH NEXT 1 ROWS ONLY;
exit
EOF`

v_BATCH_NAME=`echo ${batchid} | cut -d ":" -f1`
v_JOB_NUM=`echo ${batchid} | cut -d ":" -f2`
v_SCHD_STATUS=`echo ${batchid} | cut -d ":" -f3`

if [ "$v_SCHD_STATUS" = "90" ] || [ "$v_SCHD_STATUS"  = "01" ] 
then
 sqlplus -s $DM_dbconnect @batch_monitor.sql ${v_BATCH_NAME} ${v_JOB_NUM}
 cat BATCH_MONITOR.txt | mail -s "Data Migration Running Batch Status" jbirla@jdc.com markkevin.sarmiento@jdc.com
fi

batchid1=`sqlplus -s $DM_dbconnect << EOF
set head off 
delete from dm_mail_alert;
commit;
exit
EOF`

exit 0

