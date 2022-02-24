echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"



echo "@/opt/ig/dbmasking/sql/export/core/AUDIT_ASRDPF.sql"
#echo "@/opt/ig/dbmasking/sql/export/core/BABRPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/CLNTQY.sql"
echo "@/opt/ig/dbmasking/sql/export/core/MIOKPF.sql"
#echo "@/opt/ig/dbmasking/sql/export/core/NAME.sql"
#echo "@/opt/ig/dbmasking/sql/export/core/POLDATATEMP.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZCORPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZMIEPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZMUPPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZPDAPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZREPPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZSTGPF.sql"
echo "@/opt/ig/dbmasking/sql/export/core/ZVCHPF.sql"

exit 0