echo "******************************************************************************"
echo "*************************SQLLDR Started*************************"
echo "******************************************************************************"
cd /opt/ig/hitoku/user/output
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=AUDIT_CLEXPF_TEMP characterset=JA16SJIS data=AUDIT_CLEXPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=AUDIT_CLNT_TEMP characterset=JA16SJIS data=AUDIT_CLNT_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=AUDIT_CLNTPF_TEMP characterset=JA16SJIS data=AUDIT_CLNTPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=CLBAPF_TEMP characterset=JA16SJIS data=CLBAPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=CLEXPF_TEMP characterset=JA16SJIS data=CLEXPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=CLNTPF_TEMP characterset=JA16SJIS data=CLNTPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=GMHDPF_TEMP characterset=JA16SJIS data=GMHDPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=GMHIPF_TEMP characterset=JA16SJIS data=GMHIPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=ZALTPF_TEMP characterset=JA16SJIS data=ZALTPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=ZCLNPF_TEMP characterset=JA16SJIS data=ZCLNPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=ZMCIPF_TEMP characterset=JA16SJIS data=ZMCIPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGMBRINDP1_TEMP characterset=JA16SJIS data=TITDMGMBRINDP1_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGPOLTRNH_FREE_PLANS_TEMP characterset=JA16SJIS data=TITDMGPOLTRNH_FREE_PLANS_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGPOLTRNH_TEMP characterset=JA16SJIS data=TITDMGPOLTRNH_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGREF1_TEMP characterset=JA16SJIS data=TITDMGREF1_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=ZERRPF_TEMP characterset=JA16SJIS data=ZERRPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TOTPAMVALCHKD_TEMP characterset=JA16SJIS data=TOTPAMVALCHKD_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLNTBANK_TEMP characterset=JA16SJIS data=TITDMGCLNTBANK_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLNTBANK_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGCLNTBANK_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGMBRINDP1_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGMBRINDP1_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITPAMVALCHKDR_TEMP characterset=JA16SJIS data=TITPAMVALCHKDR_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TOTPAMMISPOL_TEMP characterset=JA16SJIS data=TOTPAMMISPOL_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITPAMBILLSTOP_TEMP characterset=JA16SJIS data=TITPAMBILLSTOP_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TOTPAMMISCLN_TEMP characterset=JA16SJIS data=TOTPAMMISCLN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLNTPRSN_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGCLNTPRSN_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLNTPRSN_TEMP characterset=JA16SJIS data=TITDMGCLNTPRSN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLTRNHIS_TEMP characterset=JA16SJIS data=TITDMGCLTRNHIS_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=TITDMGCLTRNHIS_FP_TEMP characterset=JA16SJIS data=TITDMGCLTRNHIS_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=CLRRPF_TEMP characterset=JA16SJIS data=CLRRPF_TEMP.csv enclosed_by=\'\"\'
sqlldr VM1DTA/XqTEJc9p@jpaigdbp02:1521/IGPRD22 table=AUDIT_CLRRPF_TEMP characterset=JA16SJIS data=AUDIT_CLRRPF_TEMP.csv enclosed_by=\'\"\'

echo "******************************************************************************"
echo "*************************SQLLDR Completed*************************"
echo "******************************************************************************"
exit 0