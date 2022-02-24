. /opt/ig/dbmasking/conf/db.prop
#echo "VM1DTA/MRpEW84Q@IGPRD24";
echo "$IGDBSCHEMA/$IGDBPWD@$IGDBSID";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"


#Export DATA objects
#MERGE DATA OBJECTS
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/Clear_data.sql"
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
#echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/REFERESH_MV.sql"
#echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/ZERRPF.sql" -- commented on 20211213. PA. This is for ASRF upload error.
#echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBAMSK_ZERRPF_PIP.sql" -- commented
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_CLRRPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/CLRRPF.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_AUDIT_CLRRPF_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/AUDIT_CLRRPF.sql"

exit 0
#--- Skipp staging tables.
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGMBRINDP1_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGPOLTRNH_PIP"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGPOLFP_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBAMSK_TITDMGREF1_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGMBRINDP1.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGPOLTRNH_FREE_PLANS.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGPOLTRNH.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGREF1.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGMBINP1_FP_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGCLTBNK_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGCLTBNK_FP_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGCLNPRN_FP_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITDMGCLNTPRSN_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITPAMBILLSTOP_pip.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TOTPAMMISPOL_pip.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TITPAMVALCHKDR_pip.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TOTPAMVALCHKD_pip.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBMASK_TOTPAMMISCLN_pip.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLNTPRSN_FREEPLAN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGMBRINDP1_FREEPLAN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLNTPRSN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLNTBANK_FREEPLAN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLNTBANK.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TOTPAMMISCLN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TOTPAMVALCHKD.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITPAMVALCHKDR.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITPAMBILLSTOP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TOTPAMMISPOL.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBAMSK_TITDMCLTRNHIS_FP_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/APM_DBAMSK_TITDMCLTRNHIS_PIP.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLTRNHIS_FREEPLAN.sql"
echo "@/opt/ig/dbmasking/sql/OBJECT_CREATION/TITDMGCLTRNHIS.sql"









exit 0
