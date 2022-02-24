echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"
echo "Set NLS_LANG=JA16SJIS"


####################VM1DTA TABLES#################################


echo "exec APM_DBMASK_MERG_AUDIT_CLEXPF"
echo "exec APM_DBMASK_MERG_AUDIT_CLNT"
echo "exec APM_DBMASK_MERG_AUDIT_CLNTPF"
echo "exec APM_DBMASK_MERG_CLBAPF"
echo "exec APM_DBMASK_MERG_CLEXPF"
echo "exec APM_DBMASK_MERG_CLNTPF"
echo "exec APM_DBMASK_MERG_GMHDPF"
echo "exec APM_DBMASK_MERG_GMHIPF"
echo "exec APM_DBMASK_MERG_ZALTPF"
echo "exec APM_DBMASK_MERG_ZCLNPF"
echo "exec APM_DBMASK_MERG_ZMCIPF"

exit 0










