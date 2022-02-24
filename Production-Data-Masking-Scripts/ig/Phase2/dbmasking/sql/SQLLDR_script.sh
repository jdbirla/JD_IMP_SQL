. /opt/ig/dbmasking/conf/db.prop

echo "******************************************************************************"
echo "*************************SQLLDR Started*************************"
echo "******************************************************************************"
cd /opt/ig/hitoku/user/output

sqlldr $IGDBCONSTR table=AUDIT_CLEXPF_TEMP characterset=JA16SJIS data=AUDIT_CLEXPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=AUDIT_CLNT_TEMP characterset=JA16SJIS data=AUDIT_CLNT_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=AUDIT_CLNTPF_TEMP characterset=JA16SJIS data=AUDIT_CLNTPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=CLBAPF_TEMP characterset=JA16SJIS data=CLBAPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=CLEXPF_TEMP characterset=JA16SJIS data=CLEXPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=CLNTPF_TEMP characterset=JA16SJIS data=CLNTPF_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=GMHDPF_TEMP characterset=JA16SJIS data=GMHDPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=GMHIPF_TEMP characterset=JA16SJIS data=GMHIPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=ZALTPF_TEMP characterset=JA16SJIS data=ZALTPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=ZCLNPF_TEMP characterset=JA16SJIS data=ZCLNPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=ZMCIPF_TEMP characterset=JA16SJIS data=ZMCIPF_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=ZERRPF_TEMP characterset=JA16SJIS data=ZERRPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=CLRRPF_TEMP characterset=JA16SJIS data=CLRRPF_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=AUDIT_CLRRPF_TEMP characterset=JA16SJIS data=AUDIT_CLRRPF_TEMP.csv enclosed_by=\'\"\'

#--------------------- Below is DataMigration tables. Not done in Phase 2. PA.Commented on 20211211----------------------------------------
#sqlldr $IGDBCONSTR table=TITDMGMBRINDP1_TEMP characterset=JA16SJIS data=TITDMGMBRINDP1_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGPOLTRNH_FREE_PLANS_TEMP characterset=JA16SJIS data=TITDMGPOLTRNH_FREE_PLANS_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGPOLTRNH_TEMP characterset=JA16SJIS data=TITDMGPOLTRNH_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGREF1_TEMP characterset=JA16SJIS data=TITDMGREF1_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLNTBANK_TEMP characterset=JA16SJIS data=TITDMGCLNTBANK_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLNTBANK_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGCLNTBANK_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGMBRINDP1_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGMBRINDP1_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLNTPRSN_FREEPLAN_TEMP characterset=JA16SJIS data=TITDMGCLNTPRSN_FREEPLAN_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLNTPRSN_TEMP characterset=JA16SJIS data=TITDMGCLNTPRSN_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLTRNHIS_TEMP characterset=JA16SJIS data=TITDMGCLTRNHIS_TEMP.csv enclosed_by=\'\"\'
#sqlldr $IGDBCONSTR table=TITDMGCLTRNHIS_FP_TEMP characterset=JA16SJIS data=TITDMGCLTRNHIS_FREEPLAN_TEMP.csv enclosed_by=\'\"\'

exit 0

#-------------------- Below is staging tables. Not tested in Phase 2.PA. 20211211. This may be needed later so not commented.---------
sqlldr $IGDBCONSTR table=TOTPAMVALCHKD_TEMP characterset=JA16SJIS data=TOTPAMVALCHKD_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=TITPAMVALCHKDR_TEMP characterset=JA16SJIS data=TITPAMVALCHKDR_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=TOTPAMMISPOL_TEMP characterset=JA16SJIS data=TOTPAMMISPOL_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=TITPAMBILLSTOP_TEMP characterset=JA16SJIS data=TITPAMBILLSTOP_TEMP.csv enclosed_by=\'\"\'
sqlldr $IGDBCONSTR table=TOTPAMMISCLN_TEMP characterset=JA16SJIS data=TOTPAMMISCLN_TEMP.csv enclosed_by=\'\"\'

echo "******************************************************************************"
echo "*************************SQLLDR Completed*************************"
echo "******************************************************************************"
exit 0
