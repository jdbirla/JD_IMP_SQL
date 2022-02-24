. /opt/ig/dbmasking/conf/db.prop

echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

####################VM1DTA TABLES#################################

echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/AUDIT_ASRDPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZCORPF_MoveData.sql"
#echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZREPPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZSTGPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZINSDTLSPF_MoveData.sql"
#echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZVCHPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZBENFDTLSPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZIRHPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZIRDPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZCLEPF_MoveData.sql"

exit 0
