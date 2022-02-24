echo "SYSTEM/password@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


####################GRANT ACCESS to DIR#################################
echo "@/opt/ig/dbmasking/sql/Grant_access.sql"


exit 0