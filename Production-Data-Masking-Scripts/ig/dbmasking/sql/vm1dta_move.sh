echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


####################VM1DTA TABLES#################################


echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/AUDIT_ASRDPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/CLNTQY_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/MIOKPF_MoveData.sql"
#echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/POLDATATEMP_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZCORPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZMIEPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZMUPPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZPDAPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZREPPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZSTGPF_MoveData.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/MOVE_NORMAL/ZVCHPF_MoveData.sql"



exit 0