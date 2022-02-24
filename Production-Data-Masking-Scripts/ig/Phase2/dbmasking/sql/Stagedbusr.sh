. /opt/ig/dbmasking/conf/db.prop
#echo "STAGEDBUSR/Bt7PdKHE@stgprd22";
echo "$STGDBSCHEMA/$STGDBPWD@$STGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
#echo "set underline off"
#echo "set term off"
#echo "set feed off"
echo "set serveroutput on"

echo "@/opt/ig/dbmasking/sql/Truncate_tables/STG_Truncate_tables.sql"
#echo "@/opt/ig/dbmasking/sql/export/stage/TITPAMCAMPAIGN.sql"
#echo "@/opt/ig/dbmasking/sql/export/stage/TITPAMMONTRF.sql"    
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMBILDAT.sql"  
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMDINECITI.sql"
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMMISCLN.sql"     
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMMISTRA.sql"     
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMPOLDATA.sql"   
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMPOSTTGTD.sql"
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMRFDPREM.sql"   
#echo "@/opt/ig/dbmasking/sql/export/stage/TOTPAMVALCHKD.sql"   


exit 0
