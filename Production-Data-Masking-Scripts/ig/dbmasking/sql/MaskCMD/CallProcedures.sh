echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"
echo "Set NLS_LANG=JA16SJIS"

echo "exec APM_DBMASK_write_to_AUDIT_CLNT('IMP_DATA_DIR','AUDIT_CLNT.csv')"
echo "exec APM_DBMASK_write_to_CLBAPF('IMP_DATA_DIR','CLBAPF.csv')"
echo "exec APM_DBMASK_write_to_CLEXPF('IMP_DATA_DIR','CLEXPF.csv')"
echo "exec APM_DBMASK_write_to_GMHDPF('IMP_DATA_DIR','GMHDPF.csv')"
echo "exec APM_DBMASK_write_to_GMHIPF('IMP_DATA_DIR','GMHIPF.csv')"
echo "exec APM_DBMASK_write_to_ZALTPF('IMP_DATA_DIR','ZALTPF.csv')"
echo "exec APM_DBMASK_write_to_ZCLNPF('IMP_DATA_DIR','ZCLNPF.csv')"
echo "exec APM_DBMASK_write_to_ZMCIPF('IMP_DATA_DIR','ZMCIPF.csv')"
echo "exec APM_DBMASK_writetoAUDIT_CLEXPF('IMP_DATA_DIR','AUDIT_CLEXPF.csv')"
echo "exec APM_DBMASK_writetoAUDIT_CLNTPF('IMP_DATA_DIR','AUDIT_CLNTPF.csv')"
echo "exec APM_DBMASK_writetoCLNTPF('IMP_DATA_DIR','CLNTPF.csv')"



exit 0