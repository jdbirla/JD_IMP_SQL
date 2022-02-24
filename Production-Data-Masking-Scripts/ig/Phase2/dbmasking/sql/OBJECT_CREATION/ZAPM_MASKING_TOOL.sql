create or replace PROCEDURE "ZAPM_MASKING_TOOL"
AS
  /***************************************************************************************************
  *
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CM1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  *****************************************************************************************************/
  v_parallel VARCHAR2(1000) := 'select /*+ paralle(10) */';
  v_str1     VARCHAR2(1000) := '''"''';
  v_str2     VARCHAR2(1000) := '||';
  v_str3     VARCHAR2(1000) := '''","''';
  v_str4     VARCHAR2(1000) := '''"''';
  v_str5     VARCHAR2(1000) := ' from ';
  v_sql      VARCHAR2(4000);
  v_sql1     VARCHAR2(4000);
  v_sql2     VARCHAR2(4000);
  v_sql3     VARCHAR2(4000);
  v_file UTL_FILE.FILE_TYPE;
  v_sql_res  VARCHAR2(4000);
  v_flename  VARCHAR2(4000);
  v_pagesize VARCHAR2(4000) := 'set pagesize 0 trimspool on linesize 32700 underline off term off feed off';
  v_spoloon  VARCHAR2(4000);
BEGIN
  FOR cur_tab IN
  (SELECT table_name
  FROM ALL_TABLES
  WHERE OWNER         = 'VM1DTA'
  AND num_rows        > 0
  AND TABLE_NAME NOT IN (--Truncated tables
  'RAPA_CLIENTINFO', 'IG_TITDMGPOLTRNH', 'CLNTPF_BEFORE_PATCH', 'AUDIT_CLNTPF_BEFORE_PATCH', 'POLDATATEMP', 'MV_ZMCIPF_CRDT_BAK', 'MV_ZMCIPF_BAK', 'AGNT_CLNT3', 'ZCSVAD0001', 'ZCSVAD0002', 'ZVCHPF', 'INT_MISPOL', 'INT_MISPOL_SUMINST', 'INT_MISPOL_AGENCY_COMM', 'INT_MISPOL_COMPAIGN', 'INT_MISPOL_ZMCI', 'INT_MISPOL_ZTRA', 'INT_MISINS', 'INT_MISINS_GMHI', 'INT_MISINS_GXHI', 'INT_MISINS_RIDER', 'INT_MISINS_SUMINST','TITDMGMBRINDP1_TEMP',
'TITDMGMBRINDP1_TEMP',
'TITDMGPOLTRNH_FREE_PLANS_TEMP',
'TITDMGPOLTRNH_TEMP',
'TITDMGREF1_TEMP', 
'ZALTPF_TEMP',
'ZALTPF_TEMP',
'ZMCIPF_TEMP',
'AUDIT_CLNTPF_TEMP',
'GMHIPF_TEMP',
'ZCLNPF_TEMP',
'GMHDPF_TEMP',
'AUDIT_CLEXPF_TEMP',
'CLNTPF_TEMP',
'CLEXPF_TEMP',
'TEMP_13434_PS_2',
'MEMBER_AGENT_TEMP',
'RIDER_ACUM_TEMP',
'RIDER_ACUM_TEMP_ACT',
'CLBAPF_TEMP',
'AUDIT_CLNT_TEMP',
'ITEMPF',
'ASRFTYPE_ACUM_TEMP',
'ZERRPF_TEMP',
'TEMPINRG',
'GBIH_TEMP',
'TEMP1',
'TEMP_13434_PS',
'TEMPBILL',
  --Already masked tables
  'AUDIT_ASRDPF', 'BABRPF', 'CLNTQY', 'MIOKPF', 'NAME', 'POLDATATEMP', 'ZCORPF', 'ZMIEPF', 'ZMUPPF', 'ZPDAPF', 'ZREPPF', 'ZSTGPF', 'ZVCHPF', 'AUDIT_CLNT', 'CLBAPF', 'CLEXPF', 'GMHDPF', 'GMHIPF', 'ZALTPF', 'ZCLNPF', 'ZMCIPF', 'AUDIT_CLEXPF', 'AUDIT_CLNTPF', 'CLNTPF', 'TITDMGMBRINDP1', 'TITDMGPOLTRNH_FREE_PLANS', 'TITDMGPOLTRNH', 'TITDMGREF1', 'ZERRPF', 
  --Not required
  'CHDRPF',
  'GPMDPF',
  'GBIDPF',
  'ZTEMPCOVPF',
  'ZTEMPTIERPF',
  'ZTIERPF',
  'GXHIPF',
  'GAPHPF',
  'ZDOEMB0002',
'ZDOEMB0001',
'ZDOEMB0004',
'ZDOEMB0005',
'ZDOEMB0003',
'ZDOEBL0005',
'ZDOEBL0006',
'ZDOEBL0010',
'ZDOEBL0009',
'ZDOEBL0013',
'ZDOEBL0014',
'ZDOEBL0012',
'ZDOEBL0011',
'ZDOEBL0018',
'ZDOEBL0017',
'ZDOEBL0003',
'ZDOEBL0004',
'ZDOEBL0007',
'ZDOEBL0008',
'ZDOEBL0016',
'ZDOEBL0015',
'ZDOEBL0002',
'ZDOEBL0001',
'ZDOECH0001',
'ZDOECH0002',
'ZDOECH0098',
'ZDOECP0003',
'ZDOECP0002',
'ZDOEBL0020',
'ZDOEBL0019',
'ZDOECR0002',
'ZDOECR0001',
'ZDOECB0001',
'ZDOECB0002',
'ZDOELT0004',
'ZDOELT0003',
'ZDOEPH0002',
'ZDOEPH0006',
'ZDOEPH0013',
'ZDOEPH0009',
'ZDOEPH0005',
'ZDOEPH0003',
'ZDOEPH0093',
'ZDOEPH0092',
'ZDOECH0004',
'ZDOECH0005',
'ZDOECP0005',
'ZDOECP0004',
'ZDOECB0004',
'ZDOECB0003',
'ZDOEPH0010',
'ZDOEPH0014',
'ZDOEIN0003',
'ZDOEIN0004',
'ZDOEIN0005',
'ZDOEPH0091',
'ZDOEPH0004',
'ZDOERF0002',
'ZDOERF0001',
'ZDOEPD0001',
'ZDOEPD0002',
'ZDOELT0001',
'ZDOELT0002',
'ZDRBPF',
'ZDCLPF',
'ZDPTPF',
'ZDCHPF',
'ZDRPPF',
'ZDCRPF',
'ZDLTPF',
'ZDROPF',
'ZDRFPF',
'BR_ZDROPF',
'ZDDVPF',
'ZDWLPF',
'AUDIT_CLRRPF',
'CLRRPF',
'GBIHPF',
'INT_MIS_ACTTRA_GXHI',
'ZTRAPF',
'INT_MIS_ACTTRA',
'MV_ZMCIPF',
'INT_MIS_ACTTRA_COMPAIGN',
'INT_MIS_ACTTRA_AGENCY_COMM',
'INT_MIS_ACTTRA_RIDER',
'VERSIONPF',
'GCHIPF',
'ZCELINKPF',
'GPSUPF',
'MV_ZMCIPF_CRDT',
'ZCRHPF',
'ANUMPF',
'ZPCMPF',
'ZMPCPF',
'LETCPF',
'GMOVPF',
'GIDTPF',
'ZCSVAD0003',
'ZADRPF',
'ZTDCPF',
'HELPPF'


   )) LOOP 
  BEGIN v_sql := NULL;
  v_sql1             := NULL;
  v_sql2             := NULL;
  v_sql3             := NULL;
  DBMS_OUTPUT.put_line('table name :   ' || RTRIM(cur_tab.table_name, ','));
  v_sql1 := v_parallel || v_str1;
  FOR cur_tab_col IN
  (SELECT column_name
  FROM All_Tab_ColS
  WHERE OWNER    = 'VM1DTA'
  AND table_NAME = cur_tab.table_name
  AND COLUMN_NAME NOT LIKE 'SYS_NC%'
  )
  LOOP
    v_sql2 := v_str2 || cur_tab_col.column_name || v_str2 || v_str3 || v_sql2;
  END LOOP;
  v_sql3 := RTRIM(v_sql2, '''","''');
  v_sql  := v_parallel || v_str1 || v_sql3 || v_str4 || v_str5 || ' VM1DTA.' || cur_tab.table_name;
  --   DBMS_OUTPUT.put_line('v_sql :   ' || v_sql);
  v_sql_res := v_sql||';';
  v_flename := cur_tab.table_name || '.sql';
  v_spoloon := 'spool /opt/ig/hitoku/user/input/ALLTABLEDATA/' || v_flename || ';';
  v_file    := UTL_FILE.FOPEN('IMP_DATA_DIR', v_flename, 'w', 32767);
  UTL_FILE.PUT_LINE(v_file, v_pagesize);
  UTL_FILE.PUT_LINE(v_file, v_spoloon);
  UTL_FILE.PUT_LINE(v_file, v_sql_res);
  UTL_FILE.PUT_LINE(v_file, 'spool off;');
  UTL_FILE.FCLOSE(v_file);
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.put_line('table not exported  :   ' || cur_tab.table_name);
END;
END LOOP;
END ZAPM_MASKING_TOOL;