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
