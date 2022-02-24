echo "STAGEDBUSR/Bt7PdKHE@stgprd22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"



####################STAGE TABLES#################################
echo "@/opt/ig/dbmasking/sql/merge/stage/TITPAMCAMPAIGN_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/stage/TITPAMMONTRF_EXT.sql"

exit 0