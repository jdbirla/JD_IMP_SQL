
. /opt/ig/dbmasking/conf/db.prop

echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

####################VM1DTA TABLES#################################

echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/AUDIT_ASRDPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZCORPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZREPPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZSTGPF_EXT.sql"
## New Table Entry ####
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZINSDTLSPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZBENFDTLSPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZIRHPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZIRDPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZCLEPF_EXT.sql"

exit 0
