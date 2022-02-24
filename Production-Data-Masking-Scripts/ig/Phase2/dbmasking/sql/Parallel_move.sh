. /opt/ig/dbmasking/conf/db.prop

echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"

####################VM1DTA TABLES#################################

echo "exec APM_DBMASK_MERG_AUDIT_CLEXPF";
echo "exec APM_DBMASK_MERG_AUDIT_CLNT"
echo "exec APM_DBMASK_MERG_AUDIT_CLNTPF"
echo "exec APM_DBMASK_MERG_CLBAPF"
echo "exec APM_DBMASK_MERG_CLEXPF"
echo "exec APM_DBMASK_MERG_CLNTPF"
#echo "exec APM_DBMASK_MERG_GMHDPF"
echo "exec APM_DBMASK_MERG_GMHIPF"
echo "exec APM_DBMASK_MERG_ZALTPF"
echo "exec APM_DBMASK_MERG_ZCLNPF"
echo "exec APM_DBMASK_MERG_ZMCIPF"
#echo "exec APM_DBMASK_MERG_ZERRPF"
echo "exec APM_DBMASK_MERG_CLRRPF"
echo "exec APM_DBMASK_MERG_AUDIT_CLRRPF"

#echo "exec APM_DBMASK_MERG_TITDMGMBRP1"
#echo "exec APM_DBMASK_MERG_TITDMGPOLTH_FP"
#echo "exec APM_DBMASK_MERG_TITDMGPOLTRNH"
#echo "exec APM_DBMASK_MERG_TITDMGREF1"
#echo "exec APM_DBMASK_MERG_TITDMGCLNTBANK"
#echo "exec APM_DBMASK_MERG_TITDMGCLNTPRSN"
#echo "exec APM_DBMASK_MERG_TITDMGCLTBK_FP"
#echo "exec APM_DBMASK_MERG_TITDMGCLTPN_FP"
#echo "exec APM_DBMASK_MERG_TITDMGMBIN1_FP"

#echo "exec APM_DBMASK_MERG_TITPAMBILLSTOP"
#echo "exec APM_DBMASK_MERG_TITPAMVALCHKDR"
#echo "exec APM_DBMASK_MERG_TOTPAMMISCLN"
#echo "exec APM_DBMASK_MERG_TOTPAMMISPOL"
#echo "exec APM_DBMASK_MERG_TOTPAMVALCHKD"
#echo "exec APM_DBMASK_MERG_TITDMGCLTRNHIS"
#echo "exec APM_DBMASK_MERGTITDMCLTRHIS_FP"

#----------- These below 3 scripts have been moved to LastStep.sh
#echo "exec REFERESH_MV"
#echo "@/opt/ig/dbmasking/sql/Truncate_tables/VM1DTA_Truncate_tables.sql"
#echo "@/opt/ig/dbmasking/sql/update_masked.sql"


exit 0










