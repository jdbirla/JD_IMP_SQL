echo "STAGEDBUSR/Bt7PdKHE@stgprd22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


####################STAGE TABLES#################################
echo "@/opt/ig/dbmasking/sql/merge/stage/Move/TITPAMMONTRF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/stage/Move/TITPAMCAMPAIGN_MoveData.sql"

exit 0