. /opt/ig/dbmasking/conf/db.prop

echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term on"
echo "set feed on"

echo "@/opt/ig/dbmasking/sql/Truncate_tables/VM1DTA_Truncate_tables.sql"
echo "@/opt/ig/dbmasking/sql/update_masked.sql"
echo "exec LOG_BAT_STATUS('MASK_RefreshMV started');
#echo "exec REFERESH_MV"
echo "exec LOG_BAT_STATUS('MASK_RefreshMV done!');

exit 0










