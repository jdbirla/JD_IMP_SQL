create or replace PROCEDURE                               "BQ9UX_BL01_REFUNDBL" ( 
    v_scheduleName   IN VARCHAR2, 
    v_scheduleNumber IN VARCHAR2, 
    v_zprvaldYN      IN VARCHAR2, 
    v_company        IN VARCHAR2, 
    v_userProfile    IN VARCHAR2, 
    v_i_branch       IN VARCHAR2, 
    v_transCode      IN VARCHAR2, 
    v_vrcmtime       IN NUMBER, 
    v_vrcmuser       IN NUMBER, 
    v_acctYear       IN NUMBER, 
    v_acctMonth      IN NUMBER, 
    v_vrcmTermid     IN VARCHAR2) 
AS 
/*************************************************************************************************** 
  * Amenment History: BL01 Refund 
  * Date    Init   Tag   Decription 
  * -----   -----  ---   --------------------------------------------------------------------------- 
  * MMDD    XXX   RF1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
  * 2804    JB    RF2  included checking for inputfile 2 for bill not migrated 
  * 0504    RC    RF3  For the Bill No & ZBKTRFDT Col in GBIHPF 
  * 0508    PS    RF4  For the Bill No & ZBKTRFDT Col in GBIHPF 
  * 0514    PS    RF5  Corrected ZCTAXAMT formula
  * 0529    RC    RF6  Corrected Amount Values in GBIDPF, GPMDPF, ZPCMPF & ZMPCPF
  * 0711    RC    RF7  For incident #9237, swapping the value of refund methood code coming from the staging at the time of writing it to ZRFDPF & ZREPPF. 
  *                    If the refund method code from stage db is 001 only at the time of insert then we will change it to 002 and vice versa.
  * 0723    PS    RF8  Fixed Refund Method Error
  * 0724    SC    RF9  CR AND DATA ACCUMULATION CHANGE FOR TABLES ZPCMPF AND ZMPCPF. 
  *****************************************************************************************************/ 
  v_timestart NUMBER := dbms_utility.get_time; 
  --Values fron Staging Table Start-- 
  -- STAGEDBUSR.TITDMGREF1  Start-- 
  v_recidxrefb1 TITDMGREF1.RECIDXREFB1@DMSTAGEDBLINK%type; 
  v_refnum TITDMGREF1.REFNUM@DMSTAGEDBLINK%type; 
  -- v_refnum obj_gbihpf.INSTNO%type; 
  v_chdrnum1 TITDMGREF1.CHDRNUM@DMSTAGEDBLINK%type; 
  v_zrefmtcd1 TITDMGREF1.ZREFMTCD@DMSTAGEDBLINK%type; 
  v_effdate TITDMGREF1.EFFDATE@DMSTAGEDBLINK%type; 
  v_prbilfdt TITDMGREF1.PRBILFDT@DMSTAGEDBLINK%type; 
  v_prbiltdt TITDMGREF1.PRBILTDT@DMSTAGEDBLINK%type; 
  v_zposbdsm TITDMGREF1.ZPOSBDSM@DMSTAGEDBLINK%type; 
  v_zposbdsy TITDMGREF1.ZPOSBDSY@DMSTAGEDBLINK%type; 
  v_zaltrcde01 TITDMGREF1.ZALTRCDE01@DMSTAGEDBLINK%type; 
  v_zrefundbe TITDMGREF1.ZREFUNDBE@DMSTAGEDBLINK%type; 
  v_zrefundbz TITDMGREF1.ZREFUNDBZ@DMSTAGEDBLINK%type; 
  v_zenrfdst TITDMGREF1.ZENRFDST@DMSTAGEDBLINK%type; 
  v_zzhrfdst TITDMGREF1.ZZHRFDST@DMSTAGEDBLINK%type; 
  v_bankkey TITDMGREF1.BANKKEY@DMSTAGEDBLINK%type; 
  v_bankacount TITDMGREF1.BANKACOUNT@DMSTAGEDBLINK%type; 
  v_bankaccdsc TITDMGREF1.BANKACCDSC@DMSTAGEDBLINK%type; 
  v_bnkactyp TITDMGREF1.BNKACTYP@DMSTAGEDBLINK%type; 
  v_zrqbkrdf TITDMGREF1.ZRQBKRDF@DMSTAGEDBLINK%type; 
  v_reqdate TITDMGREF1.REQDATE@DMSTAGEDBLINK%type; 
  v_zcolflag TITDMGREF1.ZCOLFLAG@DMSTAGEDBLINK%type; 
  v_paydate TITDMGREF1.PAYDATE@DMSTAGEDBLINK%type; 
  v_rdocpfx TITDMGREF1.RDOCPFX@DMSTAGEDBLINK%type; 
  v_rdoccoy TITDMGREF1.RDOCCOY@DMSTAGEDBLINK%type; 
  v_rdocnum TITDMGREF1.RDOCNUM@DMSTAGEDBLINK%type; 
  -- STAGEDBUSR.TITDMGREF1  End-- 
  -- STAGEDBUSR.TITDMGREF2  Start-- 
  v_recidxrefb2 TITDMGREF2.RECIDXREFB2@DMSTAGEDBLINK%type; 
  v_trrefnum TITDMGREF2.TRREFNUM@DMSTAGEDBLINK%type; 
  v_chdrnum2 TITDMGREF2.CHDRNUM@DMSTAGEDBLINK%type; 
  v_zrefmtcd2 TITDMGREF2.ZREFMTCD@DMSTAGEDBLINK%type; 
  v_prodtyp TITDMGREF2.PRODTYP@DMSTAGEDBLINK%type; 
  v_bprem TITDMGREF2.BPREM@DMSTAGEDBLINK%type; 
  v_gagntsel01 TITDMGREF2.GAGNTSEL01@DMSTAGEDBLINK%type; 
  v_gagntsel02 TITDMGREF2.GAGNTSEL02@DMSTAGEDBLINK%type; 
  v_gagntsel03 TITDMGREF2.GAGNTSEL03@DMSTAGEDBLINK%type; 
  v_gagntsel04 TITDMGREF2.GAGNTSEL04@DMSTAGEDBLINK%type; 
  v_gagntsel05 TITDMGREF2.GAGNTSEL05@DMSTAGEDBLINK%type; 
  v_cmrate01 TITDMGREF2.CMRATE01@DMSTAGEDBLINK%type DEFAULT 0; 
  v_cmrate02 TITDMGREF2.CMRATE02@DMSTAGEDBLINK%type DEFAULT 0; 
  v_cmrate03 TITDMGREF2.CMRATE03@DMSTAGEDBLINK%type DEFAULT 0; 
  v_cmrate04 TITDMGREF2.CMRATE04@DMSTAGEDBLINK%type DEFAULT 0; 
  v_cmrate05 TITDMGREF2.CMRATE05@DMSTAGEDBLINK%type DEFAULT 0; 
  v_commn01 TITDMGREF2.COMMN01@DMSTAGEDBLINK%type DEFAULT 0; 
  v_commn02 TITDMGREF2.COMMN02@DMSTAGEDBLINK%type DEFAULT 0; 
  v_commn03 TITDMGREF2.COMMN03@DMSTAGEDBLINK%type DEFAULT 0; 
  v_commn04 TITDMGREF2.COMMN04@DMSTAGEDBLINK%type DEFAULT 0; 
  v_commn05 TITDMGREF2.COMMN05@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zagtgprm01 TITDMGREF2.ZAGTGPRM01@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zagtgprm02 TITDMGREF2.ZAGTGPRM02@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zagtgprm03 TITDMGREF2.ZAGTGPRM03@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zagtgprm04 TITDMGREF2.ZAGTGPRM04@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zagtgprm05 TITDMGREF2.ZAGTGPRM05@DMSTAGEDBLINK%type DEFAULT 0; 
  v_zcollfee01 TITDMGREF2.ZCOLLFEE01@DMSTAGEDBLINK%type DEFAULT 0; 
  temp_val NUMBER DEFAULT 0; 
  -- STAGEDBUSR.TITDMGREF2  End-- 
  --Values fron Staging Table End-- 
  --  default values form TQ9Q9 Start--- 
  v_mbrno       VARCHAR2(20 CHAR); 
  v_dpntno      VARCHAR2(20 CHAR); 
  v_billtyp     VARCHAR2(20 CHAR); 
  v_validflag   VARCHAR2(20 CHAR); 
  v_bilflag     VARCHAR2(20 CHAR); 
  v_nrflg       VARCHAR2(20 CHAR); 
  v_revflag     VARCHAR2(20 CHAR); 
  v_planno      VARCHAR2(20 CHAR); 
  v_headcntind  VARCHAR2(20 CHAR); 
  v_recno       VARCHAR2(20 CHAR); 
  v_srcdata     VARCHAR2(20 CHAR); 
  v_rectype     VARCHAR2(20 CHAR); 
  v_zinstyp     VARCHAR2(20 CHAR); 
  v_batcpfx     VARCHAR2(20 CHAR); 
  v_zrefmtcd_DV VARCHAR2(20 CHAR); 
  v_zctaxrat    VARCHAR2(20 CHAR); 
  v_pnind       VARCHAR2(20 CHAR); 
  v_mmind       VARCHAR2(20 CHAR); 
  v_last_rowcnt NUMBER DEFAULT 0; 
  zreduplicate  NUMBER DEFAULT 0; 
  v_seq         NUMBER DEFAULT 0;
  v_pkValue        number; 
  --  default values form TQ9Q9 End--- 
  ------Define Constant to read Start---- 
  c_prefix CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('RFBL', v_company); --RFBL --RF 
  -- c_prefix CONSTANT VARCHAR2(2) :='RF'; 
  C_BQ9UX CONSTANT VARCHAR2(5) := 'BQ9UX'; 
  C_TQ9G7 CONSTANT VARCHAR2(6) := 'TQ9G7'; 
  C_TQ9NW CONSTANT VARCHAR2(6) := 'TQ9NW'; 
  C_T9797 CONSTANT VARCHAR2(6) := 'T9797'; 
  C_TR338 CONSTANT VARCHAR2(6) := 'TR338'; 
  c_Z113  CONSTANT VARCHAR2(5) := 'RQOJ'; --Missing REFNUM 
  c_Z031  CONSTANT VARCHAR2(5) := 'RQMB'; --Policy is not yet migrated 
  c_Z013  CONSTANT VARCHAR2(5) := 'RQLT'; --Invalid Date 
  c_Z105  CONSTANT VARCHAR2(5) := 'RQOB'; --Must be valid in TQ9G7 
  c_Z106  CONSTANT VARCHAR2(5) := 'RQOC'; --Missing premium from Endorser 
  c_Z107  CONSTANT VARCHAR2(5) := 'RQOD'; -- Missing premium from Jdrich 
  c_Z108  CONSTANT VARCHAR2(5) := 'RQOE'; -- Must be valid in TQ9NW 
  c_Z109  CONSTANT VARCHAR2(5) := 'RQOF'; --Invalid Bank Key 
  c_Z110  CONSTANT VARCHAR2(5) := 'RQOG'; --Invalid Account Key 
  c_Z035  CONSTANT VARCHAR2(5) := 'RQMF'; --Must be valid in TR338 --?worng 
  c_Z028  CONSTANT VARCHAR2(5) := 'RQM8'; --Must be Y or N 
  c_Z111  CONSTANT VARCHAR2(5) := 'RQOH'; --PAYDATE >= TODAY 
  c_Z112  CONSTANT VARCHAR2(5) := 'RQOI'; --Refund Bill already migrated 
  c_Z014  CONSTANT VARCHAR2(5) := 'RQLU'; --Product code not in T9797 
  c_Z023  CONSTANT VARCHAR2(5) := 'RQM3'; --Invalid Agent Number 
  c_Z033  CONSTANT VARCHAR2(5) := 'RQMD'; --Total Comm. rate must not exceed 100% 
  c_Z057  CONSTANT VARCHAR2(5) := 'RQN1'; --Commission rate cannot be blank 
  c_Z074  CONSTANT VARCHAR2(5) := 'RQNI'; --Agent Gross Premium must be provided 
  c_Z004  CONSTANT VARCHAR2(5) := 'RQLK'; --Input file 2 does not exist 
  c_Z132  CONSTANT VARCHAR2(5) := 'RQWJ'; --Agnt not in Agcy Pattern 
  ------Define Constant to read End---- 
  --------------Common Function Start--------- 
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap; 
  itemexist pkg_dm_common_operations.itemschec; 
  o_errortext pkg_dm_common_operations.errordesc; 
  i_zdoe_info1 pkg_dm_common_operations.obj_zdoe; 
  i_zdoe_info2 pkg_dm_common_operations.obj_zdoe; 
  i_zdoe_err_info2 pkg_dm_common_operations.obj_zdoe; 
  i_zdoe_info_temp pkg_dm_common_operations.obj_zdoe; 
  getTranno pkg_common_dmbl.trano; 
  checkchdrnum pkg_common_dmbl.gchdtype; 
  checkduplicate pkg_common_dmbl.zdrfpftype; 
  checkduplicateIntitdmgref2 pkg_common_dmbl.titdmgref2; 
  checkagent pkg_common_dmbl.agntpftype; 
  checkduplicateInzreppf pkg_common_dmbl.zreppftype; 
  getGagntsel pkg_common_dmbl.zagppftype; 

  getZagptnum pkg_common_dmbl.newgchipf; -- Rahul Chouhan Changes 

  --getZagptid pkg_common_dmbl.typezcpnpf; 
  refbilinfo pkg_common_dmbl.refbilltype; 
  -- checkduplicateInzrfdpf pkg_common_dmbl.zrfdpftype; 
  --getBatctrcde pkg_common_dmbl.batctrcde; 
  validatebankacc pkg_common_dmbl.bankacc; --For Performance 
  ---------------Common function end----------- 
  IgSpaceValue       VARCHAR2(1) DEFAULT ' '; 
  v_zeroes           NUMBER(1) DEFAULT 0; 
  isDateValid        VARCHAR2(20 CHAR); 
  b_isNoError1       BOOLEAN := TRUE; 
  b_isNoError2       BOOLEAN := TRUE; 
  n_isValid          NUMBER(1) DEFAULT 0; 
  isDuplicate        NUMBER(1) DEFAULT 0; 
  v_code             NUMBER; 
  v_errm             VARCHAR2(64 CHAR); 
  v_errorCount1      NUMBER(1) DEFAULT 0; 
  v_errorCount2      NUMBER(1) DEFAULT 0; 
  v_zsalplan         VARCHAR2(30 CHAR); 
  v_tableNametemp    VARCHAR2(10); 
  v_tableName        VARCHAR2(10); 
  v_temp_billno      VARCHAR2(20); 
  v_isagentExists    NUMBER(1) DEFAULT 0; 
  C_RECORDSKIPPED    CONSTANT VARCHAR2(17) := 'Record skipped'; 
  C_RECORDSUCCESS    CONSTANT VARCHAR2(20) := 'Record successful'; 
  C_SUCCESS          CONSTANT VARCHAR2(3)  := 'S'; 
  C_ERROR            CONSTANT VARCHAR2(3)  := 'E'; 
  b_globalError      BOOLEAN               := TRUE; 
  b_memberpolicyFlag BOOLEAN               := FALSE; 
  b_convertedindpol  BOOLEAN               := FALSE; 
  b_indpolicyFlag    BOOLEAN               := FALSE; 
  b_zreppfFlag       BOOLEAN               := FALSE; 
  n_cmrate           NUMBER(3); 
  n_check            NUMBER(1) DEFAULT 0; 
  n_new              NUMBER(1) DEFAULT 0; 
  n_gagnstel01       NUMBER(1) DEFAULT 0; 
  n_gagnstel02       NUMBER(1) DEFAULT 0; 
  n_gagnstel03       NUMBER(1) DEFAULT 0; 
  n_gagnstel04       NUMBER(1) DEFAULT 0; 
  n_gagnstel05       NUMBER(1) DEFAULT 0; 
  v_maxdate          CONSTANT VARCHAR2(10) := '99999999'; 
  i_chdrnum          VARCHAR2(10); 
  temp_zreppf        VARCHAR2(100); 
  temp_tranNo        VARCHAR2(100); 
  temp_cmrate        NUMBER(38, 2) DEFAULT 0; 
  tempGagntsel       VARCHAR2(200); 
  tempZagptnum       VARCHAR2(200); 
  temp_effdate       VARCHAR2(10); 
  temp_zagptnum      VARCHAR2(10); 
  temp_zcmpcode      VARCHAR2(10); 
  temp_refKey1       VARCHAR2(100 CHAR); 
  temp_refKey2       VARCHAR2(100 CHAR); 
  V_TEMP_KEY         VARCHAR2(100 CHAR); 
  --tempZcmpcode       VARCHAR2(200); 

---------------RF9: START-------------------------------------
    v_last_rowcnt     NUMBER DEFAULT 0;
    v_prv_refnum      VARCHAR2(8 CHAR);--COMPARISON VARIABLE FOR ZMPCPF(REFNUM)
    v_prv_policy      VARCHAR2(8 CHAR);--COMPARISON VARIABLE FOR ZMPCPF(POLICY NUMBER)
    v_temp_GPST01     NUMBER(17,2) ;
    v_temp_GPST02     NUMBER(17,2) ;
    v_collfee01       NUMBER(17,2) ;
    v_temp_GPST       NUMBER(17,2) ;
    v_temp_COMMN      NUMBER(17,2) ;
    v_temp_COMMN_Rnd  NUMBER(17,2) ;

    v_temp_COMMN_Stg   NUMBER(17,2) ;
    v_temp_ZAGTGPRM01  NUMBER(17,2) ;
    v_temp_ZAGTGPRM02  NUMBER(17,2) ;
    v_prv_refnum_z      VARCHAR2(8 CHAR);--COMPARISON VARIABLE FOR ZPCMPF(REFNUM)
    v_prv_policy_z      VARCHAR2(8 CHAR);--COMPARISON VARIABLE FOR ZPCMPF(POLICY NUMBER)
---------------RF9: END-------------------------------------  



  ------IG table obj start--- 
  obj_gbihpf GBIHPF%rowtype; 
  obj_gbidpf GBIDPF%rowtype; 
  obj_gpmdpf GPMDPF%rowtype; 
  -- obj_zpcmpf ZPCMPF%rowtype; 
  obj_zmpcpf ZMPCPF%rowtype; 
  obj_zrfdpf ZRFDPF%rowtype; 
  obj_zreppf VIEW_ZREPPF%rowtype; 
  obj_zreppf_updated VIEW_ZREPPF%rowtype; 
  obj_zreppf_l VIEW_ZREPPF%rowtype; 
  obj_zpcmpf01 ZPCMPF%rowtype; 
  obj_zpcmpf02 ZPCMPF%rowtype; 
  obj_zpcmpf03 ZPCMPF%rowtype; 
  obj_zpcmpf04 ZPCMPF%rowtype; 
  obj_zpcmpf05 ZPCMPF%rowtype; 
  ------IG table obj End--- 
  --temp variable--- 
  temp_cownnum GCHD.COWNNUM%type; 
  temp_ptdate GCHD.PTDATE%type; 
  temp_trano GCHD.TRANLUSED%type; 
  temp_zrefundam ZREPPF.ZREFUNDAM%type; 
  temp_zrefundam1 ZREPPF.ZREFUNDAM%type; 
  update_zrefundam ZREPPF.ZREFUNDAM%type; 
  temp_zrefmtcd ZREPPF.ZREFMTCD%type; 
  update_zrefmtcd ZREPPF.ZREFMTCD%type; 
  temp_zrefundbe ZREPPF.ZREFUNDBE%type; 
  update_zrefundbe ZREPPF.ZREFUNDBE%type; 
  temp_zrefundbz ZREPPF.ZREFUNDBZ%type; 
  update_zrefundbz ZREPPF.ZREFUNDBZ%type; 
  temp_zenrfdst ZREPPF.ZENRFDST%type; 
  update_zenrfdst ZREPPF.ZENRFDST%type; 
  temp_zzhrfdst ZREPPF.ZZHRFDST%type; 
  update_zzhrfdst ZREPPF.ZZHRFDST%type; 
  temp_zrfdst_zenrfdst ZREPPF.ZRFDST%type; 
  temp_zrfdst_zzhrfdst ZREPPF.ZRFDST%type; 
  update_zrfdst ZREPPF.ZRFDST%type; 
  n_trdt GBIHPF.TRDT%type; 
  gchp_zgporipcls GCHPPF.ZGPORIPCLS%type; 
  gchp_zconvindpol GCHPPF.ZCONVINDPOL%type; 
  v_zagptnum GCHIPF.ZAGPTNUM%type; 
  v_zcmpcode GCHIPF.ZCMPCODE%type; 
  n_splitc01 ZAGPPF.SPLITC01%type DEFAULT 0; 
  n_splitc02 ZAGPPF.SPLITC02%type DEFAULT 0; 
  n_splitc03 ZAGPPF.SPLITC03%type DEFAULT 0; 
  n_splitc04 ZAGPPF.SPLITC04%type DEFAULT 0; 
  n_splitc05 ZAGPPF.SPLITC05%type DEFAULT 0; 
  v_zcolrate ZAGPPF.Zcolrate%type DEFAULT 0; 
  temp_gagntsel01 ZAGPPF.Gagntsel01%type DEFAULT ' '; 
  temp_gagntsel02 ZAGPPF.Gagntsel02%type DEFAULT ' '; 
  temp_gagntsel03 ZAGPPF.Gagntsel03%type DEFAULT ' '; 
  temp_gagntsel04 ZAGPPF.Gagntsel04%type DEFAULT ' '; 
  temp_gagntsel05 ZAGPPF.Gagntsel05%type DEFAULT ' '; 
  n_wsaasplitc01 ZAGPPF.SPLITC01%type; 
  n_wsaasplitc02 ZAGPPF.SPLITC02%type; 
  n_wsaasplitc03 ZAGPPF.SPLITC03%type; 
  n_wsaasplitc04 ZAGPPF.SPLITC04%type; 
  n_wsaasplitc05 ZAGPPF.SPLITC05%type; 
  v_zrefundbe_l ZREPPF.ZREFUNDBE%type; 
  v_zrefundbz_l ZREPPF.Zrefundbz%type; 
  v_zrefundam_l ZREPPF.ZREFUNDAM%type; 
  v_zrefmtcd_l ZREPPF.Zrefmtcd%type; 
  v_zenrfdst_l ZREPPF.Zenrfdst%type; 
  v_zzhrfdst_l ZREPPF.Zenrfdst%type; 
  v_zrfdst_l ZREPPF.zrfdst%type; 
  v_rowcount NUMBER DEFAULT 0; 
  b_zrefundam ZREPPF.Zrefundam%type; 
  b_zrefmtcd ZREPPF.zrefmtcd%type; 
  b_zrefundbe ZREPPF.zrefundbe%type; 
  b_zrefundbz ZREPPF.zrefundbz%type; 
  b_zenrfdst ZREPPF.zenrfdst%type; 
  b_zzhrfdst ZREPPF.zzhrfdst%type; 
  v_zrefundam_r ZREPPF.zrefmtcd%type; ------- RF7
  v_zrefundam_u ZREPPF.zrefmtcd%type; ------- RF7
  --error cont start 
TYPE obj_zdoe 
IS 
  RECORD 
  ( 
    i_tablecnt  NUMBER(1), 
    i_tableName VARCHAR2(10), 
    i_refKey zdoepf.zrefkey%type, 
    i_zfilename zdoepf.zfilenme%type, 
    i_indic zdoepf.indic%type, 
    i_prefix VARCHAR2(2), 
    i_scheduleno zdoepf.jobnum%type, 
    i_error01 zdoepf.eror01%type, 
    i_errormsg01 zdoepf.errmess01%type, 
    i_errorfield01 zdoepf.erorfld01%type, 
    i_fieldvalue01 zdoepf.fldvalu01%type, 
    i_errorprogram01 zdoepf.erorprog01%type); 
  obj_error obj_zdoe; 
type ercode_tab 
IS 
  TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER; 
  t_ercode ercode_tab; 
  t_ercode2 ercode_tab; 
type errorfield_tab 
IS 
  TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER; 
  t_errorfield errorfield_tab; 
  t_errorfield2 errorfield_tab; 
type errormsg_tab 
IS 
  TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER; 
  t_errormsg errormsg_tab; 
  t_errormsg2 errormsg_tab; 
type errorfieldvalue_tab 
IS 
  TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER; 
  t_errorfieldval errorfieldvalue_tab; 
  t_errorfieldval2 errorfieldvalue_tab; 
type errorprogram_tab 
IS 
  TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER; 
  t_errorprogram errorprogram_tab; 
  t_errorprogram2 errorprogram_tab; 
  idx PLS_INTEGER; 
  idx1 VARCHAR2(2000); 
type error_type 
IS 
  TABLE OF obj_zdoe; 
  error_list error_type := error_type(); 
  errindex INTEGER      := 0; 
  --error cont end 
  -- IG Table List STart-- 
type gbidpf_type 
IS 
  TABLE OF GBIDPF%rowtype; 
  gbidpf_list gbidpf_type := gbidpf_type(); 
  gbidpfindex INTEGER     := 0; 
type gpmdpf_type 
IS 
  TABLE OF GPMDPF%rowtype; 
  gpmdpf_list gpmdpf_type := gpmdpf_type(); 
  gpmdpfindex INTEGER     := 0; 
type zmpcpf_type 
IS 
  TABLE OF ZMPCPF%rowtype; 
  zmpcpf_list zmpcpf_type := zmpcpf_type(); 
  zmpcpfindex INTEGER     := 0; 
type zpcmpf_type01 
IS 
  TABLE OF ZPCMPF%rowtype; 
  zpcmpf_list01 zpcmpf_type01 := zpcmpf_type01(); 
  zpcmpfindex01 INTEGER       := 0; 
type zpcmpf_type02 
IS 
  TABLE OF ZPCMPF%rowtype; 
  zpcmpf_list02 zpcmpf_type02 := zpcmpf_type02(); 
  zpcmpfindex02 INTEGER       := 0; 
type zpcmpf_type03 
IS 
  TABLE OF ZPCMPF%rowtype; 
  zpcmpf_list03 zpcmpf_type03 := zpcmpf_type03(); 
  zpcmpfindex03 INTEGER       := 0; 
type zpcmpf_type04 
IS 
  TABLE OF ZPCMPF%rowtype; 
  zpcmpf_list04 zpcmpf_type04 := zpcmpf_type04(); 
  zpcmpfindex04 INTEGER       := 0; 
type zpcmpf_type05 
IS 
  TABLE OF ZPCMPF%rowtype; 
  zpcmpf_list05 zpcmpf_type05 := zpcmpf_type05(); 
  zpcmpfindex05 INTEGER       := 0; 
  --TYPE zreppfarr_type IS TABLE of VIEW_ZREPPF%rowtype; 
  --TYPE zreppfarr_type IS TABLE OF VARCHAR2(15) INDEX BY VARCHAR2(15); 
TYPE zreppfarr_type 
IS 
  TABLE OF VIEW_ZREPPF%rowtype INDEX BY VARCHAR2(50); 
  /*TYPE obj_zreppf1 IS RECORD( 
  i_chdrnum zreppf.CHDRNUM%type, 
  i_tranno  zreppf.tranno %type); 
  TYPE v_array IS TABLE OF obj_zreppf1; 
  zreppfarr_list  v_array;*/ 
  zreppfarr_list1 zreppfarr_type; 
  --zreppfarr_list zreppfarr_type := zreppfarr_type(); 
  zreppfarrindex INTEGER := 0; 
  -- IG Table List END-- 
  --TITDMGREF1 
  CURSOR refundBills_cursor1 
  IS 
    SELECT * 
    FROM TITDMGREF1@DMSTAGEDBLINK 
      --where TRIM(chdrnum) = '44057599'  
    ORDER BY CHDRNUM ASC,              -- RF4 
      to_number(refnum) ASC,           -- RF4 
      ZREFMTCD ASC;                    -- RF4 
 -- ORDER BY CHDRNUM,   
 --   refnum, 
 --   ZREFMTCD; 
  obj_refundBills1 refundBills_cursor1%rowtype; 
---TITDMGREF2 
  --  CURSOR refundBills_cursor2(p1refnum TITDMGREF1.REFNUM@DMSTAGEDBLINK%type, p1chdrnum TITDMGREF1.CHDRNUM@DMSTAGEDBLINK%type) 
  --  IS 
  --    SELECT * 
  --    FROM TITDMGREF2@DMSTAGEDBLINK 
  --    WHERE TRIM(TRREFNUM) = p1refnum 
  --    AND TRIM(CHDRNUM)    = p1chdrnum; 
  --  obj_refundBills2 refundBills_cursor2%rowtype; 
 /* CURSOR refundBills_cursor2 
  IS 
    SELECT * FROM TITDMGREF2@DMSTAGEDBLINK ORDER BY CHDRNUM; 
  --  refnum, 
  -- ZREFMTCD; 
  obj_refundBills2 refundBills_cursor2%rowtype; */ 

  CURSOR refundBills_cursor2 IS SELECT A.*,  B.ZIGVALUE 
      FROM TITDMGREF2@DMSTAGEDBLINK A 
      left outer join Jd1dta.ZDRFPF B on TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM) AND TRIM(A.TRREFNUM)=TRIM(B.ZENTITY) 
       order by A.chdrnum asc, to_number(A.trrefnum) asc;    -- RF4         
--     order by A.chdrnum asc, A.trrefnum asc;               -- RF4 
       obj_refundBills2 refundBills_cursor2%rowtype; 

BEGIN 
  ---------Common Function------------ 
  
    pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9UX,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMRF', itemexist => itemexist); 
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMRF', o_errortext => o_errortext); 
  v_tableNametemp := 'ZDOE' || TRIM(c_prefix) || LPAD(TRIM(v_scheduleNumber), 4, '0'); 
  v_tableName     := TRIM(v_tableNametemp); 
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName); 
  pkg_common_dmbl.getTranNo(i_company_Name => v_company, getTranno => getTranno); 
  pkg_common_dmbl.checkpolicy(i_company => v_company, checkchdrnum => checkchdrnum); 
  pkg_common_dmbl.checkduplicate(checkduplicate => checkduplicate); 
  pkg_common_dmbl.checkduplicateIntitdmgref2(checkduplicateIntitdmgref2 => checkduplicateIntitdmgref2); 
  pkg_common_dmbl.checkagent(checkagent => checkagent); 
  pkg_common_dmbl.checkduplicateInzreppf(checkduplicateInzreppf => checkduplicateInzreppf); 
  pkg_common_dmbl.getGagntsel(getGagntsel => getGagntsel); 

  pkg_common_dmbl.getZagptnum(getZagptnum => getZagptnum);  -- Rahul Chouhan Changes 

  --pkg_common_dmbl.getZagptid(getZagptid => getZagptid); 
  pkg_common_dmbl.getrefundbillinfo(refbilinfo => refbilinfo); 
  --pkg_common_dmbl.getBatctrcde(getBatctrcde => getBatctrcde); 
  pkg_common_dmbl.validatebankacc(validatebankacc => validatebankacc); --For Performance 
  --------------------- TRDT From BSUDPF ------------------------ 
  --SELECT COUNT(*) INTO v_last_rowcnt FROM TITDMGREF1@DMSTAGEDBLINK; 
  SELECT TO_CHAR(to_date(BUSDATE, 'YYYYMMDD'), 'YYMMDD') 
  INTO n_trdt 
  FROM BUSDPF 
  WHERE COMPANY = '1'; 
  SELECT LDOCNO + 1 
  INTO v_temp_billno 
  FROM GDOCPF 
  WHERE DOCTYP = 'PRMNOT' 
  AND CHDRCOY  = v_company; 
  -- Fetch All default values form TQ9Q9 Srart 
  v_mbrno       := o_defaultvalues('MBRNO'); 
  v_dpntno      := o_defaultvalues('DPNTNO'); 
  v_billtyp     := o_defaultvalues('BILLTYP'); 
  v_validflag   := o_defaultvalues('VALIDFLAG'); 
  v_bilflag     := o_defaultvalues('BILFLAG'); 
  v_nrflg       := o_defaultvalues('NRFLG'); --?null 
  v_revflag     := o_defaultvalues('REVFLAG'); 
  v_planno      := o_defaultvalues('PLANNO'); 
  v_headcntind  := o_defaultvalues('HEADCNTIND'); 
  v_recno       := o_defaultvalues('RECNO'); 
  v_srcdata     := o_defaultvalues('SRCDATA'); 
  v_rectype     := o_defaultvalues('RECTYPE'); 
  v_zinstyp     := o_defaultvalues('ZINSTYP'); 
  v_batcpfx     := o_defaultvalues('BATCPFX'); 
  v_zrefmtcd_DV := o_defaultvalues('ZREFMTCD'); 
  v_zctaxrat    := o_defaultvalues('ZCTAXRAT'); --8 
  v_mmind       := o_defaultvalues('MMIND');   ---? --L 
  v_pnind       := o_defaultvalues('PNIND');   ---?--I 
  -- Fetch All default values form TQ9Q9 End 
  OPEN refundBills_cursor1; 
  <<again_start>> 
  LOOP 
    FETCH refundBills_cursor1 INTO obj_refundBills1; 
    EXIT 
  WHEN refundBills_cursor1%notfound; 
    v_recidxrefb1 := obj_refundBills1.RECIDXREFB1; 
    v_refnum      := TRIM(obj_refundBills1.REFNUM); 
    v_chdrnum1    := TRIM(obj_refundBills1.CHDRNUM); 
    v_rowcount    := refundBills_cursor1%rowcount; 
   -- dbms_output.put_line('v_rowcount outside ' || v_rowcount); 
    v_zrefmtcd1               := obj_refundBills1.ZREFMTCD; 
    v_effdate                 := obj_refundBills1.EFFDATE; 
    v_prbilfdt                := obj_refundBills1.PRBILFDT; 
    v_prbiltdt                := obj_refundBills1.PRBILTDT; 
    v_zposbdsm                := obj_refundBills1.ZPOSBDSM; 
    v_zposbdsy                := obj_refundBills1.ZPOSBDSY; 
    v_zaltrcde01              := obj_refundBills1.ZALTRCDE01; 
    v_zrefundbe               := obj_refundBills1.ZREFUNDBE; 
    v_zrefundbz               := obj_refundBills1.ZREFUNDBZ; 
    v_zenrfdst                := obj_refundBills1.ZENRFDST; 
    v_zzhrfdst                := obj_refundBills1.ZZHRFDST; 
    v_bankkey                 := obj_refundBills1.BANKKEY; 
    v_bankacount              := obj_refundBills1.BANKACOUNT; 
    v_bankaccdsc              := obj_refundBills1.BANKACCDSC; 
    v_bnkactyp                := obj_refundBills1.BNKACTYP; 
    v_zrqbkrdf                := obj_refundBills1.ZRQBKRDF; 
    v_reqdate                 := obj_refundBills1.REQDATE; 
    v_zcolflag                := TRIM(obj_refundBills1.ZCOLFLAG); 
    v_paydate                 := obj_refundBills1.PAYDATE; 
    v_rdocpfx                 := obj_refundBills1.RDOCPFX; 
    v_rdoccoy                 := obj_refundBills1.RDOCCOY; 
    v_rdocnum                 := obj_refundBills1.RDOCNUM; 
    b_isNoError1              := TRUE; 
    b_isNoError2              := TRUE; 
    v_errorCount1             := 0; 
    isDuplicate               := 0; 
    b_memberpolicyFlag        := FALSE; 
    b_convertedindpol         := FALSE; 
    b_indpolicyFlag           := FALSE; 
    b_zreppfFlag              := FALSE; 
    t_ercode(1)               := NULL; 
    t_ercode(2)               := NULL; 
    t_ercode(3)               := NULL; 
    t_ercode(4)               := NULL; 
    t_ercode(5)               := NULL; 
    temp_refKey1              := ' '; 
    temp_refKey1              := (v_chdrnum1 || '_' || v_refnum || '_' || v_zrefmtcd1); 
    i_zdoe_info1              := i_zdoe_info_temp; 
    i_zdoe_info1.i_zfilename  := 'TITDMGREF1'; 
    i_zdoe_info1.i_prefix     := c_prefix; 
    i_zdoe_info1.i_scheduleno := v_scheduleNumber; 
    i_zdoe_info1.i_tableName  := v_tableName; 
    i_zdoe_info1.i_refKey     := TRIM(temp_refKey1); 
    --v_temp_billno             := v_temp_billno + 1; 
    errindex             := 0; 
    n_gagnstel01         := 0; 
    n_gagnstel02         := 0; 
    n_gagnstel03         := 0; 
    n_gagnstel04         := 0; 
    n_gagnstel05         := 0; 
    n_check              := 0; 
    temp_zrefundam       := 0; 
    temp_zrefundam1      := 0; 
    update_zrefundam     := 0; 
    temp_zrefmtcd        := ''; 
    update_zrefmtcd      := ''; 
    temp_zrefundbe       := 0; 
    update_zrefundbe     := 0; 
    temp_zrefundbz       := 0; 
    update_zrefundbz     := 0; 
    temp_zenrfdst        := ''; 
    update_zenrfdst      := ''; 
    temp_zzhrfdst        := ''; 
    update_zzhrfdst      := ''; 
    temp_zrfdst_zenrfdst := ''; 
    temp_zrfdst_zzhrfdst := ''; 
    update_zrfdst        := ''; 
    gbidpfindex          := 0; 
    gpmdpfindex          := 0; 
    zpcmpfindex01        := 0; 
    zpcmpfindex02        := 0; 
    zpcmpfindex03        := 0; 
    zpcmpfindex04        := 0; 
    zpcmpfindex05        := 0; 
    zmpcpfindex          := 0; 
    gbidpf_list          := gbidpf_type(); 
    gpmdpf_list          := gpmdpf_type(); 
    zmpcpf_list          := zmpcpf_type(); 
    zpcmpf_list01        := zpcmpf_type01(); 
    zpcmpf_list02        := zpcmpf_type02(); 
    zpcmpf_list03        := zpcmpf_type03(); 
    zpcmpf_list04        := zpcmpf_type04(); 
    zpcmpf_list05        := zpcmpf_type05(); 
    n_new                := 0; 
    b_zrefundam          := 0; 
    b_zrefmtcd           := NULL; 
    b_zrefundbe          := 0; 
    b_zrefundbz          := 0; 
    b_zenrfdst           := NULL; 
    b_zzhrfdst           := NULL; 
    --   SELECT COUNT(*) INTO isDuplicate FROM ZREPPF WHERE CHDRNUM=v_chdrnum1; 
    --  IF isDuplicate > 0 THEN 
    --    IF (checkduplicateInzreppf.exists(TRIM(v_chdrnum1))) THEN 
    --      temp_zreppf := checkduplicateInzreppf(TRIM(v_chdrnum1)); 
    --      SELECT TO_NUMBER(regexp_substr(temp_zreppf, '[^$]+', 1, 1)), 
    --             regexp_substr(temp_zreppf, '[^$]+', 1, 2), 
    --             TO_NUMBER(regexp_substr(temp_zreppf, '[^$]+', 1, 3)), 
    --             TO_NUMBER(regexp_substr(temp_zreppf, '[^$]+', 1, 4)), 
    --             regexp_substr(temp_zreppf, '[^$]+', 1, 5), 
    --             regexp_substr(temp_zreppf, '[^$]+', 1, 6) 
    --        INTO temp_zrefundam, 
    --             temp_zrefmtcd, 
    --             temp_zrefundbe, 
    --             temp_zrefundbz, 
    --             temp_zenrfdst, 
    --             temp_zzhrfdst 
    --        FROM dual; 
    -- 
    --SELECT CHDRNUM, 
    --    ZREFUNDAM, 
    --    ZREFMTCD, 
    --    ZREFUNDBE, 
    --    ZREFUNDBZ, 
    --    ZENRFDST, 
    --    ZZHRFDST, 
    --    ZRFDST 
    --  FROM ZREPPF; 
    SELECT COUNT(CHDRNUM) 
    INTO n_new 
    FROM ZREPPF 
    WHERE CHDRNUM = v_chdrnum1; 
    IF n_new      > 0 THEN 
      /* select zrefundam, zrefmtcd, zrefundbe, zrefundbz, zenrfdst, zzhrfdst 
      into temp_zrefundam, 
      temp_zrefmtcd, 
      temp_zrefundbe, 
      temp_zrefundbz, 
      temp_zenrfdst, 
      temp_zzhrfdst 
      from zreppf 
      where chdrnum = v_chdrnum1;*/ 
      SELECT zrefundam, 
        zrefmtcd, 
        zrefundbe, 
        zrefundbz, 
        zenrfdst, 
        zzhrfdst 
      INTO b_zrefundam, 
        b_zrefmtcd, 
        b_zrefundbe, 
        b_zrefundbz, 
        b_zenrfdst, 
        b_zzhrfdst 
      FROM zreppf 
      WHERE chdrnum = v_chdrnum1; 
      b_zreppfFlag := true; 
    END IF; 
    select seqtmp.nextval into v_seq from dual;
    IF NOT (checkduplicateIntitdmgref2.exists(TRIM(v_chdrnum1) || TRIM(v_zrefmtcd1) || TRIM(v_refnum))) THEN 
      b_isNoError1                  := FALSE; 
      b_globalError                 := FALSE; 
      i_zdoe_info1.i_indic          := 'E'; 
      i_zdoe_info1.i_error01        := C_Z004; 
      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z004); 
      i_zdoe_info1.i_errorfield01   := 'chdrnum1'; 
      i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      --pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1); 
      --CONTINUE again_start2; 
      GOTO insertzdoe; 
    END IF; 
    /*--   temp_zrefundam := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),1,17); 
    --    temp_zrefmtcd  := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),17,20); 
    --  temp_zrefundbe := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),20,37); 
    -- temp_zrefundbz := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),37,54); 
    temp_zenrfdst  := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),54,56); 
    temp_zzhrfdst  := REGEXP_SUBSTR(checkduplicateInzreppf(TRIM(v_chdrnum1)),56,58);*/ 
    IF (getTranno.exists(TRIM(v_company) || TRIM(v_chdrnum1))) THEN 
      temp_tranNo := getTranno(TRIM(v_company) || TRIM(v_chdrnum1)); 
      SELECT regexp_substr(temp_tranNo, '[^$]+', 1, 1), 
        regexp_substr(temp_tranNo, '[^$]+', 1, 2), 
        regexp_substr(temp_tranNo, '[^$]+', 1, 3) 
      INTO temp_cownnum, 
        temp_ptdate, 
        temp_trano 
      FROM dual; 
    END IF; 
    --validation Start For TITDMGREF1 ---------- 
    -- IF v_zprvaldYN         ='Y' THEN 
    IF TRIM(v_refnum)               IS NULL THEN 
      b_isNoError1                  := FALSE; 
      i_zdoe_info1.i_indic          := 'E'; 
      i_zdoe_info1.i_error01        := C_Z113; 
      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z113); 
      i_zdoe_info1.i_errorfield01   := 'refnum'; 
      i_zdoe_info1.i_fieldvalue01   := TRIM(v_refnum); 
      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      GOTO insertzdoe; 
    END IF; 
    /*  SELECT COUNT(*) 
    INTO isDuplicate 
    FROM Jd1dta.GCHD 
    WHERE CHDRNUM                   = v_chdrnum1; 
    IF isDuplicate                  < 0 THEN*/ 
    --    SELECT COUNT(*) 
    --      INTO isDuplicate 
    --      FROM Jd1dta.ZDRFPF 
    --     WHERE CHDRNUM = v_chdrnum1 
    --       AND ZREFMTCD = v_zrefmtcd1 
    --       AND ZENTITY = v_refnum; 
    --    IF isDuplicate > 0 THEN 
    IF (checkduplicate.exists(TRIM(v_chdrnum1) ||TRIM(v_zrefmtcd1) ||TRIM(v_refnum) )) THEN 
      b_isNoError1                  := FALSE; 
      i_zdoe_info1.i_indic          := 'E'; 
      i_zdoe_info1.i_error01        := C_Z112; 
      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z112); 
      i_zdoe_info1.i_errorfield01   := 'chdrnum1'; 
      i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      GOTO insertzdoe; 
    END IF; 
    IF NOT (checkchdrnum.exists(TRIM(v_chdrnum1))) THEN 
      b_isNoError1 := FALSE; 
      --      i_zdoe_info1.i_indic          := 'E'; 
      --      i_zdoe_info1.i_error01        := C_Z031; 
      --      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z031); 
      --      i_zdoe_info1.i_errorfield01   := 'chdrnum1'; 
      --      i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
      --      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      --      GOTO insertzdoe; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z031; 
      t_errorfield(v_errorCount1)    := 'chdrnum1'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z031); 
      t_errorfieldval(v_errorCount1) := TRIM(v_chdrnum1); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    ---SIT Bug fix 
    -- As discussed with Patrice Already Validating BANKKEY in Client Bank 
    --    IF TRIM(v_bankkey) IS NOT NULL THEN 
    --      SELECT COUNT(*) 
    --        INTO isDuplicate 
    --        FROM BABRPF 
    --       WHERE TRIM(BANKKEY) = TRIM(v_bankkey); 
    --      IF isDuplicate = 0 THEN 
    --        b_isNoError1 := FALSE; 
    --        --        i_zdoe_info1.i_indic          := 'E'; 
    --        --        i_zdoe_info1.i_error01        := C_Z109; 
    --        --        i_zdoe_info1.i_errormsg01     := o_errortext(C_Z109); 
    --        --        i_zdoe_info1.i_errorfield01   := 'bankkey'; 
    --        --        i_zdoe_info1.i_fieldvalue01   := TRIM(v_bankkey); 
    --        --        i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
    --        --        GOTO insertzdoe; 
    --        v_errorCount1 := v_errorCount1 + 1; 
    --        t_ercode(v_errorCount1) := C_Z109; 
    --        t_errorfield(v_errorCount1) := 'bankkey'; 
    --        t_errormsg(v_errorCount1) := o_errortext(C_Z109); 
    --        t_errorfieldval(v_errorCount1) := TRIM(v_bankkey); 
    --        t_errorprogram(v_errorCount1) := v_scheduleName; 
    --        IF v_errorCount1 >= 5 THEN 
    --          GOTO gototable2; 
    --        END IF; 
    --      END IF; 
    --      /*   ELSE 
    --      b_isNoError1 := FALSE; 
    --      --      i_zdoe_info1.i_indic          := 'E'; 
    --      --      i_zdoe_info1.i_error01        := C_Z109; 
    --      --      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z109); 
    --      --      i_zdoe_info1.i_errorfield01   := 'bankkey'; 
    --      --      i_zdoe_info1.i_fieldvalue01   := TRIM(v_bankkey); 
    --      --      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
    --      --      GOTO insertzdoe; 
    --      v_errorCount1 := v_errorCount1 + 1; 
    --      t_ercode(v_errorCount1) := C_Z109; 
    --      t_errorfield(v_errorCount1) := 'bankkey'; 
    --      t_errormsg(v_errorCount1) := o_errortext(C_Z109); 
    --      t_errorfieldval(v_errorCount1) := TRIM(v_bankkey); 
    --      t_errorprogram(v_errorCount1) := v_scheduleName; 
    --      IF v_errorCount1 >= 5 THEN 
    --        GOTO gototable2; 
    --      END IF;*/ 
    --    END IF; 
    ---SIT Bug fix 
    IF TRIM(v_bankacount) IS NOT NULL THEN 
      --      SELECT COUNT(*) 
      --        INTO isDuplicate 
      --        FROM CLBAPF 
      --       WHERE TRIM(BANKACCKEY) = TRIM(v_bankacount) 
      --         AND ROWNUM = 1; 
      --      IF isDuplicate = 0 THEN 
      IF NOT (validatebankacc.exists(TRIM(v_bankacount))) THEN 
        b_isNoError1 := FALSE; 
        --        i_zdoe_info1.i_indic          := 'E'; 
        --        i_zdoe_info1.i_error01        := C_Z110; 
        --        i_zdoe_info1.i_errormsg01     := o_errortext(C_Z110); 
        --        i_zdoe_info1.i_errorfield01   := 'bankacount'; 
        --        i_zdoe_info1.i_fieldvalue01   := TRIM(v_bankacount); 
        --        i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
        --        GOTO insertzdoe; 
        v_errorCount1                  := v_errorCount1 + 1; 
        t_ercode(v_errorCount1)        := C_Z110; 
        t_errorfield(v_errorCount1)    := 'bankacount'; 
        t_errormsg(v_errorCount1)      := o_errortext(C_Z110); 
        t_errorfieldval(v_errorCount1) := TRIM(v_bankacount); 
        t_errorprogram(v_errorCount1)  := v_scheduleName; 
        IF v_errorCount1               >= 5 THEN 
          GOTO insertzdoe; 
        END IF; 
      END IF; 
      /* ELSE 
      b_isNoError1 := FALSE; 
      --      i_zdoe_info1.i_indic          := 'E'; 
      --      i_zdoe_info1.i_error01        := C_Z110; 
      --      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z110); 
      --      i_zdoe_info1.i_errorfield01   := 'bankacount'; 
      --      i_zdoe_info1.i_fieldvalue01   := TRIM(v_bankacount); 
      --      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      --      GOTO insertzdoe; 
      v_errorCount1 := v_errorCount1 + 1; 
      t_ercode(v_errorCount1) := C_Z110; 
      t_errorfield(v_errorCount1) := 'bankacount'; 
      t_errormsg(v_errorCount1) := o_errortext(C_Z110); 
      t_errorfieldval(v_errorCount1) := TRIM(v_bankacount); 
      t_errorprogram(v_errorCount1) := v_scheduleName; 
      IF v_errorCount1 >= 5 THEN 
      GOTO gototable2; 
      END IF;*/ 
    END IF; 
    /* IF TRIM(v_zpbacno) IS NOT NULL THEN  --v_zpbacno not in TITDMGREF1 table 
    SELECT COUNT(*) INTO isDuplicate FROM CLBAPF WHERE ZPBACNO = v_zpbacno; 
    IF isDuplicate                    = 0 THEN 
    b_isNoError1                  := FALSE; 
    i_zdoe_info1.i_indic          := 'E'; 
    i_zdoe_info1.i_error01        := C_Z110; 
    i_zdoe_info1.i_errormsg01     := o_errortext(C_Z110); 
    i_zdoe_info1.i_errorfield01   := 'zpbacno'; 
    i_zdoe_info1.i_fieldvalue01   := TRIM(v_zpbacno); 
    i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
    GOTO insertzdoe; 
    END IF; 
    ELSE b_isNoError1              := FALSE; 
    i_zdoe_info1.i_indic          := 'E'; 
    i_zdoe_info1.i_error01        := C_Z110; 
    i_zdoe_info1.i_errormsg01     := o_errortext(C_Z110); 
    i_zdoe_info1.i_errorfield01   := 'zpbacno'; 
    i_zdoe_info1.i_fieldvalue01   := TRIM(v_zpbacno); 
    i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
    GOTO insertzdoe; 
    END IF;*/ 
    --SIT Bug fix 
    IF TRIM(v_bnkactyp) IS NOT NULL THEN 
      IF NOT (itemexist.exists(TRIM(C_TR338) || TRIM(v_bnkactyp) || 9)) THEN 
        --? table name 
        b_isNoError1 := FALSE; 
        --        i_zdoe_info1.i_indic          := 'E'; 
        --        i_zdoe_info1.i_error01        := C_Z035; 
        --        i_zdoe_info1.i_errormsg01     := o_errortext(C_Z035); 
        --        i_zdoe_info1.i_errorfield01   := 'bnkactyp'; 
        --        i_zdoe_info1.i_fieldvalue01   := TRIM(v_bnkactyp); 
        --        i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
        --        GOTO insertzdoe; 
        v_errorCount1                  := v_errorCount1 + 1; 
        t_ercode(v_errorCount1)        := C_Z035; 
        t_errorfield(v_errorCount1)    := 'bnkactyp'; 
        t_errormsg(v_errorCount1)      := o_errortext(C_Z035); 
        t_errorfieldval(v_errorCount1) := TRIM(v_bnkactyp); 
        t_errorprogram(v_errorCount1)  := v_scheduleName; 
        IF v_errorCount1               >= 5 THEN 
          GOTO insertzdoe; 
        END IF; 
      END IF; 
      /*  ELSE 
      b_isNoError1 := FALSE; 
      --      i_zdoe_info1.i_indic          := 'E'; 
      --      i_zdoe_info1.i_error01        := C_Z035; 
      --      i_zdoe_info1.i_errormsg01     := o_errortext(C_Z035); 
      --      i_zdoe_info1.i_errorfield01   := 'bnkactyp'; 
      --      i_zdoe_info1.i_fieldvalue01   := TRIM(v_bnkactyp); 
      --      i_zdoe_info1.i_errorprogram01 := v_scheduleName; 
      --      GOTO insertzdoe; 
      v_errorCount1 := v_errorCount1 + 1; 
      t_ercode(v_errorCount1) := C_Z035; 
      t_errorfield(v_errorCount1) := 'bnkactyp'; 
      t_errormsg(v_errorCount1) := o_errortext(C_Z035); 
      t_errorfieldval(v_errorCount1) := TRIM(v_bnkactyp); 
      t_errorprogram(v_errorCount1) := v_scheduleName; 
      IF v_errorCount1 >= 5 THEN 
      GOTO gototable2; 
      END IF;*/ 
    END IF; 
    isDateValid                      := VALIDATE_DATE(v_prbilfdt); 
    IF isDateValid                   <> 'OK' THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z013; 
      t_errorfield(v_errorCount1)    := 'prbilfdt'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
      t_errorfieldval(v_errorCount1) := TRIM(v_prbilfdt); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    isDateValid                      := VALIDATE_DATE(v_prbiltdt); 
    IF isDateValid                   <> 'OK' THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z013; 
      t_errorfield(v_errorCount1)    := 'prbiltdt'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
      t_errorfieldval(v_errorCount1) := TRIM(v_prbiltdt); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    IF NOT (itemexist.exists(TRIM(C_TQ9G7) || TRIM(v_zrefmtcd1) || v_company)) THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z105; 
      t_errorfield(v_errorCount1)    := 'zrefmtcd1'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z105); 
      t_errorfieldval(v_errorCount1) := TRIM(v_zrefmtcd1); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    IF v_zrefmtcd1                    = '001' AND TRIM(v_zrefundbe) IS NULL THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z106; 
      t_errorfield(v_errorCount1)    := 'zrefundbe'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z106); 
      t_errorfieldval(v_errorCount1) := TRIM(v_zrefundbe); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    IF v_zrefmtcd1                    = '002' AND TRIM(v_zrefundbz) IS NULL THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z107; 
      t_errorfield(v_errorCount1)    := 'zrefundbz'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z107); 
      t_errorfieldval(v_errorCount1) := TRIM(v_zrefundbz); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    ---SIT FIX 
    IF (TRIM(v_zrefmtcd1) = '001') THEN 
      IF NOT (itemexist.exists(TRIM(C_TQ9NW) || TRIM(v_zenrfdst) || v_company)) THEN 
        --? table name 
        b_isNoError1                   := FALSE; 
        v_errorCount1                  := v_errorCount1 + 1; 
        t_ercode(v_errorCount1)        := C_Z108; 
        t_errorfield(v_errorCount1)    := 'zenrfdst'; 
        t_errormsg(v_errorCount1)      := o_errortext(C_Z108); 
        t_errorfieldval(v_errorCount1) := TRIM(v_zenrfdst); 
        t_errorprogram(v_errorCount1)  := v_scheduleName; 
        IF v_errorCount1               >= 5 THEN 
          GOTO insertzdoe; 
        END IF; 
      END IF; 
    END IF; 
    IF (TRIM(v_zrefmtcd1) = '002') THEN 
      IF NOT (itemexist.exists(TRIM(C_TQ9NW) || TRIM(v_zzhrfdst) || v_company)) THEN 
        --? table name 
        b_isNoError1                   := FALSE; 
        v_errorCount1                  := v_errorCount1 + 1; 
        t_ercode(v_errorCount1)        := C_Z108; 
        t_errorfield(v_errorCount1)    := 'zzhrfdst'; 
        t_errormsg(v_errorCount1)      := o_errortext(C_Z108); 
        t_errorfieldval(v_errorCount1) := TRIM(v_zzhrfdst); 
        t_errorprogram(v_errorCount1)  := v_scheduleName; 
        IF v_errorCount1               >= 5 THEN 
          GOTO insertzdoe; 
        END IF; 
      END IF; 
    END IF; 
    /*  IF TRIM(v_zpbctype) IS NOT NULL THEN --v_zpbctype not in TITDMGREF1 table 
    IF NOT (itemexist.exists(TRIM(C_TR338) || TRIM(v_zpbctype)||9)) THEN --? table name and zpbctype both 
    b_isNoError1                   := FALSE; 
    v_errorCount1                  := v_errorCount1 + 1; 
    t_ercode(v_errorCount1)        := C_Z035; 
    t_errorfield(v_errorCount1)    := 'zpbctype'; 
    t_errormsg(v_errorCount1)      := o_errortext(C_Z035); 
    t_errorfieldval(v_errorCount1) := TRIM(v_zpbctype); 
    t_errorprogram (v_errorCount1) := v_scheduleName; 
    IF v_errorCount1               >= 5 THEN 
    GOTO gototable2; 
    END IF; 
    END IF; 
    END IF;*/ 
    IF TRIM(v_zrqbkrdf)              <> 'Y' AND TRIM(v_zrqbkrdf) <> 'N' THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z028; 
      t_errorfield(v_errorCount1)    := 'zrqbkrdf'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z028); 
      t_errorfieldval(v_errorCount1) := TRIM(v_zrqbkrdf); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    IF TRIM(v_zcolflag)              <> 'Y' AND TRIM(v_zcolflag) <> 'N' THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z028; 
      t_errorfield(v_errorCount1)    := 'zcolflag'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z028); 
      t_errorfieldval(v_errorCount1) := TRIM(v_zcolflag); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    --SIT BUG Fix 
    isDateValid                      := VALIDATE_DATE(v_paydate); 
    IF isDateValid                   <> 'OK' THEN 
      b_isNoError1                   := FALSE; 
      v_errorCount1                  := v_errorCount1 + 1; 
      t_ercode(v_errorCount1)        := C_Z013; 
      t_errorfield(v_errorCount1)    := 'v_paydate'; 
      t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
      t_errorfieldval(v_errorCount1) := TRIM(v_paydate); 
      t_errorprogram(v_errorCount1)  := v_scheduleName; 
      IF v_errorCount1               >= 5 THEN 
        GOTO insertzdoe; 
      END IF; 
    ELSE 
      IF (TRIM(v_paydate)                <> 0) AND (TRIM(v_paydate) <> NULL) AND (TRIM(v_paydate) <> 99999999) THEN 
        IF TRIM(v_paydate)               >= TO_CHAR(sysdate, 'YYYYMMDD') THEN 
          b_isNoError1                   := FALSE; 
          v_errorCount1                  := v_errorCount1 + 1; 
          t_ercode(v_errorCount1)        := C_Z111; 
          t_errorfield(v_errorCount1)    := 'v_paydate'; 
          t_errormsg(v_errorCount1)      := o_errortext(C_Z111); 
          t_errorfieldval(v_errorCount1) := TRIM(v_paydate); 
          t_errorprogram(v_errorCount1)  := v_scheduleName; 
          IF v_errorCount1               >= 5 THEN 
            GOTO insertzdoe; 
          END IF; 
        END IF; 
      END IF; 
    END IF; 
    --validation END For TITDMGREF1 ---------- 
    --validation Start For TITDMGREF2 ---------- 
    ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGBILL1--- 
    <<insertzdoe>> 
    IF (b_isNoError1                   = FALSE) THEN 
      IF TRIM(t_ercode(1))            IS NOT NULL THEN 
        i_zdoe_info1.i_indic          := 'E'; 
        i_zdoe_info1.i_error01        := t_ercode(1); 
        i_zdoe_info1.i_errormsg01     := t_errormsg(1); 
        i_zdoe_info1.i_errorfield01   := t_errorfield(1); 
        i_zdoe_info1.i_fieldvalue01   := t_errorfieldval(1); 
        i_zdoe_info1.i_errorprogram01 := t_errorprogram(1); 
      END IF; 
      IF TRIM(t_ercode(2))            IS NOT NULL THEN 
        i_zdoe_info1.i_indic          := 'E'; 
        i_zdoe_info1.i_error02        := t_ercode(2); 
        i_zdoe_info1.i_errormsg02     := t_errormsg(2); 
        i_zdoe_info1.i_errorfield02   := t_errorfield(2); 
        i_zdoe_info1.i_fieldvalue02   := t_errorfieldval(2); 
        i_zdoe_info1.i_errorprogram02 := t_errorprogram(2); 
      END IF; 
      IF TRIM(t_ercode(3))            IS NOT NULL THEN 
        i_zdoe_info1.i_indic          := 'E'; 
        i_zdoe_info1.i_error03        := t_ercode(3); 
        i_zdoe_info1.i_errormsg03     := t_errormsg(3); 
        i_zdoe_info1.i_errorfield03   := t_errorfield(3); 
        i_zdoe_info1.i_fieldvalue03   := t_errorfieldval(3); 
        i_zdoe_info1.i_errorprogram03 := t_errorprogram(3); 
      END IF; 
      IF TRIM(t_ercode(4))            IS NOT NULL THEN 
        i_zdoe_info1.i_indic          := 'E'; 
        i_zdoe_info1.i_error04        := t_ercode(4); 
        i_zdoe_info1.i_errormsg04     := t_errormsg(4); 
        i_zdoe_info1.i_errorfield04   := t_errorfield(4); 
        i_zdoe_info1.i_fieldvalue04   := t_errorfieldval(4); 
        i_zdoe_info1.i_errorprogram04 := t_errorprogram(4); 
      END IF; 
      IF TRIM(t_ercode(5))            IS NOT NULL THEN 
        i_zdoe_info1.i_indic          := 'E'; 
        i_zdoe_info1.i_error05        := t_ercode(5); 
        i_zdoe_info1.i_errormsg05     := t_errormsg(5); 
        i_zdoe_info1.i_errorfield05   := t_errorfield(5); 
        i_zdoe_info1.i_fieldvalue05   := t_errorfieldval(5); 
        i_zdoe_info1.i_errorprogram05 := t_errorprogram(5); 
      END IF; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1); 
      CONTINUE again_start; 
    END IF; 
    IF b_isNoError1         = TRUE THEN 
      i_zdoe_info1.i_indic := 'S'; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1); 
    END IF; 
    v_errorCount1 :=0; 
    IF b_isNoError1 = TRUE AND TRIM(v_zprvaldYN) = 'N' THEN 
      --------------------- ZDRFPF Insertion Start--------------------------- 
      INSERT 
      INTO ZDRFPF 
        ( 
          RECSTATUS, 
          ZENTITY, 
          CHDRNUM, 
          ZREFMTCD, 
          ZIGVALUE, 
          JOBNUM, 
          JOBNAME,
          ZPDATATXFLG --RF9
        ) 
        VALUES 
        ( 
          'OK', 
          v_refnum, 
          v_chdrnum1, 
          v_zrefmtcd1, 
          v_temp_billno, 
          v_scheduleNumber, 
          v_scheduleName,
          obj_refundBills1.ZPDATATXFLG --RF9
        ); 
      --------------------- ZDRFPF Insertion END ---------------------------- 
      --------------------- GBIHPF Insertion START -------------------------- 
      obj_gbihpf.BILLNO    := v_temp_billno; 
      obj_gbihpf.CHDRCOY   := v_company; 
      obj_gbihpf.CHDRNUM   := v_chdrnum1; 
      obj_gbihpf.SUBSCOY   := IgSpaceValue; 
      obj_gbihpf.SUBSNUM   := IgSpaceValue; 
      obj_gbihpf.MBRNO     := v_mbrno; 
      obj_gbihpf.BILLTYP   := v_billtyp; 
      obj_gbihpf.PRBILFDT  := v_prbilfdt; 
      obj_gbihpf.PRBILTDT  := v_prbiltdt; 
      obj_gbihpf.INSTNO    := TO_NUMBER(v_refnum); -- need  to talk 
      obj_gbihpf.PBILLNO   := v_zeroes; 
      obj_gbihpf.TERMID    := v_vrcmTermid; 
      obj_gbihpf.TRDT      := n_trdt; 
      obj_gbihpf.TRTM      := v_vrcmtime; 
      obj_gbihpf.TRANNO    := temp_trano; 
      obj_gbihpf.GRPGST    := v_zeroes; 
      obj_gbihpf.GRPSDUTY  := v_zeroes; 
      obj_gbihpf.VALIDFLAG := v_validflag; 
      obj_gbihpf.BILFLAG   := v_bilflag; 
      obj_gbihpf.NRFLG     := v_nrflg; 
      obj_gbihpf.TGTPCNT   := v_zeroes; 
      obj_gbihpf.PREMOUT   := 'N'; 
      obj_gbihpf.BILLDUEDT := v_effdate; 
      obj_gbihpf.REVFLAG   := v_revflag; 
      obj_gbihpf.USER_T    := v_vrcmuser; 
      obj_gbihpf.ZGSTAFEE  := v_zeroes; 
      obj_gbihpf.ZGSTCOM   := v_zeroes; 
      obj_gbihpf.ZCOLFLAG  := v_zcolflag; 
      obj_gbihpf.ZACMCLDT  := v_maxdate; --?colom is not avelable in STAGEDBUSR.TITDMGREF1; 
      obj_gbihpf.PAYDATE   := v_paydate; 
      obj_gbihpf.ZPOSBDSM  := v_zposbdsm; 
      obj_gbihpf.ZPOSBDSY  := v_zposbdsy; 
      obj_gbihpf.USRPRF    := v_userProfile; 
      obj_gbihpf.JOBNM     := v_scheduleName; 
      obj_gbihpf.DATIME    := sysdate; 
      obj_gbihpf.ZBKTRFDT  := 99999999;  --- RF3 
      INSERT INTO GBIHPF VALUES obj_gbihpf; 
      v_errorCount1        := 0;           
      --------------------- GBIHPF Insertion END ---------------------------- 
      --------------------- ZRFDPF  Insertion START -------------------------- 
      /*  obj_zrfdpf.CHDRNUM    :=v_chdrnum1; 
      obj_zrfdpf.TRANNO     :=temp_trano; 
      obj_zrfdpf.BILLNO     :=v_temp_billno; 
      obj_zrfdpf.EFFDATE    :=v_effdate; 
      obj_zrfdpf.ZREFMTCD   :=v_zrefmtcd1; 
      IF TRIM(v_zrefundbe)  <> 0 AND TRIM(v_zrefundbe)IS NOT NULL THEN 
      obj_zrfdpf.ZREFUNDAM:=v_zrefundbe; 
      ELSE 
      obj_zrfdpf.ZREFUNDAM:=v_zrefundbz; 
      END IF; 
      INSERT INTO ZRFDPF VALUES obj_zrfdpf;*/ 
      IF TRIM(v_zrefundbe) <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
        temp_zrefundam1    := v_zrefundbe; 
      ELSE 
        temp_zrefundam1 := v_zrefundbz; 
      END IF;
        ------------RF7: START-----------  
        IF TRIM(v_zrefmtcd1) = '001' THEN
        v_zrefundam_r := '002';
        END IF;
        IF TRIM(v_zrefmtcd1) = '002' THEN
        v_zrefundam_r := '001';
        END IF;
        ------------RF7: END-----------  


      INSERT 
      INTO ZRFDPF 
        ( 
          CHDRNUM, 
          TRANNO, 
          BILLNO, 
          EFFDATE, 
          ZREFMTCD, 
          ZREFUNDAM, 
          USRPRF, 
          JOBNM, 
          DATIME 
        ) 
        VALUES 
        ( 
          v_chdrnum1, 
          temp_trano, 
          v_temp_billno, 
          v_effdate, 
          v_zrefundam_r, ----- RF7
          temp_zrefundam1, 
          v_userProfile, 
          v_scheduleName, 
          sysdate 
        ); 
      --------------------- ZRFDPF  Insertion END ---------------------------- 
      --------------------- ZREPPF Insertion START -------------------------- 
      obj_zreppf.CHDRNUM    := v_chdrnum1; 
      obj_zreppf.EFFDATE    := v_effdate; 
      obj_zreppf.TRANNO     := temp_trano; 
      obj_zreppf.ZALTRCDE01 := v_zaltrcde01; 
      obj_zreppf.ZREFUNDAM  := 0; 
      obj_zreppf.ZREFUNDBE  := 0; 
      obj_zreppf.ZREFUNDBZ  := 0; 
      -------------ZREFUNDAM ---------- 
      IF temp_zrefundam        IS NULL AND TRIM(temp_zrefundam) <> 0 THEN 
        IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDAM := v_zrefundbe; 
          update_zrefundam     := v_zrefundbe; 
        ELSE 
          obj_zreppf.ZREFUNDAM := v_zrefundbz; 
          update_zrefundam     := v_zrefundbz; 
        END IF; 
      ELSE 
        IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDAM := v_zrefundbe + temp_zrefundam; 
          update_zrefundam     := v_zrefundbe + temp_zrefundam; 
        ELSE 
          obj_zreppf.ZREFUNDAM := v_zrefundbz + temp_zrefundam; 
          update_zrefundam     := v_zrefundbz + temp_zrefundam; 
        END IF; 
      END IF; 
      -------------ZREFUNDAM  END---------- 
      -------------ZREFMTCD ---------- 
      IF temp_zrefmtcd      IS NULL THEN 
        obj_zreppf.ZREFMTCD := v_zrefmtcd1; 
        update_zrefmtcd     := v_zrefmtcd1; 
      ELSE 
        IF TRIM(temp_zrefmtcd) <> TRIM(v_zrefmtcd1) THEN 
          obj_zreppf.ZREFMTCD  := v_zrefmtcd_DV; 
          update_zrefmtcd      := v_zrefmtcd_DV; 
        ELSE 
          obj_zreppf.ZREFMTCD := v_zrefmtcd1; 
          update_zrefmtcd     := v_zrefmtcd1; 
        END IF; 
      END IF; 
      -------------ZREFMTCD  END---------- 
      -------------ZREFUNDBE---------- 
      --obj_zreppf.ZREFUNDBE :=IgSpaceValue;                                                    --?Logic 
      IF temp_zrefundbe        IS NULL AND TRIM(temp_zrefundbe) <> 0 THEN 
        IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDBE := v_zrefundbe; 
          update_zrefundbe     := v_zrefundbe; 
        END IF; 
      ELSE 
        IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDBE := v_zrefundbe + temp_zrefundbe; 
          update_zrefundbe     := v_zrefundbe + temp_zrefundbe; 
        END IF; 
      END IF; 
      -------------ZREFUNDBE END ---------- 
      -------------ZREFUNDBZ---------- 
      --obj_zreppf.ZREFUNDBZ :=IgSpaceValue; --?Logic 
      IF temp_zrefundbz        IS NULL AND TRIM(temp_zrefundbz) <> 0 THEN 
        IF TRIM(v_zrefundbz)   <> 0 AND TRIM(v_zrefundbz) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDBZ := v_zrefundbz; 
          update_zrefundbz     := v_zrefundbz; 
        END IF; 
      ELSE 
        IF TRIM(v_zrefundbz)   <> 0 AND TRIM(v_zrefundbz) IS NOT NULL THEN 
          obj_zreppf.ZREFUNDBZ := v_zrefundbz + v_zrefundbz; 
          update_zrefundbz     := v_zrefundbz + v_zrefundbz; 
        END IF; 
      END IF; 
      -------------ZREFUNDBZ END---------- 
      -------------ZENRFDST ---------- 
      -- obj_zreppf.ZENRFDST :=IgSpaceValue; --?Logic 
      IF temp_zenrfdst      IS NULL THEN 
        obj_zreppf.ZENRFDST := TRIM(v_zenrfdst); --? size worng (ST1=20 and zreppf=2 ) 
        update_zenrfdst     := TRIM(v_zenrfdst); 
      ELSE 
        IF TRIM(v_zenrfdst)    IS NOT NULL THEN 
          obj_zreppf.ZENRFDST  := TRIM(v_zenrfdst); 
          temp_zrfdst_zenrfdst := TRIM(v_zenrfdst); 
          update_zenrfdst      := TRIM(v_zenrfdst); 
        ELSE 
          obj_zreppf.ZENRFDST  := TRIM(temp_zenrfdst); 
          temp_zrfdst_zenrfdst := TRIM(temp_zenrfdst); 
          update_zenrfdst      := TRIM(temp_zenrfdst); 
        END IF; 
      END IF; 
      -------------ZENRFDST END---------- 
      -------------ZZHRFDST ---------- 
      --  obj_zreppf.ZZHRFDST :=IgSpaceValue; --?Logic 
      IF temp_zzhrfdst      IS NULL THEN 
        obj_zreppf.ZZHRFDST := TRIM(v_zzhrfdst); 
        update_zzhrfdst     := TRIM(v_zzhrfdst); 
      ELSE 
        IF TRIM(v_zzhrfdst)    IS NOT NULL THEN 
          obj_zreppf.ZZHRFDST  := TRIM(v_zzhrfdst); 
          temp_zrfdst_zenrfdst := TRIM(v_zzhrfdst); 
          update_zzhrfdst      := TRIM(v_zzhrfdst); 
        ELSE 
          obj_zreppf.ZZHRFDST  := TRIM(temp_zzhrfdst); 
          temp_zrfdst_zzhrfdst := TRIM(temp_zzhrfdst); 
          update_zzhrfdst      := TRIM(temp_zzhrfdst); 
        END IF; 
      END IF; 
      -------------ZZHRFDST END---------- 
      -------------ZRFDST ---------- 
      --   obj_zreppf.ZRFDST :=IgSpaceValue; --?Logic 
      IF temp_zrfdst_zenrfdst IS NOT NULL AND temp_zrfdst_zenrfdst <> 'RC' THEN 
        obj_zreppf.ZRFDST     := TRIM(temp_zrfdst_zenrfdst); 
        update_zrfdst         := TRIM(temp_zrfdst_zenrfdst); 
      ELSE 
        IF temp_zrfdst_zzhrfdst IS NOT NULL THEN 
          obj_zreppf.ZRFDST     := TRIM(temp_zrfdst_zzhrfdst); 
          update_zrfdst         := TRIM(temp_zrfdst_zzhrfdst); 
        ELSE 
          obj_zreppf.ZRFDST := TRIM(temp_zrfdst_zenrfdst); 
          update_zrfdst     := TRIM(temp_zrfdst_zenrfdst); 
        END IF; 
      END IF; 
      -------------ZRFDST END---------- 
      obj_zreppf.CLNTNUM := temp_cownnum; --?LogicRead CHDRPF, using CHDRCOY = Bsprpf.company and CHDRNUM = ?eTITDMGREF1.CHDRNUM. 
      --Then,CLNTNUM = GCHD.COWNNUM 
      --obj_zreppf.BANKKEY    := v_bankkey; 
      obj_zreppf.BANKKEY    := NULL;
      obj_zreppf.BANKACOUNT := v_bankacount; 
      obj_zreppf.BANKACCDSC := v_bankaccdsc; 
      obj_zreppf.BNKACTYP   := v_bnkactyp; 
      obj_zreppf.ZRQBKRDF   := v_zrqbkrdf; 
      obj_zreppf.REQDATE    := v_reqdate; 
      obj_zreppf.ZCOLFLAG   := 'Y'; 
      obj_zreppf.ZPBCODE    := IgSpaceValue; 
      obj_zreppf.ZPBACNO    := IgSpaceValue; 
      obj_zreppf.ZPBCTYPE   := IgSpaceValue; 
      obj_zreppf.CURRFROM   := v_maxdate;   --?Vrcm.Maxdate 
      obj_zreppf.PTDATE     := temp_ptdate; --?Logic Read CHDRPF, using CHDRCOY = Bsprpf.company and CHDRNUM = ?eTITDMGREF1.CHDRNUM. 
      obj_zreppf.USRPRF     := v_userProfile; 
      obj_zreppf.JOBNM      := v_scheduleName; 
      obj_zreppf.DATIME     := sysdate; 
      --Then,PTDATE = GCHD.PTDATE 
      ----JD comment 
      IF b_zreppfFlag = TRUE THEN 
        /* UPDATE VIEW_ZREPPF 
        SET ZREFUNDAM = update_zrefundam, 
        ZREFMTCD  = update_zrefmtcd, 
        ZREFUNDBE = update_zrefundbe, 
        ZREFUNDBZ = update_zrefundbz, 
        ZENRFDST  = update_zenrfdst, 
        ZZHRFDST  = update_zzhrfdst, 
        ZRFDST    = update_zrfdst 
        WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum1) 
        AND TRIM(TRANNO) = TRIM(temp_trano);*/ 
        v_zrefundbe_l        := b_ZREFUNDBE   + v_zrefundbe; 
        v_zrefundbz_l        := b_zrefundbz   + v_zrefundbz; 
        v_zrefundam_l        := v_zrefundbe_l + v_zrefundbz_l; 
        ---------------RF7: START-----------------
        --IF TRIM(v_zrefmtcd_l) = '001' THEN
        --    v_zrefmtcd_l := '002';
        --END IF;
        --IF TRIM(v_zrefmtcd_l) = '002' THEN
        --    v_zrefmtcd_l := '001';
        --END IF;
        ---------------RF7: END-------------------
        --IF (TRIm(b_ZREFMTCD) IS NOT NULL AND TRIm(b_ZREFMTCD) = TRIM(v_zrefmtcd1)) THEN 

          --v_zrefmtcd_l       := v_zrefmtcd1; 
        --ELSE 
        --  v_zrefmtcd_l := v_zrefmtcd_DV; 
        --END IF;
        ---------------RF7: START-----------------
        --IF TRIM(v_zrefmtcd_l) = '001' THEN
        --    v_zrefmtcd_l := '002';
        --END IF;
        --IF TRIM(v_zrefmtcd_l) = '002' THEN
        --    v_zrefmtcd_l := '001';
        --END IF;
        ---------------RF7: END-------------------
        IF (TRIM(v_zenrfdst) IS NOT NULL) THEN 
          v_zenrfdst_l       := v_zenrfdst; 
        ELSE 
          v_zenrfdst_l := b_ZENRFDST; 
        END IF; 
        IF (TRIM(v_zzhrfdst) IS NOT NULL) THEN 
          v_zzhrfdst_l       := v_zzhrfdst; 
        ELSE 
          v_zzhrfdst_l := b_ZZHRFDST; 
        END IF; 
        IF (TRIm(b_zenrfdst) IS NOT NULL AND TRIm(b_zenrfdst) <> 'RC') THEN 
          v_zrfdst_l         := b_zenrfdst; 
        ELSE 
          IF (TRIm(b_zzhrfdst) IS NOT NULL) THEN 
            v_zrfdst_l         := b_zzhrfdst; 
          ELSE 
            v_zrfdst_l := b_zenrfdst; 
          END IF; 
        END IF; 
        IF TRIM(v_zrefmtcd1) = '001' THEN  --- RF8
           v_zrefmtcd_l := '002';          --- RF8
        END IF;                            --- RF8
        IF TRIM(v_zrefmtcd1) = '002' THEN  --- RF8
           v_zrefmtcd_l := '001';          --- RF8
        END IF;                            --- RF8
        IF TRIM(b_ZREFMTCD) IS NULL THEN   --- RF8
           b_ZREFMTCD  := v_zrefmtcd_l;    --- RF8
        END IF;                            --- RF8
        IF TRIM(b_ZREFMTCD) <> TRIM(v_zrefmtcd_l) THEN  --- RF8
           v_zrefmtcd_l := v_zrefmtcd_DV;               --- RF8
        END IF;                                         --- RF8
        UPDATE VIEW_ZREPPF 
        SET ZREFUNDAM       = v_zrefundam_l, 
          ZREFMTCD          = v_zrefmtcd_l, --------------------- RF7
          ZREFUNDBE         = v_zrefundbe_l, 
          ZREFUNDBZ         = v_zrefundbz_l, 
          ZENRFDST          = v_zenrfdst_l, 
          ZZHRFDST          = v_zzhrfdst_l, 
          ZRFDST            = v_zrfdst_l 
        WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum1) 
        AND TRIM(TRANNO)    = TRIM(temp_trano); 
      ELSE 
        IF (TRIM(v_zrefundbe) IS NOT NULL) THEN 
          v_zrefundbe_l       := v_zrefundbe; 
        ELSE 
          v_zrefundbe_l := 0.00; 
        END IF; 
        IF (TRIM(v_zrefundbz) IS NOT NULL) THEN 
          v_zrefundbz_l       := v_zrefundbz; 
        ELSE 
          v_zrefundbz_l := 0.00; 
        END IF; 
        v_zrefundam_l        := v_zrefundbe_l + v_zrefundbz_l; 
        v_zrefmtcd_l         := v_zrefmtcd1; 
        v_zenrfdst_l         := v_zenrfdst; 
        v_zzhrfdst_l         := v_zzhrfdst; 
        IF (TRIm(v_zenrfdst) IS NOT NULL AND TRIm(v_zenrfdst) <> 'RC') THEN 
          v_zrfdst_l         := v_zenrfdst; 
        ELSE 
          IF (TRIm(v_zzhrfdst) IS NOT NULL) THEN 
            v_zrfdst_l         := v_zzhrfdst; 
          ELSE 
            v_zrfdst_l := v_zenrfdst; 
          END IF; 
        END IF; 
        obj_zreppf.ZREFUNDBE := v_zrefundbe_l; 
        obj_zreppf.ZREFUNDBZ := v_zrefundbz_l; 
        obj_zreppf.ZREFUNDAM := v_zrefundam_l; 
        -------------RF7: START-----------------------
        IF TRIM(v_zrefmtcd1) = '001' THEN
            v_zrefmtcd_l := '002';
        END IF;
        IF TRIM(v_zrefmtcd1) = '002' THEN
            v_zrefmtcd_l := '001';
        END IF;
        --ps--------------RF7: END-------------------------
        obj_zreppf.ZREFMTCD  := v_zrefmtcd_l; 
        obj_zreppf.ZENRFDST  := v_zenrfdst_l; 
        obj_zreppf.ZZHRFDST  := v_zzhrfdst_l; 
        obj_zreppf.ZRFDST    := v_zrfdst_l; 
        INSERT INTO VIEW_ZREPPF VALUES obj_zreppf; 
      END IF; 
      /*  IF (zreppfarr_list1.exists(TRIM(v_chdrnum1) || TRIM(temp_trano))) THEN 
      obj_zreppf_l  := zreppfarr_list1(TRIM(v_chdrnum1) || 
      TRIM(temp_trano)); 
      v_zrefundbe_l := obj_zreppf_l.ZREFUNDBE + v_zrefundbe; 
      v_zrefundbz_l := obj_zreppf_l.zrefundbz + v_zrefundbz; 
      v_zrefundam_l := v_zrefundbe_l + v_zrefundbz_l; 
      IF (TRIm(obj_zreppf_l.ZREFMTCD) IS NOT NULL AND 
      TRIm(obj_zreppf_l.ZREFMTCD) = TRIM(v_zrefmtcd1)) THEN 
      v_zrefmtcd_l := v_zrefmtcd1; 
      ELSE 
      v_zrefmtcd_l := v_zrefmtcd_DV; 
      END IF; 
      IF (TRIM(v_zenrfdst) IS NOT NULL) THEN 
      v_zenrfdst_l := v_zenrfdst; 
      ELSE 
      v_zenrfdst_l := obj_zreppf_l.ZENRFDST; 
      END IF; 
      IF (TRIM(v_zzhrfdst) IS NOT NULL) THEN 
      v_zzhrfdst_l := v_zzhrfdst; 
      ELSE 
      v_zzhrfdst_l := obj_zreppf_l.ZZHRFDST; 
      END IF; 
      ELSE 
      If (TRIM(v_zrefundbe) IS NOT NULL) THEN 
      v_zrefundbe_l := v_zrefundbe; 
      ELSE 
      v_zrefundbe_l := 0.00; 
      END IF; 
      if (TRIM(v_zrefundbz) IS NOT NULL) THEN 
      v_zrefundbz_l := v_zrefundbz; 
      ELSE 
      v_zrefundbz_l := 0.00; 
      END IF; 
      v_zrefundam_l := v_zrefundbe_l + v_zrefundbz_l; 
      v_zrefmtcd_l  := v_zrefmtcd1; 
      v_zenrfdst_l  := v_zenrfdst; 
      v_zzhrfdst_l  := v_zzhrfdst; 
      END IF; 
      obj_zreppf_updated           := obj_zreppf; 
      obj_zreppf_updated.ZREFUNDBE := v_zrefundbe_l; 
      obj_zreppf_updated.ZREFUNDBZ := v_zrefundbz_l; 
      obj_zreppf_updated.ZREFUNDAM := v_zrefundam_l; 
      obj_zreppf_updated.ZREFMTCD  := v_zrefmtcd_l; 
      obj_zreppf_updated.ZENRFDST  := v_zenrfdst_l; 
      obj_zreppf_updated.ZZHRFDST  := v_zzhrfdst_l; 
      obj_zreppf_updated.ZRFDST    := v_zrfdst_l; 
      zreppfarr_list1(TRIM(v_chdrnum1) || TRIM(temp_trano)) := obj_zreppf_updated; 
      */ 
      --gxhipfindex := gxhipfindex + 1; 
      --gxhipg_list.extend; 
      --zreppf_list(gxhipfindex) := obj_gxhipf; 
      --------------------- ZREPPF Insertion END ---------------------------- 
      v_temp_billno := v_temp_billno + 1; 
      ----- 
    END IF; 
  END LOOP; 
    ---- RF3 Start----- 
  UPDATE Jd1dta.GDOCPF 
  SET LDOCNO    = v_temp_billno - 1, 
    USRPRF      = v_vrcmuser, 
    JOBNM       = v_scheduleName, 
    DATIME      = CURRENT_TIMESTAMP 
  WHERE CHDRCOY = v_company 
  AND DOCTYP    = 'PRMNOT'; 
  ----- RF3 End ----- 
COMMIT;

------------RF9 : START------------------------  
    v_prv_refnum      := ' ';
    v_prv_policy      := ' ';
    v_temp_GPST01     := 0;
    v_temp_GPST02     := 0;
    v_temp_GPST       := 0;
    v_temp_COMMN      := 0;
    v_temp_COMMN_Rnd  :=0;

    v_temp_COMMN_Stg  :=0;
    v_temp_ZAGTGPRM01 :=0;
    v_temp_ZAGTGPRM02 :=0;

    v_prv_refnum_z    := ' ';--COMPARISON VARIABLE FOR ZPCMPF(REFNUM)
    v_prv_policy_z    := ' ';--COMPARISON VARIABLE FOR ZPCMPF(POLICY NUMBER)
    v_collfee01    :=0;
------------RF9 : END------------------------  


  OPEN refundBills_cursor2 ;--(TRIM(v_refnum), TRIM(v_chdrnum1)); 
  <<again_start2>> 
  LOOP 
    FETCH refundBills_cursor2 INTO obj_refundBills2; 
    EXIT 
  WHEN refundBills_cursor2%notfound; 

     v_temp_key   := TRIM(obj_refundBills2.CHDRNUM) || TRIM(obj_refundBills2.TRREFNUM) || TRIM(obj_refundBills2.ZREFMTCD); 
   select seqtmp1.nextval into v_seq from dual;
   IF (refbilinfo.exists(TRIM(v_temp_key))) THEN     
     v_refnum   := refbilinfo(TRIM(v_temp_key)).refnum; 
     v_chdrnum1 := refbilinfo(TRIM(v_temp_key)).chdrnum; 
     v_effdate  := refbilinfo(TRIM(v_temp_key)).effdate; 
     v_prbilfdt := refbilinfo(TRIM(v_temp_key)).prbilfdt; 
     v_prbiltdt := refbilinfo(TRIM(v_temp_key)).prbiltdt; 
    --  dbms_output.put_line('Procedure execution time = ' || ''); 
    ELSE       
      CONTINUE again_start2; 
    END IF; 
    v_recidxrefb2 := obj_refundBills2.RECIDXREFB2; 
    v_trrefnum    := obj_refundBills2.TRREFNUM; 
    v_chdrnum2    := obj_refundBills2.CHDRNUM; 
    v_zrefmtcd2   := obj_refundBills2.ZREFMTCD; 
    v_prodtyp     := obj_refundBills2.PRODTYP; 
    v_bprem       := obj_refundBills2.BPREM; 
    v_gagntsel01  := obj_refundBills2.GAGNTSEL01; 
    v_gagntsel02  := obj_refundBills2.GAGNTSEL02; 
    v_gagntsel03  := obj_refundBills2.GAGNTSEL03; 
    v_gagntsel04  := obj_refundBills2.GAGNTSEL04; 
    v_gagntsel05  := obj_refundBills2.GAGNTSEL05; 
    v_cmrate01    := obj_refundBills2.CMRATE01; 
    v_cmrate02    := obj_refundBills2.CMRATE02; 
    v_cmrate03    := obj_refundBills2.CMRATE03; 
    v_cmrate04    := obj_refundBills2.CMRATE04; 
    v_cmrate05    := obj_refundBills2.CMRATE05; 
    v_commn01     := obj_refundBills2.COMMN01; 
    v_commn02     := obj_refundBills2.COMMN02; 
    v_commn03     := obj_refundBills2.COMMN03; 
    v_commn04     := obj_refundBills2.COMMN04; 
    v_commn05     := obj_refundBills2.COMMN05; 
    v_zagtgprm01  := obj_refundBills2.ZAGTGPRM01; 
    v_zagtgprm02  := obj_refundBills2.ZAGTGPRM02; 
    v_zagtgprm03  := obj_refundBills2.ZAGTGPRM03; 
    v_zagtgprm04  := obj_refundBills2.ZAGTGPRM04; 
    v_zagtgprm05  := obj_refundBills2.ZAGTGPRM05; 
    v_zcollfee01  := obj_refundBills2.ZCOLLFEE01; 
    temp_cmrate   := 0; 
    t_ercode2(1)  := NULL; 
    t_ercode2(2)  := NULL; 
    t_ercode2(3)  := NULL; 
    t_ercode2(4)  := NULL; 
    t_ercode2(5)  := NULL; 
    temp_refKey2  := ' '; 
    temp_refKey2  := (v_chdrnum2 || '_' || v_trrefnum || '_' || v_zrefmtcd2 || '_' || v_prodtyp); 
    --   i_zdoe_info              :=NULL; 
    i_zdoe_info2.i_zfilename  := 'TITDMGREF2'; 
    i_zdoe_info2.i_prefix     := c_prefix; 
    i_zdoe_info2.i_scheduleno := v_scheduleNumber; 
    i_zdoe_info2.i_tableName  := v_tableName; 
    i_zdoe_info2.i_refKey     := TRIM(temp_refKey2); 
    v_errorCount2             := 0; 
    --b_globalError             := TRUE; 
    b_isNoError2 := TRUE; 
    n_gagnstel01 := 0; 
    n_gagnstel02 := 0; 
    n_gagnstel03 := 0; 
    n_gagnstel04 := 0; 
    n_gagnstel05 := 0; 
  --  v_temp_key   := TRIM(v_chdrnum2) || TRIM(v_trrefnum) || TRIM(v_zrefmtcd2); 
--    IF (refbilinfo.exists(TRIM(v_temp_key))) THEN 
--      v_refnum   := refbilinfo(TRIM(v_temp_key)).refnum; 
--      v_chdrnum1 := refbilinfo(TRIM(v_temp_key)).chdrnum; 
--      v_effdate  := refbilinfo(TRIM(v_temp_key)).effdate; 
--      v_prbilfdt := refbilinfo(TRIM(v_temp_key)).prbilfdt; 
--      v_prbiltdt := refbilinfo(TRIM(v_temp_key)).prbiltdt; 
--    ELSE 
--      CONTINUE again_start2; 
--    END IF; 
    /*      IF NOT (checkduplicateIntitdmgref2.exists(TRIM(v_chdrnum1) || 
    TRIM(v_zrefmtcd1) || 
    TRIM(v_refnum))) THEN 
    b_isNoError2                  := FALSE; 
    b_globalError                 := FALSE; 
    i_zdoe_info2.i_indic          := 'E'; 
    i_zdoe_info2.i_error01        := C_Z004; 
    i_zdoe_info2.i_errormsg01     := o_errortext(C_Z004); 
    i_zdoe_info2.i_errorfield01   := 'chdrnum1'; 
    i_zdoe_info2.i_fieldvalue01   := TRIM(v_chdrnum1); 
    i_zdoe_info2.i_errorprogram01 := v_scheduleName; 
    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2); 
    CONTINUE again_start2; 
    END IF;*/ 
    --ELSE 
    ------------------------- LOGIC FOR AGENCY PATTERN ID START------------------------ 
    -- IF b_isNoError1 = TRUE AND b_isNoError2 = TRUE THEN 
    --    dbms_output.put_line('Procedure execution time = ' || v_chdrnum1); 
    --SELECT ZAGPTNUM INTO v_zagptnum FROM GCHIPF WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum1); 

        --- Rahul Chouhan Changes Start --- 
    IF b_isNoError2 = TRUE THEN 
      IF (getZagptnum.exists(TRIM(v_chdrnum1))) THEN 
        tempZagptnum := getZagptnum(TRIM(v_chdrnum1)); 
        --    dbms_output.put_line('ZAGPTNUM' || tempZagptnum); 
        SELECT tempZagptnum 
        INTO v_zagptnum 
        FROM dual; 
      END IF; 
          --- Rahul Chouhan Changes End ----- 


      --        SELECT ZGPORIPCLS, ZCONVINDPOL 
      --          INTO gchp_zgporipcls, gchp_zconvindpol 
      --          FROM GCHPPF 
      --         WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum1); 
      --        IF TRIM(gchp_zgporipcls) = 'G' THEN 
      --          b_memberpolicyFlag := TRUE; 
      --        ELSIF TRIM(gchp_zconvindpol) <> ' ' THEN 
      --          b_convertedindpol := TRUE; 
      --        ELSIF TRIM(gchp_zgporipcls) = 'I' THEN 
      --          b_indpolicyFlag := TRUE; 
      --        END IF; 
      --        IF (getZagptnum.exists(TRIM(v_chdrnum1))) THEN 
      --          tempZagptnum := getZagptnum(TRIM(v_chdrnum1)); 
      --          SELECT regexp_substr(tempZagptnum, '[^$]+', 1, 1), 
      --                 regexp_substr(tempZagptnum, '[^$]+', 1, 2), 
      --                 regexp_substr(tempZagptnum, '[^$]+', 1, 3) 
      --            INTO temp_effdate, temp_zagptnum, temp_zcmpcode 
      --            FROM dual 
      --           WHERE regexp_substr(tempZagptnum, '[^$]+', 1, 1) <= 
      --                 TRIM(v_effdate); 
      --        END IF; 
      --        IF b_memberpolicyFlag = TRUE OR b_convertedindpol = TRUE THEN 
      --          --SELECT ZAGPTNUM INTO v_zagptnum FROM GCHIPF WHERE CHDRNUM = obj_billing1.CHDRNUM; 
      --          --        SELECT ZAGPTNUM 
      --          --        INTO v_zagptnum 
      --          --        FROM 
      --          --          (SELECT ZAGPTNUM 
      --          --          FROM GCHIPF 
      --          --          WHERE TRIM(EFFDATE) <= TRIM(v_effdate) --20170701 <= 99999999 
      --          --          AND TRIM(CHDRNUM)    = TRIM(v_chdrnum1) 
      --          --          ORDER BY EFFDATE DESC 
      --          --          ) 
      --          --        WHERE rownum = 1; 
      --          v_zagptnum := temp_zagptnum; 
      --        END IF; 
      --        IF b_indpolicyFlag = TRUE THEN 
      --          --        --SELECT ZCMPCODE INTO v_zcmpcode FROM GCHIPF WHERE CHDRNUM = obj_billing1.CHDRNUM; 
      --          --        SELECT ZCMPCODE 
      --          --        INTO v_zcmpcode 
      --          --        FROM 
      --          --          (SELECT ZCMPCODE 
      --          --          FROM GCHIPF 
      --          --          WHERE TRIM(EFFDATE) <=TRIM(v_effdate) 
      --          --          AND TRIM(CHDRNUM)    = TRIM(v_chdrnum1) 
      --          --          ORDER BY EFFDATE DESC 
      --          --          ) 
      --          --        WHERE rownum = 1; 
      --          --        --SELECT ZAGPTID INTO v_zagptnum FROM ZCPNPF WHERE ZCMPCODE = v_zcmpcode; 
      --          --        SELECT ZAGPTID 
      --          --        INTO v_zagptnum 
      --          --        FROM ZCPNPF 
      --          --        WHERE TRIM(ZCMPCODE) = TRIM(v_zcmpcode); 
      --          IF (getZagptid.exists(TRIM(temp_zcmpcode))) THEN 
      --            v_zagptnum := getZagptid(TRIM(temp_zcmpcode)); 
      --          END IF; 
      --        END IF; 
      ---------------------- SPLITC Logic ------------------------------------------ 
      -- SELECT SPLITC01, SPLITC02, SPLITC03, SPLITC04, SPLITC05 INTO n_splitc01, n_splitc02, n_splitc03, n_splitc04, n_splitc05 FROM ZAGPPF WHERE ZAGPTNUM = v_zagptnum; 
      --      SELECT GAGNTSEL01, 
      --        GAGNTSEL02, 
      --        GAGNTSEL03, 
      --        GAGNTSEL04, 
      --        GAGNTSEL05, 
      --        SPLITC01, 
      --        SPLITC02, 
      --        SPLITC03, 
      --        SPLITC04, 
      --        SPLITC05 
      --      INTO temp_gagntsel01, 
      --        temp_gagntsel02, 
      --        temp_gagntsel03, 
      --        temp_gagntsel04, 
      --        temp_gagntsel05, 
      --        n_splitc01, 
      --        n_splitc02, 
      --        n_splitc03, 
      --        n_splitc04, 
      --        n_splitc05 
      --      FROM ZAGPPF 
      --      WHERE TRIM(ZAGPTNUM)                     = TRIM(v_zagptnum); 
      -- 
      IF (getGagntsel.exists(TRIM(v_zagptnum))) THEN 
        --  dbms_output.put_line('v_zagptnum = ' || v_zagptnum); 
        tempGagntsel := getGagntsel(TRIM(v_zagptnum)); 
        --  dbms_output.put_line('tempGagntsel = ' || tempGagntsel); 
        SELECT TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 1)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 2)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 3)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 4)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 5)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 6)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 7)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 8)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 9)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 10)), 
          TRIM(regexp_substr(tempGagntsel, '[^$]+', 1, 11)) 
        INTO temp_gagntsel01, 
          temp_gagntsel02, 
          temp_gagntsel03, 
          temp_gagntsel04, 
          temp_gagntsel05, 
          n_splitc01, 
          n_splitc02, 
          n_splitc03, 
          n_splitc04, 
          n_splitc05, 
          v_zcolrate 
        FROM dual; 
        --          dbms_output.put_line('v_zcolrate = ' || v_zcolrate); 
      END IF; 
      IF TRIM(v_gagntsel01)             <> TRIM(temp_gagntsel01) AND TRIM(v_gagntsel01) <> TRIM(temp_gagntsel02) AND TRIM(v_gagntsel01) <> TRIM(temp_gagntsel03) AND TRIM(v_gagntsel01) <> TRIM(temp_gagntsel04) AND TRIM(v_gagntsel01) <> TRIM(temp_gagntsel05) THEN 
        b_isNoError2                    := FALSE; 
        n_gagnstel01                    := 0; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := c_Z132; --- NEED TO CHANGE 
        t_errorfield2(v_errorCount2)    := 'GAGNTSEL01'; 
        t_errormsg2(v_errorCount2)      := o_errortext(c_Z132); -- Need to change 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel01); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
      IF n_gagnstel01         = 1 THEN 
        IF TRIM(v_gagntsel01) = TRIM(temp_gagntsel01) THEN 
          n_wsaasplitc01     := n_splitc01; 
        END IF; 
        IF TRIM(v_gagntsel01) = TRIM(temp_gagntsel02) THEN 
          n_wsaasplitc01     := n_splitc02; 
        END IF; 
        IF TRIM(v_gagntsel01) = TRIM(temp_gagntsel03) THEN 
          n_wsaasplitc01     := n_splitc03; 
        END IF; 
        IF TRIM(v_gagntsel01) = TRIM(temp_gagntsel04) THEN 
          n_wsaasplitc01     := n_splitc04; 
        END IF; 
        IF TRIM(v_gagntsel01) = TRIM(temp_gagntsel05) THEN 
          n_wsaasplitc01     := n_splitc05; 
        END IF; 
      END IF; 
      IF TRIM(v_gagntsel02)             <> TRIM(temp_gagntsel01) AND TRIM(v_gagntsel02) <> TRIM(temp_gagntsel02) AND TRIM(v_gagntsel02) <> TRIM(temp_gagntsel03) AND TRIM(v_gagntsel02) <> TRIM(temp_gagntsel04) AND TRIM(v_gagntsel02) <> TRIM(temp_gagntsel05) THEN 
        b_isNoError2                    := FALSE; 
        n_gagnstel02                    := 0; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := c_Z132; --- NEED TO CHANGE 
        t_errorfield2(v_errorCount2)    := 'GAGNTSEL02'; 
        t_errormsg2(v_errorCount2)      := o_errortext(c_Z132); -- Need to change 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel02); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
      IF n_gagnstel02         = 1 THEN 
        IF TRIM(v_gagntsel02) = TRIM(temp_gagntsel01) THEN 
          n_wsaasplitc02     := n_splitc01; 
        END IF; 
        IF TRIM(v_gagntsel02) = TRIM(temp_gagntsel02) THEN 
          n_wsaasplitc02     := n_splitc02; 
        END IF; 
        IF TRIM(v_gagntsel02) = TRIM(temp_gagntsel03) THEN 
          n_wsaasplitc02     := n_splitc03; 
        END IF; 
        IF TRIM(v_gagntsel02) = TRIM(temp_gagntsel04) THEN 
          n_wsaasplitc02     := n_splitc04; 
        END IF; 
        IF TRIM(v_gagntsel02) = TRIM(temp_gagntsel05) THEN 
          n_wsaasplitc02     := n_splitc05; 
        END IF; 
      END IF; 
      IF TRIM(v_gagntsel03)             <> TRIM(temp_gagntsel01) AND TRIM(v_gagntsel03) <> TRIM(temp_gagntsel02) AND TRIM(v_gagntsel03) <> TRIM(temp_gagntsel03) AND TRIM(v_gagntsel03) <> TRIM(temp_gagntsel04) AND TRIM(v_gagntsel03) <> TRIM(temp_gagntsel05) THEN 
        b_isNoError2                    := FALSE; 
        n_gagnstel03                    := 0; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := c_Z132; --- NEED TO CHANGE 
        t_errorfield2(v_errorCount2)    := 'GAGNTSEL03'; 
        t_errormsg2(v_errorCount2)      := o_errortext(c_Z132); -- Need to change 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel03); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
      IF n_gagnstel03         = 1 THEN 
        IF TRIM(v_gagntsel03) = TRIM(temp_gagntsel01) THEN 
          n_wsaasplitc03     := n_splitc01; 
        END IF; 
        IF TRIM(v_gagntsel03) = TRIM(temp_gagntsel02) THEN 
          n_wsaasplitc03     := n_splitc02; 
        END IF; 
        IF TRIM(v_gagntsel03) = TRIM(temp_gagntsel03) THEN 
          n_wsaasplitc03     := n_splitc03; 
        END IF; 
        IF TRIM(v_gagntsel03) = TRIM(temp_gagntsel04) THEN 
          n_wsaasplitc03     := n_splitc04; 
        END IF; 
        IF TRIM(v_gagntsel03) = TRIM(temp_gagntsel05) THEN 
          n_wsaasplitc03     := n_splitc05; 
        END IF; 
      END IF; 
      IF TRIM(v_gagntsel04)             <> TRIM(temp_gagntsel01) AND TRIM(v_gagntsel04) <> TRIM(temp_gagntsel02) AND TRIM(v_gagntsel04) <> TRIM(temp_gagntsel03) AND TRIM(v_gagntsel04) <> TRIM(temp_gagntsel04) AND TRIM(v_gagntsel04) <> TRIM(temp_gagntsel05) THEN 
        b_isNoError2                    := FALSE; 
        n_gagnstel04                    := 0; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := c_Z132; --- NEED TO CHANGE 
        t_errorfield2(v_errorCount2)    := 'GAGNTSEL04'; 
        t_errormsg2(v_errorCount2)      := o_errortext(c_Z132); -- Need to change 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel04); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
      IF n_gagnstel04         = 1 THEN 
        IF TRIM(v_gagntsel04) = TRIM(temp_gagntsel01) THEN 
          n_wsaasplitc04     := n_splitc01; 
        END IF; 
        IF TRIM(v_gagntsel04) = TRIM(temp_gagntsel02) THEN 
          n_wsaasplitc04     := n_splitc02; 
        END IF; 
        IF TRIM(v_gagntsel04) = TRIM(temp_gagntsel03) THEN 
          n_wsaasplitc04     := n_splitc03; 
        END IF; 
        IF TRIM(v_gagntsel04) = TRIM(temp_gagntsel04) THEN 
          n_wsaasplitc04     := n_splitc04; 
        END IF; 
        IF TRIM(v_gagntsel04) = TRIM(temp_gagntsel05) THEN 
          n_wsaasplitc04     := n_splitc05; 
        END IF; 
      END IF; 
      IF TRIM(v_gagntsel05)             <> TRIM(temp_gagntsel01) AND TRIM(v_gagntsel05) <> TRIM(temp_gagntsel02) AND TRIM(v_gagntsel05) <> TRIM(temp_gagntsel03) AND TRIM(v_gagntsel05) <> TRIM(temp_gagntsel04) AND TRIM(v_gagntsel05) <> TRIM(temp_gagntsel05) THEN 
        b_isNoError2                    := FALSE; 
        n_gagnstel05                    := 0; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := c_Z132; --- NEED TO CHANGE 
        t_errorfield2(v_errorCount2)    := 'GAGNTSEL04'; 
        t_errormsg2(v_errorCount2)      := o_errortext(c_Z132); -- Need to change 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel05); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
      IF n_gagnstel05         = 1 THEN 
        IF TRIM(v_gagntsel05) = TRIM(temp_gagntsel01) THEN 
          n_wsaasplitc05     := n_splitc01; 
        END IF; 
        IF TRIM(v_gagntsel05) = TRIM(temp_gagntsel02) THEN 
          n_wsaasplitc05     := n_splitc02; 
        END IF; 
        IF TRIM(v_gagntsel05) = TRIM(temp_gagntsel03) THEN 
          n_wsaasplitc05     := n_splitc03; 
        END IF; 
        IF TRIM(v_gagntsel05) = TRIM(temp_gagntsel04) THEN 
          n_wsaasplitc05     := n_splitc04; 
        END IF; 
        IF TRIM(v_gagntsel05) = TRIM(temp_gagntsel05) THEN 
          n_wsaasplitc05     := n_splitc05; 
        END IF; 
      END IF; 
    END IF; 



    IF NOT (itemexist.exists(TRIM(C_T9797) || TRIM(v_prodtyp) || 1)) THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z014; 
      t_errorfield2(v_errorCount2)    := 'prodtyp'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z014); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_prodtyp); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    --END IF; 
    IF TRIM(v_gagntsel01) IS NOT NULL THEN 
      IF NOT (checkagent.exists(TRIM(v_gagntsel01))) THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z023; 
        t_errorfield2(v_errorCount2)    := 'gagntsel01'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z023); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel01); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      ELSE 
        n_gagnstel01 := 1; 
      END IF; 
    END IF; 
    IF TRIM(v_gagntsel02) IS NOT NULL THEN 
      IF NOT (checkagent.exists(TRIM(v_gagntsel02))) THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z023; 
        t_errorfield2(v_errorCount2)    := 'gagntsel02'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z023); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel02); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      ELSE 
        n_gagnstel02 := 1; 
      END IF; 
    END IF; 
    IF TRIM(v_gagntsel03) IS NOT NULL THEN 
      IF NOT (checkagent.exists(TRIM(v_gagntsel03))) THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z023; 
        t_errorfield2(v_errorCount2)    := 'gagntsel03'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z023); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel03); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      ELSE 
        n_gagnstel03 := 1; 
      END IF; 
    END IF; 
    IF TRIM(v_gagntsel04) IS NOT NULL THEN 
      IF NOT (checkagent.exists(TRIM(v_gagntsel04))) THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z023; 
        t_errorfield2(v_errorCount2)    := 'gagntsel04'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z023); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel04); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      ELSE 
        n_gagnstel04 := 1; 
      END IF; 
    END IF; 
    IF TRIM(v_gagntsel05) IS NOT NULL THEN 
      IF NOT (checkagent.exists(TRIM(v_gagntsel05))) THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z023; 
        t_errorfield2(v_errorCount2)    := 'gagntsel05'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z023); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_gagntsel05); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      ELSE 
        n_gagnstel05 := 1; 
      END IF; 
    END IF; 
    IF v_cmrate01                       IS NOT NULL THEN 
      temp_cmrate                       := v_cmrate01; 
      IF temp_cmrate                     > 100 THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z033; 
        t_errorfield2(v_errorCount2)    := 'v_cmrate01'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z033); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_cmrate01); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
    END IF; 
    IF v_cmrate02                       IS NOT NULL THEN 
      temp_cmrate                       := temp_cmrate + v_cmrate02; 
      IF temp_cmrate                     > 100 THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z033; 
        t_errorfield2(v_errorCount2)    := 'cmrate02'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z033); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_cmrate02); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
    END IF; 
    IF v_cmrate03                       IS NOT NULL THEN 
      temp_cmrate                       := temp_cmrate + v_cmrate03; 
      IF temp_cmrate                     > 100 THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z033; 
        t_errorfield2(v_errorCount2)    := 'cmrate03'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z033); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_cmrate03); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
    END IF; 
    IF v_cmrate04                       IS NOT NULL THEN 
      temp_cmrate                       := temp_cmrate + v_cmrate04; 
      IF temp_cmrate                     > 100 THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z033; 
        t_errorfield2(v_errorCount2)    := 'cmrate04'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z033); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_cmrate04); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
    END IF; 
    IF v_cmrate05                       IS NOT NULL THEN 
      temp_cmrate                       := temp_cmrate + v_cmrate05; 
      IF temp_cmrate                     > 100 THEN 
        b_isNoError2                    := FALSE; 
        b_globalError                   := FALSE; 
        v_errorCount2                   := v_errorCount2 + 1; 
        t_ercode2(v_errorCount2)        := C_Z033; 
        t_errorfield2(v_errorCount2)    := 'cmrate05'; 
        t_errormsg2(v_errorCount2)      := o_errortext(C_Z033); 
        t_errorfieldval2(v_errorCount2) := TRIM(v_cmrate05); 
        t_errorprogram2(v_errorCount2)  := v_scheduleName; 
        IF v_errorCount2                >= 5 THEN 
          GOTO insertzdoe2; 
        END IF; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate01)               <> 0 AND TRIM(v_commn01) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z057; 
      t_errorfield2(v_errorCount2)    := 'commn01'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z057); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_commn01); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate02)               <> 0 AND TRIM(v_commn02) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z057; 
      t_errorfield2(v_errorCount2)    := 'commn02'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z057); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_commn02); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate03)               <> 0 AND TRIM(v_commn03) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z057; 
      t_errorfield2(v_errorCount2)    := 'commn03'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z057); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_commn03); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate04)               <> 0 AND TRIM(v_commn04) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z057; 
      t_errorfield2(v_errorCount2)    := 'commn04'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z057); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_commn04); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate05) <> 0 AND TRIM(v_commn05) = 0 THEN 
      -- should be 0 but v_cmrate05 =null 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z057; 
      t_errorfield2(v_errorCount2)    := 'commn05'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z057); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_commn05); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate01)               <> 0 AND TRIM(v_zagtgprm01) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z074; 
      t_errorfield2(v_errorCount2)    := 'zagtgprm01'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z074); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_zagtgprm01); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate02)               <> 0 AND TRIM(v_zagtgprm02) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z074; 
      t_errorfield2(v_errorCount2)    := 'zagtgprm02'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z074); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_zagtgprm02); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate03)               <> 0 AND TRIM(v_zagtgprm03) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z074; 
      t_errorfield2(v_errorCount2)    := 'zagtgprm03'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z074); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_zagtgprm03); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate04)               <> 0 AND TRIM(v_zagtgprm04) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z074; 
      t_errorfield2(v_errorCount2)    := 'zagtgprm04'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z074); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_zagtgprm04); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 
    IF TRIM(v_cmrate05)               <> 0 AND TRIM(v_zagtgprm05) = 0 THEN 
      b_isNoError2                    := FALSE; 
      b_globalError                   := FALSE; 
      v_errorCount2                   := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := C_Z074; 
      t_errorfield2(v_errorCount2)    := 'zagtgprm05'; 
      t_errormsg2(v_errorCount2)      := o_errortext(C_Z074); 
      t_errorfieldval2(v_errorCount2) := TRIM(v_zagtgprm05); 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      IF v_errorCount2                >= 5 THEN 
        GOTO insertzdoe2; 
      END IF; 
    END IF; 

   -----------------RF2:Bil not migrated---- 
    IF (TRIM(obj_refundBills2.ZIGVALUE) IS NULL) AND v_zprvaldYN = 'N' THEN 
      b_isNoError2                  := FALSE; 
      b_globalError                 := FALSE; 
      v_errorCount2                := v_errorCount2 + 1; 
      t_ercode2(v_errorCount2)        := 'BLNM'; 
      t_errorfield2(v_errorCount2)    := ' '; 
      t_errormsg2(v_errorCount2)      := 'Bill Not migrated'; 
      t_errorfieldval2(v_errorCount2) := ' '; 
      t_errorprogram2(v_errorCount2)  := v_scheduleName; 
      GOTO insertzdoe2; 
    END IF; 
    --------------RF2:Bil not migrated------------- 
    --validation END For TITDMGREF2 ---------- 
    ------------------------- LOGIC FOR AGENCY PATTERN ID END ------------------------ 
    ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGREF2--- 
    <<insertzdoe2>> 
    IF (b_isNoError2                   = FALSE) THEN 
      IF TRIM(t_ercode2(1))           IS NOT NULL THEN 
        i_zdoe_info2.i_indic          := 'E'; 
        i_zdoe_info2.i_error01        := t_ercode2(1); 
        i_zdoe_info2.i_errormsg01     := t_errormsg2(1); 
        i_zdoe_info2.i_errorfield01   := t_errorfield2(1); 
        i_zdoe_info2.i_fieldvalue01   := t_errorfieldval2(1); 
        i_zdoe_info2.i_errorprogram01 := t_errorprogram2(1); 
      END IF; 
      IF TRIM(t_ercode2(2))           IS NOT NULL THEN 
        i_zdoe_info2.i_indic          := 'E'; 
        i_zdoe_info2.i_error02        := t_ercode2(2); 
        i_zdoe_info2.i_errormsg02     := t_errormsg2(2); 
        i_zdoe_info2.i_errorfield02   := t_errorfield2(2); 
        i_zdoe_info2.i_fieldvalue02   := t_errorfieldval2(2); 
        i_zdoe_info2.i_errorprogram02 := t_errorprogram2(2); 
      END IF; 
      IF TRIM(t_ercode2(3))           IS NOT NULL THEN 
        i_zdoe_info2.i_indic          := 'E'; 
        i_zdoe_info2.i_error03        := t_ercode2(3); 
        i_zdoe_info2.i_errormsg03     := t_errormsg2(3); 
        i_zdoe_info2.i_errorfield03   := t_errorfield2(3); 
        i_zdoe_info2.i_fieldvalue03   := t_errorfieldval2(3); 
        i_zdoe_info2.i_errorprogram03 := t_errorprogram2(3); 
      END IF; 
      IF TRIM(t_ercode2(4))           IS NOT NULL THEN 
        i_zdoe_info2.i_indic          := 'E'; 
        i_zdoe_info2.i_error04        := t_ercode2(4); 
        i_zdoe_info2.i_errormsg04     := t_errormsg2(4); 
        i_zdoe_info2.i_errorfield04   := t_errorfield2(4); 
        i_zdoe_info2.i_fieldvalue04   := t_errorfieldval2(4); 
        i_zdoe_info2.i_errorprogram04 := t_errorprogram2(4); 
      END IF; 
      IF TRIM(t_ercode2(5))           IS NOT NULL THEN 
        i_zdoe_info2.i_indic          := 'E'; 
        i_zdoe_info2.i_error05        := t_ercode2(5); 
        i_zdoe_info2.i_errormsg05     := t_errormsg2(5); 
        i_zdoe_info2.i_errorfield05   := t_errorfield2(5); 
        i_zdoe_info2.i_fieldvalue05   := t_errorfieldval2(5); 
        i_zdoe_info2.i_errorprogram05 := t_errorprogram2(5); 
      END IF; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2); 
      v_errorCount2 :=0; 
      CONTINUE again_start2; 
    END IF; 
    ---fill the error array 
    IF b_isNoError2           = TRUE THEN 
--      obj_error.i_tableName  := i_zdoe_info1.i_tableName; 
--      obj_error.i_refKey     := i_zdoe_info2.i_refKey; 
--      obj_error.i_zfilename  := i_zdoe_info2.i_zfilename; 
--      obj_error.i_indic      := C_SUCCESS; 
--      obj_error.i_prefix     := i_zdoe_info2.i_prefix; 
--      obj_error.i_scheduleno := i_zdoe_info2.i_scheduleno; 
--      obj_error.i_errormsg01 := C_RECORDSUCCESS; 
      -- errindex               := errindex + 1; 
       i_zdoe_info2.i_indic := 'S'; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2); 
      --error_list.extend; 
      --error_list(errindex) := obj_error; 
    END IF; 
    IF b_isNoError2 = TRUE AND v_zprvaldYN = 'N' THEN 
      v_temp_billno :=obj_refundBills2.ZIGVALUE;  -- RF3 
      -- insert in  IG Jd1dta.GBIDPF   table End- 
      obj_gbidpf.CHDRCOY    := v_company; 
      obj_gbidpf.BILLNO     := v_temp_billno; 
      obj_gbidpf.PRODTYP    := v_prodtyp; 
      obj_gbidpf.PLANNO     := v_planno; 
      obj_gbidpf.CLASSINS   := IgSpaceValue; 
      obj_gbidpf.BPREM      := v_bprem * -1;  ---- RF6
      obj_gbidpf.BEXTPRM    := v_zeroes; 
      obj_gbidpf.BCOMM      := v_zeroes; 
      obj_gbidpf.BOVCOMM01  := v_zeroes; 
      obj_gbidpf.BOVCOMM02  := v_zeroes; 
      obj_gbidpf.DISCRATE   := v_zeroes; 
      obj_gbidpf.DISCAMT    := v_zeroes; 
      obj_gbidpf.BATCCOY    := v_company; 
      obj_gbidpf.BATCBRN    := v_i_branch; 
      obj_gbidpf.BATCACTYR  := v_acctYear; 
      obj_gbidpf.BATCACTMN  := v_acctMonth; 
      obj_gbidpf.BATCTRCDE  := v_transCode; 
      obj_gbidpf.BATCBATCH  := IgSpaceValue; 
      obj_gbidpf.TERMID     := v_vrcmTermid; 
      obj_gbidpf.TRDT       := n_trdt; 
      obj_gbidpf.TRTM       := v_vrcmtime; 
      obj_gbidpf.TRANNO     := temp_trano; 
      obj_gbidpf.FEES       := v_zeroes; 
      obj_gbidpf.VALIDFLAG  := v_validflag; 
      obj_gbidpf.WKLADM     := v_zeroes; 
      obj_gbidpf.DISCAMT1   := v_zeroes; 
      obj_gbidpf.DISCAMT2   := v_zeroes; 
      obj_gbidpf.DISCRATE1  := v_zeroes; 
      obj_gbidpf.DISCRATE2  := v_zeroes; 
      obj_gbidpf.RIBFEE     := v_zeroes; 
      obj_gbidpf.RIBFGST    := v_zeroes; 
      obj_gbidpf.USER_T     := v_vrcmuser; --?varcom.vrcmUser.toInt() 
      obj_gbidpf.ZCTAXAMT01 := v_zeroes; 
      obj_gbidpf.ZCTAXAMT02 := v_zeroes; 
      obj_gbidpf.ZCTAXAMT03 := v_zeroes; 
      obj_gbidpf.USRPRF     := v_userProfile; 
      obj_gbidpf.JOBNM      := v_scheduleName; 
      obj_gbidpf.DATIME     := sysdate; 
      INSERT INTO GBIDPF VALUES obj_gbidpf; 
      --------------------- Insert GBIDPF values in obj_gbidpf ---------------------------- 
            --------------------- Insert GBIDPF values in obj_gbidpf END---------------------------- 
      -- insert in  IG Jd1dta.GBIDPF   table End- 
      -- insert in  IG Jd1dta.GPMDPF    table Start- 
      obj_gpmdpf.CHDRCOY    := v_company; 
      obj_gpmdpf.CHDRNUM    := v_chdrnum1; 
      obj_gpmdpf.PRODTYP    := v_prodtyp; 
      obj_gpmdpf.HEADCNTIND := v_headcntind; 
      obj_gpmdpf.MBRNO      := v_mbrno; 
      obj_gpmdpf.DPNTNO     := v_dpntno; 
      obj_gpmdpf.TRANNO     := temp_trano; 
      obj_gpmdpf.RECNO      := v_recno; 
      obj_gpmdpf.PLANNO     := v_planno; 
      obj_gpmdpf.SUBSCOY    := IgSpaceValue; 
      obj_gpmdpf.SUBSNUM    := IgSpaceValue; 
      obj_gpmdpf.BILLTYP    := v_billtyp; 
      obj_gpmdpf.BILLNO     := v_temp_billno; 
      obj_gpmdpf.EFFDATE    := v_effdate; 
      obj_gpmdpf.PPREM      := v_bprem * -1;  --- RF6
      obj_gpmdpf.PEMXTPRM   := v_zeroes; 
      obj_gpmdpf.POAXTPRM   := v_zeroes; 
      obj_gpmdpf.INSTNO     := v_refnum; 
      obj_gpmdpf.PRMFRDT    := v_prbilfdt; 
      obj_gpmdpf.PRMTODT    := v_prbiltdt; 
      obj_gpmdpf.PNIND      := 'I'; --v_pnind;-- 
      obj_gpmdpf.MMIND      := 'L'; --v_mmind; 
      obj_gpmdpf.SRCDATA    := v_srcdata; 
      obj_gpmdpf.BATCCOY    := v_company; 
      obj_gpmdpf.BATCBRN    := v_i_branch; 
      obj_gpmdpf.BATCACTYR  := v_acctYear; 
      obj_gpmdpf.BATCACTMN  := v_acctMonth; 
      obj_gpmdpf.BATCTRCD   := v_transCode; 
      obj_gpmdpf.BATCBATCH  := IgSpaceValue; 
      obj_gpmdpf.RECTYPE    := v_rectype; 
      obj_gpmdpf.JOBNOUD    := v_zeroes; 
      obj_gpmdpf.FLATFEE    := v_zeroes; 
      obj_gpmdpf.FEES       := v_zeroes; 
      obj_gpmdpf.EVNTFEE    := v_zeroes; 
      obj_gpmdpf.MFJOBNO    := v_zeroes; 
      obj_gpmdpf.JOBNOISS   := v_scheduleNumber; 
      obj_gpmdpf.BBJOBNO    := v_zeroes; 
      obj_gpmdpf.JOBNOTPA   := v_zeroes; 
      obj_gpmdpf.USRPRF     := v_userProfile; 
      obj_gpmdpf.JOBNM      := v_scheduleName; 
      obj_gpmdpf.DATIME     := sysdate; 
      select SEQ_GPMDPF.nextval into v_pkValue from dual;
      obj_gpmdpf.UNIQUE_NUMBER := v_pkValue; 
      INSERT INTO GPMDPF VALUES obj_gpmdpf; 
      --------------------- Insert GBIDPF values in obj_gbidpf ---------------------------- 
      --------------------- Insert GBIDPF values in obj_gbidpf END ---------------------------- 


      -- insert in  IG Jd1dta.GPMDPF    table End- 

------------------RF9 : START :IG Table ZMPCPF Values START-------------------------------------------------


    IF (obj_refundBills1.ZPDATATXFLG = 'Y') THEN    
             IF ((TRIM(v_prv_refnum) IS NULL) AND (TRIM(v_prv_policy) IS NULL) ) THEN

              v_prv_refnum  := obj_refundBills2.TRREFNUM;
              v_prv_policy :=obj_refundBills2.CHDRNUM;  

                           obj_zmpcpf.CHDRCOY    := v_company;
                           obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
                           obj_zmpcpf.EFFDATE    := v_effdate;
                           obj_zmpcpf.USRPRF := v_userProfile;
                           obj_zmpcpf.JOBNM  := v_scheduleName;
                           obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
                           obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP'); 
                           obj_zmpcpf.EXTRFLAG := 'T';
                           obj_zmpcpf.ENTITY := obj_refundBills2.CHDRNUM;
                           obj_zmpcpf.KEY := obj_refundBills2.TRREFNUM; -- instb
                           obj_zmpcpf.STATUSTYP := ' ';
                           obj_zmpcpf.ZCTAXRAT   := v_zctaxrat;

              END IF;


	        IF ((TRIM(v_prv_refnum) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum) IS NOT NULL) AND (TRIM(v_prv_policy) IS NOT NULL)) THEN


                           obj_zmpcpf.GPST01     := v_temp_GPST01 * -1;
                           obj_zmpcpf.GPST02     := v_temp_GPST02 * -1;
                           obj_zmpcpf.ZCOLLFEE01 := (v_temp_GPST01 * v_zcolrate / 100) * -1 ;
                           obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01) * -1 ;
                           obj_zmpcpf.ZCTAXAMT   := ROUND(v_collfee01 - obj_zmpcpf.ZCOLLFEE02) * -1;   -- BL6
                           obj_zmpcpf.MCOLFEE := ROUND(obj_zmpcpf.ZCOLLFEE01) * -1 ;
                           obj_zmpcpf.MCOLFCTAX := obj_zmpcpf.ZCTAXAMT;
                           INSERT INTO ZMPCPF VALUES obj_zmpcpf;

                    END IF;

             v_prv_refnum  := obj_refundBills2.TRREFNUM;
             v_prv_policy :=obj_refundBills2.CHDRNUM; 



           --obj_zmpcpf.GPST01     := v_temp_GPST01 * -1; 
           --obj_zmpcpf.GPST02     := v_temp_GPST02 * -1;

          obj_zmpcpf.ZCTAXRAT   := v_zctaxrat;
          obj_zmpcpf.CHDRCOY    := v_company;
          obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
          obj_zmpcpf.EFFDATE    := v_effdate;
          obj_zmpcpf.USRPRF := v_userProfile;
          obj_zmpcpf.JOBNM  := v_scheduleName;
          obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
          obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP'); 
          obj_zmpcpf.EXTRFLAG := 'T';
          obj_zmpcpf.ENTITY := obj_refundBills2.CHDRNUM;
          obj_zmpcpf.KEY := obj_refundBills2.TRREFNUM; 
          obj_zmpcpf.STATUSTYP := ' ';
          v_temp_GPST01     := 0;
          v_temp_GPST02     := 0; 
          v_collfee01       := 0;  
        END IF;        

                IF  ((TRIM(v_prv_refnum) IS NOT NULL) AND  (trim(v_prv_refnum) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy) = TRIM(obj_refundBills2.CHDRNUM)))  THEN


                   v_temp_GPST01     := v_temp_GPST01 + obj_refundBills2.BPREM;
                   v_temp_GPST02     := v_temp_GPST02 + ROUND(obj_refundBills2.BPREM);
                   v_collfee01       :=v_collfee01 + obj_refundBills2.ZCOLLFEE01;

                END IF;

  END IF;                  
-------------------- IG Table ZMPCPF Values END--------------------------      


--      
--      
--      -- insert in  IG Jd1dta.ZMPCPF     table Start- 
--      obj_zmpcpf.CHDRCOY  := v_company; 
--      --RF8 obj_zmpcpf.CHDRNUM  := v_chdrnum1; 
--      obj_zmpcpf.ZAGPTNUM := v_zagptnum; 
--      obj_zmpcpf.EFFDATE  := v_effdate; 
--      --RF8 obj_zmpcpf.MBRNO    := v_mbrno; 
--      --RF8 obj_zmpcpf.PRODTYP  := v_prodtyp; 
--      --RF8 obj_zmpcpf.TRANNO   := temp_trano; 
--      --RF8 obj_zmpcpf.RECNO    := v_recno; 
--      --RF8 obj_zmpcpf.BILLNO   := v_temp_billno; 
--      --RF8 obj_zmpcpf.DPNTNO   := v_dpntno; 
--      obj_zmpcpf.GPST01   := v_bprem * -1; --- RF6
--      obj_zmpcpf.GPST02   := ROUND(v_bprem) * -1; --- RF6
--      --   obj_zmpcpf.ZCOLLFEE01 := v_zcollfee01; 
--      ---   obj_zmpcpf.ZCOLLFEE02 := ROUND(v_zcollfee01); 
--      obj_zmpcpf.ZCOLLFEE01 := (v_bprem * v_zcolrate / 100) * -1; --- RF6
--      --  obj_zmpcpf.ZCOLLFEE02 := ROUND(v_zcollfee01); 
--      obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01) * -1; --- RF6
--      obj_zmpcpf.ZCTAXRAT   := v_zctaxrat; 
--      -- obj_zmpcpf.ZCTAXAMT   := ROUND((v_zcollfee01 - v_zcollfee01 / 1.08));   -- RF5
--      obj_zmpcpf.ZCTAXAMT   := ROUND(v_zcollfee01 - obj_zmpcpf.ZCOLLFEE02) * -1;      -- RF5 --- RF6
--      obj_zmpcpf.USRPRF     := v_userProfile; 
--      obj_zmpcpf.JOBNM      := v_scheduleName; 
--      obj_zmpcpf.DATIME     := sysdate; 
--      ---SIT BUG FIX 
--      obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP'); 
--      --RF8 obj_zmpcpf.RECTYPE  := o_defaultvalues('RECTYPE'); 
--      INSERT INTO ZMPCPF VALUES obj_zmpcpf; 
      --------------------- Insert ZMPCPF values in obj_gbidpf ---------------------------- 


      --------------------- Insert ZMPCPF values in obj_gbidpf END---------------------------- 
      -- insert in  IG Jd1dta.ZMPCPF    table End- 
      -- insert in  IG Jd1dta.ZPCMPF     table Start- 

------------------RF9 : END---------------------------------------------------


------------------RF9 : START : IG Table ZPCMPF insert Values-------------------------------------------------


 IF (obj_refundBills1.ZPDATATXFLG = 'Y') THEN 

 --------START FOR AGENT 1------------------------------------
      IF n_gagnstel01            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
              v_prv_policy_z :=obj_refundBills2.CHDRNUM; 

              obj_zpcmpf01.CHDRCOY    := v_company;
              obj_zpcmpf01.EFFDATE    := v_effdate;
              obj_zpcmpf01.GAGNTSEL   := v_gagntsel01;
              obj_zpcmpf01.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
              obj_zpcmpf01.CMRATE     := v_cmrate01;  
              obj_zpcmpf01.BATCPFX   := v_batcpfx;
              obj_zpcmpf01.BATCCOY   := v_company;
              obj_zpcmpf01.BATCBRN   := v_i_branch;
              obj_zpcmpf01.BATCACTYR := v_acctYear;
              obj_zpcmpf01.BATCACTMN := v_acctMonth;
              obj_zpcmpf01.BATCTRCD  := v_transCode;
              obj_zpcmpf01.BATCBATCH := IgSpaceValue;
              obj_zpcmpf01.USRPRF    := v_userProfile;
              obj_zpcmpf01.JOBNM     := v_scheduleName;
              obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf01.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf01.EXTRFLAG   := 'T';
              obj_zpcmpf01.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf01.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf01.STATUSTYP := ' ';
              obj_zpcmpf01.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf01.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf01.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf01.ZAGTGPRM  := v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf01.ZAGTRPRM  := v_temp_ZAGTGPRM02 * -1;

                    obj_zpcmpf01.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf01.MTOTPREM  := v_temp_GPST  * -1;
                    obj_zpcmpf01.MCOMMN    := v_temp_GPST  * -1;
                    obj_zpcmpf01.MCOMCTAX  := obj_zpcmpf01.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf01;

                    END IF;

             v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
             v_prv_policy_z  :=obj_refundBills2.CHDRNUM; 



              obj_zpcmpf01.CHDRCOY    := v_company;
              obj_zpcmpf01.EFFDATE    := v_effdate;
              obj_zpcmpf01.GAGNTSEL   := v_gagntsel01;
              obj_zpcmpf01.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
              obj_zpcmpf01.CMRATE     := v_cmrate01;  
              obj_zpcmpf01.BATCPFX   := v_batcpfx;
              obj_zpcmpf01.BATCCOY   := v_company;
              obj_zpcmpf01.BATCBRN   := v_i_branch;
              obj_zpcmpf01.BATCACTYR := v_acctYear;
              obj_zpcmpf01.BATCACTMN := v_acctMonth;
              obj_zpcmpf01.BATCTRCD  := v_transCode;
              obj_zpcmpf01.BATCBATCH := IgSpaceValue;
              obj_zpcmpf01.USRPRF    := v_userProfile;
              obj_zpcmpf01.JOBNM     := v_scheduleName;
              obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf01.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf01.EXTRFLAG   := 'T';
              obj_zpcmpf01.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf01.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf01.STATUSTYP := ' ';
              obj_zpcmpf01.NOCOMNFLG := 'N';


              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_refundBills2.CHDRNUM)))  THEN



                                   IF (obj_refundBills2.COMMN01 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN01) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN01) / 1.08) * -1); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_refundBills2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_refundBills2.COMMN01;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_refundBills2.ZAGTGPRM01;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_refundBills2.ZAGTGPRM01);           

                END IF;


      END IF;
----------------------END FOR AGENT -1------------------------------------


--      IF n_gagnstel01            = 1 THEN 
--        obj_zpcmpf01.CHDRCOY    := v_company; 
--        --RF8 obj_zpcmpf01.CHDRNUM    := v_chdrnum1; 
--        obj_zpcmpf01.EFFDATE    := v_effdate; 
--        --RF8 obj_zpcmpf01.PRODTYP    := v_prodtyp; 
--        --RF8 obj_zpcmpf01.ZAGPTNUM   := v_zagptnum; 
--        --RF8 obj_zpcmpf01.HEADCNTIND := v_headcntind; 
--        --RF8 obj_zpcmpf01.MBRNO      := v_mbrno; 
--        --RF8 obj_zpcmpf01.DPNTNO     := v_dpntno; 
--        --RF8 obj_zpcmpf01.BILLNO     := v_temp_billno; 
--        obj_zpcmpf01.GPST       := v_bprem * -1; --- RF6
--        obj_zpcmpf01.GAGNTSEL   := v_gagntsel01; 
--        obj_zpcmpf01.ZINSTYPE   := v_zinstyp; ----? 
--        obj_zpcmpf01.SPLITC     := n_wsaasplitc01; 
--        obj_zpcmpf01.CMRATE     := v_cmrate01; 
--        IF (v_commn01            < 0) THEN 
--          obj_zpcmpf01.COMMN    := ROUND((ABS(v_commn01) / 1.08) * -1); -- ?Logic 
--        ELSE 
--          obj_zpcmpf01.COMMN := ROUND((ABS(v_commn01) / 1.08) * -1); -- ?Logic --- RF6
--        END IF; 
--        -- obj_zpcmpf01.COMMN      := v_commn01; 
--        obj_zpcmpf01.BATCPFX   := v_batcpfx; 
--        obj_zpcmpf01.BATCCOY   := v_company; 
--        obj_zpcmpf01.BATCBRN   := v_i_branch; 
--        obj_zpcmpf01.BATCACTYR := v_acctYear; 
--        obj_zpcmpf01.BATCACTMN := v_acctMonth; 
--        obj_zpcmpf01.BATCTRCD  := v_transCode; 
--        obj_zpcmpf01.BATCBATCH := IgSpaceValue; 
--        --RF8 obj_zpcmpf01.RECNO     := v_recno; 
--        --RF8 obj_zpcmpf01.RECTYPE   := v_rectype; 
--        obj_zpcmpf01.ZAGTGPRM  := v_zagtgprm01 * -1;        -- ?Logic --- RF6
--        obj_zpcmpf01.ZAGTRPRM  := ROUND(v_zagtgprm01) * -1; -- ?Logic --- RF6
--        obj_zpcmpf01.ZCTAXRAT  := v_zctaxrat;          -- ?Logic (No Defalt value) 
--        obj_zpcmpf01.ZCTAXAMT  := ROUND(v_commn01 - obj_zpcmpf01.COMMN) * -1; --- RF6
--        --RF8 obj_zpcmpf01.TRANNO    := temp_trano; 
--        obj_zpcmpf01.USRPRF    := v_userProfile; 
--        obj_zpcmpf01.JOBNM     := v_scheduleName; 
--        obj_zpcmpf01.DATIME    := sysdate; 
--        INSERT INTO ZPCMPF VALUES obj_zpcmpf01; 
        --------------------- Insert ZPCMPF01 values in obj_gbidpf ---------------------------- 


        --------------------- Insert ZPCMPF01 values in obj_gbidpf END---------------------------- 

  -----------------START FOR AGENT -2-------------------

  IF n_gagnstel02            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
              v_prv_policy_z :=obj_refundBills2.CHDRNUM; 

              obj_zpcmpf02.CHDRCOY    := v_company;
              obj_zpcmpf02.EFFDATE    := v_effdate;
              obj_zpcmpf02.GAGNTSEL   := v_gagntsel02;
              obj_zpcmpf02.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
              obj_zpcmpf02.CMRATE     := v_cmrate02;  
              obj_zpcmpf02.BATCPFX   := v_batcpfx;
              obj_zpcmpf02.BATCCOY   := v_company;
              obj_zpcmpf02.BATCBRN   := v_i_branch;
              obj_zpcmpf02.BATCACTYR := v_acctYear;
              obj_zpcmpf02.BATCACTMN := v_acctMonth;
              obj_zpcmpf02.BATCTRCD  := v_transCode;
              obj_zpcmpf02.BATCBATCH := IgSpaceValue;
              obj_zpcmpf02.USRPRF    := v_userProfile;
              obj_zpcmpf02.JOBNM     := v_scheduleName;
              obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf02.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf02.EXTRFLAG   := 'T';
              obj_zpcmpf02.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf02.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf02.STATUSTYP := ' ';
              obj_zpcmpf02.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf02.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf02.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf02.ZAGTGPRM  := v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf02.ZAGTRPRM  := v_temp_ZAGTGPRM02 * -1;

                    obj_zpcmpf02.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf02.MTOTPREM  := v_temp_GPST  * -1;
                    obj_zpcmpf02.MCOMMN    := v_temp_GPST  * -1;
                    obj_zpcmpf02.MCOMCTAX  := obj_zpcmpf02.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf02;

                    END IF;

             v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
             v_prv_policy_z  :=obj_refundBills2.CHDRNUM; 



              obj_zpcmpf02.CHDRCOY    := v_company;
              obj_zpcmpf02.EFFDATE    := v_effdate;
              obj_zpcmpf02.GAGNTSEL   := v_gagntsel02;
              obj_zpcmpf02.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
              obj_zpcmpf02.CMRATE     := v_cmrate02;  
              obj_zpcmpf02.BATCPFX   := v_batcpfx;
              obj_zpcmpf02.BATCCOY   := v_company;
              obj_zpcmpf02.BATCBRN   := v_i_branch;
              obj_zpcmpf02.BATCACTYR := v_acctYear;
              obj_zpcmpf02.BATCACTMN := v_acctMonth;
              obj_zpcmpf02.BATCTRCD  := v_transCode;
              obj_zpcmpf02.BATCBATCH := IgSpaceValue;
              obj_zpcmpf02.USRPRF    := v_userProfile;
              obj_zpcmpf02.JOBNM     := v_scheduleName;
              obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf02.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf02.EXTRFLAG   := 'T';
              obj_zpcmpf02.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf02.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf02.STATUSTYP := ' ';
              obj_zpcmpf02.NOCOMNFLG := 'N';


              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_refundBills2.CHDRNUM)))  THEN



                                   IF (obj_refundBills2.COMMN02 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN02) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN02) / 1.08) * -1); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_refundBills2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_refundBills2.COMMN02;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_refundBills2.ZAGTGPRM02;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_refundBills2.ZAGTGPRM02);           

                END IF;


      END IF;
   -----------------END FOR AGENT -2----------------------------


--      IF n_gagnstel02            = 1 THEN 
--        obj_zpcmpf02.CHDRCOY    := v_company; 
--        --RF8 obj_zpcmpf02.CHDRNUM    := v_chdrnum1; 
--        obj_zpcmpf02.EFFDATE    := v_effdate; 
--        --RF8 obj_zpcmpf02.PRODTYP    := v_prodtyp; 
--        --RF8 obj_zpcmpf02.ZAGPTNUM   := v_zagptnum; 
--        --RF8 obj_zpcmpf02.HEADCNTIND := v_headcntind; 
--        --RF8 obj_zpcmpf02.MBRNO      := v_mbrno; 
--        --RF8 obj_zpcmpf02.DPNTNO     := v_dpntno; 
--        --RF8 obj_zpcmpf02.BILLNO     := v_temp_billno; 
--        obj_zpcmpf02.GPST       := v_bprem * -1; --- RF6
--        obj_zpcmpf02.GAGNTSEL   := v_gagntsel02; 
--        obj_zpcmpf02.ZINSTYPE   := v_zinstyp; ----? 
--        obj_zpcmpf02.SPLITC     := n_wsaasplitc02; 
--        obj_zpcmpf02.CMRATE     := v_cmrate02; 
--        -- obj_zpcmpf02.COMMN      := v_commn02; 
--        IF (v_commn02         < 0) THEN 
--          obj_zpcmpf02.COMMN := ROUND((ABS(v_commn02) / 1.08) * -1); -- ?Logic 
--        ELSE 
--          obj_zpcmpf02.COMMN := ROUND((ABS(v_commn02) / 1.08) * -1); -- ?Logic --- RF6
--        END IF; 
--        obj_zpcmpf02.BATCPFX   := v_batcpfx; 
--        obj_zpcmpf02.BATCCOY   := v_company; 
--        obj_zpcmpf02.BATCBRN   := v_i_branch; 
--        obj_zpcmpf02.BATCACTYR := v_acctYear; 
--        obj_zpcmpf02.BATCACTMN := v_acctMonth; 
--        obj_zpcmpf02.BATCTRCD  := v_transCode; 
--        obj_zpcmpf02.BATCBATCH := IgSpaceValue; 
--        --RF8 obj_zpcmpf02.RECNO     := v_recno; 
--        --RF8 obj_zpcmpf02.RECTYPE   := v_rectype; 
--        obj_zpcmpf02.ZAGTGPRM  := v_zagtgprm02 * -1;        -- ?Logic --- RF6
--        obj_zpcmpf02.ZAGTRPRM  := ROUND(v_zagtgprm02) * -1; -- ?Logic --- RF6
--        obj_zpcmpf02.ZCTAXRAT  := v_zctaxrat;          -- ?Logic (No Defalt value) 
--        obj_zpcmpf02.ZCTAXAMT  := ROUND(v_commn02 - obj_zpcmpf02.COMMN) * -1; --- RF6
--        --RF8 obj_zpcmpf02.TRANNO    := temp_trano; 
--        obj_zpcmpf02.USRPRF    := v_userProfile; 
--        obj_zpcmpf02.JOBNM     := v_scheduleName; 
--        obj_zpcmpf02.DATIME    := sysdate; 
--        INSERT INTO ZPCMPF VALUES obj_zpcmpf02; 
--        --------------------- Insert ZPCMPF02 values in obj_gbidpf ---------------------------- 
--        --------------------- Insert ZPCMPF03 values in obj_gbidpf END---------------------------- 
--      END IF; 

----------------------START FOR AGENT -3-----------------------------

IF n_gagnstel03            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
              v_prv_policy_z :=obj_refundBills2.CHDRNUM; 

              obj_zpcmpf03.CHDRCOY    := v_company;
              obj_zpcmpf03.EFFDATE    := v_effdate;
              obj_zpcmpf03.GAGNTSEL   := v_gagntsel03;
              obj_zpcmpf03.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
              obj_zpcmpf03.CMRATE     := v_cmrate03;  
              obj_zpcmpf03.BATCPFX   := v_batcpfx;
              obj_zpcmpf03.BATCCOY   := v_company;
              obj_zpcmpf03.BATCBRN   := v_i_branch;
              obj_zpcmpf03.BATCACTYR := v_acctYear;
              obj_zpcmpf03.BATCACTMN := v_acctMonth;
              obj_zpcmpf03.BATCTRCD  := v_transCode;
              obj_zpcmpf03.BATCBATCH := IgSpaceValue;
              obj_zpcmpf03.USRPRF    := v_userProfile;
              obj_zpcmpf03.JOBNM     := v_scheduleName;
              obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf03.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf03.EXTRFLAG   := 'T';
              obj_zpcmpf03.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf03.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf03.STATUSTYP := ' ';
              obj_zpcmpf03.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf03.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf03.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf03.ZAGTGPRM  := v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf03.ZAGTRPRM  := v_temp_ZAGTGPRM02 * -1;

                    obj_zpcmpf03.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf03.MTOTPREM  := v_temp_GPST  * -1;
                    obj_zpcmpf03.MCOMMN    := v_temp_GPST  * -1;
                    obj_zpcmpf03.MCOMCTAX  := obj_zpcmpf03.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf03;

                    END IF;

             v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
             v_prv_policy_z  :=obj_refundBills2.CHDRNUM; 



              obj_zpcmpf03.CHDRCOY    := v_company;
              obj_zpcmpf03.EFFDATE    := v_effdate;
              obj_zpcmpf03.GAGNTSEL   := v_gagntsel03;
              obj_zpcmpf03.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
              obj_zpcmpf03.CMRATE     := v_cmrate03;  
              obj_zpcmpf03.BATCPFX   := v_batcpfx;
              obj_zpcmpf03.BATCCOY   := v_company;
              obj_zpcmpf03.BATCBRN   := v_i_branch;
              obj_zpcmpf03.BATCACTYR := v_acctYear;
              obj_zpcmpf03.BATCACTMN := v_acctMonth;
              obj_zpcmpf03.BATCTRCD  := v_transCode;
              obj_zpcmpf03.BATCBATCH := IgSpaceValue;
              obj_zpcmpf03.USRPRF    := v_userProfile;
              obj_zpcmpf03.JOBNM     := v_scheduleName;
              obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf03.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf03.EXTRFLAG   := 'T';
              obj_zpcmpf03.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf03.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf03.STATUSTYP := ' ';
              obj_zpcmpf03.NOCOMNFLG := 'N';


              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_refundBills2.CHDRNUM)))  THEN



                                   IF (obj_refundBills2.COMMN03 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN03) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN03) / 1.08) * -1); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_refundBills2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_refundBills2.COMMN03;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_refundBills2.ZAGTGPRM03;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_refundBills2.ZAGTGPRM03);           

                END IF;


      END IF;

 -----------------------END FOR AGENT -3-------------------------------------------------------     

--      IF n_gagnstel03            = 1 THEN 
--        obj_zpcmpf03.CHDRCOY    := v_company; 
--       --RF8  obj_zpcmpf03.CHDRNUM    := v_chdrnum1; 
--        obj_zpcmpf03.EFFDATE    := v_effdate; 
--        --RF8 obj_zpcmpf03.PRODTYP    := v_prodtyp; 
--        --RF8 obj_zpcmpf03.ZAGPTNUM   := v_zagptnum; 
--        --RF8 obj_zpcmpf03.HEADCNTIND := v_headcntind; 
--        --RF8 obj_zpcmpf03.MBRNO      := v_mbrno; 
--        --RF8 obj_zpcmpf03.DPNTNO     := v_dpntno; 
--        --RF8 obj_zpcmpf03.BILLNO     := v_temp_billno; 
--        obj_zpcmpf03.GPST       := v_bprem * -1; --- RF6
--        obj_zpcmpf03.GAGNTSEL   := v_gagntsel03; 
--        obj_zpcmpf03.ZINSTYPE   := v_zinstyp; ----? 
--        obj_zpcmpf03.SPLITC     := n_wsaasplitc03; 
--        obj_zpcmpf03.CMRATE     := v_cmrate03; 
--        IF (v_commn03            < 0) THEN 
--          obj_zpcmpf03.COMMN    := ROUND((ABS(v_commn03) / 1.08) * -1); -- ?Logic 
--        ELSE 
--          obj_zpcmpf03.COMMN := ROUND((ABS(v_commn03) / 1.08) * -1); -- ?Logic --- RF6
--        END IF; 
--        obj_zpcmpf03.BATCPFX   := v_batcpfx; 
--        obj_zpcmpf03.BATCCOY   := v_company; 
--        obj_zpcmpf03.BATCBRN   := v_i_branch; 
--        obj_zpcmpf03.BATCACTYR := v_acctYear; 
--        obj_zpcmpf03.BATCACTMN := v_acctMonth; 
--        obj_zpcmpf03.BATCTRCD  := v_transCode; 
--        obj_zpcmpf03.BATCBATCH := IgSpaceValue; 
--        --RF8 obj_zpcmpf03.RECNO     := v_recno; 
--        --RF8 obj_zpcmpf03.RECTYPE   := v_rectype; 
--        obj_zpcmpf03.ZAGTGPRM  := v_zagtgprm03 * -1;        -- ?Logic --- RF6
--        obj_zpcmpf03.ZAGTRPRM  := ROUND(v_zagtgprm03) * -1; -- ?Logic --- RF6
--        obj_zpcmpf03.ZCTAXRAT  := v_zctaxrat;          -- ?Logic (No Defalt value) 
--        obj_zpcmpf03.ZCTAXAMT  := ROUND(v_commn03 - obj_zpcmpf03.COMMN) * -1; --- RF6
--        --RF8 obj_zpcmpf03.TRANNO    := temp_trano; 
--        obj_zpcmpf03.USRPRF    := v_userProfile; 
--        obj_zpcmpf03.JOBNM     := v_scheduleName; 
--        obj_zpcmpf03.DATIME    := sysdate; 
--        INSERT INTO ZPCMPF VALUES obj_zpcmpf03; 
--        --------------------- Insert ZPCMPF03 values in obj_gbidpf ---------------------------- 
--        --------------------- Insert ZPCMPF03 values in obj_gbidpf END---------------------------- 
--      END IF; 

--------------------START FOR AGENT 4----------------------------------------

IF n_gagnstel04            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
              v_prv_policy_z :=obj_refundBills2.CHDRNUM; 

              obj_zpcmpf04.CHDRCOY    := v_company;
              obj_zpcmpf04.EFFDATE    := v_effdate;
              obj_zpcmpf04.GAGNTSEL   := v_gagntsel04;
              obj_zpcmpf04.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
              obj_zpcmpf04.CMRATE     := v_cmrate04;  
              obj_zpcmpf04.BATCPFX   := v_batcpfx;
              obj_zpcmpf04.BATCCOY   := v_company;
              obj_zpcmpf04.BATCBRN   := v_i_branch;
              obj_zpcmpf04.BATCACTYR := v_acctYear;
              obj_zpcmpf04.BATCACTMN := v_acctMonth;
              obj_zpcmpf04.BATCTRCD  := v_transCode;
              obj_zpcmpf04.BATCBATCH := IgSpaceValue;
              obj_zpcmpf04.USRPRF    := v_userProfile;
              obj_zpcmpf04.JOBNM     := v_scheduleName;
              obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf04.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf04.EXTRFLAG   := 'T';
              obj_zpcmpf04.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf04.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf04.STATUSTYP := ' ';
              obj_zpcmpf04.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf04.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf04.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf04.ZAGTGPRM  := v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf04.ZAGTRPRM  := v_temp_ZAGTGPRM02 * -1;

                    obj_zpcmpf04.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf04.MTOTPREM  := v_temp_GPST  * -1;
                    obj_zpcmpf04.MCOMMN    := v_temp_GPST  * -1;
                    obj_zpcmpf04.MCOMCTAX  := obj_zpcmpf04.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf04;

                    END IF;

             v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
             v_prv_policy_z  :=obj_refundBills2.CHDRNUM; 



              obj_zpcmpf04.CHDRCOY    := v_company;
              obj_zpcmpf04.EFFDATE    := v_effdate;
              obj_zpcmpf04.GAGNTSEL   := v_gagntsel04;
              obj_zpcmpf04.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
              obj_zpcmpf04.CMRATE     := v_cmrate04;  
              obj_zpcmpf04.BATCPFX   := v_batcpfx;
              obj_zpcmpf04.BATCCOY   := v_company;
              obj_zpcmpf04.BATCBRN   := v_i_branch;
              obj_zpcmpf04.BATCACTYR := v_acctYear;
              obj_zpcmpf04.BATCACTMN := v_acctMonth;
              obj_zpcmpf04.BATCTRCD  := v_transCode;
              obj_zpcmpf04.BATCBATCH := IgSpaceValue;
              obj_zpcmpf04.USRPRF    := v_userProfile;
              obj_zpcmpf04.JOBNM     := v_scheduleName;
              obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf04.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf04.EXTRFLAG   := 'T';
              obj_zpcmpf04.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf04.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf04.STATUSTYP := ' ';
              obj_zpcmpf04.NOCOMNFLG := 'N';


              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_refundBills2.CHDRNUM)))  THEN



                                   IF (obj_refundBills2.COMMN04 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN04) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN04) / 1.08) * -1); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_refundBills2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_refundBills2.COMMN04;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_refundBills2.ZAGTGPRM04;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_refundBills2.ZAGTGPRM04);           

                END IF;


      END IF;

 -----------------------------------END FOR AGENT -4------------------------------------------------------------     

--      IF n_gagnstel04            = 1 THEN 
--        obj_zpcmpf04.CHDRCOY    := v_company; 
--        --RF8 obj_zpcmpf04.CHDRNUM    := v_chdrnum1; 
--        obj_zpcmpf04.EFFDATE    := v_effdate; 
--        --RF8 obj_zpcmpf04.PRODTYP    := v_prodtyp; 
--        --RF8 obj_zpcmpf04.ZAGPTNUM   := v_zagptnum; 
--        --RF8 obj_zpcmpf04.HEADCNTIND := v_headcntind; 
--        --RF8 obj_zpcmpf04.MBRNO      := v_mbrno; 
--        --RF8 obj_zpcmpf04.DPNTNO     := v_dpntno; 
--        --RF8 obj_zpcmpf04.BILLNO     := v_temp_billno; 
--        obj_zpcmpf04.GPST       := v_bprem * -1; --- RF6
--        obj_zpcmpf04.GAGNTSEL   := v_gagntsel04; 
--        obj_zpcmpf04.ZINSTYPE   := v_zinstyp; ----? 
--        obj_zpcmpf04.SPLITC     := n_wsaasplitc04; 
--        obj_zpcmpf04.CMRATE     := v_cmrate04; 
--        IF (v_commn04            < 0) THEN 
--          obj_zpcmpf04.COMMN    := ROUND((ABS(v_commn04) / 1.08) * -1); -- ?Logic 
--        ELSE 
--          obj_zpcmpf04.COMMN := ROUND((ABS(v_commn04) / 1.08) * -1); -- ?Logic --- RF6
--        END IF; 
--        obj_zpcmpf04.BATCPFX   := v_batcpfx; 
--        obj_zpcmpf04.BATCCOY   := v_company; 
--        obj_zpcmpf04.BATCBRN   := v_i_branch; 
--        obj_zpcmpf04.BATCACTYR := v_acctYear; 
--        obj_zpcmpf04.BATCACTMN := v_acctMonth; 
--        obj_zpcmpf04.BATCTRCD  := v_transCode; 
--        obj_zpcmpf04.BATCBATCH := IgSpaceValue; 
--        --RF8 obj_zpcmpf04.RECNO     := v_recno; 
--        --RF8 obj_zpcmpf04.RECTYPE   := v_rectype; 
--        obj_zpcmpf04.ZAGTGPRM  := v_zagtgprm04 * -1;        -- ?Logic --- RF6
--        obj_zpcmpf04.ZAGTRPRM  := ROUND(v_zagtgprm04) * -1; -- ?Logic --- RF6
--        obj_zpcmpf04.ZCTAXRAT  := v_zctaxrat;          -- ?Logic (No Defalt value) 
--        obj_zpcmpf04.ZCTAXAMT  := ROUND(v_commn04 - obj_zpcmpf04.COMMN) * -1; --- RF6
--        --RF8 obj_zpcmpf04.TRANNO    := temp_trano; 
--        obj_zpcmpf04.USRPRF    := v_userProfile; 
--        obj_zpcmpf04.JOBNM     := v_scheduleName; 
--        obj_zpcmpf04.DATIME    := sysdate; 
--        INSERT INTO ZPCMPF VALUES obj_zpcmpf04; 
--        --------------------- Insert ZPCMPF04 values in obj_gbidpf ---------------------------- 
--        --------------------- Insert ZPCMPF04 values in obj_gbidpf END---------------------------- 
--      END IF; 

------------START FOR AGENT -5---------------------------------------

IF n_gagnstel05            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
              v_prv_policy_z :=obj_refundBills2.CHDRNUM; 

              obj_zpcmpf05.CHDRCOY    := v_company;
              obj_zpcmpf05.EFFDATE    := v_effdate;
              obj_zpcmpf05.GAGNTSEL   := v_gagntsel05;
              obj_zpcmpf05.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
              obj_zpcmpf05.CMRATE     := v_cmrate05;  
              obj_zpcmpf05.BATCPFX   := v_batcpfx;
              obj_zpcmpf05.BATCCOY   := v_company;
              obj_zpcmpf05.BATCBRN   := v_i_branch;
              obj_zpcmpf05.BATCACTYR := v_acctYear;
              obj_zpcmpf05.BATCACTMN := v_acctMonth;
              obj_zpcmpf05.BATCTRCD  := v_transCode;
              obj_zpcmpf05.BATCBATCH := IgSpaceValue;
              obj_zpcmpf05.USRPRF    := v_userProfile;
              obj_zpcmpf05.JOBNM     := v_scheduleName;
              obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf05.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf05.EXTRFLAG   := 'T';
              obj_zpcmpf05.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf05.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf05.STATUSTYP := ' ';
              obj_zpcmpf05.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_refundBills2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_refundBills2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf05.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf05.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf05.ZAGTGPRM  := v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf05.ZAGTRPRM  := v_temp_ZAGTGPRM02 * -1;

                    obj_zpcmpf05.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf05.MTOTPREM  := v_temp_GPST  * -1;
                    obj_zpcmpf05.MCOMMN    := v_temp_GPST  * -1;
                    obj_zpcmpf05.MCOMCTAX  := obj_zpcmpf05.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf05;

                    END IF;

             v_prv_refnum_z  := obj_refundBills2.TRREFNUM;
             v_prv_policy_z  :=obj_refundBills2.CHDRNUM; 



              obj_zpcmpf05.CHDRCOY    := v_company;
              obj_zpcmpf05.EFFDATE    := v_effdate;
              obj_zpcmpf05.GAGNTSEL   := v_gagntsel05;
              obj_zpcmpf05.ZINSTYPE   := v_zinstyp;
              obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
              obj_zpcmpf05.CMRATE     := v_cmrate05;  
              obj_zpcmpf05.BATCPFX   := v_batcpfx;
              obj_zpcmpf05.BATCCOY   := v_company;
              obj_zpcmpf05.BATCBRN   := v_i_branch;
              obj_zpcmpf05.BATCACTYR := v_acctYear;
              obj_zpcmpf05.BATCACTMN := v_acctMonth;
              obj_zpcmpf05.BATCTRCD  := v_transCode;
              obj_zpcmpf05.BATCBATCH := IgSpaceValue;
              obj_zpcmpf05.USRPRF    := v_userProfile;
              obj_zpcmpf05.JOBNM     := v_scheduleName;
              obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf05.ZCTAXRAT  := v_zctaxrat;
              obj_zpcmpf05.EXTRFLAG   := 'T';
              obj_zpcmpf05.ENTITY   := obj_refundBills2.CHDRNUM;
              obj_zpcmpf05.KEY   := obj_refundBills2.TRREFNUM;
              obj_zpcmpf05.STATUSTYP := ' ';
              obj_zpcmpf05.NOCOMNFLG := 'N';


              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_refundBills2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_refundBills2.CHDRNUM)))  THEN



                                   IF (obj_refundBills2.COMMN05 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN05) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_refundBills2.COMMN05) / 1.08) * -1); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_refundBills2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_refundBills2.COMMN05;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_refundBills2.ZAGTGPRM05;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_refundBills2.ZAGTGPRM05);           

                END IF;


      END IF;
-----------------------------------END FOR AGENT -5 --------------------------------------


--      IF n_gagnstel05            = 1 THEN 
--        obj_zpcmpf05.CHDRCOY    := v_company; 
--        --RF8 obj_zpcmpf05.CHDRNUM    := v_chdrnum1; 
--        obj_zpcmpf05.EFFDATE    := v_effdate; 
--        --RF8 obj_zpcmpf05.PRODTYP    := v_prodtyp; 
--        --RF8 obj_zpcmpf05.ZAGPTNUM   := v_zagptnum; 
--        --RF8 obj_zpcmpf05.HEADCNTIND := v_headcntind; 
--        --RF8 obj_zpcmpf05.MBRNO      := v_mbrno; 
--        --RF8 obj_zpcmpf05.DPNTNO     := v_dpntno; 
--        --RF8 obj_zpcmpf05.BILLNO     := v_temp_billno; 
--        obj_zpcmpf05.GPST       := v_bprem * -1; --- RF6
--        obj_zpcmpf05.GAGNTSEL   := v_gagntsel05; 
--        obj_zpcmpf05.ZINSTYPE   := v_zinstyp; ----? 
--        obj_zpcmpf05.SPLITC     := n_wsaasplitc05; 
--        obj_zpcmpf05.CMRATE     := v_cmrate05; 
--        IF (v_commn05            < 0) THEN 
--          obj_zpcmpf05.COMMN    := ROUND((ABS(v_commn05) / 1.08) * -1); -- ?Logic 
--        ELSE 
--          obj_zpcmpf05.COMMN := ROUND((ABS(v_commn05) / 1.08) * -1); -- ?Logic --- RF6
--        END IF; 
--        obj_zpcmpf05.BATCPFX   := v_batcpfx; 
--        obj_zpcmpf05.BATCCOY   := v_company; 
--        obj_zpcmpf05.BATCBRN   := v_i_branch; 
--        obj_zpcmpf05.BATCACTYR := v_acctYear; 
--        obj_zpcmpf05.BATCACTMN := v_acctMonth; 
--        obj_zpcmpf05.BATCTRCD  := v_transCode; 
--        obj_zpcmpf05.BATCBATCH := IgSpaceValue; 
--        --RF8 obj_zpcmpf05.RECNO     := v_recno; 
--        --RF8 obj_zpcmpf05.RECTYPE   := v_rectype; 
--        obj_zpcmpf05.ZAGTGPRM  := v_zagtgprm05 * -1;        -- ?Logic --- RF6
--        obj_zpcmpf05.ZAGTRPRM  := ROUND(v_zagtgprm05) * -1; -- ?Logic --- RF6
--        obj_zpcmpf05.ZCTAXRAT  := v_zctaxrat;          -- ?Logic (No Defalt value) 
--        obj_zpcmpf05.ZCTAXAMT  := ROUND(v_commn05 - obj_zpcmpf05.COMMN) * -1; --- RF6
--        --RF8 obj_zpcmpf05.TRANNO    := temp_trano; 
--        obj_zpcmpf05.USRPRF    := v_userProfile; 
--        obj_zpcmpf05.JOBNM     := v_scheduleName; 
--        obj_zpcmpf05.DATIME    := sysdate; 
--        INSERT INTO ZPCMPF VALUES obj_zpcmpf05; 
--        --------------------- Insert ZPCMPF05 values in obj_gbidpf ---------------------------- 
--       END IF;
  END IF;      
END IF;
END LOOP;
---------------------------------RF9: START-----------------------------------------------------------------------------------------
  IF b_isNoError2 = TRUE AND v_zprvaldYN = 'N' THEN
-----------------------INSERTING THE ZMPCPF LAST RECORD START-----------------------------------------------------------------------
     IF (obj_refundBills1.ZPDATATXFLG = 'Y') THEN

                           obj_zmpcpf.CHDRCOY    := v_company;
                           obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
                           obj_zmpcpf.EFFDATE    := v_effdate; 
                           obj_zmpcpf.USRPRF := v_userProfile;
                           obj_zmpcpf.JOBNM  := v_scheduleName;
                           obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
                           obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP'); 
                           obj_zmpcpf.EXTRFLAG := 'T';
                           obj_zmpcpf.ENTITY := obj_refundBills2.CHDRNUM;
                           obj_zmpcpf.KEY := obj_refundBills2.TRREFNUM; 
                           obj_zmpcpf.STATUSTYP := ' ';
                           obj_zmpcpf.ZCTAXRAT   := v_zctaxrat;
                           obj_zmpcpf.GPST01     :=  v_temp_GPST01 * -1;
                           obj_zmpcpf.GPST02     := v_temp_GPST02 * -1;
                           obj_zmpcpf.ZCOLLFEE01 := (v_temp_GPST01 * v_zcolrate / 100) * -1 ;
                           obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01) * -1 ;
                           obj_zmpcpf.ZCTAXAMT   := ROUND(v_collfee01 - obj_zmpcpf.ZCOLLFEE02);   -- BL6
                           obj_zmpcpf.MCOLFEE := ROUND(obj_zmpcpf.ZCOLLFEE01) * -1 ;
                           obj_zmpcpf.MCOLFCTAX := obj_zmpcpf.ZCTAXAMT;
                           INSERT INTO ZMPCPF VALUES obj_zmpcpf;
 ---------------------INSERTING THE ZMPCPF LAST RECORD END---------------------------------------------------------------------------

 -----------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-1 START -----------------------------------------------------------------------
                IF n_gagnstel01            = 1 THEN

                    obj_zpcmpf01.CHDRCOY    := v_company;
                    obj_zpcmpf01.EFFDATE    := v_effdate;
                    obj_zpcmpf01.GAGNTSEL   := v_gagntsel01;
                    obj_zpcmpf01.ZINSTYPE   := v_zinstyp;
                    obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
                    obj_zpcmpf01.CMRATE     := v_cmrate01;   
                    obj_zpcmpf01.BATCPFX   := v_batcpfx;
                    obj_zpcmpf01.BATCCOY   := v_company;
                    obj_zpcmpf01.BATCBRN   := v_i_branch;
                    obj_zpcmpf01.BATCACTYR := v_acctYear;
                    obj_zpcmpf01.BATCACTMN := v_acctMonth;
                    obj_zpcmpf01.BATCTRCD  := v_transCode;
                    obj_zpcmpf01.BATCBATCH := IgSpaceValue;
                    obj_zpcmpf01.USRPRF    := v_userProfile;
                    obj_zpcmpf01.JOBNM     := v_scheduleName;
                    obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf01.ZCTAXRAT  := v_zctaxrat;
                    obj_zpcmpf01.EXTRFLAG   := 'T';
                    obj_zpcmpf01.ENTITY   := obj_refundBills2.CHDRNUM;
                    obj_zpcmpf01.KEY   := obj_refundBills2.TRREFNUM;
                    obj_zpcmpf01.STATUSTYP := ' ';
                    obj_zpcmpf01.NOCOMNFLG := 'N';
                    obj_zpcmpf01.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf01.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf01.ZAGTGPRM  :=  v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf01.ZAGTRPRM  :=  v_temp_ZAGTGPRM02 * -1;
                    obj_zpcmpf01.ZCTAXAMT  :=  ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf01.MTOTPREM  := v_temp_GPST   * -1;
                    obj_zpcmpf01.MCOMMN    := v_temp_GPST   * -1;
                    obj_zpcmpf01.MCOMCTAX  := obj_zpcmpf01.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf01;
               END IF;           
       -----------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-1 END--------------------------------

       -------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-2 START -------------------------
                IF n_gagnstel02            = 1 THEN  

                    obj_zpcmpf02.CHDRCOY    := v_company;
                    obj_zpcmpf02.EFFDATE    := v_effdate;
                    obj_zpcmpf02.GAGNTSEL   := v_gagntsel02;
                    obj_zpcmpf02.ZINSTYPE   := v_zinstyp;
                    obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
                    obj_zpcmpf02.CMRATE     := v_cmrate02;   
                    obj_zpcmpf02.BATCPFX   := v_batcpfx;
                    obj_zpcmpf02.BATCCOY   := v_company;
                    obj_zpcmpf02.BATCBRN   := v_i_branch;
                    obj_zpcmpf02.BATCACTYR := v_acctYear;
                    obj_zpcmpf02.BATCACTMN := v_acctMonth;
                    obj_zpcmpf02.BATCTRCD  := v_transCode;
                    obj_zpcmpf02.BATCBATCH := IgSpaceValue;
                    obj_zpcmpf02.USRPRF    := v_userProfile;
                    obj_zpcmpf02.JOBNM     := v_scheduleName;
                    obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf02.ZCTAXRAT  := v_zctaxrat;
                    obj_zpcmpf02.EXTRFLAG   := 'T';
                    obj_zpcmpf02.ENTITY   := obj_refundBills2.CHDRNUM;
                    obj_zpcmpf02.KEY   := obj_refundBills2.TRREFNUM;
                    obj_zpcmpf02.STATUSTYP := ' ';
                    obj_zpcmpf02.NOCOMNFLG := 'N';
                    obj_zpcmpf02.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf02.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf02.ZAGTGPRM  :=  v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf02.ZAGTRPRM  :=  v_temp_ZAGTGPRM02 * -1;
                    obj_zpcmpf02.ZCTAXAMT  :=  ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf02.MTOTPREM  := v_temp_GPST   * -1;
                    obj_zpcmpf02.MCOMMN    := v_temp_GPST   * -1;
                    obj_zpcmpf02.MCOMCTAX  := obj_zpcmpf02.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf02;
               END IF;                             
     ----------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-2 END-----------------------------------------------

     ------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-3 START ------------------------------------
                IF n_gagnstel03            = 1 THEN  

                    obj_zpcmpf03.CHDRCOY    := v_company;
                    obj_zpcmpf03.EFFDATE    := v_effdate;
                    obj_zpcmpf03.GAGNTSEL   := v_gagntsel03;
                    obj_zpcmpf03.ZINSTYPE   := v_zinstyp;
                    obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
                    obj_zpcmpf03.CMRATE     := v_cmrate03;   
                    obj_zpcmpf03.BATCPFX   := v_batcpfx;
                    obj_zpcmpf03.BATCCOY   := v_company;
                    obj_zpcmpf03.BATCBRN   := v_i_branch;
                    obj_zpcmpf03.BATCACTYR := v_acctYear;
                    obj_zpcmpf03.BATCACTMN := v_acctMonth;
                    obj_zpcmpf03.BATCTRCD  := v_transCode;
                    obj_zpcmpf03.BATCBATCH := IgSpaceValue;
                    obj_zpcmpf03.USRPRF    := v_userProfile;
                    obj_zpcmpf03.JOBNM     := v_scheduleName;
                    obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf03.ZCTAXRAT  := v_zctaxrat;
                    obj_zpcmpf03.EXTRFLAG   := 'T';
                    obj_zpcmpf03.ENTITY   := obj_refundBills2.CHDRNUM;
                    obj_zpcmpf03.KEY   := obj_refundBills2.TRREFNUM;
                    obj_zpcmpf03.STATUSTYP := ' ';
                    obj_zpcmpf03.NOCOMNFLG := 'N';
                    obj_zpcmpf03.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf03.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf03.ZAGTGPRM  :=  v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf03.ZAGTRPRM  :=  v_temp_ZAGTGPRM02 * -1;
                    obj_zpcmpf03.ZCTAXAMT  :=  ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf03.MTOTPREM  := v_temp_GPST   * -1;
                    obj_zpcmpf03.MCOMMN    := v_temp_GPST   * -1;
                    obj_zpcmpf03.MCOMCTAX  := obj_zpcmpf03.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf03;
               END IF;   						  
       --------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-3 END----------------------------------------

       ------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-4 START ---------------------------
                IF n_gagnstel04            = 1 THEN   

                    obj_zpcmpf04.CHDRCOY    := v_company;
                    obj_zpcmpf04.EFFDATE    := v_effdate;
                    obj_zpcmpf04.GAGNTSEL   := v_gagntsel04;
                    obj_zpcmpf04.ZINSTYPE   := v_zinstyp;
                    obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
                    obj_zpcmpf04.CMRATE     := v_cmrate04;   
                    obj_zpcmpf04.BATCPFX   := v_batcpfx;
                    obj_zpcmpf04.BATCCOY   := v_company;
                    obj_zpcmpf04.BATCBRN   := v_i_branch;
                    obj_zpcmpf04.BATCACTYR := v_acctYear;
                    obj_zpcmpf04.BATCACTMN := v_acctMonth;
                    obj_zpcmpf04.BATCTRCD  := v_transCode;
                    obj_zpcmpf04.BATCBATCH := IgSpaceValue;
                    obj_zpcmpf04.USRPRF    := v_userProfile;
                    obj_zpcmpf04.JOBNM     := v_scheduleName;
                    obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf04.ZCTAXRAT  := v_zctaxrat;
                    obj_zpcmpf04.EXTRFLAG   := 'T';
                    obj_zpcmpf04.ENTITY   := obj_refundBills2.CHDRNUM;
                    obj_zpcmpf04.KEY   := obj_refundBills2.TRREFNUM;
                    obj_zpcmpf04.STATUSTYP := ' ';
                    obj_zpcmpf04.NOCOMNFLG := 'N';
                    obj_zpcmpf04.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf04.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf04.ZAGTGPRM  :=  v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf04.ZAGTRPRM  :=  v_temp_ZAGTGPRM02 * -1;
                    obj_zpcmpf04.ZCTAXAMT  :=  ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf04.MTOTPREM  := v_temp_GPST   * -1;
                    obj_zpcmpf04.MCOMMN    := v_temp_GPST   * -1;
                    obj_zpcmpf04.MCOMCTAX  := obj_zpcmpf04.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf04;
               END IF;                             
       ------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-4 END---------------------

       ----------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-5 START -------------
                IF n_gagnstel05            = 1 THEN 

                    obj_zpcmpf05.CHDRCOY    := v_company;
                    obj_zpcmpf05.EFFDATE    := v_effdate;
                    obj_zpcmpf05.GAGNTSEL   := v_gagntsel05;
                    obj_zpcmpf05.ZINSTYPE   := v_zinstyp;
                    obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
                    obj_zpcmpf05.CMRATE     := v_cmrate05;   
                    obj_zpcmpf05.BATCPFX   := v_batcpfx;
                    obj_zpcmpf05.BATCCOY   := v_company;
                    obj_zpcmpf05.BATCBRN   := v_i_branch;
                    obj_zpcmpf05.BATCACTYR := v_acctYear;
                    obj_zpcmpf05.BATCACTMN := v_acctMonth;
                    obj_zpcmpf05.BATCTRCD  := v_transCode;
                    obj_zpcmpf05.BATCBATCH := IgSpaceValue;
                    obj_zpcmpf05.USRPRF    := v_userProfile;
                    obj_zpcmpf05.JOBNM     := v_scheduleName;
                    obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf05.ZCTAXRAT  := v_zctaxrat;
                    obj_zpcmpf05.EXTRFLAG   := 'T';
                    obj_zpcmpf05.ENTITY   := obj_refundBills2.CHDRNUM;
                    obj_zpcmpf05.KEY   := obj_refundBills2.TRREFNUM;
                    obj_zpcmpf05.STATUSTYP := ' ';
                    obj_zpcmpf05.NOCOMNFLG := 'N';
                    obj_zpcmpf05.GPST      := v_temp_GPST  * -1;     
                    obj_zpcmpf05.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf05.ZAGTGPRM  :=  v_temp_ZAGTGPRM01 * -1;
                    obj_zpcmpf05.ZAGTRPRM  :=  v_temp_ZAGTGPRM02 * -1;
                    obj_zpcmpf05.ZCTAXAMT  :=  ROUND(v_temp_COMMN_Stg - v_temp_COMMN) * -1;
                    obj_zpcmpf05.MTOTPREM  := v_temp_GPST   * -1;
                    obj_zpcmpf05.MCOMMN    := v_temp_GPST   * -1;
                    obj_zpcmpf05.MCOMCTAX  := obj_zpcmpf05.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf05;
               END IF;                             
       ----------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-5 END-------------------
  END IF;     
 END IF;
 ---------------------------------RF9: END----------------------------------------------------------------------------------------- 
dbms_output.put_line('Procedure execution time = ' || (dbms_utility.get_time - v_timestart) / 100); 

CLOSE refundBills_cursor2; 
CLOSE refundBills_cursor1; 

END BQ9UX_BL01_REFUNDBL;