create or replace PROCEDURE                                                                  "BQ9UU_MB01_POLHIST" (i_schedulename   IN VARCHAR2,
                                               i_schedulenumber IN VARCHAR2,
                                               i_zprvaldyn      IN VARCHAR2,
                                               i_company        IN VARCHAR2,
                                               i_userprofile    IN VARCHAR2,
                                               i_branch         IN VARCHAR2,
                                               i_transcode      IN VARCHAR2,
                                               i_vrcmTermid     IN VARCHAR2) AS
                                               
  /***************************************************************************************************
  * Amenment History: MB01 Policy Transaction
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   PH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0501     SC    PH2   Performance change for Dm rehearsal.
  * 0502     SC    PH3   LOGIC CHANGED TO GET UNIQUE_NUMBER FROM PAZDCHPF(PREVIOUSLY ZCLNPF).
  * 0504     PS    PH4   Bank Desc , Bank Key and Bank Acct Type for Credit Card needs to be taken from CLBAPF
  *                      when Credit Card Number field is not null. TRANCDE must be set to T902 for first transation
  *                      otherwise, it must be set to T912.
  * 0504     SC    PH5   CHANGED FOR #7685 - [functional issue]screen validation incorrect. 
  * 0505     SC    PH6   Length of columns ZCNBRFRM and ZCNBRTO of ZENCTPF is increased from 6 to 20.
  * 0505     SC    PH7   Change for Tciket #7843 -Incorrect Fields on ZALTPF
  * 0507     SC    PH8   ITR4 - LOT2 Changes
  * 0508     SC    PH9   Changes For Ticket #7852 -Incorrect Fields on ZTRAPF
  * 0511     RC    PH10  Data Verification Changes
  * 0512     PS    PH11  Data Verification Changes
  * 0516     SJ    PH12  Removed unused fields like company   
  * 0517     SJ    PH13  Added check for ZCARDDC(card digit count) on ZENCTPF to get card type
  * 0528     SC    PH14  ZDDREQNO field added in Policy History trsanction Module.
  * 0710     RC    PH15  EFDATE for ZTRAPF
  * 1107     JDB   PH16  Solution for converted policy
  * 0518     SK    PH17  Implemented Logic to fetch limited records to avoid PGA memory issue   
  * 0721     PS    PH18  PREAUTNO to accept null values   
  *****************************************************************************************************/
  ----------------------------VARIABLES DECLARATION START-----------------------------------------------
  v_timestart NUMBER := dbms_utility.get_time; --Timecheck
  v_chdrnum   TITDMGPOLTRNH.CHDRNUM@DMSTAGEDBLINK%TYPE;
  /* Contract Number  */
  v_zseqno TITDMGPOLTRNH.ZSEQNO@DMSTAGEDBLINK%TYPE;
  /* Sequence Number  */
  v_effdate TITDMGPOLTRNH.EFFDATE@DMSTAGEDBLINK%TYPE;
  /* Alteration Date  */
  v_zaltregdat TITDMGPOLTRNH.ZALTREGDAT@DMSTAGEDBLINK%TYPE;
  /* Alteration registration date  */
  v_zaltrcde01 TITDMGPOLTRNH.ZALTRCDE01@DMSTAGEDBLINK%TYPE;
  /* Alteration Reason 01  */
  v_zinhdsclm TITDMGPOLTRNH.ZINHDSCLM@DMSTAGEDBLINK%TYPE;
  /* Inheritance Disclaimer Flag  */
  v_zuwrejflg TITDMGPOLTRNH.ZUWREJFLG@DMSTAGEDBLINK%TYPE;
  /* Underwriting Rejection flag  */
  v_zstopbpj TITDMGPOLTRNH.ZSTOPBPJ@DMSTAGEDBLINK%TYPE;
  /* 2nd Stop Bill to P/J  */
  v_ztrxstat TITDMGPOLTRNH.ZTRXSTAT@DMSTAGEDBLINK%TYPE;
  /* Txn Status   */
  v_zstatresn TITDMGPOLTRNH.ZSTATRESN@DMSTAGEDBLINK%TYPE;
  /* Status Reason  */
  v_zaclsdat TITDMGPOLTRNH.ZACLSDAT@DMSTAGEDBLINK%TYPE;
  /* AnnounceClosure Dte */
  v_apprdte TITDMGPOLTRNH.APPRDTE@DMSTAGEDBLINK%TYPE;
  /* Approval Date  */
  v_zpdatatxdte TITDMGPOLTRNH.ZPDATATXDTE@DMSTAGEDBLINK%TYPE;
  /* Policy data Transfer date  */
  v_zpdatatxflg TITDMGPOLTRNH.ZPDATATXFLG@DMSTAGEDBLINK%TYPE;
  /* Policy data Transfer Flag  */
  v_zrefundam TITDMGPOLTRNH.ZREFUNDAM@DMSTAGEDBLINK%TYPE;
  /* Refund Amount  */
  v_zpayinreq TITDMGPOLTRNH.ZPAYINREQ@DMSTAGEDBLINK%TYPE;
  /* PAY-IN REQUIRED FLAG  */
 -- v_crdtcard TITDMGPOLTRNH.CRDTCARD@DMSTAGEDBLINK%TYPE;
  v_crdtcard varchar2(16 char);
  /* Credit Card No.  */
  v_preautno TITDMGPOLTRNH.PREAUTNO@DMSTAGEDBLINK%TYPE;
  /* Card Approval No.  */
  v_bnkacckey01 TITDMGPOLTRNH.BNKACCKEY01@DMSTAGEDBLINK%TYPE;
  /* Bank A/C No. */
  v_zenspcd01 TITDMGPOLTRNH.ZENSPCD01@DMSTAGEDBLINK%TYPE;
  /* Endorser Specific Code 1  */
  v_zenspcd02 TITDMGPOLTRNH.ZENSPCD02@DMSTAGEDBLINK%TYPE;
  /* Endorser Specific Code 2  */
  v_zcifcode TITDMGPOLTRNH.ZCIFCODE@DMSTAGEDBLINK%TYPE;
  /* CIF code  */
------------------------PH14-START----------------------------
  v_zddreqno TITDMGPOLTRNH.ZDDREQNO@DMSTAGEDBLINK%TYPE;
------------------------PH14-END------------------------------

 -- v_temp_crdtcard TITDMGPOLTRNH.CRDTCARD@DMSTAGEDBLINK%type;
   v_temp_crdtcard varchar2(16 char);
  i_text          DMLOG.LTEXT%type;
  --v_zseqno TITDMGPOLTRNH.zseqno@DMSTAGEDBLINK%type;

  v_zendcde         GCHPPF.ZENDCDE%type;
  v_zccflag         ZENCIPF.ZCCFLAG%type;
  v_zbnkflag        ZENCIPF.ZBNKFLAG%type;
  v_clientnum       PAZDCLPF.ZIGVALUE%type;
  v_bankaccdsc      CLBAPF.Bankaccdsc%type;
  v_bnkactyp        CLBAPF.Bnkactyp%type;
  v_bankkey         CLBAPF.Bankkey%type;
  v_mthto           CLBAPF.Mthto%type := 0;
  v_yearto          CLBAPF.Yearto%type := 0;
  v_zcrdtype        ZENCTPF.ZCRDTYPE%type;
  v_tranno          ZTRAPF.TRANNO%type;
  i_fsucompany      CLBAPF.CLNTCOY%type := 9;
  v_unique_number01 NUMBER(18, 0) DEFAULT 0;
  v_prv_polnum      ZTRAPF.CHDRNUM%type;
  v_last_tranno     ZTRAPF.TRANNO%type;
  v_isrecordexixts  NUMBER(1) DEFAULT 0;
  v_statcode        GCHD.STATCODE%type;
  v_mplnum          GCHD.MPLNUM%type;
  v_cownnum         GCHD.COWNNUM%type;
  v_refkey          VARCHAR2(50 CHAR);
  v_errorcount      NUMBER(1) DEFAULT 0;
  v_isvalid         NUMBER(1) DEFAULT 0;
  v_isdatevalid     VARCHAR2(20 CHAR);
  v_isduplicate     NUMBER(1) DEFAULT 0;
  v_isexist         NUMBER(1) DEFAULT 0;
  v_isanyerror      VARCHAR2(1) DEFAULT 'N';
  v_migrationprefix VARCHAR2(2);
  v_chdrpfx         VARCHAR2(20 CHAR);
  v_space           VARCHAR2(2) DEFAULT ' ';
  v_zero            NUMBER(2) DEFAULT 0;
  v_maxdate         NUMBER(8) DEFAULT 99999999;
  v_last_rowcnt     NUMBER DEFAULT 0;

  --SIT CHNAGE START--
  v_zcmpcode       GCHIPF.ZCMPCODE%type;
  v_zcpnscde       GMHIPF.ZCPNSCDE%type;
  v_zconvindpol    GCHPPF.ZCONVINDPOL%type;
  v_zsalechnl      GMHDPF.ZSALECHNL%type;
  v_zsolctflg      GCHIPF.ZSOLCTFLG%type;
  v_zplancde       GMHIPF.ZPLANCDE%type;
  v_dcldate        GMHIPF.DCLDATE%type;
  v_zdclitem01     GMHIPF.ZDCLITEM01%type;
  v_zdclitem02     GMHIPF.ZDCLITEM02%type;
  v_zdeclcat       GMHIPF.ZDECLCAT%type;
  v_tranlused      GCHD.TRANLUSED%type;
  v_ccdate         gchipf.ccdate%type;
  v_efdatetemp     ztrapf.efdate%type;
  v_daytempccdate  varchar(2);
  v_daytempeffdate varchar(2);
  v_yearmonthtemp  number(6);
  v_efdatefinal    ztrapf.efdate%type;

----- PH15: START------
  v_newefdate ztrapf.efdate%type;
----- PH15: END------

temp_val NUMBER DEFAULT 0;
--SIT CHANGE END--

  v_zplancls       GCHPPF.ZPLANCLS%type; --TICKET- #7540- DM REHEARSAL-------

-------------PH2:START---------------------------------------------------------------------
 v_temp_cownum GCHD.COWNNUM%type;
 v_temp_effdate ZTRAPF.EFFDATE%type;
-------------PH2:END-----------------------------------------------------------------------

-------------PH3:START---------------------------------------------------------------------
 v_seqno_cl2 NUMBER DEFAULT 0;
 v_temp_seqno_cl2 NUMBER DEFAULT 0;
-------------PH3:START---------------------------------------------------------------------

----------------PH5: START-------------------------------------------------------------------  
   v_btdate       GCHD.BTDATE%type;       
   v_zdfcncy      GMHIPF.ZDFCNCY%type;  
   v_zmargnflg    GMHIPF.ZMARGNFLG%type; 
   v_zpgpfrdt     GCHPPF.ZPGPFRDT%type; 
   v_zpgptodt     GCHPPF.ZPGPTODT%type; 
----------------PH5: START-------------------------------------------------------------------   
----------------PH7: START-------------------------------------------------------------------  
   v_cltreln       GMHD.CLTRELN%type;       
----------------PH7: END------------------------------------------------------------------- 
---- [START] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue
    v_range_from GCHD.chdrnum%type;
    v_range_to   GCHD.chdrnum%type;
---- [END] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue
  -----------------------VARIABLE FOR DEFAULT VALUES-----------------------------
  --CHANGE THIS ACCORDINGLY FOR TRANSACTION HISTORY AS THERE NO OTHER ENTRY FOR THIS
  v_validflag VARCHAR2(20 CHAR);
  v_zquotind  VARCHAR2(20 CHAR);
  v_mbrno     VARCHAR2(20 CHAR);
  v_dpntno    VARCHAR2(20 CHAR);
-------------PH7: START------------------------------------
--  v_clntreln  VARCHAR2(20 CHAR); --SIT change
-------------PH7: END--------------------------------------
  /*  ITR4 - PH8 - LOT2 changes -- Start */
  --v_zpgpfrdt  VARCHAR2(20 CHAR);--Itr4 Lot2 Change // declared already, hence not required
  --v_zpgptodt  VARCHAR2(20 CHAR);--Itr4 Lot2 Change // declared already, hence not required
  /*  ITR4 - PH8 - LOT2 changes -- Start */
  ----------------------------VARIABLES DECLARATION END----------------------------------------------------------------
  ----------------PH9: START------------------------------------------------------------------- 
   v_zpoltdate       GCHPPF.ZPOLTDATE%type; 
   v_cltdob          CLNTPF.CLTDOB%type; 
   v_startdateMM     NUMBER(4);
   v_enddateMM       NUMBER(4);
   v_startdateYY     NUMBER(4);
   v_enddateYY       NUMBER(4); 
   v_age             ZTRAPF.AGE%type; 
  ----------------PH9: END-------------------------------------------------------------------  
  ----------------------------OBJECT FOR IG TABLES START----------------------------------------------------------
  obj_ztrapf VIEW_DM_ZTRAPF%rowtype;
  obj_zmcipf zmcipf%rowtype;
  --obj_clbapf clbapf%rowtype;



  obj_gchd   pkg_common_dmmb_phst.OBJ_GCHD;
  obj_zaltpf VIEW_DM_ZALTPF%rowtype;

  --SIT CHNAGE START--
  --obj_gchi GCHIPF%rowtype;
  obj_gchi pkg_common_dmmb_phst.OBJ_GCHI;
  obj_gmhi pkg_common_dmmb_phst.OBJ_GMHI;
  obj_gchp pkg_common_dmmb_phst.OBJ_GCHP;
  obj_gmhd pkg_common_dmmb_phst.OBJ_GMHD;

  obj_zencipf pkg_common_dmmb_phst.OBJ_ZENCIPF;--PH2:CHANGE---

-------------PH3:START-------------------------------------------------------------------

-----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START------
  --obj_zclnpf pkg_common_dmmb_phst.OBJ_ZCLNPF;
-----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END-------- 

-----------Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: START------
    obj_zdchpf pkg_common_dmmb_phst.OBJ_ZDCHPF;
-----------Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: END-------- 

-------------PH3:END-------------------------------------------------------------------

obj_clbapf_cc  pkg_common_dmmb_phst.OBJ_CLBAPF_CC;
obj_clbapf_bn   pkg_common_dmmb_phst.OBJ_CLBAPF_BN;
  --SIT CHANGE END--
  ----------------------------OBJECT FOR IG TABLES END------------------------------------------------------------

  --------------------------------CONSTANTS----------------------------------------------------------------------------
  c_prefix CONSTANT VARCHAR2(2) := get_migration_prefix('PHST', i_company); /* Policy Transaction History  */
  -----------------------------ERROR CONSTANTS-------------------------------------------------------------------------
  c_errorcount CONSTANT NUMBER := 5;
  c_Z101       CONSTANT VARCHAR2(4) := 'RQO7'; /*Policy not in IG */
  c_Z099       CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicated record found*/
  c_Z013       CONSTANT VARCHAR2(4) := 'RQLT'; /*Invalid Date*/
  c_Z104       CONSTANT VARCHAR2(4) := 'RQOA'; /*Invalid Altr Reason code */
  c_Z007       CONSTANT VARCHAR2(4) := 'RQLN'; /*Transaction Status not in TQ9FT*/
  c_Z008       CONSTANT VARCHAR2(4) := 'RQLO'; /*Status Reason not in TQ9FU */
  c_Z011       CONSTANT VARCHAR2(4) := 'RQQ1'; /*Credit Card No/Bank Account No/ Endorser specific code is blank*/
  c_Z075       CONSTANT VARCHAR2(4) := 'RQNJ'; /*Credit card is mandatory */
  c_RFTQ       CONSTANT VARCHAR2(4) := 'RFTQ'; /*Invalid Credit Card No*/
  c_Z076       CONSTANT VARCHAR2(4) := 'RQNK'; /* PREAUTNO is mandatory */
  c_Z077       CONSTANT VARCHAR2(4) := 'RQNL'; /*BANKACCNO is mandatory*/
  c_F826       CONSTANT VARCHAR2(4) := 'F826'; /*Bank account not on file */
  c_bq9uu      CONSTANT VARCHAR2(5) := 'BQ9UU';
  c_bq9sc      CONSTANT VARCHAR2(5) := 'BQ9SC';

  --------------------------COMMON FUNCTION START-----------------------------------------------------------------------
  v_tablenametemp VARCHAR2(10);
  v_tablename     VARCHAR2(10);
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  --checkZendcde    pkg_common_dmmb_phst.gchppftype; ---DM REHEARSAL PERFORMANCE----
  -- checkClient     pkg_common_dmmb_phst.zdclpftype; --PH12: commented as not required: discussed with Patrice May16
  getclbaforcc    pkg_common_dmmb_phst.clbatype;
  getclbaforbnk   pkg_common_dmmb_phst.clbatype1;
  getgchd         pkg_common_dmmb_phst.gchdtype1;
  --SIT CHNAGE START---
  getgchipf pkg_common_dmmb_phst.gchItype1;
  getgmhipf pkg_common_dmmb_phst.gmhitype;
  getgchppf pkg_common_dmmb_phst.gchptype;
  getgmhdpf pkg_common_dmmb_phst.gmhdtype;

-------------PH3:START-------------------------------------------------------------------

----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START------
   --getzclnpf pkg_common_dmmb_phst.zclnpftype;
----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END--------

----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: START------
   getzdchpf pkg_common_dmmb_phst.zdchpftype;
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: END--------

-------------PH3:END---------------------------------------------------------------------


-------------PH2:START-------------------------------------------------------------------
   getzencipf pkg_common_dmmb_phst.zencipftype;
-------------PH2:END---------------------------------------------------------------------

  --SIT CHNAGE END---
    checkdupl pkg_common_dmmb_phst.phduplicate;

  -------------PH9: START-------------------------------------------------------------------
    clntdob pkg_common_dmmb_phst.getclntdob;
  -------------PH9: END--------------------------------------------------------------------- 

  TYPE ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  TYPE errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  TYPE errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  TYPE errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  TYPE errorprogram_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;

  --------------------------COMMON FUNCTION END-------------------------------------------------------------------------
  getconpol      PKG_COMMON_DMMB_PHST.conpoltype; --PH16
  obj_getconpol  CONV_POL_HIST%rowtype; --PH16
  v_isconvpol    VARCHAR2(1 CHAR); --PH16
  v_ispolchnaged VARCHAR2(1 CHAR); --PH16
  v_prevpolno    TITDMGPOLTRNH.CHDRNUM@DMSTAGEDBLINK%TYPE; --PH16
  TYPE checkstat IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50); --PH16
  a_checkpolst checkstat; --PH16
  v_splfound   VARCHAR2(1 CHAR); --PH16
  v_onlyspl    VARCHAR2(1 CHAR); --PH16

  ----------------------------------------------------------------------------------------------------------------------
  CURSOR c_polhistcursor IS
    SELECT * FROM IG_TITDMGPOLTRNH 
    ORDER BY LPAD(chdrnum, 8, '0') ASC, LPAD(zseqno, 3, '0') ASC;

  o_polhistobj c_polhistcursor%rowtype;
 BEGIN

 -------PH16:START------------
  DELETE FROM CONV_POL_HIST;
  INSERT INTO CONV_POL_HIST
    select *
      from ((select DISTINCT (chdrnum) as PH_CHDRNUM
               from titdmgpoltrnh@dmstagedblink) PH INNER JOIN
            (select chdrnum as GC_CHDRNUM, ZPRVCHDR
               from gchd
              where TRIM(ZPRVCHDR) is not null) GC on
            PH.PH_CHDRNUM = GC.GC_CHDRNUM)
     order by PH_CHDRNUM asc;
  PKG_COMMON_DMMB_PHST.getconpolinfo(getconpol => getconpol);

  -------PH16:END------------
  --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------

 pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9SC,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMPH',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPH',
                                        o_errortext   => o_errortext);
--  pkg_common_dmmb_phst.checkgchppf(i_company    => i_company,         ---DM REHEARSAL PERFORMANCE----
--                                   checkZendcde => checkZendcde);     ---DM REHEARSAL PERFORMANCE----
  --pkg_common_dmmb_phst.checkzdclpf(checkClient => checkClient); --PH12 commented as not required: discussed with Patrice May16
  pkg_common_dmmb_phst.getclbaforcc(getclbaforcc => getclbaforcc);
  pkg_common_dmmb_phst.getclbaforbnk(getclbaforbnk => getclbaforbnk);
  pkg_common_dmmb_phst.getgchd(getgchd => getgchd);

  --SIT CHNAGE START---
  pkg_common_dmmb_phst.getgchipf(getgchipf => getgchipf);
  pkg_common_dmmb_phst.getgmhipf(getgmhipf => getgmhipf);
  pkg_common_dmmb_phst.getgchppf(getgchppf => getgchppf);
  pkg_common_dmmb_phst.getgmhdpf(getgmhdpf => getgmhdpf);
  --SIT CHNAGE END---

-------------PH3:START---------------------------------------------------------------------

----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START------
   --pkg_common_dmmb_phst.getzclnpf(getzclnpf => getzclnpf);
----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END--------

----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF:  DM_REHEARSAL_PERFORMANCE: START------
   pkg_common_dmmb_phst.getzdchpf(getzdchpf => getzdchpf);
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF:  DM_REHEARSAL_PERFORMANCE: END--------

-------------PH3:END---------------------------------------------------------------------


-------------PH2:START---------------------------------------------------------------------
   pkg_common_dmmb_phst.getzencipf(getzencipf => getzencipf);
-------------PH2:END-----------------------------------------------------------------------

-------------PH9: START-------------------------------------------------------------------  
  pkg_common_dmmb_phst.checkclntdob(clntdob => clntdob);
-------------PH9: END-------------------------------------------------------------------

  pkg_common_dmmb_phst.checkcpdup(checkdupl => checkdupl);

  v_tablenametemp := 'ZDOE' || trim(c_prefix) ||
                     lpad(trim(i_schedulenumber), 4, '0');

  v_tablename := trim(v_tablenametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tablename);

  DELETE FROM Jd1dta.IG_TITDMGPOLTRNH;
  COMMIT;
---- [START] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue
  Select CHDRNUM_FROM, CHDRNUM_TO into v_range_from, v_range_to 
      FROM MB01_POLHIST_RANGE;
---- [END] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue

  insert into Jd1dta.IG_TITDMGPOLTRNH
    SELECT * FROM TITDMGPOLTRNH@DMSTAGEDBLINK
    WHERE CHDRNUM between v_range_from AND v_range_to; -- PH17
    --ORDER BY LPAD(chdrnum, 8, '0') ASC, LPAD(zseqno, 3, '0') ASC; --PH16
  -- where trim(chdrnum) IN ('88656066');
  COMMIT;

  -- SELECT COUNT(*)INTO v_last_rowcnt FROM Jd1dta.IG_TITDMGPOLTRNH;
  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------

  ------------------FETCH ALL DEFAULT VALUES FROM TABLE TQ9Q9, ITEM BQ9TL-----------------------------------------------------
  v_validflag := o_defaultvalues('VALIDFLAG');
  v_zquotind  := o_defaultvalues('ZQUOTIND');
  v_mbrno     := o_defaultvalues('MBRNO');
  v_dpntno    := o_defaultvalues('DPNTNO');
-----------------PH7: START-----------------------------------  
 -- v_clntreln  := o_defaultvalues('CLTRELN'); --SIT change
-----------------PH7: END-------------------------------------  
  --  v_prv_polnum := null;
  --  v_last_tranno :=0;
  /*  ITR4 - PH8 - LOT2 changes -- Start */
 -- v_zpgpfrdt  := o_defaultvalues('ZPGPFRDT');--Itr4 Lot2 Change // Not from default anymore, taking from GCHPPF
 -- v_zpgptodt  := o_defaultvalues('ZPGPTODT');--Itr4 Lot2 Change // Not from default anymore, taking from GCHPPF
  /*  ITR4 - PH8 - LOT2 changes -- Start */
  -----------------------------OPEN CURSOR------------------------------------------------------------------------------------

  OPEN c_polhistcursor;
  <<skiprecord>>
  LOOP
    FETCH c_polhistcursor
      INTO o_polhistobj;
    EXIT WHEN c_polhistcursor%notfound;
    ---------------------------INITIALIZATION START----------------------------------------------------------------------------
    ----------------------------------------------------------
    v_chdrnum     := RTRIM(o_polhistobj.CHDRNUM);
    v_zseqno      := RTRIM(o_polhistobj.ZSEQNO);
    v_effdate     := RTRIM(o_polhistobj.EFFDATE);
    v_zaltregdat  := RTRIM(o_polhistobj.ZALTREGDAT);
    --TICKET- #7544- DM REHEARSAL STARTS-------------------
    --v_zaltrcde01  := RTRIM(o_polhistobj.ZALTRCDE01); 
    v_zaltrcde01  := o_polhistobj.ZALTRCDE01;
    --TICKET- #7544- DM REHEARSAL ENDS---------------------
    v_zinhdsclm   := RTRIM(o_polhistobj.ZINHDSCLM);
    v_zuwrejflg   := RTRIM(o_polhistobj.ZUWREJFLG);
    v_zstopbpj    := RTRIM(o_polhistobj.ZSTOPBPJ);
    v_ztrxstat    := RTRIM(o_polhistobj.ZTRXSTAT);
    v_zstatresn   := RTRIM(o_polhistobj.ZSTATRESN);
    v_zaclsdat    := RTRIM(o_polhistobj.ZACLSDAT);
    v_apprdte     := RTRIM(o_polhistobj.APPRDTE);
    v_zpdatatxdte := RTRIM(o_polhistobj.ZPDATATXDTE);
    v_zpdatatxflg := RTRIM(o_polhistobj.ZPDATATXFLG);
    v_zrefundam   := RTRIM(o_polhistobj.ZREFUNDAM);
    v_zpayinreq   := RTRIM(o_polhistobj.ZPAYINREQ);
    v_crdtcard    := RTRIM(o_polhistobj.CRDTCARD);
    v_preautno    := RTRIM(o_polhistobj.PREAUTNO);
    v_bnkacckey01 := RTRIM(o_polhistobj.BNKACCKEY01);
    v_zenspcd01   := RTRIM(o_polhistobj.ZENSPCD01);
    v_zenspcd02   := RTRIM(o_polhistobj.ZENSPCD02);
    v_zcifcode    := RTRIM(o_polhistobj.ZCIFCODE);

    v_tranno := TO_NUMBER(v_zseqno) + 1;

-------------PH3:START---------------------------------------------------------------------
    v_seqno_cl2 := TO_NUMBER(v_zseqno);
-------------PH3:END---------------------------------------------------------------------
--------------------------PH14-START-------------------------------------------------------
    v_zddreqno  := RTRIM(o_polhistobj.ZDDREQNO);
--------------------------PH14-END-------------------------------------------------------


select temp_seq.nextval into temp_val from dual;
    ---SIT Bug fix
    v_bankaccdsc := null;
    v_bnkactyp   := null;
    v_bankkey    := null;
    v_mthto      := null;
    v_yearto     := null;

    ----REFERENCE KEY FOR POLHIST WILL BE THE COMBINATION OF  CHDRNUM + ?g-?g + ZSEQNO + ?g-?g + EFFDATE FIELDS------
    v_refkey := v_chdrnum || '-' || v_zseqno || '-' || v_effdate;

    v_isanyerror := 'N';
    v_errorcount := 0;
    t_ercode(1) := NULL;
    t_ercode(2) := NULL;
    t_ercode(3) := NULL;
    t_ercode(4) := NULL;
    t_ercode(5) := NULL;

    i_zdoe_info              := NULL;
    i_zdoe_info.i_zfilename  := 'TITDMGPOLTRNH';
    i_zdoe_info.i_prefix     := c_prefix;
    i_zdoe_info.i_scheduleno := i_schedulenumber;
    i_zdoe_info.i_refkey     := v_refkey;
    i_zdoe_info.i_tablename  := v_tablename;
    ---------------------------INITIALIZATION END-------------------------------------------------------------------------------
    ----------------------PH16:START---------------------------------------
    --v_trancde   := 'T912';
    -- v_zquotind1 := 'A';
    v_onlyspl := 'F';
    IF (getconpol.exists(TRIM(v_chdrnum))) THEN
      v_isconvpol := 'T';
    else
      v_isconvpol := 'F';
    END IF;

    IF (a_checkpolst.exists(TRIM(v_chdrnum))) THEN
      v_ispolchnaged := 'F';
    else
      v_ispolchnaged := 'T';
      v_splfound     := 'F';

    END IF;
    a_checkpolst(TRIM(v_chdrnum)) := TRIM(v_chdrnum);

    ----CASE1:  New Business (when ZPRVCHDR is spaces) Transfer Flg N
    IF ((v_isconvpol = 'F') and (TRIM(v_zseqno) = '000') and
       (TRIM(v_zpdatatxflg) != 'Y')) THEN
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
      --  v_trancde     := 'T902';
      --  v_zquotind1   := v_space;
    END IF;

    ----CASE2: New Business Policy - due to alteration ((‘P04’,‘P06’,‘P08’) and Transfer Flg N
    IF ((v_isconvpol = 'T') and
       ((TRIM(v_zaltrcde01) = 'P04') OR (TRIM(v_zaltrcde01) = 'P06') OR
       (TRIM(v_zaltrcde01) = 'P08')) and ((TRIM(v_zpdatatxflg) != 'Y'))) then
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
      --   v_trancde     := 'T902';
      --   v_zquotind1   := v_space;
      v_splfound := 'T';
      v_onlyspl  := 'T';
    END IF;

    IF (v_splfound = 'T') then
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
      --  v_trancde     := 'T912';
      --  v_zquotind1   := 'A';
    END IF;

    ----CASE3:  New Business (when ZPRVCHDR is spaces) Transfer Flg  Y

    ----CASE4:New Business Policy - due to alteration ((‘P04’,‘P06’,‘P08’) and Transfer Flg Y

    ----------------------PH16:END---------------------------------------
    ---------------------------------------FETCH VALUES FROM COMMON FUNCTION-----------------------------------------------

-------------PH2:START-------------------------------------------------------------------    
----------DM REHEARSAL PERFORMANCE: START-----------------------------------------------------
--    IF (checkZendcde.exists(TRIM(v_chdrnum) || TRIM(i_company))) THEN
--      v_zendcde := checkZendcde(TRIM(v_chdrnum) || TRIM(i_company));
--    END IF;

--TICKET- #7540- DM REHEARSAL STARTS-----------------------------
    IF (getgchppf.exists(v_chdrnum)) THEN
      obj_gchp      := getgchppf(v_chdrnum); --PH12
      v_zconvindpol := obj_gchp.zconvindpol;
      v_zendcde := obj_gchp.zendcde;
      v_zplancls := obj_gchp.zplancls; 
   -----------PH5: START-------------------------    
      v_zpgpfrdt    := obj_gchp.zpgpfrdt; 
      v_zpgptodt    := obj_gchp.zpgptodt;
   -----------PH5: END---------------------------
   -----------PH9: START-------------------------    
      v_zpoltdate    := obj_gchp.zpoltdate; 
   -----------PH9: END---------------------------
    END IF;
--TICKET- #7540- DM REHEARSAL ENDS-------------------------------
-------------PH2:END-------------------------------------------------------------------

----------DM REHEARSAL PERFORMANCE: END------------------------------------------------------

    /*IF (checkClient.exists(TRIM(v_chdrnum))) THEN
      v_clientnum := checkClient(TRIM(v_chdrnum));
    END IF;*/

    IF (getgchd.exists(v_chdrnum)) THEN
      obj_gchd    := getgchd(v_chdrnum); --PH12
      v_clientnum := obj_gchd.cownnum; -- PH12 
      v_cownnum   := obj_gchd.cownnum;
      v_statcode  := obj_gchd.statcode;
      v_tranlused := obj_gchd.tranlused;
   -----------PH5: START------------------------- 
      v_btdate    := obj_gchd.btdate; 
   -----------PH5: START-------------------------       
    END IF;

    --    IF (getgchd.exists(v_chdrnum || TRIM(i_company))) THEN
    --          obj_gchd   := getgchd(v_chdrnum || TRIM(i_company));
    --          v_statcode := obj_gchd.statcode;
    --    END IF;

-------------PH2:START-------------------------------------------------------------------
    IF (RTRIM(v_zendcde) IS NOT NULL) THEN
        IF (getzencipf.exists(v_zendcde)) THEN
              obj_zencipf   := getzencipf(v_zendcde);
              v_zbnkflag := obj_zencipf.ZBNKFLAG;
              v_zccflag  := obj_zencipf.ZCCFLAG;
        END IF;
    END IF;

--    IF (RTRIM(v_zendcde) IS NOT NULL) THEN
--      SELECT ZBNKFLAG, ZCCFLAG
--        INTO v_zbnkflag, v_zccflag
--        FROM ZENCIPF
--       where RTRIM(ZENDCDE) = RTRIM(v_zendcde);
--    END IF;
-------------PH2:END---------------------------------------------------------------------

    --SIT CHNAGE START---
    IF (getgchipf.exists(v_chdrnum)) THEN
      obj_gchi    := getgchipf(v_chdrnum); --PH12
      v_zcmpcode  := obj_gchi.zcmpcode;
      v_zsolctflg := obj_gchi.zsolctflg;
      v_ccdate    := obj_gchi.ccdate;
    END IF;

    IF (getgmhipf.exists(v_chdrnum)) THEN
      obj_gmhi := getgmhipf(v_chdrnum); --PH12

      v_zcpnscde   := obj_gmhi.zcpnscde;
      v_zplancde   := obj_gmhi.zplancde;
      v_dcldate    := obj_gmhi.dcldate;
      v_zdclitem01 := obj_gmhi.zdclitem01;
      v_zdclitem02 := obj_gmhi.zdclitem02;
      v_zdeclcat   := obj_gmhi.zdeclcat;
   -----------PH4: START------------------------- 
      v_zdfcncy    := obj_gmhi.zdfcncy;
      v_zmargnflg  := obj_gmhi.zmargnflg;
   -----------PH4: START------------------------- 

    END IF;

--THIS PIECE OF CODE IS MOVED UP INSIDE DM REHEARSAL CODE----
--    IF (getgchppf.exists(v_chdrnum || TRIM(i_company))) THEN
--      obj_gchp      := getgchppf(v_chdrnum || TRIM(i_company));
--      v_zconvindpol := obj_gchp.zconvindpol;
--    END IF;

    IF (getgmhdpf.exists(v_chdrnum)) THEN
      obj_gmhd    := getgmhdpf(v_chdrnum); --PH12
      v_zsalechnl := obj_gmhd.zsalechnl;
      v_cltreln   := obj_gmhd.cltreln;---PH7: New Column Added "CLTRELN"
    END IF;

    --SIT CHNAGE END---   

    -----------------------------------------------------------------------------------------------------------------------
    --[START] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGPOLTRNH---------------------------------------------------------
    ------VALIDATION - CHDRNUM "Policy Number must be already migrated". -------------------------------------------

    IF NOT (getgchd.exists(TRIM(v_chdrnum))) THEN --PH12
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := c_Z101;
      t_errorfield(v_errorCount) := 'CHDRNUM';
      t_errormsg(v_errorCount) := o_errortext(c_Z101);
      t_errorfieldval(v_errorCount) := v_chdrnum;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ------VALIDATION -CHDRNUM +TRANNO + ZALTREGDAT "Check duplicate record." ----------------------------------------------------------
   /* SELECT COUNT(RECIDXPOLTRNH)
      INTO v_isduplicate
      FROM Jd1dta.ZDPTPF
     WHERE RTRIM(zentity) = v_refkey;

    IF v_isduplicate > 0 THEN*/
    IF (checkdupl.exists(TRIM(v_refkey))) THEN
      v_isanyerror                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := c_Z099;
      i_zdoe_info.i_errormsg01     := o_errortext(c_Z099);
      i_zdoe_info.i_errorfield01   := 'REFKEY';
      i_zdoe_info.i_fieldvalue01   := v_refkey;
      i_zdoe_info.i_errorprogram01 := i_schedulename;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skiprecord;
    END IF;
    ------VALIDATION - EFFDATE "Must be a valid date and in correct format YYYYMMDD"----------------------------------------------------------
    v_isdatevalid := validate_date(v_effdate);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z013;
      t_errorfield(v_errorcount) := 'EFFDATE';
      t_errormsg(v_errorcount) := o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_effdate;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZALTREGDAT "Must be a valid date and in correct format YYYYMMDD"----------------------------------------------------------
    v_isdatevalid := validate_date(v_zaltregdat);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z013;
      t_errorfield(v_errorcount) := 'ZALTREGDAT';
      t_errormsg(v_errorcount) := o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zaltregdat;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ------VALIDATION - ZALTRCDE01 "Must be in TQ9MP"----------------------------------------------------------

    /*IF (v_zaltrcde01 IS NULL) THEN
        IF (TO_NUMBER(v_zseqno) <> 0) THEN
          v_isanyerror := 'Y';
          v_errorcount := v_errorcount + 1;
          t_ercode(v_errorcount) := c_Z104;
          t_errorfield(v_errorcount) := 'ZALTRCDE01';
          t_errormsg(v_errorcount) := o_errortext(c_Z104);
          t_errorfieldval(v_errorcount) := v_zaltrcde01;
          t_errorprogram(v_errorcount) := i_schedulename;
         IF v_errorcount >= c_errorcount THEN
            GOTO insertzdoe;
         END IF;
         END IF;
    ELSE  */
    ---01/03/2018 Chage suggested by abhishek done by birla

-------------PH2:START-------------------------------------------------------------------
--TICKET- #7544 DM REHEARSAL START----------------------------------------------------------------

--    IF (v_zaltrcde01 IS NOT NULL) THEN
--      IF NOT
--          (itemexist.EXISTS(trim('TQ9MP') || trim(v_zaltrcde01) || i_company)) THEN
--        v_isanyerror := 'Y';
--        v_errorcount := v_errorcount + 1;
--        t_ercode(v_errorcount) := c_Z104;
--        t_errorfield(v_errorcount) := 'ZALTRCDE01';
--        t_errormsg(v_errorcount) := o_errortext(c_Z104);
--        t_errorfieldval(v_errorcount) := v_zaltrcde01;
--        t_errorprogram(v_errorcount) := i_schedulename;
--        IF v_errorcount >= c_errorcount THEN
--          GOTO insertzdoe;
--        END IF;
--      END IF;
--    END IF;

    IF (TRIM(v_zaltrcde01) IS NOT NULL) THEN
      IF NOT
          (itemexist.EXISTS(trim('TQ9MP') || trim(v_zaltrcde01) || i_company)) THEN
        v_isanyerror := 'Y';
        v_errorcount := v_errorcount + 1;
        t_ercode(v_errorcount) := c_Z104;
        t_errorfield(v_errorcount) := 'ZALTRCDE01';
        t_errormsg(v_errorcount) := o_errortext(c_Z104);
        t_errorfieldval(v_errorcount) := v_zaltrcde01;
        t_errorprogram(v_errorcount) := i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

--TICKET- #7544 DM REHEARSAL END--------------------------------------------------------------- 
-------------PH2:END-------------------------------------------------------------------

    ------VALIDATION - ZTRXSTAT "Must be in TQ9FT"----------------------------------------------------------
    IF NOT
        (itemexist.EXISTS(trim('TQ9FT') || trim(v_ztrxstat) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z007;
      t_errorfield(v_errorcount) := 'ZTRXSTAT';
      t_errormsg(v_errorcount) := o_errortext(c_Z007);
      t_errorfieldval(v_errorcount) := v_ztrxstat;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZSTATRESN "Must be in TQ9FU"----------------------------------------------------------

    IF (v_zstatresn IS NOT NULL) THEN
      IF NOT
          (itemexist.EXISTS(trim('TQ9FU') || trim(v_zstatresn) || i_company)) THEN
        v_isanyerror := 'Y';
        v_errorcount := v_errorcount + 1;
        t_ercode(v_errorcount) := c_Z008;
        t_errorfield(v_errorcount) := 'ZSTATRESN';
        t_errormsg(v_errorcount) := o_errortext(c_Z008);
        t_errorfieldval(v_errorcount) := v_zstatresn;
        t_errorprogram(v_errorcount) := i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
    ------VALIDATION - CRDTCARD "At least one of the 3 fields (Credit Card No, Bank Account No and Endorser Specific Code) is mandatory."-----
    --COMBINING ALL THREE VALIDATION RATHER THAN CHECKING INDIVIDUALLY---
    --VALIDATION - CRDTCARD + VALIDATION - BNKACCKEY01 + VALIDATION - ZENSPCD01----------
    IF (TRIM(v_zplancls) <> 'FP') THEN  
    IF ((v_crdtcard IS NULL) AND (v_bnkacckey01 IS NULL) AND
       (v_zenspcd01 IS NULL)) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := c_Z011;
      t_errorfield(v_errorCount) := 'CRDTCARD';
      t_errormsg(v_errorCount) := o_errortext(c_Z011);
      t_errorfieldval(v_errorCount) := v_crdtcard;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;

    END IF;
    END IF;

-------------PH2:START-------------------------------------------------------------------    
-----------------TICKET- #7540- DM REHEARSAL STARTS-----------------------------   
------VALIDATION - ZENDCDE & CRDTCARD "Check if Credit Card is Mandatory as per Endorser"----------------------------------
IF (TRIM(v_zplancls) <> 'FP') THEN  --FOR FREE PLAN DO NOT PERFORM VALIDATION
    IF (RTRIM(v_zccflag) IS NOT NULL) THEN
      IF (RTRIM(v_zccflag) = 'Y' AND v_crdtcard IS NULL) THEN
        v_isAnyError := 'Y';
        v_errorCount := v_errorCount + 1;
        t_ercode(v_errorCount) := c_Z075;
        t_errorfield(v_errorCount) := 'CRDTCARD';
        t_errormsg(v_errorCount) := o_errortext(c_Z075);
        t_errorfieldval(v_errorCount) := v_crdtcard;
        t_errorprogram(v_errorCount) := i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
END IF;
----------------TICKET- #7540- DM REHEARSAL ENDS-----------------------------
-------------PH2:END-------------------------------------------------------------------

    ------VALIDATION - CRDTCARD "If Credit card is not blank, it must be already present in Client bank database (CLBAPF)."----
    IF (v_crdtcard IS NOT NULL) THEN

      IF NOT
          (getclbaforcc.EXISTS(v_crdtcard || v_clientnum)) --PH12

       THEN
        v_isAnyError := 'Y';
        v_errorCount := v_errorCount + 1;
        t_ercode(v_errorCount) := c_RFTQ;
        t_errorfield(v_errorCount) := 'CRDTCARD';
        t_errormsg(v_errorCount) := o_errortext(c_RFTQ);
        t_errorfieldval(v_errorCount) := v_crdtcard;
        t_errorprogram(v_errorCount) := i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      -- END IF;
    END IF;
    ------- PH 18 START -----------
    ------VALIDATION - PREAUTNO "CRDTCARD (Credit card) is not blank, but PREAUTNO (Card Approval No.) is blank"---------------
    --IF ((v_crdtcard IS NOT NULL) AND (v_preautno IS NULL)) THEN
    --  v_isAnyError := 'Y';
    --  v_errorCount := v_errorCount + 1;
    --  t_ercode(v_errorCount) := c_Z076;
    --  t_errorfield(v_errorCount) := 'PREAUTNO';
    --  t_errormsg(v_errorCount) := o_errortext(c_Z076);
    --  t_errorfieldval(v_errorCount) := v_preautno;
    --  t_errorprogram(v_errorCount) := i_scheduleName;
    --  IF v_errorCount >= C_ERRORCOUNT THEN
    --    GOTO insertzdoe;
    --  END IF;
    --END IF;
    ------- PH 18 END -----------
-------------PH2:START-------------------------------------------------------------------    
--------------------TICKET- #7540- DM REHEARSAL STARTS----------------------------- 
------VALIDATION - ZENDCDE & BNKACCKEY01 "Check if Bank Account No is Mandatory as per Endorser"---------------
IF (TRIM(v_zplancls) <> 'FP') THEN  --FOR FREE PLAN DO NOT PERFORM VALIDATION
    IF (RTRIM(v_zbnkflag) IS NOT NULL) THEN
      IF (RTRIM(v_zbnkflag) = 'Y' AND v_bnkacckey01 IS NULL) THEN
        v_isAnyError := 'Y';
        v_errorCount := v_errorCount + 1;
        t_ercode(v_errorCount) := c_Z077;
        t_errorfield(v_errorCount) := 'BNKACCKEY1'; -- changed "BNKACCKEY01"  to "BNKACCKEY1" as max field length is 10.
        t_errormsg(v_errorCount) := o_errortext(c_Z077);
        t_errorfieldval(v_errorCount) := v_bnkacckey01;
        t_errorprogram(v_errorCount) := i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
  END IF;  
-------------------------TICKET- #7540- DM REHEARSAL ENDS-----------------------------    
-------------PH2:END-------------------------------------------------------------------

    ------VALIDATION - BNKACCKEY01 "If Bank Account No is not blank, it must be already present in Client bank database (CLBAPF)."---
    IF (v_bnkacckey01 IS NOT NULL) THEN

      IF NOT
          (getclbaforbnk.EXISTS(v_bnkacckey01 || v_clientnum)) THEN --PH12
        v_isAnyError := 'Y';
        v_errorCount := v_errorCount + 1;
        t_ercode(v_errorCount) := c_F826;
        t_errorfield(v_errorCount) := 'BNKACCKEY1'; -- changed "BNKACCKEY01"  to "BNKACCKEY1" as max field length is 10.
        t_errormsg(v_errorCount) := o_errortext(c_F826);
        t_errorfieldval(v_errorCount) := v_bnkacckey01;
        t_errorprogram(v_errorCount) := i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
    --END IF;
    ------VALIDATION - ZACLSDAT "Must be a valid date and in correct format YYYYMMDD"-----------------------------
    v_isdatevalid := validate_date(v_zaclsdat);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z013;
      t_errorfield(v_errorcount) := 'ZACLSDAT';
      t_errormsg(v_errorcount) := o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zaclsdat;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ------VALIDATION - APPRDTE "Must be a valid date and in correct format YYYYMMDD"-----------------------------
    v_isdatevalid := validate_date(v_apprdte);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z013;
      t_errorfield(v_errorcount) := 'APPRDTE';
      t_errormsg(v_errorcount) := o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_apprdte;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ------VALIDATION - ZPDATATXDTE "Must be a valid date and in correct format YYYYMMDD"-----------------------------

    v_isdatevalid := validate_date(v_zpdatatxdte);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_Z013;
      t_errorfield(v_errorcount) := 'ZPDATATXDT'; -- changed "ZPDATATXDTE"  to "ZPDATATXDT" as max field length is 10.
      t_errormsg(v_errorcount) := o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zpdatatxdte;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ----[END] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGPOLTRNH---------------------------------------------------------

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF--------------------------------------------------------

    <<insertzdoe>>
    IF (v_isanyerror = 'Y') THEN
      IF TRIM(t_ercode(1)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := t_ercode(1);
        i_zdoe_info.i_errormsg01     := t_errormsg(1);
        i_zdoe_info.i_errorfield01   := t_errorfield(1);
        i_zdoe_info.i_fieldvalue01   := t_errorfieldval(1);
        i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
      END IF;

      IF TRIM(t_ercode(2)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error02        := t_ercode(2);
        i_zdoe_info.i_errormsg02     := t_errormsg(2);
        i_zdoe_info.i_errorfield02   := t_errorfield(2);
        i_zdoe_info.i_fieldvalue02   := t_errorfieldval(2);
        i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
      END IF;

      IF TRIM(t_ercode(3)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error03        := t_ercode(3);
        i_zdoe_info.i_errormsg03     := t_errormsg(3);
        i_zdoe_info.i_errorfield03   := t_errorfield(3);
        i_zdoe_info.i_fieldvalue03   := t_errorfieldval(3);
        i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
      END IF;

      IF TRIM(t_ercode(4)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error04        := t_ercode(4);
        i_zdoe_info.i_errormsg04     := t_errormsg(4);
        i_zdoe_info.i_errorfield04   := t_errorfield(4);
        i_zdoe_info.i_fieldvalue04   := t_errorfieldval(4);
        i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
      END IF;

      IF TRIM(t_ercode(5)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error05        := t_ercode(5);
        i_zdoe_info.i_errormsg05     := t_errormsg(5);
        i_zdoe_info.i_errorfield05   := t_errorfield(5);
        i_zdoe_info.i_fieldvalue05   := t_errorfieldval(5);
        i_zdoe_info.i_errorprogram05 := t_errorprogram(5);
      END IF;

      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skiprecord;
    END IF;

    -- If there is no Error Insert success record in ZDOE

    IF (v_isanyerror = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF---------------------------------------------------------

    --------IF PRE-VALIDATION IS NO - INSERT INTO "ZDPTPF" REGISTRY TABLE--------------------------------------------------------

    IF i_zprvaldyn = 'N' AND v_isanyerror = 'N' THEN
      -- insert into Registry table

      INSERT INTO Jd1dta.ZDPTPF
        (zentity, --CHDRNUM + ?g-?g + ZSEQNO + ?g-?g + EFFDATE
         zigValue, --ZTRAPF.CHDRNUM + ?g-?g + ZTRAPF.TRANNO + ?g-?g + ZTRAPF.EFFDATE---HERE TRANNO WILL BE SEQNO+1
         jobNum,
         jobName)
      VALUES
        (v_refkey,
         v_chdrnum || '-' || v_tranno || '-' || v_effdate,
         i_schedulenumber,
         i_schedulename);

      ---------------------- INSERT ZTRAPF START--------------------------------------------------------------------------------------------------
      -- SET DEFAULT VALUES IN OBJECT FOR ZTRAPF
      --IF (TRIM(v_zseqno) = '000') THEN
        IF (TRIM(v_zseqno) = '000' or v_onlyspl = 'T') THEN     ---PH16
        obj_ztrapf.ZQUOTIND := v_space;
        obj_ztrapf.TRANCDE := 'T902';     -- PH4
      ELSE
        obj_ztrapf.ZQUOTIND := 'A';
        obj_ztrapf.TRANCDE := 'T912';     -- PH4
      END IF;

      obj_ztrapf.MBRNO  := v_mbrno;
      -- obj_ztrapf.DPNTNO := v_dpntno; -- PH11
      obj_ztrapf.DPNTNO := '00';    -- RH11

      -- SET OTHER VALUES IN OBJECT FOR ZTRAPF
      obj_ztrapf.CHDRCOY    := i_company;
      obj_ztrapf.CHDRNUM    := v_chdrnum;
      obj_ztrapf.TRANNO     := v_tranno;
      obj_ztrapf.EFFDATE    := v_effdate;
      obj_ztrapf.ZALTREGDAT := v_zaltregdat;
      obj_ztrapf.ZALTRCDE01 := v_zaltrcde01;
      obj_ztrapf.ZALTRCDE02 := v_space;
      obj_ztrapf.ZALTRCDE03 := v_space;
      obj_ztrapf.ZALTRCDE04 := v_space;
      obj_ztrapf.ZALTRCDE05 := v_space;
-----------------------------PH5: START----------
      --obj_ztrapf.ZCLMRECD   := v_zero;
      obj_ztrapf.ZCLMRECD   := v_maxdate;
-----------------------------PH5: END------------
    --obj_ztrapf.ZCLMRECD   := v_zero;
      obj_ztrapf.ZINHDSCLM  := v_zinhdsclm;
    --obj_ztrapf.ZFINALBYM  := v_zero; ---PH9-------
      obj_ztrapf.ZUWREJFLG  := v_zuwrejflg;
      obj_ztrapf.ZVIOLTYP   := v_space;
      obj_ztrapf.ZSTOPBPJ   := v_zstopbpj;
-----------------------------PH5: START-----------
--      obj_ztrapf.ZDFCNCY    := v_space;
--      obj_ztrapf.ZMARGNFLG  := v_space;
-----------------------------PH5: END------------
      ---SIT Bug fix
-----------------------------PH5: START-----------

      IF (v_tranno = v_tranlused) THEN      
        obj_ztrapf.ZLOGALTDT  :=v_btdate;--GET IT FROM GCHD
        obj_ztrapf.ZDFCNCY    :=v_zdfcncy;--GET IT FROM GMHIPF
        obj_ztrapf.ZMARGNFLG  :=v_zmargnflg;--GET IT FROM GMHIPF
       ELSE 
        obj_ztrapf.ZLOGALTDT  :=0;
        obj_ztrapf.ZDFCNCY    :='N';
        obj_ztrapf.ZMARGNFLG  :='N';       
      END IF;
-----------------------------PH5: END-----------------


      IF (getgmhipf.exists(v_chdrnum)) THEN
        obj_gmhi            := getgmhipf(v_chdrnum); --PH12
        obj_ztrapf.DOCRCDTE := obj_gmhi.docrcdte;
        obj_ztrapf.HPROPDTE := obj_gmhi.hpropdte;
      END IF;

      obj_ztrapf.ZTRXSTAT  := v_ztrxstat;
      obj_ztrapf.ZSTATRESN := v_zstatresn;
      obj_ztrapf.ZACLSDAT  := v_zaclsdat;
      obj_ztrapf.APPRDTE   := v_apprdte;

      --      IF (getgchd.exists(v_chdrnum || TRIM(i_company))) THEN
      --        obj_gchd  := getgchd(v_chdrnum || TRIM(i_company));
      --        v_cownnum := obj_gchd.cownnum;
      --      END IF;


      -- BEGIN

----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START------
--      select UNIQUE_NUMBER
--        into v_unique_number01
--        from zclnpf
--       where TRIM(CLNTPFX) = TRIM('CN')
--         and TRIM(CLNTCOY) = TRIM('9')
--         and TRIM(CLNTNUM) = TRIM(v_cownnum)
--         and TRIM(EFFDATE) <= TRIM(v_effdate)
--         and rownum = '1'
--       order by EFFDATE desc, UNIQUE_NUMBER desc;
----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END--------

      ---- EXCEPTION
      --   WHEN NO_DATA_FOUND THEN
      --     v_unique_number01 := 0;
      --  END;

-------------------------PH3:START-------------------------------------------------------------------

-------------PH2:START-------------------------------------------------------------------
----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START------      
--    IF (getzclnpf.exists(v_cownnum || TRIM(i_fsucompany) || TRIM(v_effdate))) THEN  
--      obj_zclnpf    := getzclnpf(v_cownnum || TRIM(i_fsucompany) || TRIM(v_effdate));
--      v_unique_number01 := obj_zclnpf.UNIQUE_NUMBER;
--      v_temp_cownum:=trim(v_cownnum);
--      v_temp_effdate:=trim(v_effdate);
--    ELSE
--     obj_zclnpf    := getzclnpf(v_temp_cownum || TRIM(i_fsucompany) || TRIM(v_temp_effdate));
--     v_unique_number01 := obj_zclnpf.UNIQUE_NUMBER;
--    END IF;
----Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END--------
-------------PH2:END-------------------------------------------------------------------

----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: START------      
    IF (getzdchpf.exists(TRIM(v_cownnum) || TRIM(v_seqno_cl2) || TRIM(v_effdate))) THEN  
      obj_zdchpf         := getzdchpf(TRIM(v_cownnum) || TRIM(v_seqno_cl2) || TRIM(v_effdate));
      v_unique_number01  := obj_zdchpf.RECIDXCLNTHIS;
      v_temp_cownum      := trim(v_cownnum);
      v_temp_effdate     := trim(v_effdate);
      v_temp_seqno_cl2   := trim(v_seqno_cl2);
    ELSE
      obj_zdchpf         := getzdchpf(TRIM(v_temp_cownum) || TRIM(v_temp_seqno_cl2) || TRIM(v_temp_effdate));
      v_unique_number01  := obj_zdchpf.RECIDXCLNTHIS;
    END IF;
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: END--------

--------------------------PH3:END-------------------------------------------------------------------

      obj_ztrapf.UNIQUE_NUMBER_01 := v_unique_number01;

      obj_ztrapf.UNIQUE_NUMBER_02 := v_unique_number01;

      obj_ztrapf.ALTQUOTENO  := v_space;
      obj_ztrapf.ZPDATATXDAT := v_zpdatatxdte;
      obj_ztrapf.ZPDATATXFLG := v_zpdatatxflg;
      obj_ztrapf.ZREFUNDAM   := v_zrefundam;
      obj_ztrapf.ZSURCHRGE   := v_zero;
      obj_ztrapf.ZSALPLNCHG  := v_space;
      obj_ztrapf.ZORIGSALP   := v_space;
      obj_ztrapf.ZPAYINREQ   := v_zpayinreq;
      obj_ztrapf.USRPRF      := i_userprofile;
      obj_ztrapf.JOBNM       := i_schedulename;
      obj_ztrapf.DATIME      := CAST(sysdate AS TIMESTAMP);

      v_daytempccdate  := substr(v_ccdate, 7, 8);
      v_daytempeffdate := substr(v_effdate, 7, 8);

      IF (v_daytempccdate = v_daytempeffdate) THEN
        obj_ztrapf.EFDATE := v_effdate;
      ELSE
        --dbms_output.put_line('v_effdate = ' || v_effdate);
        --  dbms_output.put_line('v_chdrnum = ' || v_chdrnum);
        v_efdatetemp      := DATCONOPERATION('MONTH', v_effdate);
        v_yearmonthtemp   := substr(v_efdatetemp, 1, 6);
        v_efdatefinal     := v_yearmonthtemp || v_daytempccdate;
        obj_ztrapf.EFDATE := v_efdatefinal;
      END IF;
------------- PH15: START---------------
IF TRIM(v_zpdatatxflg) = 'N' AND v_btdate <> '99999999' THEN
SELECT to_number(TO_CHAR(to_date(v_btdate, 'yyyymmdd') + 1,
                               'yyyymmdd'))
        INTO v_newefdate
        FROM dual;
obj_ztrapf.EFDATE := v_newefdate;
END IF;
------------- PH15: END---------------

-----------------------------PH5: START-------------------

      IF (v_tranno = v_tranlused) THEN

        obj_zaltpf.ZPGPFRDT    :=v_zpgpfrdt;--GET IT FROM GCHPPF
        obj_zaltpf.ZPGPTODT    :=v_zpgptodt;--GET IT FROM GCHPPF
       ELSE 
        obj_zaltpf.ZPGPFRDT    :=v_maxdate;
        obj_zaltpf.ZPGPTODT    :=v_maxdate;

      END IF;

-----------------------------PH5: END---------------------
----------------PH9: START------------------------------------------------
-------------CHANGE FOR ZTRAPF COLUMN "ZPOLDATE"----------------
     IF (v_tranno = 1) THEN
        obj_ztrapf.ZPOLDATE    :=NULL;
     ELSE
          IF ((v_zpoltdate <> 0) AND (v_zpoltdate IS NOT NULL) ) THEN
          obj_ztrapf.ZPOLDATE   := v_zpoltdate;
          ELSE
          obj_ztrapf.ZPOLDATE   := v_maxdate;
          END IF;
     END IF;

------------CHANGE FOR ZTRAPF COLUMN "ZFINALBYM"--------------------------
    obj_ztrapf.ZFINALBYM   := v_zero;--still need confirmation
    obj_ztrapf.ZRVTRANNO   := v_zero;

------------CHANGE FOR ZTRAPF COLUMN "AGE"--------------------------   

    IF (clntdob.exists(TRIM(v_clientnum))) THEN
         v_cltdob    := clntdob(TRIM(v_clientnum));
    END IF;

    IF((TRIM(v_cltdob) IS NOT NULL) AND (TRIM(v_cltdob) <> 0) AND (TRIM(v_cltdob) <> 99999999)) THEN
         v_startdateMM := SUBSTR(TRIM(v_cltdob), 5, 8);
         v_enddateMM   := SUBSTR(TRIM(v_effdate), 5, 8);
         v_startdateYY := SUBSTR(TRIM(v_cltdob), 1, 4);
         v_enddateYY   := SUBSTR(TRIM(v_effdate), 1, 4);

      IF(v_startdateMM <= v_enddateMM)  THEN
         v_age         := (v_enddateYY) - (v_startdateYY) ;
         obj_ztrapf.AGE   := v_age;
      END IF; 

      IF(v_startdateMM > v_enddateMM) THEN
         v_age         := (v_enddateYY - v_startdateYY) - 1 ;
         obj_ztrapf.AGE   := v_age;
      END IF;

    ELSE
         obj_ztrapf.AGE   := v_zero;
    END IF;

----------------PH9: END-------------------------------------------------- 
--------- PH10 Start -------------
--- Set STATCODE = STATCODE in GCHD | For future dates cancellation, STATCODE = "CA"
    obj_ztrapf.STATCODE := v_statcode;
    IF ((v_zpoltdate <> 0) AND (v_zpoltdate IS NOT NULL) AND (v_zpoltdate = v_maxdate)) AND v_statcode = 'IF' THEN
       obj_ztrapf.STATCODE := 'CA';
    END IF;
 
  --IF TRIM(obj_ztrapf.TRANCDE) = 'T902' THEN
  --  obj_ztrapf.STATCODE := 'XN';
  --ELSE
  --  obj_ztrapf.STATCODE := v_statcode;
  --END IF;
--------- PH10 End ---------------
 
 IF SUBSTR(OBJ_ZTRAPF.ZALTRCDE01,1,1) = 'T' THEN
    OBJ_ZTRAPF.ZCSTPBIL := 'Y';
 END IF;
 
      -- INSERT INTO IG TARGET TABLE ZTRAPF
      INSERT INTO Jd1dta.VIEW_DM_ZTRAPF VALUES obj_ztrapf;

      ---------------------- INSERT ZTRAPF END--------------------------------------------------------------------------------------------------
      ---------------------- INSERT ZMCIPF START-------------------------------------------------------------------------------------------------
      -- IF v_zaltrcde01 = 'M04' OR v_zaltrcde01 = 'M01' THEN

      IF ((TRIM(v_zaltrcde01) = 'M04') OR (TRIM(v_zaltrcde01) = 'M01') OR (TRIM(v_zaltrcde01) = 'M02') OR
         ((TRIM(v_zseqno) = '000') and ((TRIM(v_zenspcd01) IS NOT NULL) OR
         (TRIM(v_zenspcd02) IS NOT NULL) OR
         (TRIM(v_crdtcard) IS NOT NULL) OR
     --  (TRIM(v_bnkacckey01) IS NOT NULL)))) THEN -- PH14: line commented --
         (TRIM(v_bnkacckey01) IS NOT NULL) OR      -- PH14: new line --------
         (TRIM(v_zddreqno) IS NOT NULL)))) THEN    -- PH14: new line --------
        /*    dbms_output.put_line('v_zaltrcde01 = ' || v_zaltrcde01 ||
        'v_zseqno=' || v_zseqno || 'v_zenspcd01 =' ||
        v_zenspcd01 || 'v_zenspcd02=' || v_zenspcd02 ||
        'v_crdtcard=' || v_crdtcard ||
        'v_bnkacckey01= ' || v_bnkacckey01);*/
        -- SET VALUES IN OBJECT FOR ZMCIPF--
        obj_zmcipf.CHDRNUM := v_chdrnum;

        --        IF (getgchd.exists(v_chdrnum || TRIM(i_company))) THEN
        --          obj_gchd   := getgchd(v_chdrnum || TRIM(i_company));
        --          v_statcode := obj_gchd.statcode;
        --        
        --        END IF;

        /* IF (RTRIM(v_statcode) = 'IF') THEN
          obj_zmcipf.TRANNO := 1;
        END IF;
        IF (RTRIM(v_statcode) = 'CA') THEN
          obj_zmcipf.TRANNO := 2;
        END IF;*/
        obj_zmcipf.TRANNO := v_tranno;

        obj_zmcipf.ZENDCDE := v_zendcde;

        obj_zmcipf.ZENSPCD01 := v_zenspcd01;

        obj_zmcipf.ZENSPCD02 := v_zenspcd02;

        obj_zmcipf.ZCIFCODE := v_zcifcode;

        obj_zmcipf.CRDTCARD     := v_crdtcard;
        obj_zmcipf.BANKACCKEY01 := v_bnkacckey01;

        IF (v_bnkacckey01 IS NOT NULL) THEN
          IF (getclbaforbnk.exists(v_bnkacckey01 || TRIM(v_clientnum))) THEN --PH12
            obj_clbapf_bn   := getclbaforbnk(v_bnkacckey01 || TRIM(v_clientnum)); --PH12
            v_bankaccdsc := obj_clbapf_bn.bankaccdsc;
            v_bnkactyp   := obj_clbapf_bn.bnkactyp;
            v_bankkey    := obj_clbapf_bn.bankkey;
          END IF;
        END IF;
        -- PH4 START --
        IF (v_crdtcard IS NOT NULL) THEN
          IF (getclbaforbnk.exists(v_crdtcard || TRIM(v_clientnum))) THEN  --PH12
            obj_clbapf_bn   := getclbaforbnk(v_crdtcard || TRIM(v_clientnum));  --PH12
            v_bankaccdsc := obj_clbapf_bn.bankaccdsc;
            v_bnkactyp   := obj_clbapf_bn.bnkactyp;
            v_bankkey    := obj_clbapf_bn.bankkey;
          END IF;
        END IF;   
        -- PH4 END --
        obj_zmcipf.BANKACCDSC01 := v_bankaccdsc;
        obj_zmcipf.BNKACTYP01   := v_bnkactyp;
        obj_zmcipf.BANKKEY      := v_bankkey;

        obj_zmcipf.BANKACCKEY02 := v_space;

        obj_zmcipf.BANKACCDSC02 := v_space;
        obj_zmcipf.BNKACTYP02   := v_space;
        obj_zmcipf.ZPBCTYPE     := v_space;
        obj_zmcipf.ZPBCODE      := v_space;
        obj_zmcipf.PREAUTNO     := v_preautno;

        IF (v_crdtcard IS NOT NULL) THEN
          IF (getclbaforcc.exists(v_crdtcard || TRIM(v_clientnum))) THEN --PH12
            obj_clbapf_cc := getclbaforcc(v_crdtcard || TRIM(v_clientnum));  --PH12
            v_mthto    := obj_clbapf_cc.mthto;
            v_yearto   := obj_clbapf_cc.yearto;
          END IF;
        END IF;

        obj_zmcipf.MTHTO  := v_mthto;
        obj_zmcipf.YEARTO := v_yearto;

        obj_zmcipf.DATIME := CAST(sysdate AS TIMESTAMP);
        obj_zmcipf.JOBNM  := i_schedulename;
        IF (TRIM(v_crdtcard) IS NOT NULL) THEN
          BEGIN

            IF (v_chdrnum IS NOT NULL) THEN

              IF (getgchd.exists(v_chdrnum)) THEN  --PH12
                obj_gchd := getgchd(v_chdrnum);  --PH12
                v_mplnum := obj_gchd.mplnum;

              END IF;
            END IF;

            v_temp_crdtcard := v_crdtcard;
            IF (TRIM(v_mplnum) IS NOT NULL) THEN
---------------------------------PH6: START-------------
--              IF LENGTH(TRIM(v_crdtcard)) > 6 THEN
--                v_temp_crdtcard := SUBSTR(v_crdtcard, 0, 6);
--              END IF;
---------------------------------PH6: END---------------

              /*   i_text := 'v_crdtcard' || v_crdtcard || 'v_chdrnum:' ||
                        v_chdrnum || 'v_mplnum:' || v_mplnum ||
                        'v_temp_crdtcard:' || v_temp_crdtcard;
              dmlog_info(i_lkey => 'CAMP_CODE 1', i_ltext => i_text);*/
              dbms_output.put_line('v_mplnum:' || v_mplnum || 'ZCNBRFRM:' || v_temp_crdtcard || 'length(v_temp_crdtcard):' || length(v_temp_crdtcard));
             
                       
              SELECT ZCRDTYPE
                into v_zcrdtype
                FROM ZENCTPF
               WHERE TRIM(ZPOLNMBR) = TRIM(v_mplnum)
                 and ((TRIM(TO_NUMBER(ZCNBRFRM)) < TRIM(v_temp_crdtcard) and
                      TRIM(TO_NUMBER(ZCNBRTO)) > TRIM(v_temp_crdtcard)) OR
                      TRIM(TO_NUMBER(ZCNBRFRM)) = TRIM(v_temp_crdtcard) and
                      TRIM(TO_NUMBER(ZCNBRTO)) = TRIM(v_temp_crdtcard)) AND 
                      TO_NUMBER(ZCARDDC) = length(v_temp_crdtcard); -- PH13 

            ELSE

---------------------------------PH6: START------------------------------
--              IF LENGTH(TRIM(v_crdtcard)) > 6 THEN
--                v_temp_crdtcard := SUBSTR(v_crdtcard, 0, 6);
--              END IF;
---------------------------------PH6: END-------------------------------
              /* i_text := 'v_crdtcard' || v_crdtcard || 'v_chdrnum:' ||
                        v_chdrnum || 'v_mplnum:' || v_zendcde ||
                        'v_temp_crdtcard:' || v_temp_crdtcard;
              dmlog_info(i_lkey => 'v_zendcde', i_ltext => i_text);*/

              SELECT ZCRDTYPE
                into v_zcrdtype
                FROM ZENCTPF
               WHERE TRIM(ZENDCDE) = TRIM(v_zendcde) --get the value of this zendcode from map
                 and ((TRIM(TO_NUMBER(ZCNBRFRM)) < TRIM(v_temp_crdtcard) and
                      TRIM(TO_NUMBER(ZCNBRTO)) > TRIM(v_temp_crdtcard)) OR
                      TRIM(TO_NUMBER(ZCNBRFRM)) = TRIM(v_temp_crdtcard) OR
                      TRIM(TO_NUMBER(ZCNBRTO)) = TRIM(v_temp_crdtcard))
                  AND TO_NUMBER(ZCARDDC) = length(v_temp_crdtcard); -- PH13
            END IF;

          EXCEPTION
            when No_data_found then

              v_zcrdtype := null;
          end;
        ELSE
          v_zcrdtype := ' ';
        END IF;
        obj_zmcipf.CARDTYP := v_zcrdtype;
        ------SIT Bug 
        obj_zmcipf.effdate := v_effdate;
        ----------------------------------------------check-------------------------------------------------------------------------------------------

        obj_zmcipf.USRPRF := i_userprofile;

------------------------PH14-START----------------------------
        obj_zmcipf.ZDDREQNO := v_zddreqno;
------------------------PH14-END------------------------------

        ----INSERT INTO IG TARGET TABLE ZTRAPF
        INSERT INTO Jd1dta.ZMCIPF VALUES obj_zmcipf;
      END IF;
      ---------------------- INSERT ZTRAPF END-------------------------------------------------------------------------------------------------------
      -----------------------UPDATE GCHD START------------------------------------------------------------------------------------------------------------

      --      IF ((v_prv_polnum IS NOT NULL) AND (v_prv_polnum <> v_chdrnum))
      --       THEN
      --        --Read GCHD where GCHD.CHDRNUM = TITDMGPOLTRNH.REFNUM, and update GCHD records to overwrite value of GCHD.TRANLUSED, with value in wsaa-last-tranno.
      --        UPDATE Jd1dta.GCHD
      --           SET TRANLUSED = v_last_tranno
      --         WHERE RTRIM(CHDRNUM) = RTRIM(v_prv_polnum);
      --      
      --      ELSE IF  (c_polhistcursor%rowcount = v_last_rowcnt) THEN
      --      
      --       UPDATE Jd1dta.GCHD
      --           SET TRANLUSED = v_tranno
      --         WHERE RTRIM(CHDRNUM) = RTRIM(v_chdrnum);
      --         
      --     END IF;
      --     END IF;
      -----------------------UPDATE GCHD END---------------------------------------------------------------------------------
      -------------------------SET VALUES OF PREV POLICY NO. AND LAST TRAN NO.-----------------------------------------------
      --       v_prv_polnum  := obj_ztrapf.CHDRNUM;
      --       v_last_tranno := obj_ztrapf.TRANNO;
      -----------------------------------------------------------------------------------------------------------------------      

      ---------------------- INSERT ZALTPF START-----------------------------------------------------------------------------
      -- SET DEFAULT VALUES IN OBJECT FOR ZTRAPF
 ------------------PH7: START--------------------------------    
     -- obj_zaltpf.CLTRELN := v_clntreln; --SIT change 
     obj_zaltpf.CLTRELN := v_cltreln; 
 ------------------PH7: END----------------------------------

      -- SET OTHER VALUES IN OBJECT FOR ZTRAPF
      obj_zaltpf.CHDRNUM := v_chdrnum;
      obj_zaltpf.TRANNO  := v_tranno;
      --obj_zaltpf.ALTQUOTENO             := v_space;--given "null" setting "spaces" here
      --obj_zaltpf.ZINTQUOT               := v_space;--given "null" setting "spaces" here
      obj_zaltpf.COWNNUM  := v_cownnum; --need to fetch again either from PAZDCLPF or GCHD
      obj_zaltpf.ZCMPCODE := v_zcmpcode;
      obj_zaltpf.ZCPNSCDE := v_zcpnscde;
      --obj_zaltpf.ZPCPNCDE               := v_space;--given "null" setting "spaces" here
      obj_zaltpf.ZCONVINDPOL := v_zconvindpol;
      obj_zaltpf.ZSALECHNL   := v_zsalechnl;
      obj_zaltpf.ZSOLCTFLG   := v_zsolctflg;
      --obj_zaltpf.CLTRELN
      obj_zaltpf.ZPLANCDE    := v_zplancde;
      obj_zaltpf.CRDTCARD    := v_crdtcard; --currently getting from TITDMGPOLTRNH might be changed
      obj_zaltpf.BNKACCKEY01 := v_bnkacckey01; --currently getting from TITDMGPOLTRNH might be changed
      --obj_zaltpf.BNKACCKEY02            := v_space;--given "null" setting "spaces" here
      obj_zaltpf.ZENSPCD01 := v_zenspcd01; --currently getting from TITDMGPOLTRNH might be changed
      obj_zaltpf.ZENSPCD02 := v_zenspcd02; --currently getting from TITDMGPOLTRNH might be changed
      obj_zaltpf.ZCIFCODE  := v_zcifcode; --currently getting from TITDMGPOLTRNH might be changed
      --obj_zaltpf.ZKANASNM               := v_space;
      --obj_zaltpf.ZKANAGNM               := v_space;
      --obj_zaltpf.KANJISURNAME           := v_space;
      --obj_zaltpf.KANJIGIVNAME           := v_space;
      --obj_zaltpf.ZRCORADR               := v_space;
      --obj_zaltpf.CLTPCODE               := v_space;
      --obj_zaltpf.KANJICLTADDR01         := v_space;
      --obj_zaltpf.KANJICLTADDR02         := v_space;
      --obj_zaltpf.KANJICLTADDR03         := v_space;
      --obj_zaltpf.KANJICLTADDR04         := v_space;
      --obj_zaltpf.ZKANADDR01             := v_space;
      --obj_zaltpf.ZKANADDR02             := v_space;
      --obj_zaltpf.ZKANADDR03             := v_space;
      --obj_zaltpf.ZKANADDR04             := v_space;
      --obj_zaltpf.CLTPHONE01             := v_space;

 ------------------PH7: START----------------------------------------------- 
--      IF ((RTRIM(v_statcode) = 'CA') AND (v_tranno = v_tranlused)) THEN
--        obj_zaltpf.CHGFLAG := 'T';
--      ELSE
--        obj_zaltpf.CHGFLAG := 'A';
--      END IF;
 ------------------PH7: END------------------------------------------------

      --obj_zaltpf.CHGFLAG                := v_space;--not sure of the value

      obj_zaltpf.DCLDATE    := v_dcldate; --not sure of the value
      obj_zaltpf.ZDCLITEM01 := v_zdclitem01; --not sure of the value
      obj_zaltpf.ZDCLITEM02 := v_zdclitem02; --not sure of the value
      obj_zaltpf.USRPRF     := i_userprofile;
      obj_zaltpf.JOBNM      := i_schedulename;
      obj_zaltpf.DATIME     := CAST(sysdate AS TIMESTAMP);
      obj_zaltpf.ZDECLCAT   := v_zdeclcat;
  /*  ITR4 - PH8 - LOT2 changes -- Start */
  --- obj_zaltpf.ZPGPFRDT   := v_zpgpfrdt;--ITR4 - Lot2 Chnage // already updated above 
  ---obj_zaltpf.ZPGPTODT   := v_zpgptodt;--Itr4 Lot2 Chnage // already updated above 
  /*  ITR4 - PH8 - LOT2 changes -- End */

      INSERT INTO Jd1dta.VIEW_DM_ZALTPF VALUES obj_zaltpf;
    END IF;

  END LOOP;

  CLOSE c_polhistcursor;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

END BQ9UU_MB01_POLHIST;