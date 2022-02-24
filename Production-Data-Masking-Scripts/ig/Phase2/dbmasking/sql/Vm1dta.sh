. /opt/ig/dbmasking/conf/db.prop
echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

echo "@/opt/ig/dbmasking/sql/export/core/AUDIT_ASRDPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZCORPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZREPPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZSTGPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZINSDTLSPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZBENFDTLSPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZIRHPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZIRDPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZCLEPF.sql"

exit 0
