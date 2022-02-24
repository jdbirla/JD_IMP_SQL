echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

echo "@/opt/ig/dbmasking/sql/AUDIT_CLEXPF.sql"
echo "@/opt/ig/dbmasking/sql/CLNTPF.sql"

exit 0