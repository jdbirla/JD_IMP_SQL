create or replace PROCEDURE                                      "BQ9SC_MB01_MBRIND" (i_scheduleName   IN VARCHAR2,
                                                         i_scheduleNumber IN VARCHAR2,
                                                         i_zprvaldYN      IN VARCHAR2,
                                                         i_company        IN VARCHAR2,
                                                         i_fsucocompany   IN VARCHAR2,
                                                         i_usrprf         IN VARCHAR2,
                                                         i_branch         IN VARCHAR2,
                                                         i_transCode      IN VARCHAR2,
                                                         i_vrcmtime       IN NUMBER,
                                                         i_vrcmuser       IN NUMBER,
                                                         i_trdt1          IN NUMBER,
                                                         i_acctYear       IN NUMBER,
                                                         i_acctMonth      IN NUMBER,
                                                         i_vrcmTermid     IN VARCHAR2) IS
  /***************************************************************************************************
  * Amenment History: DMMB-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 2804     001   MB2  included checking for inputfile 2 for ploicy not migrated
  * 0501     002   MB3  set values for ZCOLMCLS and ZPLANCLS, read t-table T3684 and get bnkacctyp
                        Change logic to set value of GCHIPF.BTDATENR
  * 0502     003   MB4  Change CRDATE in GCHIPF and set ZPENDDT in GCHPPF
  * 0505     RC    MB5  #7865 - Incorrect fields on ZTIERPF
  * 0507     006   MB6  ITR4 - LOT2 changes
  * 0507     006   MB6  ITR4 - LOT2 changes
  * 0511     JDB   MB7  Changes for data verification 
  * 0512     MPS   MB8  Changes for data verification 
  * 0516     SJ    MB9  Removed validation for TREFNUM and ZCONVINDPOL (now both columns can have value)
  * 0521     JDB   MB10 Add EFFDATE for ztierpf 
  * 0612     MPS   MB11 TRANNO = TRANLUSED 
  * 0625     JDB   MB12 ZIRA ZJNDM-48
  * 0705     SC    MB13 INCORRECT TRANNO FOR MEMBER FILE 2(Z-TRACKER 9564)
  * 0706     SC    MB14 BILLFREQ AND GADJFREQ INCORRECTLY SET AS 00 (Z-TRACKER 9610)
  *                     AND COLUMN NAME "TRANSFERFLG" CHANGED TO "ZPDATATXFLG"
  * 0711     AK    MB15 1) When STATCODE value is changed, corressponding value of DTETRM should also set 
  *                        accordingly (except decline cases - ZTRXSTAT = 'RJ').
  *                        - If Policy is INFORCE, DTETRM should be max-date.
  *                        - If Policy is Cancelled, DTETRM should remain unchanged for value passed from TITDMGMBRINDP1.
  *                     2) ZPOLDATE will remains unchanged, for value passed from TITDMGMBRINDP1.
  * 0729     MPS   MB16 Removed chages for MB12 to get statcode
  * 1009     MPS   MB17 Check of Credit card for Free plan 
  
  ********************************************************************************************************************************/
  /**** MB4 :  MOD : condition change due to new requirement : START ****/
  v_temp_crdate NUMBER(8) DEFAULT 0;
  /**** MB4 :  MOD : condition change due to new requirement : END ****/
  i_text DMLOG.LTEXT%type;
  --timecheck
  v_timestart NUMBER := dbms_utility.get_time;
  ---local Vairables
  v_refnump1          VARCHAR2(8);
  v_refnumpseq        TITDMGMBRINDP1.REFNUM@DMSTAGEDBLINK%type;
  v_seqno1            VARCHAR2(3);
  SEQMBRTMP1          NUMBER(18) default 0;
  SEQMBRTMP2          NUMBER(18) default 0;
  v_seqno             VARCHAR2(1);
  v_seqnoincr         VARCHAR2(3);
  v_isduplicatePAZDRPPF NUMBER(1) DEFAULT 0;
  v_ismasterplmig     NUMBER(1) DEFAULT 0;
  v_isduplicatep2     NUMBER(1) DEFAULT 0;
  --v_iszplancde        NUMBER(1) DEFAULT 0;
  v_iszendcde    NUMBER(1) DEFAULT 0;
  v_iszcmpcode   NUMBER(1) DEFAULT 0;
  v_errorCountp1 NUMBER(1) DEFAULT 0;
  v_errorCountp2 NUMBER(1) DEFAULT 0;
  v_isAnyErrorp1 VARCHAR2(1) DEFAULT 'N';
  v_isAnyErrorp2 VARCHAR2(1) DEFAULT 'N';
  -- v_zdoecrtcountMB NUMBER(1) DEFAULT 0;
  -- v_zdoecrtcountIN NUMBER(1) DEFAULT 0;
  v_GlobalErrorp2 VARCHAR2(1) DEFAULT 'N';
  v_prefix        VARCHAR2(2);
  v_refKeyp1      VARCHAR2(29 CHAR);
  v_refKeyp2      VARCHAR2(33 CHAR);
  v_isdtetrmvalid VARCHAR2(20 CHAR);
  v_iseffdate     VARCHAR2(20 CHAR);
  v_timech01      VARCHAR2(10 CHAR);
  v_timech02      VARCHAR2(10 CHAR);
  v_zigvalue      PAZDCLPF.Zigvalue%type;
  v_template      DFPOPF.TEMPLATE%type;
  v_zcovcmdt      ZESDPF.Zcovcmdt%type;
  obj_dfpopf      DFPOPF%rowtype;
  v_currency      VARCHAR2(3 CHAR);
  v_zagptid       Zcpnpf.Zagptid%type;
  v_admnoper01    ZAGPPF.Admnoper05%type;
  v_gagntsel01    ZAGPPF.Gagntsel05%type;
  v_admnoper02    ZAGPPF.Admnoper05%type;
  v_gagntsel02    ZAGPPF.Gagntsel05%type;
  v_admnoper03    ZAGPPF.Admnoper05%type;
  v_gagntsel03    ZAGPPF.Gagntsel05%type;
  v_admnoper04    ZAGPPF.Admnoper05%type;
  v_gagntsel04    ZAGPPF.Gagntsel05%type;
  v_admnoper05    ZAGPPF.Admnoper05%type;
  v_gagntsel05    ZAGPPF.Gagntsel05%type;
  --v_zinstype       ZSLPPF.zinstype%type;
  v_cltdob        CLNTPF.Cltdob%type;
  v_zenspcd02_1   ZCLEPF.Zenspcd02%type;
  v_zcifcode      ZCLEPF.Zcifcode%type;
  v_bankaccdsc    CLBAPF.Bankaccdsc%type;
  v_bnkactyp      CLBAPF.Bnkactyp%type;
  v_bankkey       CLBAPF.Bankkey%type;
  v_mthto         CLBAPF.Mthto%type := 0;
  v_yearto        CLBAPF.Yearto%type := 0;
  v_temp_crdtcard TITDMGMBRINDP1.CRDTCARD@DMSTAGEDBLINK%type;
  v_trmdate       TITDMGMBRINDP1.ZPOLTDATE@DMSTAGEDBLINK%type; -- MB16
  v_zcrdtype      ZENCTPF.Zcrdtype%type;
  v_polanv        GCHPPF.Polanv%type;
  v_zagptnum      GCHIPF.Zagptnum%type;
  v_zplancls      GCHPPF.Zplancls%type;
  v_zcolmcls      GCHPPf.Zcolmcls%type;
  v_zprmsi        GMHIPF.ZPRMSI %type;
  v_olddta1       GMOVPF.Olddta%type;
  v_newdta1       GMOVPF.Olddta%type;
  v_olddta2       GMOVPF.Olddta%type;
  v_newdta2       GMOVPF.Olddta%type;
  v_olddta3       GMOVPF.Olddta%type;
  v_newdta3       GMOVPF.Olddta%type;
  v_refkey        GMOVPF.Refkey%type;
  i_trdt          NUMBER(6) DEFAULT 0;
  v_isDateValid   VARCHAR2(20 CHAR);
  v_zpolcls       ZCPNPF.zpolcls%type;
  v_zplancls_new  gchppf.zplancls%type;
  --v_constructrefkey       varchar2(4000 char);
  v_btdatenr  gchipf.btdatenr%type;
  v_datconage gmhdpf.AGE%type;
  --v_temprefKeyp2          VARCHAR2(33 CHAR);
  --v_obj_clba clbapf%rowtype;
  v_zclntid  ZENDRPF.Zclntid%type;
  v_zfacthus ZENDRPF.zfacthus%type; -- MB3
    ----- WAVE 2---------
  n_issdate GMHIPF.NOTSFROM%type;
  -----------Unique numbers------------
  v_seq_gchppf gchppf.unique_number%type;
  v_seq_gmhdpf gmhdpf.unique_number%type;
  v_seq_gmhipf gmhipf.unique_number%type;
  v_seq_gxhipf gxhipf.unique_number%type;
  -----------Unique numbers------------
  ----IG tables records---
  obj_gchd   GCHD%rowtype;
  obj_gchppf GCHPPF%rowtype;
  obj_gchipf GCHIPF%rowtype;
  obj_gmhdpf GMHDPF%rowtype;
  obj_gmhipf GMHIPF%rowtype;
  --obj_zmcipf    ZMCIPF%rowtype;
  obj_gxhipf GXHIPF%rowtype;
  obj_gaphpf GAPHPF%rowtype;
  --obj_mtrnpfPN  MTRNPF%rowtype;
  --obj_mtrnpfCA  MTRNPF%rowtype;
  obj_gmovpf1   GMOVPF%rowtype;
  obj_gmovpf2   GMOVPF%rowtype;
  obj_gmovpf3PN GMOVPF%rowtype;
  --obj_gmovpf3CA GMOVPF%rowtype;
  --obj_ztierpf ZTIERPF%rowtype; --ITR3
  obj_zclepf       ZCLEPF%rowtype; --ITR3
  obj_ztierpf      VIEW_DM_ZTIERPF%rowtype; --ITR3
  obj_ztempcovpf1  VIEW_DM_ZTEMPCOVPF%rowtype; --SIT
  obj_ztempcovpf2  VIEW_DM_ZTEMPCOVPF%rowtype; --SIT
  obj_ztemptierpf1 VIEW_DM_ZTEMPTIERPF%rowtype; --SIT
  obj_ztemptierpf2 VIEW_DM_ZTEMPTIERPF%rowtype; --SIT
  obj_zcelinkpf    VIEW_DM_ZCELINKPF%rowtype; --ITR4 CHNAGES
  obj_gpsupf       gpsupf%rowtype;
  obj_getmpol      IG_DM_MASTERPOL%rowtype;
  obj_getclnt      CLNTPF%rowtype;
  ------Constant---------
  /*---------RH-CHANGES---------
   TYPE obj_mbrmig IS RECORD(
   refnum    TITDMGMBRINDp1.refnum@DMSTAGEDBLINK%type,
   mpolnum   TITDMGMBRINDp1.mpolnum@DMSTAGEDBLINK%type,
   statcode  TITDMGMBRINDp1.statcode@DMSTAGEDBLINK%type,
   dtetrm    TITDMGMBRINDp1.dtetrm@DMSTAGEDBLINK%type,
   zplancde  TITDMGMBRINDp1.zplancde@DMSTAGEDBLINK%type,
   ZWAITPEDT TITDMGMBRINDp1.ZWAITPEDT@DMSTAGEDBLINK%type,
   effdate   TITDMGMBRINDp1.effdate@DMSTAGEDBLINK%type);
  TYPE v_array IS TABLE OF obj_mbrmig;
   mbrmigindex integer := 0;
   mbrmig_list v_array;
   ------------RH_CHANGES------------ */
  i_refnum    TITDMGMBRINDp1.refnum@DMSTAGEDBLINK%type;
  i_cnttypind TITDMGMBRINDp1.cnttypind@DMSTAGEDBLINK%type;
  i_mpolnum   TITDMGMBRINDp1.mpolnum@DMSTAGEDBLINK%type;
  i_statcode  TITDMGMBRINDp1.statcode@DMSTAGEDBLINK%type;
  i_dtetrm    TITDMGMBRINDp1.dtetrm@DMSTAGEDBLINK%type;
  i_zplancde  TITDMGMBRINDp1.zplancde@DMSTAGEDBLINK%type;
  i_ZWAITPEDT TITDMGMBRINDp1.ZWAITPEDT@DMSTAGEDBLINK%type;
  i_effdate   TITDMGMBRINDp1.effdate@DMSTAGEDBLINK%type;
  i_zpoltdate TITDMGMBRINDp1.ZPOLTDATE@DMSTAGEDBLINK%type;   --MB16
  i_zpdatatxflag TITDMGMBRINDp1.ZPDATATXFLG@DMSTAGEDBLINK%type;  --MB16
  i_ztrxstat TITDMGMBRINDp1.ZTRXSTAT@DMSTAGEDBLINK%type;   --MB16
  i_trmflag VARCHAR2(1 CHAR);
  ------------RH_CHANGES------------
  C_PREFIX_MEBR CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('MEBR',
                                                             i_company); --'MB'
  C_PREFIX_INDV CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('INDV',
                                                             i_company); --'IN'
  /*  C_PREFIX_MEBR constant varchar2(2) := 'MB';
  C_PREFIX_INDV constant varchar2(2) := 'IN';*/
  C_SPACE        CONSTANT VARCHAR2(1) := ' ';
  C_ZERO         CONSTANT NUMBER := 0;
  C_MAXDATE      CONSTANT VARCHAR2(20 CHAR) := '99999999';
  C_ERRORCOUNTP1 CONSTANT NUMBER := 5;
  C_ERRORCOUNTP2 CONSTANT NUMBER := 5;
  C_Z001         CONSTANT VARCHAR2(4) := 'RQLH';
  /*  RQLH  Z001  Policy already migrated */
  C_Z002 CONSTANT VARCHAR2(4) := 'RQLI';
  /*  RQLI  Z002  Client not yet migrated */
  C_Z003 CONSTANT VARCHAR2(4) := 'RQLJ';
  /*  RQLJ  Z003  Master policy not yet migrated  */
  C_Z004 CONSTANT VARCHAR2(4) := 'RQLK';
  /*  RQLK  Z004  Input file 2 records does not exist */
  C_Z005 CONSTANT VARCHAR2(4) := 'RQLL';
  /*  RQLL  Z005  Sales Channel not in TQ9FW  */
  C_Z006 CONSTANT VARCHAR2(4) := 'RQLM';
  /*  RQLM  Z006  Relation not in T3584 */
  C_Z007 CONSTANT VARCHAR2(4) := 'RQLN';
  /*  RQLN  Z007  Transaction Status not in TQ9FT */
  C_Z008 CONSTANT VARCHAR2(4) := 'RQLO';
  /*  RQLO  Z008  Status Reason not in TQ9FU  */
  C_Z009 CONSTANT VARCHAR2(4) := 'RQLP';
  /*  RQLP  Z009  Sales Plan not valid  */
  C_Z010 CONSTANT VARCHAR2(4) := 'RQLQ';
  /*  RQLQ  Z010  Endorser Code Not valid */
  C_Z011 CONSTANT VARCHAR2(4) := 'RQQ1';
  /*   RQQ1 Z011  Credit Card No/Bank Account No/ Endorser specific code is blank */
  C_Z012 CONSTANT VARCHAR2(4) := 'RQLS';
  /*  RQLS  Z012  Invalid contract type indicator */
  C_Z013 CONSTANT VARCHAR2(4) := 'RQLT';
  /*  RQLT  Z013  Invalid Date  */
  C_Z014 CONSTANT VARCHAR2(4) := 'RQLU';
  /*  RQLU  Z014  Product code not in T9797 */
  C_Z021 CONSTANT VARCHAR2(4) := 'RQM1';
  /*  RQM1  Z021 Campaign Code not valid     */
  C_Z099 CONSTANT VARCHAR2(4) := 'RQO6';
  /*  RQO6  Z099  Duplicate record found  */
  --C_Z075         constant varchar2(4) := 'RQNJ'; /*  RQNJ  Z075  Credit card is mandatory  */
  --C_Z076         constant varchar2(4) := 'RQNK'; /*  RQNK  Z076  PREAUTNO is mandatory */
  --C_Z077         constant varchar2(4) := 'RQNL'; /*  RQNL  Z077  BANKACCNO is mandatory  */
  --C_Z078         constant varchar2(4) := 'RQNM'; /*  RQNM  Z078  ZENDCDE is mandatory  */
  --C_Z079         constant varchar2(4) := 'RQNN'; /*  RQNN  Z079  Invalid ZENSPCD02 */
  --C_Z080         constant varchar2(4) := 'RQNO'; /*  RQNO  Z080  ZENSPCD not in ZCLEPF */
  --C_Z081         constant varchar2(4) := 'RQNP'; /*  RQNP  Z081  GPOLTYPE not set - DFPOPF */
  C_Z082 CONSTANT VARCHAR2(4) := 'RQNQ';
  /*  RQNQ  Z082  REFNUM is mandatory */
  C_Z083 CONSTANT VARCHAR2(4) := 'RQNR';
  /*  RQNR  Z083  GPOLTYPE is mandatory */
  C_Z084 CONSTANT VARCHAR2(4) := 'RQNS';
  /*  RQNS  Z084  Master Pol. is required */
  C_Z085 CONSTANT VARCHAR2(4) := 'RQNT';
  /*  RQNT  Z085  Master Pol. not required  */
  C_Z086 CONSTANT VARCHAR2(4) := 'RQNU';
  /*  RQNU  Z086  ZPOLPERD is mandatory */
  C_Z087 CONSTANT VARCHAR2(4) := 'RQNV';
  /*  RQNV  Z087  CLTRELN is mandatory  */
  C_Z088 CONSTANT VARCHAR2(4) := 'RQNW';
  /*  RQNW  Z088  ZPLANCDE is mandatory */
  C_Z089 CONSTANT VARCHAR2(4) := 'RQNX';
  /*  RQNX  Z089  DTERM not required  */
  C_Z090 CONSTANT VARCHAR2(4) := 'RQNY';
  /*  RQNY  Z090  ZCMPCODE is mandatory */
  C_Z091 CONSTANT VARCHAR2(4) := 'RQNZ';
  /*  RQNZ  Z091  PRODTYP is mandatory  */
  C_Z092 CONSTANT VARCHAR2(4) := 'RQO0';
  /*  RQO0  Z092  HSUMINSU is mandatory */
  C_E315 CONSTANT VARCHAR2(4) := 'E315';
  C_F623 CONSTANT VARCHAR2(4) := 'F623';
  C_S008 CONSTANT VARCHAR2(4) := 'S008';
  --C_RPRD                constant varchar2(4) := 'RPRD';
  --C_F950                constant varchar2(4) := 'F950';
  --C_RPRM                constant varchar2(4) := 'RPRM';
  --C_RFTQ                constant varchar2(4) := 'RFTQ';
  --C_F826                constant varchar2(4) := 'F826';
  --C_W533                constant varchar2(4) := 'W533';
  C_BQ9SC CONSTANT VARCHAR2(5) := 'BQ9SC';
  --C_RPRK                constant varchar2(4) := 'RPRK';
  --C_RPRF                constant varchar2(4) := 'RPRF';
  ----ITR3 Validation error codes:START
  C_Z093 CONSTANT VARCHAR2(4) := 'RQO1';
  /*  ZCONVINDPOL must be blank*/
  C_Z120 CONSTANT VARCHAR2(4) := 'RQOQ';
  /*  ZCONVINDPOL is invalid*/
  C_Z095 CONSTANT VARCHAR2(4) := 'RQO3';
  /*  Old Pol No must be blank */
  C_Z094 CONSTANT VARCHAR2(4) := 'RQO2';
  /*  Invalid Old Policy No.*/
  C_Z121 CONSTANT VARCHAR2(4) := 'RQOR';
  /*  TREFNUM is invalid */
  C_Z096 CONSTANT VARCHAR2(4) := 'RQO4';
  /*  Outside policy period*/
  C_Z097 CONSTANT VARCHAR2(4) := 'RQO5';
  /*  From date > To date*/
  /**** ITR-4_LOT2 : MB6 - MOD : condition change due to new requirement : START ****/
  C_Z028 CONSTANT VARCHAR2(4) := 'E315';
  /*  Must be Y or N*/
  /**** ITR-4_LOT2 : MB6 - MOD : condition change due to new requirement : END ****/
  ----ITR3 Validation error codes:END
  C_TRMPOL              CONSTANT VARCHAR2(2) := '13';
  C_ADDMBR              CONSTANT VARCHAR2(2) := '01';
  C_NEWBZ_ISSUE         CONSTANT VARCHAR2(4) := 'T903';
  C_ISS_TERM            CONSTANT VARCHAR2(4) := 'T913';
  C_BIGDECIMAL_DEFAULT  CONSTANT NUMBER := 0.00;
  C_BIGDECIMAL_DEFAULT1 CONSTANT NUMBER := 0.000;
  C_RECORDSKIPPED       CONSTANT VARCHAR2(17) := 'Record skipped';
  C_RECORDSUCCESS       CONSTANT VARCHAR2(20) := 'Record successful';
  C_SUCCESS             CONSTANT VARCHAR2(3) := 'S';
  C_ERROR               CONSTANT VARCHAR2(3) := 'E';
  --  C_RECSKIPPEDUPDATE    constant varchar2(17) := '''Record skipped''';
  --C_SUCCESS             constant varchar2(3) := '''S''';
  -- C_ERROR               constant varchar2(3) := '''E''';
  C_FUNCDEADDMBR   CONSTANT VARCHAR2(5) := '04000';
  C_FUNCDEADDMBRPP CONSTANT VARCHAR2(5) := '05000';
  C_FUNCDETRMBR    CONSTANT VARCHAR2(5) := '04021';
  C_FUNCDETRMBRPP  CONSTANT VARCHAR2(5) := '05021';
  --TITDMGMBRINDP1
  CURSOR cur_mbr_ind_p1 IS
    SELECT *
      FROM TITDMGMBRINDP1@DMSTAGEDBLINK
     ORDER BY LPAD(refnum, 15, '0') ASC;
  --where TRIM(refnum) = '03671288000';
  /* select *
  from (select *
  from TITDMGMBRINDP1@DMSTAGEDBLINK
  order by TO_NUMBER(refnum) asc)
  where rownum < 10; */
  obj_mbrindp1 cur_mbr_ind_p1%rowtype;
  --TITDMGMBRINDP2
  /*CURSOR cur_mbr_ind_p2(p1refnum TITDMGMBRINDP1.REFNUM@DMSTAGEDBLINK%type) IS
  SELECT *
  FROM TITDMGMBRINDP2@DMSTAGEDBLINK
  where TRIM(refnum) = p1refnum;*/
  /*CURSOR cur_mbr_ind_p2 IS
  SELECT *
  FROM TITDMGMBRINDP2@DMSTAGEDBLINK
  order by LPAD(refnum, 15, '0') asc; */
  CURSOR cur_mbr_ind_p2 IS
    SELECT A.*, B.CHDRNUM AS CHDRNUM_B
      FROM TITDMGMBRINDP2@DMSTAGEDBLINK A
      LEFT OUTER JOIN Jd1dta.PAZDRPPF B
        ON SUBSTR(A.refnum, 1, 8) = TRIM(B.CHDRNUM)
     ORDER BY LPAD(A.refnum, 15, '0') ASC;
  -- where TRIM(refnum) = p1refnum;
  --obj_mbrindp2 TITDMGMBRINDP2@DMSTAGEDBLINK%rowtype;
  obj_mbrindp2 cur_mbr_ind_p2%rowtype;
  --------------Common Function Start---------
  --v_tablecnt      NUMBER(1) := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableNameMB   VARCHAR2(10);
  v_tableNameIN   VARCHAR2(10);
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  --itemexist       pkg_dm_common_operations.itemschec;
  itemexist         pkg_common_dmmb.itemschec;
  o_errortext       pkg_dm_common_operations.errordesc;
  i_zdoe_infop1     pkg_dm_common_operations.obj_zdoe;
  i_zdoe_infop2     pkg_dm_common_operations.obj_zdoe;
  i_zdoe_err_infop2 pkg_dm_common_operations.obj_zdoe;
  -- checkrefnum       pkg_common_dmmb.refnumtype;
  getzigvalue  pkg_common_dmmb.zigvaluetype;
  checksalplan pkg_common_dmmb.salplantype;
  getzinstype  pkg_common_dmmb.zinstype;
  getdfpo      pkg_common_dmmb.dfpopftype;
  getclba      pkg_common_dmmb.clbatype;
  checkchdrnum pkg_common_dmmb.gchdtype;
  zendcde      pkg_common_dmmb.checkzendcde;
  campcode     pkg_common_dmmb.checkcampcode;
  getmpol      pkg_common_dmmb.mpoltype;
  getclntinfo  pkg_common_dmmb.clntpftype;
  checkpoldup  pkg_common_dmmb.polduplicatetype;
  clntdob      pkg_common_dmmb.getclntdob;
  facthouse    pkg_common_dmmb.zendfacthouse; -- MB3
  -----------RH:Changes-----------
  mbrp1info pkg_common_dmmb.mbrinfotype;
  -----------RH:Changes-----------
  -- getpolanv pkg_common_dmmb.plolanvtype;
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercodep1 ercode_tab;
  t_ercodep2 ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfieldp1 errorfield_tab;
  t_errorfieldp2 errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsgp1 errormsg_tab;
  t_errormsgp2 errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldvalp1 errorfieldvalue_tab;
  t_errorfieldvalp2 errorfieldvalue_tab;
  type errorprofram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorprogramp1 errorprofram_tab;
  t_errorprogramp2 errorprofram_tab;
  TYPE obj_zdoe IS RECORD(
    i_tablecnt       NUMBER(1),
    i_tableName      VARCHAR2(10),
    i_refKey         zdoepf.zrefkey%type,
    i_zfilename      zdoepf.zfilenme%type,
    i_indic          zdoepf.indic%type,
    i_prefix         VARCHAR2(2),
    i_scheduleno     zdoepf.jobnum%type,
    i_error01        zdoepf.eror01%type,
    i_errormsg01     zdoepf.errmess01%type,
    i_errorfield01   zdoepf.erorfld01%type,
    i_fieldvalue01   zdoepf.fldvalu01%type,
    i_errorprogram01 zdoepf.erorprog01%type);
  obj_error obj_zdoe;
  ---------------Common function end-----------
  --v_faltu VARCHAR2(1) DEFAULT 'N';
  idx PLS_INTEGER;
  TYPE error_type IS TABLE OF obj_zdoe;
  error_list error_type := error_type();
  errindex   INTEGER := 0;
  TYPE gxhipg_type IS TABLE OF GXHIPF%rowtype;
  gxhipg_list gxhipg_type := gxhipg_type();
  gxhipfindex INTEGER := 0;
  TYPE gmovpf3PN_type IS TABLE OF GMOVPF%rowtype;
  gmovpf3PN_list gmovpf3PN_type := gmovpf3PN_type();
  gmovpf3PNindex INTEGER := 0;
  /*TYPE gmovpf3CA_type IS TABLE of gmovpf%rowtype;
  gmovpf3CA_list gmovpf3CA_type := gmovpf3CA_type();
  gmovpf3CAindex integer := 0;*/
  TYPE gaphpf_type IS TABLE OF gaphpf%rowtype;
  gaphpf_list gaphpf_type := gaphpf_type();
  gaphpfindex INTEGER := 0;
  /* TYPE mtrnpfCA_type IS TABLE of mtrnpf%rowtype;
  mtrnpfCA_list mtrnpfCA_type := mtrnpfCA_type();
  mtrnpfCAindex integer := 0;
  TYPE mtrnpfPN_type IS TABLE of mtrnpf%rowtype;
  mtrnpfPN_list mtrnpfPN_type := mtrnpfPN_type();
  mtrnpfPNindex integer := 0;*/
  TYPE ztierpf_type IS TABLE OF VIEW_DM_ZTIERPF%rowtype;
  ztierpf_list ztierpf_type := ztierpf_type();
  ztierpfindex INTEGER := 0;
  TYPE ztempcovpf1_type IS TABLE OF VIEW_DM_ZTEMPCOVPF%rowtype;
  ztempcovpf1_list ztempcovpf1_type := ztempcovpf1_type();
  ztempcovpf1index INTEGER := 0;
  TYPE ztempcovpf2_type IS TABLE OF VIEW_DM_ZTEMPCOVPF%rowtype;
  ztempcovpf2_list ztempcovpf2_type := ztempcovpf2_type();
  ztempcovpf2index INTEGER := 0;
  TYPE ztemptierpf1_type IS TABLE OF VIEW_DM_ZTEMPTIERPF%rowtype;
  ztemptierpf1_list ztemptierpf1_type := ztemptierpf1_type();
  ztemptierpf1index INTEGER := 0;
  TYPE ztemptierpf2_type IS TABLE OF VIEW_DM_ZTEMPTIERPF%rowtype;
  ztemptierpf2_list ztemptierpf2_type := ztemptierpf2_type();
  ztemptierpf2index INTEGER := 0;

  ----------------
  v_insendate gchi.INSENDTE%type; --MB12
  v_BUSDATE   busdpf.busdate%type; --MB12
  --MB16 TYPE checkstat IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50); --MB12
  --MB16 a_checkpolst checkstat;
  --MB16 b_checkpolst checkstat;
BEGIN
  /*DBMS_PROFILER.start_profiler('DM MBR NEW-5  ' ||
  TO_CHAR(SYSDATE, 'YYYYMMDD HH24:MI:SS'));*/
  SELECT BUSDATE
    INTO v_BUSDATE
    FROM busdpf
   WHERE TRIM(company) = TRIM(i_company); --MB12 : BUSDATE
  --------Master plocies loading----------
  DELETE FROM IG_DM_MASTERPOL;
  INSERT INTO IG_DM_MASTERPOL
    SELECT DISTINCT (a.CHDRNUM),
                    b.ZPLANCLS,
                    b.Zcolmcls,
                    b.POLANV,
                    c.ZAGPTNUM
      FROM gchd a, GCHPPF b, GCHIPF c
     WHERE TRIm(a.CHDRNUM) = TRIm(b.CHDRNUM)
       AND TRIm(a.CHDRNUM) = TRIm(c.CHDRNUM)
       AND TRIm(a.CHDRNUM) = TRIm(a.MPLNUM);
  ----------------------
  ---------Common Function Calling---------
  pkg_common_dmmb.getmpolinfo(getmpol => getmpol);

											
											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9SC,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMMB',
                                        o_errortext   => o_errortext);
  pkg_common_dmmb.getitemvalue(itemexist => itemexist);
  --pkg_common_dmmb.checkrefnum(checkrefnum =>   );
  pkg_common_dmmb.getzigvalue(getzigvalue => getzigvalue);
  pkg_common_dmmb.checksalplan(checksalplan => checksalplan);
  pkg_common_dmmb.getzinstype(getzinstype => getzinstype);
  pkg_common_dmmb.getdfpo(getdfpo => getdfpo);
  pkg_common_dmmb.getclba(getclba => getclba);
  --pkg_common_dmmb.checkpolicy(checkchdrnum => checkchdrnum);
  pkg_common_dmmb.checkendorser(zendcde => zendcde);
  pkg_common_dmmb.checkcampcde(campcode => campcode);
  -- pkg_common_dmmb.getclientinfo(getclntinfo => getclntinfo);
  pkg_common_dmmb.checkpoldup(checkpoldup => checkpoldup);
  pkg_common_dmmb.checkclntdob(clntdob => clntdob);
  --  pkg_common_dmmb.getpolanv(getpolanv => getpolanv);
  pkg_common_dmmb.getmbrp1info(mbrp1info => mbrp1info);
  pkg_common_dmmb.getfacthouse(facthouse => facthouse); -- MB3
  ---------Common Function Calling------------
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX_MEBR) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableNameMB   := TRIM(v_tableNametemp);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX_INDV) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableNameIN   := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableNameMB);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableNameIN);
  /*SELECT COUNT(*)
  INTO v_zdoecrtcountMB
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableNameMB;
  SELECT COUNT(*)
  INTO v_zdoecrtcountIN
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableNameIN;
  */
  i_trdt := SUBSTR(i_trdt1, 3, 6);
  OPEN cur_mbr_ind_p1;
  <<skipRecord>>
  LOOP
    FETCH cur_mbr_ind_p1
      INTO obj_mbrindp1;
    EXIT WHEN cur_mbr_ind_p1%notfound;
    IF TRIM(obj_mbrindp1.cnttypind) = 'I' THEN
      v_prefix := C_PREFIX_INDV;
    ELSE
      v_prefix := C_PREFIX_MEBR;
    END IF;
    v_refKeyp1   := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
    v_refnump1   := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
    v_refnumpseq := TRIM(obj_mbrindp1.refnum);
    v_seqno1     := SUBSTR(TRIM(obj_mbrindp1.refnum), 9, 3);
    v_seqnoincr  := v_seqno1 + 1;
    v_seqno      := 1;
    i_trmflag    := 'N';
    ----------Initialization-------
    i_zdoe_infop1              := NULL;
    i_zdoe_infop1.i_zfilename  := 'TITDMGMBRINDP1';
    i_zdoe_infop1.i_prefix     := v_prefix;
    i_zdoe_infop1.i_scheduleno := i_scheduleNumber;
    i_zdoe_infop1.i_refKey     := TRIM(v_refKeyp1);
    IF (TRIM(v_prefix) = 'MB') THEN
      i_zdoe_infop1.i_tableName := v_tableNameMB;
    ELSE
      i_zdoe_infop1.i_tableName := v_tableNameIN;
    END IF;
    --  v_tablecnt := 1;
    v_isAnyErrorp1 := 'N';
    v_errorCountp1 := 0;
    t_ercodep1(1) := NULL;
    t_ercodep1(2) := NULL;
    t_ercodep1(3) := NULL;
    t_ercodep1(4) := NULL;
    t_ercodep1(5) := NULL;
    errindex := 0;
    gxhipfindex := 0;
    gmovpf3PNindex := 0;
    -- gmovpf3CAindex := 0;
    gaphpfindex := 0;
    --mtrnpfCAindex := 0;
    --mtrnpfPNindex := 0;
    ztierpfindex      := 0;
    ztempcovpf1index  := 0;
    ztempcovpf2index  := 0;
    ztemptierpf1index := 0;
    ztemptierpf2index := 0;
    --  error_list  := error_type();
    gxhipg_list    := gxhipg_type();
    gmovpf3PN_list := gmovpf3PN_type();
    --gmovpf3CA_list := gmovpf3CA_type();
    gaphpf_list := gaphpf_type();
    --mtrnpfCA_list  := mtrnpfCA_type();
    --mtrnpfPN_list  := mtrnpfPN_type();
    ztierpf_list      := ztierpf_type();
    ztempcovpf1_list  := ztempcovpf1_type();
    ztempcovpf2_list  := ztempcovpf2_type();
    ztemptierpf1_list := ztemptierpf1_type();
    ztemptierpf2_list := ztemptierpf2_type();
    v_zprmsi          := 0;
    ----------Initialization -------
    --dbms_output.put_line('TRIM(v_refnump1)==>' || TRIM(v_refnump1));
    /**** MB4 :  MOD : condition change due to new requirement : START ****/
    v_temp_crdate := 0;
    SELECT to_number(TO_CHAR(to_date(obj_mbrindp1.crdate, 'yyyymmdd') - 1,
                             'yyyymmdd'))
      INTO v_temp_crdate
      FROM dual;

    SELECT SEQTMP.nextval INTO SEQMBRTMP1 from dual;
    --   dbms_output.put_line(obj_mbrindp1.crdate  || '   ' || v_temp_crdate );
    /**** MB4 :  MOD : condition change due to new requirement : END ****/
    ---------------First part of validation -TITDMGMBRINDP1----------------------------------------
    --- MB12 : MOD : Change for state code based on termination conditions : start
    ---IF zpoltdate and dtetrm = MAX DATE
    --- MB16 START --
    IF (TRIM(obj_mbrindp1.ZTRXSTAT)) <> 'RJ' THEN        
        v_trmdate := C_MAXDATE;
        IF  (TRIM(obj_mbrindp1.zpoltdate) <> C_MAXDATE) 
        AND (TRIM(obj_mbrindp1.zpoltdate) IS NOT NULL) THEN
            v_trmdate := obj_mbrindp1.zpoltdate;
        END IF;   

        IF  (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE)
        AND (TRIM(obj_mbrindp1.dtetrm) IS NOT NULL) THEN
            v_trmdate := obj_mbrindp1.dtetrm;
        END IF;
        dbms_output.put_line('CHDRNUM ' || obj_mbrindp1.refnum);
        dbms_output.put_line('ZDTETRM ' || v_trmdate);

        IF  (v_trmdate <> C_MAXDATE) AND (TRIM(obj_mbrindp1.ZPDATATXFLG) = 'Y') THEN
        dbms_output.put_line('Mig Date ' || v_BUSDATE);

            IF  (v_trmdate >= v_BUSDATE) THEN
                obj_mbrindp1.STATCODE := 'IF';           
                obj_mbrindp1.zpoltdate := v_trmdate;
                obj_mbrindp1.dtetrm := C_MAXDATE;
            END IF;
            IF  (v_trmdate < v_BUSDATE) THEN
                obj_mbrindp1.STATCODE := 'CA';           
                obj_mbrindp1.zpoltdate := C_MAXDATE;
                obj_mbrindp1.dtetrm := v_trmdate;
            END IF;
        END IF;
        dbms_output.put_line('OUT Date ' || v_BUSDATE);
        IF  (v_trmdate <> C_MAXDATE) 
        AND ((TRIM(obj_mbrindp1.ZPDATATXFLG) <> 'Y') OR (TRIM(obj_mbrindp1.ZPDATATXFLG) IS NULL)) THEN
        dbms_output.put_line('Mig Date 2' || v_BUSDATE);
            obj_mbrindp1.STATCODE := 'IF';           
            obj_mbrindp1.zpoltdate := v_trmdate;
            obj_mbrindp1.dtetrm := C_MAXDATE;
        END IF;
    END IF;


   -- IF ((TRIM(obj_mbrindp1.zpoltdate) = C_MAXDATE) AND
   --    (TRIM(obj_mbrindp1.dtetrm) = C_MAXDATE)) THEN
   --      obj_mbrindp1.STATCODE := obj_mbrindp1.statcode;
   -- END IF;
   -- IF ((TRIM(obj_mbrindp1.zpoltdate) <> C_MAXDATE) OR
   --    (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE)) THEN
   --  IF (TRIM(obj_mbrindp1.ZTRXSTAT)) <> 'RJ' THEN  --MB15 -- IF_starts (STATCODE should not be reset for Decilned polices)       
      ----for zpoltdate != MAX Date
    --  IF ((TRIM(obj_mbrindp1.zpoltdate) IS NOT NULL) AND
    --     (TRIM(obj_mbrindp1.zpoltdate) != 0) AND
    --     (TRIM(obj_mbrindp1.zpoltdate) <> C_MAXDATE)) THEN
      ----Condition TRANSFERFLG(ZPDATATXFLG) = 'Y'
    --    IF (TRIM(obj_mbrindp1.ZPDATATXFLG) = 'Y') THEN ---MB14
    --      IF (v_BUSDATE <= obj_mbrindp1.zpoltdate) THEN
    --        obj_mbrindp1.STATCODE := 'IF';
    --        obj_mbrindp1.dtetrm := C_MAXDATE; -- MB15
    --      END IF;
    --      IF (obj_mbrindp1.zpoltdate < v_BUSDATE) THEN
    --        obj_mbrindp1.STATCODE := 'CA';
    --        obj_mbrindp1.dtetrm := obj_mbrindp1.zpoltdate; --MB15
    --      END IF;
    --    ELSE
          ----Condition TRANSFERFLG(ZPDATATXFLG) != 'Y'
    --      obj_mbrindp1.STATCODE := 'IF';
    --      obj_mbrindp1.dtetrm := C_MAXDATE; -- MB15
    --    END IF;
    --  END IF;
      ----for dtetrm != MAX Date
    --  IF ((TRIM(obj_mbrindp1.dtetrm) IS NOT NULL) AND
    --     (TRIM(obj_mbrindp1.dtetrm) != 0) AND
    --     (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE)) THEN
        ----Condition TRANSFERFLG(ZPDATATXFLG) = 'Y'
    --    IF (TRIM(obj_mbrindp1.ZPDATATXFLG) = 'Y') THEN ---MB14
    --      IF (v_BUSDATE <= obj_mbrindp1.dtetrm) THEN
    --        obj_mbrindp1.STATCODE := 'IF';           
    --        obj_mbrindp1.zpoltdate := obj_mbrindp1.dtetrm; -- MB15
    --        obj_mbrindp1.dtetrm := C_MAXDATE; -- MB15
    --      END IF;
    --      IF (obj_mbrindp1.dtetrm < v_BUSDATE) THEN
    --        obj_mbrindp1.STATCODE := 'CA';
    --      END IF;
    --    ELSE
          ----Condition TRANSFERFLG(ZPDATATXFLG) != 'Y'
     --     obj_mbrindp1.STATCODE := 'IF';
     --     obj_mbrindp1.dtetrm := C_MAXDATE; -- MB15
    --    END IF;
    --  END IF;
    -- END IF; -- MB15 -- IF_ends
    --END IF;
    /*dbms_output.put_line('TRIM(v_refnump1)==>' || TRIM(v_refnump1) ||
    'obj_mbrindp1.STATCODE=> ' ||
    obj_mbrindp1.STATCODE);*/

    --MB16 a_checkpolst(TRIM(obj_mbrindp1.refnum)) := obj_mbrindp1.STATCODE;
    --MB16 i_statcode := a_checkpolst(TRIM(obj_mbrindp1.refnum));
    --MB16 b_checkpolst := a_checkpolst;
    --- MB16 END --
    --- MB12 : MOD : Change for state code based on termination conditions : END

    ---REFNUM NULL VALIDATION
    IF TRIM(v_refnump1) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z082;
      t_errorfieldp1(v_errorCountp1) := 'REFNUM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z082);
      t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      GOTO insertzdoep1;
    ELSE
      ---Check for duplicate record IN PAZDRPPF
      /*    select count(RECIDXPOLICY)
      into v_isduplicatePAZDRPPF
      FROM Jd1dta.PAZDRPPF
      WHERE RTRIM(CHDRNUM) = TRIM(v_refnump1);*/
      IF (checkpoldup.exists(TRIM(v_refnump1))) THEN
        --  IF v_isduplicatePAZDRPPF > 0 THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z001;
        t_errorfieldp1(v_errorCountp1) := 'REFNUM';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z001);
        t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        GOTO insertzdoep1;
      END IF;
      --Check for exist record IN PAZDCLPF
      /*   SELECT COUNT(*) OVER(), r.zigvalue
      into v_isexistzdclpf, v_zigvalue
      FROM Jd1dta.ZDCLPF_TEST r
      WHERE TRIM(ZENTITY) = TRIM(v_refnump1);*/
      /* SELECT COUNT(*) OVER(), r.zigvalue
      into v_isexistzdclpf, v_zigvalue
      FROM Jd1dta.PAZDCLPF r
      WHERE TRIM(ZENTITY) = TRIM(v_refnump1);*/
      IF NOT (getzigvalue.exists(TRIM(v_refnump1))) THEN
        -- IF v_isexistzdclpf < 1 THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z002;
        t_errorfieldp1(v_errorCountp1) := 'REFNUM';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z002);
        t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      ELSE
        v_zigvalue := getzigvalue(TRIM(v_refnump1));
      END IF;
      ---Check for exist record IN TITDMGMBRINDP2
      /*    SELECT COUNT(*)
      INTO v_isexsittitdmgmbrindp2
      FROM STAGEDBUSR.TITDMGMBRINDP2
      WHERE TRIM(REFNUM) = TRIM(v_refnump1);*/
      /*   IF NOT (checkrefnum.exists(TRIM(v_refnumpseq))) THEN
      -- IF v_isexsittitdmgmbrindp2 < 1 THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z004;
      t_errorfieldp1(v_errorCountp1) := 'REFNUM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z004);
      t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnumpseq);
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
      GOTO insertzdoep1;
      END IF;
      --    END IF;
      END IF;*/
    END IF;
    --GPOLTYPE null validation
    IF TRIM(obj_mbrindp1.gpoltype) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z083;
      t_errorfieldp1(v_errorCountp1) := 'GPOLTYPE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z083);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.gpoltype;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    --ZENDCDE null validation
    IF TRIM(obj_mbrindp1.zendcde) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z084;
      t_errorfieldp1(v_errorCountp1) := 'ZENDCDE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z084);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zendcde;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    --ZCMPCODE null validation
    IF TRIM(obj_mbrindp1.zcmpcode) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z090;
      t_errorfieldp1(v_errorCountp1) := 'ZCMPCODE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z090);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zcmpcode;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    --MPOLNUM  null validation
    IF obj_mbrindp1.cnttypind = 'M' THEN
      IF TRIM(obj_mbrindp1.MPOLNUM) IS NULL THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z084;
        t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z084);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.MPOLNUM;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --MPOLNUM  is not null validation
    IF TRIM(obj_mbrindp1.cnttypind) <> 'M' THEN
      IF TRIM(obj_mbrindp1.MPOLNUM) IS NOT NULL THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z085;
        t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z085);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.MPOLNUM;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---ZPOLPERD null validation
    IF TRIM(obj_mbrindp1.zpolperd) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z086;
      t_errorfieldp1(v_errorCountp1) := 'ZPOLPERD';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z086);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zpolperd;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZMARGNFLG Value must be either ?Y? or ?N?
    IF (TRIM(obj_mbrindp1.zmargnflg) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.zmargnflg) <> 'Y') AND
       (TRIM(obj_mbrindp1.zmargnflg) <> 'N'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_E315;
      t_errorfieldp1(v_errorCountp1) := 'ZMARGNFLG';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_E315);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zmargnflg;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZDFCNCY Value must be either ?Y? or ?N?
    IF (TRIM(obj_mbrindp1.zdfcncy) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.zdfcncy) <> 'Y') AND
       (TRIM(obj_mbrindp1.zdfcncy) <> 'N'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_E315;
      t_errorfieldp1(v_errorCountp1) := 'ZDFCNCY';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_E315);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zdfcncy;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZSOLCTFLG Value must be either ?Y? or ?N?
    IF (TRIM(obj_mbrindp1.zsolctflg) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.zsolctflg) <> 'Y') AND
       (TRIM(obj_mbrindp1.zsolctflg) <> 'N'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_E315;
      t_errorfieldp1(v_errorCountp1) := 'ZSOLCTFLG';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_E315);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zsolctflg;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---CLTRELN null validation
    IF TRIM(obj_mbrindp1.cltreln) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z087;
      t_errorfieldp1(v_errorCountp1) := 'CLTRELN';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z087);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.cltreln;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ZPLANCDE null validation
    IF TRIM(obj_mbrindp1.zplancde) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z088;
      t_errorfieldp1(v_errorCountp1) := 'ZPLANCDE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z088);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zplancde;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZDCLITEM01 Value must be either ?Y? or ?N?
    IF (TRIM(obj_mbrindp1.zdclitem01) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.zdclitem01) <> 'Y') AND
       (TRIM(obj_mbrindp1.zdclitem01) <> 'N'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_E315;
      t_errorfieldp1(v_errorCountp1) := 'ZDCLITEM01';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_E315);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zdclitem01;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZDCLITEM02 Value must be either ?Y? or ?N?
    IF (TRIM(obj_mbrindp1.zdclitem02) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.zdclitem02) <> 'Y') AND
       (TRIM(obj_mbrindp1.zdclitem02) <> 'N'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_E315;
      t_errorfieldp1(v_errorCountp1) := 'ZDCLITEM02';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_E315);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zdclitem01;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----DTETRM Validation 1
    v_isdtetrmvalid := VALIDATE_DATE(TRIM(obj_mbrindp1.dtetrm));
    IF ((TRIM(obj_mbrindp1.statcode) = 'CA') AND
       ((TRIM(obj_mbrindp1.dtetrm) IS NULL) OR v_isdtetrmvalid <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_F623;
      t_errorfieldp1(v_errorCountp1) := 'DTETRM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_F623);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.dtetrm;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----DTETRM Validation 1
    IF ((TRIM(obj_mbrindp1.statcode) <> 'CA') AND
       (TRIM(obj_mbrindp1.dtetrm) IS NOT NULL) AND
       (TRIM(obj_mbrindp1.dtetrm) <> 0) AND
       (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE)) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z089;
      t_errorfieldp1(v_errorCountp1) := 'DTETRM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z089);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.dtetrm;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----STATCODE Validation
    IF TRIM(obj_mbrindp1.statcode) IS NULL THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_S008;
      t_errorfieldp1(v_errorCountp1) := 'STATCODE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_S008);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.statcode;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    ELSE
      IF (trim(obj_mbrindp1.statcode) <> 'PN') AND
         (TRIM(obj_mbrindp1.statcode) <> 'CA') AND
         (TRIM(obj_mbrindp1.statcode) <> 'XN') AND
         (TRIM(obj_mbrindp1.statcode) <> 'IF') THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_S008;
        t_errorfieldp1(v_errorCountp1) := 'STATCODE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_S008);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.statcode;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ----------- New Validation For Newly Added Column ISSDATE -------------------------------------
    IF TRIM(obj_mbrindp1.statcode) = 'PN' THEN
      n_issdate := o_defaultvalues('NOTSFROM');
    ELSE
      IF (TRIM(obj_mbrindp1.ISSDATE) <> 99999999 AND
         TRIM(obj_mbrindp1.ISSDATE) IS NOT NULL) THEN
        n_issdate := obj_mbrindp1.ISSDATE;
      ELSE
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z013;
        t_errorfieldp1(v_errorCountp1) := 'ISSDATE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ISSDATE;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---------------Second part of validation -TITDMGMBRINDP1----------------------------------------
    ---MPOLNUM validation
    /* IF TRIM(obj_mbrindp1.mpolnum) IS NOT NULL THEN
    select count(*)
    into v_ismasterplmig
    from GCHD
    where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum);*/
    --  IF NOT        (checkchdrnum.exists(TRIM(obj_mbrindp1.mpolnum) || TRIM(i_company))) THEN
    IF TRIM(obj_mbrindp1.mpolnum) IS NOT NULL THEN
      IF NOT (getmpol.exists(TRIM(obj_mbrindp1.mpolnum))) THEN
        IF TRIM(v_ismasterplmig) < 1 THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z003;
          t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_Z003);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.mpolnum;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        END IF;
      END IF;
    END IF;
    --ZSALECHNL validation
    IF TRIM(obj_mbrindp1.zsalechnl) IS NOT NULL THEN
      IF NOT
          (itemexist.exists(TRIM('TQ9FW') || TRIM(obj_mbrindp1.zsalechnl) || 1)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z005;
        t_errorfieldp1(v_errorCountp1) := 'ZSALECHNL';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z005);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zsalechnl;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --CLTRELN validation
    IF TRIM(obj_mbrindp1.cltreln) IS NOT NULL THEN
      IF NOT
          (itemexist.exists(TRIM('T3584') || TRIM(obj_mbrindp1.cltreln) || 9)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z006;
        t_errorfieldp1(v_errorCountp1) := 'CLTRELN';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z006);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.cltreln;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --ZTRXSTAT validation
    IF TRIM(obj_mbrindp1.ztrxstat) IS NOT NULL THEN
      IF NOT
          (itemexist.exists(TRIM('TQ9FT') || TRIM(obj_mbrindp1.ztrxstat) || 1)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z007;
        t_errorfieldp1(v_errorCountp1) := 'ZTRXSTAT';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z007);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ztrxstat;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --ZSTATRESN validation
    IF TRIM(obj_mbrindp1.zstatresn) IS NOT NULL THEN
      IF NOT
          (itemexist.exists(TRIM('TQ9FU') || TRIM(obj_mbrindp1.zstatresn) || 1)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z008;
        t_errorfieldp1(v_errorCountp1) := 'ZSTATRESN';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z008);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zstatresn;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --ZPLANCDE validation
    IF TRIM(obj_mbrindp1.zplancde) IS NOT NULL THEN
      /* select count(*)
      into v_iszplancde
      from ZSLPPF
      where TRIM(ZSALPLAN) = obj_mbrindp1.zplancde;*/
      IF NOT (checksalplan.exists(TRIM(obj_mbrindp1.zplancde))) THEN
        --    IF TRIM(v_iszplancde) < 1 THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z009;
        t_errorfieldp1(v_errorCountp1) := 'ZPLANCDE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z009);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zplancde;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    --ZENDCDE validation
    /*    IF TRIM(obj_mbrindp1.zendcde) IS NOT NULL THEN
    select count(*)
    into v_iszendcde
    from ZENDRPF
    where TRIM(ZENDCDE) = TRIM(obj_mbrindp1.zendcde);*/
    IF NOT (zendcde.exists(TRIM(obj_mbrindp1.zendcde))) THEN
      IF TRIM(v_iszendcde) < 1 THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z010;
        t_errorfieldp1(v_errorCountp1) := 'ZENDCDE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z010);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zendcde;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    -- MB17 - MPS --
    IF (TRIM(obj_mbrindp1.GPOLTYPE) = 'FSH') THEN
       IF ((TRIM(obj_mbrindp1.crdtcard) IS NULL)  AND
           (TRIM(obj_mbrindp1.zenspcd01) IS NULL) AND
           (TRIM(obj_mbrindp1.zenspcd02) IS NULL) AND
           (TRIM(obj_mbrindp1.ZCIFCODE) IS NULL)) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z011;
          t_errorfieldp1(v_errorCountp1) := 'CRDTCARD';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_Z011);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.crdtcard;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        END IF;
    END IF;
    -- MB17 - MPS --
    --At least one of the 3 fields (Credit Card No, Bank Account No and Endorser Specific Code) is mandatory. validation
    IF (TRIM(obj_mbrindp1.GPOLTYPE) <> 'FSH') THEN
        IF ((TRIM(obj_mbrindp1.crdtcard) IS NULL) AND
           (TRIM(obj_mbrindp1.bnkacckey01) IS NULL) AND
           (TRIM(obj_mbrindp1.zenspcd01) IS NULL)) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z011;
          t_errorfieldp1(v_errorCountp1) := 'CRDTCARD';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_Z011);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.crdtcard;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        END IF;
    END IF;
    /* --At least one of the 3 fields (Credit Card No, Bank Account No and Endorser Specific Code) is mandatory. validation
    IF ((TRIM(obj_mbrindp1.crdtcard) IS NULL) AND
    (TRIM(obj_mbrindp1.bnkacckey01) IS NULL) AND
    (TRIM(obj_mbrindp1.zenspcd01) IS NULL)) THEN
    v_isAnyErrorp1 := 'Y';
    v_errorCountp1 := INSERT_ZDOE(v_prefix,
    i_scheduleNumber,
    TRIM(v_refKeyp1),
    C_Z011,
    'BNKACCKEY01',
    obj_mbrindp1.bnkacckey01,
    NULL,
    'E');
    IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    GOTO insertzdoep1;
    END IF;
    END IF;
    --At least one of the 3 fields (Credit Card No, Bank Account No and Endorser Specific Code) is mandatory. validation
    IF ((TRIM(obj_mbrindp1.crdtcard) IS NULL) AND
    (TRIM(obj_mbrindp1.bnkacckey01) IS NULL) AND
    (TRIM(obj_mbrindp1.zenspcd01) IS NULL)) THEN
    v_isAnyErrorp1 := 'Y';
    v_errorCountp1 := INSERT_ZDOE(v_prefix,
    i_scheduleNumber,
    TRIM(v_refKeyp1),
    C_Z011,
    'ZENSPCD01',
    obj_mbrindp1.zenspcd01,
    NULL,
    'E');
    IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    GOTO insertzdoep1;
    END IF;
    END IF;*/
    --ZCMPCODE validation
    /*IF TRIM(obj_mbrindp1.zcmpcode) IS NOT NULL THEN
    select count(*)
    into v_iszcmpcode
    from ZCPNPF
    where TRIM(ZCMPCODE) = TRIM(obj_mbrindp1.zcmpcode);*/
    IF NOT (campcode.exists(TRIM(obj_mbrindp1.zcmpcode))) THEN
      IF TRIM(v_iszcmpcode) < 1 THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z021;
        t_errorfieldp1(v_errorCountp1) := 'ZCMPCODE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z021);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zcmpcode;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ----CNTTYPIND Value must be either ?M? or ?I?
    IF (TRIM(obj_mbrindp1.cnttypind) IS NOT NULL AND
       ((TRIM(obj_mbrindp1.cnttypind) <> 'M') AND
       (TRIM(obj_mbrindp1.cnttypind) <> 'I'))) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z012;
      t_errorfieldp1(v_errorCountp1) := 'CNTTYPIND';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z012);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.cnttypind;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----EFFDATE Validation
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.effdate));
    IF ((TRIM(obj_mbrindp1.effdate) IS NULL) OR (v_iseffdate <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'EFFDATE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.effdate;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----DOCRCVDT Validation
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.docrcvdt));
    IF ((TRIM(obj_mbrindp1.docrcvdt) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'DOCRCVDT';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.docrcvdt;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----HPROPDTE Validation
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.hpropdte));
    IF ((TRIM(obj_mbrindp1.hpropdte) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'HPROPDTE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.hpropdte;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ----ZANNCLDT Validation
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.zanncldt));
    IF ((TRIM(obj_mbrindp1.zanncldt) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'ZANNCLDT';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zanncldt;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---PTDATE validation
    IF (TRIM(obj_mbrindp1.statcode) <> 'PN') THEN
      v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.ptdate));
      IF ((TRIM(obj_mbrindp1.ptdate) IS NULL) OR
         (TRIM(v_iseffdate) <> 'OK')) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z013;
        t_errorfieldp1(v_errorCountp1) := 'PTDATE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ptdate;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---BTDATE validation
    IF (TRIM(obj_mbrindp1.statcode) <> 'PN') 
    AND (TRIM(obj_mbrindp1.ZTRXSTAT) <> 'RJ')
    THEN
      v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.btdate));
      IF ((TRIM(obj_mbrindp1.btdate) IS NULL) OR
         (TRIM(v_iseffdate) <> 'OK')) THEN
        v_isAnyErrorp1 := 'Y'; --MB12
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z013;
        t_errorfieldp1(v_errorCountp1) := 'BTDATE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.btdate;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---ITR-3 ZWAITPEDT validation
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.zwaitpedt));
    IF ((TRIM(obj_mbrindp1.zwaitpedt) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y'; --MB12
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'ZWAITPEDT';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zwaitpedt;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ITR-3 ZCONVINDPOL must be blank
    IF (TRIM(obj_mbrindp1.ZCONVINDPOL) IS NOT NULL AND
       (TRIM(obj_mbrindp1.cnttypind) <> 'M')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z093;
      t_errorfieldp1(v_errorCountp1) := 'ZCONVINDPO';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z093);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZCONVINDPOL;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    /*---ITR-3  ZCONVINDPOL is invalid  ---As removed in TSD
    IF (TRIM(obj_mbrindp1.ZCONVINDPOL) IS NOT NULL AND
    (TRIM(obj_mbrindp1.cnttypind) = 'M')) THEN
    select count(*)
    into v_ismasterplmig
    from GCHD
    where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.ZCONVINDPOL);
    IF TRIM(v_ismasterplmig) < 1 THEN
    v_isAnyErrorp1 := 'Y';
    v_errorCountp1 := v_errorCountp1 + 1;
    t_ercodep1(v_errorCountp1) := C_Z120;
    t_errorfieldp1(v_errorCountp1) := 'ZCONVINDPOL';
    t_errormsgp1(v_errorCountp1) := o_errortext(C_Z120);
    t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZCONVINDPOL;
    t_errorprogramp1(v_errorCountp1) := i_scheduleName;
    IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    GOTO insertzdoep1;
    END IF;
    END IF;
    END IF;*/
    --ITR-3  OLDPOLNUM Old Pol No must be blank-
    IF (TRIM(obj_mbrindp1.OLDPOLNUM) IS NOT NULL AND
       (TRIM(obj_mbrindp1.cnttypind) <> 'I')) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z095;
      t_errorfieldp1(v_errorCountp1) := 'OLDPOLNUM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z095);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.OLDPOLNUM;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    /*  --ITR-3  OLDPOLNUM Invalid Old Policy No. ---As removed in TSD
    IF (TRIM(obj_mbrindp1.OLDPOLNUM) IS NOT NULL AND
    (TRIM(obj_mbrindp1.cnttypind) = 'I')) THEN
    select count(*)
    into v_ismasterplmig
    from GCHD
    where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.OLDPOLNUM);
    IF TRIM(v_ismasterplmig) < 1 THEN
    v_isAnyErrorp1 := 'Y';
    v_errorCountp1 := v_errorCountp1 + 1;
    t_ercodep1(v_errorCountp1) := C_Z094;
    t_errorfieldp1(v_errorCountp1) := 'OLDPOLNUM';
    t_errormsgp1(v_errorCountp1) := o_errortext(C_Z094);
    t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.OLDPOLNUM;
    t_errorprogramp1(v_errorCountp1) := i_scheduleName;
    IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    GOTO insertzdoep1;
    END IF;
    END IF;
    END IF;*/
    --ITR-3  TREFNUM TREFNUM is invalid
    ---SIT bug changes
    /* IF (TRIM(obj_mbrindp1.TREFNUM) IS NOT NULL) THEN
    select count(*)
    into v_ismasterplmig
    from GCHD
    where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.TREFNUM);
    IF TRIM(v_ismasterplmig) < 1 THEN
    v_isAnyErrorp1 := 'Y';
    v_errorCountp1 := v_errorCountp1 + 1;
    t_ercodep1(v_errorCountp1) := C_Z121;
    t_errorfieldp1(v_errorCountp1) := 'TREFNUM';
    t_errormsgp1(v_errorCountp1) := o_errortext(C_Z121);
    t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.TREFNUM;
    t_errorprogramp1(v_errorCountp1) := i_scheduleName;
    IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    GOTO insertzdoep1;
    END IF;
    END IF;
    END IF;*/
    --ITR-3  TREFNUM  ZCONVINDPOL is invalid
    -- MB9 [START]
    --    IF (TRIM(obj_mbrindp1.TREFNUM) IS NOT NULL AND
    --       (TRIM(obj_mbrindp1.ZCONVINDPOL) IS NOT NULL)) THEN
    --      v_isAnyErrorp1 := 'Y';
    --      v_errorCountp1 := v_errorCountp1 + 1;
    --      t_ercodep1(v_errorCountp1) := C_Z120;
    --      t_errorfieldp1(v_errorCountp1) := 'TREFNUM';
    --      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z120);
    --      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.TREFNUM;
    --      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
    --      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
    --        GOTO insertzdoep1;
    --      END IF;
    --    END IF;
    -- MB9 [END]

    --ITR-3  TREFNUM  Old Pol No must be blank
    IF (TRIM(obj_mbrindp1.TREFNUM) IS NOT NULL AND
       (TRIM(obj_mbrindp1.OLDPOLNUM) IS NOT NULL)) THEN
      v_isAnyErrorp1 := 'Y';
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z095;
      t_errorfieldp1(v_errorCountp1) := 'TREFNUM';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z095);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.TREFNUM;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ITR-3 ZPOLTDATE validation  Invalid Date
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.ZPOLTDATE));
    IF ((TRIM(obj_mbrindp1.ZPOLTDATE) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y'; --MB12
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'ZPOLTDATE';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPOLTDATE;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ITR-3 ZPOLTDATE validation Outside policy period
    IF ((TRIM(obj_mbrindp1.ZPOLTDATE) IS NOT NULL) AND
       (TRIM(obj_mbrindp1.ZPOLTDATE) <> 0) AND
       (TRIM(obj_mbrindp1.ZPOLTDATE) <> C_MAXDATE)) THEN
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      IF ((TRIM(obj_mbrindp1.ZPOLTDATE) < obj_mbrindp1.effdate) OR
         (TRIM(obj_mbrindp1.ZPOLTDATE) > v_temp_crdate)) THEN
        /**** MB4 :  MOD : condition change due to new requirement : END ****/
        v_isAnyErrorp1 := 'Y'; --MB12
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z096;
        t_errorfieldp1(v_errorCountp1) := 'ZPOLTDATE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z096);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPOLTDATE;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---ITR-3 ZPGPFRDT validation  Invalid Date
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.ZPGPFRDT));
    IF ((TRIM(obj_mbrindp1.ZPGPFRDT) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y'; --MB12
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'ZPGPFRDT';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPGPFRDT;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ITR-3 ZPGPFRDT validation Outside policy period
    IF ((TRIM(obj_mbrindp1.ZPGPFRDT) IS NOT NULL) AND
       (TRIM(obj_mbrindp1.ZPGPFRDT) <> 0) AND
       (TRIM(obj_mbrindp1.ZPGPFRDT) <> C_MAXDATE)) THEN
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      IF ((TRIM(obj_mbrindp1.ZPGPFRDT) < obj_mbrindp1.effdate) OR
         (TRIM(obj_mbrindp1.ZPGPFRDT) > v_temp_crdate)) THEN
        /**** MB4 :  MOD : condition change due to new requirement : END ****/
        v_isAnyErrorp1 := 'Y'; --MB12
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z096;
        t_errorfieldp1(v_errorCountp1) := 'ZPGPFRDT';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z096);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPGPFRDT;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---ITR-3 ZPGPTODT validation  Invalid Date
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp1.ZPGPTODT));
    IF ((TRIM(obj_mbrindp1.ZPGPTODT) IS NULL) OR
       (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp1 := 'Y'; --MB12
      v_errorCountp1 := v_errorCountp1 + 1;
      t_ercodep1(v_errorCountp1) := C_Z013;
      t_errorfieldp1(v_errorCountp1) := 'ZPGPTODT';
      t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
      t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPGPTODT;
      t_errorprogramp1(v_errorCountp1) := i_scheduleName;
      IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
        GOTO insertzdoep1;
      END IF;
    END IF;
    ---ITR-3 ZPGPTODT validation  From date > To date
    IF (TRIM(obj_mbrindp1.ZPGPFRDT) IS NOT NULL) THEN
      IF ((TRIM(obj_mbrindp1.ZPGPTODT) IS NULL) OR
         (TRIM(obj_mbrindp1.ZPGPTODT) < obj_mbrindp1.ZPGPFRDT)) THEN
        v_isAnyErrorp1 := 'Y'; --MB12
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z097;
        t_errorfieldp1(v_errorCountp1) := 'ZPGPTODT';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z097);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPGPTODT;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---ITR-3 ZPGPTODT validation Outside policy period
    IF ((TRIM(obj_mbrindp1.ZPGPTODT) IS NOT NULL) AND
       (TRIM(obj_mbrindp1.ZPGPTODT) <> 0) AND
       (TRIM(obj_mbrindp1.ZPGPTODT) <> C_MAXDATE)) THEN
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      IF ((TRIM(obj_mbrindp1.ZPGPTODT) < obj_mbrindp1.effdate) OR
         (TRIM(obj_mbrindp1.ZPGPTODT) > v_temp_crdate)) THEN
        /**** MB4 :  MOD : condition change due to new requirement : END ****/
        v_isAnyErrorp1 := 'Y'; --MB12
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z096;
        t_errorfieldp1(v_errorCountp1) := 'ZPGPTODT';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z096);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZPGPTODT;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---MB12 : MOD  :BTDATE allow As MAX DATE only for CA state : START
    ---BTDATE validation
    IF (TRIM(obj_mbrindp1.statcode) <> 'CA') THEN
      IF (TRIM(obj_mbrindp1.btdate) = C_MAXDATE) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_Z013;
        t_errorfieldp1(v_errorCountp1) := 'BTDATE';
        t_errormsgp1(v_errorCountp1) := o_errortext(C_Z013);
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.btdate;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;
      END IF;
    END IF;
    ---MB12 : MOD  :BTDATE allow As MAX DATE only for CA state : END
    <<insertzdoep1>>
    i_zdoe_infop1.i_tableName := i_zdoe_infop1.i_tableName;
    IF (v_isAnyErrorp1 = 'Y') THEN
      IF TRIM(t_ercodep1(1)) IS NOT NULL THEN
        i_zdoe_infop1.i_indic          := C_ERROR;
        i_zdoe_infop1.i_error01        := t_ercodep1(1);
        i_zdoe_infop1.i_errormsg01     := t_errormsgp1(1);
        i_zdoe_infop1.i_errorfield01   := t_errorfieldp1(1);
        i_zdoe_infop1.i_fieldvalue01   := t_errorfieldvalp1(1);
        i_zdoe_infop1.i_errorprogram01 := t_errorprogramp1(1);
      END IF;
      IF TRIM(t_ercodep1(2)) IS NOT NULL THEN
        i_zdoe_infop1.i_indic          := C_ERROR;
        i_zdoe_infop1.i_error02        := t_ercodep1(2);
        i_zdoe_infop1.i_errormsg02     := t_errormsgp1(2);
        i_zdoe_infop1.i_errorfield02   := t_errorfieldp1(2);
        i_zdoe_infop1.i_fieldvalue02   := t_errorfieldvalp1(2);
        i_zdoe_infop1.i_errorprogram02 := t_errorprogramp1(2);
      END IF;
      IF TRIM(t_ercodep1(3)) IS NOT NULL THEN
        i_zdoe_infop1.i_indic          := C_ERROR;
        i_zdoe_infop1.i_error03        := t_ercodep1(3);
        i_zdoe_infop1.i_errormsg03     := t_errormsgp1(3);
        i_zdoe_infop1.i_errorfield03   := t_errorfieldp1(3);
        i_zdoe_infop1.i_fieldvalue03   := t_errorfieldvalp1(3);
        i_zdoe_infop1.i_errorprogram03 := t_errorprogramp1(3);
      END IF;
      IF TRIM(t_ercodep1(4)) IS NOT NULL THEN
        i_zdoe_infop1.i_indic          := C_ERROR;
        i_zdoe_infop1.i_error04        := t_ercodep1(4);
        i_zdoe_infop1.i_errormsg04     := t_errormsgp1(4);
        i_zdoe_infop1.i_errorfield04   := t_errorfieldp1(4);
        i_zdoe_infop1.i_fieldvalue04   := t_errorfieldvalp1(4);
        i_zdoe_infop1.i_errorprogram04 := t_errorprogramp1(4);
      END IF;
      IF TRIM(t_ercodep1(5)) IS NOT NULL THEN
        i_zdoe_infop1.i_indic          := C_ERROR;
        i_zdoe_infop1.i_error05        := t_ercodep1(5);
        i_zdoe_infop1.i_errormsg05     := t_errormsgp1(5);
        i_zdoe_infop1.i_errorfield05   := t_errorfieldp1(5);
        i_zdoe_infop1.i_fieldvalue05   := t_errorfieldvalp1(5);
        i_zdoe_infop1.i_errorprogram05 := t_errorprogramp1(5);
      END IF;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_infop1);
      CONTINUE skipRecord;
    END IF;
    IF (v_isAnyErrorp1 = 'N') THEN
      i_zdoe_infop1.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_infop1);
    END IF;
    IF ((TRIM(i_zprvaldYN) = 'N') AND (TRIM(v_isAnyErrorp1) = 'N')) THEN
      IF (itemexist.exists(TRIM('TQ9FK') || TRIM(obj_mbrindp1.gpoltype) || 1)) THEN
        --    v_template := itemexist(obj_mbrindp1.gpoltype).template;
        v_template := itemexist(TRIM('TQ9FK') || TRIM(obj_mbrindp1.gpoltype) || TRIM('1'))
                      .template;
        /*  select *
        into obj_dfpopf
        from DFPOPF
        where TRIM(template) = TRIM(v_template);  */
        IF (getdfpo.exists(TRIM(v_template))) THEN
          obj_dfpopf := getdfpo(TRIM(v_template));
        END IF;
      END IF;
      obj_gchd.CHDRCOY := i_company;
      obj_gchd.CHDRNUM := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gchd.CHDRPFX := o_defaultvalues('CHDRPFX');
      obj_gchd.CNTTYPE := obj_mbrindp1.gpoltype;
      obj_gchd.COWNPFX := o_defaultvalues('COWNPFX');
      obj_gchd.COWNCOY := i_fsucocompany;
      /*  IF v_isexistzdclpf > 0 THEN
      SELECT zigvalue
      INTO v_zigvalue1
      FROM Jd1dta.PAZDCLPF
      WHERE TRIM(ZENTITY) = TRIM(v_refnump1);
      END IF; */
      obj_gchd.COWNNUM  := v_zigvalue;
      obj_gchd.STATCODE := obj_mbrindp1.statcode;
      IF (TRIM(obj_mbrindp1.statcode) = 'PN') THEN
        obj_gchd.PNDATE := obj_mbrindp1.effdate;
      ELSE
        obj_gchd.PNDATE := C_MAXDATE;
      END IF;
      -- obj_gchd.SUBSFLG := obj_dfpopf.Subsflg;
      obj_gchd.SUBSFLG := C_SPACE; --MB7
      --- 17/02/2018 After Pre-SIT execution
      /*  IF ((TRIM(obj_mbrindp1.zanncldt) IS NULL) OR
      ((TRIM(obj_mbrindp1.zanncldt) = C_MAXDATE)) OR
      ((TRIM(obj_mbrindp1.zanncldt) = C_ZERO))) THEN
      obj_gchd.OCCDATE := obj_mbrindp1.effdate;
      ELSE
      obj_gchd.OCCDATE := TRIM(v_zcovcmdt);
      END IF;*/
      obj_gchd.OCCDATE := obj_mbrindp1.effdate;
      obj_gchd.HRSKIND := obj_dfpopf.hrskind;
      /* SELECT TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 0, 3))
      into v_currency
      FROM ITEMPF
      WHERE RTRIM(ITEMTABL) = 'T9775'
      and TRIM(ITEMITEM) = TRIM(i_branch)
      AND RTRIM(ITEMCOY) = TRIM(i_company);    */
      IF (itemexist.exists(TRIM('T9775') || TRIM(i_branch) || 1)) THEN
        --  v_currency := itemexist(i_branch).currency;
        v_currency := itemexist(TRIM('T9775') || TRIM(i_branch) || TRIM('1'))
                      .currency;
      END IF;
      obj_gchd.CNTCURR  := TRIM(v_currency);
      obj_gchd.BILLCURR := TRIM(v_currency);
      --  obj_gchd.TAKOVRFLG  := obj_dfpopf.takovrflg;
      obj_gchd.TAKOVRFLG  := C_SPACE; --MB7
      obj_gchd.GPRNLTYP   := obj_dfpopf.gprnltyp;
      obj_gchd.GPRMNTHS   := obj_dfpopf.gprmnths;
      obj_gchd.RNLNOTTO   := obj_dfpopf.rnlnotto;
      obj_gchd.SRCEBUS    := o_defaultvalues('SRCEBUS');
      obj_gchd.COYSRVAC   := obj_dfpopf.coysrvac;
      obj_gchd.MRKSRVAC   := obj_dfpopf.mrksrvac;
      obj_gchd.DESPPFX    := C_SPACE;
      obj_gchd.DESPCOY    := C_SPACE;
      obj_gchd.DESPNUM    := C_SPACE;
      obj_gchd.POLSCHPFLG := o_defaultvalues('POLSCHPFLG');
      obj_gchd.BTDATE     := obj_mbrindp1.btdate;
      obj_gchd.ADJDATE    := C_MAXDATE;
      obj_gchd.PTDATE     := obj_mbrindp1.ptdate;
      obj_gchd.PTDATEAB   := C_MAXDATE;
      obj_gchd.TRANLUSED  := o_defaultvalues('TRANLUSED');
      obj_gchd.LMBRNO     := o_defaultvalues('LMBRNO');
      obj_gchd.LHEADNO    := o_defaultvalues('LHEADNO');
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
        obj_gchd.EFFDCLDT := obj_mbrindp1.dtetrm;
      ELSE
        obj_gchd.EFFDCLDT := C_MAXDATE;
      END IF;
      obj_gchd.SERVUNIT := o_defaultvalues('SERVUNIT');
      IF (TRIM(obj_mbrindp1.statcode) = 'PN') THEN
        obj_gchd.PNTRCDE := o_defaultvalues('PNTRCDE');
      ELSE
        obj_gchd.PNTRCDE := C_SPACE;
      END IF;
      obj_gchd.PROCID := C_SPACE;
      obj_gchd.TRANID := concat('QPAD', TO_CHAR(sysdate, 'YYMMDDHHMM'));
      --IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      --  obj_gchd.TRANNO := v_seqnoincr;
      --ELSE
      --  obj_gchd.TRANNO := v_seqno;
      --END IF;
      obj_gchd.TRANNO    := v_seqnoincr;
      obj_gchd.VALIDFLAG := o_defaultvalues('VALIDFLAG');
      obj_gchd.SPECIND   := C_SPACE;
      obj_gchd.TAXFLAG   := obj_dfpopf.taxflag;
      obj_gchd.AGEDEF    := obj_dfpopf.agedef;
      obj_gchd.TERMAGE   := obj_dfpopf.termage;
      obj_gchd.PERSONCOV := obj_dfpopf.personcov;
      obj_gchd.ENROLLTYP := obj_dfpopf.enrolltyp;
      obj_gchd.SPLITSUBS := obj_dfpopf.splitsubs;
      obj_gchd.AVLISU    := C_SPACE;
      --  obj_gchd.MPLPFX    := o_defaultvalues('CHDRPFX');
      obj_gchd.MPLPFX := C_SPACE; --MB7
      obj_gchd.MPLCOY := i_company;
      IF (TRIM(obj_mbrindp1.cnttypind) = 'I') THEN
        obj_gchd.MPLNUM := C_SPACE;
      ELSE
        obj_gchd.MPLNUM := obj_mbrindp1.mpolnum;
      END IF;
      obj_gchd.USRPRF   := i_usrprf;
      obj_gchd.JOBNM    := i_scheduleName;
      obj_gchd.DATIME   := CAST(sysdate AS TIMESTAMP);
      obj_gchd.IGRASP   := C_SPACE;
      obj_gchd.IEXPLAIN := C_SPACE;
      obj_gchd.IDATE    := C_ZERO;
      obj_gchd.MIDJOIN  := C_SPACE;
      obj_gchd.CVISAIND := C_SPACE;
      obj_gchd.COVERNT  := C_SPACE;
      obj_gchd.CNTISS   := C_ZERO;
      -- obj_gchd.REPNUM   := C_ZERO;
      obj_gchd.REPNUM  := C_SPACE; --MB7 
      obj_gchd.REPTYPE := C_SPACE;
      obj_gchd.PAYRCOY := C_SPACE;
      obj_gchd.PAYRNUM := C_SPACE;
      obj_gchd.PAYRPFX := C_SPACE;
      IF (TRIm(obj_mbrindp1.oldpolnum) IS NOT NULL) THEN
        obj_gchd.ZPRVCHDR := obj_mbrindp1.oldpolnum;
      ELSE
        obj_gchd.ZPRVCHDR := obj_mbrindp1.trefnum;
      END IF;
      --- 17/02/2018 After Pre-SIT execution
      obj_gchd.CURRFROM := C_ZERO;
      obj_gchd.CURRTO   := C_ZERO;
      --  obj_gchd.TRANLUSED    := v_seqnoincr;
      obj_gchd.TRANLUSED    := obj_gchd.TRANNO; --MB12 : TRANNO == TRANLUSED
      obj_gchd.Zrwnlage     := o_defaultvalues('ZRWNLAGE'); --MB7 Need to change TQ9Q9
      obj_gchd.QUOTENO      := C_ZERO; --MB7 new added
      obj_gchd.SCHMNO       := C_SPACE; --MB7 new added
      obj_gchd.RTGRANTE     := C_SPACE; --MB7 new added
      obj_gchd.RTGRANTEDATE := C_ZERO; --MB7 new added
      obj_gchd.CPIINCRIND   := C_SPACE; --MB7 new added
      obj_gchd.SUPERFLAG    := C_SPACE; --MB7 new added
      
      IF obj_gchd.STATCODE = 'XN' THEN
         obj_gchd.PTDATE  := C_MAXDATE;
      END IF;
      
      INSERT INTO GCHD VALUES obj_gchd;
      ------Insert Into IG table "GCHD"  END -----
      ---Insert into IG table  "GCHPPF" BEGIN (pq9ho.updateGchppf())---
      SELECT zagptid, zpolcls
        INTO v_zagptid, v_zpolcls
        FROM Zcpnpf
       WHERE TRIM(ZCMPCODE) = TRIM(obj_mbrindp1.zcmpcode);
      SELECT SEQ_GCHPPF.nextval INTO v_seq_gchppf FROM dual;
      obj_gchppf.unique_number := v_seq_gchppf;
      obj_gchppf.CHDRCOY       := i_company;
      obj_gchppf.CHDRNUM       := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gchppf.EXBRKNM       := obj_dfpopf.exbrknm;
      obj_gchppf.EXUNDNM       := obj_dfpopf.exundnm;
      obj_gchppf.BRKSRVAC      := obj_dfpopf.brksrvac;
      obj_gchppf.REFNO         := obj_dfpopf.refno;
      obj_gchppf.MBRDATA       := obj_dfpopf.mbrdata;
      obj_gchppf.ADMNRULE      := obj_dfpopf.admnrule;
      obj_gchppf.DEFPLANDI     := obj_dfpopf.defplandi;
      obj_gchppf.DEFCLMPYE     := obj_dfpopf.defclmpye;
      obj_gchppf.EMPGRP        := obj_dfpopf.empgrp;
      obj_gchppf.INWINCTYP     := obj_dfpopf.inwinctyp;
      obj_gchppf.AREACOD       := obj_dfpopf.areacod;
      obj_gchppf.INDUSTRY      := obj_dfpopf.industry;
      obj_gchppf.MAJORMET      := obj_dfpopf.majormet;
      obj_gchppf.BULKIND       := obj_dfpopf.bulkind;
      obj_gchppf.FFEEWHOM      := C_SPACE;
      obj_gchppf.PRODMIX       := obj_dfpopf.prodmix;
      obj_gchppf.FEELVL        := obj_dfpopf.feelvl;
      obj_gchppf.CTBEFFDT      := obj_dfpopf.ctbeffdt;
      obj_gchppf.EXBFML        := obj_dfpopf.exbfml;
      obj_gchppf.EXBLDAYS      := obj_dfpopf.exbldays;
      obj_gchppf.CTBFML        := obj_dfpopf.ctbfml;
      obj_gchppf.CTBNDAYS      := obj_dfpopf.ctbndays;
      obj_gchppf.EFAIS         := obj_dfpopf.efais;
      obj_gchppf.EFADP         := obj_dfpopf.efadp;
      obj_gchppf.NOREM         := obj_dfpopf.norem;
      obj_gchppf.FSTRMFML      := obj_dfpopf.fstrmfml;
      obj_gchppf.FSTRMDAY      := obj_dfpopf.fstrmday;
      obj_gchppf.SNDRMFML      := obj_dfpopf.sndrmfml;
      obj_gchppf.SNDRMDAY      := obj_dfpopf.sndrmday;
      obj_gchppf.TRDRMFML      := obj_dfpopf.trdrmfml;
      obj_gchppf.TRDRMDAY      := obj_dfpopf.trdrmday;
      obj_gchppf.MBRIDFLD      := obj_dfpopf.mbridfld;
      obj_gchppf.EXBDUEDT      := C_MAXDATE;
      obj_gchppf.CTBDUEDT      := C_MAXDATE;
      obj_gchppf.LSTEXBFR      := C_MAXDATE;
      obj_gchppf.LSTEXBTO      := C_MAXDATE;
      obj_gchppf.LSTEXBTO      := C_MAXDATE;
      obj_gchppf.LSTCTBTO      := C_MAXDATE;
      obj_gchppf.LSTEBPDT      := C_MAXDATE;
      obj_gchppf.FSTRMPDT      := C_MAXDATE;
      obj_gchppf.SNDRMPDT      := C_MAXDATE;
      obj_gchppf.TRDRMPDT      := C_MAXDATE;
      IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
        /* select POLANV
        into v_polanv
        from Jd1dta.GCHPPF
        where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum)
        and TRIM(CHDRCOY) = TRIM(i_company);*/
        obj_getmpol := getmpol(TRIM(obj_mbrindp1.mpolnum));
        v_polanv    := obj_getmpol.polanv;
        /* IF (getpolanv.exists(TRIM(obj_mbrindp1.mpolnum) || TRIM(i_company ))) THEN
        v_polanv :=  getpolanv(TRIM(obj_mbrindp1.mpolnum) || TRIM(i_company)) ;
        END IF;*/
        obj_gchppf.POLANV := v_polanv;
      END IF;
      obj_gchppf.CTBRULE  := obj_dfpopf.ctbrule;
      obj_gchppf.ACBLRULE := obj_dfpopf.acblrule;
      obj_gchppf.FMCRULE  := obj_dfpopf.fmcrule;
      obj_gchppf.SWTRANNO := C_ZERO;
      obj_gchppf.FEEWHO   := obj_dfpopf.feewho;
      obj_gchppf.ZSRCEBUS := C_SPACE;
      obj_gchppf.CALCMTHD := obj_dfpopf.calcmthd;
      obj_gchppf.AGEBASIS := obj_dfpopf.agebasis;
      obj_gchppf.FCLLVL   := obj_dfpopf.fcllvl;
      obj_gchppf.PRMPYOPT := obj_dfpopf.prmpyopt;
      obj_gchppf.PRMBRLVL := obj_dfpopf.prmbrlvl;
      obj_gchppf.TOLRULE  := obj_dfpopf.tolrule;
      obj_gchppf.CERTINFM := obj_dfpopf.certinfm;
      obj_gchppf.FMC2RULE := obj_dfpopf.fmc2rule;
      obj_gchppf.LMBRPFX  := C_SPACE;
      obj_gchppf.LOYBNFLG := obj_dfpopf.loybnflg;
      obj_gchppf.SWCFLG   := obj_dfpopf.swcflg;
      obj_gchppf.AUTORNW  := obj_dfpopf.autornw;
      obj_gchppf.GAPLPFX  := obj_dfpopf.gaplpfx;
      obj_gchppf.NMLVAR   := obj_dfpopf.nmlvar;
      obj_gchppf.EXTFMLY  := obj_dfpopf.extfmly;
      obj_gchppf.PINFDTE  := C_MAXDATE;
      obj_gchppf.CASHLESS := o_defaultvalues('CASHLESS');
      obj_gchppf.LOCATION := C_SPACE;
      obj_gchppf.SUBLOCN  := C_SPACE;
      obj_gchppf.TTDATE   := C_MAXDATE;
      obj_gchppf.JOBNM    := i_scheduleName;
      obj_gchppf.USRPRF   := i_usrprf;
      obj_gchppf.DATIME   := CAST(sysdate AS TIMESTAMP);
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      obj_gchppf.ZPENDDT := v_temp_crdate;
      /**** MB4 :  MOD : condition change due to new requirement : END ****/
      /* IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
      select ZPLANCLS, Zcolmcls
      into v_zplancls, v_zcolmcls
      from Jd1dta.GCHPPF
      where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum)
      and CHDRCOY = TRIM(i_company);
      obj_gchppf.ZPLANCLS := v_zplancls;
      ELSE
      obj_gchppf.ZPLANCLS := 'PP';
      END IF; */
      -- obj_gchppf.PLANCLASSIFICATION    := 'a';
      -------- MB2: get value of ZCOLMCLS and ZPLANCLS --------
      IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
        obj_getmpol    := getmpol(TRIM(obj_mbrindp1.mpolnum));
        v_zplancls     := obj_getmpol.zplancls;
        v_zcolmcls     := obj_getmpol.zcolmcls;
        v_zplancls_new := v_zplancls;
      ELSE
        v_zplancls_new := 'PP';
        /* Use ZENDCDE and read ZENDRPF, and get Fact-House (zendrpf.getZfacthus())
        if Fact-house not blank, use Fact-house and read t-table T3684 and get bnkacctyp.
        set ZCOLMCLS = t3684rec.bnkacctyp.toString() */
        v_zfacthus := facthouse(TRIM(obj_mbrindp1.zendcde));
        IF v_zfacthus IS NOT NULL THEN
          IF itemexist.exists(TRIM('T3684') || TRIM(v_zfacthus) || 9) THEN
            v_zcolmcls := itemexist(TRIM('T3684') || TRIM(v_zfacthus) || 9)
                          .bnkacctyp;
          END IF;
        END IF;
      END IF;
      -------- MB2: get value of ZCOLMCLS and ZPLANCLS  --------
      obj_gchppf.ZPLANCLS := v_zplancls_new;
      --obj_gchppf.ZAPLFOD    := C_MAXDATE; -- obj_gchppf.APPLICATIONFORMOUTPUT := 'a';  -- MB8
      obj_gchppf.ZAPLFOD    := 0; -- obj_gchppf.APPLICATIONFORMOUTPUT := 'a'; -- MB8
      obj_gchppf.ZGPORIPCLS := v_zpolcls; -- obj_gchppf.GROUPCLASSIFICATION   := 'a';
      obj_gchppf.ZENDCDE    := obj_mbrindp1.zendcde; -- obj_gchppf.ENDORSERCODE          := 'a';
      ---03/05/18 SIT bug fix
      -- obj_gchppf.Zccode  := obj_mbrindp1.zcmpcode; --   obj_gchppf.CAMPAIGNCODE          := 'a';
      obj_gchppf.PETNAME    := C_SPACE;
      obj_gchppf.LSTCTBFR   := C_MAXDATE;
      obj_gchppf.OPTAUTORNW := C_SPACE;
      obj_gchppf.OCALLVSA   := C_SPACE;
      obj_gchppf.ZPOLPERD   := obj_mbrindp1.zpolperd;
      obj_gchppf.ZCOLMCLS   := v_zcolmcls;
      IF (TRIM(obj_mbrindp1.Cnttypind) = 'M') THEN
        obj_gchppf.ZCONVINDPOL := obj_mbrindp1.ZCONVINDPOL;
      ELSE
        obj_gchppf.ZCONVINDPOL := C_SPACE;
      END IF;
      IF (TRIM(obj_mbrindp1.ZPOLTDATE) IS NOT NULL) THEN
        obj_gchppf.ZPOLTDATE := obj_mbrindp1.ZPOLTDATE;
      ELSE
        obj_gchppf.ZPOLTDATE := C_MAXDATE;
      END IF;
      IF (TRIM(obj_mbrindp1.ZPGPFRDT) IS NOT NULL) THEN
        obj_gchppf.ZPGPFRDT := obj_mbrindp1.ZPGPFRDT;
      ELSE
        obj_gchppf.ZPGPFRDT := C_MAXDATE;
      END IF;
      IF (TRIM(obj_mbrindp1.ZPGPTODT) IS NOT NULL) THEN
        obj_gchppf.ZPGPTODT := obj_mbrindp1.ZPGPTODT;
      ELSE
        obj_gchppf.ZPGPTODT := C_MAXDATE;
      END IF;
      obj_gchppf.SINSTNO := obj_mbrindp1.SINSTNO;
      --SIT BUG FIx
      obj_gchppf.ZNBMNAGE := o_defaultvalues('ZNBMNAGE');
      obj_gchppf.MATAGE   := C_ZERO; --MB7 new addedd 
      INSERT INTO GCHPPF VALUES obj_gchppf;
      ---Insert into IG table "GCHPPF" END ---
      ---Insert into IG table "GCHIPF" BEGIN  (pq9ho.updateGchipf())--
      obj_gchipf.CHDRCOY := i_company;
      obj_gchipf.CHDRNUM := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gchipf.EFFDATE := obj_mbrindp1.effdate;
      obj_gchipf.CCDATE  := obj_mbrindp1.effdate;
      obj_gchipf.ZPSTDDT := obj_mbrindp1.effdate;
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      obj_gchipf.CRDATE := v_temp_crdate;
      /**** MB4 :  MOD : condition change due to new requirement : END ****/
      -- obj_gchipf.CRDATE                := obj_mbrindp1.crdate;
      --  obj_gchipf.PRVBILFLG := obj_dfpopf.prvbilflg;
      obj_gchipf.PRVBILFLG := C_SPACE; --MB7
      IF (TRIM(v_zplancls) = 'FP') THEN
        obj_gchipf.BILLFREQ := '00';--MB14
      ELSE
        obj_gchipf.BILLFREQ := obj_dfpopf.billfreq;
      END IF; ---MB7
      IF (TRIM(v_zplancls) = 'FP') THEN
        obj_gchipf.GADJFREQ := '00';--MB14
      ELSE
        obj_gchipf.GADJFREQ := obj_dfpopf.gadjfreq;
      END IF; --MB7

      obj_gchipf.PAYRPFX := C_SPACE;
      obj_gchipf.PAYRCOY := C_SPACE;
      obj_gchipf.PAYRNUM := C_SPACE;
      obj_gchipf.AGNTPFX := o_defaultvalues('AGNTPFX');
      obj_gchipf.AGNTCOY := i_fsucocompany;
      IF (TRIM(obj_mbrindp1.Cnttypind) <> 'I') THEN
        /*   select zagptid, zpolcls
        into v_zagptid, v_zpolcls
        from Zcpnpf
        where TRIM(ZCMPCODE) = TRIM(obj_mbrindp1.zcmpcode);*/
        /*   select ZAGPTNUM
        into v_zagptnum
        from GCHIPF
        where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum)
        AND EFFDATE <= TRIM(obj_mbrindp1.effdate)
        and ROWNUM = 1
        order by tranno DESC;*/
        obj_getmpol := getmpol(TRIM(obj_mbrindp1.mpolnum));
        v_zagptnum  := obj_getmpol.zagptnum;
        SELECT admnoper01,
               gagntsel01,
               admnoper02,
               gagntsel02,
               admnoper03,
               gagntsel03,
               admnoper04,
               gagntsel04,
               admnoper05,
               gagntsel05
          INTO v_admnoper01,
               v_gagntsel01,
               v_admnoper02,
               v_gagntsel02,
               v_admnoper03,
               v_gagntsel03,
               v_admnoper04,
               v_gagntsel04,
               v_admnoper05,
               v_gagntsel05
          FROM ZAGPPF
         WHERE TRIM(zagptnum) = v_zagptnum
           AND TRIM(Zagptpfx) = 'AP'
           AND TRIM(Zagptcoy) = i_company;
        IF TRIM(v_admnoper01) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel01;
        END IF;
        IF TRIM(v_admnoper02) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel02;
        END IF;
        IF TRIM(v_admnoper03) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel03;
        END IF;
        IF TRIM(v_admnoper04) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel04;
        END IF;
        IF TRIM(v_admnoper05) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel05;
        END IF;
      ELSE
        /*  select zagptid, zpolcls
        into v_zagptid, v_zpolcls
        from Zcpnpf
        where TRIM(ZCMPCODE) = TRIM(obj_mbrindp1.zcmpcode);*/
        SELECT admnoper01,
               gagntsel01,
               admnoper02,
               gagntsel02,
               admnoper03,
               gagntsel03,
               admnoper04,
               gagntsel04,
               admnoper05,
               gagntsel05
          INTO v_admnoper01,
               v_gagntsel01,
               v_admnoper02,
               v_gagntsel02,
               v_admnoper03,
               v_gagntsel03,
               v_admnoper04,
               v_gagntsel04,
               v_admnoper05,
               v_gagntsel05
          FROM ZAGPPF
         WHERE TRIM(zagptnum) = v_zagptid
           AND TRIM(Zagptpfx) = 'AP'
           AND TRIM(Zagptcoy) = i_company;
        IF TRIM(v_admnoper01) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel01;
        END IF;
        IF TRIM(v_admnoper02) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel02;
        END IF;
        IF TRIM(v_admnoper03) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel03;
        END IF;
        IF TRIM(v_admnoper04) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel04;
        END IF;
        IF TRIM(v_admnoper05) = 'Y' THEN
          obj_gchipf.AGNTNUM := v_gagntsel05;
        END IF;
      END IF;
      obj_gchipf.ZAGPTNUM  := v_zagptid;
      obj_gchipf.CNTBRANCH := i_branch;
      -- obj_gchipf.STCA      := C_SPACE;
      obj_gchipf.STCA := 'LF'; --MB7
      obj_gchipf.STCB := C_SPACE;
      obj_gchipf.STCC := C_SPACE;
      obj_gchipf.STCD := C_SPACE;
      obj_gchipf.STCE := C_SPACE;
      IF (TRIM(obj_mbrindp1.Cnttypind) = 'M') THEN
        /* select ZPLANCLS
        into v_zplancls
        from Jd1dta.GCHPPF
        where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum)
        and CHDRCOY = TRIM(i_company);*/
        obj_getmpol := getmpol(TRIM(obj_mbrindp1.mpolnum));
        v_zplancls  := obj_getmpol.zplancls;
        IF (TRIM(v_zplancls) = 'FP') THEN
          /**** MB4 :  MOD : condition change due to new requirement : START ****/
          --obj_gchipf.BTDATENR := v_temp_crdate;
          obj_gchipf.BTDATENR := TO_NUMBER(to_CHAR(to_date(v_temp_crdate,'YYYYMMDD') + 1,'yyyymmdd'));
          /**** MB4 :  MOD : condition change due to new requirement : END ****/
        ELSE
          v_btdatenr := DATCONOPERATION('MONTH', obj_gchipf.CCDATE);
        --  IF (TRIM(obj_mbrindp1.btdate) <> C_MAXDATE) THEN
        --    --v_btdatenr := DATCONOPERATION('DAY', obj_mbrindp1.btdate);
        --    v_btdatenr := DATCONOPERATION('MONTH', obj_gchipf.CCDATE); -- MB3: GCHIPF.CCDATE + 1 month
        --    --  dbms_output.put_line('obj_gchipf.BTDATENR : v_btdatenr      =>' ||      v_btdatenr);
        --    obj_gchipf.BTDATENR := v_btdatenr;
        --  ELSE
        --    obj_gchipf.BTDATENR := obj_mbrindp1.btdate;
        --  END IF;
        END IF;
      END IF;
      obj_gchipf.NRISDATE  := C_MAXDATE;
      obj_gchipf.CRATE     := obj_dfpopf.crate;
      obj_gchipf.TERNMPRM  := C_ZERO;
      obj_gchipf.SURGSCHMV := obj_dfpopf.surgschmv;
      obj_gchipf.AREACDEMV := obj_dfpopf.areacdemv;
      obj_gchipf.MEDPRVDR  := obj_dfpopf.medprvdr;
      obj_gchipf.SPSMBR    := obj_dfpopf.spsmbr;
      obj_gchipf.CHILDMBR  := obj_dfpopf.childmbr;
      obj_gchipf.SPSMED    := obj_dfpopf.spsmed;
      obj_gchipf.CHILDMED  := obj_dfpopf.childmed;
      obj_gchipf.TERMID    := i_vrcmTermid;
      --obj_gchipf.USER_T    := i_vrcmuser; --   obj_gchipf.USER      := 'a';
      obj_gchipf.USER_T := 36; --MB7
      obj_gchipf.TRDT   := i_trdt;
      obj_gchipf.TRTM   := i_vrcmtime;
      obj_gchipf.TRANNO := 1;
      --IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      --  obj_gchipf.TRANNO := v_seqnoincr;
      --ELSE
      --  obj_gchipf.TRANNO := v_seqno;
      --END IF;
      obj_gchipf.BANKCODE := obj_dfpopf.bankcode;
      obj_gchipf.BILLCHNL := obj_dfpopf.billchnl;
      obj_gchipf.MANDREF  := C_SPACE;
      obj_gchipf.RIMTHVCD := obj_dfpopf.rimthvcd;
      --  obj_gchipf.PRMRVWDT := C_MAXDATE;
      obj_gchipf.PRMRVWDT := C_ZERO; --MB7
      obj_gchipf.APPLTYP  := obj_dfpopf.appltyp;
      obj_gchipf.RIIND    := obj_dfpopf.riind;
      --  obj_gchipf.POLBREAK := o_defaultvalues('POLBREAK');
      obj_gchipf.POLBREAK := C_SPACE; --MB7
      obj_gchipf.CFTYPE   := C_SPACE;
      obj_gchipf.LMTDRL   := C_SPACE;
      obj_gchipf.CFLIMIT  := C_ZERO;
      obj_gchipf.NOFCLAIM := C_ZERO;
      -- obj_gchipf.TPA      := C_SPACE;--MB7 comment out as setting null
      obj_gchipf.WKLADRT := C_ZERO;
      obj_gchipf.WKLCMRT := C_ZERO;
      obj_gchipf.NOFMBR  := C_ZERO;
      --  obj_gchipf.ZCOLMCLS  := 'a';  --still in discussion
      obj_gchipf.USRPRF  := i_usrprf;
      obj_gchipf.JOBNM   := i_scheduleName;
      obj_gchipf.DATIME  := CAST(sysdate AS TIMESTAMP);
      obj_gchipf.ECNV    := o_defaultvalues('ECNV');
      obj_gchipf.CVNTYPE := o_defaultvalues('CVNTYPE');
      obj_gchipf.COVERNT := C_SPACE;
      /*   SELECT TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 0, 5)),
      TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 6, 5))
      into v_timech01, v_timech02
      FROM ITEMPF
      WHERE RTRIM(ITEMTABL) = 'TQ9GX'
      and TRIM(ITEMITEM) = 'SHIT902'
      AND RTRIM(ITEMCOY) = TRIM(i_company); */
      IF (itemexist.exists(TRIM('TQ9GX') || TRIM('SHIT902') || 1)) THEN
        -- v_timech01 := itemexist('SHIT902').timech01;
        --   v_timech02 := itemexist('SHIT902').timech02;
        v_timech01 := itemexist(TRIM('TQ9GX') || TRIM('SHIT902') || TRIM('1'))
                      .timech01;
        v_timech02 := itemexist(TRIM('TQ9GX') || TRIM('SHIT902') || TRIM('1'))
                      .timech02;
      END IF;
      obj_gchipf.TIMECH01 := v_timech01;
      obj_gchipf.TIMECH02 := v_timech02;
      obj_gchipf.TPAFLG   := C_SPACE;
      obj_gchipf.DOCRCDTE := obj_mbrindp1.docrcvdt;
      obj_gchipf.INSSTDTE := obj_mbrindp1.effdate;
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      /**** MB12 :  MOD : INSENDTE recalculation CRDATE+1 : START ****/
      SELECT to_number(TO_CHAR(to_date(obj_gchipf.CRDATE, 'yyyymmdd') + 1,
                               'yyyymmdd'))
        INTO v_insendate
        FROM dual;
      obj_gchipf.INSENDTE := v_insendate;
      /**** MB12 :  MOD : INSENDTE recalculation CRDATE+1 : END ****/
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      obj_gchipf.ZSOLCTFLG := obj_mbrindp1.zsolctflg;
      --- 17/02/2018 After Pre-SIT execution
      obj_gchipf.COWNNUM := v_zigvalue;
      ---03/05/18 SIT bug fix
      obj_gchipf.zcmpcode := obj_mbrindp1.zcmpcode;
      obj_gchipf.ZPENDDT  := v_temp_crdate;

      INSERT INTO GCHIPF VALUES obj_gchipf;
      ---Insert into IG table "GCHIPF" END ---
      ---Insert into IG table "GMHDPF" BEGIN (pq9ho.updateGmhdpf()) ---
      SELECT SEQ_GMHDPF.nextval INTO v_seq_gmhdpf FROM dual;
      obj_gmhdpf.unique_number := v_seq_gmhdpf;
      obj_gmhdpf.CHDRCOY       := i_company;
      obj_gmhdpf.CHDRNUM       := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gmhdpf.MBRNO         := o_defaultvalues('MBRNO');
      obj_gmhdpf.DPNTNO        := o_defaultvalues('DPNTNO');
      --- 17/02/2018 After Pre-SIT execution
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
        obj_gmhdpf.DTETRM := obj_mbrindp1.dtetrm;
      ELSE
        obj_gmhdpf.DTETRM := C_MAXDATE;
      END IF;
      --obj_gmhdpf.DTETRM := C_MAXDATE;
      obj_gmhdpf.REASONTRM := o_defaultvalues('REASONTRM');
      -- obj_gmhdpf.PNDATE    := obj_mbrindp1.docrcvdt;
      obj_gmhdpf.PNDATE  := C_MAXDATE;
      obj_gmhdpf.CLNTPFX := o_defaultvalues('CLNTPFX');
      obj_gmhdpf.FSUCO   := i_fsucocompany;
      obj_gmhdpf.CLNTNUM := v_zigvalue;
      obj_gmhdpf.HEADCNT := o_defaultvalues('HEADCNT');
      obj_gmhdpf.DTEATT  := obj_mbrindp1.effdate;
      --  obj_gmhdpf.MEDEVD  := C_SPACE;--MB7 comment out as setting null
      obj_gmhdpf.RELN    := o_defaultvalues('RELN');
      obj_gmhdpf.FAUWDT  := C_MAXDATE;
      obj_gmhdpf.LDPNTNO := o_defaultvalues('LDPNTNO');
      obj_gmhdpf.TERMID  := i_vrcmTermid;
      obj_gmhdpf.TRDT    := i_trdt;
      obj_gmhdpf.TRTM    := i_vrcmtime;
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
        obj_gmhdpf.TRANNO := v_seqnoincr;
      ELSE
        obj_gmhdpf.TRANNO := v_seqno;
      END IF;
      obj_gmhdpf.CLIENT := v_zigvalue;
      -- obj_gmhdpf.TERMRSNCD := o_defaultvalues('TERMRSNCD');--MB7 comment out as setting null
      -- obj_gmhdpf.REFIND    := o_defaultvalues('REFIND');--MB7 comment out as setting null
      --   obj_gmhdpf.EMPNO     := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.SMOKEIND  := C_SPACE;--MB7 comment out as setting null
      -- obj_gmhdpf.OCCPCLAS  := C_SPACE;--MB7 comment out as setting null
      -- obj_gmhdpf.ETHORG    := C_SPACE;--MB7 comment out as setting null
      obj_gmhdpf.GHEIGHT := C_ZERO;
      obj_gmhdpf.GWEIGHT := C_ZERO;
      --  obj_gmhdpf.PAYMMETH  := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.DEFCLMPYE := C_SPACE;--MB7 comment out as setting null
      obj_gmhdpf.PRVPOLDT := C_MAXDATE;
      -- obj_gmhdpf.DEPT      := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.NEWOLDCL  := C_SPACE;--MB7 comment out as setting null
      -- dbms_output.put_line('v_zigvalue      =>' || v_zigvalue);
      /* select CLTDOB
      into v_cltdob
      from CLNTPF
      where TRIM(CLNTNUM) = TRIM(v_zigvalue);*/
      /*  obj_getclnt := getclntinfo(TRIM(v_zigvalue));
      v_cltdob    := obj_getclnt.cltdob;*/
      v_cltdob    := clntdob(TRIM(v_zigvalue));
      v_datconage := DATEDIFF('YEAR', v_cltdob, obj_mbrindp1.effdate);
      --    dbms_output.put_line('v_datconage      =>' || v_datconage);
      obj_gmhdpf.AGE   := v_datconage;
      obj_gmhdpf.ORDOB := C_ZERO;
      -- obj_gmhdpf.STATCODE   := obj_mbrindp1.statcode;
      --   obj_gmhdpf.STATCODE   := C_SPACE;--MB7 comment out as setting null
      --   obj_gmhdpf.BANKACCKEY := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.APPLICNO   := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.CERTNO     := C_SPACE;--MB7 comment out as setting null
      obj_gmhdpf.MEDCMPDT := C_MAXDATE;
      /*  IF (TRIM(obj_mbrindp1.statcode) = 'IF') THEN
        obj_gmhdpf.INFORCE := o_defaultvalues('INFORCE');
      ELSE
        obj_gmhdpf.INFORCE := C_SPACE;
      END IF; */ --MB7 comment out as setting null
      --  obj_gmhdpf.WEIGHTUNIT := C_SPACE;--MB7 comment out as setting null
      -- obj_gmhdpf.HEIGHTUNIT := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhdpf.MBRTYPC    := C_SPACE;--MB7 comment out as setting null
      obj_gmhdpf.SIFACT := C_BIGDECIMAL_DEFAULT1;
      -- obj_gmhdpf.RDYPROC := C_SPACE; --MB7 comment out as setting null
      /*  IF (TRIM(obj_mbrindp1.statcode) = 'IF') THEN
      obj_gmhdpf.INSUFFMN := o_defaultvalues('INSUFFMN');
      ELSE
      obj_gmhdpf.INSUFFMN := C_SPACE;
      END IF;*/
      --   obj_gmhdpf.INSUFFMN := C_SPACE;
      obj_gmhdpf.INSUFFMN := 'Y'; --MB7 
      -- obj_gmhdpf.DPNTTYPE := C_SPACE; MB7 comment out as setting null
      obj_gmhdpf.USRPRF   := i_usrprf;
      obj_gmhdpf.JOBNM    := i_scheduleName;
      obj_gmhdpf.DATIME   := CAST(sysdate AS TIMESTAMP);
      obj_gmhdpf.USER_T   := i_vrcmuser;
      obj_gmhdpf.ZANNCLDT := obj_mbrindp1.zanncldt;
      obj_gmhdpf.ZCPNSCDE := obj_mbrindp1.zcmpcode ||
                             obj_mbrindp1.zcpnscde02;
      --  obj_gmhdpf.ZCPNSCDE  := C_SPACE;
      obj_gmhdpf.ZSALECHNL := obj_mbrindp1.zsalechnl;
      obj_gmhdpf.CLTRELN   := o_defaultvalues('RELN');

      INSERT INTO GMHDPF VALUES obj_gmhdpf;
      --------insert into IG table "GMOVPF"  BEGIN(pq9ho.updateGmhdpf())----
      -- IF (TRIM(obj_mbrindp1.statcode) <> 'PN') THEN  Previous code
      IF (TRIM(obj_mbrindp1.statcode) = 'XN') THEN
        v_olddta1 := obj_gmhdpf.Chdrcoy || obj_gmhdpf.Chdrnum ||
                     obj_gmhdpf.Mbrno || obj_gmhdpf.Dpntno || C_MAXDATE ||
                     obj_gmhdpf.Reasontrm || obj_gmhdpf.Clntpfx ||
                     obj_gmhdpf.Fsuco || obj_gmhdpf.Clntnum ||
                     obj_gmhdpf.Headcnt || obj_gmhdpf.Dteatt ||
                     obj_gmhdpf.Medevd || obj_gmhdpf.Reln ||
                     obj_gmhdpf.Fauwdt || obj_gmhdpf.Ldpntno ||
                     obj_gmhdpf.Termid ||
                    --  obj_gmhdpf.UserT ||
                     obj_gmhdpf.Trdt || obj_gmhdpf.Trtm ||
                     obj_gmhdpf.Tranno || obj_gmhdpf.Pndate ||
                     obj_gmhdpf.Client || obj_gmhdpf.Termrsncd ||
                     obj_gmhdpf.Refind || obj_gmhdpf.Empno ||
                     obj_gmhdpf.Smokeind || obj_gmhdpf.Occpclas ||
                     obj_gmhdpf.Ethorg || obj_gmhdpf.Gheight ||
                     obj_gmhdpf.Gweight || obj_gmhdpf.Paymmeth ||
                     obj_gmhdpf.Defclmpye || obj_gmhdpf.Prvpoldt ||
                     obj_gmhdpf.Dept || obj_gmhdpf.Newoldcl ||
                     obj_gmhdpf.Age || obj_gmhdpf.Ordob || 'IF' ||
                     obj_gmhdpf.Bankacckey || obj_gmhdpf.Applicno ||
                     obj_gmhdpf.Certno || obj_gmhdpf.Medcmpdt ||
                     obj_gmhdpf.Inforce || obj_gmhdpf.Weightunit ||
                     obj_gmhdpf.Heightunit || obj_gmhdpf.Mbrtypc ||
                     obj_gmhdpf.Sifact || obj_gmhdpf.Rdyproc ||
                     obj_gmhdpf.Insuffmn || obj_gmhdpf.Dpnttype ||
                     obj_gmhdpf.Usrprf || obj_gmhdpf.Jobnm ||
                     obj_gmhdpf.Datime || obj_gmhdpf.Zcpnscde ||
                     obj_gmhdpf.Zsalechnl;
        --obj_gmhdpf.Zanncldt();
        v_refkey              := obj_gmhdpf.Chdrcoy || obj_gmhdpf.Chdrnum ||
                                 obj_gmhdpf.Mbrno || obj_gmhdpf.Dpntno;
        obj_gmovpf1.Chdrcoy   := obj_gmhdpf.Chdrcoy;
        obj_gmovpf1.Chdrnum   := obj_gmhdpf.Chdrnum;
        obj_gmovpf1.Effdate   := obj_mbrindp1.effdate;
        obj_gmovpf1.Tranno    := 1;
        obj_gmovpf1.User_t    := obj_gmhdpf.User_t;
        obj_gmovpf1.Trdt      := obj_gmhdpf.Trdt;
        obj_gmovpf1.Trtm      := obj_gmhdpf.Trtm;
        obj_gmovpf1.Termid    := obj_gmhdpf.Termid;
        obj_gmovpf1.Batccoy   := i_company;
        obj_gmovpf1.Batcbrn   := i_branch;
        obj_gmovpf1.Batcactyr := i_acctYear;
        obj_gmovpf1.Batcactmn := i_acctMonth;
        IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
          obj_gmovpf1.Batctrcde := 'T913';
        ELSE
          obj_gmovpf1.Batctrcde := 'T903';
        END IF;
        obj_gmovpf1.Batcbatch := C_SPACE;
        obj_gmovpf1.Olddta    := v_olddta1;
        obj_gmovpf1.Newdta    := '';
        obj_gmovpf1.Funccode  := C_FUNCDEADDMBR;
        obj_gmovpf1.Refkey    := v_refkey;
        obj_gmovpf1.Rfmt      := 'GMHDREC';
        obj_gmovpf1.Chgtype   := '';
        obj_gmovpf1.Riprior   := ' ';
        obj_gmovpf1.Onpreflg  := '';
        obj_gmovpf1.Fachold   := '';
        obj_gmovpf1.Planvflg  := '';
        obj_gmovpf1.Usrprf    := i_usrprf;
        obj_gmovpf1.Jobnm     := i_scheduleName;
        obj_gmovpf1.Datime    := CAST(sysdate AS TIMESTAMP);
        INSERT INTO GMOVPF VALUES obj_gmovpf1;
      END IF;
      /* IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      v_olddta1 := obj_gmhdpf.Chdrcoy || obj_gmhdpf.Chdrnum ||
      obj_gmhdpf.Mbrno || obj_gmhdpf.Dpntno || C_MAXDATE ||
      obj_gmhdpf.Reasontrm || obj_gmhdpf.Clntpfx ||
      obj_gmhdpf.Fsuco || obj_gmhdpf.Clntnum ||
      obj_gmhdpf.Headcnt || obj_gmhdpf.Dteatt ||
      obj_gmhdpf.Medevd || obj_gmhdpf.Reln ||
      obj_gmhdpf.Fauwdt || obj_gmhdpf.Ldpntno ||
      obj_gmhdpf.Termid ||
      --  obj_gmhdpf.UserT ||
      obj_gmhdpf.Trdt || obj_gmhdpf.Trtm ||
      obj_gmhdpf.Tranno || obj_gmhdpf.Pndate ||
      obj_gmhdpf.Client || obj_gmhdpf.Termrsncd ||
      obj_gmhdpf.Refind || obj_gmhdpf.Empno ||
      obj_gmhdpf.Smokeind || obj_gmhdpf.Occpclas ||
      obj_gmhdpf.Ethorg || obj_gmhdpf.Gheight ||
      obj_gmhdpf.Gweight || obj_gmhdpf.Paymmeth ||
      obj_gmhdpf.Defclmpye || obj_gmhdpf.Prvpoldt ||
      obj_gmhdpf.Dept || obj_gmhdpf.Newoldcl ||
      obj_gmhdpf.Age || obj_gmhdpf.Ordob || 'IF' ||
      obj_gmhdpf.Bankacckey || obj_gmhdpf.Applicno ||
      obj_gmhdpf.Certno || obj_gmhdpf.Medcmpdt ||
      obj_gmhdpf.Inforce || obj_gmhdpf.Weightunit ||
      obj_gmhdpf.Heightunit || obj_gmhdpf.Mbrtypc ||
      obj_gmhdpf.Sifact || obj_gmhdpf.Rdyproc ||
      obj_gmhdpf.Insuffmn || obj_gmhdpf.Dpnttype ||
      obj_gmhdpf.Usrprf || obj_gmhdpf.Jobnm ||
      obj_gmhdpf.Datime || obj_gmhdpf.Zcpnscde ||
      obj_gmhdpf.Zsalechnl;
      --obj_gmhdpf.Zanncldt();
      v_newdta1 := obj_gmhdpf.Chdrcoy || obj_gmhdpf.Chdrnum ||
      obj_gmhdpf.Mbrno || obj_gmhdpf.Dpntno ||
      obj_gmhdpf.Dtetrm || obj_gmhdpf.Reasontrm ||
      obj_gmhdpf.Clntpfx || obj_gmhdpf.Fsuco ||
      obj_gmhdpf.Clntnum || obj_gmhdpf.Headcnt ||
      obj_gmhdpf.Dteatt || obj_gmhdpf.Medevd ||
      obj_gmhdpf.Reln || obj_gmhdpf.Fauwdt ||
      obj_gmhdpf.Ldpntno || obj_gmhdpf.Termid ||
      obj_gmhdpf.user_t || obj_gmhdpf.Trdt ||
      obj_gmhdpf.Trtm || obj_gmhdpf.Tranno ||
      obj_gmhdpf.Pndate || obj_gmhdpf.Client ||
      obj_gmhdpf.Termrsncd || obj_gmhdpf.Refind ||
      obj_gmhdpf.Empno || obj_gmhdpf.Smokeind ||
      obj_gmhdpf.Occpclas || obj_gmhdpf.Ethorg ||
      obj_gmhdpf.Gheight || obj_gmhdpf.Gweight ||
      obj_gmhdpf.Paymmeth || obj_gmhdpf.Defclmpye ||
      obj_gmhdpf.Prvpoldt || obj_gmhdpf.Dept ||
      obj_gmhdpf.Newoldcl || obj_gmhdpf.Age ||
      obj_gmhdpf.Ordob || obj_gmhdpf.Statcode ||
      obj_gmhdpf.Bankacckey || obj_gmhdpf.Applicno ||
      obj_gmhdpf.Certno || obj_gmhdpf.Medcmpdt ||
      obj_gmhdpf.Inforce || obj_gmhdpf.Weightunit ||
      obj_gmhdpf.Heightunit || obj_gmhdpf.Mbrtypc ||
      obj_gmhdpf.Sifact || obj_gmhdpf.Rdyproc ||
      obj_gmhdpf.Insuffmn || obj_gmhdpf.Dpnttype ||
      obj_gmhdpf.Usrprf || obj_gmhdpf.Jobnm ||
      obj_gmhdpf.Datime || obj_gmhdpf.Zcpnscde ||
      obj_gmhdpf.Zsalechnl || obj_gmhdpf.Zanncldt;
      v_refkey := obj_gmhdpf.Chdrcoy + obj_gmhdpf.Chdrnum +
      obj_gmhdpf.Mbrno + obj_gmhdpf.Dpntno;
      obj_gmovpf1.Chdrcoy   := obj_gmhdpf.Chdrcoy;
      obj_gmovpf1.Chdrnum   := obj_gmhdpf.Chdrnum;
      obj_gmovpf1.Effdate   := obj_mbrindp1.effdate;
      obj_gmovpf1.Tranno    := 2;
      obj_gmovpf1.User_t    := obj_gmhdpf.User_t;
      obj_gmovpf1.Trdt      := obj_gmhdpf.Trdt;
      obj_gmovpf1.Trtm      := obj_gmhdpf.Trtm;
      obj_gmovpf1.Termid    := obj_gmhdpf.Termid;
      obj_gmovpf1.Batccoy   := i_company;
      obj_gmovpf1.Batcbrn   := i_branch;
      obj_gmovpf1.Batcactyr := i_acctYear;
      obj_gmovpf1.Batcactmn := i_acctMonth;
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      obj_gmovpf1.Batctrcde := 'T913';
      ELSE
      obj_gmovpf1.Batctrcde := 'T913';
      END IF;
      obj_gmovpf1.Batcbatch := C_SPACE;
      obj_gmovpf1.Olddta    := v_olddta1;
      obj_gmovpf1.Newdta    := v_newdta1;
      obj_gmovpf1.Funccode  := C_FUNCDETRMBR;
      obj_gmovpf1.Refkey    := v_refkey;
      obj_gmovpf1.Rfmt      := 'GMHDREC';
      obj_gmovpf1.Chgtype   := '';
      obj_gmovpf1.Riprior   := ' ';
      obj_gmovpf1.Onpreflg  := '';
      obj_gmovpf1.Fachold   := '';
      obj_gmovpf1.Planvflg  := '';
      obj_gmovpf1.Usrprf    := i_usrprf;
      obj_gmovpf1.Jobnm     := i_scheduleName;
      obj_gmovpf1.Datime    := CAST(sysdate AS TIMESTAMP);
      Insert into GMOVPF values obj_gmovpf1;
      END IF;*/
      --------insert into IG table "GMOVPF"  END (pq9ho.updateGmhdpf())----
      ---Insert into IG table "GMHDPF" END ---
      ---Insert into IG table "GMHIPF" BEGIN  (pq9ho.updateGmhipf()) ---
      SELECT SEQ_GMHIPF.nextval INTO v_seq_gmhipf FROM dual;
      obj_gmhipf.unique_number := v_seq_gmhipf;
      obj_gmhipf.CHDRCOY       := i_company;
      obj_gmhipf.CHDRNUM       := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gmhipf.MBRNO         := o_defaultvalues('MBRNO');
      obj_gmhipf.DPNTNO        := o_defaultvalues('DPNTNO');
      obj_gmhipf.EFFDATE       := obj_mbrindp1.effdate;
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
        obj_gmhipf.DTETRM := obj_mbrindp1.dtetrm;
      ELSE
        obj_gmhipf.DTETRM := C_MAXDATE;
      END IF;
      --  obj_gmhipf.DTETRM   := C_MAXDATE;
      --  obj_gmhipf.SUBSCOY  := C_SPACE;  --MB7 comment out as setting null
      --  obj_gmhipf.SUBSNUM  := C_SPACE; --MB7 comment out as setting null
      --   obj_gmhipf.OCCPCODE := C_SPACE;  --MB7 comment out as setting null
      obj_gmhipf.SALARY := C_BIGDECIMAL_DEFAULT;
      obj_gmhipf.DTEAPP := C_MAXDATE;
      obj_gmhipf.SBSTDL := C_SPACE;
      obj_gmhipf.TERMID := i_vrcmTermid;
      obj_gmhipf.TRDT   := i_trdt;
      obj_gmhipf.TRTM   := i_vrcmtime;
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
        obj_gmhipf.TRANNO := v_seqnoincr;
      ELSE
        obj_gmhipf.TRANNO := v_seqno;
      END IF;
      --  obj_gmhipf.FUPFLG     := C_SPACE; --MB7 comment out as setting null
      --  obj_gmhipf.CLIENT     := v_zigvalue; --MB7 comment out as setting null
      obj_gmhipf.PERSONCOV := o_defaultvalues('PERSONCOV');
      obj_gmhipf.MLVLPLAN  := o_defaultvalues('MLVLPLAN');
      --  obj_gmhipf.CLNTCOY    := i_fsucocompany;
      obj_gmhipf.CLNTCOY := C_SPACE; --MB7
      -- obj_gmhipf.PCCCLNT    := C_SPACE;--MB7 comment out as setting null
      --  obj_gmhipf.APCCCLNT   := C_SPACE;--MB7 comment out as setting null
      obj_gmhipf.EARNING    := C_BIGDECIMAL_DEFAULT;
      obj_gmhipf.CTBPRCNT   := C_BIGDECIMAL_DEFAULT;
      obj_gmhipf.CTBAMT     := C_BIGDECIMAL_DEFAULT;
      obj_gmhipf.USRPRF     := i_usrprf;
      obj_gmhipf.JOBNM      := i_scheduleName;
      obj_gmhipf.DATIME     := CAST(sysdate AS TIMESTAMP);
      obj_gmhipf.ZTRXSTAT   := obj_mbrindp1.ztrxstat;
      obj_gmhipf.QUOTENO    := C_SPACE;
      obj_gmhipf.ZCPNSCDE   := obj_mbrindp1.ZCPNSCDE02; -- obj_gmhipf.ZCPNSCDE   := obj_mbrindp1.zcmpcode;
      obj_gmhipf.ZDCLITEM01 := obj_mbrindp1.zdclitem01;
      obj_gmhipf.ZDCLITEM02 := obj_mbrindp1.zdclitem02;
      obj_gmhipf.ZDCRSNCD   := o_defaultvalues('ZDCRSNCD');
      obj_gmhipf.ZDECLCAT   := C_SPACE;
      obj_gmhipf.ZDFCNCY    := obj_mbrindp1.zdfcncy;
      obj_gmhipf.DATATYPE   := o_defaultvalues('DATATYPE');
      /* select SUM(APREM)
      into v_zprmsi
      from STAGEDBUSR.TITDMGMBRINDP2
      where TRIM(REFNUM) = TRIM(obj_mbrindp1.refnum); */
      obj_gmhipf.ZPRMSI    := v_zprmsi;
      obj_gmhipf.ZADCHCTL  := o_defaultvalues('ZADCHCTL');
      obj_gmhipf.ZMARGNFLG := obj_mbrindp1.zmargnflg;
      obj_gmhipf.USER_T    := i_vrcmuser;
      --  obj_gmhipf.ZALTRCDE01 := o_defaultvalues('ZALTRCDE01');
      --  obj_gmhipf.ZALTRCDE02 := o_defaultvalues('ZALTRCDE02');
      --  obj_gmhipf.ZALTRCDE03 := o_defaultvalues('ZALTRCDE03');
      --  obj_gmhipf.ZALTRCDE04 := o_defaultvalues('ZALTRCDE04');
      --  obj_gmhipf.ZALTRCDE05 := o_defaultvalues('ZALTRCDE05');
      obj_gmhipf.DCLDATE   := obj_mbrindp1.dcldate;
      obj_gmhipf.NOTSFROM  := n_issdate;
      obj_gmhipf.ZSTATRESN := obj_mbrindp1.zstatresn;
      obj_gmhipf.HPROPDTE  := obj_mbrindp1.hpropdte;
      --   obj_gmhipf.ADDRINDC  := o_defaultvalues('ADDRINDC');
      obj_gmhipf.ADDRINDC  := C_SPACE; --MB7
      obj_gmhipf.ZWRKPCT   := o_defaultvalues('ZWRKPCT');
      obj_gmhipf.ZINHDSCLM := o_defaultvalues('ZINHDSCLM');
      obj_gmhipf.DOCRCDTE  := obj_mbrindp1.docrcvdt;
      --   obj_gmhipf.ISSTAFF   := C_SPACE; --MB7 comment out as setting null
      obj_gmhipf.ZPLANCDE := obj_mbrindp1.zplancde;
      obj_gmhipf.ZINTENT  := o_defaultvalues('ZINTENT');
      ---SIT Changes
      obj_gmhipf.zdeclcat := obj_mbrindp1.zdeclcat;
      INSERT INTO GMHIPF VALUES obj_gmhipf;
      --------insert into IG table "GMOVPF" for GMHIPF BEGIN(pq9ho.updateGmhdpf())----
      --IF (TRIM(obj_mbrindp1.statcode) <> 'PN') THEN  Previous code
      IF (TRIM(obj_mbrindp1.statcode) = 'XN') THEN
        v_olddta2             := obj_gmhipf.Chdrcoy || obj_gmhipf.Chdrnum ||
                                 obj_gmhipf.Mbrno || obj_gmhipf.Dpntno ||
                                 obj_gmhipf.Effdate || C_MAXDATE ||
                                 obj_gmhipf.Subscoy || obj_gmhipf.Subsnum ||
                                 obj_gmhipf.Occpcode || obj_gmhipf.Salary ||
                                 obj_gmhipf.Dteapp || obj_gmhipf.Sbstdl ||
                                 obj_gmhipf.Termid || obj_gmhipf.User_t ||
                                 obj_gmhipf.Trdt || obj_gmhipf.Trtm ||
                                 obj_gmhipf.Tranno || obj_gmhipf.Fupflg ||
                                 obj_gmhipf.Dpntno || obj_gmhipf.Client ||
                                 obj_gmhipf.Personcov ||
                                 obj_gmhipf.Mlvlplan || obj_gmhipf.Clntcoy ||
                                 obj_gmhipf.Pccclnt || obj_gmhipf.Apccclnt ||
                                 obj_gmhipf.Earning || obj_gmhipf.Ctbprcnt ||
                                 obj_gmhipf.Ctbamt || obj_gmhipf.Usrprf ||
                                 obj_gmhipf.Jobnm || obj_gmhipf.Datime ||
                                 obj_gmhipf.Isstaff || obj_gmhipf.Ztrxstat ||
                                 obj_gmhipf.Zstatresn || obj_gmhipf.Quoteno ||
                                 obj_gmhipf.Zplancde || obj_gmhipf.Hpropdte ||
                                 obj_gmhipf.Notsfrom || obj_gmhipf.Docrcdte ||
                                 obj_gmhipf.Dcldate || obj_gmhipf.Zdeclcat ||
                                 obj_gmhipf.Zdclitem01 ||
                                 obj_gmhipf.Zdclitem02 ||
                                 obj_gmhipf.Zdcrsncd ||
                                -- obj_gmhipf.Zaltrcde01 ||
                                --  obj_gmhipf.Zaltrcde02 || obj_gmhipf.Zaltrcde03 ||
                                --   obj_gmhipf.Zaltrcde04 || obj_gmhipf.Zaltrcde05 ||
                                 obj_gmhipf.Addrindc || obj_gmhipf.Zadchctl ||
                                 obj_gmhipf.Zmargnflg || obj_gmhipf.Zdfcncy ||
                                 obj_gmhipf.Zinhdsclm ||
                                 obj_gmhipf.Zcpnscde || obj_gmhipf.Zprmsi;
        v_refkey              := obj_gmhipf.Chdrcoy || obj_gmhipf.Chdrnum ||
                                 obj_gmhipf.Mbrno || obj_gmhipf.Dpntno ||
                                 obj_gmhipf.Effdate;
        obj_gmovpf2.Chdrcoy   := obj_gmhipf.Chdrcoy;
        obj_gmovpf2.Chdrnum   := obj_gmhipf.Chdrnum;
        obj_gmovpf2.Effdate   := obj_mbrindp1.effdate;
        obj_gmovpf2.Tranno    := 1;
        obj_gmovpf2.User_t    := obj_gmhipf.User_t;
        obj_gmovpf2.Trdt      := obj_gmhipf.Trdt;
        obj_gmovpf2.Trtm      := obj_gmhipf.Trtm;
        obj_gmovpf2.Termid    := obj_gmhipf.Termid;
        obj_gmovpf2.Batccoy   := i_company;
        obj_gmovpf2.Batcbrn   := i_branch;
        obj_gmovpf2.Batcactyr := i_acctYear;
        obj_gmovpf2.Batcactmn := i_acctMonth;
        IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
          obj_gmovpf2.Batctrcde := 'T913';
        ELSE
          obj_gmovpf2.Batctrcde := 'T903';
        END IF;
        obj_gmovpf2.Batcbatch := C_SPACE;
        obj_gmovpf2.Olddta    := v_olddta2;
        obj_gmovpf2.Newdta    := '';
        obj_gmovpf2.Funccode  := C_FUNCDEADDMBR;
        obj_gmovpf2.Refkey    := v_refkey;
        obj_gmovpf2.Rfmt      := 'GMHIREC';
        obj_gmovpf2.Chgtype   := '';
        obj_gmovpf2.Riprior   := ' ';
        obj_gmovpf2.Onpreflg  := '';
        obj_gmovpf2.Fachold   := '';
        obj_gmovpf2.Planvflg  := '';
        obj_gmovpf2.Usrprf    := i_usrprf;
        obj_gmovpf2.Jobnm     := i_scheduleName;
        obj_gmovpf2.Datime    := CAST(sysdate AS TIMESTAMP);
        INSERT INTO GMOVPF VALUES obj_gmovpf2;
      END IF;
      /* IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      v_olddta2 := obj_gmhipf.Chdrcoy || obj_gmhipf.Chdrnum ||
      obj_gmhipf.Mbrno || obj_gmhipf.Dpntno ||
      obj_gmhipf.Effdate || C_MAXDATE || obj_gmhipf.Subscoy ||
      obj_gmhipf.Subsnum || obj_gmhipf.Occpcode ||
      obj_gmhipf.Salary || obj_gmhipf.Dteapp ||
      obj_gmhipf.Sbstdl || obj_gmhipf.Termid ||
      obj_gmhipf.User_t || obj_gmhipf.Trdt ||
      obj_gmhipf.Trtm || obj_gmhipf.Tranno ||
      obj_gmhipf.Fupflg || obj_gmhipf.Dpntno ||
      obj_gmhipf.Client || obj_gmhipf.Personcov ||
      obj_gmhipf.Mlvlplan || obj_gmhipf.Clntcoy ||
      obj_gmhipf.Pccclnt || obj_gmhipf.Apccclnt ||
      obj_gmhipf.Earning || obj_gmhipf.Ctbprcnt ||
      obj_gmhipf.Ctbamt || obj_gmhipf.Usrprf ||
      obj_gmhipf.Jobnm || obj_gmhipf.Datime ||
      obj_gmhipf.Isstaff || obj_gmhipf.Ztrxstat ||
      obj_gmhipf.Zstatresn || obj_gmhipf.Quoteno ||
      obj_gmhipf.Zplancde || obj_gmhipf.Hpropdte ||
      obj_gmhipf.Notsfrom || obj_gmhipf.Docrcdte ||
      obj_gmhipf.Dcldate || obj_gmhipf.Zdeclcat ||
      obj_gmhipf.Zdclitem01 || obj_gmhipf.Zdclitem02 ||
      obj_gmhipf.Zdcrsncd ||
      --obj_gmhipf.Zaltrcde01 ||
      -- obj_gmhipf.Zaltrcde02 || obj_gmhipf.Zaltrcde03 ||
      -- obj_gmhipf.Zaltrcde04 || obj_gmhipf.Zaltrcde05 ||
      obj_gmhipf.Addrindc || obj_gmhipf.Zadchctl ||
      obj_gmhipf.Zmargnflg || obj_gmhipf.Zdfcncy ||
      obj_gmhipf.Zinhdsclm || obj_gmhipf.Zcpnscde ||
      obj_gmhipf.Zprmsi;
      v_newdta2 := obj_gmhipf.Chdrcoy || obj_gmhipf.Chdrnum ||
      obj_gmhipf.Mbrno || obj_gmhipf.Dpntno ||
      obj_gmhipf.Effdate || obj_gmhipf.Dtetrm ||
      obj_gmhipf.Subscoy || obj_gmhipf.Subsnum ||
      obj_gmhipf.Occpcode || obj_gmhipf.Salary ||
      obj_gmhipf.Dteapp || obj_gmhipf.Sbstdl ||
      obj_gmhipf.Termid || obj_gmhipf.User_t ||
      obj_gmhipf.Trdt || obj_gmhipf.Trtm ||
      obj_gmhipf.Tranno || obj_gmhipf.Fupflg ||
      obj_gmhipf.Dpntno || obj_gmhipf.Client ||
      obj_gmhipf.Personcov || obj_gmhipf.Mlvlplan ||
      obj_gmhipf.Clntcoy || obj_gmhipf.Pccclnt ||
      obj_gmhipf.Apccclnt || obj_gmhipf.Earning ||
      obj_gmhipf.Ctbprcnt || obj_gmhipf.Ctbamt ||
      obj_gmhipf.Usrprf || obj_gmhipf.Jobnm ||
      obj_gmhipf.Datime || obj_gmhipf.Isstaff ||
      obj_gmhipf.Ztrxstat || obj_gmhipf.Zstatresn ||
      obj_gmhipf.Quoteno || obj_gmhipf.Zplancde ||
      obj_gmhipf.Hpropdte || obj_gmhipf.Notsfrom ||
      obj_gmhipf.Docrcdte || obj_gmhipf.Dcldate ||
      obj_gmhipf.Zdeclcat || obj_gmhipf.Zdclitem01 ||
      obj_gmhipf.Zdclitem02 || obj_gmhipf.Zdcrsncd ||
      -- obj_gmhipf.Zaltrcde01 || obj_gmhipf.Zaltrcde02 ||
      --    obj_gmhipf.Zaltrcde03 || obj_gmhipf.Zaltrcde04 ||
      --  obj_gmhipf.Zaltrcde05 ||
      obj_gmhipf.Addrindc || obj_gmhipf.Zadchctl ||
      obj_gmhipf.Zmargnflg || obj_gmhipf.Zdfcncy ||
      obj_gmhipf.Zinhdsclm || obj_gmhipf.Zcpnscde ||
      obj_gmhipf.Zprmsi;
      v_refkey := obj_gmhipf.Chdrcoy + obj_gmhipf.Chdrnum +
      obj_gmhipf.Mbrno + obj_gmhipf.Dpntno +
      obj_gmhipf.Effdate;
      obj_gmovpf2.Chdrcoy   := obj_gmhipf.Chdrcoy;
      obj_gmovpf2.Chdrnum   := obj_gmhipf.Chdrnum;
      obj_gmovpf2.Effdate   := obj_gmhipf.effdate;
      obj_gmovpf2.Tranno    := 2;
      obj_gmovpf2.User_t    := obj_gmhipf.User_t;
      obj_gmovpf2.Trdt      := obj_gmhipf.Trdt;
      obj_gmovpf2.Trtm      := obj_gmhipf.Trtm;
      obj_gmovpf2.Termid    := obj_gmhipf.Termid;
      obj_gmovpf2.Batccoy   := i_company;
      obj_gmovpf2.Batcbrn   := i_branch;
      obj_gmovpf2.Batcactyr := i_acctYear;
      obj_gmovpf2.Batcactmn := i_acctMonth;
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      obj_gmovpf2.Batctrcde := 'T913';
      ELSE
      obj_gmovpf2.Batctrcde := 'T903';
      END IF;
      obj_gmovpf2.Batcbatch := C_SPACE;
      obj_gmovpf2.Olddta    := v_olddta2;
      obj_gmovpf2.Newdta    := v_newdta2;
      obj_gmovpf2.Funccode  := C_FUNCDETRMBR;
      obj_gmovpf2.Refkey    := v_refkey;
      obj_gmovpf2.Rfmt      := 'GMHIREC';
      obj_gmovpf2.Chgtype   := '';
      obj_gmovpf2.Riprior   := ' ';
      obj_gmovpf2.Onpreflg  := '';
      obj_gmovpf2.Fachold   := '';
      obj_gmovpf2.Planvflg  := '';
      obj_gmovpf2.Usrprf    := i_usrprf;
      obj_gmovpf2.Jobnm     := i_scheduleName;
      obj_gmovpf2.Datime    := CAST(sysdate AS TIMESTAMP);
      Insert into GMOVPF values obj_gmovpf2;
      END IF;*/
      --------insert into IG table "GMOVPF" for GMHIPF  END (pq9ho.updateGmhdpf())----
      ---Insert into IG table "GMHIPF" END ---
      /* ITR3 Changes  removed ZMCIPF table
      ---Insert into IG table "ZMCIPF " BEGIN  (ZmcipfDAOImpl.updateZmcipf(), pq9ho.updateUniquePerEndorserTab) ---
      -- obj_zmcipf.CHDRCOY      := 'a';  --Not present in Table,Not even mentioned in Data model
      obj_zmcipf.CHDRNUM := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      --obj_zmcipf.MBRNO        := 'a'; --Not present in Table,Not even mentioned in Data model
      IF (TRIM(obj_mbrindp1.statcode) = 'CA') THEN
      obj_zmcipf.TRANNO := 2;
      ELSE
      obj_zmcipf.TRANNO := 1;
      END IF;
      obj_zmcipf.ZENDCDE := obj_mbrindp1.zendcde; --  obj_zmcipf.ZENDCODE     := 'a';
      obj_zmcipf.ZENSPCD01 := obj_mbrindp1.zenspcd01;
      IF (((TRIM(obj_mbrindp1.zenspcd02) IS NULL) OR
      ((TRIM(obj_mbrindp1.zcifcode))) IS NULL) AND
      ((TRIM(obj_mbrindp1.zenspcd01) IS NOT NULL))) THEN
      select ZENSPCD02, ZCIFCODE
      into v_zenspcd02_1, v_zcifcode
      from ZCLEPF
      where TRIM(clntnum) = TRIM(v_zigvalue)
      and TRIM(zenspcd01) = TRIM(obj_mbrindp1.zenspcd01)
      and TRIM(zendcde) = TRIM(obj_mbrindp1.zendcde);
      END IF;
      IF ((TRIM(obj_mbrindp1.zenspcd02)) IS NOT NULL) THEN
      obj_zmcipf.ZENSPCD02 := obj_mbrindp1.zenspcd02;
      ELSE
      obj_zmcipf.ZENSPCD02 := v_zenspcd02_1;
      END IF;
      IF ((TRIM(obj_mbrindp1.zcifcode)) IS NOT NULL) THEN
      obj_zmcipf.ZCIFCODE := obj_mbrindp1.zcifcode;
      ELSE
      obj_zmcipf.ZCIFCODE := v_zcifcode;
      END IF;
      obj_zmcipf.CRDTCARD     := obj_mbrindp1.crdtcard;
      obj_zmcipf.BANKACCKEY01 := obj_mbrindp1.bnkacckey01;
      \* BEGIN
      IF (TRIM(obj_mbrindp1.bnkacckey01) IS NOT NULL) THEN
      select bankaccdsc, bnkactyp, bankkey
      into v_bankaccdsc, v_bnkactyp, v_bankkey
      from CLBAPF
      where TRIM(bankacckey) = TRIM(obj_mbrindp1.bnkacckey01)
      AND TRIM(Clntpfx) = TRIM('CN')
      and TRIM(Clntcoy) = TRIM(i_fsucocompany)
      and TRIM(clntnum) = TRIM(v_zigvalue)
      and TRIM(validflag) = TRIM('1')
      and TRIM(bnkactyp) = TRIM('CC');
      END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      v_bankaccdsc := null;
      v_bnkactyp   := null;
      v_bankkey    := null;
      END;
      *\
      IF (TRIM(obj_mbrindp1.bnkacckey01) IS NOT NULL) THEN
      IF (getclba.exists(TRIM(obj_mbrindp1.bnkacckey01) ||
      TRIM(v_zigvalue) || TRIM(i_fsucocompany))) THEN
      v_obj_clba   := getclba(TRIM(obj_mbrindp1.bnkacckey01) ||
      TRIM(v_zigvalue) || TRIM(i_fsucocompany));
      v_bankaccdsc := v_obj_clba.bankaccdsc;
      v_bnkactyp   := v_obj_clba.bnkactyp;
      v_bankkey    := v_obj_clba.bankkey;
      END IF;
      END IF;
      obj_zmcipf.BANKACCDSC01 := v_bankaccdsc;
      obj_zmcipf.BNKACTYP01   := v_bnkactyp;
      obj_zmcipf.BANKACCKEY02 := C_SPACE;
      obj_zmcipf.BANKACCDSC02 := C_SPACE;
      obj_zmcipf.BNKACTYP02   := C_SPACE;
      --  obj_zmcipf.ZBANKCD      := 'a';
      --   obj_zmcipf.ZBRANCHCD    := 'a';
      obj_zmcipf.ZPBCTYPE := C_SPACE;
      obj_zmcipf.ZPBCODE  := C_SPACE;
      obj_zmcipf.PREAUTNO := obj_mbrindp1.preautno;
      \* BEGIN
      IF (TRIM(obj_mbrindp1.crdtcard) IS NOT NULL) THEN
      select MTHTO, YEARTO
      into v_mthto, v_yearto
      from CLBAPF
      where TRIM(bankacckey) = TRIM(obj_mbrindp1.crdtcard)
      AND TRIM(Clntpfx) = TRIM('CN')
      and TRIM(Clntcoy) = TRIM(i_fsucocompany)
      and TRIM(clntnum) = TRIM(v_zigvalue)
      and TRIM(validflag) = TRIM('1')
      and TRIM(bnkactyp) = TRIM('CC');
      END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      obj_zmcipf.MTHTO  := 0;
      obj_zmcipf.YEARTO := 0;
      END;*\
      IF (TRIM(obj_mbrindp1.crdtcard) IS NOT NULL) THEN
      IF (getclba.exists(TRIM(obj_mbrindp1.crdtcard) || TRIM(v_zigvalue) ||
      TRIM(i_fsucocompany))) THEN
      v_obj_clba := getclba(TRIM(obj_mbrindp1.crdtcard) ||
      TRIM(v_zigvalue) || TRIM(i_fsucocompany));
      v_mthto    := v_obj_clba.mthto;
      v_yearto   := v_obj_clba.yearto;
      END IF;
      END IF;
      obj_zmcipf.MTHTO  := v_mthto;
      obj_zmcipf.YEARTO := v_yearto;
      obj_zmcipf.DATIME := CAST(sysdate AS TIMESTAMP);
      obj_zmcipf.JOBNM  := i_scheduleName;
      BEGIN
      IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
      IF LENGTH(TRIM(obj_mbrindp1.crdtcard)) > 6 THEN
      v_temp_crdtcard := SUBSTR(TRIM(obj_mbrindp1.crdtcard), 0, 6);
      --  dbms_output.put_line('v_temp_crdtcard--'||v_temp_crdtcard);
      END IF;
      SELECT ZCRDTYPE
      into v_zcrdtype
      FROM ZENCTPF
      WHERE TRIM(ZPOLNMBR) = obj_mbrindp1.mpolnum
      and ((TRIM(TO_NUMBER(ZCNBRFRM)) < TRIM(v_temp_crdtcard) and
      TRIM(TO_NUMBER(ZCNBRTO)) > TRIM(v_temp_crdtcard)) OR
      TRIM(TO_NUMBER(ZCNBRFRM)) = TRIM(v_temp_crdtcard) OR
      TRIM(TO_NUMBER(ZCNBRTO)) = TRIM(v_temp_crdtcard));
      ELSE
      SELECT ZCRDTYPE
      into v_zcrdtype
      FROM ZENCTPF
      WHERE TRIM(ZENDCDE) = TRIM(obj_mbrindp1.zendcde)
      and ((TRIM(TO_NUMBER(ZCNBRFRM)) < TRIM(v_temp_crdtcard) and
      TRIM(TO_NUMBER(ZCNBRTO)) > TRIM(v_temp_crdtcard)) OR
      TRIM(TO_NUMBER(ZCNBRFRM)) = TRIM(v_temp_crdtcard) OR
      TRIM(TO_NUMBER(ZCNBRTO)) = TRIM(v_temp_crdtcard));
      END IF;
      EXCEPTION
      when No_data_found then
      v_zcrdtype := null;
      end;
      obj_zmcipf.CARDTYP := v_zcrdtype;
      obj_zmcipf.BANKKEY := v_bankkey;
      obj_zmcipf.USRPRF  := i_usrprf;
      --  obj_zmcipf.DPNTNO       := 'a'; --Not present in Table,Not even mentioned in Data model
      insert into ZMCIPF values obj_zmcipf;
      ---Insert into IG table "ZMCIPF" END ---*/
      ---Insert into IG table "ZCLEPF" START ---*/
      --- 17/02/2018 After Pre-SIT execution
      --- IF (TRIM(obj_mbrindp1.ZENSPCD01) IS NOT NULL) THEN
      IF ((TRIM(obj_mbrindp1.ZENSPCD01) IS NOT NULL) OR
         (TRIM(obj_mbrindp1.ZENSPCD02) IS NOT NULL) OR
         (TRIM(obj_mbrindp1.Zcifcode) IS NOT NULL)) THEN
        -- MB12  : MOD : Cratte ZCLEPF iff one of them given
        obj_zclepf.CLNTNUM := obj_gchd.COWNNUM;
        obj_zclepf.ZENDCDE := obj_gchppf.ZENDCDE;
        obj_zclepf.ZENSPCD01 := obj_mbrindp1.ZENSPCD01;
        obj_zclepf.ZENSPCD02 := obj_mbrindp1.ZENSPCD02;
        obj_zclepf.ZCIFCODE := obj_mbrindp1.ZCIFCODE;
        obj_zclepf. usrprf := i_usrprf; --MB7 New Added
        obj_zclepf.JOBNM := i_scheduleName; --MB7 New Added
        obj_zclepf.DATIME := CAST(sysdate AS TIMESTAMP); --MB7 New Added
        INSERT INTO ZCLEPF VALUES obj_zclepf;
        ---Insert into IG table "ZCLEPF" END ---*/
      END IF;
      ---Insert into IG table "GPSUPF" END ---*/
      obj_gpsupf. chdrcoy := i_company;
      obj_gpsupf. chdrnum := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      obj_gpsupf. subscoy := i_fsucocompany;
      /*      select ZCLNTID
      into v_zclntid
      from ZENDRPF
      where TRIM(ZENDCDE) = TRIM(obj_gchppf.ZENDCDE);*/
      IF (zendcde.exists(TRIM(obj_mbrindp1.zendcde))) THEN
        v_zclntid := zendcde(TRIM(obj_mbrindp1.zendcde));
      ELSE
        v_zclntid := NULL;
      END IF;
      obj_gpsupf. subsnum := v_zclntid;
      obj_gpsupf. dteatt := obj_gchipf.ccdate;
      obj_gpsupf. dtetrm := C_MAXDATE;
      obj_gpsupf. reasontrm := C_SPACE;
      obj_gpsupf. lnbillno := C_ZERO;
      obj_gpsupf. labillno := C_ZERO;
      obj_gpsupf. lpbillno := C_ZERO;
      obj_gpsupf. ptdate := C_MAXDATE;
      obj_gpsupf. ptdateab := C_MAXDATE;
      obj_gpsupf. termid := i_vrcmTermid;
      obj_gpsupf. user_t := i_vrcmuser;
      obj_gpsupf. trdt := i_trdt;
      obj_gpsupf. trtm := i_vrcmtime;
      obj_gpsupf. tranno := '1';
      obj_gpsupf. schdflg := C_SPACE;
      obj_gpsupf. mandref := C_SPACE;
      obj_gpsupf. usrprf := i_usrprf;
      obj_gpsupf.JOBNM := i_scheduleName;
      obj_gpsupf.DATIME := CAST(sysdate AS TIMESTAMP);
      obj_gpsupf. sinfdte := C_MAXDATE;
      INSERT INTO gpsupf VALUES obj_gpsupf;
      ---Insert into IG table "GPSUPF" END ---*/
      ---ITR4 CHANGE INSERT ZCELINKPF START----------------
      obj_zcelinkpf.CLNTPFX := TRIM(o_defaultvalues('CLNTPFX'));
      obj_zcelinkpf.CLNTCOY := TRIM(i_fsucocompany);
      obj_zcelinkpf.CLNTNUM := TRIM(obj_gchd.COWNNUM);
      obj_zcelinkpf.ZENDCDE := TRIM(obj_mbrindp1.zendcde);
      obj_zcelinkpf.USRPRF  := i_usrprf;
      obj_zcelinkpf.JOBNM   := i_scheduleName;
      obj_zcelinkpf.DATIME  := CAST(sysdate AS TIMESTAMP);
      INSERT INTO Jd1dta.VIEW_DM_ZCELINKPF VALUES obj_zcelinkpf;
      ---ITR4 CHANGE INSERT ZCELINKPF END----------------
      INSERT INTO PAZDRPPF
        (CHDRNUM, PREFIX, JOBNUM, JOBNAME)
      VALUES
        (TRIM(v_refnump1), v_prefix, i_scheduleNumber, i_scheduleName);
    END IF;
    /*   mbrmigindex := mbrmigindex + 1;
    mbrmig_list.extend;
    mbrmig_list(mbrmigindex) := obj_mbrmig;*/
  END LOOP;
  CLOSE cur_mbr_ind_p1;
  OPEN cur_mbr_ind_p2;
  <<skipRecordp2>>
  LOOP
    FETCH cur_mbr_ind_p2
      INTO obj_mbrindp2;
    EXIT WHEN cur_mbr_ind_p2%NOTFOUND;
    v_refKeyp2 := TRIM(obj_mbrindp2.refnum) || '-' ||
                  TRIM(obj_mbrindp2.prodtyp);
    --  dbms_output.put_line('v_refKeyp2 ==>' || v_refKeyp2);
    -- v_temprefKeyp2    := '''' || v_refKeyp2 || '''';
    -- v_constructrefkey := CONCAT(v_constructrefkey, v_temprefKeyp2);
    --   v_constructrefkey := CONCAT(v_constructrefkey, ',');
	----------MB13: START-----------------
	v_seqno1     := SUBSTR(TRIM(obj_mbrindp2.refnum), 9, 3);
    v_seqnoincr  := v_seqno1 + 1;
    v_seqno      := 1;
    SELECT SEQTMP1.nextval INTO SEQMBRTMP2 from dual;
	----------MB13: ENDS---------------------
    ----------Initialization -------
    IF (mbrp1info.exists(TRIM(obj_mbrindp2.refnum))) THEN
      i_refnum    := mbrp1info(TRIM(obj_mbrindp2.refnum)).refnum;
      i_cnttypind := mbrp1info(TRIM(obj_mbrindp2.refnum)).cnttypind;
      i_mpolnum   := mbrp1info(TRIM(obj_mbrindp2.refnum)).mpolnum;
      i_statcode  := mbrp1info(TRIM(obj_mbrindp2.refnum)).statcode;
      i_dtetrm    := mbrp1info(TRIM(obj_mbrindp2.refnum)).dtetrm;
      i_zplancde  := mbrp1info(TRIM(obj_mbrindp2.refnum)).zplancde;
      i_effdate   := mbrp1info(TRIM(obj_mbrindp2.refnum)).effdate;
      i_ZWAITPEDT := mbrp1info(TRIM(obj_mbrindp2.refnum)).zwaitpedt;
      i_zpoltdate := mbrp1info(TRIM(obj_mbrindp2.refnum)).zpoltdate;
      i_zpdatatxflag := mbrp1info(TRIM(obj_mbrindp2.refnum)).zpdatatxflag;
      i_ztrxstat := mbrp1info(TRIM(obj_mbrindp2.refnum)).ztrxstat;
      --MB16 IF (b_checkpolst.exists(TRIM(i_refnum))) THEN
      --MB16  i_statcode := b_checkpolst(i_refnum);
      --MB16 END IF; ---MB12 
      --  dbms_output.put_line('i_refnum = ' || i_refnum || 'i_cnttypind=' || i_cnttypind || 'i_mpolnum=' || i_mpolnum || 'i_statcode=' || i_statcode || 'i_dtetrm=' || i_dtetrm || 'i_zplancde=' || i_zplancde || 'i_effdate=' || i_effdate);

    ELSE
      CONTINUE skipRecordp2;
    END IF;
    IF TRIM(i_cnttypind) = 'I' THEN
      v_prefix := C_PREFIX_INDV;
    ELSE
      v_prefix := C_PREFIX_MEBR;
    END IF;
    i_zdoe_infop2              := NULL;
    i_zdoe_infop2.i_zfilename  := 'TITDMGMBRINDP2';
    i_zdoe_infop2.i_prefix     := v_prefix;
    i_zdoe_infop2.i_scheduleno := i_scheduleNumber;
    i_zdoe_infop2.i_refKey     := TRIM(v_refKeyp2);
    IF (TRIM(v_prefix) = 'MB') THEN
      i_zdoe_infop2.i_tableName := v_tableNameMB;
    ELSE
      i_zdoe_infop2.i_tableName := v_tableNameIN;
    END IF;
    /* IF (TRIM(v_prefix) = 'MB') THEN
    --   i_zdoe_infop2.i_tablecnt := v_zdoecrtcountMB;
    v_zdoecrtcountMB         := 1;
    ELSE
    i_zdoe_infop2.i_tablecnt := v_zdoecrtcountIN;
    v_zdoecrtcountIN         := 1;
    END IF;*/
    v_isAnyErrorp2 := 'N';
    v_errorCountp2 := 0;
    t_ercodep2(1) := NULL;
    t_ercodep2(2) := NULL;
    t_ercodep2(3) := NULL;
    t_ercodep2(4) := NULL;
    t_ercodep2(5) := NULL;
    /*
    gxhipfindex  := 0;
    gmovpf3PNindex  := 0;
    gmovpf3CAindex  := 0;
    gaphpfindex  := 0;
    mtrnpfCAindex  := 0;
    mtrnpfPNindex  := 0;*/
    v_zprmsi := v_zprmsi + obj_mbrindp2.aprem;
    ----------Initialization -------
    ---------------First part of validation -TITDMGMBRINDP2----------------------------------------
    ---REFNUM NULL VALIDATION
    IF TRIM(obj_mbrindp2.refnum) IS NULL THEN
      v_isAnyErrorp2 := 'Y';
      v_GlobalErrorp2 := 'Y';
      v_errorCountp2 := v_errorCountp2 + 1;
      t_ercodep2(v_errorCountp2) := C_Z082;
      t_errorfieldp2(v_errorCountp2) := 'REFNUM';
      t_errormsgp2(v_errorCountp2) := o_errortext(C_Z082);
      t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.refnum;
      t_errorprogramp2(v_errorCountp2) := i_scheduleName;
      GOTO insertzdoep2;
    END IF;
    ---PRODTYP NULL VALIDATION
    IF TRIM(obj_mbrindp2.prodtyp) IS NULL THEN
      v_isAnyErrorp2 := 'Y';
      v_GlobalErrorp2 := 'Y';
      v_errorCountp2 := v_errorCountp2 + 1;
      t_ercodep2(v_errorCountp2) := C_Z091;
      t_errorfieldp2(v_errorCountp2) := 'PRODTYP';
      t_errormsgp2(v_errorCountp2) := o_errortext(C_Z091);
      t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.prodtyp;
      t_errorprogramp2(v_errorCountp2) := i_scheduleName;
      GOTO insertzdoep2;
    END IF;
    /* MPS Performance Issue - There is no need to perform this as PK should not allow duplicates
    --REFNUM+PRODTYP duplicate check validation
    IF ((TRIM(obj_mbrindp2.prodtyp) IS NOT NULL) AND
    (TRIM(obj_mbrindp2.refnum) IS NOT NULL)) THEN
    select count(*)
    into v_isduplicatep2
    from TITDMGMBRINDP2@DMSTAGEDBLINK
    where TRIM(REFNUM) = TRIM(obj_mbrindp2.refnum)
    AND TRIM(PRODTYP) = TRIM(obj_mbrindp2.prodtyp);
    IF TRIM(v_isduplicatep2) > 1 THEN
    v_GlobalErrorp2 := 'Y';
    v_errorCountp2 := v_errorCountp2 + 1;
    t_ercodep2(v_errorCountp2) := C_Z099;
    t_errorfieldp2(v_errorCountp2) := 'REFNUM';
    t_errormsgp2(v_errorCountp2) := o_errortext(C_Z099);
    t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.refnum;
    t_errorprogramp2(v_errorCountp2) := i_scheduleName;
    IF (v_errorCountp2 = C_ERRORCOUNTP2) THEN
    GOTO insertzdoep2;
    END IF;
    END IF;
    END IF;
    */
    --MPS
    ----EFFDATE Validation
    ----------------MB2:policy not migrated----
    IF (TRIM(obj_mbrindp2.chdrnum_b) IS NULL) THEN
      v_isAnyErrorp2                 := 'Y';
      v_errorCountp2                 := v_errorCountp2 + 1;
      i_zdoe_infop2.i_indic          := 'E';
      i_zdoe_infop2.i_error01        := 'PLNM';
      i_zdoe_infop2.i_errormsg01     := 'Policy Not migrated';
      i_zdoe_infop2.i_errorprogram01 := i_scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_infop2);
      CONTINUE skipRecordp2;
    END IF;
    --------------MB2:policy not migrated-------------
    v_iseffdate := VALIDATE_DATE(TRIM(obj_mbrindp2.effdate));
    IF ((TRIM(obj_mbrindp2.effdate) IS NULL) OR (TRIM(v_iseffdate) <> 'OK')) THEN
      v_isAnyErrorp2 := 'Y';
      v_GlobalErrorp2 := 'Y';
      v_errorCountp2 := v_errorCountp2 + 1;
      t_ercodep2(v_errorCountp2) := C_Z013;
      t_errorfieldp2(v_errorCountp2) := 'EFFDATE';
      t_errormsgp2(v_errorCountp2) := o_errortext(C_Z013);
      t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.effdate;
      t_errorprogramp2(v_errorCountp2) := i_scheduleName;
      IF (v_errorCountp2 = C_ERRORCOUNTP2) THEN
        GOTO insertzdoep2;
      END IF;
    END IF;
    ----HSUMINSU Validation
    /* IF (TRIM(obj_mbrindp2.hsuminsu) = C_ZERO) THEN
    v_isAnyErrorp2 := 'Y';
    v_GlobalErrorp2 := 'Y';
    v_errorCountp2 := v_errorCountp2 + 1;
    t_ercodep2(v_errorCountp2) := C_Z092;
    t_errorfieldp2(v_errorCountp2) := 'HSUMINSU';
    t_errormsgp2(v_errorCountp2) := o_errortext(C_Z092);
    t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.hsuminsu;
    t_errorprogramp2(v_errorCountp2) := i_scheduleName;
    IF (v_errorCountp2 = C_ERRORCOUNTP2) THEN
    GOTO insertzdoep2;
    END IF;
    END IF; */
    ---------------second part of validation -TITDMGMBRINDP2----------------------------------------
    --PRODTYP validation
    IF TRIM(obj_mbrindp2.prodtyp) IS NOT NULL THEN
      IF NOT
          (itemexist.exists(TRIM('T9797') || TRIM(obj_mbrindp2.prodtyp) || 1)) THEN
        v_isAnyErrorp2 := 'Y';
        v_GlobalErrorp2 := 'Y';
        v_errorCountp2 := v_errorCountp2 + 1;
        t_ercodep2(v_errorCountp2) := C_Z014;
        t_errorfieldp2(v_errorCountp2) := 'PRODTYP';
        t_errormsgp2(v_errorCountp2) := o_errortext(C_Z014);
        t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.prodtyp;
        t_errorprogramp2(v_errorCountp2) := i_scheduleName;
        IF (v_errorCountp2 = C_ERRORCOUNTP2) THEN
          GOTO insertzdoep2;
        END IF;
      END IF;
    END IF;
    /**** ITR-4_LOT2 :  MB6 - MOD : condition change due to new requirement : START ****/
    IF (TRIM(obj_mbrindp2.ZTAXFLG) <> 'Y') AND
       (TRIM(obj_mbrindp2.ZTAXFLG) <> 'N') THEN
      v_isAnyErrorp2 := 'Y';
      v_GlobalErrorp2 := 'Y';
      v_errorCountp2 := v_errorCountp2 + 1;
      t_ercodep2(v_errorCountp2) := C_Z028;
      t_errorfieldp2(v_errorCountp2) := 'ZTAXFLG';
      t_errormsgp2(v_errorCountp2) := o_errortext(C_Z028);
      t_errorfieldvalp2(v_errorCountp2) := obj_mbrindp2.ZTAXFLG;
      t_errorprogramp2(v_errorCountp2) := i_scheduleName;
      IF (v_errorCountp2 = C_ERRORCOUNTP2) THEN
        GOTO insertzdoep2;
      END IF;
    END IF;
    /**** ITR-4_LOT2 :  MB6 - MOD : condition change due to new requirement : END ****/
    -------------------------------Insert into ZDOEPF for P2 : START---------------------------------------
    <<insertzdoep2>>
    IF (v_isAnyErrorp2 = 'Y') THEN
      IF TRIM(t_ercodep2(1)) IS NOT NULL THEN
        i_zdoe_infop2.i_indic          := C_ERROR;
        i_zdoe_infop2.i_error01        := t_ercodep2(1);
        i_zdoe_infop2.i_errormsg01     := t_errormsgp2(1);
        i_zdoe_infop2.i_errorfield01   := t_errorfieldp2(1);
        i_zdoe_infop2.i_fieldvalue01   := t_errorfieldvalp2(1);
        i_zdoe_infop2.i_errorprogram01 := t_errorprogramp2(1);
      END IF;
      IF TRIM(t_ercodep2(2)) IS NOT NULL THEN
        i_zdoe_infop2.i_indic          := C_ERROR;
        i_zdoe_infop2.i_error02        := t_ercodep2(2);
        i_zdoe_infop2.i_errormsg02     := t_errormsgp2(2);
        i_zdoe_infop2.i_errorfield02   := t_errorfieldp2(2);
        i_zdoe_infop2.i_fieldvalue02   := t_errorfieldvalp2(2);
        i_zdoe_infop2.i_errorprogram02 := t_errorprogramp2(2);
      END IF;
      IF TRIM(t_ercodep2(3)) IS NOT NULL THEN
        i_zdoe_infop2.i_indic          := C_ERROR;
        i_zdoe_infop2.i_error03        := t_ercodep2(3);
        i_zdoe_infop2.i_errormsg03     := t_errormsgp2(3);
        i_zdoe_infop2.i_errorfield03   := t_errorfieldp2(3);
        i_zdoe_infop2.i_fieldvalue03   := t_errorfieldvalp2(3);
        i_zdoe_infop2.i_errorprogram03 := t_errorprogramp2(3);
      END IF;
      IF TRIM(t_ercodep2(4)) IS NOT NULL THEN
        i_zdoe_infop2.i_indic          := C_ERROR;
        i_zdoe_infop2.i_error04        := t_ercodep2(4);
        i_zdoe_infop2.i_errormsg04     := t_errormsgp2(4);
        i_zdoe_infop2.i_errorfield04   := t_errorfieldp2(4);
        i_zdoe_infop2.i_fieldvalue04   := t_errorfieldvalp2(4);
        i_zdoe_infop2.i_errorprogram04 := t_errorprogramp2(4);
      END IF;
      IF TRIM(t_ercodep2(5)) IS NOT NULL THEN
        i_zdoe_infop2.i_indic          := C_ERROR;
        i_zdoe_infop2.i_error05        := t_ercodep2(5);
        i_zdoe_infop2.i_errormsg05     := t_errormsgp2(5);
        i_zdoe_infop2.i_errorfield05   := t_errorfieldp2(5);
        i_zdoe_infop2.i_fieldvalue05   := t_errorfieldvalp2(5);
        i_zdoe_infop2.i_errorprogram05 := t_errorprogramp2(5);
      END IF;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_infop2);
      CONTINUE skipRecordp2;
    END IF;
    IF (v_isAnyErrorp2 = 'N') THEN
      i_zdoe_infop2.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_infop2);
    END IF;
    -------------------------------Insert into ZDOEPF for P2 : END---------------------------------------
    ------------------INSERT INTO IG tables and registry table---------------------------------------------
    IF ((TRIM(i_zprvaldYN) = 'N') AND (TRIM(v_isAnyErrorp2) = 'N')) THEN
      --       i_text :=  TRIM(obj_mbrindp1.mpolnum);
      -- dmlog_info(i_lkey => 'obj_mbrindp1.mpolnum', i_ltext => i_text);
      /*IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
      select ZPLANCLS, Zcolmcls
      into v_zplancls, v_zcolmcls
      from Jd1dta.GCHPPF
      where TRIM(CHDRNUM) = TRIM(obj_mbrindp1.mpolnum)
      and CHDRCOY = TRIM(i_company);
      v_zplancls_new := v_zplancls;
      ELSE
      v_zplancls_new := 'PP';
      END IF;
      */
          --- MB16 START --
    IF (TRIM(i_ZTRXSTAT)) <> 'RJ' THEN        
        v_trmdate := C_MAXDATE;
        IF  (TRIM(i_zpoltdate) <> C_MAXDATE) 
        AND (TRIM(i_zpoltdate) IS NOT NULL) THEN
            v_trmdate := i_zpoltdate;
        END IF;   

        IF  (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE)
        AND (TRIM(obj_mbrindp1.dtetrm) IS NOT NULL) THEN
            v_trmdate := i_dtetrm;
        END IF;

    END IF;

      IF (TRIM(i_mpolnum) IS NOT NULL) THEN
        obj_getmpol    := getmpol(TRIM(i_mpolnum));
        v_zplancls     := obj_getmpol.zplancls;
        v_zcolmcls     := obj_getmpol.zcolmcls;
        v_zplancls_new := v_zplancls;
      ELSE
        v_zplancls_new := 'PP';
      END IF;
      ---Insert into IG table "GXHIPF " BEGIN (pq9ho.updateGxhipf())---
      SELECT SEQ_GXHIPF.nextval INTO v_seq_gxhipf FROM dual;
      obj_gxhipf.unique_number := v_seq_gxhipf;
      obj_gxhipf.CHDRCOY       := i_company;
      obj_gxhipf.CHDRNUM       := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_gxhipf.MBRNO         := o_defaultvalues('MBRNO');
      obj_gxhipf.PRODTYP       := obj_mbrindp2.prodtyp;
      obj_gxhipf.PLANNO        := o_defaultvalues('PLANNO');
      obj_gxhipf.EFFDATE       := obj_mbrindp2.effdate;
      obj_gxhipf.HEADNO        := C_SPACE;
      obj_gxhipf.FMLYCDE       := C_SPACE;
      obj_gxhipf.DTEATT        := obj_mbrindp2.effdate;
      IF (TRIM(i_statcode) = 'CA') THEN
        obj_gxhipf.DTETRM := i_dtetrm;
      ELSE
        obj_gxhipf.DTETRM := C_MAXDATE;
      END IF;
      -- obj_gxhipf.DTETRM    := C_MAXDATE;
      obj_gxhipf.REASONTRM := C_SPACE;
      obj_gxhipf.XCESSSI   := C_ZERO;
      obj_gxhipf.APRVDATE  := C_MAXDATE;
      obj_gxhipf.ACCPTDTE  := C_MAXDATE;
      obj_gxhipf.SPECTRM   := C_SPACE;
      obj_gxhipf.EXTRPRM   := C_ZERO;
      obj_gxhipf.SUMINSU   := obj_mbrindp2.hsuminsu;
      obj_gxhipf.USERSI    := C_ZERO;
      obj_gxhipf.DECFLG    := C_SPACE;
      obj_gxhipf.DPNTNO    := o_defaultvalues('DPNTNO');
      --  obj_gxhipf.TERMID    := i_vrcmTermid;
      obj_gxhipf.TERMID := C_SPACE; --MB7
      obj_gxhipf.TRDT   := i_trdt;
      obj_gxhipf.TRTM   := i_vrcmtime;
      --IF (TRIM(i_statcode) = 'CA') THEN
       -- obj_gxhipf.TRANNO := v_seqnoincr;
     -- ELSE
       -- obj_gxhipf.TRANNO := v_seqno;
     -- END IF;
      obj_gxhipf.TRANNO := 1;
      obj_gxhipf.EMLOAD     := C_ZERO;
      obj_gxhipf.OALOAD     := C_ZERO;
      obj_gxhipf.BILLACTN   := C_SPACE;
      obj_gxhipf.IMPAIRCD01 := C_SPACE;
      obj_gxhipf.IMPAIRCD02 := C_SPACE;
      obj_gxhipf.IMPAIRCD03 := C_SPACE;
      obj_gxhipf.RIEMLOAD   := C_ZERO;
      obj_gxhipf.RIOALOAD   := C_ZERO;
      obj_gxhipf.STDPRMLOAD := C_ZERO;
      obj_gxhipf.DTECLAM    := C_ZERO;
      obj_gxhipf.USRPRF     := i_usrprf;
      obj_gxhipf.JOBNM      := i_scheduleName;
      obj_gxhipf.DATIME     := CAST(sysdate AS TIMESTAMP);
      IF (TRIM(v_zplancls_new) = 'FP') THEN
        obj_gxhipf.DPREM := obj_mbrindp2.aprem;
      END IF;
      IF (TRIM(v_zplancls_new) = 'PP') THEN
        obj_gxhipf.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
      END IF;
      obj_gxhipf.LOADREASON := C_SPACE;
      obj_gxhipf.MBRIND     := C_SPACE;
      obj_gxhipf.NCBSI      := 0;
      --   obj_gxhipf.RIPROCDT   := C_MAXDATE;
      --obj_gxhipf.RIPROCDT := C_ZERO; --MB7
      IF obj_gxhipf.DTETRM = C_MAXDATE THEN
         obj_gxhipf.RIPROCDT := C_ZERO;
      ELSE 
         obj_gxhipf.RIPROCDT := C_MAXDATE;
      END IF;
      -- obj_gxhipf.USER_T     := i_vrcmuser;
      obj_gxhipf.USER_T := C_ZERO; --MB7
      IF (i_zplancde IS NOT NULL) THEN
        /* select ZINSTYPE
        into v_zinstype
        from ZSLPPF
        where TRIM(zsalplan) = TRIM(zplancde)
        and TRIM(prodtyp) = TRIM(obj_mbrindp2.prodtyp);
        obj_gxhipf.ZINSTYPE := v_zinstype;*/
        IF (getzinstype.exists(TRIM(i_zplancde) ||
                               TRIM(obj_mbrindp2.prodtyp))) THEN
          obj_gxhipf.ZINSTYPE := getzinstype(TRIM(i_zplancde) ||
                                             TRIM(obj_mbrindp2.prodtyp)); -- obj_gxhipf.ZINSTYP    := 'a';
        END IF;
        IF ((TRIM(i_ZWAITPEDT) IS NOT NULL) OR (TRIM(i_ZWAITPEDT) != 0) OR
           (TRIM(i_ZWAITPEDT) <> C_MAXDATE)) THEN
          IF (TRIm(obj_mbrindp2.prodtyp) IN
             ('1989',
               '1990',
               '1991',
               '1992',
               '1993',
               '1995',
               '1996',
               '1997')) THEN
            obj_gxhipf.ZWAITPEDT := i_ZWAITPEDT;
          ELSE
            obj_gxhipf.ZWAITPEDT := C_MAXDATE;
          END IF;
        ELSE
          obj_gxhipf.ZWAITPEDT := C_MAXDATE;
        END IF;
      END IF;
      /**** ITR-4_LOT2 :  MB6 - MOD : condition change due to new requirement : START ****/
      obj_gxhipf.ZTAXFLG := obj_mbrindp2.ZTAXFLG;
      /**** ITR-4_LOT2 :  Mb6 - MOD : condition change due to new requirement : END ****/
      -- insert into GXHIPF values obj_gxhipf;

      obj_gxhipf.APRVDATE := obj_gxhipf.DTEATT;
      obj_gxhipf.ACCPTDTE := obj_gxhipf.DTETRM;
      
      INSERT INTO GXHIPF VALUES obj_gxhipf;
      --------insert into IG table "GMOVPF" for GXHIPF BEGIN(pq9ho.updateGmhdpf())----
      -- IF (TRIM(i_statcode) <> 'PN') THEN   Previous code
      IF (TRIM(i_statcode) = 'XN') THEN
        v_olddta3               := obj_gxhipf.Chdrcoy || obj_gxhipf.Chdrnum ||
                                   obj_gxhipf.Prodtyp || obj_gxhipf.Planno ||
                                   obj_gxhipf.Effdate || obj_gxhipf.Mbrno ||
                                   obj_gxhipf.Dpntno;
        v_refkey                := obj_gxhipf.Chdrcoy || obj_gxhipf.Chdrnum ||
                                   obj_gxhipf.Prodtyp || obj_gxhipf.Planno ||
                                   obj_gxhipf.Effdate || obj_gxhipf.Mbrno ||
                                   obj_gxhipf.Dpntno;
        obj_gmovpf3PN.Chdrcoy   := obj_gxhipf.Chdrcoy;
        obj_gmovpf3PN.Chdrnum   := obj_gxhipf.Chdrnum;
        obj_gmovpf3PN.Effdate   := i_effdate;
        obj_gmovpf3PN.Tranno    := 1;
        obj_gmovpf3PN.User_t    := obj_gxhipf.User_t;
        obj_gmovpf3PN.Trdt      := obj_gxhipf.Trdt;
        obj_gmovpf3PN.Trtm      := obj_gxhipf.Trtm;
        obj_gmovpf3PN.Termid    := obj_gxhipf.Termid;
        obj_gmovpf3PN.Batccoy   := i_company;
        obj_gmovpf3PN.Batcbrn   := i_branch;
        obj_gmovpf3PN.Batcactyr := i_acctYear;
        obj_gmovpf3PN.Batcactmn := i_acctMonth;
        IF (TRIM(i_statcode) = 'CA') THEN
          obj_gmovpf3PN.Batctrcde := 'T913';
        ELSE
          obj_gmovpf3PN.Batctrcde := 'T903';
        END IF;
        obj_gmovpf3PN.Batcbatch := C_SPACE;
        obj_gmovpf3PN.Olddta    := v_olddta3;
        obj_gmovpf3PN.Newdta    := '';
        obj_gmovpf3PN.Funccode  := C_FUNCDEADDMBRPP;
        obj_gmovpf3PN.Refkey    := v_refkey;
        obj_gmovpf3PN.Rfmt      := 'GXHIPEMREC';
        obj_gmovpf3PN.Chgtype   := '';
        obj_gmovpf3PN.Riprior   := ' ';
        obj_gmovpf3PN.Onpreflg  := '';
        obj_gmovpf3PN.Fachold   := '';
        obj_gmovpf3PN.Planvflg  := '';
        obj_gmovpf3PN.Usrprf    := i_usrprf;
        obj_gmovpf3PN.Jobnm     := i_scheduleName;
        obj_gmovpf3PN.Datime    := CAST(sysdate AS TIMESTAMP);
        --  Insert into GMOVPF values obj_gmovpf3PN;
        INSERT INTO gmovpf VALUES obj_gmovpf3PN;
      END IF;
      /* IF (TRIM(i_statcode) = 'CA') THEN
      v_olddta3 := obj_gxhipf.Chdrcoy || obj_gxhipf.Chdrnum ||
      obj_gxhipf.Prodtyp || obj_gxhipf.Planno ||
      obj_gxhipf.Effdate || obj_gxhipf.Mbrno ||
      obj_gxhipf.Dpntno;
      v_newdta3 := obj_gxhipf.Chdrcoy || obj_gxhipf.Chdrnum ||
      obj_gxhipf.Prodtyp || obj_gxhipf.Planno ||
      obj_gxhipf.Effdate || obj_gxhipf.Mbrno ||
      obj_gxhipf.Dpntno;
      v_refkey := obj_gxhipf.Chdrcoy || obj_gxhipf.Chdrnum ||
      obj_gxhipf.Prodtyp || obj_gxhipf.Planno ||
      obj_gxhipf.Effdate || obj_gxhipf.Mbrno ||
      obj_gxhipf.Dpntno;
      obj_gmovpf3CA.Chdrcoy   := obj_gxhipf.Chdrcoy;
      obj_gmovpf3CA.Chdrnum   := obj_gxhipf.Chdrnum;
      obj_gmovpf3CA.Effdate   := obj_gxhipf.effdate;
      obj_gmovpf3CA.Tranno    := 2;
      obj_gmovpf3CA.User_t    := obj_gxhipf.User_t;
      obj_gmovpf3CA.Trdt      := obj_gxhipf.Trdt;
      obj_gmovpf3CA.Trtm      := obj_gxhipf.Trtm;
      obj_gmovpf3CA.Termid    := obj_gxhipf.Termid;
      obj_gmovpf3CA.Batccoy   := i_company;
      obj_gmovpf3CA.Batcbrn   := i_branch;
      obj_gmovpf3CA.Batcactyr := i_acctYear;
      obj_gmovpf3CA.Batcactmn := i_acctMonth;
      IF (TRIM(i_statcode) = 'CA') THEN
      obj_gmovpf3CA.Batctrcde := 'T913';
      ELSE
      obj_gmovpf3CA.Batctrcde := 'T903';
      END IF;
      obj_gmovpf3CA.Batcbatch := C_SPACE;
      obj_gmovpf3CA.Olddta    := v_olddta3;
      obj_gmovpf3CA.Newdta    := v_newdta3;
      obj_gmovpf3CA.Funccode  := C_FUNCDETRMBRPP;
      obj_gmovpf3CA.Refkey    := v_refkey;
      obj_gmovpf3CA.Rfmt      := 'GXHIPEMREC';
      obj_gmovpf3CA.Chgtype   := '';
      obj_gmovpf3CA.Riprior   := ' ';
      obj_gmovpf3CA.Onpreflg  := '';
      obj_gmovpf3CA.Fachold   := '';
      obj_gmovpf3CA.Planvflg  := '';
      obj_gmovpf3CA.Usrprf    := i_usrprf;
      obj_gmovpf3CA.Jobnm     := i_scheduleName;
      obj_gmovpf3CA.Datime    := CAST(sysdate AS TIMESTAMP);
      --   Insert into GMOVPF values obj_gmovpf3CA;
      gmovpf3CAindex := gmovpf3CAindex + 1;
      gmovpf3CA_list.extend;
      gmovpf3CA_list(gmovpf3CAindex) := obj_gmovpf3CA;
      END IF;*/
      --------insert into IG table "GMOVPF" for GXHIPF  END (pq9ho.updateGmhdpf())----
      ---Insert into IG table "GXHIPF" END ---
      ---Insert into IG table "GAPHPF" BEGIN ---
      obj_gaphpf.CHDRCOY    := i_company;
      obj_gaphpf.CHDRNUM    := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_gaphpf.HEADCNTIND := o_defaultvalues('HEADCNTIND');
      obj_gaphpf.MBRNO      := o_defaultvalues('MBRNO');
      obj_gaphpf.DPNTNO     := o_defaultvalues('DPNTNO');
      obj_gaphpf.PRODTYP    := obj_mbrindp2.prodtyp;
      obj_gaphpf.PLANNO     := o_defaultvalues('PLANNO');
      obj_gaphpf.EFFDATE    := obj_mbrindp2.effdate;
      --MB16 F (TRIM(i_statcode) = 'CA') THEN
      --MB16   obj_gaphpf.DTETRM := i_dtetrm;
      --MB16 ELSE
      --MB16  obj_gaphpf.DTETRM := C_MAXDATE;
      --MB16 END IF;
      obj_gaphpf.DTETRM := C_MAXDATE;
      --MB16 IF (TRIM(i_statcode) = 'CA') THEN
      --MB16  obj_gaphpf.TRANNO := v_seqnoincr;
      --MB16 ELSE
      --MB16  obj_gaphpf.TRANNO := v_seqno;
      --MB16 END IF;
      obj_gaphpf.TRANNO   := v_seqno;  --MB16
      obj_gaphpf.SUBSCOY  := C_SPACE;
      obj_gaphpf.SUBSNUM  := C_SPACE;
      obj_gaphpf.APREM    := obj_mbrindp2.aprem;
      obj_gaphpf.AEXTPRM  := C_ZERO;
      obj_gaphpf.AEXTPRMR := C_ZERO;
      obj_gaphpf.HSUMINSU := obj_mbrindp2.hsuminsu;
      obj_gaphpf.PRMAMTRT := obj_mbrindp2.aprem;
      obj_gaphpf.INDICX   := o_defaultvalues('INDICX');
      obj_gaphpf.UPDTYPE := o_defaultvalues('UPDTYPEN');  -- MB16
      obj_gaphpf.RESNCD := o_defaultvalues('RESNCDA');    -- MB16
      -- MB16 START --
      --IF (TRIM(i_statcode) = 'CA') THEN
      --  obj_gaphpf.UPDTYPE := o_defaultvalues('UPDTYPET');
      --ELSE
      --  obj_gaphpf.UPDTYPE := o_defaultvalues('UPDTYPEN');
      --END IF;
      --IF (TRIM(i_statcode) = 'CA') THEN
      --  obj_gaphpf.RESNCD := o_defaultvalues('RESNCDT');
      --ELSE
      --  obj_gaphpf.RESNCD := o_defaultvalues('RESNCDA');
      --END IF;
      -- MB16 END --
      obj_gaphpf.SRCDATA := o_defaultvalues('SRCDATA');
      obj_gaphpf.BATCTRCD := C_NEWBZ_ISSUE;  -- MB16

      --MB16 STARTS --
      --IF ((TRIM(i_statcode) = 'IF') OR (TRIM(i_statcode) = 'XN')) THEN
      --  obj_gaphpf.BATCTRCD := C_NEWBZ_ISSUE;
      --END IF;
      --IF (TRIM(i_statcode) = 'CA') THEN
      --  obj_gaphpf.BATCTRCD := C_ISS_TERM;
      --END IF;
      -- MB16 END --
      obj_gaphpf.VALIDFLAG := o_defaultvalues('VALIDFLAG');
      obj_gaphpf.JOBNM     := i_scheduleName;
      obj_gaphpf.USRPRF    := i_usrprf;
      obj_gaphpf.DATIME    := CAST(sysdate AS TIMESTAMP);
      --   Insert into GAPHPF values obj_gaphpf;
      INSERT INTO gaphpf VALUES obj_gaphpf;
      ---Insert into IG table "GAPHPF" END ---
      ---Insert into IG table "MTRNPF" BEGIN ---
      /*  IF (TRIM(i_statcode) <> 'PN') THEN
      obj_mtrnpfPN.CHDRCOY  := i_company;
      obj_mtrnpfPN.CHDRNUM  := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_mtrnpfPN.PRODTYP  := obj_mbrindp2.prodtyp;
      obj_mtrnpfPN.MBRNO    := o_defaultvalues('MBRNO');
      obj_mtrnpfPN.DPNTNO   := o_defaultvalues('DPNTNO');
      obj_mtrnpfPN.TRANNO   := 1;
      obj_mtrnpfPN.RLDPNTNO := C_SPACE;
      obj_mtrnpfPN.ISSDATE  := obj_mbrindp2.effdate;
      obj_mtrnpfPN.CHGTYPE  := C_ADDMBR;
      obj_mtrnpfPN.EFFDATE  := obj_mbrindp2.effdate;
      obj_mtrnpfPN.JOBNOTPA := c_ZERO;
      obj_mtrnpfPN.JOBNORIE := c_ZERO;
      obj_mtrnpfPN.USRPRF   := i_usrprf; -- obj_mtrnpf.USER_PROFILE := 'a';
      obj_mtrnpfPN.JOBNM    := i_scheduleName; --  obj_mtrnpf.JOB_NAME     := 'a';
      obj_mtrnpfPN.DATIME   := CAST(sysdate AS TIMESTAMP);
      -- insert into MTRNPF values obj_mtrnpfPN;
      mtrnpfPNindex := mtrnpfPNindex + 1;
      mtrnpfPN_list.extend;
      mtrnpfPN_list(mtrnpfPNindex) := obj_mtrnpfPN;
      END IF;
      IF (TRIM(i_statcode) = 'CA') THEN
      obj_mtrnpfCA.CHDRCOY  := i_company;
      obj_mtrnpfCA.CHDRNUM  := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_mtrnpfCA.PRODTYP  := obj_mbrindp2.prodtyp;
      obj_mtrnpfCA.MBRNO    := o_defaultvalues('MBRNO');
      obj_mtrnpfCA.DPNTNO   := o_defaultvalues('DPNTNO');
      obj_mtrnpfCA.TRANNO   := 2;
      obj_mtrnpfCA.RLDPNTNO := C_SPACE;
      obj_mtrnpfCA.ISSDATE  := obj_mbrindp2.effdate;
      obj_mtrnpfCA.CHGTYPE  := C_TRMPOL;
      obj_mtrnpfCA.EFFDATE  := obj_mbrindp2.effdate;
      obj_mtrnpfCA.JOBNOTPA := c_ZERO;
      obj_mtrnpfCA.JOBNORIE := c_ZERO;
      -- obj_mtrnpf.USER_PROFILE := 'a';
      -- obj_mtrnpf.JOB_NAME     := 'a';
      obj_mtrnpfCA.DATIME := CAST(sysdate AS TIMESTAMP);
      --  insert into MTRNPF values obj_mtrnpfCA;
      mtrnpfCAindex := mtrnpfCAindex + 1;
      mtrnpfCA_list.extend;
      mtrnpfCA_list(mtrnpfCAindex) := obj_mtrnpfCA;
      END IF;*/
      ---Insert into IG table "MTRNPF" END ---
      ---Insert into IG table "ZTIERPF " START ---
      obj_ztierpf.chdrcoy := i_company;
      --  dbms_output.put_line('obj_mbrindp2.refnum ==>' || obj_mbrindp2.refnum);
      obj_ztierpf.CHDRNUM := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_ztierpf.MBRNO   := o_defaultvalues('MBRNO');
      obj_ztierpf.DPNTNO  := o_defaultvalues('DPNTNO');
      obj_ztierpf.PRODTYP := obj_mbrindp2.prodtyp;

      --IF (TRIM(i_statcode) = 'CA') THEN -- MB16
      --IF v_trmdate <> C_MAXDATE THEN             --MB16
      --  obj_ztierpf.TRANNO := v_seqnoincr;
      --ELSE
      --  obj_ztierpf.TRANNO := v_seqno;
      --END IF;
      --   obj_ztierpf.TRANNO  := v_seqno;
      -- obj_ztierpf.EFFDATE := obj_mbrindp2.effdate;--MB7 comment out as setting null
      
      obj_ztierpf.TRANNO := 1;
      obj_ztierpf.EFFDATE := obj_mbrindp2.effdate; --MB10
      obj_ztierpf.ZTIERNO := o_defaultvalues('ZTIERNO');
      --IF (TRIM(i_statcode) = 'CA') THEN -- MB16
      IF v_trmdate <> C_MAXDATE THEN             --MB16
        obj_ztierpf.DTETRM := i_dtetrm;
      ELSE
        obj_ztierpf.DTETRM := C_MAXDATE;
      END IF;
      obj_ztierpf.DTEATT  := obj_mbrindp2.effdate;
      obj_ztierpf.SUMINSU := obj_mbrindp2.HSUMINSU;
      --    obj_ztierpf.DPREM   := obj_mbrindp2.APREM;
      IF (TRIM(v_zplancls_new) = 'FP') THEN
        obj_ztierpf.DPREM := obj_mbrindp2.aprem;
      END IF;
      IF (TRIM(v_zplancls_new) = 'PP') THEN
        obj_ztierpf.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
      END IF;
      obj_ztierpf.USRPRF := i_usrprf;
      obj_ztierpf.JOBNM  := i_scheduleName;
      obj_ztierpf.DATIME := CAST(sysdate AS TIMESTAMP);
      ----- MB5 START -----
      --obj_ztierpf.EFDATE  := C_MAXDATE; --- MB5
      --obj_ztierpf.ZMDDVDT := C_MAXDATE; --- MB5
      IF obj_ztierpf.DTETRM <> C_MAXDATE THEN
         obj_ztierpf.ZREINDT := C_MAXDATE;
      ELSE
         obj_ztierpf.ZREINDT := C_ZERO;
      END IF;
      --Obj_ztierpf.ZREINDT := C_ZERO; --- MB5
      
      obj_ztierpf.ZCVGSTRTDT := obj_ztierpf.DTEATT;
      obj_ztierpf.ZCVGENDDT := obj_ztierpf.DTETRM;
      obj_ztierpf.ZWAITPERD := obj_gxhipf.ZWAITPEDT;
      
      
      
      ----- MB5 END -----
      INSERT INTO VIEW_DM_ZTIERPF VALUES obj_ztierpf;
      ---Insert into IG table "ZTIERPF " END ---*/
      ---Insert into IG table "ZTEMPCOVPF" START ---
      obj_ztempcovpf1.CHDRCOY    := i_company;
      obj_ztempcovpf1.CHDRNUM    := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_ztempcovpf1.ALTQUOTENO := NULL;
      obj_ztempcovpf1.TRANNO     := v_seqno;
      obj_ztempcovpf1.MBRNO      := o_defaultvalues('MBRNO');
      obj_ztempcovpf1.DPNTNO     := o_defaultvalues('DPNTNO');
      obj_ztempcovpf1.PRODTYP    := obj_mbrindp2.prodtyp;
      obj_ztempcovpf1.EFFDATE    := obj_mbrindp2.EFFDATE;
      obj_ztempcovpf1.DTEATT     := obj_mbrindp2.EFFDATE;
      /*IF (TRIM(i_statcode) = 'CA') THEN
      obj_ztempcovpf1.DTETRM := i_dtetrm;
      ELSE
      obj_ztempcovpf1.DTETRM := C_MAXDATE;
      END IF;*/
      obj_ztempcovpf1.DTETRM := C_MAXDATE;
      obj_ztempcovpf1.SUMINS := obj_mbrindp2.HSUMINSU;
      --   obj_ztempcovpf1.DPREM    := obj_mbrindp2.APREM;
      IF (TRIM(v_zplancls_new) = 'FP') THEN
        obj_ztempcovpf1.DPREM := obj_mbrindp2.aprem;
      END IF;
      IF (TRIM(v_zplancls_new) = 'PP') THEN
        obj_ztempcovpf1.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
      END IF;
      --  obj_ztempcovpf1.ZWPENDDT := C_MAXDATE;
      IF ((TRIM(i_ZWAITPEDT) IS NOT NULL) OR (TRIM(i_ZWAITPEDT) != 0) OR
         (TRIM(i_ZWAITPEDT) <> C_MAXDATE)) THEN
        IF (TRIM(obj_mbrindp2.prodtyp) IN
           ('1989', '1990', '1991', '1992', '1993', '1995', '1996', '1997')) THEN
          obj_ztempcovpf1.ZWPENDDT := i_ZWAITPEDT;
        ELSE
          obj_ztempcovpf1.ZWPENDDT := C_MAXDATE;
        END IF;
      ELSE
        obj_ztempcovpf1.ZWPENDDT := C_MAXDATE;
      END IF;
      obj_ztempcovpf1.ZCHGTYPE := 'A';
      obj_ztempcovpf1.DSUMIN   := obj_mbrindp2.HSUMINSU;
      obj_ztempcovpf1.ZSALPLAN := i_zplancde;
      obj_ztempcovpf1.USRPRF   := i_usrprf;
      obj_ztempcovpf1.JOBNM    := i_scheduleName;
      obj_ztempcovpf1.DATIME   := CAST(sysdate AS TIMESTAMP);
      obj_ztempcovpf1.ZINSTYPE := o_defaultvalues('ZINSTYPE');
      --obj_ztempcovpf1.REFNUM   := 'a';
      
      obj_ztempcovpf1.ZCVGSTRTDT := obj_ztempcovpf1.DTEATT;
      obj_ztempcovpf1.ZCVGENDDT := obj_ztempcovpf1.DTETRM;
      
      
      INSERT INTO VIEW_DM_ZTEMPCOVPF VALUES obj_ztempcovpf1;
      --IF (TRIM(i_statcode) = 'CA') THEN -- MB16
      IF v_trmdate <> C_MAXDATE THEN             --MB16
        obj_ztempcovpf2.CHDRCOY    := i_company;
        obj_ztempcovpf2.CHDRNUM    := SUBSTR(TRIM(obj_mbrindp2.refnum),
                                             1,
                                             8);
        obj_ztempcovpf2.ALTQUOTENO := NULL;
        obj_ztempcovpf2.TRANNO     := v_seqnoincr;
        obj_ztempcovpf2.MBRNO      := o_defaultvalues('MBRNO');
        obj_ztempcovpf2.DPNTNO     := o_defaultvalues('DPNTNO');
        obj_ztempcovpf2.PRODTYP    := obj_mbrindp2.prodtyp;
        obj_ztempcovpf2.EFFDATE    := obj_mbrindp2.EFFDATE;
        obj_ztempcovpf2.DTEATT     := obj_mbrindp2.EFFDATE;
        /* IF (TRIM(i_statcode) = 'CA') THEN
        obj_ztempcovpf2.DTETRM := i_dtetrm;
        ELSE
        obj_ztempcovpf2.DTETRM := C_MAXDATE;
        END IF;*/
        obj_ztempcovpf2.DTETRM := i_dtetrm;
        obj_ztempcovpf2.SUMINS := obj_mbrindp2.HSUMINSU;
        --  obj_ztempcovpf2.DPREM    := obj_mbrindp2.APREM;
        IF (TRIM(v_zplancls_new) = 'FP') THEN
          obj_ztempcovpf2.DPREM := obj_mbrindp2.aprem;
        END IF;
        IF (TRIM(v_zplancls_new) = 'PP') THEN
          obj_ztempcovpf2.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
        END IF;
        --obj_ztempcovpf2.ZWPENDDT := C_MAXDATE;
        IF ((TRIM(i_ZWAITPEDT) IS NOT NULL) OR (TRIM(i_ZWAITPEDT) != 0) OR
           (TRIM(i_ZWAITPEDT) <> C_MAXDATE)) THEN
          IF (TRIM(obj_mbrindp2.prodtyp) IN
             ('1989',
               '1990',
               '1991',
               '1992',
               '1993',
               '1995',
               '1996',
               '1997')) THEN
            obj_ztempcovpf2.ZWPENDDT := i_ZWAITPEDT;
          ELSE
            obj_ztempcovpf2.ZWPENDDT := C_MAXDATE;
          END IF;
        ELSE
          obj_ztempcovpf2.ZWPENDDT := C_MAXDATE;
        END IF;
        obj_ztempcovpf2.ZCHGTYPE := 'T';
        obj_ztempcovpf2.DSUMIN   := obj_mbrindp2.HSUMINSU;
        obj_ztempcovpf2.ZSALPLAN := i_zplancde;
        obj_ztempcovpf2.USRPRF   := i_usrprf;
        obj_ztempcovpf2.JOBNM    := i_scheduleName;
        obj_ztempcovpf2.DATIME   := CAST(sysdate AS TIMESTAMP);
        obj_ztempcovpf2.ZINSTYPE := o_defaultvalues('ZINSTYPE');
        -- obj_ztempcovpf2.REFNUM   := 'a';
        
        obj_ztempcovpf2.ZCVGSTRTDT := obj_ztempcovpf2.DTEATT;
        obj_ztempcovpf2.ZCVGENDDT := obj_ztempcovpf2.DTETRM;
      
      
        INSERT INTO VIEW_DM_ZTEMPCOVPF VALUES obj_ztempcovpf2;
      END IF;
      ---Insert into IG table "ZTEMPCOVPF" END ---*/
      ---Insert into IG table "ztemptierpf" START ---
      obj_ztemptierpf1.CHDRCOY    := i_company;
      obj_ztemptierpf1.CHDRNUM    := SUBSTR(TRIM(obj_mbrindp2.refnum), 1, 8);
      obj_ztemptierpf1.ALTQUOTENO := NULL;
      obj_ztemptierpf1.MBRNO      := o_defaultvalues('MBRNO');
      obj_ztemptierpf1.DPNTNO     := o_defaultvalues('DPNTNO');
      obj_ztemptierpf1.PRODTYP    := obj_mbrindp2.prodtyp;
      obj_ztemptierpf1.TRANNO     := v_seqno;
      obj_ztemptierpf1.EFFDATE    := obj_mbrindp2.EFFDATE;
      obj_ztemptierpf1.ZTIERNO    := 1;
      /* IF (TRIM(i_statcode) = 'CA') THEN
      obj_ztemptierpf1.DTETRM := i_dtetrm;
      ELSE
      obj_ztemptierpf1.DTETRM := C_MAXDATE;
      END IF;*/
      obj_ztemptierpf1.DTETRM := C_MAXDATE;
      --  obj_ztemptierpf1.DTETRM     := 'a';
      obj_ztemptierpf1.DTEATT  := obj_mbrindp2.EFFDATE;
      obj_ztemptierpf1.SUMINSU := obj_mbrindp2.HSUMINSU;
      -- obj_ztemptierpf1.DPREM    := obj_mbrindp2.APREM;
      IF (TRIM(v_zplancls_new) = 'FP') THEN
        obj_ztemptierpf1.DPREM := obj_mbrindp2.aprem;
      END IF;
      IF (TRIM(v_zplancls_new) = 'PP') THEN
        obj_ztemptierpf1.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
      END IF;
      obj_ztemptierpf1.ZVIOLTYP := NULL;
      --obj_ztemptierpf1.EFDATE   := NULL;--MB7 comment out as setting null
      -- obj_ztemptierpf1.ZMDDVDT  := NULL;--MB7 comment out as setting null
      obj_ztemptierpf1.USRPRF := i_usrprf;
      obj_ztemptierpf1.JOBNM  := i_scheduleName;
      obj_ztemptierpf1.DATIME := CAST(sysdate AS TIMESTAMP);
      --obj_ztemptierpf1.REFNUM   := 'a';
      obj_ztemptierpf1.XTRANNO  := 1;
      obj_ztemptierpf1.ZCHGTYPE := 'A';
      ----- MB5 START -----
      --obj_ztemptierpf1.EFDATE   := C_MAXDATE;
      --obj_ztemptierpf1.ZMDDVDT  := C_MAXDATE;
      ----- MB5 END -----
      -- obj_ztemptierpf1.ZREINDT  := C_MAXDATE;
      
      obj_ztemptierpf1.ZCVGSTRTDT := obj_ztemptierpf1.DTEATT;
      obj_ztemptierpf1.ZCVGENDDT := obj_ztemptierpf1.DTETRM;
      obj_ztemptierpf1.ZWAITPERD := obj_gxhipf.ZWAITPEDT;
      
      INSERT INTO VIEW_DM_ZTEMPTIERPF VALUES obj_ztemptierpf1;
--IF (TRIM(i_statcode) = 'CA') THEN -- MB16
      IF v_trmdate <> C_MAXDATE THEN             --MB16
        obj_ztemptierpf2.CHDRCOY    := i_company;
        obj_ztemptierpf2.CHDRNUM    := SUBSTR(TRIM(obj_mbrindp2.refnum),
                                              1,
                                              8);
        obj_ztemptierpf2.ALTQUOTENO := NULL;
        obj_ztemptierpf2.MBRNO      := o_defaultvalues('MBRNO');
        obj_ztemptierpf2.DPNTNO     := o_defaultvalues('DPNTNO');
        obj_ztemptierpf2.PRODTYP    := obj_mbrindp2.prodtyp;
        obj_ztemptierpf2.TRANNO     := v_seqnoincr;
        obj_ztemptierpf2.EFFDATE    := obj_mbrindp2.EFFDATE;  -- MB16
        --  obj_ztemptierpf2.EFFDATE    := obj_mbrindp2.EFFDATE; --MB7 comment out as setting null
        obj_ztemptierpf2.ZTIERNO := 1;
        /*IF (TRIM(i_statcode) = 'CA') THEN
        obj_ztemptierpf2.DTETRM := i_dtetrm;
        ELSE
        obj_ztemptierpf2.DTETRM := C_MAXDATE;
        END IF;*/  
        obj_ztemptierpf2.DTETRM  := i_dtetrm;
        obj_ztemptierpf2.DTEATT  := obj_mbrindp2.EFFDATE;
        obj_ztemptierpf2.SUMINSU := obj_mbrindp2.HSUMINSU;
        -- obj_ztemptierpf2.DPREM    := obj_mbrindp2.APREM;
        IF (TRIM(v_zplancls_new) = 'FP') THEN
          obj_ztemptierpf2.DPREM := obj_mbrindp2.aprem;
        END IF;
        IF (TRIM(v_zplancls_new) = 'PP') THEN
          obj_ztemptierpf2.DPREM := TRIM(obj_mbrindp2.aprem) / 12;
        END IF;
        obj_ztemptierpf2.ZVIOLTYP := NULL;
        --  obj_ztemptierpf2.EFDATE   := NULL;
        -- obj_ztemptierpf2.ZMDDVDT  := NULL;--MB7 comment out as setting null
        obj_ztemptierpf2.USRPRF := i_usrprf;
        obj_ztemptierpf2.JOBNM  := i_scheduleName;
        obj_ztemptierpf2.DATIME := CAST(sysdate AS TIMESTAMP);
        --   obj_ztemptierpf2.REFNUM   := 'a';
        obj_ztemptierpf2.XTRANNO  := 1;
        obj_ztemptierpf2.ZCHGTYPE := 'T';
        ----- MB5 START -----
        --obj_ztemptierpf2.EFDATE   := C_MAXDATE;
        --obj_ztemptierpf2.ZMDDVDT  := C_MAXDATE;
        ----- MB5 END -----
        --  obj_ztemptierpf2.ZREINDT  := C_MAXDATE;
        
        obj_ztemptierpf2.ZCVGSTRTDT := obj_ztemptierpf2.DTEATT;
        obj_ztemptierpf2.ZCVGENDDT := obj_ztemptierpf2.DTETRM;
        obj_ztemptierpf2.ZWAITPERD := obj_gxhipf.ZWAITPEDT;
      
        INSERT INTO VIEW_DM_ZTEMPTIERPF VALUES obj_ztemptierpf2;
      END IF;
      ---Insert into IG table "ztemptierpf" END ---*/
    END IF;
  END LOOP;
  CLOSE cur_mbr_ind_p2;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
  -- DBMS_PROFILER.stop_profiler;
END BQ9SC_MB01_MBRIND;