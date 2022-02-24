echo "VM1DTA/XqTEJc9p@IGPRD22";

echo "set pagesize 0"
echo "set trimspool on"
echo "set linesize 32700"
echo "set underline off"
echo "set term off"
echo "set feed off"
#echo "Set NLS_LANG=JA16SJIS"

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
echo "exec APM_DBMASKwritetoTITDMGMBRP1('IMP_DATA_DIR','TITDMGMBRINDP1.csv')"
echo "exec APM_DBMASKwritetoTITDMGPOLHPF('IMP_DATA_DIR','TITDMGPOLTRNH_FREE_PLANS.csv')"
echo "exec APM_DBMASKwritetoTITDMGPOL('IMP_DATA_DIR','TITDMGPOLTRNH.csv')"
echo "exec APM_DBMASKwritetoTITDMGREF1('IMP_DATA_DIR','TITDMGREF1.csv')"
echo "exec APM_DBMASKwritetozerrpf('IMP_DATA_DIR','ZERRPF.csv')"
echo "exec APM_DBMASKwritetoTITDMGCLBNK('IMP_DATA_DIR','TITDMGCLNTBANK.csv')"
echo "exec APM_DBMASKwritetoTITDMGCLBNKFP('IMP_DATA_DIR','TITDMGCLNTBANK_FREEPLAN.csv')"
echo "exec APM_DBMASKwritetoTITDMGMBRP1FP('IMP_DATA_DIR','TITDMGMBRINDP1_FREEPLAN.csv')"
echo "exec APM_DBMASKwritetoTITDMGCLPRSN('IMP_DATA_DIR','TITDMGCLNTPRSN.csv')"
echo "exec APM_DBMASKwritetoTITDMGCLPRNFP('IMP_DATA_DIR','TITDMGCLNTPRSN_FREEPLAN.csv')"
echo "exec APM_DBMASK_write_to_TOTPAMSPOL('IMP_DATA_DIR','TOTPAMMISPOL.csv')"
echo "exec APM_DBMASK_write_to_TOTPAMVCKD('IMP_DATA_DIR','TOTPAMVALCHKD.csv')"
echo "exec APM_DBMASK_writeto_TITPAMBLSTP('IMP_DATA_DIR','TITPAMBILLSTOP.csv')"
echo "exec APM_DBMASK_writeto_TITPAMVLCDR('IMP_DATA_DIR','TITPAMVALCHKDR.csv')"
echo "exec APM_DBMASK_write_to_TOTPAMSCLN('IMP_DATA_DIR','TOTPAMMISCLN.csv')"
echo "exec APM_DBMASKwritetoTITDMCLTRNHIS('IMP_DATA_DIR','TITDMGCLTRNHIS.csv')"
echo "exec APM_DBMASKwriteTITDMCLTRHIS_FP('IMP_DATA_DIR','TITDMGCLTRNHIS_FREEPLAN.csv')"
echo "exec APM_DBMASK_writetoCLRRPF('IMP_DATA_DIR','CLRRPF.csv')"
echo "exec APM_DBMASK_writetoAUDIT_CLRRPF('IMP_DATA_DIR','AUDIT_CLRRPF.csv')"





exit 0