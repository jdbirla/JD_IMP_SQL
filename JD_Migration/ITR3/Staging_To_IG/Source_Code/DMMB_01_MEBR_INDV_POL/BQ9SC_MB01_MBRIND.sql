--------------------------------------------------------
--  File created - Wednesday-July-07-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure BQ9SC_MB01_MBRIND
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9SC_MB01_MBRIND" (i_scheduleName   IN VARCHAR2,
                                                i_scheduleNumber IN VARCHAR2,
                                                i_zprvaldYN      IN VARCHAR2,
                                                i_company        IN VARCHAR2,
                                                i_fsucocompany   IN VARCHAR2,
                                                i_usrprf         IN VARCHAR2,
                                                i_branch         IN VARCHAR2,
                                                i_vrcmTermid     IN VARCHAR2,
                                                i_user_t         in NUMBER,
                                                i_array_size     IN PLS_INTEGER DEFAULT 1000,
                                                start_id         IN NUMBER,
                                                end_id           IN NUMBER)
  AUTHID current_user AS
  /***************************************************************************************************
  * Amenment History: DMMB-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  **********************************************SHI_START******************************************************
  * 2804     001   MB2  included checking for inputfile 2 for ploicy not migrated
  * 0501     002   MB3  set values for ZCOLMCLS and ZPLANCLS, read t-table T3684 and get bnkacctyp
                        Change logic to set value of GCHIPF.
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

  **********************************************SHI_END******************************************************

  **********************************************PA_START******************************************************
  * MMMDD    XXX   MBXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  *0720      JDB   MB18    PA New Implementation
  *0120      JDB   MB19    ITR3 Development
  *0216      JDB   MB20    ITR3 CR changes from IG
  *0301      JDB   MB21    Post validation fix
  * JUN10    MKS   MB22    ZJNPG-9664 : Start Time and End Time change in GCHIPF for CR P2-9351 implementation. 
  * 1111     JDB   MB23    CR-5599 (P2-16975)_GCHIPF_Data Model Changes
  * 0303     JDB   MB24    Termdate in GMHD and GMHI should be EFDATE of ZTRA


  **********************************************PA_END******************************************************
  ********************************************************************************************************************************/

  -----------------------local Vairables : START-----------------
  v_temp_crdate NUMBER(8) DEFAULT 0;
  --  i_text DMLOG.LTEXT%type;
  v_timestart  NUMBER := dbms_utility.get_time;
  v_refnump1   VARCHAR2(8);
  v_refnumpseq TITDMGMBRINDP1.REFNUM@DMSTAGEDBLINK%type;
  v_trmdate    TITDMGMBRINDP1.ZPOLTDATE@DMSTAGEDBLINK%type; -- MB16
  v_seqno1     VARCHAR2(3);

  v_errorCountp1 NUMBER(1) DEFAULT 0;
  v_isAnyErrorp1 VARCHAR2(1) DEFAULT 'N';
  v_prefix       VARCHAR2(2);
  v_refKeyp1     VARCHAR2(29 CHAR);
  v_ZDOErefKeyp  VARCHAR2(29 CHAR);

  v_mbrno         varchar2(5 CHAR);
  v_isdtetrmvalid VARCHAR2(20 CHAR);
  v_iseffdate     VARCHAR2(20 CHAR);
  v_timech01      VARCHAR2(10 CHAR);
  v_timech02      VARCHAR2(10 CHAR);
  v_zigvalue      PAZDCLPF.Zigvalue%type;
  v_template      DFPOPF.TEMPLATE%type;
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
  v_cltdob        CLNTPF.Cltdob%type;
  v_polanv        GCHPPF.Polanv%type;
  v_zagptnum      GCHIPF.Zagptnum%type;
  v_zplancls      GCHPPF.Zplancls%type;
  v_zcolmcls      GCHPPf.Zcolmcls%type;
  v_zprmsi        GMHIPF.ZPRMSI %type;
  v_zpolcls       ZCPNPF.zpolcls%type;
  v_zplancls_new  gchppf.zplancls%type;
  v_datconage     gmhdpf.AGE%type;
  v_zfacthus      ZENDRPF.zfacthus%type; -- MB3
  n_issdate       GMHIPF.NOTSFROM%type;
  v_mastset       VARCHAR2(50 CHAR);
  v_meminsty      VARCHAR2(100 CHAR);
  v_isOccReq      VARCHAR2(100 CHAR);
  v_zclepfkey     VARCHAR2(183 CHAR);
  res1            number;
  res2            number;
  res3            number;
  res4            number;
  res5            number;
  v_final_flg     varchar2(1) := 'N';
  p_exitcode      number;
  p_exittext      varchar2(2000);

  -----------Unique numbers------------
  v_seq_gchppf gchppf.unique_number%type;
  v_seq_gchdpf gchd.unique_number%type;
  v_seq_gmhdpf gmhdpf.unique_number%type;
  v_seq_gmhipf gmhipf.unique_number%type;
  v_seq_gchipf  gchipf.unique_number%type;
   v_SEQ_ZCLEPF ZCLEPF.unique_number%type;
  -----------Unique numbers------------
  ----IG tables records---
  obj_gchd         GCHD%rowtype;
  obj_gchppf       GCHPPF%rowtype;
  obj_gchipf       GCHIPF%rowtype;
  obj_gmhdpf       GMHDPF%rowtype;
  obj_gmhipf       GMHIPF%rowtype;
  obj_clrrpf       Jd1dta.CLRRPF%rowtype;
  obj_audit_clrrpf Jd1dta.AUDIT_CLRRPF%rowtype;
  obj_zclepf       ZCLEPF%rowtype;
  obj_zcelinkpf    VIEW_DM_ZCELINKPF%rowtype;
  v_insendate      gchi.INSENDTE%type; --MB12
  v_BUSDATE        busdpf.busdate%type; --MB12
  v_pkValueClrrpf  CLRRPF.UNIQUE_NUMBER%type;
  checkzcelpf      pkg_common_dmmb.zcelpftype;

-- v_daytempccdate  	VARCHAR(2);  --MB24
 -- v_daytempeffdate 	VARCHAR(2);--MB24
 -- v_yearmonthtemp  	NUMBER(6);--MB24
 -- v_efdatetemp     	ZTRAPF.EFDATE%type;--MB24
 -- v_efdatefinal    	ZTRAPF.EFDATE%type;--MB24
  -----------------------local Vairables : END-----------------

  ------------------Constant : START--------------------------

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
  C_Z001         CONSTANT VARCHAR2(4) := 'RQLH';
  C_COMMAS       CONSTANT VARCHAR2(4) := ',,,';
  /*  RQLH  Z001  Policy already migrated */
  C_Z002 CONSTANT VARCHAR2(4) := 'RQLI';
  /*  RQLI  Z002  Client not yet migrated */
  C_Z003 CONSTANT VARCHAR2(4) := 'RQLJ';
  /*  RQLJ  Z003  Master policy not yet migrated  */
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
  C_E315  CONSTANT VARCHAR2(4) := 'E315';
  C_F623  CONSTANT VARCHAR2(4) := 'F623';
  C_S008  CONSTANT VARCHAR2(4) := 'S008';
  C_BQ9SC CONSTANT VARCHAR2(5) := 'BQ9SC';
  C_Z093  CONSTANT VARCHAR2(4) := 'RQO1';
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
  /**** SHI ITR-4_LOT2 : MB6 - MOD : condition change due to new requirement : START ****/
  C_Z028 CONSTANT VARCHAR2(4) := 'E315';
  /*  Must be Y or N*/
  C_E186 CONSTANT VARCHAR2(4) := 'E186';
  /*FIELD MUST BE ENTERED*/
  C_PA01 CONSTANT VARCHAR2(4) := 'PA01';
  /*Client Category is null*/
  C_PA02 CONSTANT VARCHAR2(4) := 'PA02';
  /*HLDCOUNT val must set*/
  C_PA03 CONSTANT VARCHAR2(4) := 'PA03';
  /*Planclass mismatch with master pol*/
  C_RRYA CONSTANT VARCHAR2(4) := 'RRYA';
  /*Mbr PP > Mstr PP (months)*/
  C_RSAZ CONSTANT VARCHAR2(4) := 'RSAZ';
  /*Only 2 Named Ins Allowd*/
  C_PA04 CONSTANT VARCHAR2(4) := 'PA04';
  /* Ins Role not valid*/
  C_PA05 CONSTANT VARCHAR2(4) := 'PA05';
  /*  Template not available in DFPO*/
  C_PA06 CONSTANT VARCHAR2(4) := 'PA06';
  /*  Tranno number is blank*/
  C_PA07 CONSTANT VARCHAR2(4) := 'PA07';
  /*Owner data has error*/
  C_PA08 CONSTANT VARCHAR2(4) := 'PA08';
  /*cnttypind is blank*/
  C_RSBU CONSTANT VARCHAR2(4) := 'RSBU';
  /*InsType nt eqlto SetPlan*/
  C_G788 CONSTANT VARCHAR2(4) := 'G788';
  /*Occupation code missing */
  C_PA09 CONSTANT VARCHAR2(4) := 'PA09';
  /* Master policy is cancelled*/
  C_PA10 CONSTANT VARCHAR2(4) := 'PA10';
  /*'Policy has more than 2 periods'*/

  /**** SHI ITR-4_LOT2 : MB6 - MOD : condition change due to new requirement : END ****/
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
  C_FUNCDEADDMBR        CONSTANT VARCHAR2(5) := '04000';
  C_FUNCDEADDMBRPP      CONSTANT VARCHAR2(5) := '05000';
  C_FUNCDETRMBR         CONSTANT VARCHAR2(5) := '04021';
  C_FUNCDETRMBRPP       CONSTANT VARCHAR2(5) := '05021';
  C_ZPRDCTG             CONSTANT varchar2(2) := 'PA';
  C_T902                CONSTANT VARCHAR2(4) := 'T902';
  C_limit PLS_INTEGER := i_array_size;
  C_ROLE_MP CONSTANT varchar2(2) := 'MP';
  C_ROLE_OW CONSTANT varchar2(2) := 'OW';
  C_ROLE_LF CONSTANT varchar2(2) := 'LF';
  C_USED2B  CONSTANT CHAR(1 CHAR) := ' ';
  C_TRDT    CONSTANT NUMBER(6) := to_number(to_char(sysdate, 'YYMMDD'));
  C_TRTM    CONSTANT NUMBER(6) := to_Number(TO_CHAR(CURRENT_TIMESTAMP,
                                                    'HH24MISS'));

  ------------------Constant : END--------------------------

  -------------------Common Function : Start------------------
  v_tableNametemp VARCHAR2(10);
  v_tableNameMB   VARCHAR2(10);
  v_tableNameIN   VARCHAR2(10);
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_common_dmmb.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_infop1   pkg_dm_common_operations.obj_zdoe;
  -- getzigvalue     pkg_common_dmmb.zigvaluetype;
  -- checksalplan     pkg_common_dmmb.salplantype;
  getdfpo pkg_common_dmmb.dfpopftype;
  --zendcde          pkg_common_dmmb.checkzendcde;
  --campcode         pkg_common_dmmb.checkcampcode;
  getbmpol pkg_common_dmmb.mpoltype;
  getmpol  pkg_common_dmmb.mpoltype;

  checkpoldup pkg_common_dmmb.polduplicatetype;
  -- clntdob          pkg_common_dmmb.getclntdob;
  -- facthouse        pkg_common_dmmb.zendfacthouse; -- MB3
  hldconditioninfo pkg_common_dmmb.hldconditioninfotype;
  --obj_getmpol     pkg_common_dmmb.obj_bmpolrec;
  obj_getmpol pkg_common_dmmb.obj_mpolrec;

  obj_HLDCOUNT   pkg_common_dmmb.obj_hldcondition;
  dosplitinstype pkg_common_dmmb.salinstype;
  getoccreq      pkg_common_dmmb.occsaltype;
  getzagp        pkg_common_dmmb.zagptype;
  obj_getzagp    pkg_common_dmmb.obj_zagprec;

  TYPE obj_PolDatatype IS RECORD(
    statcode           gchd.STATCODE%type,
    zplanclass         gchppf.zplancls%type,
    mpolnum            gchd.MPLNUM%type,
    PERIOD_NO          dmigtitdmgmbrindp1.PERIOD_NO%type,
    total_period_count dmigtitdmgmbrindp1.total_period_count%type,
    ZBLNKPOL           dmigtitdmgmbrindp1.ZBLNKPOL%type,
    crdate             dmigtitdmgmbrindp1.crdate%type,
    OwnerErr           VARCHAR2(1));

  obj_PolData    obj_PolDatatype;
  obj_PolDatarec obj_PolDatatype;

  TYPE poltype IS TABLE OF obj_PolDatatype INDEX BY VARCHAR2(16);
  Map_Pol poltype;

  TYPE obj_OwnerClnType IS RECORD(
    ISOwner varchar2(1 Char));

  obj_OwnerClnData    obj_OwnerClnType;
  obj_OwnerClnDatarec obj_OwnerClnType;

  TYPE OwnerCln IS TABLE OF obj_OwnerClnType INDEX BY VARCHAR2(16);
  Map_OwnerCln OwnerCln;

  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercodep1 ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfieldp1 errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsgp1 errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldvalp1 errorfieldvalue_tab;
  type errorprofram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorprogramp1 errorprofram_tab;

  /*
  idx PLS_INTEGER;

  TYPE gchd_type IS TABLE of gchd%rowtype;
  gchd_list gchd_type := gchd_type();
  gchdindex integer := 0;

  TYPE GCHPPF_type IS TABLE of GCHPPF%rowtype;
  GCHPPF_list GCHPPF_type := GCHPPF_type();
  GCHPPFindex integer := 0;

  TYPE GCHIPF_type IS TABLE of GCHIPF%rowtype;
  GCHIPF_list GCHIPF_type := GCHIPF_type();
  GCHIPFindex integer := 0;

  TYPE ZCLEPF_type IS TABLE of ZCLEPF%rowtype;
  ZCLEPF_list ZCLEPF_type := ZCLEPF_type();
  ZCLEPFindex integer := 0;

  TYPE CLRRPF_type IS TABLE of CLRRPF%rowtype;
  CLRRPF_list CLRRPF_type := CLRRPF_type();
  CLRRPFindex integer := 0;

  TYPE AUDIT_CLRRPF_type IS TABLE of AUDIT_CLRRPF%rowtype;
  AUDIT_CLRRPF_list AUDIT_CLRRPF_type := AUDIT_CLRRPF_type();
  AUDIT_CLRRPFindex integer := 0;

  TYPE GMHDPF_type IS TABLE of GMHDPF%rowtype;
  GMHDPF_list GMHDPF_type := GMHDPF_type();
  GMHDPFindex integer := 0;

  TYPE GMHIPF_type IS TABLE of GMHIPF%rowtype;
  GMHIPF_list GMHIPF_type := GMHIPF_type();
  GMHIPFindex integer := 0;

  TYPE zcelinkpf_type IS TABLE of VIEW_DM_ZCELINKPF%rowtype;
  zcelinkpf_list zcelinkpf_type := zcelinkpf_type();
  zcelinkpfindex integer := 0;*/
  -------------------Common Function : END------------------

  ----------------Cursor query :START----------
  CURSOR cur_mbr_ind_p1 IS

    select *
      from (SELECT TIT.*,
                   zcpn.zcmpcode as IGzcmpcode,
                   ZCPN.zagptid,
                   ZCPN.zpolcls,
                   ZCPN.ZPETNAME,
                   zsal.zsalplan,
                   zend.zendcde  as IGZENDCDE,
                   zend.zfacthus,
                   pazd.zigvalue AS IGCLNTNUM,
                   clnt.clntnum,
                   clnt.occpcode,
                   clnt.Cltdob,
                   PANY.CLNTSTAS,
                   RPPF.CHDRNUM CHDRNUM_DUP
              FROM Jd1dta.dmigtitdmgmbrindp1 TIT
              left outer join Jd1dta.zcpnpf ZCPN
                on RTRIM(TIT.ZCMPCODE) = RTRIM(zcpn.zcmpcode)
              Left outer join (select Distinct (zsalplan) from Jd1dta.zslppf) ZSAL
                on RTRIM(TIT.zplancde) = RTRIM(zsal.zsalplan)
              left outer join Jd1dta.zendrpf ZEND
                on RTRIM(TIT.zendcde) = RTRIM(zend.zendcde)
              left outer join Jd1dta.pazdclpf PAZD
                on RTRIM(TIT.clientno) = RTRIM(pazd.zentity)
              left outer join Jd1dta.clntpf clnt
                on RTRIM(pazd.zigvalue) = RTRIM(clnt.clntnum)
              left outer join Jd1dta.pazdnypf PANY
                on RTRIM(TIT.clientno) = RTRIM(PANY.zentity)
                LEFT OUTER JOIN PAZDRPPF RPPF 
                on TIT.polnum = RPPF.POLNUM
                AND TIT.zinsrole = RPPF.ZINSROLE

            -- where refnum ='M00A1524'
            )
     WHERE REFNUMCHUNK between start_id and end_id
     ORDER BY LPAD(refnum, 15, '0'), zinsrole;
  obj_mbrindp1 cur_mbr_ind_p1%rowtype;

  type t_mbrind_list is table of cur_mbr_ind_p1%rowtype;
  mbrind_list t_mbrind_list;
  --obj_mbrindp1 t_mbrind_list;

  ----------------Cursor query :START----------

BEGIN
  /* DBMS_PROFILER.start_profiler('DM MBR NEW-7  ' ||
  TO_CHAR(SYSDATE, 'YYYYMMDD HH24:MI:SS'));*/
  SELECT BUSDATE
    INTO v_BUSDATE
    FROM busdpf
   WHERE TRIM(company) = TRIM(i_company); --MB12 : BUSDATE

  ---------Common Function Calling---------
  pkg_common_dmmb.getbmpolinfo(getbmpol => getbmpol);
  pkg_common_dmmb.getmpolinfo(getmpol => getmpol);

  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9SC,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMMB',
                                        o_errortext   => o_errortext);
  pkg_common_dmmb.getitemvalue(itemexist => itemexist);
  -- pkg_common_dmmb.getzigvalue(getzigvalue => getzigvalue);
  --pkg_common_dmmb.checksalplan(checksalplan => checksalplan);
  pkg_common_dmmb.getdfpo(getdfpo => getdfpo);
  --pkg_common_dmmb.checkendorser(zendcde => zendcde);
  --pkg_common_dmmb.checkcampcde(campcode => campcode);
  --pkg_common_dmmb.checkpoldup(checkpoldup => checkpoldup);
  -- pkg_common_dmmb.checkclntdob(clntdob => clntdob);
  --pkg_common_dmmb.getfacthouse(facthouse => facthouse);
  pkg_common_dmmb.gethldcondition(hldconditioninfo => hldconditioninfo);
  pkg_common_dmmb.splitinstype(dosplitinstype => dosplitinstype);
  pkg_common_dmmb.isoccrequired(getoccreq => getoccreq);
  pkg_common_dmmb.getzagp(getzagp => getzagp);
  pkg_common_dmmb.checkzclepf(checkzcelpf => checkzcelpf);
  ---------Common Function Calling------------
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX_MEBR) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableNameMB   := TRIM(v_tableNametemp);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX_INDV) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableNameIN   := TRIM(v_tableNametemp);
  --  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableNameMB);
  --  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableNameIN);

  OPEN cur_mbr_ind_p1;

  LOOP
    FETCH cur_mbr_ind_p1 bulk collect
      into mbrind_list limit C_limit;

    -- dbms_output.put_line('bulk collect call');
    <<skipRecord>>
  ---MB18:
    for i in 1 .. mbrind_list.count loop

      obj_mbrindp1 := mbrind_list(i);

      /*
            OPEN cur_mbr_ind_p1;
      <<skipRecord>>
      LOOP
        FETCH cur_mbr_ind_p1
          INTO obj_mbrindp1;
        EXIT WHEN cur_mbr_ind_p1%notfound;*/

      --EXIT WHEN cur_mbr_ind_p1%notfound;
      IF TRIM(obj_mbrindp1.cnttypind) = 'I' THEN
        v_prefix := C_PREFIX_INDV;
      ELSE
        v_prefix := C_PREFIX_MEBR;
      END IF;
      v_refKeyp1    := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      v_ZDOErefKeyp := obj_mbrindp1.refnum;
      v_refnump1    := SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8);
      v_refnumpseq  := TRIM(obj_mbrindp1.refnum);
      v_seqno1      := SUBSTR(TRIM(obj_mbrindp1.refnum), 9, 3);
      v_mbrno       := LPAD(obj_mbrindp1.mbrno, 5, '0');

      -- dbms_output.put_line('v_refKeyp1 :' || v_refKeyp1);
      -- dbms_output.put_line('v_mbrno :' || v_mbrno);
      --v_seqnoincr  := v_seqno1 + 1;
      --v_seqno      := 1;
      ----------Initialization-------
      i_zdoe_infop1              := NULL;
      i_zdoe_infop1.i_zfilename  := 'TITDMGMBRINDP1';
      i_zdoe_infop1.i_prefix     := v_prefix;
      i_zdoe_infop1.i_scheduleno := i_scheduleNumber;
      i_zdoe_infop1.i_refKey     := TRIM(v_ZDOErefKeyp) || '-' ||
                                    obj_mbrindp1.zinsrole;
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

      v_zprmsi := 0;
      ----------Initialization -------
      --dbms_output.put_line('TRIM(v_refnump1)==>' || TRIM(v_refnump1));
      /**** MB4 :  MOD : condition change due to new requirement : START ****/
      v_temp_crdate := 0;
      SELECT to_number(TO_CHAR(to_date(obj_mbrindp1.crdate, 'yyyymmdd') - 1,
                               'yyyymmdd'))
        INTO v_temp_crdate
        FROM dual;

      /**** MB4 :  MOD : condition change due to new requirement : END ****/
      ---------------First part of validation -TITDMGMBRINDP1----------------------------------------
      --- MB12 : MOD : Change for state code based on termination conditions : start
      ---IF zpoltdate and dtetrm = MAX DATE
      --- MB16 START --
      /*
      IF (obj_mbrindp1.last_trxs = 'Y') THEN
        IF (((obj_mbrindp1.client_category) IS not null) and
           (obj_mbrindp1.client_category = '0')) THEN

          IF (TRIM(obj_mbrindp1.ZTRXSTAT)) <> 'RJ' THEN
            v_trmdate := C_MAXDATE;
            IF (TRIM(obj_mbrindp1.zpoltdate) <> C_MAXDATE) AND
               (TRIM(obj_mbrindp1.zpoltdate) IS NOT NULL) THEN
              v_trmdate := obj_mbrindp1.zpoltdate;
            END IF;

            IF (TRIM(obj_mbrindp1.dtetrm) <> C_MAXDATE) AND
               (TRIM(obj_mbrindp1.dtetrm) IS NOT NULL) THEN
              v_trmdate := obj_mbrindp1.dtetrm;
            END IF;

            IF (v_trmdate <> C_MAXDATE) AND
               (TRIM(obj_mbrindp1.ZPDATATXFLG) = 'Y') THEN

              IF (v_trmdate >= v_BUSDATE) THEN
                obj_mbrindp1.STATCODE  := 'IF';
                obj_mbrindp1.zpoltdate := v_trmdate;
                obj_mbrindp1.dtetrm    := C_MAXDATE;
              END IF;
              IF (v_trmdate < v_BUSDATE) THEN
                obj_mbrindp1.STATCODE  := 'CA';
                obj_mbrindp1.zpoltdate := C_MAXDATE;
                obj_mbrindp1.dtetrm    := v_trmdate;
              END IF;
            END IF;
            IF (v_trmdate <> C_MAXDATE) AND
               ((TRIM(obj_mbrindp1.ZPDATATXFLG) <> 'Y') OR
               (TRIM(obj_mbrindp1.ZPDATATXFLG) IS NULL)) THEN
              obj_mbrindp1.STATCODE  := 'IF';
              obj_mbrindp1.zpoltdate := v_trmdate;
              obj_mbrindp1.dtetrm    := C_MAXDATE;
            END IF;
          END IF;
          IF (obj_mbrindp1.plnclass = 'F') THEN
            IF (obj_mbrindp1.crdate < v_BUSDATE) THEN
              obj_mbrindp1.STATCODE := 'LA';
            END IF;
          END IF;
        END IF;
      END IF;
      */
      ---MB18--
      -----Client category must not null---
      IF ((TRIM(obj_mbrindp1.client_category) IS NULL) or
         ((obj_mbrindp1.zinsrole) IS NULL)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_PA01;
        t_errorfieldp1(v_errorCountp1) := 'CLNTCATG';
        t_errormsgp1(v_errorCountp1) := 'clnt cat or ins role is null';
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.gpoltype;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;

        GOTO insertzdoep1;
      END IF;

      /*
          "INSURED ROLE(T-table : TW990):
      '0' : Owner
      '1' - Main Insrd,
      '2' - Spouse,
      '3' - Relative "
      */

      IF ((obj_mbrindp1.zinsrole IS NOT NULL) AND
         (obj_mbrindp1.zinsrole <> '0') AND (obj_mbrindp1.zinsrole <> '1') and
         (obj_mbrindp1.zinsrole <> '2') and (obj_mbrindp1.zinsrole <> '3')) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_PA04;
        t_errorfieldp1(v_errorCountp1) := 'ZINSROLE';
        t_errormsgp1(v_errorCountp1) := 'Ins Role not valid';
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zinsrole;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;

        GOTO insertzdoep1;
      END IF;

      IF ((TRIM(obj_mbrindp1.trannomin) IS NULL) or
         ((TRIM(obj_mbrindp1.trannomax) IS NULL)) or
         (obj_mbrindp1.trannomin = 0) or (obj_mbrindp1.trannomin = 0)) THEN
        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_PA06;
        t_errorfieldp1(v_errorCountp1) := 'TRANNO';
        t_errormsgp1(v_errorCountp1) := 'Tranno number is blank';
        t_errorfieldvalp1(v_errorCountp1) := 'TRMIN:' ||
                                             obj_mbrindp1.trannomin ||
                                             ' TRMAX:' ||
                                             obj_mbrindp1.trannomax;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;

        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
      END IF;

      --cnttypind  is not null validation
      IF (TRIM(obj_mbrindp1.cnttypind) IS NULL) THEN

        v_isAnyErrorp1 := 'Y';
        v_errorCountp1 := v_errorCountp1 + 1;
        t_ercodep1(v_errorCountp1) := C_PA08;
        t_errorfieldp1(v_errorCountp1) := 'CNTTYPIND';
        t_errormsgp1(v_errorCountp1) := 'cnttypind is blank';
        t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.cnttypind;
        t_errorprogramp1(v_errorCountp1) := i_scheduleName;
        IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
          GOTO insertzdoep1;
        END IF;

      END IF;

      -----MB18:Client category "0" (Policy owner) data validation :START ---------
      IF (obj_mbrindp1.client_category = '0') THEN

        --  IF NOT (getzigvalue.exists(TRIM(obj_mbrindp1.clientno))) THEN
        IF (obj_mbrindp1.clntnum is null) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z002;
          t_errorfieldp1(v_errorCountp1) := 'CLIENTNO';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_Z002);
          t_errorfieldvalp1(v_errorCountp1) := TRIM(obj_mbrindp1.clientno);
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        ELSE
          -- v_zigvalue := getzigvalue(TRIM(obj_mbrindp1.clientno));
          v_zigvalue := obj_mbrindp1.clntnum;
          obj_OwnerClnData.ISOwner := 'Y';
          Map_OwnerCln(v_zigvalue) := obj_OwnerClnData;
        END IF;

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

         -- IF (checkpoldup.exists(TRIM(v_refnump1) || obj_mbrindp1.zinsrole)) THEN
         IF (obj_mbrindp1.CHDRNUM_DUP is not null) THEN
          
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z001;
            t_errorfieldp1(v_errorCountp1) := 'REFNUM';
            t_errormsgp1(v_errorCountp1) := o_errortext(C_Z001);
            t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            GOTO insertzdoep1;
          END IF;

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
        ELSE
          IF (itemexist.exists(TRIM('TQ9FK') || TRIM(obj_mbrindp1.gpoltype) || 1)) THEN
            v_template := itemexist(TRIM('TQ9FK') || TRIM(obj_mbrindp1.gpoltype) || TRIM('1'))
                          .template;

            IF NOT (getdfpo.exists(TRIM(v_template))) THEN
              v_isAnyErrorp1 := 'Y';
              v_errorCountp1 := v_errorCountp1 + 1;
              t_ercodep1(v_errorCountp1) := C_PA05;
              t_errorfieldp1(v_errorCountp1) := 'TEMPLATE';
              t_errormsgp1(v_errorCountp1) := 'Template not available in DFPO';
              t_errorfieldvalp1(v_errorCountp1) := v_template;
              t_errorprogramp1(v_errorCountp1) := i_scheduleName;
              IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
                GOTO insertzdoep1;
              END IF;
            ELSE
              obj_dfpopf := getdfpo(TRIM(v_template));
            END iF;

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
        IF ((TRIM(obj_mbrindp1.zcmpcode) IS NULL) or
           (LENGTH(TRIM(obj_mbrindp1.zcmpcode)) < 6)) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z021;
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
            t_errorfieldvalp1(v_errorCountp1) := TRIM(obj_mbrindp1.MPOLNUM);
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
            t_errorfieldvalp1(v_errorCountp1) := TRIm(obj_mbrindp1.MPOLNUM);
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
             (TRIM(obj_mbrindp1.statcode) <> 'LA') AND
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
        ---------------Second part of validation -TITDMGMBRINDP1----------------------------------------

        IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL and
           obj_mbrindp1.zblnkpol = 'Y') THEN
          IF NOT (getbmpol.exists(TRIM(obj_mbrindp1.mpolnum))) THEN

            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z003;
            t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
            t_errormsgp1(v_errorCountp1) := o_errortext(C_Z003);
            t_errorfieldvalp1(v_errorCountp1) := TRIM(obj_mbrindp1.mpolnum);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;

          else
            obj_getmpol := getbmpol(TRIM(obj_mbrindp1.mpolnum));
          END IF;

        END IF;

        IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL and
           obj_mbrindp1.zblnkpol = 'N') THEN
          IF NOT
              (getmpol.exists(TRIM(obj_mbrindp1.mpolnum) || v_temp_crdate)) THEN

            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z003;
            t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
            --t_errormsgp1(v_errorCountp1) := o_errortext('PP master policy not mig');
            t_errormsgp1(v_errorCountp1) := 'PP master policy not mig';
            t_errorfieldvalp1(v_errorCountp1) := TRIm(obj_mbrindp1.mpolnum);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;

          else
            obj_getmpol := getmpol(TRIM(obj_mbrindp1.mpolnum) ||
                                   v_temp_crdate);
          END IF;

        END IF;
        --ZSALECHNL validation
        IF TRIM(obj_mbrindp1.zsalechnl) IS NOT NULL THEN
          IF NOT (itemexist.exists(TRIM('TQ9FW') ||
                                   TRIM(obj_mbrindp1.zsalechnl) || 1)) THEN
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
          IF NOT (itemexist.exists(TRIM('TQ9FU') ||
                                   TRIM(obj_mbrindp1.zstatresn) || 1)) THEN
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

        --ZENDCDE validation
        IF (TRIM(obj_mbrindp1.IGzendcde) IS NULL) THEN
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
        -- MB17 - MPS --
        --We need to move these validation in policy transaction history

        IF (obj_mbrindp1.plnclass = 'F') THEN
          IF ((TRIM(obj_mbrindp1.crdtcard) IS NULL) AND
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
        IF (obj_mbrindp1.plnclass <> 'F') THEN
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

        if (obj_mbrindp1.igzcmpcode is null) then
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
        IF (TRIM(obj_mbrindp1.statcode) <> 'PN') AND
           (TRIM(obj_mbrindp1.ZTRXSTAT) <> 'RJ') THEN
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

        IF (obj_mbrindp1.last_trxs = 'Y') THEN
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
        END IF;
        ---MB12 : MOD  :BTDATE allow As MAX DATE only for CA state : START
        ---BTDATE validation
        IF (TRIM(obj_mbrindp1.statcode) <> 'CA') AND
           (TRIM(obj_mbrindp1.statcode) <> 'PN') THEN
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

        IF TRIM(obj_mbrindp1.TERMAGE) IS NULL THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_E186;
          t_errorfieldp1(v_errorCountp1) := 'TERMAGE';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_E186);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.TERMAGE;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        end if;
        IF TRIM(obj_mbrindp1.ZRWNLAGE) IS NULL THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_E186;
          t_errorfieldp1(v_errorCountp1) := 'ZRWNLAGE';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_E186);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZRWNLAGE;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        end if;

        IF TRIM(obj_mbrindp1.ZNBMNAGE) IS NULL THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_E186;
          t_errorfieldp1(v_errorCountp1) := 'ZNBMNAGE';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_E186);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZNBMNAGE;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        end if;
        IF TRIM(obj_mbrindp1.ZBLNKPOL) IS NULL THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_E186;
          t_errorfieldp1(v_errorCountp1) := 'ZBLNKPOL';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_E186);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.ZBLNKPOL;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        end if;

        IF (obj_mbrindp1.total_period_count > 2) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_PA10;
          t_errorfieldp1(v_errorCountp1) := 'POLPRDCNT';
          --  t_errormsgp1(v_errorCountp1) := o_errortext('Policy has more than 2 periods');
          t_errormsgp1(v_errorCountp1) := 'Policy has more than 2 periods';
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.total_period_count;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        end if;

        ----Validation with master policy
        IF (obj_mbrindp1.zblnkpol = 'Y') THEN
          IF (obj_mbrindp1.plnclass != substr(obj_getmpol.ZPLANCLS, 1, 1)) THEN
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_PA03;
            t_errorfieldp1(v_errorCountp1) := 'PLNCLASS';
            t_errormsgp1(v_errorCountp1) := 'plnclass mismatch with master pol';
            t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.plnclass;
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;
          end if;
        end if;

        IF (obj_mbrindp1.zblnkpol = 'N') THEN

          IF (obj_mbrindp1.plnclass = 'P') THEN
            IF (obj_getmpol.STATCODE = 'CA' or obj_getmpol.STATCODE = 'LA') THEN
              if (obj_mbrindp1.statcode = 'CA') THEN
                v_isAnyErrorp1 := 'Y';
                v_errorCountp1 := v_errorCountp1 + 1;
                t_ercodep1(v_errorCountp1) := C_PA09;
                t_errorfieldp1(v_errorCountp1) := 'STATCODE';
                -- t_errormsgp1(v_errorCountp1) := o_errortext('Master policy is cancelled');
                t_errormsgp1(v_errorCountp1) := 'Master policy is cancelled';
                t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.STATCODE;
                t_errorprogramp1(v_errorCountp1) := i_scheduleName;
                IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
                  GOTO insertzdoep1;
                END IF;
              END IF;
            END IF;

          end if;

          if (obj_mbrindp1.cnttypind = 'M') then
            IF (obj_mbrindp1.effdate < obj_getmpol.ccdate) THEN
              v_isAnyErrorp1 := 'Y';
              v_errorCountp1 := v_errorCountp1 + 1;
              t_ercodep1(v_errorCountp1) := C_Z096;
              t_errorfieldp1(v_errorCountp1) := 'EFFDATE';
              t_errormsgp1(v_errorCountp1) := o_errortext(C_Z096);
              t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.effdate;
              t_errorprogramp1(v_errorCountp1) := i_scheduleName;
              IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
                GOTO insertzdoep1;
              END IF;
            end if;

            IF (v_temp_crdate != obj_getmpol.crdate) THEN
              v_isAnyErrorp1 := 'Y';
              v_errorCountp1 := v_errorCountp1 + 1;
              t_ercodep1(v_errorCountp1) := C_Z096;
              t_errorfieldp1(v_errorCountp1) := 'CRDATE';
              t_errormsgp1(v_errorCountp1) := o_errortext(C_Z096);
              t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.crdate;
              t_errorprogramp1(v_errorCountp1) := i_scheduleName;
              IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
                GOTO insertzdoep1;
              END IF;
            end if;

            IF (obj_mbrindp1.zpolperd > obj_getmpol.Zgpmppp) THEN
              v_isAnyErrorp1 := 'Y';
              v_errorCountp1 := v_errorCountp1 + 1;
              t_ercodep1(v_errorCountp1) := C_RRYA;
              t_errorfieldp1(v_errorCountp1) := 'ZPOLPERD';
              t_errormsgp1(v_errorCountp1) := o_errortext(C_RRYA);
              t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zpolperd;
              t_errorprogramp1(v_errorCountp1) := i_scheduleName;
              IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
                GOTO insertzdoep1;
              END IF;
            end if;
          end if;
        END IF;

        IF (TRIM(obj_mbrindp1.mpolnum) IS NOT NULL) THEN
          v_zplancls     := obj_getmpol.zplancls;
          v_zcolmcls     := obj_getmpol.zcolmcls;
          v_zplancls_new := v_zplancls;
        ELSE
          v_zplancls_new := 'PP';
          /* Use ZENDCDE and read ZENDRPF, and get Fact-House (zendrpf.getZfacthus())
          if Fact-house not blank, use Fact-house and read t-table T3684 and get bnkacctyp.
          set ZCOLMCLS = t3684rec.bnkacctyp.toString() */
          -- v_zfacthus := facthouse(TRIM(obj_mbrindp1.zendcde));
          v_zfacthus := obj_mbrindp1.zfacthus;
          IF v_zfacthus IS NOT NULL THEN
            IF itemexist.exists(TRIM('T3684') || TRIM(v_zfacthus) || 9) THEN
              v_zcolmcls := itemexist(TRIM('T3684') || TRIM(v_zfacthus) || 9)
                            .bnkacctyp;
            END IF;
          END IF;
        END IF;

        IF (itemexist.exists(TRIM('T9775') || TRIM(i_branch) || 1)) THEN
          v_currency := itemexist(TRIM('T9775') || TRIM(i_branch) || TRIM('1'))
                        .currency;
        END IF;

        IF (itemexist.exists('TQ9GX' || RTRIM(obj_mbrindp1.gpoltype) ||
                             C_T902 || '1')) THEN

          v_timech01 := itemexist('TQ9GX' || RTRIM(obj_mbrindp1.gpoltype) || C_T902 ||'1')
                        .timech01;
          v_timech02 := itemexist('TQ9GX' || RTRIM(obj_mbrindp1.gpoltype) || C_T902 ||'1')
                        .timech02;
        END IF;

        IF (RTRIM(v_zcolmcls) = 'C') THEN
          IF (hldconditioninfo.exists(TRIM(obj_mbrindp1.zendcde) ||
                                      trim(obj_mbrindp1.effdate))) THEN
            obj_HLDCOUNT := hldconditioninfo(TRIM(obj_mbrindp1.zendcde) ||
                                             trim(obj_mbrindp1.effdate));

          ELSE
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_PA02;
            t_errorfieldp1(v_errorCountp1) := 'HLDCOUNT';
            t_errormsgp1(v_errorCountp1) := 'HLDCOUNT val must set';
            t_errorfieldvalp1(v_errorCountp1) := null;
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;
          end if;
        ENd if;

        obj_PolData.statcode           := obj_mbrindp1.STATCODE;
        obj_PolData.zplanclass         := obj_mbrindp1.PLNCLASS;
        obj_PolData.mpolnum            := obj_mbrindp1.mpolnum;
        obj_PolData.OwnerErr           := v_isAnyErrorp1;
        obj_PolData.PERIOD_NO          := obj_mbrindp1.PERIOD_NO;
        obj_PolData.total_period_count := obj_mbrindp1.total_period_count;
        obj_PolData.ZBLNKPOL           := obj_mbrindp1.ZBLNKPOL;
        obj_PolData.crdate             := v_temp_crdate;

        Map_Pol(v_refKeyp1) := obj_PolData;

      END IF;

      -----MB18:Client category "0" (Policy owner) data validation : END----------

      -----MB18:Client category "1" (Policy insured) data validation :START ---------
      if (obj_mbrindp1.client_category = '1') THEN

        IF (Map_Pol.exists((v_refKeyp1))) THEN
          obj_PolDatarec := Map_Pol(v_refKeyp1);
          -- dbms_output.put_line('obj_PolDatarec :' || obj_PolDatarec.mpolnum);
          if (obj_PolDatarec.OwnerErr = 'Y') THEN
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_PA07;
            t_errorfieldp1(v_errorCountp1) := 'REFNUM';
            t_errormsgp1(v_errorCountp1) := 'Owner data has error';
            t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            GOTO insertzdoep1;
          END IF;

        else

          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_PA07;
          t_errorfieldp1(v_errorCountp1) := 'REFNUM';
          t_errormsgp1(v_errorCountp1) := 'Owner data has error';
          t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          GOTO insertzdoep1;

        END IF;

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

          IF (checkpoldup.exists(TRIM(v_refnump1) || obj_mbrindp1.zinsrole)) THEN
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z001;
            t_errorfieldp1(v_errorCountp1) := 'REFNUM';
            t_errormsgp1(v_errorCountp1) := o_errortext(C_Z001);
            t_errorfieldvalp1(v_errorCountp1) := TRIM(v_refnump1);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            GOTO insertzdoep1;
          END IF;
        end if;

        --  IF NOT (getzigvalue.exists(TRIM(obj_mbrindp1.clientno))) THEN
        IF (obj_mbrindp1.clntnum is null) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_Z002;
          t_errorfieldp1(v_errorCountp1) := 'CLIENTNO';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_Z002);
          t_errorfieldvalp1(v_errorCountp1) := TRIM(obj_mbrindp1.clientno);
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        ELSE
          -- v_zigvalue := getzigvalue(TRIM(obj_mbrindp1.clientno));
          v_zigvalue := obj_mbrindp1.clntnum;

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

        IF TRIM(obj_PolDatarec.statcode) = 'PN' THEN
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

        /*
        CLTRELN null validation T-table T3584 values
        1:Self
        2:Spouse
        3:Relative */
        IF (TRIM(obj_mbrindp1.cltreln) IS NULL) THEN
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
          IF NOT (itemexist.exists(TRIM('TQ9FU') ||
                                   TRIM(obj_mbrindp1.zstatresn) || 1)) THEN
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

          IF (TRIm(obj_mbrindp1.zsalplan) is null) THEN
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

           IF TRIM(obj_mbrindp1.zplancde) IS  NULL THEN


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

        IF (TRIM(obj_PolDatarec.mpolnum) IS NOT NULL and
           obj_PolDatarec.ZBLNKPOL = 'Y') THEN
          IF NOT (getbmpol.exists(TRIM(obj_PolDatarec.mpolnum))) THEN
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z003;
            t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
            --  t_errormsgp1(v_errorCountp1) := o_errortext(C_Z003);
            t_errormsgp1(v_errorCountp1) := 'Insured val Bln mas pol not mig';
            t_errorfieldvalp1(v_errorCountp1) := TRIm(obj_mbrindp1.mpolnum);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;
          else
            obj_getmpol := getbmpol(TRIM(obj_PolDatarec.mpolnum));
          END IF;

        END IF;

        IF (TRIM(obj_PolDatarec.mpolnum) IS NOT NULL and
           obj_PolDatarec.ZBLNKPOL != 'Y') THEN
          IF NOT (getmpol.exists(TRIM(obj_PolDatarec.mpolnum) ||
                                 obj_PolDatarec.crdate)) THEN
            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_Z003;
            t_errorfieldp1(v_errorCountp1) := 'MPOLNUM';
            --  t_errormsgp1(v_errorCountp1) := o_errortext(C_Z003);
            t_errormsgp1(v_errorCountp1) := 'Insured val mas pol not mig';
            t_errorfieldvalp1(v_errorCountp1) := TRIM(obj_mbrindp1.mpolnum);
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;
          else
            obj_getmpol := getmpol(TRIM(obj_PolDatarec.mpolnum) ||
                                   obj_PolDatarec.crdate);
          END IF;

        END IF;
    IF (TRIm(obj_mbrindp1.zsalplan) is not null) THEN
        IF TRIM(obj_PolDatarec.mpolnum) IS NOT NULL THEN
          if (obj_getmpol.ZINSTYPST1 is not null and
             (obj_getmpol.ZINSTYPST1 != C_COMMAS)) then
            v_mastset  := trim(obj_getmpol.ZINSTYPST1);
            v_meminsty := dosplitinstype(trim(obj_mbrindp1.zplancde));
            res1       := validate_instype(v_mastset, v_meminsty);
            --  dbms_output.put_line('res1 = ' || res1);

            if (res1 = 0) then
              if (obj_getmpol.ZINSTYPST2 is not null and
                 (obj_getmpol.ZINSTYPST2 != C_COMMAS)) then

                v_mastset  := trim(obj_getmpol.ZINSTYPST2);
                v_meminsty := dosplitinstype(trim(obj_mbrindp1.zplancde));
                res2       := validate_instype(v_mastset, v_meminsty);
                --  dbms_output.put_line('res2 = ' || res2);
                if (res2 = 0) then
                  if (obj_getmpol.ZINSTYPST3 is not null and
                     (obj_getmpol.ZINSTYPST3 != C_COMMAS)) then

                    v_mastset  := trim(obj_getmpol.ZINSTYPST3);
                    v_meminsty := dosplitinstype(trim(obj_mbrindp1.zplancde));
                    res3       := validate_instype(v_mastset, v_meminsty);
                    --   dbms_output.put_line('res3 = ' || res3);
                    if (res3 = 0) then
                      if (obj_getmpol.ZINSTYPST4 is not null and
                         (obj_getmpol.ZINSTYPST4 != C_COMMAS)) then

                        v_mastset  := trim(obj_getmpol.ZINSTYPST4);
                        v_meminsty := dosplitinstype(trim(obj_mbrindp1.zplancde));
                        res4       := validate_instype(v_mastset,
                                                       v_meminsty);
                        --  dbms_output.put_line('res4 = ' || res4);

                        if (res4 = 0) then
                          if (obj_getmpol.ZINSTYPST5 is not null and
                             (obj_getmpol.ZINSTYPST5 != C_COMMAS)) then

                            v_mastset  := trim(obj_getmpol.ZINSTYPST5);
                            v_meminsty := dosplitinstype(trim(obj_mbrindp1.zplancde));
                            res5       := validate_instype(v_mastset,
                                                           v_meminsty);
                            --  dbms_output.put_line('res5 = ' || res5);
                          end if;
                        end if;
                      end if;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          end if;

          if (res1 = 1 or res2 = 1 or res3 = 1 or res4 = 1 or res5 = 1) then
            v_final_flg := 'Y';
          end if;
          --dbms_output.put_line('v_final_flg = ' || v_final_flg);

          IF v_final_flg = 'N' THEN

            v_isAnyErrorp1 := 'Y';
            v_errorCountp1 := v_errorCountp1 + 1;
            t_ercodep1(v_errorCountp1) := C_RSBU;
            t_errorfieldp1(v_errorCountp1) := 'ZPLANCDE';
            t_errormsgp1(v_errorCountp1) := o_errortext(C_RSBU);
            t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.zplancde;
            t_errorprogramp1(v_errorCountp1) := i_scheduleName;
            IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
              GOTO insertzdoep1;
            END IF;

          END IF;
        end if;
        end if;
		/*  Removing validation becasue SHI client has null 
    IF ((TRIm(obj_mbrindp1.zplancde) is not null )and (TRIm(obj_mbrindp1.zsalplan) is not null )) THEN
        v_isOccReq := getoccreq(trim(obj_mbrindp1.zplancde));

        IF (v_isOccReq = 'Y' and TRIM(obj_mbrindp1.occpcode) is null) THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_G788;
          t_errorfieldp1(v_errorCountp1) := 'CLNTNUM';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_G788);
          t_errorfieldvalp1(v_errorCountp1) := v_zigvalue;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        END IF;
       End IF;
         */
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

        IF (v_mbrno > '00002') THEN
          v_isAnyErrorp1 := 'Y';
          v_errorCountp1 := v_errorCountp1 + 1;
          t_ercodep1(v_errorCountp1) := C_RSAZ;
          t_errorfieldp1(v_errorCountp1) := 'MBRNO';
          t_errormsgp1(v_errorCountp1) := o_errortext(C_RSAZ);
          t_errorfieldvalp1(v_errorCountp1) := obj_mbrindp1.mbrno;
          t_errorprogramp1(v_errorCountp1) := i_scheduleName;
          IF (v_errorCountp1 = C_ERRORCOUNTP1) THEN
            GOTO insertzdoep1;
          END IF;
        END IF;
      END if;

      -----MB18:Client category "1" (Policy insured) data validation : END----------

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
        --      dbms_output.put_line('obj_mbrindp1.zinsrole :' ||                           obj_mbrindp1.zinsrole);
        INSERT INTO PAZDRPPF
          (CHDRNUM, PREFIX, ZINSROLE, JOBNUM, JOBNAME,POLNUM)
        VALUES
          (TRIM(v_ZDOErefKeyp),
           v_prefix,
           obj_mbrindp1.zinsrole,
           i_scheduleNumber,
           i_scheduleName,
           v_refnump1);

        IF (obj_mbrindp1.client_category = '0') THEN
          --MB19
          IF (obj_mbrindp1.LAST_TRXS = 'Y') THEN
            --select SEQ_CHDRPF.nextval into v_seq_gchdpf from dual;
            v_seq_gchdpf := SEQ_CHDRPF.nextval; --PerfImprov
            obj_gchd.UNIQUE_NUMBER := v_seq_gchdpf;
            obj_gchd.CHDRCOY       := i_company;
            obj_gchd.CHDRNUM       := v_refnump1;
            obj_gchd.CHDRPFX       := o_defaultvalues('CHDRPFX');
            obj_gchd.CNTTYPE       := obj_mbrindp1.gpoltype;
            obj_gchd.COWNPFX       := o_defaultvalues('COWNPFX');
            obj_gchd.COWNCOY       := i_fsucocompany;
            obj_gchd.COWNNUM       := v_zigvalue;
            obj_gchd.STATCODE      := obj_mbrindp1.statcode;
            IF (TRIM(obj_mbrindp1.statcode) = 'PN') THEN
              obj_gchd.PNDATE := obj_mbrindp1.effdate;
            ELSE
              obj_gchd.PNDATE := C_MAXDATE;
            END IF;
            obj_gchd.SUBSFLG := C_SPACE; --MB7
            obj_gchd.OCCDATE := obj_mbrindp1.occdate;
            obj_gchd.HRSKIND := obj_dfpopf.hrskind;

            obj_gchd.CNTCURR    := TRIM(v_currency);
            obj_gchd.BILLCURR   := TRIM(v_currency);
            obj_gchd.TAKOVRFLG  := C_SPACE; --MB7
            obj_gchd.GPRNLTYP   := obj_dfpopf.gprnltyp;
            obj_gchd.GPRMNTHS   := obj_dfpopf.gprmnths;
            obj_gchd.RNLNOTTO   := obj_dfpopf.rnlnotto;
            obj_gchd.SRCEBUS    := null;
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
            obj_gchd.LMBRNO     := o_defaultvalues('LMBRNO');
            obj_gchd.LHEADNO    := o_defaultvalues('LHEADNO');
            IF (obj_mbrindp1.statcode = 'CA' OR
               obj_mbrindp1.statcode = 'LA') THEN
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
            obj_gchd.PROCID    := C_SPACE;
            obj_gchd.TRANID    := concat('QPAD',
                                         TO_CHAR(sysdate, 'YYMMDDHHMM'));
            obj_gchd.TRANNO    := obj_mbrindp1.trannomax;
            obj_gchd.VALIDFLAG := o_defaultvalues('VALIDFLAG');
            obj_gchd.SPECIND   := C_SPACE;
            obj_gchd.TAXFLAG   := obj_dfpopf.taxflag;
            obj_gchd.AGEDEF    := obj_dfpopf.agedef;

            if (obj_mbrindp1.plnclass = 'F') THEN
              obj_gchd.TERMAGE := 100;
            else
              obj_gchd.TERMAGE := obj_mbrindp1.termage;

            END IF;
            obj_gchd.PERSONCOV := obj_dfpopf.personcov;
            obj_gchd.ENROLLTYP := obj_dfpopf.enrolltyp;
            obj_gchd.SPLITSUBS := obj_dfpopf.splitsubs;
            obj_gchd.AVLISU    := C_SPACE;
            obj_gchd.MPLPFX    := C_SPACE; --MB7
            obj_gchd.MPLCOY    := i_company;
            IF (TRIM(obj_mbrindp1.cnttypind) = 'I') THEN
              obj_gchd.MPLNUM := C_SPACE;
            ELSE
              obj_gchd.MPLNUM := obj_mbrindp1.mpolnum;
            END IF;
            obj_gchd.USRPRF    := i_usrprf;
            obj_gchd.JOBNM     := i_scheduleName;
            obj_gchd.DATIME    := CAST(sysdate AS TIMESTAMP);
            obj_gchd.IGRASP    := C_SPACE;
            obj_gchd.IEXPLAIN  := C_SPACE;
            obj_gchd.IDATE     := C_ZERO;
            obj_gchd.MIDJOIN   := C_SPACE;
            obj_gchd.CVISAIND  := C_SPACE;
            obj_gchd.COVERNT   := C_SPACE;
            obj_gchd.CNTISS    := C_ZERO;
            obj_gchd.REPNUM    := C_SPACE; --MB7
            obj_gchd.REPTYPE   := C_SPACE;
            obj_gchd.PAYRCOY   := C_SPACE;
            obj_gchd.PAYRNUM   := C_SPACE;
            obj_gchd.PAYRPFX   := C_SPACE;
            obj_gchd.ZPRVCHDR  := obj_mbrindp1.trefnum;
            obj_gchd.CURRFROM  := C_ZERO;
            obj_gchd.CURRTO    := C_ZERO;
            obj_gchd.TRANLUSED := obj_mbrindp1.trannomax; --MB12 : TRANNO == TRANLUSED
            if (obj_mbrindp1.plnclass = 'F') THEN
              obj_gchd.Zrwnlage := 100;
            else
              obj_gchd.Zrwnlage := obj_mbrindp1.zrwnlage;
            END IF;
            obj_gchd.QUOTENO      := C_ZERO; --MB7 new added
            obj_gchd.SCHMNO       := C_SPACE; --MB7 new added
            obj_gchd.RTGRANTE     := C_SPACE; --MB7 new added
            obj_gchd.RTGRANTEDATE := C_ZERO; --MB7 new added
            obj_gchd.CPIINCRIND   := C_SPACE; --MB7 new added
            obj_gchd.SUPERFLAG    := C_SPACE; --MB7 new added
            IF obj_gchd.STATCODE = 'XN' THEN
              obj_gchd.PTDATE := C_MAXDATE;
            END IF;

            INSERT INTO Jd1dta.GCHD VALUES obj_gchd;
          END IF;
          ---MB18
          /*
          gchdindex := gchdindex + 1;
          gchd_list.extend;
          gchd_list(gchdindex) := obj_gchd;*/

          ---MB18
          ------Insert Into IG table "GCHD"  END -----
          ---Insert into IG table  "GCHPPF" BEGIN (pq9ho.updateGchppf())---
          --MB18
          /*SELECT zagptid, zpolcls
           INTO v_zagptid, v_zpolcls
           FROM Zcpnpf
          WHERE TRIM(ZCMPCODE) = TRIM(obj_mbrindp1.zcmpcode);*/
          --MB19
          IF (obj_mbrindp1.LAST_TRXS = 'Y') THEN
            v_zagptid := obj_mbrindp1.zagptid;
            v_zpolcls := obj_mbrindp1.zpolcls;
            --MB18
            --SELECT SEQ_GCHPPF.nextval INTO v_seq_gchppf FROM dual;
            v_seq_gchppf := SEQ_GCHPPF.nextval; --PerfImprov
            obj_gchppf.unique_number := v_seq_gchppf;
            obj_gchppf.CHDRCOY       := i_company;
            obj_gchppf.CHDRNUM       := v_refnump1;
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

            v_polanv := obj_getmpol.polanv;

            obj_gchppf.POLANV := v_polanv;

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

            -------- MB2: get value of ZCOLMCLS and ZPLANCLS --------

            -------- MB2: get value of ZCOLMCLS and ZPLANCLS  --------
            obj_gchppf.ZPLANCLS   := v_zplancls_new;
            obj_gchppf.ZAPLFOD    := 0; -- MB8
            obj_gchppf.ZGPORIPCLS := v_zpolcls;
            obj_gchppf.ZENDCDE    := obj_mbrindp1.zendcde;

            obj_gchppf.PETNAME    := obj_mbrindp1.ZPETNAME;
            obj_gchppf.LSTCTBFR   := C_MAXDATE;
            obj_gchppf.OPTAUTORNW := C_SPACE;
            obj_gchppf.OCALLVSA   := C_SPACE;
            obj_gchppf.ZCOLMCLS   := v_zcolmcls;
            --MB18
            /* IF (TRIM(obj_mbrindp1.Cnttypind) = 'M') THEN
              obj_gchppf.ZCONVINDPOL := obj_mbrindp1.ZCONVINDPOL;
            ELSE
              obj_gchppf.ZCONVINDPOL := C_SPACE;
            END IF;*/
            obj_gchppf.ZCONVINDPOL := null;
            IF (obj_mbrindp1.plnclass = 'P') THEN
              IF (TRIM(obj_mbrindp1.ZPOLTDATE) IS NOT NULL) THEN
                obj_gchppf.ZPOLTDATE := obj_mbrindp1.ZPOLTDATE;
              ELSE
                obj_gchppf.ZPOLTDATE := C_MAXDATE;
              END IF;
            ELSE
              obj_gchppf.ZPOLTDATE := obj_mbrindp1.crdate;
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
            if (obj_mbrindp1.plnclass = 'F') THEN
              obj_gchppf.ZNBMNAGE := 0;
            else
              obj_gchppf.ZNBMNAGE := obj_mbrindp1.ZNBMNAGE;
            END IF;

            obj_gchppf.MATAGE := C_ZERO; --MB7 new addedd
            --MB18--------
            obj_gchppf.FLAGPRINT   := 'N';
            obj_gchppf.STMPDUTYEXE := null;
            obj_gchppf.ZISMBRPOL   := null;
            obj_gchppf.ZINSRENDT   := null;
            if (RTRIM(obj_gchppf.zcolmcls) = 'C') then

              obj_gchppf.HLDCOUNT := obj_HLDCOUNT.HLDCONDITION;
            else
              obj_gchppf.HLDCOUNT := C_ZERO;
            end if;

            obj_gchppf.ZGRPCLS   := obj_getmpol.ZGRPCLS;
            obj_gchppf.REASONCD  := null;
            obj_gchppf.ZSALECHNL := obj_mbrindp1.zsalechnl;
            obj_gchppf.ZPRDCTG   := C_ZPRDCTG;
            ---MB18-------
            --MB19
            obj_gchppf.ZLAPTRX := obj_mbrindp1.zlaptrx;
            INSERT INTO GCHPPF VALUES obj_gchppf;
          END IF;
          /*
          gchppfindex := gchppfindex + 1;
          gchppf_list.extend;
          gchppf_list(gchppfindex) := obj_gchppf;*/
          ---Insert into IG table "GCHPPF" END ---
          ---Insert into IG table "GCHIPF" BEGIN  (pq9ho.updateGchipf())--
           v_seq_gchipf := SEQ_gchipf.nextval;
           obj_gchipf.unique_number  := v_seq_gchipf;
          obj_gchipf.CHDRCOY := i_company;
          obj_gchipf.CHDRNUM := v_refnump1;
          obj_gchipf.EFFDATE := obj_mbrindp1.effdate;
          obj_gchipf.CCDATE  := obj_mbrindp1.effdate;
          obj_gchipf.ZPSTDDT := obj_gchipf.CCDATE;
          /**** MB4 :  MOD : condition change due to new requirement : START ****/
          obj_gchipf.CRDATE := v_temp_crdate;
          /**** MB4 :  MOD : condition change due to new requirement : END ****/

          obj_gchipf.PRVBILFLG := C_SPACE; --MB7
          IF (TRIM(v_zplancls) = 'FP') THEN
            obj_gchipf.BILLFREQ := '00'; --MB14
          ELSE
            obj_gchipf.BILLFREQ := obj_dfpopf.billfreq;
          END IF; ---MB7
          IF (TRIM(v_zplancls) = 'FP') THEN
            obj_gchipf.GADJFREQ := '00'; --MB14
          ELSE
            obj_gchipf.GADJFREQ := obj_dfpopf.gadjfreq;
          END IF; --MB7

          obj_gchipf.PAYRPFX := C_SPACE;
          obj_gchipf.PAYRCOY := C_SPACE;
          obj_gchipf.PAYRNUM := C_SPACE;
          obj_gchipf.AGNTPFX := o_defaultvalues('AGNTPFX');
          obj_gchipf.AGNTCOY := i_fsucocompany;
          IF (TRIM(obj_mbrindp1.Cnttypind) <> 'I') THEN

            --  obj_getmpol := getbmpol(TRIM(obj_mbrindp1.mpolnum));
            v_zagptnum := obj_getmpol.zagptnum;
            IF (getzagp.exists(v_zagptnum)) THEN

              obj_getzagp := getzagp(v_zagptnum);

              v_admnoper01 := obj_getzagp.admnoper01;
              v_gagntsel01 := obj_getzagp.gagntsel01;
              v_admnoper02 := obj_getzagp.admnoper02;
              v_gagntsel02 := obj_getzagp.gagntsel02;
              v_admnoper03 := obj_getzagp.admnoper03;
              v_gagntsel03 := obj_getzagp.gagntsel03;
              v_admnoper04 := obj_getzagp.admnoper04;
              v_gagntsel04 := obj_getzagp.gagntsel04;
              v_admnoper05 := obj_getzagp.admnoper05;
              v_gagntsel05 := obj_getzagp.gagntsel05;

            end if;

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

            IF (getzagp.exists(v_zagptnum)) THEN

              obj_getzagp := getzagp(v_zagptid);

              v_admnoper01 := obj_getzagp.admnoper01;
              v_gagntsel01 := obj_getzagp.gagntsel01;
              v_admnoper02 := obj_getzagp.admnoper02;
              v_gagntsel02 := obj_getzagp.gagntsel02;
              v_admnoper03 := obj_getzagp.admnoper03;
              v_gagntsel03 := obj_getzagp.gagntsel03;
              v_admnoper04 := obj_getzagp.admnoper04;
              v_gagntsel04 := obj_getzagp.gagntsel04;
              v_admnoper05 := obj_getzagp.admnoper05;
              v_gagntsel05 := obj_getzagp.gagntsel05;

            end if;

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
          obj_gchipf.ZAGPTNUM  := '        ';
          obj_gchipf.CNTBRANCH := i_branch;
          -- obj_gchipf.STCA      := C_SPACE;
          obj_gchipf.STCA := 'LF'; --MB7
          obj_gchipf.STCB := C_SPACE;
          obj_gchipf.STCC := C_SPACE;
          obj_gchipf.STCD := C_SPACE;
          obj_gchipf.STCE := C_SPACE;

          IF (TRIM(v_zplancls) = 'FP') THEN
            /**** MB4 :  MOD : condition change due to new requirement : START ****/

            obj_gchipf.BTDATENR := TO_NUMBER(to_CHAR(to_date(v_temp_crdate,
                                                             'YYYYMMDD') + 1,
                                                     'yyyymmdd'));
            /**** MB4 :  MOD : condition change due to new requirement : END ****/
          ELSE
            obj_gchipf.BTDATENR := DATCONOPERATION('MONTH',
                                                   obj_gchipf.CCDATE);

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
          obj_gchipf.TRDT   := C_TRDT;
          obj_gchipf.TRTM   := C_TRTM;
          obj_gchipf.TRANNO := obj_mbrindp1.trannonbrn;

          obj_gchipf.BANKCODE := obj_dfpopf.bankcode;
          obj_gchipf.BILLCHNL := obj_dfpopf.billchnl;
          obj_gchipf.MANDREF  := C_SPACE;
          obj_gchipf.RIMTHVCD := obj_dfpopf.rimthvcd;
          obj_gchipf.PRMRVWDT := C_ZERO; --MB7
          obj_gchipf.APPLTYP  := obj_dfpopf.appltyp;
          obj_gchipf.RIIND    := obj_dfpopf.riind;
          obj_gchipf.POLBREAK := C_SPACE; --MB7
          obj_gchipf.CFTYPE   := C_SPACE;
          obj_gchipf.LMTDRL   := C_SPACE;
          obj_gchipf.CFLIMIT  := C_ZERO;
          obj_gchipf.NOFCLAIM := C_ZERO;
          obj_gchipf.WKLADRT  := C_ZERO;
          obj_gchipf.WKLCMRT  := C_ZERO;
          obj_gchipf.NOFMBR   := C_ZERO;
          obj_gchipf.USRPRF   := i_usrprf;
          obj_gchipf.JOBNM    := i_scheduleName;
          obj_gchipf.DATIME   := CAST(sysdate AS TIMESTAMP);
          obj_gchipf.ECNV     := o_defaultvalues('ECNV');
          obj_gchipf.CVNTYPE  := o_defaultvalues('CVNTYPE');
          obj_gchipf.COVERNT  := C_SPACE;

          --obj_gchipf.TIMECH01 := v_timech01; -- MB22
          --obj_gchipf.TIMECH02 := v_timech02; -- MB22

		  --START MB22: 
		  IF SUBSTR(TRIM(obj_mbrindp1.refnum), 1, 8) = '00' THEN --New Business
			obj_gchipf.TIMECH01 := v_timech01;
			obj_gchipf.TIMECH02 := v_timech02;		  
		  ELSE -- Renewal
			obj_gchipf.TIMECH01 := v_timech02;
			obj_gchipf.TIMECH02 := v_timech02;	
		  END IF;
		  --START MB22:

          obj_gchipf.TPAFLG   := C_SPACE;
          obj_gchipf.DOCRCDTE := obj_mbrindp1.docrcvdt;
          obj_gchipf.INSSTDTE := obj_mbrindp1.effdate;
          /**** MB4 :  MOD : condition change due to new requirement : START ****/
          /**** MB12 :  MOD : INSENDTE recalculation CRDATE+1 : START ****/

          v_insendate         := to_number(TO_CHAR(to_date(obj_gchipf.CRDATE,
                                                           'yyyymmdd') + 1,
                                                   'yyyymmdd'));
          obj_gchipf.INSENDTE := v_insendate;
          /**** MB12 :  MOD : INSENDTE recalculation CRDATE+1 : END ****/
          /**** MB4 :  MOD : condition change due to new requirement : START ****/
          obj_gchipf.ZSOLCTFLG := obj_mbrindp1.zsolctflg;
          --- 17/02/2018 After Pre-SIT execution
          obj_gchipf.COWNNUM := v_zigvalue;
          ---03/05/18 SIT bug fix
          obj_gchipf.zcmpcode := obj_mbrindp1.zcmpcode;
          obj_gchipf.ZPENDDT  := v_temp_crdate;

          ----MB18------
          obj_gchipf.TPA      := '        ';
          obj_gchipf.HPROPDTE := null;
          obj_gchipf.ZCEDTIME := null;
          obj_gchipf.ZCSTIME  := null;
          obj_gchipf.zpolperd := obj_mbrindp1.zpolperd;
          ---MB18-------
          --MB19
          obj_gchipf.ZRNWCNT := obj_mbrindp1.ZRNWCNT;
		  
		   obj_gchipf.ZORIGPOLSTRDT := C_MAXDATE;		  --MB23

		   obj_gchipf.ZORIGPOLENDDT :=C_MAXDATE;		  --MB23


          INSERT INTO GCHIPF VALUES obj_gchipf;
          /*
          GCHIPFindex := GCHIPFindex + 1;
          GCHIPF_list.extend;
          GCHIPF_list(GCHIPFindex) := obj_gchipf;*/

          ---Insert into IG table "GCHIPF" END ---

          ---Insert into IG table "ZCLEPF" START ---*/
          --- 17/02/2018 After Pre-SIT execution
          --- IF (TRIM(obj_mbrindp1.ZENSPCD01) IS NOT NULL) THEN
          --MB19
          IF (obj_mbrindp1.LAST_TRXS = 'Y') THEN
            v_zclepfkey := RTRIM(obj_gchd.COWNNUM) ||
                           NVL(RTRIM(obj_mbrindp1.ZENSPCD01), ' ') ||
                           NVL(RTRIM(obj_mbrindp1.ZENSPCD02), ' ') ||
                           NVL(RTRIM(obj_mbrindp1.zcifcode), ' ');
            If NOT (checkzcelpf.exists(v_zclepfkey)) THEN
              IF ((TRIM(obj_mbrindp1.ZENSPCD01) IS NOT NULL) OR
                 (TRIM(obj_mbrindp1.ZENSPCD02) IS NOT NULL) OR
                 (TRIM(obj_mbrindp1.Zcifcode) IS NOT NULL)) THEN
                -- MB12  : MOD : Cratte ZCLEPF iff one of them given
                obj_zclepf.CLNTNUM := obj_gchd.COWNNUM;
                obj_zclepf.ZENDCDE := obj_gchppf.ZENDCDE;
                IF (TRIM(obj_mbrindp1.ZENSPCD01) IS NOT NULL) then

                  obj_zclepf.ZENSPCD01 := obj_mbrindp1.ZENSPCD01;
                else

                  obj_zclepf.ZENSPCD01 := '                                                                      ';
                end if;
                IF (TRIM(obj_mbrindp1.ZENSPCD02) IS NOT NULL) then
                  obj_zclepf.ZENSPCD02 := obj_mbrindp1.ZENSPCD02;
                else
                  obj_zclepf.ZENSPCD02 := '                                                                      ';

                end if;
                IF (TRIM(obj_mbrindp1.Zcifcode) IS NOT NULL) then
                  obj_zclepf.ZCIFCODE := obj_mbrindp1.ZCIFCODE;
                else
                  obj_zclepf.ZCIFCODE := '               ';
                end if;
                obj_zclepf. usrprf := i_usrprf; --MB7 New Added
                obj_zclepf.JOBNM := i_scheduleName; --MB7 New Added
                obj_zclepf.DATIME := CAST(sysdate AS TIMESTAMP); --MB7 New Added

                 v_SEQ_ZCLEPF := SEQ_ZCLEPF.nextval;
                 obj_zclepf.unique_number := v_SEQ_ZCLEPF;
                INSERT INTO ZCLEPF VALUES obj_zclepf;

                /*
                ZCLEPFindex := ZCLEPFindex + 1;
                ZCLEPF_list.extend;
                ZCLEPF_list(ZCLEPFindex) := obj_zclepf;*/

                ---Insert into IG table "ZCLEPF" END ---*/
              END IF;
            END IF;

            ---Insert into IG table "zcelinkpf" START ---*/

            ---ITR4 CHANGE INSERT ZCELINKPF START----------------
            IF (obj_mbrindp1.CLNTSTAS = 'NW') THEN
              obj_zcelinkpf.CLNTPFX := TRIM(o_defaultvalues('CLNTPFX'));
              obj_zcelinkpf.CLNTCOY := TRIM(i_fsucocompany);
              obj_zcelinkpf.CLNTNUM := TRIM(obj_gchd.COWNNUM);
              obj_zcelinkpf.ZENDCDE := TRIM(obj_mbrindp1.zendcde);
              obj_zcelinkpf.USRPRF  := i_usrprf;
              obj_zcelinkpf.JOBNM   := i_scheduleName;
              obj_zcelinkpf.DATIME  := CAST(sysdate AS TIMESTAMP);
              INSERT INTO Jd1dta.VIEW_DM_ZCELINKPF VALUES obj_zcelinkpf;
            END IF;
            /*
            zcelinkpfindex := zcelinkpfindex + 1;
            zcelinkpf_list.extend;
            zcelinkpf_list(zcelinkpfindex) := obj_zcelinkpf;*/

            ---ITR4 CHANGE INSERT ZCELINKPF END----------------
            ---Insert into IG table "zcelinkpf" END ---
            -- insert in  IG CLRRPF for MP table start-

            --select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
            v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
            obj_clrrpf.CLNTCOY       := TRIM(i_fsucocompany);
            obj_clrrpf.CLNTNUM       := v_zigvalue;
            obj_clrrpf.CLRRROLE      := C_ROLE_MP;
            obj_clrrpf.FOREPFX       := o_defaultvalues('CHDRPFX');
            obj_clrrpf.FORECOY       := i_company;
            obj_clrrpf.FORENUM       := v_refnump1;
            obj_clrrpf.USED2B        := C_USED2B;
            obj_clrrpf.JOBNM         := i_scheduleName;
            obj_clrrpf.USRPRF        := i_usrprf;
            obj_clrrpf.DATIME        := sysdate;
            INSERT INTO CLRRPF VALUES obj_clrrpf;

            /*
            CLRRPFindex := CLRRPFindex + 1;
            CLRRPF_list.extend;
            CLRRPF_list(CLRRPFindex) := obj_CLRRPF;*/

            -- insert in  IG CLRRPF table end-

            --- insert in  IG AUDIT_CLRRPF for MP table start-
           v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_audit_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_audit_clrrpf.oldclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
            obj_audit_clrrpf.newclntcoy  := TRIM(i_fsucocompany);
            obj_audit_clrrpf.newclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclrrrole := C_ROLE_MP;
            obj_audit_clrrpf.newforepfx  := o_defaultvalues('CHDRPFX');
            obj_audit_clrrpf.newforecoy  := i_company;
            obj_audit_clrrpf.newforenum  := v_refnump1;
            obj_audit_clrrpf.newused2b   := C_USED2B;
            obj_audit_clrrpf.newusrprf   := i_usrprf;
            obj_audit_clrrpf.newjobnm    := i_scheduleName;
            obj_audit_clrrpf.newdatime   := sysdate;
            obj_audit_clrrpf.userid      := i_usrprf;
            obj_audit_clrrpf.action      := 'INSERT';
            obj_audit_clrrpf.tranno      := 2;
            obj_audit_clrrpf.systemdate  := sysdate;
            insert into audit_clrrpf values obj_audit_clrrpf;

            /*
            AUDIT_CLRRPFindex := AUDIT_CLRRPFindex + 1;
            AUDIT_CLRRPF_list.extend;
            AUDIT_CLRRPF_list(AUDIT_CLRRPFindex) := obj_AUDIT_CLRRPF;*/

            --- insert in  IG AUDIT_CLRRPF for MP table END-

            -- insert in  IG CLRRPF for OW table start-

            --select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
            v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
            obj_clrrpf.CLNTCOY       := TRIM(i_fsucocompany);
            obj_clrrpf.CLNTNUM       := v_zigvalue;
            obj_clrrpf.CLRRROLE      := C_ROLE_OW;
            obj_clrrpf.FOREPFX       := o_defaultvalues('CHDRPFX');
            obj_clrrpf.FORECOY       := i_company;
            obj_clrrpf.FORENUM       := v_refnump1;
            obj_clrrpf.USED2B        := C_USED2B;
            obj_clrrpf.JOBNM         := i_scheduleName;
            obj_clrrpf.USRPRF        := i_usrprf;
            obj_clrrpf.DATIME        := sysdate;
            INSERT INTO CLRRPF VALUES obj_clrrpf;

            /*
            CLRRPFindex := CLRRPFindex + 1;
            CLRRPF_list.extend;
            CLRRPF_list(CLRRPFindex) := obj_CLRRPF;*/
            -- insert in  IG CLRRPF for OW table END -

            --- insert in  IG AUDIT_CLRRPF for OW table start-
 v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_audit_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_audit_clrrpf.oldclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
            obj_audit_clrrpf.newclntcoy  := TRIM(i_fsucocompany);
            obj_audit_clrrpf.newclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclrrrole := C_ROLE_OW;
            obj_audit_clrrpf.newforepfx  := o_defaultvalues('CHDRPFX');
            obj_audit_clrrpf.newforecoy  := i_company;
            obj_audit_clrrpf.newforenum  := v_refnump1;
            obj_audit_clrrpf.newused2b   := C_USED2B;
            obj_audit_clrrpf.newusrprf   := i_usrprf;
            obj_audit_clrrpf.newjobnm    := i_scheduleName;
            obj_audit_clrrpf.newdatime   := sysdate;
            obj_audit_clrrpf.userid      := i_usrprf;
            obj_audit_clrrpf.action      := 'INSERT';
            obj_audit_clrrpf.tranno      := 2;
            obj_audit_clrrpf.systemdate  := sysdate;
            insert into audit_clrrpf values obj_audit_clrrpf;
          END IF;
          /*
          AUDIT_CLRRPFindex := AUDIT_CLRRPFindex + 1;
          AUDIT_CLRRPF_list.extend;
          AUDIT_CLRRPF_list(AUDIT_CLRRPFindex) := obj_AUDIT_CLRRPF;*/

          --- insert in  IG AUDIT_CLRRPF for OW table END-

        END IF;

        IF (obj_mbrindp1.client_category = '1') THEN
          ---Insert into IG table "GMHDPF" BEGIN (pq9ho.updateGmhdpf()) ---
          --MB19
          IF (obj_mbrindp1.LAST_TRXS = 'Y') THEN
            --SELECT SEQ_GMHDPF.nextval INTO v_seq_gmhdpf FROM dual;
            v_seq_gmhdpf := SEQ_GMHDPF.nextval; --PerfImprov
            obj_gmhdpf.unique_number := v_seq_gmhdpf;
            obj_gmhdpf.CHDRCOY       := i_company;
            obj_gmhdpf.CHDRNUM       := v_refnump1;
            obj_gmhdpf.MBRNO         := v_mbrno;
            obj_gmhdpf.DPNTNO        := o_defaultvalues('DPNTNO');
            --- 17/02/2018 After Pre-SIT execution
            IF (obj_PolDatarec.statcode = 'CA' or
               obj_PolDatarec.statcode = 'LA') THEN
              obj_gmhdpf.DTETRM := obj_mbrindp1.dtetrm;
	       /*-- MB24 : Calculation Base Date EFDATE Determination Logic: START -----------------
              v_daytempccdate  := substr(obj_gchipf.CCDATE, 7, 2); --CCDATE :: DD
              v_daytempeffdate := substr(obj_mbrindp1.dtetrm, 7, 2); -- dtetrm :: DD
              IF (v_daytempccdate = v_daytempeffdate) THEN
                 obj_gmhdpf.DTETRM := obj_mbrindp1.dtetrm;
              ELSE
                v_efdatetemp      := DATCONOPERATION('MONTH', obj_mbrindp1.dtetrm);
                v_yearmonthtemp   := substr(v_efdatetemp, 1, 6);
                v_efdatefinal     := v_yearmonthtemp || v_daytempccdate;
                obj_gmhdpf.DTETRM := v_efdatefinal;
              END IF;
              -- MB24 : Calculation Base Date EFDATE Determination Logic: END -----------------*/
	      
            ELSE
              obj_gmhdpf.DTETRM := C_MAXDATE;
            END IF;
            obj_gmhdpf.REASONTRM := null;
            obj_gmhdpf.PNDATE    := obj_mbrindp1.docrcvdt;
            obj_gmhdpf.CLNTPFX   := o_defaultvalues('CLNTPFX');
            obj_gmhdpf.FSUCO     := i_fsucocompany;
            obj_gmhdpf.CLNTNUM   := v_zigvalue;
            obj_gmhdpf.HEADCNT   := o_defaultvalues('HEADCNT');
            obj_gmhdpf.DTEATT    := obj_mbrindp1.occdate;
            obj_gmhdpf.RELN      := obj_mbrindp1.cltreln;
            obj_gmhdpf.FAUWDT    := C_MAXDATE;
            obj_gmhdpf.LDPNTNO   := o_defaultvalues('LDPNTNO');
            obj_gmhdpf.TERMID    := i_vrcmTermid;
            obj_gmhdpf.TRDT      := C_TRDT;
            obj_gmhdpf.TRTM      := C_TRTM;
            IF (TRIM(obj_PolDatarec.statcode) = 'CA') THEN
              obj_gmhdpf.TRANNO := obj_mbrindp1.trannomax;
            ELSE
              obj_gmhdpf.TRANNO := obj_mbrindp1.trannomin;
            END IF;
            obj_gmhdpf.CLIENT   := v_zigvalue;
            obj_gmhdpf.GHEIGHT  := C_ZERO;
            obj_gmhdpf.GWEIGHT  := C_ZERO;
            obj_gmhdpf.PRVPOLDT := C_MAXDATE;
            -- v_cltdob            := clntdob(TRIM(v_zigvalue));
            v_cltdob            := obj_mbrindp1.cltdob;
            v_datconage         := DATEDIFF('YEAR',
                                            v_cltdob,
                                            obj_mbrindp1.effdate);
            obj_gmhdpf.AGE      := v_datconage;
            obj_gmhdpf.ORDOB    := C_ZERO;
            obj_gmhdpf.MEDCMPDT := C_MAXDATE;
            obj_gmhdpf.SIFACT   := C_BIGDECIMAL_DEFAULT1;
            obj_gmhdpf.INSUFFMN := 'Y'; --MB7
            obj_gmhdpf.USRPRF   := i_usrprf;
            obj_gmhdpf.JOBNM    := i_scheduleName;
            obj_gmhdpf.DATIME   := CAST(sysdate AS TIMESTAMP);
            obj_gmhdpf.USER_T   := i_user_t;
            obj_gmhdpf.ZANNCLDT := obj_mbrindp1.zanncldt;
           /* obj_gmhdpf.ZCPNSCDE := obj_mbrindp1.zcmpcode ||
                                   obj_mbrindp1.zcpnscde02;*/ --MB20
            obj_gmhdpf.CLTRELN  := obj_mbrindp1.cltreln;

            ----MB18---
            obj_gmhdpf.MEDEVD       := null;
            obj_gmhdpf.TERMRSNCD    := null;
            obj_gmhdpf.REFIND       := null;
            obj_gmhdpf.EMPNO        := null;
            obj_gmhdpf.SMOKEIND     := null;
            obj_gmhdpf.OCCPCLAS     := null;
            obj_gmhdpf.ETHORG       := null;
            obj_gmhdpf.PAYMMETH     := null;
            obj_gmhdpf.DEFCLMPYE    := null;
            obj_gmhdpf.DEPT         := null;
            obj_gmhdpf.NEWOLDCL     := null;
            obj_gmhdpf.STATCODE     := obj_PolDatarec.statcode;
            obj_gmhdpf.BANKACCKEY   := null;
            obj_gmhdpf.APPLICNO     := null;
            obj_gmhdpf.CERTNO       := null;
            obj_gmhdpf.INFORCE      := null;
            obj_gmhdpf.WEIGHTUNIT   := null;
            obj_gmhdpf.HEIGHTUNIT   := null;
            obj_gmhdpf.MBRTYPC      := null;
            obj_gmhdpf.RDYPROC      := null;
            obj_gmhdpf.DPNTTYPE     := null;
            obj_gmhdpf.SECUITYNO    := null;
            obj_gmhdpf.SUBSNUM      := null;
            obj_gmhdpf.CNTRCDHRS    := null;
            obj_gmhdpf.EMPLYMNTBSIS := null;
            obj_gmhdpf.USCITIZENFLG := null;
            obj_gmhdpf.LCTDOVRCSFLG := null;
            obj_gmhdpf.NRSVISATP    := null;
            obj_gmhdpf.STOFDMCL     := null;
            obj_gmhdpf.EMPLYR       := null;
            obj_gmhdpf.CMNT         := null;
            obj_gmhdpf.ZDFCNCY      := obj_mbrindp1.zdfcncy;
            obj_gmhdpf.ZMARGNFLG    := obj_mbrindp1.zmargnflg;
            obj_gmhdpf.REPORTFLAG   := null;
            obj_gmhdpf.DISTYP       := null;
            obj_gmhdpf.REPTFROM     := null;
            obj_gmhdpf.REPTTO       := null;
            obj_gmhdpf.ACCNTMONTH   := null;
            obj_gmhdpf.ACCNTYEAR    := null;
            ---MB18----
            --MB19
            obj_gmhdpf.VOLTYPE := null;

            INSERT INTO GMHDPF VALUES obj_gmhdpf;
          END IF;
          /*
          GMHDPFindex := GMHDPFindex + 1;
          GMHDPF_list.extend;
          GMHDPF_list(GMHDPFindex) := obj_gmhdpf;*/

          ---Insert into IG table "GMHDPF" END ---
          ---Insert into IG table "GMHIPF" BEGIN  (pq9ho.updateGmhipf()) ---
          --SELECT SEQ_GMHIPF.nextval INTO v_seq_gmhipf FROM dual;
          v_seq_gmhipf := SEQ_GMHIPF.nextval; --PerfImprov
          obj_gmhipf.unique_number := v_seq_gmhipf;
          obj_gmhipf.CHDRCOY       := i_company;
          obj_gmhipf.CHDRNUM       := v_refKeyp1;
          obj_gmhipf.MBRNO         := v_mbrno;
          obj_gmhipf.DPNTNO        := o_defaultvalues('DPNTNO');
          obj_gmhipf.EFFDATE       := obj_mbrindp1.effdate;
          IF (obj_PolDatarec.statcode = 'CA' OR
             obj_PolDatarec.statcode = 'LA') THEN
            obj_gmhipf.DTETRM := obj_mbrindp1.dtetrm;
	    
	      /* -- MB24 : Calculation Base Date EFDATE Determination Logic: START -----------------
              v_daytempccdate  := substr(obj_gchipf.CCDATE, 7, 2); --CCDATE :: DD
              v_daytempeffdate := substr(obj_mbrindp1.dtetrm, 7, 2); -- dtetrm :: DD
              IF (v_daytempccdate = v_daytempeffdate) THEN
                 obj_gmhipf.DTETRM  := obj_mbrindp1.dtetrm;
              ELSE
                v_efdatetemp      := DATCONOPERATION('MONTH', obj_mbrindp1.dtetrm);
                v_yearmonthtemp   := substr(v_efdatetemp, 1, 6);
                v_efdatefinal     := v_yearmonthtemp || v_daytempccdate;
                obj_gmhipf.DTETRM  := v_efdatefinal;
              END IF;
              -- MB24 : Calculation Base Date EFDATE Determination Logic: END -----------------*/
	      
          elsIF (obj_PolDatarec.statcode = 'IF') THEN
            if (obj_PolDatarec.total_period_count > 1 and
               obj_PolDatarec.PERIOD_NO = 1) THEN
              obj_gmhipf.DTETRM := obj_mbrindp1.crdate;
            else
              obj_gmhipf.DTETRM := C_MAXDATE;
            END IF;
          ELSE
            obj_gmhipf.DTETRM := C_MAXDATE;
          END IF;
          obj_gmhipf.SALARY := C_BIGDECIMAL_DEFAULT;
          obj_gmhipf.DTEAPP := C_MAXDATE;
          obj_gmhipf.SBSTDL := C_SPACE;
          obj_gmhipf.TERMID := i_vrcmTermid;
          obj_gmhipf.TRDT   := C_TRDT;
          obj_gmhipf.TRTM   := C_TRTM;
          IF (TRIM(obj_PolDatarec.statcode) = 'CA') THEN
            obj_gmhipf.TRANNO := obj_mbrindp1.trannomax;
          ELSE
            obj_gmhipf.TRANNO := obj_mbrindp1.trannonbrn;
          END IF;
          obj_gmhipf.PERSONCOV := o_defaultvalues('PERSONCOV');
          obj_gmhipf.MLVLPLAN  := o_defaultvalues('MLVLPLAN');
          obj_gmhipf.CLNTCOY   := TRIM(i_fsucocompany); --MB7 MB21
          obj_gmhipf.EARNING   := C_BIGDECIMAL_DEFAULT;
          obj_gmhipf.CTBPRCNT  := C_BIGDECIMAL_DEFAULT;
          obj_gmhipf.CTBAMT    := C_BIGDECIMAL_DEFAULT;
          obj_gmhipf.USRPRF    := i_usrprf;
          obj_gmhipf.JOBNM     := i_scheduleName;
          obj_gmhipf.DATIME    := CAST(sysdate AS TIMESTAMP);
          obj_gmhipf.ZTRXSTAT  := obj_mbrindp1.ztrxstat;
          obj_gmhipf.QUOTENO   := C_SPACE;
          obj_gmhipf.ZDCRSNCD  := null;
          obj_gmhipf.ZDECLCAT  := C_SPACE;
          obj_gmhipf.DATATYPE  := null;
          obj_gmhipf.ZPRMSI    := v_zprmsi;
          obj_gmhipf.ZADCHCTL  := null;
          obj_gmhipf.USER_T    := i_user_t;
          obj_gmhipf.NOTSFROM  := n_issdate;
          obj_gmhipf.ZSTATRESN := obj_mbrindp1.zstatresn;
          obj_gmhipf.HPROPDTE  := obj_mbrindp1.hpropdte;
          obj_gmhipf.ADDRINDC  := C_SPACE; --MB7
        --  obj_gmhipf.ZWRKPCT   := o_defaultvalues('ZWRKPCT'); --MB21
         obj_gmhipf.ZWRKPCT   := null; --MB21
          obj_gmhipf.ZINHDSCLM := o_defaultvalues('ZINHDSCLM');
          obj_gmhipf.DOCRCDTE  := obj_mbrindp1.docrcvdt;
          obj_gmhipf.ZPLANCDE  := obj_mbrindp1.zplancde;

          ----------MB18----
          obj_gmhipf.SUBSCOY    := null;
          obj_gmhipf.SUBSNUM    := null;
          obj_gmhipf.OCCPCODE   := null;
          obj_gmhipf.FUPFLG     := null;
          obj_gmhipf.CLIENT     := null;
          obj_gmhipf.PCCCLNT    := null;
          obj_gmhipf.APCCCLNT   := null;
          obj_gmhipf.ISSTAFF    := null;
          obj_gmhipf.DCLDATE    := C_MAXDATE;
          obj_gmhipf.ZDCLITEM01 := null;
          obj_gmhipf.ZDCLITEM02 := null;
          v_insendate           := to_number(TO_CHAR(to_date(obj_gchipf.CRDATE,
                                                             'yyyymmdd') + 1,
                                                     'yyyymmdd'));

          obj_gmhipf.ZCENDDTE   := v_insendate;
          obj_gmhipf.ZWORKPLCE1 := null; --SHI it was null and there was no impact
          obj_gmhipf.ZWORKPLCE2 := null; -- SHI is was null and there was no impact
          obj_gmhipf.ZPOLDTFLG  := null;
          obj_gmhipf.OPTBENEFIT := null;
          obj_gmhipf.WATNGPRD   := null;

          ---------MB18----------
          --MB19
          obj_gmhipf.SIFACTOR := null;

          INSERT INTO GMHIPF VALUES obj_gmhipf;
          /*
          GMHIPFindex := GMHIPFindex + 1;
          GMHIPF_list.extend;
          GMHIPF_list(GMHIPFindex) := obj_gmhipf;*/

          ---Insert into IG table "GMHIPF" END ---
          ---Insert into IG table "zcelinkpf" START ---*/
          --MB19
          IF (obj_mbrindp1.LAST_TRXS = 'Y') THEN
            IF NOT (Map_OwnerCln.exists(v_zigvalue)) THEN
              IF (obj_mbrindp1.CLNTSTAS = 'NW') THEN
                ---ITR4 CHANGE INSERT ZCELINKPF START----------------
                obj_zcelinkpf.CLNTPFX := TRIM(o_defaultvalues('CLNTPFX'));
                obj_zcelinkpf.CLNTCOY := TRIM(i_fsucocompany);
                obj_zcelinkpf.CLNTNUM := TRIM(v_zigvalue);
                obj_zcelinkpf.ZENDCDE := TRIM(obj_mbrindp1.zendcde);
                obj_zcelinkpf.USRPRF  := i_usrprf;
                obj_zcelinkpf.JOBNM   := i_scheduleName;
                obj_zcelinkpf.DATIME  := CAST(sysdate AS TIMESTAMP);
                INSERT INTO Jd1dta.VIEW_DM_ZCELINKPF VALUES obj_zcelinkpf;
              end if;
              /*
              zcelinkpfindex := zcelinkpfindex + 1;
              zcelinkpf_list.extend;
              zcelinkpf_list(zcelinkpfindex) := obj_zcelinkpf;*/
            end if;
            ---ITR4 CHANGE INSERT ZCELINKPF END----------------

            ---Insert into IG table "zcelinkpf" END ---

            -- insert in  IG CLRRPF for LF table start-
            --MB19
            --select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
            v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
            obj_clrrpf.CLNTCOY       := TRIM(i_fsucocompany);
            obj_clrrpf.CLNTNUM       := v_zigvalue;
            obj_clrrpf.CLRRROLE      := C_ROLE_LF;
            obj_clrrpf.FOREPFX       := o_defaultvalues('CHDRPFX');
            obj_clrrpf.FORECOY       := i_company;
            obj_clrrpf.FORENUM       := v_refnump1;
            obj_clrrpf.USED2B        := C_USED2B;
            obj_clrrpf.JOBNM         := i_scheduleName;
            obj_clrrpf.USRPRF        := i_usrprf;
            obj_clrrpf.DATIME        := sysdate;
            INSERT INTO CLRRPF VALUES obj_clrrpf;
            /*
            CLRRPFindex := CLRRPFindex + 1;
            CLRRPF_list.extend;
            CLRRPF_list(CLRRPFindex) := obj_CLRRPF;*/

            -- insert in  IG CLRRPF for LF table END -

            --- insert in  IG AUDIT_CLRRPF for LF table start-
            --MB19
             v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
            obj_audit_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
            obj_audit_clrrpf.oldclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
            obj_audit_clrrpf.newclntcoy  := TRIM(i_fsucocompany);
            obj_audit_clrrpf.newclntnum  := v_zigvalue;
            obj_audit_clrrpf.newclrrrole := C_ROLE_LF;
            obj_audit_clrrpf.newforepfx  := o_defaultvalues('CHDRPFX');
            obj_audit_clrrpf.newforecoy  := i_company;
            obj_audit_clrrpf.newforenum  := v_refnump1;
            obj_audit_clrrpf.newused2b   := C_USED2B;
            obj_audit_clrrpf.newusrprf   := i_usrprf;
            obj_audit_clrrpf.newjobnm    := i_scheduleName;
            obj_audit_clrrpf.newdatime   := sysdate;
            obj_audit_clrrpf.userid      := i_usrprf;
            obj_audit_clrrpf.action      := 'INSERT';
            obj_audit_clrrpf.tranno      := 2;
            obj_audit_clrrpf.systemdate  := sysdate;
            insert into audit_clrrpf values obj_audit_clrrpf;

            /*
            AUDIT_CLRRPFindex := AUDIT_CLRRPFindex + 1;
             AUDIT_CLRRPF_list.extend;
             AUDIT_CLRRPF_list(AUDIT_CLRRPFindex) := obj_AUDIT_CLRRPF;*/

            --- insert in  IG AUDIT_CLRRPF for LF table END-
          END IF;
        END IF;

      END IF;

    end loop;

    /*
    --Its giving ora-12838 cannot read/modify an object after modifying it in parallel in forall
    --if we are comminting for each bulk collection then is working fine or we can remove append_values hint
      idx := gchd_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN gchd_list.first .. gchd_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.GCHD
        VALUES gchd_list
          (idx);

    END IF;

       idx := gchppf_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN gchppf_list.first .. gchppf_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.GCHPPF
        VALUES gchppf_list
          (idx);

    END IF;

    idx := GCHIPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN GCHIPF_list.first .. GCHIPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.GCHIPF
        VALUES GCHIPF_list
          (idx);
    END IF;

    idx := ZCLEPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN ZCLEPF_list.first .. ZCLEPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.ZCLEPF
        VALUES ZCLEPF_list
          (idx);
    END IF;

    idx := CLRRPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN CLRRPF_list.first .. CLRRPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.CLRRPF
        VALUES CLRRPF_list
          (idx);
    END IF;

    idx := AUDIT_CLRRPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN AUDIT_CLRRPF_list.first .. AUDIT_CLRRPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.AUDIT_CLRRPF
        VALUES AUDIT_CLRRPF_list
          (idx);
    END IF;

    idx := GMHIPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN GMHIPF_list.first .. GMHIPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.GMHIPF
        VALUES GMHIPF_list
          (idx);
    END IF;

    idx := GMHDPF_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN GMHDPF_list.first .. GMHDPF_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.GMHDPF
        VALUES GMHDPF_list
          (idx);
    END IF;

    idx := zcelinkpf_list.first;
    IF (idx IS NOT NULL) THEN
      FORALL idx IN zcelinkpf_list.first .. zcelinkpf_list.last
        INSERT \*+ APPEND_VALUES *\
        INTO Jd1dta.VIEW_DM_ZCELINKPF
        VALUES zcelinkpf_list
          (idx);
    END IF;


    gchd_list.delete;
    gchppf_list.delete;
    ZCLEPF_list.delete;
    CLRRPF_list.delete;
    AUDIT_CLRRPF_list.delete;
    GCHIPF_list.delete;
    GMHIPF_list.delete;
    GMHDPF_list.delete;
    zcelinkpf_list.delete;

    gchdindex         := 0;
    gchppfindex       := 0;
    GCHIPFindex       := 0;
    ZCLEPFindex       := 0;
    CLRRPFindex       := 0;
    AUDIT_CLRRPFindex := 0;
    GMHIPFindex       := 0;
    GMHDPFindex       := 0;
    zcelinkpfindex    := 0;*/

    EXIT WHEN cur_mbr_ind_p1%notfound;

  END LOOP;

  CLOSE cur_mbr_ind_p1;

  dbms_output.put_line('End execution of BQ9SC_MB01_MBRIND, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'BQ9SC_MB01_MBRIND : ' || i_scheduleName || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm || ' ' ||
                  v_refnump1;

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

    commit;
    raise;

    dbms_output.put_line('Procedure execution time = ' ||
                         (dbms_utility.get_time - v_timestart) / 100);

  --DBMS_PROFILER.stop_profiler;
END BQ9SC_MB01_MBRIND;

/
