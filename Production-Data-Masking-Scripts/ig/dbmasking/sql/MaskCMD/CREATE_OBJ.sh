echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


#Export DATA objects
#MERGE DATA OBJECTS
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_AUDIT_CLEXPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_AUDIT_CLEXPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_AUDIT_CLNTPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_AUDIT_CLNT_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_CLBAPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_CLEXPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_CLNTPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_GMHIPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_ZALTPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_ZCLNPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_ZMCIPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_gmhdpf_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/AUDIT_CLEXPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/AUDIT_CLNT.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/AUDIT_CLNTPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/CLBAPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/CLEXPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/CLNTPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/GMHDPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/GMHIPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/ZALTPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/ZCLNPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/ZMCIPF.sql"





exit 0