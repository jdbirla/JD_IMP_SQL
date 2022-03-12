create or replace PROCEDURE                               "BQ9TK_BL01_BILLHIST" (
    i_scheduleName   IN VARCHAR2,
    i_scheduleNumber IN VARCHAR2,
    i_zprvaldYN      IN VARCHAR2,
    i_company        IN VARCHAR2,
    i_usrprf         IN VARCHAR2,
    i_branch         IN VARCHAR2,
    i_transCode      IN VARCHAR2,
    i_vrcmTermid     IN VARCHAR2,
    i_vrcmtime       IN NUMBER,
    i_vrcmuser       IN NUMBER,
    i_acctYear       IN NUMBER,
    i_acctMonth      IN NUMBER)
AS
/***************************************************************************************************
  * Amenment History: BL01 Billing History
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       BL1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  *2804      JB        BL2   included checking for inputfile 2 for bill not migrated
  *0504      PS        BL3   Included ZCOLRATE from ZAGPPF.
  *0508      PS        BL4   Converted TRREFNUM to number during sorting.
  *0511      RC        BL5   Data Verification Changes
  *0514      PS        BL6   Corrected ZCTAXAMT formula
  *0521		 RC		   BL7	 ZMPCPF & ZPCMPF EFFDATE
  *0713      RC        BL8   CR 7825 Changes
  *0723      SC        BL9  CR AND DATA ACCUMULATION CHANGES
  *****************************************************************************************************/
  v_timestart        NUMBER := dbms_utility.get_time;
  isValid            NUMBER(1) DEFAULT 0;
  v_date             VARCHAR2(20);
  n_duplicate        NUMBER(3) DEFAULT 0;
  v_tableNametemp    VARCHAR2(10);
  v_tableName        VARCHAR2(10);
  n_errorCount       NUMBER(1) DEFAULT 0;
  n_errorCount2      NUMBER(1) DEFAULT 0;
  b_isNoError        BOOLEAN := TRUE;
  b_isNoError2       BOOLEAN := TRUE;
  b_globalError      BOOLEAN := TRUE;
  b_memberpolicyFlag BOOLEAN := FALSE;
  b_convertedindpol  BOOLEAN := FALSE;
  b_indpolicyFlag    BOOLEAN := FALSE;
  n_cmrate           NUMBER(3);
  n_check            NUMBER(3) DEFAULT 1;
  n_gagnstel01       NUMBER(1) DEFAULT 0;
  n_gagnstel02       NUMBER(1) DEFAULT 0;
  n_gagnstel03       NUMBER(1) DEFAULT 0;
  n_gagnstel04       NUMBER(1) DEFAULT 0;
  n_gagnstel05       NUMBER(1) DEFAULT 0;
  v_pkvalue          NUMBER;
  v_gpmdun           NUMBER;
  n_billno GDOCPF.LDOCNO%type;
  n_trdt GBIHPF.TRDT%type;
  C_MAXDATE CONSTANT VARCHAR2(20 CHAR) := '99999999';
  C_BQ9TK   CONSTANT VARCHAR2(5)       := 'BQ9TK';
  C_PREFIX  CONSTANT VARCHAR2(2)       := GET_MIGRATION_PREFIX('BILL', i_company);
  gchp_zgporipcls GCHPPF.ZGPORIPCLS%type;
  gchp_zconvindpol GCHPPF.ZCONVINDPOL%type;
  v_zagptnum GCHIPF.ZAGPTNUM%type;
  v_zcmpcode GCHIPF.ZCMPCODE%type;
  n_splitc01 ZAGPPF.SPLITC01%type;
  n_splitc02 ZAGPPF.SPLITC02%type;
  n_splitc03 ZAGPPF.SPLITC03%type;
  n_splitc04 ZAGPPF.SPLITC04%type;
  n_splitc05 ZAGPPF.SPLITC05%type;
  v_zcolrate ZAGPPF.Zcolrate%type DEFAULT 0;
  v_gagntsel01 ZAGPPF.Gagntsel01%type;
  v_gagntsel02 ZAGPPF.Gagntsel02%type;
  v_gagntsel03 ZAGPPF.Gagntsel03%type;
  v_gagntsel04 ZAGPPF.Gagntsel04%type;
  v_gagntsel05 ZAGPPF.Gagntsel05%type;
  n_wsaasplitc01 ZAGPPF.SPLITC01%type;
  n_wsaasplitc02 ZAGPPF.SPLITC02%type;
  n_wsaasplitc03 ZAGPPF.SPLITC03%type;
  n_wsaasplitc04 ZAGPPF.SPLITC04%type;
  n_wsaasplitc05 ZAGPPF.SPLITC05%type;
  C_RECORDSKIPPED CONSTANT VARCHAR2(17) := 'Record skipped';
  C_RECORDSUCCESS CONSTANT VARCHAR2(20) := 'Record successful';
  C_SUCCESS       CONSTANT VARCHAR2(3)  := 'S';
  C_ERROR         CONSTANT VARCHAR2(3)  := 'E';
  obj_gbidpf GBIDPF%rowtype;
  obj_gpmdpf GPMDPF%rowtype;
  obj_zmpcpf ZMPCPF%rowtype;
  obj_zpcmpf01 ZPCMPF%rowtype;
  obj_zpcmpf02 ZPCMPF%rowtype;
  obj_zpcmpf03 ZPCMPF%rowtype;
  obj_zpcmpf04 ZPCMPF%rowtype;
  obj_zpcmpf05 ZPCMPF%rowtype;
  tempZagppf VARCHAR2(200);
  idx_billno PLS_INTEGER;
  t_billno GPMDPF.BILLNO%type; ----BL8

  tempZagptnum VARCHAR2(200); -- Rehearsal Chnages
  temp_val     NUMBER DEFAULT 0;
---------------BL9: START-------------------------------------
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
---------------BL9: END-------------------------------------  
  --- Rehearsal Changes ------
  i_trrefnum TITDMGBILL1.TRREFNUM@DMSTAGEDBLINK%type;
  i_chdrnum TITDMGBILL1.CHDRNUM@DMSTAGEDBLINK%type;
  i_prbilfdt TITDMGBILL1.PRBILFDT@DMSTAGEDBLINK%type;
  i_prbiltdt TITDMGBILL1.PRBILTDT@DMSTAGEDBLINK%type;
  v_temp_key VARCHAR2(200);
  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist pkg_dm_common_operations.itemschec;
  o_errortext pkg_dm_common_operations.errordesc;
  i_zdoe_info1 pkg_dm_common_operations.obj_zdoe;
  i_zdoe_info2 pkg_dm_common_operations.obj_zdoe;
  i_zdoe_err_info2 pkg_dm_common_operations.obj_zdoe;
  i_zdoe_info_temp pkg_dm_common_operations.obj_zdoe;
  checkchdrnum pkg_common_dmbl.gchdtype;
  checkagent pkg_common_dmbl.agntpftype;
  --  file2exists      pkg_common_dmbl.titdmgbill;
  getZagppf pkg_common_dmbl.newzagppf;
  getZdrbpf pkg_common_dmbl.duplicateZdrbpf;
  getZagptnum pkg_common_dmbl.newgchipf; ---- Rehearsal Chnages
  BILL1INFO pkg_common_dmbl.BILL1TYPE;     -- Rehearsal Chnages
  t_zentity ZDRBPF.ZENTITY%type;
  t_chdrnum ZDRBPF.CHDRNUM%type;
  t_zigvalue ZDRBPF.ZIGVALUE%type;
  ----getbillno        pkg_common_dmmb.billnomap;
  --  TYPE obj_billno IS RECORD(
  --       t_zentity  ZDRBPF.ZENTITY%type,
  --       t_chdrnum  ZDRBPF.CHDRNUM%type,
  --       t_zigvalue ZDRBPF.ZIGVALUE%type);
  --  TYPE t_billno IS TABLE OF obj_billno index by BINARY_INTEGER;
  --       billnolist t_billno;
  --
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
  TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  t_errorfieldval2 errorfieldvalue_tab;
type errorprogram_tab
IS
  TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;
  t_errorprogram2 errorprogram_tab;
  idx PLS_INTEGER;
type error_type
IS
  TABLE OF obj_zdoe;
  error_list error_type := error_type();
  errindex INTEGER      := 0;
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
  -------------------- TITDMGBILL1 ---------------------------
  CURSOR c_billing1
  IS
    SELECT * FROM TITDMGBILL1@DMSTAGEDBLINK  ORDER BY chdrnum ASC, to_number(trrefnum) ASC;   -- BL3
    --SELECT * FROM TITDMGBILL1@DMSTAGEDBLINK ORDER BY chdrnum ASC, trrefnum ASC;            -- BL3
  obj_billing1 c_billing1%rowtype;
  ---------------------- TITDMGBILL2 -------------------------
  CURSOR c_billing2
  IS


    SELECT A.*,
      B.ZIGVALUE, B.PRBILFDT, B.PRBILTDT  -- BL5
    FROM TITDMGBILL2@DMSTAGEDBLINK A
    LEFT OUTER JOIN Jd1dta.ZDRBPF B
    ON TRIM(A.CHDRNUM)  = TRIM(B.CHDRNUM)
    AND TRIM(A.TRREFNUM)=TRIM(B.ZENTITY)
    ORDER BY A.chdrnum ASC,
      to_number(A.trrefnum) ASC;    -- BL3


  --  A.trrefnum ASC;               -- BL3
  --WHERE TRIM(TRREFNUM) = t1refnum
  --AND TRIM(CHDRNUM) = t1chdrnum;
  obj_billing2 c_billing2%rowtype;
  --  CURSOR c_billing2 IS
  --    SELECT *
  --      FROM TITDMGBILL2@DMSTAGEDBLINK
  --       order by chdrnum asc, trrefnum asc;
  --     --WHERE TRIM(TRREFNUM) = t1refnum
  --       --AND TRIM(CHDRNUM) = t1chdrnum;
  --  obj_billing2 c_billing2%rowtype;
BEGIN
  ---------Common Function Calling------------
    pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9TK,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMBL', o_errortext => o_errortext);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'BQ9TK', itemexist => itemexist);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  pkg_common_dmbl.checkpolicy(i_company => i_company, checkchdrnum => checkchdrnum);
  pkg_common_dmbl.checkagent(checkagent => checkagent);
  --pkg_common_dmbl.file2exists(file2exists => file2exists);
  pkg_common_dmbl.getZagppf(getZagppf => getZagppf);
  pkg_common_dmbl.getZdrbpf(getZdrbpf => getZdrbpf);
  ---pkg_common_dmmb.getbillno(getbillno => getbillno);
  pkg_common_dmbl.getZagptnum(getZagptnum => getZagptnum); -- Rehearsal Chnages
  pkg_common_dmbl.getbill1info(BILL1INFO => BILL1INFO);    -- Rehearsal Chnages
  --------------------- TRDT From BSUDPF ------------------------
  SELECT TO_CHAR(to_date(BUSDATE, 'YYYYMMDD'), 'YYMMDD')
  INTO n_trdt
  FROM BUSDPF
  WHERE COMPANY = '1';
  -------------- BILLNO From GDOCPF --------------------------
  SELECT LDOCNO + 1
  INTO n_billno
  FROM GDOCPF
  WHERE CHDRCOY = '1'
  AND DOCTYP    = 'PRMNOT';
  OPEN c_billing1;
  <<again_start>>
  LOOP
    FETCH c_billing1 INTO obj_billing1;
    EXIT
  WHEN c_billing1%notfound;
    i_zdoe_info1              := NULL;
    i_zdoe_info1.i_zfilename  := 'TITDMGBILL1';
    i_zdoe_info1.i_prefix     := C_PREFIX;
    i_zdoe_info1.i_scheduleno := i_scheduleNumber;
    i_zdoe_info1.i_refKey     := obj_billing1.TRREFNUM || '-' || obj_billing1.CHDRNUM;
    i_zdoe_info1.i_tableName  := v_tableName;
    --b_isNoError              :=true;
    n_errorCount       := 0;
    n_duplicate        := 0;
    t_ercode(1)        := NULL;
    t_ercode(2)        := NULL;
    t_ercode(3)        := NULL;
    t_ercode(4)        := NULL;
    t_ercode(5)        := NULL;
    isValid            := 0;
    n_check            := 1;
    n_gagnstel01       := 0;
    n_gagnstel02       := 0;
    errindex           := 0;
    n_gagnstel03       := 0;
    n_gagnstel04       := 0;
    n_gagnstel05       := 0;
    b_memberpolicyFlag := FALSE;
    b_convertedindpol  := FALSE;
    b_indpolicyFlag    := FALSE;
    b_isNoError        := TRUE;
    gbidpfindex        := 0;
    gpmdpfindex        := 0;
    zpcmpfindex01      := 0;
    zpcmpfindex02      := 0;
    zpcmpfindex03      := 0;
    zpcmpfindex04      := 0;
    zpcmpfindex05      := 0;
    zmpcpfindex        := 0;
    gbidpf_list        := gbidpf_type();
    gpmdpf_list        := gpmdpf_type();
    zmpcpf_list        := zmpcpf_type();
    zpcmpf_list01      := zpcmpf_type01();
    zpcmpf_list02      := zpcmpf_type02();
    zpcmpf_list03      := zpcmpf_type03();
    zpcmpf_list04      := zpcmpf_type04();
    zpcmpf_list05      := zpcmpf_type05();
    SELECT SEQTMP.nextval INTO temp_val FROM dual;
    --------------------- TITDMGBILL1 Validations Start --------------------------
    ----------------- Duplicate Record Validation ------------------------------
    IF (getZdrbpf.exists(TRIM(obj_billing1.TRREFNUM) || TRIM(obj_billing1.CHDRNUM))) THEN
      b_isNoError                   := FALSE;
      n_errorCount                  := n_errorCount + 1;
      t_ercode(n_errorCount)        := 'RQMA';
      t_errorfield(n_errorCount)    := 'CHDRNUM';
      t_errormsg(n_errorCount)      := o_errortext('RQMA');
      t_errorfieldval(n_errorCount) := obj_billing1.CHDRNUM || '-' || obj_billing1.TRREFNUM;
      t_errorprogram(n_errorCount)  := i_scheduleName;
      GOTO insertzdoe;
    END IF;
    ----------------- CHDRNUM Validation ------------------------------
    IF NOT (checkchdrnum.exists(TRIM(obj_billing1.CHDRNUM))) THEN
      b_isNoError                   := FALSE;
      n_errorCount                  := n_errorCount + 1;
      t_ercode(n_errorCount)        := 'RQMB';
      t_errorfield(n_errorCount)    := 'CHDRNUM';
      t_errormsg(n_errorCount)      := o_errortext('RQMB');
      t_errorfieldval(n_errorCount) := obj_billing1.CHDRNUM;
      t_errorprogram(n_errorCount)  := i_scheduleName;
      GOTO insertzdoe;
    END IF;
    ------------------- PREMIUM OUTSTANDING Validation -----------------------------
    IF obj_billing1.PREMOUT         <> 'Y' AND obj_billing1.PREMOUT <> 'N' THEN
      b_isNoError                   := FALSE;
      n_errorCount                  := n_errorCount + 1;
      t_ercode(n_errorCount)        := 'RQM8';
      t_errorfield(n_errorCount)    := 'PREMOUT';
      t_errormsg(n_errorCount)      := o_errortext('RQM8');
      t_errorfieldval(n_errorCount) := obj_billing1.PREMOUT;
      t_errorprogram(n_errorCount)  := i_scheduleName;
      IF n_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ------------------------ PERIOD OF BILLING Validation ---------------------------------
    v_date                          := VALIDATE_DATE(obj_billing1.PRBILFDT);
    IF v_date                       <> 'OK' THEN
      b_isNoError                   := FALSE;
      n_errorCount                  := n_errorCount + 1;
      t_ercode(n_errorCount)        := 'RQLT';
      t_errorfield(n_errorCount)    := 'PRBILFDT';
      t_errormsg(n_errorCount)      := o_errortext('RQLT');
      t_errorfieldval(n_errorCount) := obj_billing1.PRBILFDT;
      t_errorprogram(n_errorCount)  := i_scheduleName;
      IF n_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    v_date                          := VALIDATE_DATE(obj_billing1.PRBILTDT);
    IF v_date                       <> 'OK' THEN
      b_isNoError                   := FALSE;
      n_errorCount                  := n_errorCount + 1;
      t_ercode(n_errorCount)        := 'RQLT';
      t_errorfield(n_errorCount)    := 'PRBILTDT';
      t_errormsg(n_errorCount)      := o_errortext('RQLT');
      t_errorfieldval(n_errorCount) := obj_billing1.PRBILTDT;
      t_errorprogram(n_errorCount)  := i_scheduleName;
      IF n_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    ----------------- Insert ZDOE ------------------------------
    <<insertzdoe>>
    IF (b_isNoError                    = FALSE) THEN
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
    IF b_isNoError               = TRUE THEN
      i_zdoe_info1.i_indic      := C_SUCCESS;
      i_zdoe_info1.i_errormsg01 := C_RECORDSUCCESS;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1);
    END IF;
    IF b_isNoError = TRUE AND i_zprvaldYN = 'N' THEN
      --------------------- GBIHPF Insertion ----------------------------
      INSERT
      INTO Jd1dta.GBIHPF
        (
          BILLNO,
          CHDRCOY,
          CHDRNUM,
          SUBSCOY,
          SUBSNUM,
          MBRNO,
          BILLTYP,
          PRBILFDT,
          PRBILTDT,
          INSTNO,
          PBILLNO,
          TERMID,
          TRDT,
          TRTM,
          TRANNO,
          GRPGST,
          GRPSDUTY,
          VALIDFLAG,
          BILFLAG,
          NRFLG,
          TGTPCNT,
          USRPRF,
          JOBNM,
          DATIME,
          PREMOUT,
          BILLDUEDT,
          REVFLAG,
          USER_T,
          ZGSTAFEE,
          ZGSTCOM,
          ZCOLFLAG,
          ZACMCLDT,
          PAYDATE,
          ZPOSBDSM,
          ZPOSBDSY,
          ZBKTRFDT,
          ---- BL5 Start -----
          RDOCPFX,
          RDOCCOY,
          RDOCNUM,
          ZSTPBLYN
          ---- BL5 End ------
        )
        VALUES
        (
          n_billno,
          i_company,
          obj_billing1.CHDRNUM,
          ' ',
          ' ',
          --o_defaultvalues('MBRNO'), --- BL5
          ' ', -- BL5
          o_defaultvalues('BILLTYP'),
          obj_billing1.PRBILFDT,
          obj_billing1.PRBILTDT,
          obj_billing1.TRREFNUM,
          '0',
          --i_vrcmTermid, --- BL5
          'QPAD', --- BL5
          n_trdt,
          i_vrcmtime,
          obj_billing1.TRREFNUM,
          '0',
          '0',
          o_defaultvalues('VALIDFLAG'),
          o_defaultvalues('BILFLAG'),
          o_defaultvalues('NRFLG'),
          '0',
          i_usrprf,
          i_scheduleName,
          CAST(sysdate AS TIMESTAMP),
          obj_billing1.PREMOUT,
          obj_billing1.TFRDATE,
          o_defaultvalues('REVFLAG'),
          --i_vrcmuser, --- BL5
          36, --- BL5
          '0',
          '0',
          obj_billing1.ZCOLFLAG,
          obj_billing1.ZACMCLDT,
          C_MAXDATE,
          obj_billing1.ZPOSBDSM,
          obj_billing1.ZPOSBDSY,
          C_MAXDATE,
          ------ BL5 Start ----
          ' ',
          ' ',
          ' ',
          ' '
          ------ BL5 End -----
        );
      ---------------------------- ZDRBPF Insertion -----------------------------
      INSERT
      INTO Jd1dta.ZDRBPF
        (
          PREFIX,
          ZENTITY,
          CHDRNUM,
          ZIGVALUE,
          JOBNUM,
          JOBNAME,
          PRBILFDT, --- BL5
          PRBILTDT,  --- BL5
          ZPDATATXFLG --BL9
        )
        VALUES
        (
          C_PREFIX,
          obj_billing1.TRREFNUM,
          obj_billing1.CHDRNUM,
          n_billno,
          i_scheduleNumber,
          i_scheduleName,
          obj_billing1.PRBILFDT, --- BL5
          obj_billing1.PRBILTDT,--- BL5
          obj_billing1.ZPDATATXFLG --BL9
        );
      n_billno := n_billno + 1;
    END IF;
    --select bilseq1.nextval into v_pkvalue from dual;
  END LOOP;

  --------------------------- GDOCPF Updation -----------------------
  UPDATE Jd1dta.GDOCPF
  SET LDOCNO    = n_billno - 1,
    USRPRF      = i_usrprf,
    JOBNM       = i_scheduleName,
    DATIME      = CURRENT_TIMESTAMP
  WHERE CHDRCOY = '1'
  AND DOCTYP    = 'PRMNOT';
 COMMIT;
  --------------------------- OPEN TITDMGBILL2 -----------------------
  --   Select ZENTITY, CHDRNUM, ZIGVALUE
  --      BULK COLLECT
  --      into billnolist
  --      from Jd1dta.ZDRBPF;
   --------------------------- OPEN TITDMGBILL2 -----------------------
  --   Select ZENTITY, CHDRNUM, ZIGVALUE
  --      BULK COLLECT
  --      into billnolist
  --      from Jd1dta.ZDRBPF;


------------BL9 : START------------------------  
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
------------BL9 : END------------------------  
  OPEN c_billing2;
  <<again_start2>>
  LOOP
    FETCH c_billing2 INTO obj_billing2;
    EXIT
  WHEN c_billing2%notfound;
    i_zdoe_info2              := NULL;
    i_zdoe_info2.i_zfilename  := 'TITDMGBILL2';
    i_zdoe_info2.i_refKey     := obj_billing2.TRREFNUM || '-' || obj_billing2.CHDRNUM || '-' || obj_billing2.PRODTYP;
    i_zdoe_info2.i_tableName  := v_tableName;
    i_zdoe_info2.i_scheduleno := i_scheduleNumber;
    b_isNoError2              := TRUE;
    n_errorCount2             := 0;
    t_ercode2(1)              := NULL;
    t_ercode2(2)              := NULL;
    t_ercode2(3)              := NULL;
    t_ercode2(4)              := NULL;
    t_ercode2(5)              := NULL;
    n_gagnstel01              := 0;
    n_gagnstel02              := 0;
    n_gagnstel03              := 0;
    n_gagnstel04              := 0;
    n_gagnstel05              := 0;
    v_temp_key                := TRIM(obj_billing2.TRREFNUM) || TRIM(obj_billing2.CHDRNUM); ---- Rehearsal Chnages
    SELECT SEQTMP1.nextval INTO temp_val FROM dual;
    -- Rehearsal Chnages
    --IF (BILL1INFO.exists(v_temp_key)) THEN
    --  i_trrefnum := BILL1INFO(TRIM(v_temp_key)).trrefnum;
    --  i_chdrnum  := BILL1INFO(TRIM(v_temp_key)).chdrnum;
    --  i_prbilfdt := BILL1INFO(TRIM(v_temp_key)).prbilfdt;
    --  i_prbiltdt := BILL1INFO(TRIM(v_temp_key)).prbiltdt;
    --ELSE
    --  CONTINUE again_start2;
    --END IF;
    -- Rehearsal Chnages

	--SELECT COUNT(*)INTO v_last_rowcnt FROM TITDMGBILL2@DMSTAGEDBLINK  where chdrnum in ('00285404','00287016');--BL9

    -----------------BL2:Bil not migrated----
    IF (TRIM(obj_billing2.ZIGVALUE) IS NULL) THEN
      b_isNoError2                  := FALSE;
      b_globalError                 := FALSE;
      n_errorCount2                 := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'BLNM';
      t_errorfield2(n_errorCount2)    := ' ';
      t_errormsg2(n_errorCount2)      := 'Bill Not migrated';
      t_errorfieldval2(n_errorCount2) := ' ';
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      GOTO insertzdoe2;
    END IF;
    --------------BL2:Bil not migrated-------------
    ---------------- Product Code Validation -------------------
    IF NOT (itemexist.exists(TRIM('T9797') || TRIM(obj_billing2.PRODTYP) || 1)) THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQLU';
      t_errorfield2(n_errorCount2)    := 'PRODTYP';
      t_errormsg2(n_errorCount2)      := o_errortext('RQLU');
      t_errorfieldval2(n_errorCount2) := obj_billing2.PRODTYP;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    -------------------- Group Agent Validation --------------------
    IF NOT (checkagent.exists(TRIM(obj_billing2.GAGNTSEL01))) THEN
      --IF n_gagnstel01 = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQM3';
      t_errorfield2(n_errorCount2)    := 'GAGNTSEL01';
      t_errormsg2(n_errorCount2)      := o_errortext('RQM3');
      t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL01;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    ELSE
      n_gagnstel01 := 1;
    END IF;
    IF TRIM(obj_billing2.GAGNTSEL02) IS NOT NULL THEN
      IF NOT (checkagent.exists(TRIM(obj_billing2.GAGNTSEL02))) THEN
        --IF n_gagnstel02 = 0 THEN
        b_isNoError2                    := FALSE;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQM3';
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL02';
        t_errormsg2(n_errorCount2)      := o_errortext('RQM3');
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL02;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      ELSE
        n_gagnstel02 := 1;
      END IF;
    END IF;
    IF TRIM(obj_billing2.GAGNTSEL03) IS NOT NULL THEN
      IF NOT (checkagent.exists(TRIM(obj_billing2.GAGNTSEL03))) THEN
        --IF n_gagnstel03 = 0 THEN
        b_isNoError2                    := FALSE;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQM3';
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL03';
        t_errormsg2(n_errorCount2)      := o_errortext('RQM3');
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL03;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      ELSE
        n_gagnstel03 := 1;
      END IF;
    END IF;
    IF TRIM(obj_billing2.GAGNTSEL04) IS NOT NULL THEN
      IF NOT (checkagent.exists(TRIM(obj_billing2.GAGNTSEL04))) THEN
        --IF n_gagnstel04 = 0 THEN
        b_isNoError2                    := FALSE;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQM3';
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL04';
        t_errormsg2(n_errorCount2)      := o_errortext('RQM3');
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL04;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      ELSE
        n_gagnstel04 := 1;
      END IF;
    END IF;
    IF TRIM(obj_billing2.GAGNTSEL05) IS NOT NULL THEN
      IF NOT (checkagent.exists(TRIM(obj_billing2.GAGNTSEL05))) THEN
        --IF n_gagnstel05 = 0 THEN
        b_isNoError2                    := FALSE;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQM3';
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL05';
        t_errormsg2(n_errorCount2)      := o_errortext('RQM3');
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL05;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      ELSE
        n_gagnstel05 := 1;
      END IF;
    END IF;
    ----------------- Commision Percentage Validation --------------------
    n_cmrate                          := obj_billing2.CMRATE01;
    IF obj_billing2.CMRATE01          IS NOT NULL AND n_cmrate > 100 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQMD';
      t_errorfield2(n_errorCount2)    := 'CMRATE01';
      t_errormsg2(n_errorCount2)      := o_errortext('RQMD');
      t_errorfieldval2(n_errorCount2) := obj_billing2.CMRATE01;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    n_cmrate                          := n_cmrate + obj_billing2.CMRATE02;
    IF TRIM(obj_billing2.CMRATE02)    IS NOT NULL AND n_cmrate > 100 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQMD';
      t_errorfield2(n_errorCount2)    := 'CMRATE02';
      t_errormsg2(n_errorCount2)      := o_errortext('RQMD');
      t_errorfieldval2(n_errorCount2) := obj_billing2.CMRATE02;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    n_cmrate                          := n_cmrate + obj_billing2.CMRATE03;
    IF TRIM(obj_billing2.CMRATE03)    IS NOT NULL AND n_cmrate > 100 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQMD';
      t_errorfield2(n_errorCount2)    := 'CMRATE03';
      t_errormsg2(n_errorCount2)      := o_errortext('RQMD');
      t_errorfieldval2(n_errorCount2) := obj_billing2.CMRATE03;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    n_cmrate                          := n_cmrate + obj_billing2.CMRATE04;
    IF TRIM(obj_billing2.CMRATE04)    IS NOT NULL AND n_cmrate > 100 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQMD';
      t_errorfield2(n_errorCount2)    := 'CMRATE04';
      t_errormsg2(n_errorCount2)      := o_errortext('RQMD');
      t_errorfieldval2(n_errorCount2) := obj_billing2.CMRATE04;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    n_cmrate                          := n_cmrate + obj_billing2.CMRATE05;
    IF TRIM(obj_billing2.CMRATE05)    IS NOT NULL AND n_cmrate > 100 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQMD';
      t_errorfield2(n_errorCount2)    := 'CMRATE05';
      t_errormsg2(n_errorCount2)      := o_errortext('RQMD');
      t_errorfieldval2(n_errorCount2) := obj_billing2.CMRATE05;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    ------------------- Commision Validation --------------------------
    IF TRIM(obj_billing2.CMRATE01)     > 0 AND TRIM(obj_billing2.COMMN01) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQN1';
      t_errorfield2(n_errorCount2)    := 'COMMN01';
      t_errormsg2(n_errorCount2)      := o_errortext('RQN1');
      t_errorfieldval2(n_errorCount2) := obj_billing2.COMMN01;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE02)     > 0 AND TRIM(obj_billing2.COMMN02) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQN1';
      t_errorfield2(n_errorCount2)    := 'COMMN02';
      t_errormsg2(n_errorCount2)      := o_errortext('RQN1');
      t_errorfieldval2(n_errorCount2) := obj_billing2.COMMN02;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE03)     > 0 AND TRIM(obj_billing2.COMMN03) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQN1';
      t_errorfield2(n_errorCount2)    := 'COMMN03';
      t_errormsg2(n_errorCount2)      := o_errortext('RQN1');
      t_errorfieldval2(n_errorCount2) := obj_billing2.COMMN03;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE04)     > 0 AND TRIM(obj_billing2.COMMN04) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQN1';
      t_errorfield2(n_errorCount2)    := 'COMMN04';
      t_errormsg2(n_errorCount2)      := o_errortext('RQN1');
      t_errorfieldval2(n_errorCount2) := obj_billing2.COMMN04;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE05)     > 0 AND TRIM(obj_billing2.COMMN05) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQN1';
      t_errorfield2(n_errorCount2)    := 'COMMN05';
      t_errormsg2(n_errorCount2)      := o_errortext('RQN1');
      t_errorfieldval2(n_errorCount2) := obj_billing2.COMMN05;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    ----------------------- Agent Gross Premium ------------------
    IF TRIM(obj_billing2.CMRATE01)     > 0 AND TRIM(obj_billing2.ZAGTGPRM01) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQNI';
      t_errorfield2(n_errorCount2)    := 'ZAGTGPRM01';
      t_errormsg2(n_errorCount2)      := o_errortext('RQNI');
      t_errorfieldval2(n_errorCount2) := obj_billing2.ZAGTGPRM01;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE02)     > 0 AND TRIM(obj_billing2.ZAGTGPRM02) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQNI';
      t_errorfield2(n_errorCount2)    := 'ZAGTGPRM02';
      t_errormsg2(n_errorCount2)      := o_errortext('RQNI');
      t_errorfieldval2(n_errorCount2) := obj_billing2.ZAGTGPRM02;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE03)     > 0 AND TRIM(obj_billing2.ZAGTGPRM03) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQNI';
      t_errorfield2(n_errorCount2)    := 'ZAGTGPRM03';
      t_errormsg2(n_errorCount2)      := o_errortext('RQNI');
      t_errorfieldval2(n_errorCount2) := obj_billing2.ZAGTGPRM03;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE04)     > 0 AND TRIM(obj_billing2.ZAGTGPRM04) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQNI';
      t_errorfield2(n_errorCount2)    := 'ZAGTGPRM04';
      t_errormsg2(n_errorCount2)      := o_errortext('RQNI');
      t_errorfieldval2(n_errorCount2) := obj_billing2.ZAGTGPRM04;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    IF TRIM(obj_billing2.CMRATE05)     > 0 AND TRIM(obj_billing2.ZAGTGPRM05) = 0 THEN
      b_isNoError2                    := FALSE;
      b_globalError                   := FALSE;
      n_errorCount2                   := n_errorCount2 + 1;
      t_ercode2(n_errorCount2)        := 'RQNI';
      t_errorfield2(n_errorCount2)    := 'ZAGTGPRM05';
      t_errormsg2(n_errorCount2)      := o_errortext('RQNI');
      t_errorfieldval2(n_errorCount2) := obj_billing2.ZAGTGPRM05;
      t_errorprogram2(n_errorCount2)  := i_scheduleName;
      IF n_errorCount2                >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    END IF;
    ------------------------- LOGIC FOR AGENCY PATTERN ID ------------------------
    IF b_isNoError2 = TRUE THEN
      --SELECT ZAGPTNUM INTO v_zagptnum FROM GCHIPF WHERE TRIM(CHDRNUM) = TRIM(obj_billing1.CHDRNUM);
      --dbms_output.put_line('Procedure execution time = ' || obj_billing2.CHDRNUM);
      IF (getZagptnum.exists(TRIM(obj_billing2.CHDRNUM))) THEN
        tempZagptnum := getZagptnum(TRIM(obj_billing2.CHDRNUM));
        --dbms_output.put_line('ZAGPTNUM' || tempZagptnum);
        SELECT tempZagptnum
        INTO v_zagptnum
        FROM dual;
      END IF;
      ---------------------- SPLITC Logic ------------------------------------------
      IF (getZagppf.exists(trim(v_zagptnum))) THEN
        tempZagppf := getZagppf(TRIM(v_zagptnum));
        SELECT TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 1)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 2)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 3)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 4)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 5)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 6)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 7)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 8)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 9)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 10)),
          TRIM(regexp_substr(tempZagppf, '[^$]+', 1, 11))       -- BL3
        INTO v_gagntsel01,
          v_gagntsel02,
          v_gagntsel03,
          v_gagntsel04,
          v_gagntsel05,
          n_splitc01,
          n_splitc02,
          n_splitc03,
          n_splitc04,
          n_splitc05,
          v_zcolrate         -- BL3
        FROM dual;
      END IF;
      IF TRIM(obj_billing2.GAGNTSEL01)  <> TRIM(v_gagntsel01) AND TRIM(obj_billing2.GAGNTSEL01) <> TRIM(v_gagntsel02) AND TRIM(obj_billing2.GAGNTSEL01) <> TRIM(v_gagntsel03) AND TRIM(obj_billing2.GAGNTSEL01) <> TRIM(v_gagntsel04) AND TRIM(obj_billing2.GAGNTSEL01) <> TRIM(v_gagntsel05) THEN
        b_isNoError2                    := FALSE;
        n_gagnstel01                    := 0;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQWJ'; --- NEED TO CHANGE
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL01';
        t_errormsg2(n_errorCount2)      := o_errortext('RQWJ'); -- Need to change
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL01;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      IF n_gagnstel01                    = 1 THEN
        IF TRIM(obj_billing2.GAGNTSEL01) = TRIM(v_gagntsel01) THEN
          n_wsaasplitc01                := n_splitc01;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL01) = TRIM(v_gagntsel02) THEN
          n_wsaasplitc01                := n_splitc02;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL01) = TRIM(v_gagntsel03) THEN
          n_wsaasplitc01                := n_splitc03;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL01) = TRIM(v_gagntsel04) THEN
          n_wsaasplitc01                := n_splitc04;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL01) = TRIM(v_gagntsel05) THEN
          n_wsaasplitc01                := n_splitc05;
        END IF;
      END IF;
      IF TRIM(obj_billing2.GAGNTSEL02)  <> TRIM(v_gagntsel01) AND TRIM(obj_billing2.GAGNTSEL02) <> TRIM(v_gagntsel02) AND TRIM(obj_billing2.GAGNTSEL02) <> TRIM(v_gagntsel03) AND TRIM(obj_billing2.GAGNTSEL02) <> TRIM(v_gagntsel04) AND TRIM(obj_billing2.GAGNTSEL02) <> TRIM(v_gagntsel05) THEN
        b_isNoError2                    := FALSE;
        n_gagnstel02                    := 0;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQWJ'; --- NEED TO CHANGE
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL02';
        t_errormsg2(n_errorCount2)      := o_errortext('RQWJ'); -- Need to change
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL02;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      IF n_gagnstel02                    = 1 THEN
        IF TRIM(obj_billing2.GAGNTSEL02) = TRIM(v_gagntsel01) THEN
          n_wsaasplitc02                := n_splitc01;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL02) = TRIM(v_gagntsel02) THEN
          n_wsaasplitc02                := n_splitc02;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL02) = TRIM(v_gagntsel03) THEN
          n_wsaasplitc02                := n_splitc03;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL02) = TRIM(v_gagntsel04) THEN
          n_wsaasplitc02                := n_splitc04;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL02) = TRIM(v_gagntsel05) THEN
          n_wsaasplitc02                := n_splitc05;
        END IF;
      END IF;
      IF TRIM(obj_billing2.GAGNTSEL03)  <> TRIM(v_gagntsel01) AND TRIM(obj_billing2.GAGNTSEL03) <> TRIM(v_gagntsel02) AND TRIM(obj_billing2.GAGNTSEL03) <> TRIM(v_gagntsel03) AND TRIM(obj_billing2.GAGNTSEL03) <> TRIM(v_gagntsel04) AND TRIM(obj_billing2.GAGNTSEL03) <> TRIM(v_gagntsel05) THEN
        b_isNoError2                    := FALSE;
        n_gagnstel03                    := 0;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQWJ'; --- NEED TO CHANGE
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL03';
        t_errormsg2(n_errorCount2)      := o_errortext('RQWJ'); -- Need to change
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL03;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      IF n_gagnstel03                    = 1 THEN
        IF TRIM(obj_billing2.GAGNTSEL03) = TRIM(v_gagntsel01) THEN
          n_wsaasplitc03                := n_splitc01;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL03) = TRIM(v_gagntsel02) THEN
          n_wsaasplitc03                := n_splitc02;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL03) = TRIM(v_gagntsel03) THEN
          n_wsaasplitc03                := n_splitc03;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL03) = TRIM(v_gagntsel04) THEN
          n_wsaasplitc03                := n_splitc04;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL03) = TRIM(v_gagntsel05) THEN
          n_wsaasplitc03                := n_splitc05;
        END IF;
      END IF;
      IF TRIM(obj_billing2.GAGNTSEL04)  <> TRIM(v_gagntsel01) AND TRIM(obj_billing2.GAGNTSEL04) <> TRIM(v_gagntsel02) AND TRIM(obj_billing2.GAGNTSEL04) <> TRIM(v_gagntsel03) AND TRIM(obj_billing2.GAGNTSEL04) <> TRIM(v_gagntsel04) AND TRIM(obj_billing2.GAGNTSEL04) <> TRIM(v_gagntsel05) THEN
        b_isNoError2                    := FALSE;
        n_gagnstel04                    := 0;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQWJ'; --- NEED TO CHANGE
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL04';
        t_errormsg2(n_errorCount2)      := o_errortext('RQWJ'); -- Need to change
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL04;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      IF n_gagnstel04                    = 1 THEN
        IF TRIM(obj_billing2.GAGNTSEL04) = TRIM(v_gagntsel01) THEN
          n_wsaasplitc04                := n_splitc01;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL04) = TRIM(v_gagntsel02) THEN
          n_wsaasplitc04                := n_splitc02;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL04) = TRIM(v_gagntsel03) THEN
          n_wsaasplitc04                := n_splitc03;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL04) = TRIM(v_gagntsel04) THEN
          n_wsaasplitc04                := n_splitc04;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL04) = TRIM(v_gagntsel05) THEN
          n_wsaasplitc04                := n_splitc05;
        END IF;
      END IF;
      IF TRIM(obj_billing2.GAGNTSEL05)  <> TRIM(v_gagntsel01) AND TRIM(obj_billing2.GAGNTSEL05) <> TRIM(v_gagntsel02) AND TRIM(obj_billing2.GAGNTSEL05) <> TRIM(v_gagntsel03) AND TRIM(obj_billing2.GAGNTSEL05) <> TRIM(v_gagntsel04) AND TRIM(obj_billing2.GAGNTSEL05) <> TRIM(v_gagntsel05) THEN
        b_isNoError2                    := FALSE;
        n_gagnstel05                    := 0;
        b_globalError                   := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQWJ'; --- NEED TO CHANGE
        t_errorfield2(n_errorCount2)    := 'GAGNTSEL05';
        t_errormsg2(n_errorCount2)      := o_errortext('RQWJ'); -- Need to change
        t_errorfieldval2(n_errorCount2) := obj_billing2.GAGNTSEL05;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      IF n_gagnstel05                    = 1 THEN
        IF TRIM(obj_billing2.GAGNTSEL05) = TRIM(v_gagntsel01) THEN
          n_wsaasplitc05                := n_splitc01;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL05) = TRIM(v_gagntsel02) THEN
          n_wsaasplitc05                := n_splitc02;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL05) = TRIM(v_gagntsel03) THEN
          n_wsaasplitc05                := n_splitc03;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL05) = TRIM(v_gagntsel04) THEN
          n_wsaasplitc05                := n_splitc04;
        END IF;
        IF TRIM(obj_billing2.GAGNTSEL05) = TRIM(v_gagntsel05) THEN
          n_wsaasplitc05                := n_splitc05;
        END IF;
      END IF;
    END IF;
    ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGBILL2---
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
      CONTINUE again_start2;

    END IF;
    IF b_isNoError               = TRUE THEN
      i_zdoe_info2.i_indic      := C_SUCCESS;
      i_zdoe_info2.i_errormsg01 := C_RECORDSUCCESS;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2);
    END IF;
    IF b_isNoError2 = TRUE AND i_zprvaldYN = 'N' THEN
      ----------------- Get IG Bill Number  ------------------------------
      --          For idx_billno IN billnolist.first .. billnolist.last
      --          LOOP
      --              IF TRIM(obj_billing2.TRREFNUM) = billnolist(idx_billno).t_zentity
      --              AND TRIM(obj_billing2.chdrnum) = billnolist(idx_billno).t_chdrnum THEN
      --                 n_billno := billnolist(idx_billno).t_zigvalue;
      --              END IF;
      --          END LOOP;
      n_billno := obj_billing2.ZIGVALUE;
      --------------------- IG Table GBIDPF Values -------------------------------
      obj_gbidpf.CHDRCOY := i_company;
      --obj_gbidpf.BILLNO     := n_billno;
      obj_gbidpf.BILLNO     := obj_billing2.ZIGVALUE;
      obj_gbidpf.PRODTYP    := obj_billing2.PRODTYP;
      obj_gbidpf.PLANNO     := o_defaultvalues('PLANNO');
      obj_gbidpf.CLASSINS   := '  ';
      obj_gbidpf.BPREM      := obj_billing2.BPREM;
      obj_gbidpf.BEXTPRM    := '0';
      obj_gbidpf.BCOMM      := '0';
      obj_gbidpf.BOVCOMM01  := '0';
      obj_gbidpf.BOVCOMM02  := '0';
      obj_gbidpf.DISCRATE   := '0';
      obj_gbidpf.DISCAMT    := '0';
      obj_gbidpf.BATCCOY    := i_company;
      obj_gbidpf.BATCBRN    := i_branch;
      obj_gbidpf.BATCACTYR  := i_acctYear;
      obj_gbidpf.BATCACTMN  := i_acctMonth;
      obj_gbidpf.BATCTRCDE  := i_transCode;
      obj_gbidpf.BATCBATCH  := ' ';
      --obj_gbidpf.TERMID     := i_vrcmTermid; --- BL5
      obj_gbidpf.TERMID     := 'QPAD'; --- BL5
      obj_gbidpf.TRDT       := n_trdt;
      obj_gbidpf.TRTM       := i_vrcmtime;
      obj_gbidpf.TRANNO     := obj_billing2.TRREFNUM;
      obj_gbidpf.FEES       := '0';
      obj_gbidpf.VALIDFLAG  := o_defaultvalues('VALIDFLAG');
      obj_gbidpf.USRPRF     := i_usrprf;
      obj_gbidpf.JOBNM      := i_scheduleName;
      obj_gbidpf.DATIME     := CAST(sysdate AS TIMESTAMP);
      obj_gbidpf.WKLADM     := '0';
      obj_gbidpf.DISCAMT1   := '0';
      obj_gbidpf.DISCAMT2   := '0';
      obj_gbidpf.DISCRATE1  := '0';
      obj_gbidpf.DISCRATE2  := '0';
      obj_gbidpf.RIBFEE     := '0';
      obj_gbidpf.RIBFGST    := '0';
      --obj_gbidpf.USER_T     := i_vrcmuser; --- BL5
      obj_gbidpf.USER_T     := 36; --- BL5
      obj_gbidpf.ZCTAXAMT01 := '0';
      obj_gbidpf.ZCTAXAMT02 := '0';
      obj_gbidpf.ZCTAXAMT03 := '0';
      obj_gbidpf.BADVRFUND  := 0; --- BL5
      --------------------- Insert GBIDPF values in obj_gbidpf ----------------------------
      --gbidpfindex := gbidpfindex + 1;
      --gbidpf_list.extend;
      --gbidpf_list(gbidpfindex) := obj_gbidpf;
      INSERT
      INTO GBIDPF VALUES obj_gbidpf;
 -------------------- IG Table GPMDPF Values --------------------------
      obj_gpmdpf.CHDRCOY    := i_company;
      obj_gpmdpf.CHDRNUM    := obj_billing2.CHDRNUM;
      obj_gpmdpf.PRODTYP    := obj_billing2.PRODTYP;
      obj_gpmdpf.HEADCNTIND := o_defaultvalues('HEADCNTIND');
      obj_gpmdpf.MBRNO      := o_defaultvalues('MBRNO');
      obj_gpmdpf.DPNTNO     := o_defaultvalues('DPNTNO');
      obj_gpmdpf.TRANNO     := obj_billing2.TRREFNUM;
      obj_gpmdpf.RECNO      := o_defaultvalues('RECNO');
      obj_gpmdpf.PLANNO     := o_defaultvalues('PLANNO');
      obj_gpmdpf.SUBSCOY    := ' ';
      obj_gpmdpf.SUBSNUM    := ' ';
      obj_gpmdpf.BILLTYP    := o_defaultvalues('BILLTYP');
      obj_gpmdpf.BILLNO     := n_billno;
      --obj_gpmdpf.EFFDATE    := i_prbilfdt; --- BL5
      obj_gpmdpf.EFFDATE    := obj_billing2.PRBILFDT; --- BL5
      obj_gpmdpf.PPREM      := obj_billing2.BPREM;
      obj_gpmdpf.PEMXTPRM   := '0';
      obj_gpmdpf.POAXTPRM   := '0';
      obj_gpmdpf.INSTNO     := obj_billing2.TRREFNUM;
      --obj_gpmdpf.PRMFRDT    := i_prbilfdt; --- BL5
      obj_gpmdpf.PRMFRDT    := obj_billing2.PRBILFDT; --- BL5
      --obj_gpmdpf.PRMTODT    := i_prbiltdt; --- BL5
      obj_gpmdpf.PRMTODT    := obj_billing2.PRBILTDT; --- BL5
      obj_gpmdpf.PNIND      := o_defaultvalues('PNIND');
      obj_gpmdpf.MMIND      := o_defaultvalues('MMIND');
      obj_gpmdpf.SRCDATA    := o_defaultvalues('SRCDATA');
      obj_gpmdpf.BATCCOY    := i_company;
      obj_gpmdpf.BATCBRN    := i_branch;
      obj_gpmdpf.BATCACTYR  := i_acctYear;
      obj_gpmdpf.BATCACTMN  := i_acctMonth;
      obj_gpmdpf.BATCTRCD   := i_transCode;
      obj_gpmdpf.BATCBATCH  := ' ';
      obj_gpmdpf.RECTYPE    := o_defaultvalues('RECTYPE');
      obj_gpmdpf.JOBNOUD    := '0';
      obj_gpmdpf.FLATFEE    := '0';
      obj_gpmdpf.FEES       := '0';
      obj_gpmdpf.EVNTFEE    := '0';
      obj_gpmdpf.MFJOBNO    := '0';
      obj_gpmdpf.JOBNOISS   := i_scheduleNumber;
      obj_gpmdpf.BBJOBNO    := '0';
      obj_gpmdpf.JOBNOTPA   := '0';
      obj_gpmdpf.USRPRF     := i_usrprf;
      obj_gpmdpf.JOBNM      := i_scheduleName;
      obj_gpmdpf.DATIME     := CAST(sysdate AS TIMESTAMP);
      select SEQ_GPMDPF.nextval into v_gpmdun from dual;
      obj_gpmdpf.UNIQUE_NUMBER := v_gpmdun;
      --------------------- Insert GBIDPF values in obj_gbidpf ----------------------------
      --gpmdpfindex := gpmdpfindex + 1;
      --gpmdpf_list.extend;
      --gpmdpf_list(gpmdpfindex) := obj_gpmdpf;
      INSERT
      INTO GPMDPF VALUES obj_gpmdpf;

-------------------BL9: START------------------------------------------------------------------------

  -------------------- IG Table ZMPCPF Values START--------------------------

    IF (obj_billing1.ZPDATATXFLG = 'Y') THEN    
             IF ((TRIM(v_prv_refnum) IS NULL) AND (TRIM(v_prv_policy) IS NULL) ) THEN

              v_prv_refnum  := obj_billing2.TRREFNUM;
              v_prv_policy :=obj_billing2.CHDRNUM; 

                           obj_zmpcpf.CHDRCOY    := i_company;
                           obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
                           obj_zmpcpf.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
                           obj_zmpcpf.USRPRF := i_usrprf;
                           obj_zmpcpf.JOBNM  := i_scheduleName;
                           obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
                           obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP');
                           obj_zmpcpf.EXTRFLAG := 'T';
                           obj_zmpcpf.ENTITY := obj_billing2.CHDRNUM;
                           obj_zmpcpf.KEY := obj_billing2.TRREFNUM; -- instb
                           obj_zmpcpf.STATUSTYP := ' ';
                           obj_zmpcpf.ZCTAXRAT   := o_defaultvalues('ZCTAXRAT');

              END IF;


	        IF ((TRIM(v_prv_refnum) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum) IS NOT NULL) AND (TRIM(v_prv_policy) IS NOT NULL)) THEN


                           obj_zmpcpf.GPST01     := v_temp_GPST01 ;
                           obj_zmpcpf.GPST02     := v_temp_GPST02 ;
                           obj_zmpcpf.ZCOLLFEE01 := v_temp_GPST01* v_zcolrate / 100;---obj_billing2.BPREM * v_zcolrate / 100;
                           obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01);
                           obj_zmpcpf.ZCTAXAMT   := ROUND(v_collfee01 - obj_zmpcpf.ZCOLLFEE02);   -- BL6
                           obj_zmpcpf.MCOLFEE := ROUND(obj_zmpcpf.ZCOLLFEE01);
                           obj_zmpcpf.MCOLFCTAX := obj_zmpcpf.ZCTAXAMT;
                           INSERT INTO ZMPCPF VALUES obj_zmpcpf;

                    END IF;

             v_prv_refnum  := obj_billing2.TRREFNUM;
             v_prv_policy :=obj_billing2.CHDRNUM; 



           obj_zmpcpf.GPST01     := v_temp_GPST01 ;
           obj_zmpcpf.GPST02     := v_temp_GPST02 ;
           obj_zmpcpf.ZCTAXRAT   := o_defaultvalues('ZCTAXRAT');

          obj_zmpcpf.CHDRCOY    := i_company;
          obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
          obj_zmpcpf.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
          obj_zmpcpf.USRPRF := i_usrprf;
          obj_zmpcpf.JOBNM  := i_scheduleName;
          obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
          obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP');
          obj_zmpcpf.EXTRFLAG := 'T';
          obj_zmpcpf.ENTITY := obj_billing2.CHDRNUM;
          obj_zmpcpf.KEY := obj_billing2.TRREFNUM; -- instb
          obj_zmpcpf.STATUSTYP := ' ';
          v_temp_GPST01     := 0;
          v_temp_GPST02     := 0; 
          v_collfee01       := 0;  
        END IF;        

                IF  ((TRIM(v_prv_refnum) IS NOT NULL) AND  (trim(v_prv_refnum) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy) = TRIM(obj_billing2.CHDRNUM)))  THEN


                   v_temp_GPST01     := v_temp_GPST01 + obj_billing2.BPREM;
                   v_temp_GPST02     := v_temp_GPST02 + ROUND(obj_billing2.BPREM);
                   v_collfee01       :=v_collfee01 + obj_billing2.ZCOLLFEE01; --- zcollfee01;

                END IF;

  END IF;                  
     -------------------- IG Table ZMPCPF Values END--------------------------      
-------------------BL9: END--------------------------------------------------------------------------



-------------------BL9: START------------------------------------------------------------------------
      -------------------- IG Table ZMPCPF Values --------------------------
	    -------------------- IG Table ZMPCPF Values --------------------------
--    --IF obj_billing2.ZPDATATXFLG = 'Y' THEN ----- BL8
--      obj_zmpcpf.CHDRCOY    := i_company;
--      --obj_zmpcpf.CHDRNUM    := obj_billing2.CHDRNUM; ----- BL8
--      obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
--      obj_zmpcpf.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
--      --obj_zmpcpf.MBRNO      := o_defaultvalues('MBRNO'); ----- BL8
----      obj_zmpcpf.PRODTYP    := obj_billing2.PRODTYP;----- BL8
----      obj_zmpcpf.TRANNO     := o_defaultvalues('TRANNO');----- BL8
----      obj_zmpcpf.RECNO      := o_defaultvalues('RECNO');----- BL8
----      obj_zmpcpf.BILLNO     := n_billno;----- BL8
----      obj_zmpcpf.DPNTNO     := o_defaultvalues('DPNTNO');----- BL8
--      obj_zmpcpf.GPST01     := obj_billing2.BPREM;
--      obj_zmpcpf.GPST02     := ROUND(obj_billing2.BPREM);
--      obj_zmpcpf.ZCOLLFEE01 := obj_billing2.BPREM * v_zcolrate / 100;
--      obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01);
--      obj_zmpcpf.ZCTAXRAT   := o_defaultvalues('ZCTAXRAT');
--      --obj_zmpcpf.ZCTAXAMT   := ROUND((obj_billing2.ZCOLLFEE01 -                  -- BL6
--      --obj_billing2.ZCOLLFEE01                                 / 1.08));          -- BL6
--      obj_zmpcpf.ZCTAXAMT   := ROUND(obj_billing2.ZCOLLFEE01 - obj_zmpcpf.ZCOLLFEE02);   -- BL6
--      obj_zmpcpf.USRPRF := i_usrprf;
--      obj_zmpcpf.JOBNM  := i_scheduleName;
--      obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
--      ---SIT BUG FIX
--      obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP');
--      --obj_zmpcpf.RECTYPE  := o_defaultvalues('RECTYPE'); ----- BL8
--
--      ---------------BL8: Start--------------------
--      obj_zmpcpf.EXTRFLAG := 'T';
--      obj_zmpcpf.ENTITY := obj_billing2.CHDRNUM;
--      obj_zmpcpf.KEY := obj_billing2.TRREFNUM;
--      obj_zmpcpf.STATUSTYP := ' ';
--      obj_zmpcpf.MCOLFEE := ROUND(obj_zmpcpf.ZCOLLFEE01);
--      obj_zmpcpf.MCOLFCTAX := ROUND(obj_billing2.ZCOLLFEE01 - obj_zmpcpf.ZCOLLFEE02);
--      ---------------BL8: End--------------------
--      --------------------- Insert ZMPCPF values in obj_gbidpf ----------------------------
--      --zmpcpfindex := zmpcpfindex ;
--      --zmpcpf_list.extend;
--      --zmpcpf_list(zmpcpfindex) := obj_zmpcpf;
--
--      --t_billno := obj_billing2.ZIGVALUE;
--INSERT INTO ZMPCPF VALUES obj_zmpcpf;
-------------------BL9: END--------------------------------------------------------------------------

--    END IF;
      -------------------- IG Table ZPCMPF Values --------------------------

--      IF n_gagnstel01            = 1 THEN
--        obj_zpcmpf01.CHDRCOY    := i_company;
--        ------------- BL8: Start----------------------
--        --obj_zpcmpf01.CHDRNUM    := obj_billing2.CHDRNUM;
--        obj_zpcmpf01.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
--       -- obj_zpcmpf01.PRODTYP    := obj_billing2.PRODTYP;
--        --obj_zpcmpf01.ZAGPTNUM   := v_zagptnum;
--        --obj_zpcmpf01.HEADCNTIND := o_defaultvalues('HEADCNTIND');
--        --obj_zpcmpf01.MBRNO      := o_defaultvalues('MBRNO');
--        --obj_zpcmpf01.DPNTNO     := o_defaultvalues('DPNTNO');
--        --obj_zpcmpf01.BILLNO     := n_billno;
--        -------------------BL8: End------------------------
--        obj_zpcmpf01.GPST       := obj_billing2.BPREM;
--        obj_zpcmpf01.GAGNTSEL   := obj_billing2.GAGNTSEL01;
--        obj_zpcmpf01.ZINSTYPE   := o_defaultvalues('ZINSTYP');
--        obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
--        obj_zpcmpf01.CMRATE     := obj_billing2.CMRATE01;
--        IF (obj_billing2.COMMN01 < 0) THEN
--          obj_zpcmpf01.COMMN    := ROUND((ABS(obj_billing2.COMMN01) / 1.08) * -1); -- ?Logic
--        ELSE
--          obj_zpcmpf01.COMMN := ROUND((ABS(obj_billing2.COMMN01) / 1.08)); -- ?Logic
--        END IF;
--        obj_zpcmpf01.BATCPFX   := o_defaultvalues('BATCPFX');
--        obj_zpcmpf01.BATCCOY   := i_company;
--        obj_zpcmpf01.BATCBRN   := i_branch;
--        obj_zpcmpf01.BATCACTYR := i_acctYear;
--        obj_zpcmpf01.BATCACTMN := i_acctMonth;
--        obj_zpcmpf01.BATCTRCD  := i_transCode;
--        obj_zpcmpf01.BATCBATCH := ' ';
--        obj_zpcmpf01.USRPRF    := i_usrprf;
--        obj_zpcmpf01.JOBNM     := i_scheduleName;
--        obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
--        --obj_zpcmpf01.RECNO     := o_defaultvalues('RECNO');----- BL8
--        --obj_zpcmpf01.RECTYPE   := o_defaultvalues('RECTYPE');----- BL8
--        obj_zpcmpf01.ZAGTGPRM  := obj_billing2.ZAGTGPRM01;
--        obj_zpcmpf01.ZAGTRPRM  := ROUND(obj_billing2.ZAGTGPRM01);
--        obj_zpcmpf01.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
--        obj_zpcmpf01.ZCTAXAMT  := ROUND(obj_billing2.COMMN01 -
--        obj_zpcmpf01.COMMN);
--        --obj_zpcmpf01.TRANNO := o_defaultvalues('TRANNO');----- BL8
--        --------------------- Insert ZPCMPF01 values in obj_gbidpf ----------------------------
--        --zpcmpfindex01 := zpcmpfindex01 + 1;
--        --zpcmpf_list01.extend;
--        --zpcmpf_list01(zpcmpfindex01) := obj_zpcmpf01;
--        
--        -------------------BL9: START------------------------------------------------------------------------
--        obj_zpcmpf01.EXTRFLAG   := 'T';
--        obj_zpcmpf01.ENTITY   := obj_billing2.CHDRNUM;
--        obj_zpcmpf01.KEY   := obj_billing2.TRREFNUM;
--        obj_zpcmpf01.STATUSTYP := ' ';
--        obj_zpcmpf01.MCOMMN := obj_zpcmpf01.COMMN;
--        obj_zpcmpf01.MCOMCTAX  := obj_zpcmpf01.ZCTAXAMT;
--        obj_zpcmpf01.NOCOMNFLG := 'N';
--        obj_zpcmpf01.MTOTPREM  := obj_billing2.BPREM;
--        -------------------BL9: END--------------------------------------------------------------------------        
--        INSERT
--        INTO ZPCMPF VALUES obj_zpcmpf01;
--      END IF;    


  -------------------- IG Table ZPCMPF insert Values --------------------------
  -------------------BL9: START------------------------------------------------------------------------
IF (obj_billing1.ZPDATATXFLG = 'Y') THEN 
      IF n_gagnstel01            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_billing2.TRREFNUM;
              v_prv_policy_z :=obj_billing2.CHDRNUM; 


              obj_zpcmpf01.CHDRCOY    := i_company;
              obj_zpcmpf01.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf01.GAGNTSEL   := obj_billing2.GAGNTSEL01;
              obj_zpcmpf01.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
              obj_zpcmpf01.CMRATE     := obj_billing2.CMRATE01;    
              obj_zpcmpf01.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf01.BATCCOY   := i_company;
              obj_zpcmpf01.BATCBRN   := i_branch;
              obj_zpcmpf01.BATCACTYR := i_acctYear;
              obj_zpcmpf01.BATCACTMN := i_acctMonth;
              obj_zpcmpf01.BATCTRCD  := i_transCode;
              obj_zpcmpf01.BATCBATCH := ' ';
              obj_zpcmpf01.USRPRF    := i_usrprf;
              obj_zpcmpf01.JOBNM     := i_scheduleName;
              obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf01.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf01.EXTRFLAG   := 'T';
              obj_zpcmpf01.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf01.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf01.STATUSTYP := ' ';
              obj_zpcmpf01.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf01.GPST      := v_temp_GPST ;     
                    obj_zpcmpf01.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf01.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf01.ZAGTRPRM  := v_temp_ZAGTGPRM02;

                    obj_zpcmpf01.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf01.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf01.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf01.MCOMCTAX  := obj_zpcmpf01.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf01;

                    END IF;

             v_prv_refnum_z  := obj_billing2.TRREFNUM;
             v_prv_policy_z  :=obj_billing2.CHDRNUM; 

              obj_zpcmpf01.CHDRCOY    := i_company;
              obj_zpcmpf01.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf01.GAGNTSEL   := obj_billing2.GAGNTSEL01;
              obj_zpcmpf01.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
              obj_zpcmpf01.CMRATE     := obj_billing2.CMRATE01;    
              obj_zpcmpf01.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf01.BATCCOY   := i_company;
              obj_zpcmpf01.BATCBRN   := i_branch;
              obj_zpcmpf01.BATCACTYR := i_acctYear;
              obj_zpcmpf01.BATCACTMN := i_acctMonth;
              obj_zpcmpf01.BATCTRCD  := i_transCode;
              obj_zpcmpf01.BATCBATCH := ' ';
              obj_zpcmpf01.USRPRF    := i_usrprf;
              obj_zpcmpf01.JOBNM     := i_scheduleName;
              obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf01.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf01.EXTRFLAG   := 'T';
              obj_zpcmpf01.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf01.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf01.STATUSTYP := ' ';
              obj_zpcmpf01.NOCOMNFLG := 'N';

              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_billing2.CHDRNUM)))  THEN



                                   IF (obj_billing2.COMMN01 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN01) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN01) / 1.08)); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_billing2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_billing2.COMMN01;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_billing2.ZAGTGPRM01;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_billing2.ZAGTGPRM01);           

                END IF;


      END IF;
      -------------------BL9: END--------------------------------------------------------------------------  


--      IF n_gagnstel02            = 1 THEN
--        obj_zpcmpf02.CHDRCOY    := i_company;
--        ------------- BL8: Start----------------------
----        obj_zpcmpf02.CHDRNUM    := obj_billing2.CHDRNUM;
--        obj_zpcmpf02.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
----        obj_zpcmpf02.PRODTYP    := obj_billing2.PRODTYP;
----        obj_zpcmpf02.ZAGPTNUM   := v_zagptnum;
----        obj_zpcmpf02.HEADCNTIND := o_defaultvalues('HEADCNTIND');
----        obj_zpcmpf02.MBRNO      := o_defaultvalues('MBRNO');
----        obj_zpcmpf02.DPNTNO     := o_defaultvalues('DPNTNO');
----        obj_zpcmpf02.BILLNO     := n_billno;
--        ------------- BL8: End----------------------
--        obj_zpcmpf02.GPST       := obj_billing2.BPREM;
--        obj_zpcmpf02.GAGNTSEL   := obj_billing2.GAGNTSEL02;
--        obj_zpcmpf02.ZINSTYPE   := o_defaultvalues('ZINSTYP');
--        obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
--        obj_zpcmpf02.CMRATE     := obj_billing2.CMRATE02;
--        IF (obj_billing2.COMMN02 < 0) THEN
--          obj_zpcmpf02.COMMN    := ROUND((ABS(obj_billing2.COMMN02) / 1.08) * -1); -- ?Logic
--        ELSE
--          obj_zpcmpf02.COMMN := ROUND((ABS(obj_billing2.COMMN02) / 1.08)); -- ?Logic
--        END IF;
--        obj_zpcmpf02.BATCPFX   := o_defaultvalues('BATCPFX');
--        obj_zpcmpf02.BATCCOY   := i_company;
--        obj_zpcmpf02.BATCBRN   := i_branch;
--        obj_zpcmpf02.BATCACTYR := i_acctYear;
--        obj_zpcmpf02.BATCACTMN := i_acctMonth;
--        obj_zpcmpf02.BATCTRCD  := i_transCode;
--        obj_zpcmpf02.BATCBATCH := ' ';
--        obj_zpcmpf02.USRPRF    := i_usrprf;
--        obj_zpcmpf02.JOBNM     := i_scheduleName;
--        obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
--        --obj_zpcmpf02.RECNO     := o_defaultvalues('RECNO');----- BL8
--        --obj_zpcmpf02.RECTYPE   := o_defaultvalues('RECTYPE');----- BL8
--        obj_zpcmpf02.ZAGTGPRM  := obj_billing2.ZAGTGPRM02;
--        obj_zpcmpf02.ZAGTRPRM  := ROUND(obj_billing2.ZAGTGPRM02);
--        obj_zpcmpf02.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
--        obj_zpcmpf02.ZCTAXAMT  := ROUND(obj_billing2.COMMN02 -
--        obj_zpcmpf02.COMMN);
--       -- obj_zpcmpf02.TRANNO := o_defaultvalues('TRANNO');----- BL8
--        --------------------- Insert ZPCMPF02 values in obj_gbidpf ----------------------------
--        --zpcmpfindex02 := zpcmpfindex02 + 1;
--        --zpcmpf_list02.extend;
--        --zpcmpf_list02(zpcmpfindex02) := obj_zpcmpf02;
--                
--        -------------------BL9: START------------------------------------------------------------------------
--        obj_zpcmpf02.EXTRFLAG   := 'T';
--        obj_zpcmpf02.ENTITY   := obj_billing2.CHDRNUM;
--        obj_zpcmpf02.KEY   := obj_billing2.TRREFNUM;
--        obj_zpcmpf02.STATUSTYP := ' ';
--        obj_zpcmpf02.MCOMMN := obj_zpcmpf02.COMMN;
--        obj_zpcmpf02.MCOMCTAX  := obj_zpcmpf02.ZCTAXAMT;
--        obj_zpcmpf02.NOCOMNFLG := 'N';
--        obj_zpcmpf02.MTOTPREM  := obj_billing2.BPREM;
--        -------------------BL9: END--------------------------------------------------------------------------    
--       
--        INSERT
--        INTO ZPCMPF VALUES obj_zpcmpf02;
--      END IF;

        -------------------BL9: START------------------------------------------------------------------------
      IF n_gagnstel02            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_billing2.TRREFNUM;
              v_prv_policy_z :=obj_billing2.CHDRNUM; 


              obj_zpcmpf02.CHDRCOY    := i_company;
              obj_zpcmpf02.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf02.GAGNTSEL   := obj_billing2.GAGNTSEL02;
              obj_zpcmpf02.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
              obj_zpcmpf02.CMRATE     := obj_billing2.CMRATE02;    
              obj_zpcmpf02.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf02.BATCCOY   := i_company;
              obj_zpcmpf02.BATCBRN   := i_branch;
              obj_zpcmpf02.BATCACTYR := i_acctYear;
              obj_zpcmpf02.BATCACTMN := i_acctMonth;
              obj_zpcmpf02.BATCTRCD  := i_transCode;
              obj_zpcmpf02.BATCBATCH := ' ';
              obj_zpcmpf02.USRPRF    := i_usrprf;
              obj_zpcmpf02.JOBNM     := i_scheduleName;
              obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf02.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf02.EXTRFLAG   := 'T';
              obj_zpcmpf02.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf02.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf02.STATUSTYP := ' ';
              obj_zpcmpf02.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf02.GPST      := v_temp_GPST ;     
                    obj_zpcmpf02.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf02.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf02.ZAGTRPRM  := v_temp_ZAGTGPRM02;

                    obj_zpcmpf02.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf02.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf02.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf02.MCOMCTAX  := obj_zpcmpf02.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf02;

                    END IF;

             v_prv_refnum_z  := obj_billing2.TRREFNUM;
             v_prv_policy_z  :=obj_billing2.CHDRNUM; 

              obj_zpcmpf02.CHDRCOY    := i_company;
              obj_zpcmpf02.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf02.GAGNTSEL   := obj_billing2.GAGNTSEL02;
              obj_zpcmpf02.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
              obj_zpcmpf02.CMRATE     := obj_billing2.CMRATE02;    
              obj_zpcmpf02.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf02.BATCCOY   := i_company;
              obj_zpcmpf02.BATCBRN   := i_branch;
              obj_zpcmpf02.BATCACTYR := i_acctYear;
              obj_zpcmpf02.BATCACTMN := i_acctMonth;
              obj_zpcmpf02.BATCTRCD  := i_transCode;
              obj_zpcmpf02.BATCBATCH := ' ';
              obj_zpcmpf02.USRPRF    := i_usrprf;
              obj_zpcmpf02.JOBNM     := i_scheduleName;
              obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf02.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf02.EXTRFLAG   := 'T';
              obj_zpcmpf02.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf02.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf02.STATUSTYP := ' ';
              obj_zpcmpf02.NOCOMNFLG := 'N';

              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_billing2.CHDRNUM)))  THEN



                                   IF (obj_billing2.COMMN02 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN02) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN02) / 1.08)); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_billing2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_billing2.COMMN02;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_billing2.ZAGTGPRM02;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_billing2.ZAGTGPRM02);           

                END IF;



      END IF;
      -------------------BL9: END--------------------------------------------------------------------------  

--      IF n_gagnstel03            = 1 THEN
--        obj_zpcmpf03.CHDRCOY    := i_company;
--        ------------- BL8: Start----------------------
----        obj_zpcmpf03.CHDRNUM    := obj_billing2.CHDRNUM;
--        obj_zpcmpf03.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
----        obj_zpcmpf03.PRODTYP    := obj_billing2.PRODTYP;
----        obj_zpcmpf03.ZAGPTNUM   := v_zagptnum;
----        obj_zpcmpf03.HEADCNTIND := o_defaultvalues('HEADCNTIND');
----        obj_zpcmpf03.MBRNO      := o_defaultvalues('MBRNO');
----        obj_zpcmpf03.DPNTNO     := o_defaultvalues('DPNTNO');
----        obj_zpcmpf03.BILLNO     := n_billno;
--        ------------- BL8: End----------------------
--        obj_zpcmpf03.GPST       := obj_billing2.BPREM;
--        obj_zpcmpf03.GAGNTSEL   := obj_billing2.GAGNTSEL03;
--        obj_zpcmpf03.ZINSTYPE   := o_defaultvalues('ZINSTYP');
--        obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
--        obj_zpcmpf03.CMRATE     := obj_billing2.CMRATE03;
--        IF (obj_billing2.COMMN03 < 0) THEN
--          obj_zpcmpf03.COMMN    := ROUND((ABS(obj_billing2.COMMN03) / 1.08) * -1); -- ?Logic
--        ELSE
--          obj_zpcmpf03.COMMN := ROUND((ABS(obj_billing2.COMMN03) / 1.08)); -- ?Logic
--        END IF;
--        obj_zpcmpf03.BATCPFX   := o_defaultvalues('BATCPFX');
--        obj_zpcmpf03.BATCCOY   := i_company;
--        obj_zpcmpf03.BATCBRN   := i_branch;
--        obj_zpcmpf03.BATCACTYR := i_acctYear;
--        obj_zpcmpf03.BATCACTMN := i_acctMonth;
--        obj_zpcmpf03.BATCTRCD  := i_transCode;
--        obj_zpcmpf03.BATCBATCH := ' ';
--        obj_zpcmpf03.USRPRF    := i_usrprf;
--        obj_zpcmpf03.JOBNM     := i_scheduleName;
--        obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
--        --obj_zpcmpf03.RECNO     := o_defaultvalues('RECNO');----- BL8
--        --obj_zpcmpf03.RECTYPE   := o_defaultvalues('RECTYPE');----- BL8
--        obj_zpcmpf03.ZAGTGPRM  := obj_billing2.ZAGTGPRM03;
--        obj_zpcmpf03.ZAGTRPRM  := ROUND(obj_billing2.ZAGTGPRM03);
--        obj_zpcmpf03.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
--        obj_zpcmpf03.ZCTAXAMT  := ROUND(obj_billing2.COMMN03 -
--        obj_zpcmpf03.COMMN);
--        --obj_zpcmpf03.TRANNO := o_defaultvalues('TRANNO');----- BL8
--        --------------------- Insert ZPCMPF03 values in obj_gbidpf ----------------------------
--        -- zpcmpfindex03 := zpcmpfindex03 + 1;
--        -- zpcmpf_list03.extend;
--        -- zpcmpf_list03(zpcmpfindex03) := obj_zpcmpf03;
--        -------------------BL9: START------------------------------------------------------------------------
--        obj_zpcmpf03.EXTRFLAG   := 'T';
--        obj_zpcmpf03.ENTITY   := obj_billing2.CHDRNUM;
--        obj_zpcmpf03.KEY   := obj_billing2.TRREFNUM;
--        obj_zpcmpf03.STATUSTYP := ' ';
--        obj_zpcmpf03.MCOMMN := obj_zpcmpf03.COMMN;
--        obj_zpcmpf03.MCOMCTAX  := obj_zpcmpf03.ZCTAXAMT;
--        obj_zpcmpf03.NOCOMNFLG := 'N';
--        obj_zpcmpf03.MTOTPREM  := obj_billing2.BPREM;
--        -------------------BL9: END--------------------------------------------------------------------------        
--        INSERT
--        INTO ZPCMPF VALUES obj_zpcmpf03;
--      END IF;
        -------------------BL9: START------------------------------------------------------------------------
      IF n_gagnstel03            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_billing2.TRREFNUM;
              v_prv_policy_z :=obj_billing2.CHDRNUM; 


              obj_zpcmpf03.CHDRCOY    := i_company;
              obj_zpcmpf03.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf03.GAGNTSEL   := obj_billing2.GAGNTSEL03;
              obj_zpcmpf03.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
              obj_zpcmpf03.CMRATE     := obj_billing2.CMRATE03;    
              obj_zpcmpf03.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf03.BATCCOY   := i_company;
              obj_zpcmpf03.BATCBRN   := i_branch;
              obj_zpcmpf03.BATCACTYR := i_acctYear;
              obj_zpcmpf03.BATCACTMN := i_acctMonth;
              obj_zpcmpf03.BATCTRCD  := i_transCode;
              obj_zpcmpf03.BATCBATCH := ' ';
              obj_zpcmpf03.USRPRF    := i_usrprf;
              obj_zpcmpf03.JOBNM     := i_scheduleName;
              obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf03.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf03.EXTRFLAG   := 'T';
              obj_zpcmpf03.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf03.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf03.STATUSTYP := ' ';
              obj_zpcmpf03.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf03.GPST      := v_temp_GPST ;     
                    obj_zpcmpf03.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf03.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf03.ZAGTRPRM  := v_temp_ZAGTGPRM02;

                    obj_zpcmpf03.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf03.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf03.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf03.MCOMCTAX  := obj_zpcmpf03.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf03;

                    END IF;

             v_prv_refnum_z  := obj_billing2.TRREFNUM;
             v_prv_policy_z  :=obj_billing2.CHDRNUM; 

              obj_zpcmpf03.CHDRCOY    := i_company;
              obj_zpcmpf03.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf03.GAGNTSEL   := obj_billing2.GAGNTSEL03;
              obj_zpcmpf03.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
              obj_zpcmpf03.CMRATE     := obj_billing2.CMRATE03;    
              obj_zpcmpf03.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf03.BATCCOY   := i_company;
              obj_zpcmpf03.BATCBRN   := i_branch;
              obj_zpcmpf03.BATCACTYR := i_acctYear;
              obj_zpcmpf03.BATCACTMN := i_acctMonth;
              obj_zpcmpf03.BATCTRCD  := i_transCode;
              obj_zpcmpf03.BATCBATCH := ' ';
              obj_zpcmpf03.USRPRF    := i_usrprf;
              obj_zpcmpf03.JOBNM     := i_scheduleName;
              obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf03.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf03.EXTRFLAG   := 'T';
              obj_zpcmpf03.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf03.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf03.STATUSTYP := ' ';
              obj_zpcmpf03.NOCOMNFLG := 'N';

              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_billing2.CHDRNUM)))  THEN



                                   IF (obj_billing2.COMMN03 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN03) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN03) / 1.08)); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_billing2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_billing2.COMMN03;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_billing2.ZAGTGPRM03;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_billing2.ZAGTGPRM03);           

                END IF;



      END IF;
      -------------------BL9: END--------------------------------------------------------------------------  


--      IF n_gagnstel04            = 1 THEN
--        obj_zpcmpf04.CHDRCOY    := i_company;
--        ------------- BL8: Start----------------------
----        obj_zpcmpf04.CHDRNUM    := obj_billing2.CHDRNUM;
--          obj_zpcmpf04.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
----        obj_zpcmpf04.PRODTYP    := obj_billing2.PRODTYP;
----        obj_zpcmpf04.ZAGPTNUM   := v_zagptnum;
----        obj_zpcmpf04.HEADCNTIND := o_defaultvalues('HEADCNTIND');
----        obj_zpcmpf04.MBRNO      := o_defaultvalues('MBRNO');
----        obj_zpcmpf04.DPNTNO     := o_defaultvalues('DPNTNO');
----        obj_zpcmpf04.BILLNO     := n_billno;
--        ------------- BL8: End----------------------
--        obj_zpcmpf04.GPST       := obj_billing2.BPREM;
--        obj_zpcmpf04.GAGNTSEL   := obj_billing2.GAGNTSEL04;
--        obj_zpcmpf04.ZINSTYPE   := o_defaultvalues('ZINSTYP');
--        obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
--        obj_zpcmpf04.CMRATE     := obj_billing2.CMRATE04;
--        IF (obj_billing2.COMMN04 < 0) THEN
--          obj_zpcmpf04.COMMN    := ROUND((ABS(obj_billing2.COMMN04) / 1.08) * -1); -- ?Logic
--        ELSE
--          obj_zpcmpf04.COMMN := ROUND((ABS(obj_billing2.COMMN04) / 1.08)); -- ?Logic
--        END IF;
--        obj_zpcmpf04.BATCPFX   := o_defaultvalues('BATCPFX');
--        obj_zpcmpf04.BATCCOY   := i_company;
--        obj_zpcmpf04.BATCBRN   := i_branch;
--        obj_zpcmpf04.BATCACTYR := i_acctYear;
--        obj_zpcmpf04.BATCACTMN := i_acctMonth;
--        obj_zpcmpf04.BATCTRCD  := i_transCode;
--        obj_zpcmpf04.BATCBATCH := ' ';
--        obj_zpcmpf04.USRPRF    := i_usrprf;
--        obj_zpcmpf04.JOBNM     := i_scheduleName;
--        obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
--        --obj_zpcmpf04.RECNO     := o_defaultvalues('RECNO');----- BL8
--        --obj_zpcmpf04.RECTYPE   := o_defaultvalues('RECTYPE');----- BL8
--        obj_zpcmpf04.ZAGTGPRM  := obj_billing2.ZAGTGPRM04;
--        obj_zpcmpf04.ZAGTRPRM  := ROUND(obj_billing2.ZAGTGPRM04);
--        obj_zpcmpf04.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
--        obj_zpcmpf04.ZCTAXAMT  := ROUND(obj_billing2.COMMN04 -
--        obj_zpcmpf04.COMMN);
--        --obj_zpcmpf04.TRANNO := o_defaultvalues('TRANNO');----- BL8
--        --------------------- Insert ZPCMPF04 values in obj_gbidpf ----------------------------
--        --  zpcmpfindex04 := zpcmpfindex04 + 1;
--        -- zpcmpf_list04.extend;
--        -- zpcmpf_list04(zpcmpfindex04) := obj_zpcmpf04;
---------------------BL9: START------------------------------------------------------------------------
--        obj_zpcmpf04.EXTRFLAG   := 'T';
--        obj_zpcmpf04.ENTITY   := obj_billing2.CHDRNUM;
--        obj_zpcmpf04.KEY   := obj_billing2.TRREFNUM;
--        obj_zpcmpf04.STATUSTYP := ' ';
--        obj_zpcmpf04.MCOMMN := obj_zpcmpf04.COMMN;
--        obj_zpcmpf04.MCOMCTAX  := obj_zpcmpf04.ZCTAXAMT;
--        obj_zpcmpf04.NOCOMNFLG := 'N';
--        obj_zpcmpf04.MTOTPREM  := obj_billing2.BPREM;
---------------------BL9: END--------------------------------------------------------------------------
--        INSERT
--        INTO ZPCMPF VALUES obj_zpcmpf04;
--      END IF;
        -------------------BL9: START------------------------------------------------------------------------
      IF n_gagnstel04            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_billing2.TRREFNUM;
              v_prv_policy_z :=obj_billing2.CHDRNUM;


              obj_zpcmpf04.CHDRCOY    := i_company;
              obj_zpcmpf04.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf04.GAGNTSEL   := obj_billing2.GAGNTSEL04;
              obj_zpcmpf04.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
              obj_zpcmpf04.CMRATE     := obj_billing2.CMRATE04;    
              obj_zpcmpf04.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf04.BATCCOY   := i_company;
              obj_zpcmpf04.BATCBRN   := i_branch;
              obj_zpcmpf04.BATCACTYR := i_acctYear;
              obj_zpcmpf04.BATCACTMN := i_acctMonth;
              obj_zpcmpf04.BATCTRCD  := i_transCode;
              obj_zpcmpf04.BATCBATCH := ' ';
              obj_zpcmpf04.USRPRF    := i_usrprf;
              obj_zpcmpf04.JOBNM     := i_scheduleName;
              obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf04.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf04.EXTRFLAG   := 'T';
              obj_zpcmpf04.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf04.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf04.STATUSTYP := ' ';
              obj_zpcmpf04.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf04.GPST      := v_temp_GPST ;     
                    obj_zpcmpf04.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf04.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf04.ZAGTRPRM  := v_temp_ZAGTGPRM02;

                    obj_zpcmpf04.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf04.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf04.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf04.MCOMCTAX  := obj_zpcmpf04.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf04;

                    END IF;

             v_prv_refnum_z  := obj_billing2.TRREFNUM;
             v_prv_policy_z  :=obj_billing2.CHDRNUM; 

              obj_zpcmpf04.CHDRCOY    := i_company;
              obj_zpcmpf04.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf04.GAGNTSEL   := obj_billing2.GAGNTSEL04;
              obj_zpcmpf04.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
              obj_zpcmpf04.CMRATE     := obj_billing2.CMRATE04;    
              obj_zpcmpf04.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf04.BATCCOY   := i_company;
              obj_zpcmpf04.BATCBRN   := i_branch;
              obj_zpcmpf04.BATCACTYR := i_acctYear;
              obj_zpcmpf04.BATCACTMN := i_acctMonth;
              obj_zpcmpf04.BATCTRCD  := i_transCode;
              obj_zpcmpf04.BATCBATCH := ' ';
              obj_zpcmpf04.USRPRF    := i_usrprf;
              obj_zpcmpf04.JOBNM     := i_scheduleName;
              obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf04.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf04.EXTRFLAG   := 'T';
              obj_zpcmpf04.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf04.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf04.STATUSTYP := ' ';
              obj_zpcmpf04.NOCOMNFLG := 'N';

              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0;
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_billing2.CHDRNUM)))  THEN



                                   IF (obj_billing2.COMMN04 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN04) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN04) / 1.08)); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_billing2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_billing2.COMMN04;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_billing2.ZAGTGPRM04;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_billing2.ZAGTGPRM04);           

                END IF;



      END IF;
      -------------------BL9: END--------------------------------------------------------------------------  

--      IF n_gagnstel05            = 1 THEN
--        obj_zpcmpf05.CHDRCOY    := i_company;
--         ------------- BL8: Start----------------------
----        obj_zpcmpf05.CHDRNUM    := obj_billing2.CHDRNUM;
--          obj_zpcmpf05.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
----        obj_zpcmpf05.PRODTYP    := obj_billing2.PRODTYP;
----        obj_zpcmpf05.ZAGPTNUM   := v_zagptnum;
----        obj_zpcmpf05.HEADCNTIND := o_defaultvalues('HEADCNTIND');
----        obj_zpcmpf05.MBRNO      := o_defaultvalues('MBRNO');
----        obj_zpcmpf05.DPNTNO     := o_defaultvalues('DPNTNO');
----        obj_zpcmpf05.BILLNO     := n_billno;
--         ------------- BL8: End----------------------
--        obj_zpcmpf05.GPST       := obj_billing2.BPREM;
--        obj_zpcmpf05.GAGNTSEL   := obj_billing2.GAGNTSEL05;
--        obj_zpcmpf05.ZINSTYPE   := o_defaultvalues('ZINSTYP');
--        obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
--        obj_zpcmpf05.CMRATE     := obj_billing2.CMRATE05;
--        --   obj_zpcmpf05.COMMN      := obj_billing2.COMMN05;
--        IF (obj_billing2.COMMN05 < 0) THEN
--          obj_zpcmpf05.COMMN    := ROUND((ABS(obj_billing2.COMMN05) / 1.08) * -1); -- ?Logic
--        ELSE
--          obj_zpcmpf05.COMMN := ROUND((ABS(obj_billing2.COMMN05) / 1.08)); -- ?Logic
--        END IF;
--        obj_zpcmpf05.BATCPFX   := o_defaultvalues('BATCPFX');
--        obj_zpcmpf05.BATCCOY   := i_company;
--        obj_zpcmpf05.BATCBRN   := i_branch;
--        obj_zpcmpf05.BATCACTYR := i_acctYear;
--        obj_zpcmpf05.BATCACTMN := i_acctMonth;
--        obj_zpcmpf05.BATCTRCD  := i_transCode;
--        obj_zpcmpf05.BATCBATCH := ' ';
--        obj_zpcmpf05.USRPRF    := i_usrprf;
--        obj_zpcmpf05.JOBNM     := i_scheduleName;
--        obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
--       -- obj_zpcmpf05.RECNO     := o_defaultvalues('RECNO');----- BL8
--        --obj_zpcmpf05.RECTYPE   := o_defaultvalues('RECTYPE');----- BL8
--        obj_zpcmpf05.ZAGTGPRM  := obj_billing2.ZAGTGPRM05;
--        obj_zpcmpf05.ZAGTRPRM  := ROUND(obj_billing2.ZAGTGPRM05);
--        obj_zpcmpf05.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
--        obj_zpcmpf05.ZCTAXAMT  := ROUND(obj_billing2.COMMN05 -
--        obj_zpcmpf05.COMMN);
--        --obj_zpcmpf05.TRANNO := o_defaultvalues('TRANNO');----- BL8
--        --------------------- Insert ZPCMPF05 values in obj_gbidpf ----------------------------
--       --     zpcmpfindex05 := zpcmpfindex05 + 1;
--        --   zpcmpf_list05.extend;
--        -- zpcmpf_list05(zpcmpfindex05) := obj_zpcmpf05;
--        
--        -------------------BL9: START------------------------------------------------------------------------
--        obj_zpcmpf05.EXTRFLAG   := 'T';
--        obj_zpcmpf05.ENTITY   := obj_billing2.CHDRNUM;
--        obj_zpcmpf05.KEY   := obj_billing2.TRREFNUM;
--        obj_zpcmpf05.STATUSTYP := ' ';
--        obj_zpcmpf05.MCOMMN := obj_zpcmpf05.COMMN;
--        obj_zpcmpf05.MCOMCTAX  := obj_zpcmpf05.ZCTAXAMT;
--        obj_zpcmpf05.NOCOMNFLG := 'N';
--        obj_zpcmpf05.MTOTPREM  := obj_billing2.BPREM;
--        -------------------BL9: END--------------------------------------------------------------------------
--        INSERT
--        INTO ZPCMPF VALUES obj_zpcmpf05;
--END IF;
        -------------------BL9: START------------------------------------------------------------------------
      IF n_gagnstel05            = 1 THEN

      IF ((TRIM(v_prv_refnum_z) IS NULL) AND (TRIM(v_prv_policy_z) IS NULL) ) THEN

              v_prv_refnum_z  := obj_billing2.TRREFNUM;
              v_prv_policy_z :=obj_billing2.CHDRNUM;


              obj_zpcmpf05.CHDRCOY    := i_company;
              obj_zpcmpf05.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf05.GAGNTSEL   := obj_billing2.GAGNTSEL05;
              obj_zpcmpf05.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
              obj_zpcmpf05.CMRATE     := obj_billing2.CMRATE05;    
              obj_zpcmpf05.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf05.BATCCOY   := i_company;
              obj_zpcmpf05.BATCBRN   := i_branch;
              obj_zpcmpf05.BATCACTYR := i_acctYear;
              obj_zpcmpf05.BATCACTMN := i_acctMonth;
              obj_zpcmpf05.BATCTRCD  := i_transCode;
              obj_zpcmpf05.BATCBATCH := ' ';
              obj_zpcmpf05.USRPRF    := i_usrprf;
              obj_zpcmpf05.JOBNM     := i_scheduleName;
              obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf05.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf05.EXTRFLAG   := 'T';
              obj_zpcmpf05.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf05.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf05.STATUSTYP := ' ';
              obj_zpcmpf05.NOCOMNFLG := 'N';


      END IF;


	        IF ((TRIM(v_prv_refnum_z) <> TRIM(obj_billing2.TRREFNUM)) OR (TRIM(v_prv_policy_z) <> TRIM(obj_billing2.CHDRNUM)))  THEN
                    IF ((TRIM(v_prv_refnum_z) IS NOT NULL) AND (TRIM(v_prv_policy_z) IS NOT NULL)) THEN

                    obj_zpcmpf05.GPST      := v_temp_GPST ;     
                    obj_zpcmpf05.COMMN     := v_temp_COMMN ;  


                    obj_zpcmpf05.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf05.ZAGTRPRM  := v_temp_ZAGTGPRM02;

                    obj_zpcmpf05.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf05.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf05.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf05.MCOMCTAX  := obj_zpcmpf05.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf05;

                    END IF;

             v_prv_refnum_z  := obj_billing2.TRREFNUM;
             v_prv_policy_z  :=obj_billing2.CHDRNUM; 

              obj_zpcmpf05.CHDRCOY    := i_company;
              obj_zpcmpf05.EFFDATE    := obj_billing2.PRBILFDT;
              obj_zpcmpf05.GAGNTSEL   := obj_billing2.GAGNTSEL05;
              obj_zpcmpf05.ZINSTYPE   := o_defaultvalues('ZINSTYP');
              obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
              obj_zpcmpf05.CMRATE     := obj_billing2.CMRATE05;    
              obj_zpcmpf05.BATCPFX   := o_defaultvalues('BATCPFX');
              obj_zpcmpf05.BATCCOY   := i_company;
              obj_zpcmpf05.BATCBRN   := i_branch;
              obj_zpcmpf05.BATCACTYR := i_acctYear;
              obj_zpcmpf05.BATCACTMN := i_acctMonth;
              obj_zpcmpf05.BATCTRCD  := i_transCode;
              obj_zpcmpf05.BATCBATCH := ' ';
              obj_zpcmpf05.USRPRF    := i_usrprf;
              obj_zpcmpf05.JOBNM     := i_scheduleName;
              obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
              obj_zpcmpf05.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
              obj_zpcmpf05.EXTRFLAG   := 'T';
              obj_zpcmpf05.ENTITY   := obj_billing2.CHDRNUM;
              obj_zpcmpf05.KEY   := obj_billing2.TRREFNUM;
              obj_zpcmpf05.STATUSTYP := ' ';
              obj_zpcmpf05.NOCOMNFLG := 'N';

              v_temp_GPST           := 0;
              v_temp_COMMN          := 0; 
              v_temp_COMMN_Stg      := 0;
              v_temp_ZAGTGPRM01     := 0;
              v_temp_ZAGTGPRM02     := 0; 
        END IF;        

                IF  ((TRIM(v_prv_refnum_z) IS NOT NULL) AND  (trim(v_prv_policy_z) IS NOT NULL) 
                AND  (TRIM(v_prv_refnum_z) = TRIM(obj_billing2.TRREFNUM)) AND  (TRIM(v_prv_policy_z) = TRIM(obj_billing2.CHDRNUM)))  THEN



                                   IF (obj_billing2.COMMN05 < 0) THEN
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN05) / 1.08) * -1); -- ?Logic
                                   ELSE
                                      v_temp_COMMN_Rnd    := ROUND((ABS(obj_billing2.COMMN05) / 1.08)); -- ?Logic
                                   END IF;

                    v_temp_GPST            := v_temp_GPST + obj_billing2.BPREM;
                    v_temp_COMMN           := v_temp_COMMN + v_temp_COMMN_Rnd;
                    v_temp_COMMN_Stg     := v_temp_COMMN_Stg + obj_billing2.COMMN05;--this the varialbe which has the exact value as in stage no ABS or ROunded value
                    v_temp_ZAGTGPRM01      := v_temp_ZAGTGPRM01 + obj_billing2.ZAGTGPRM05;
                    v_temp_ZAGTGPRM02      := v_temp_ZAGTGPRM02 + ROUND(obj_billing2.ZAGTGPRM05);           

                END IF;



      END IF;

END IF;      
      -------------------BL9: END--------------------------------------------------------------------------  
    END IF;
END LOOP;

---------------------------------BL9: START-----------------------------------------------------------------------------------------
  IF b_isNoError2 = TRUE AND i_zprvaldYN = 'N' THEN
-----------------------INSERTING THE ZMPCPF LAST RECORD START-----------------------------------------------------------------------
     IF (obj_billing1.ZPDATATXFLG = 'Y') THEN

                           obj_zmpcpf.CHDRCOY    := i_company;
                           obj_zmpcpf.ZAGPTNUM   := v_zagptnum;
                           obj_zmpcpf.EFFDATE    := obj_billing2.PRBILFDT; --- BL7
                           obj_zmpcpf.USRPRF := i_usrprf;
                           obj_zmpcpf.JOBNM  := i_scheduleName;
                           obj_zmpcpf.DATIME := CAST(sysdate AS TIMESTAMP);
                           obj_zmpcpf.ZINSTYPE := o_defaultvalues('ZINSTYP');
                           obj_zmpcpf.EXTRFLAG := 'T';
                           obj_zmpcpf.ENTITY := obj_billing2.CHDRNUM;
                           obj_zmpcpf.KEY := obj_billing2.TRREFNUM; -- instb
                           obj_zmpcpf.STATUSTYP := ' ';
                           obj_zmpcpf.GPST01     := v_temp_GPST01 ;
                           obj_zmpcpf.GPST02     := v_temp_GPST02 ;
                           obj_zmpcpf.ZCOLLFEE01 := v_temp_GPST01* v_zcolrate / 100;---obj_billing2.BPREM * v_zcolrate / 100;
                           obj_zmpcpf.ZCOLLFEE02 := ROUND(obj_zmpcpf.ZCOLLFEE01);
                           obj_zmpcpf.ZCTAXAMT   := ROUND(v_collfee01 - obj_zmpcpf.ZCOLLFEE02);   -- BL6
                           obj_zmpcpf.MCOLFEE := ROUND(obj_zmpcpf.ZCOLLFEE01);
                           obj_zmpcpf.MCOLFCTAX := obj_zmpcpf.ZCTAXAMT;
                           INSERT INTO ZMPCPF VALUES obj_zmpcpf;
 ---------------------INSERTING THE ZMPCPF LAST RECORD END---------------------------------------------------------------------------

 -----------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-1 START -----------------------------------------------------------------------
                IF n_gagnstel01            = 1 THEN
                    obj_zpcmpf01.CHDRCOY    := i_company;
                    obj_zpcmpf01.EFFDATE    := obj_billing2.PRBILFDT;
                    obj_zpcmpf01.GAGNTSEL   := obj_billing2.GAGNTSEL01;
                    obj_zpcmpf01.ZINSTYPE   := o_defaultvalues('ZINSTYP');
                    obj_zpcmpf01.SPLITC     := n_wsaasplitc01;
                    obj_zpcmpf01.CMRATE     := obj_billing2.CMRATE01;    
                    obj_zpcmpf01.BATCPFX   := o_defaultvalues('BATCPFX');
                    obj_zpcmpf01.BATCCOY   := i_company;
                    obj_zpcmpf01.BATCBRN   := i_branch;
                    obj_zpcmpf01.BATCACTYR := i_acctYear;
                    obj_zpcmpf01.BATCACTMN := i_acctMonth;
                    obj_zpcmpf01.BATCTRCD  := i_transCode;
                    obj_zpcmpf01.BATCBATCH := ' ';
                    obj_zpcmpf01.USRPRF    := i_usrprf;
                    obj_zpcmpf01.JOBNM     := i_scheduleName;
                    obj_zpcmpf01.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf01.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
                    obj_zpcmpf01.EXTRFLAG   := 'T';
                    obj_zpcmpf01.ENTITY   := obj_billing2.CHDRNUM;
                    obj_zpcmpf01.KEY   := obj_billing2.TRREFNUM;
                    obj_zpcmpf01.STATUSTYP := ' ';
                    obj_zpcmpf01.NOCOMNFLG := 'N';
                    obj_zpcmpf01.GPST      := v_temp_GPST ;     
                    obj_zpcmpf01.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf01.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf01.ZAGTRPRM  := v_temp_ZAGTGPRM02;
                    obj_zpcmpf01.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf01.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf01.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf01.MCOMCTAX  := obj_zpcmpf01.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf01;
               END IF;           
       -----------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-1 END--------------------------------

       -------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-2 START -------------------------
                IF n_gagnstel02            = 1 THEN       
                    obj_zpcmpf02.CHDRCOY    := i_company;
                    obj_zpcmpf02.EFFDATE    := obj_billing2.PRBILFDT;
                    obj_zpcmpf02.GAGNTSEL   := obj_billing2.GAGNTSEL02;
                    obj_zpcmpf02.ZINSTYPE   := o_defaultvalues('ZINSTYP');
                    obj_zpcmpf02.SPLITC     := n_wsaasplitc02;
                    obj_zpcmpf02.CMRATE     := obj_billing2.CMRATE02;    
                    obj_zpcmpf02.BATCPFX   := o_defaultvalues('BATCPFX');
                    obj_zpcmpf02.BATCCOY   := i_company;
                    obj_zpcmpf02.BATCBRN   := i_branch;
                    obj_zpcmpf02.BATCACTYR := i_acctYear;
                    obj_zpcmpf02.BATCACTMN := i_acctMonth;
                    obj_zpcmpf02.BATCTRCD  := i_transCode;
                    obj_zpcmpf02.BATCBATCH := ' ';
                    obj_zpcmpf02.USRPRF    := i_usrprf;
                    obj_zpcmpf02.JOBNM     := i_scheduleName;
                    obj_zpcmpf02.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf02.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
                    obj_zpcmpf02.EXTRFLAG   := 'T';
                    obj_zpcmpf02.ENTITY   := obj_billing2.CHDRNUM;
                    obj_zpcmpf02.KEY   := obj_billing2.TRREFNUM;
                    obj_zpcmpf02.STATUSTYP := ' ';
                    obj_zpcmpf02.NOCOMNFLG := 'N';
                    obj_zpcmpf02.GPST      := v_temp_GPST ;     
                    obj_zpcmpf02.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf02.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf02.ZAGTRPRM  := v_temp_ZAGTGPRM02;
                    obj_zpcmpf02.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf02.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf02.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf02.MCOMCTAX  := obj_zpcmpf02.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf02;
               END IF;                             
     ----------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-2 END-----------------------------------------------

     ------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-3 START ------------------------------------
                IF n_gagnstel03            = 1 THEN     
                    obj_zpcmpf03.CHDRCOY    := i_company;
                    obj_zpcmpf03.EFFDATE    := obj_billing2.PRBILFDT;
                    obj_zpcmpf03.GAGNTSEL   := obj_billing2.GAGNTSEL03;
                    obj_zpcmpf03.ZINSTYPE   := o_defaultvalues('ZINSTYP');
                    obj_zpcmpf03.SPLITC     := n_wsaasplitc03;
                    obj_zpcmpf03.CMRATE     := obj_billing2.CMRATE03;    
                    obj_zpcmpf03.BATCPFX   := o_defaultvalues('BATCPFX');
                    obj_zpcmpf03.BATCCOY   := i_company;
                    obj_zpcmpf03.BATCBRN   := i_branch;
                    obj_zpcmpf03.BATCACTYR := i_acctYear;
                    obj_zpcmpf03.BATCACTMN := i_acctMonth;
                    obj_zpcmpf03.BATCTRCD  := i_transCode;
                    obj_zpcmpf03.BATCBATCH := ' ';
                    obj_zpcmpf03.USRPRF    := i_usrprf;
                    obj_zpcmpf03.JOBNM     := i_scheduleName;
                    obj_zpcmpf03.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf03.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
                    obj_zpcmpf03.EXTRFLAG   := 'T';
                    obj_zpcmpf03.ENTITY   := obj_billing2.CHDRNUM;
                    obj_zpcmpf03.KEY   := obj_billing2.TRREFNUM;
                    obj_zpcmpf03.STATUSTYP := ' ';
                    obj_zpcmpf03.NOCOMNFLG := 'N';
                    obj_zpcmpf03.GPST      := v_temp_GPST ;     
                    obj_zpcmpf03.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf03.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf03.ZAGTRPRM  := v_temp_ZAGTGPRM02;
                    obj_zpcmpf03.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf03.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf03.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf03.MCOMCTAX  := obj_zpcmpf03.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf03;
               END IF;   						  
       --------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-3 END----------------------------------------

       ------------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-4 START ---------------------------
                IF n_gagnstel04            = 1 THEN       
                    obj_zpcmpf04.CHDRCOY    := i_company;
                    obj_zpcmpf04.EFFDATE    := obj_billing2.PRBILFDT;
                    obj_zpcmpf04.GAGNTSEL   := obj_billing2.GAGNTSEL04;
                    obj_zpcmpf04.ZINSTYPE   := o_defaultvalues('ZINSTYP');
                    obj_zpcmpf04.SPLITC     := n_wsaasplitc04;
                    obj_zpcmpf04.CMRATE     := obj_billing2.CMRATE04;    
                    obj_zpcmpf04.BATCPFX   := o_defaultvalues('BATCPFX');
                    obj_zpcmpf04.BATCCOY   := i_company;
                    obj_zpcmpf04.BATCBRN   := i_branch;
                    obj_zpcmpf04.BATCACTYR := i_acctYear;
                    obj_zpcmpf04.BATCACTMN := i_acctMonth;
                    obj_zpcmpf04.BATCTRCD  := i_transCode;
                    obj_zpcmpf04.BATCBATCH := ' ';
                    obj_zpcmpf04.USRPRF    := i_usrprf;
                    obj_zpcmpf04.JOBNM     := i_scheduleName;
                    obj_zpcmpf04.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf04.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
                    obj_zpcmpf04.EXTRFLAG   := 'T';
                    obj_zpcmpf04.ENTITY   := obj_billing2.CHDRNUM;
                    obj_zpcmpf04.KEY   := obj_billing2.TRREFNUM;
                    obj_zpcmpf04.STATUSTYP := ' ';
                    obj_zpcmpf04.NOCOMNFLG := 'N';
                    obj_zpcmpf04.GPST      := v_temp_GPST ;     
                    obj_zpcmpf04.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf04.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf04.ZAGTRPRM  := v_temp_ZAGTGPRM02;
                    obj_zpcmpf04.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf04.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf04.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf04.MCOMCTAX  := obj_zpcmpf04.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf04;
               END IF;                             
       ------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-4 END---------------------

       ----------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-5 START -------------
                IF n_gagnstel05            = 1 THEN       
                    obj_zpcmpf05.CHDRCOY    := i_company;
                    obj_zpcmpf05.EFFDATE    := obj_billing2.PRBILFDT;
                    obj_zpcmpf05.GAGNTSEL   := obj_billing2.GAGNTSEL05;
                    obj_zpcmpf05.ZINSTYPE   := o_defaultvalues('ZINSTYP');
                    obj_zpcmpf05.SPLITC     := n_wsaasplitc05;
                    obj_zpcmpf05.CMRATE     := obj_billing2.CMRATE05;    
                    obj_zpcmpf05.BATCPFX   := o_defaultvalues('BATCPFX');
                    obj_zpcmpf05.BATCCOY   := i_company;
                    obj_zpcmpf05.BATCBRN   := i_branch;
                    obj_zpcmpf05.BATCACTYR := i_acctYear;
                    obj_zpcmpf05.BATCACTMN := i_acctMonth;
                    obj_zpcmpf05.BATCTRCD  := i_transCode;
                    obj_zpcmpf05.BATCBATCH := ' ';
                    obj_zpcmpf05.USRPRF    := i_usrprf;
                    obj_zpcmpf05.JOBNM     := i_scheduleName;
                    obj_zpcmpf05.DATIME    := CAST(sysdate AS TIMESTAMP);
                    obj_zpcmpf05.ZCTAXRAT  := o_defaultvalues('ZCTAXRAT');
                    obj_zpcmpf05.EXTRFLAG   := 'T';
                    obj_zpcmpf05.ENTITY   := obj_billing2.CHDRNUM;
                    obj_zpcmpf05.KEY   := obj_billing2.TRREFNUM;
                    obj_zpcmpf05.STATUSTYP := ' ';
                    obj_zpcmpf05.NOCOMNFLG := 'N';
                    obj_zpcmpf05.GPST      := v_temp_GPST ;     
                    obj_zpcmpf05.COMMN     := v_temp_COMMN ;         
                    obj_zpcmpf05.ZAGTGPRM  := v_temp_ZAGTGPRM01;
                    obj_zpcmpf05.ZAGTRPRM  := v_temp_ZAGTGPRM02;
                    obj_zpcmpf05.ZCTAXAMT  := ROUND(v_temp_COMMN_Stg - v_temp_COMMN);
                    obj_zpcmpf05.MTOTPREM  := v_temp_GPST;
                    obj_zpcmpf05.MCOMMN    := v_temp_GPST;
                    obj_zpcmpf05.MCOMCTAX  := obj_zpcmpf05.ZCTAXAMT;

                          INSERT INTO ZPCMPF VALUES obj_zpcmpf05;
               END IF;                             
       ----------------INSERTING THE ZPCMPF LAST RECORD FOR AGENT-5 END-------------------
  END IF;     
 END IF;
 ---------------------------------BL9: END-----------------------------------------------------------------------------------------       
  dbms_output.put_line('Procedure execution time = ' || (dbms_utility.get_time - v_timestart) / 100);
  CLOSE c_billing1;
  CLOSE c_billing2;
END BQ9TK_BL01_BILLHIST;