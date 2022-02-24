echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


####################VM1DTA TABLES#################################

echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/AUDIT_ASRDPF_EXT.sql"
#echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/BABRPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/CLNTQY_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/MIOKPF_EXT.sql"
#echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/NAME_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/POLDATATEMP_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZCORPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZMIEPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZMUPPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZPDAPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZREPPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZSTGPF_EXT.sql"
echo "@/opt/ig/dbmasking/sql/merge/core/NormalApproach/ZVCHPF_EXT.sql"


exit 0