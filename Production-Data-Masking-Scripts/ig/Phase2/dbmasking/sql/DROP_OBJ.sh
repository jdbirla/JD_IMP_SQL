. /opt/ig/dbmasking/conf/db.prop
#echo "VM1DTA/MRpEW84Q@IGPRD24";
echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

#All PIP objects drop scripts, or any other drop object scripts.
echo "@/opt/ig/dbmasking/sql/OBJECT_DROP_SQLS/dROP_OBJS_AUDIT_CLRRPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_DROP_SQLS/DROP_OBJS_ZALTPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_DROP_SQLS/DROP_OBJS_CLNTPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_DROP_SQLS/DROP_OBJS_ALL_EXT_TABLES.sql"

exit 0
