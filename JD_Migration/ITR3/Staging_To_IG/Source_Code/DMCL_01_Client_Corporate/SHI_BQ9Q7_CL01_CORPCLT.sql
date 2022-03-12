create or replace PROCEDURE                        "BQ9Q7_CL01_CORPCLT" (scheduleName   IN VARCHAR2,
                                               scheduleNumber IN VARCHAR2,
                                               zprvaldYN      IN VARCHAR2,
                                               company        IN VARCHAR2,
                                               userProfile    IN VARCHAR2,
                                               i_branch       IN VARCHAR2,
                                               i_transCode    IN VARCHAR2,
                                               i_vrcmTermid   IN VARCHAR2) AS
/***************************************************************************************************
  * Amenment History: CL01 Corporate Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CC1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * MAY11	 RC		   CC2	 Data Verification Changes 
  *****************************************************************************************************/                                                 
  v_timestart NUMBER := dbms_utility.get_time;
  -- values from Staging DB
  refnum   TITDMGCLNTCORP.CLNTKEY@DMSTAGEDBLINK%type;
  lsurname TITDMGCLNTCORP.LSURNAME@DMSTAGEDBLINK%type;
  zkanasnm TITDMGCLNTCORP.ZKANASNM@DMSTAGEDBLINK%type;
  -- cltstat      STAGEDBUSR.TITDMGCLNTCORP.CLTSTAT%type;
  cltaddr01  TITDMGCLNTCORP.CLTADDR01@DMSTAGEDBLINK%type;
  cltaddr02  TITDMGCLNTCORP.CLTADDR02@DMSTAGEDBLINK%type;
  cltaddr03  TITDMGCLNTCORP.CLTADDR03@DMSTAGEDBLINK%type;
  cltaddr04  TITDMGCLNTCORP.CLTADDR04@DMSTAGEDBLINK%type;
  zkanaddr01 TITDMGCLNTCORP.ZKANADDR01@DMSTAGEDBLINK%type;
  zkanaddr02 TITDMGCLNTCORP.ZKANADDR02@DMSTAGEDBLINK%type;
  zkanaddr03 TITDMGCLNTCORP.ZKANADDR03@DMSTAGEDBLINK%type;
  zkanaddr04 TITDMGCLNTCORP.ZKANADDR04@DMSTAGEDBLINK%type;
  cltpcode   TITDMGCLNTCORP.CLTPCODE@DMSTAGEDBLINK%type;
  cltdobx    TITDMGCLNTCORP.CLTDOBX@DMSTAGEDBLINK%type;
  --clttype STAGEDBUSR.TITDMGCLNTCORP.CLTTYPE%type;
  cltphone01   TITDMGCLNTCORP.CLTPHONE01@DMSTAGEDBLINK%type;
  cltphone02   TITDMGCLNTCORP.CLTPHONE02@DMSTAGEDBLINK%type;
  faxno        TITDMGCLNTCORP.FAXNO@DMSTAGEDBLINK%type;
  isDuplicate  NUMBER(2) DEFAULT 0;
  errorCount   NUMBER(1) DEFAULT 0;
  t_index      NUMBER(1) DEFAULT 0;
  v_clntnum    VARCHAR2(8 CHAR);
  p_roleflag   VARCHAR2(1 CHAR) DEFAULT 'Y';
  isDateValid  VARCHAR2(20 CHAR);
  v_tranid     VARCHAR2(14 CHAR);
  IgSpaceValue VARCHAR2(1) DEFAULT ' ';
  v_effdate    NUMBER(10) DEFAULT 0;
  v_initials   VARCHAR2(5 CHAR);
  isValidName  VARCHAR2(10 CHAR);
  b_isNoError  BOOLEAN := TRUE;
  v_rinternet  VARCHAR2(20 CHAR);
  anum_cursor1 types.ref_cursor;
  AnRow        ANUMPF%ROWTYPE;
  --  default values form TQ9Q9 Start
  v_clntpfx     VARCHAR2(20 CHAR);
  v_clntcoy     VARCHAR2(20 CHAR);
  v_validflag   VARCHAR2(20 CHAR);
  v_clttype     VARCHAR2(20 CHAR);
  v_surname     VARCHAR2(20 CHAR);
  v_givname     VARCHAR2(20 CHAR);
  v_mailing     VARCHAR2(20 CHAR);
  v_dirmail     VARCHAR2(20 CHAR);
  v_statcode    VARCHAR2(20 CHAR);
  v_soe         VARCHAR2(20 CHAR);
  v_docno       VARCHAR2(20 CHAR);
  v_cltdod      VARCHAR2(20 CHAR);
  v_cltstat     VARCHAR2(20 CHAR);
  v_cltmchg     VARCHAR2(20 CHAR);
  v_taxflag     VARCHAR2(20 CHAR);
  v_fao         VARCHAR2(20 CHAR);
  v_language    VARCHAR2(20 CHAR);
  v_abusnum     VARCHAR2(20 CHAR);
  v_branchid    VARCHAR2(20 CHAR);
  v_zkanagnm    VARCHAR2(20 CHAR);
  v_zkanagnmnor VARCHAR2(20 CHAR);
  v_rdidtelno   VARCHAR2(20 CHAR);
  v_rpager      VARCHAR2(20 CHAR);
  v_faxno       VARCHAR2(20 CHAR);
  v_rtaxidnum   VARCHAR2(20 CHAR);
  v_rstaflag    VARCHAR2(20 CHAR);
  v_zspecind    VARCHAR2(20 CHAR);
  v_oldidno     VARCHAR2(20 CHAR);
  v_amlstatus   VARCHAR2(20 CHAR);
  v_forepfx     VARCHAR2(20 CHAR);
  v_forecoy     VARCHAR2(20 CHAR);
  v_forenum     VARCHAR2(20 CHAR);
  v_used2b      VARCHAR2(20 CHAR);
  v_ecact       VARCHAR2(20 CHAR);
  v_staffno     VARCHAR2(20 CHAR);
  v_capital     VARCHAR2(20 CHAR);
  v_servbrh     VARCHAR2(20 CHAR);
  v_lgivname    VARCHAR2(20 CHAR);
  v_rmblphone   VARCHAR2(20 CHAR);
  v_splindic    VARCHAR2(20 CHAR);
  v_ctrycode    VARCHAR2(20 CHAR);
  v_vip         VARCHAR2(20 CHAR);
  C_ZERO CONSTANT NUMBER(1) := 0;
  --  v_tablecnt      NUMBER(1)          := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  v_space         VARCHAR2(1 CHAR);
  v_y             VARCHAR2(1 CHAR);
  --  default values form TQ9Q9 End
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLCO', company);
  -- C_PREFIX CONSTANT VARCHAR2(2) := 'CC';
  C_T3643 CONSTANT VARCHAR2(5) := 'T3643';
  C_T3645 CONSTANT VARCHAR2(5) := 'T3645';
  C_BQ9Q7 CONSTANT VARCHAR2(5) := 'BQ9Q7';
  C_H036  CONSTANT VARCHAR2(5) := 'H366';
  C_Z099  CONSTANT VARCHAR2(4) := 'RQO6';
  C_Z016  CONSTANT VARCHAR2(6) := 'RQLW';
  C_Z073  CONSTANT VARCHAR2(4) := 'RQNH';
  C_Z017  CONSTANT VARCHAR2(4) := 'RQLX';
  C_Z013  CONSTANT VARCHAR2(4) := 'RQLT';
  C_Z019  CONSTANT VARCHAR2(4) := 'RQLZ';
  C_Z020  CONSTANT VARCHAR2(4) := 'RQV3';
  C_Z021  CONSTANT VARCHAR2(4) := 'RQV4';
  C_E299  CONSTANT VARCHAR2(4) := 'E299';
  -- C_CLRROLE CONSTANT VARCHAR2(4) := 'AG';
  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  ---------------Common function end-----------
  ------IG table obj start---
  obj_clntpf CLNTPF%rowtype;
  -- obj_auditClntpf AUDIT_CLNTPF%rowtype;
  obj_clexpf CLEXPF%rowtype;
  --obj_clrrpf CLRRPF%rowtype;
  obj_zclnf view_DM_ZCLNPF%rowtype;
  -- SIT Fix
  obj_versionpf VERSIONPF%rowtype;
  ------IG table obj end ---
  CURSOR CORPORATECLIENT_cursor IS
    SELECT * FROM TITDMGCLNTCORP@DMSTAGEDBLINK;
  obj_client CORPORATECLIENT_cursor%rowtype;
  --error cont start
  t_index PLS_INTEGER;
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  type i_errorprogram_tab IS TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
  t_errorprogram i_errorprogram_tab;
  --error cont end
BEGIN
  ---------Common Function------------

											
											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9Q7,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCL',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCL',
                                        o_errortext   => o_errortext);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  /*SELECT COUNT(*)
  INTO v_tablecnt
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableName;*/
  -- Fetch All default values form TQ9Q9 Srart
  v_clntpfx     := o_defaultvalues('CLNTPFX');
  v_clntcoy     := o_defaultvalues('CLNTCOY');
  v_validflag   := o_defaultvalues('VALIDFLAG');
  v_clttype     := o_defaultvalues('CLTTYPE');
  v_surname     := o_defaultvalues('SURNAME');
  v_givname     := o_defaultvalues('GIVNAME');
  v_mailing     := o_defaultvalues('MAILING');
  v_dirmail     := o_defaultvalues('DIRMAIL');
  v_statcode    := o_defaultvalues('STATCODE');
  v_soe         := o_defaultvalues('SOE');
  v_docno       := o_defaultvalues('DOCNO');
  v_cltdod      := o_defaultvalues('CLTDOD');
  v_cltstat     := o_defaultvalues('CLTSTAT');
  v_cltmchg     := o_defaultvalues('CLTMCHG');
  v_taxflag     := o_defaultvalues('TAXFLAG');
  v_fao         := o_defaultvalues('FAO');
  v_language    := o_defaultvalues('LANGUAGE');
  v_abusnum     := o_defaultvalues('ABUSNUM');
  v_branchid    := o_defaultvalues('BRANCHID');
  v_zkanagnm    := o_defaultvalues('ZKANAGNM');
  v_zkanagnmnor := o_defaultvalues('ZKANAGNMNO');
  v_rdidtelno   := o_defaultvalues('RDIDTELNO');
  v_rpager      := o_defaultvalues('RPAGER');
  v_faxno       := o_defaultvalues('FAXNO');
  v_rtaxidnum   := o_defaultvalues('RTAXIDNUM');
  v_rstaflag    := o_defaultvalues('RSTAFLAG');
  v_zspecind    := o_defaultvalues('ZSPECIND');
  v_oldidno     := o_defaultvalues('OLDIDNO');
  v_amlstatus   := o_defaultvalues('AMLSTATUS');
  v_forepfx     := o_defaultvalues('FOREPFX');
  v_forecoy     := o_defaultvalues('FORECOY');
  v_forenum     := o_defaultvalues('FORENUM');
  v_used2b      := o_defaultvalues('USED2B');
  v_ecact       := o_defaultvalues('ECACT');
  v_staffno     := o_defaultvalues('STAFFNO');
  v_capital     := o_defaultvalues('CAPITAL');
  v_servbrh     := o_defaultvalues('SERVBRH');
  v_lgivname    := o_defaultvalues('LGIVNAME');
  v_rmblphone   := o_defaultvalues('RMBLPHONE');
  v_splindic    := o_defaultvalues('SPLINDIC');
  v_ctrycode    := o_defaultvalues('CTRYCODE');
  v_vip         := o_defaultvalues('VIP');

  -- Fetch All default values form TQ9Q9 End
  v_tranid := concat('QPAD', TO_CHAR(sysdate, 'YYMMDDHHMM'));

  select DECODE(v_capital, '', 0, ' ', 0, v_capital)
    into v_capital
    from dual;

  OPEN CORPORATECLIENT_cursor;
  <<skipRecord>>
  LOOP
    FETCH CORPORATECLIENT_cursor
      INTO obj_client;
    EXIT WHEN CORPORATECLIENT_cursor%notfound;
    -- Set variable values from staging db to be validated
    --  v_tablecnt := 1;
    refnum   := obj_client.CLNTKEY;
    lsurname := obj_client.LSURNAME;
    zkanasnm := obj_client.ZKANASNM;
    -- cltstat              := obj_client.CLTSTAT;
    cltaddr01  := obj_client.CLTADDR01;
    cltaddr02  := obj_client.CLTADDR02;
    cltaddr03  := obj_client.CLTADDR03;
    cltaddr04  := obj_client.CLTADDR04;
    cltpcode   := obj_client.CLTPCODE;
    cltdobx    := obj_client.CLTDOBX;
    zkanaddr01 := obj_client.zkanaddr01;
    zkanaddr02 := obj_client.zkanaddr02;
    zkanaddr03 := obj_client.zkanaddr03;
    zkanaddr04 := obj_client.zkanaddr04;
    --  v_rinternet := obj_client.RINTERNET;
    cltphone01 := obj_client.CLTPHONE01;
    cltphone02 := obj_client.CLTPHONE02;
    faxno      := obj_client.faxno;
    -- Initialize error  variables start
    /*t_index     := 0; */
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info := NULL;
    --   i_zdoe_info.i_tablecnt   := v_tablecnt;
    i_zdoe_info.i_zfilename  := 'TITDMGCLNTCORP';
    i_zdoe_info.i_prefix     := C_PREFIX;
    i_zdoe_info.i_scheduleno := scheduleNumber;
    i_zdoe_info.i_tableName  := v_tableName;
    i_zdoe_info.i_refKey     := TRIM(refnum);
    -- Initialize error  variables end
    -- reset counter
    --t_index     := 0;
    errorCount  := 0;
    v_space     := ' ';
    v_y         := 'Y';
    b_isNoError := TRUE;
    v_effdate   := 19010101;
    v_initials  := SUBSTR(v_lgivname, 1, 1);
    --IF (zprvaldYN = 'Y') THEN
    -- validate for duplicate record in PAZDCLPF
    IF TRIM(refnum) IS NULL THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_H036;
      i_zdoe_info.i_errormsg01     := o_errortext(C_H036);
      i_zdoe_info.i_errorfield01   := 'Refnum';
      i_zdoe_info.i_fieldvalue01   := TRIM(refnum);
      i_zdoe_info.i_errorprogram01 := scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;
    ELSE
      SELECT COUNT(*)
        INTO isDuplicate
        FROM Jd1dta.PAZDCLPF
       WHERE RTRIM(ZENTITY) = TRIM(refnum)
         AND PREFIX = C_PREFIX;
      IF isDuplicate > 0 THEN
        b_isNoError                  := FALSE;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z099;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z099);
        i_zdoe_info.i_errorfield01   := 'Refnum';
        i_zdoe_info.i_fieldvalue01   := TRIM(refnum);
        i_zdoe_info.i_errorprogram01 := scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      END IF;
    END IF;
    -- validate for duplicate record in PAZDCLPF
    -- validate CLTADDR01
    IF TRIM(cltaddr01) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(cltaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(cltaddr01);
    --      IF isValidName                <> 'OK' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr01';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(cltaddr01);
    --        t_errorprogram (errorCount) := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- validate CLTADDR01
    -- validate CLTADDR02
    IF TRIM(cltaddr02) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(cltaddr02);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(cltaddr02);
    --      IF isValidName                <> 'OK' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr02';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(cltaddr02);
    --        t_errorprogram (errorCount) := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- validate CLTADDR02
    -- validate CLTSTAT
    --  IF NOT (itemexist.exists(TRIM(C_T3645) || TRIM(CLTPCODE)||9)) THEN
    IF TRIM(CLTPCODE) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E299;
      t_errorfield(errorCount) := 'CLTPCODE';
      t_errormsg(errorCount) := o_errortext(C_E299);
      t_errorfieldval(errorCount) := TRIM(CLTPCODE);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate zkanaddr01
    IF TRIM(zkanaddr01) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(zkanaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate zkanaddr01
    -- validate zkanaddr02
    IF TRIM(zkanaddr02) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(zkanaddr02);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate zkanaddr02
    /* -- validate zkanaddr03
    IF TRIM(zkanaddr03)           IS NULL THEN
    b_isNoError                 := FALSE;
    errorCount                  := errorCount + 1;
    t_ercode(errorCount)        := C_Z017;
    t_errorfield(errorCount)    := 'zkanaddr03';
    t_errormsg(errorCount)      := o_errortext(C_Z017);
    t_errorfieldval(errorCount) := TRIM(zkanaddr03);
    t_errorprogram (errorCount) := scheduleName;
    IF errorCount               >= 5 THEN
    GOTO insertzdoe;
    END IF;
    END IF;
    -- validate zkanaddr03
    -- validate zkanaddr04
    IF TRIM(zkanaddr04)           IS NULL THEN
    b_isNoError                 := FALSE;
    errorCount                  := errorCount + 1;
    t_ercode(errorCount)        := C_Z017;
    t_errorfield(errorCount)    := 'zkanaddr04';
    t_errormsg(errorCount)      := o_errortext(C_Z017);
    t_errorfieldval(errorCount) := TRIM(zkanaddr04);
    t_errorprogram (errorCount) := scheduleName;
    IF errorCount               >= 5 THEN
    GOTO insertzdoe;
    END IF;
    END IF;
    -- validate zkanaddr04*/
    -- validate p_cltdobx
    isDateValid := VALIDATE_DATE(cltdobx);
    IF isDateValid <> 'OK' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdobx';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(cltdobx);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate p_cltdobx
    -- validate CLTSTAT
    IF NOT (itemexist.exists(TRIM(C_T3643) || TRIM(v_cltstat) || 9)) THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z019;
      t_errorfield(errorCount) := 'cltstat';
      t_errormsg(errorCount) := o_errortext(C_Z019);
      t_errorfieldval(errorCount) := TRIM(v_cltstat);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate CLTSTAT
    -- validate lsurname
    IF TRIM(lsurname) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z020;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_Z020);
      t_errorfieldval(errorCount) := TRIM(lsurname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(lsurname);
    --      IF isValidName                <> 'OK' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'lsurname';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(lsurname);
    --        t_errorprogram (errorCount) := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- validate lsurname
    -- validate zkanasnm
    IF TRIM(zkanasnm) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'zkanasnm';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(zkanasnm);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- validate zkanasnm
    <<insertzdoe>>
    IF (b_isNoError = FALSE) THEN
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
      CONTINUE skipRecord;
    END IF;
    IF (b_isNoError = TRUE) THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;
    -- update IG  tables START
    IF ((b_isNoError = TRUE) AND (zprvaldYN = 'N')) THEN
      /*      DMgetAutoNumber('CN', '1', '31', anum_cursor1);
      LOOP
      FETCH anum_cursor1
      INTO anRow.UNIQUE_NUMBER,
      anRow.PREFIX,
      anRow.GENKEY,
      anRow.AUTONUM,
      anRow.USRPRF,
      anRow.JOBNM,
      anRow.DATIME;
      EXIT
      WHEN anum_cursor1%notfound;
      v_clntnum := TRIM(SUBSTR(anRow.AUTONUM, 1, 8));
      END LOOP;
      */
      SELECT SEQANUMPF.nextval INTO v_clntnum FROM dual;
      -- insert in  IG zdclpf table start-
      INSERT INTO Jd1dta.PAZDCLPF
        (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
      VALUES
        ('OK', C_PREFIX, refnum, v_clntnum, scheduleNumber, scheduleName);
      -- insert in  IG zdclpf table end-
      -- insert in  IG CLNTPF table start-
      obj_clntpf.CLNTPFX     := v_clntpfx;
      obj_clntpf.CLNTCOY     := v_clntcoy;
      obj_clntpf.VALIDFLAG   := v_validflag;
      obj_clntpf.CLTTYPE     := v_clttype;
      obj_clntpf.CLTDOD      := v_cltdod;
      obj_clntpf.CLTSTAT     := v_cltstat;
      obj_clntpf.CLTMCHG     := v_cltmchg;
      --obj_clntpf.TAXFLAG     := v_taxflag; -- CC2
	  obj_clntpf.TAXFLAG     := 'N'; -- CC2
      obj_clntpf.FAO         := v_fao;
      obj_clntpf.ECACT       := v_ecact;
      obj_clntpf.STAFFNO     := v_staffno;
      obj_clntpf.CAPITAL     := v_capital;
      obj_clntpf.LANGUAGE    := v_language;
      obj_clntpf.ABUSNUM     := v_abusnum;
      obj_clntpf.BRANCHID    := v_branchid;
      obj_clntpf.ZKANAGNM    := v_zkanagnm;
      obj_clntpf.ZKANASNMNOR := lsurname;
      obj_clntpf.SURNAME     := v_surname;
      obj_clntpf.GIVNAME     := v_givname;
      obj_clntpf.MAILING     := v_mailing;
      obj_clntpf.DIRMAIL     := v_dirmail;
      --SIT Bug fix
      obj_clntpf.SERVBRH    := i_branch;
      obj_clntpf.STATCODE   := v_statcode;
      obj_clntpf.SOE        := v_soe;
      obj_clntpf.DOCNO      := v_docno;
      obj_clntpf.LGIVNAME   := v_lgivname;
      obj_clntpf.CLNTNUM    := v_clntnum;
      obj_clntpf.TRANID     := v_tranid;
      obj_clntpf.CLTIND     := 'C';
      obj_clntpf.INITIALS   := v_initials;
      IF TRIM(cltaddr01) IS NOT NULL THEN
      obj_clntpf.CLTADDR01  := cltaddr01;
      ELSE
      obj_clntpf.CLTADDR01  := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr02) IS NOT NULL THEN
      obj_clntpf.CLTADDR02  := cltaddr02;
      ELSE
      obj_clntpf.CLTADDR02  := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr03) IS NOT NULL THEN
      obj_clntpf.CLTADDR03  := cltaddr03;
      ELSE
      obj_clntpf.CLTADDR03  := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr04) IS NOT NULL THEN
      obj_clntpf.CLTADDR04  := cltaddr04;
      ELSE
      obj_clntpf.CLTADDR04  := IgSpaceValue;
      END IF;
      obj_clntpf.CLTADDR05  := IgSpaceValue;
      IF TRIM(cltpcode) IS NOT NULL THEN
      obj_clntpf.CLTPCODE   := cltpcode;
      ELSE
      obj_clntpf.CLTPCODE   := IgSpaceValue;
      END IF;
      IF TRIM(cltphone01) IS NOT NULL THEN
      obj_clntpf.CLTPHONE01 := cltphone01;
      ELSE
      obj_clntpf.CLTPHONE01 := IgSpaceValue;
      END IF;
      IF TRIM(cltphone02) IS NOT NULL THEN
      obj_clntpf.CLTPHONE02 := cltphone02;
      ELSE
      obj_clntpf.CLTPHONE02 := IgSpaceValue;
      END IF;
      IF TRIM(cltdobx) IS NOT NULL THEN
      obj_clntpf.CLTDOB     := cltdobx;
      ELSE
      obj_clntpf.CLTDOB     := IgSpaceValue;
      END IF;
      IF TRIM(faxno) IS NOT NULL THEN
      obj_clntpf.FAXNO      := faxno;
      ELSE
      obj_clntpf.FAXNO      := IgSpaceValue;
      END IF;
      obj_clntpf.ROLEFLAG01 := IgSpaceValue;
      ---SIT Bug fix
      obj_clntpf.ROLEFLAG02  := p_roleflag;
      obj_clntpf.ROLEFLAG03  := IgSpaceValue;
      obj_clntpf.ROLEFLAG04  := IgSpaceValue;
      obj_clntpf.ROLEFLAG05  := IgSpaceValue;
      obj_clntpf.ROLEFLAG06  := IgSpaceValue;
      obj_clntpf.ROLEFLAG07  := IgSpaceValue;
      obj_clntpf.ROLEFLAG08  := IgSpaceValue;
      obj_clntpf.ROLEFLAG09  := IgSpaceValue;
      obj_clntpf.ROLEFLAG10  := IgSpaceValue;
      obj_clntpf.ROLEFLAG11  := IgSpaceValue;
      obj_clntpf.ROLEFLAG12  := IgSpaceValue;
      obj_clntpf.ROLEFLAG13  := IgSpaceValue;
      obj_clntpf.ROLEFLAG14  := IgSpaceValue;
      obj_clntpf.ROLEFLAG15  := IgSpaceValue;
      obj_clntpf.ROLEFLAG16  := IgSpaceValue;
      obj_clntpf.ROLEFLAG17  := IgSpaceValue;
      obj_clntpf.ROLEFLAG18  := IgSpaceValue;
      obj_clntpf.ROLEFLAG19  := IgSpaceValue;
      obj_clntpf.ROLEFLAG20  := IgSpaceValue;
      obj_clntpf.ROLEFLAG21  := IgSpaceValue;
      obj_clntpf.ROLEFLAG22  := IgSpaceValue;
      obj_clntpf.ROLEFLAG23  := IgSpaceValue;
      obj_clntpf.ROLEFLAG24  := IgSpaceValue;
      obj_clntpf.ROLEFLAG25  := IgSpaceValue;
      obj_clntpf.ROLEFLAG26  := IgSpaceValue;
      obj_clntpf.ROLEFLAG27  := IgSpaceValue;
      obj_clntpf.ROLEFLAG28  := IgSpaceValue;
      obj_clntpf.ROLEFLAG29  := IgSpaceValue;
      obj_clntpf.ROLEFLAG30  := IgSpaceValue;
      obj_clntpf.ROLEFLAG31  := IgSpaceValue;
      obj_clntpf.ROLEFLAG32  := IgSpaceValue;
      obj_clntpf.ROLEFLAG33  := IgSpaceValue;
      obj_clntpf.ROLEFLAG34  := IgSpaceValue;
      obj_clntpf.ROLEFLAG35  := IgSpaceValue;
      obj_clntpf.SRDATE      := '19010101';
      IF TRIM(zkanaddr01) IS NOT NULL THEN
      obj_clntpf.ZKANADDR01  := zkanaddr01;
      ELSE
      obj_clntpf.ZKANADDR01  := IgSpaceValue;
      END IF;
      IF TRIM(zkanaddr02) IS NOT NULL THEN
      obj_clntpf.ZKANADDR02  := zkanaddr02;
      ELSE
      obj_clntpf.ZKANADDR02  := IgSpaceValue;
      END IF;
      IF TRIM(zkanaddr03) IS NOT NULL THEN
      obj_clntpf.ZKANADDR03  := zkanaddr03;
      ELSE
      obj_clntpf.ZKANADDR03  := IgSpaceValue;
      END IF;
      IF TRIM(zkanaddr04) IS NOT NULL THEN
      obj_clntpf.ZKANADDR04  := zkanaddr04;
      ELSE
      obj_clntpf.ZKANADDR04  := IgSpaceValue;
      END IF;
      obj_clntpf.ZKANADDR05  := IgSpaceValue;
      IF TRIM(zkanasnm) IS NOT NULL THEN 
      obj_clntpf.ZKANASNM    := zkanasnm;
      ELSE
      obj_clntpf.ZKANASNM    := IgSpaceValue;
      END IF;
      obj_clntpf.JOBNM       := scheduleName;
      obj_clntpf.DATIME      := CURRENT_TIMESTAMP;
      obj_clntpf.TRDT        := TO_CHAR(sysdate, 'YYMMDD');
      obj_clntpf.TRTM        := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
      obj_clntpf.USRPRF      := userProfile;
      IF TRIM(i_vrcmTermid) IS NOT NULL THEN
      obj_clntpf.TERMID      := i_vrcmTermid; --IgSpaceValue; --System updated
      ELSE
      obj_clntpf.TERMID      := IgSpaceValue;
      END IF;
      obj_clntpf.ZKANASNMNOR := lsurname; --updated from Kana Surname name (Removed spaces)
      IF TRIM(lsurname) IS NOT NULL THEN
      obj_clntpf.LSURNAME    := lsurname;
      ELSE
      obj_clntpf.LSURNAME    := IgSpaceValue;
      END IF;
      ---SIT Bug fix
      obj_clntpf.ctrycode  := v_ctrycode;
      obj_clntpf.vip       := v_vip;
      obj_clntpf.idtype    := IgSpaceValue;
      obj_clntpf.z1gstregd := 0;
      obj_clntpf.z1gstregn := IgSpaceValue;

      -- SIT Bug Fix
      obj_clntpf.SECUITYNO := IgSpaceValue;
      obj_clntpf.PAYROLLNO  := IgSpaceValue;
      --obj_clntpf.SALUT  := IgSpaceValue;
      obj_clntpf.CLTSEX := IgSpaceValue;
      obj_clntpf.ADDRTYPE := IgSpaceValue;
      obj_clntpf.OCCPCODE := IgSpaceValue;
      obj_clntpf.MIDDL01 := IgSpaceValue;
      obj_clntpf.MIDDL02 := IgSpaceValue;
      obj_clntpf.MARRYD := IgSpaceValue;
      obj_clntpf.TLXNO  := IgSpaceValue;
      obj_clntpf.TGRAM  := IgSpaceValue;
      obj_clntpf.BIRTHP := IgSpaceValue;
      obj_clntpf.SALUTL := IgSpaceValue;
      obj_clntpf.STCA   := IgSpaceValue;
      obj_clntpf.STCB   := IgSpaceValue;
      obj_clntpf.STCC   := IgSpaceValue;
      obj_clntpf.STCD   := IgSpaceValue;
      obj_clntpf.STCE   := IgSpaceValue;
      --obj_clntpf.PROCFLAG := IgSpaceValue;
      --obj_clntpf.USER_T   := IgSpaceValue;
      obj_clntpf.SNDXCDE    := IgSpaceValue;
      obj_clntpf.NATLTY     := IgSpaceValue;
      obj_clntpf.STATE      := IgSpaceValue;
      obj_clntpf.CTRYORIG   := IgSpaceValue;
      obj_clntpf.ETHORIG    := IgSpaceValue;
      obj_clntpf.ZADDRCD    := IgSpaceValue;
      obj_clntpf.ZKANAGNMNOR := IgSpaceValue;
      obj_clntpf.TELECTRYCODE := IgSpaceValue;
      obj_clntpf.TELECTRYCODE1 := IgSpaceValue;
      obj_clntpf.ZDLIND := IgSpaceValue;
      obj_clntpf.DIRMKTMTD := IgSpaceValue;
      obj_clntpf.PREFCONMTD := IgSpaceValue;
      obj_clntpf.CLNTSTATECD := IgSpaceValue;
      obj_clntpf.FUNDADMINFLAG := IgSpaceValue;
      --obj_clntpf.EXCEP := IgSpaceValue; -- CC2
	  obj_clntpf.EXCEP := 'N'; -- CC2


      INSERT INTO CLNTPF VALUES obj_clntpf;
      -- insert in  IG CLNTPF table end-
      -- insert in  IG CLEXPF table start-
      obj_clexpf.CLNTPFX   := v_clntpfx;
      obj_clexpf.CLNTCOY   := v_clntcoy;
      obj_clexpf.CLNTNUM   := v_clntnum;
      obj_clexpf.RDIDTELNO := v_rdidtelno;
      obj_clexpf.RMBLPHONE := v_rmblphone;
      obj_clexpf.RPAGER    := v_rpager;
      obj_clexpf.FAXNO     := v_faxno;
      obj_clexpf.RINTERNET := ' ';
      obj_clexpf.RTAXIDNUM := v_rtaxidnum;
      obj_clexpf.RSTAFLAG  := v_rstaflag;
      obj_clexpf.SPLINDIC  := v_splindic;
      obj_clexpf.ZSPECIND  := v_zspecind;
      obj_clexpf.OLDIDNO   := v_oldidno;
      obj_clexpf.VALIDFLAG := v_validflag;
      obj_clexpf.AMLSTATUS := v_amlstatus;
      obj_clexpf.JOBNM     := scheduleName;
      obj_clexpf.USRPRF    := userProfile;
      obj_clexpf.DATIME    := sysdate;

      -- SIT Bug Fix
      obj_clexpf.OTHIDNO := IgSpaceValue;
      obj_clexpf.OTHIDTYPE := IgSpaceValue;
      obj_clexpf.ZDMAILTO01 := IgSpaceValue;
      obj_clexpf.ZDMAILTO02 := IgSpaceValue;
      obj_clexpf.ZDMAILCC01 := IgSpaceValue;
      obj_clexpf.ZDMAILCC02 := IgSpaceValue;
      obj_clexpf.ZDMAILCC03 := IgSpaceValue;
      obj_clexpf.ZDMAILCC04 := IgSpaceValue;
      obj_clexpf.ZDMAILCC05 := IgSpaceValue;
      obj_clexpf.ZDMAILCC06 := IgSpaceValue;
      obj_clexpf.ZDMAILCC07 := IgSpaceValue;
      obj_clexpf.RINTERNET2 := IgSpaceValue;
      obj_clexpf.TELECTRYCODE := IgSpaceValue;
      obj_clexpf.ZFATHERNAME := IgSpaceValue;

      INSERT INTO CLEXPF VALUES obj_clexpf;
      -- insert in  IG CLEXPF table end-
      /*  -- insert in  IG CLRRPF table start-
      obj_clrrpf.CLNTPFX  := v_clntpfx;
      obj_clrrpf.CLNTCOY  := v_clntcoy;
      obj_clrrpf.CLNTNUM  := v_clntnum;
      obj_clrrpf.CLRRROLE := C_CLRROLE;
      obj_clrrpf.FOREPFX  := v_forepfx;
      obj_clrrpf.FORECOY  := v_forecoy;
      obj_clrrpf.FORENUM  := v_forenum;
      obj_clrrpf.USED2B   := v_used2b;
      obj_clrrpf.JOBNM    := scheduleName;
      obj_clrrpf.USRPRF   := userProfile;
      obj_clrrpf.DATIME   := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;
      -- insert in  IG CLRRPF table end- */
      -- insert in  IG ZCLNPF table start-
      obj_zclnf.CLNTPFX        := v_clntpfx;
      obj_zclnf.CLNTCOY        := v_clntcoy;
      obj_zclnf.CLNTNUM        := v_clntnum;
      obj_zclnf.CLTDOB         := cltdobx;
      obj_zclnf.LSURNAME       := lsurname;
      obj_zclnf.LGIVNAME       := v_space; --v_lgivname; Not Null
      obj_zclnf.ZKANASNM       := zkanasnm;
      obj_zclnf.ZKANAGNM       := v_space; -- v_zkanagnm;  Not Null
      obj_zclnf.CLTPCODE       := cltpcode;
      obj_zclnf.ZKANADDR01     := zkanaddr01;
      obj_zclnf.ZKANADDR02     := zkanaddr02;
      obj_zclnf.ZKANADDR03     := zkanaddr03;
      obj_zclnf.ZKANADDR04     := zkanaddr04;
      IF TRIM(cltaddr01) IS NOT NULL THEN
      obj_zclnf.CLTADDR01      := cltaddr01;
      ELSE
      obj_zclnf.CLTADDR01      := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr02) IS NOT NULL THEN
      obj_zclnf.CLTADDR02      := cltaddr02;
      ELSE
      obj_zclnf.CLTADDR02      := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr03) IS NOT NULL THEN
      obj_zclnf.CLTADDR03      := cltaddr03;
      ELSE
      obj_zclnf.CLTADDR03      := IgSpaceValue;
      END IF;
      IF TRIM(cltaddr04) IS NOT NULL THEN
      obj_zclnf.CLTADDR04      := cltaddr04;
      ELSE
      obj_zclnf.CLTADDR04      := IgSpaceValue;
      END IF;
      IF TRIM(cltphone01) IS NOT NULL THEN
      obj_zclnf.CLTPHONE01     := cltphone01;
      ELSE
      obj_zclnf.CLTPHONE01     := IgSpaceValue;
      END IF;
      IF TRIM(cltphone02) IS NOT NULL THEN
      obj_zclnf.CLTPHONE02     := cltphone02;
      ELSE
      obj_zclnf.CLTPHONE02     := IgSpaceValue;
      END IF;
      obj_zclnf.CLTDOBFLAG     := v_y;
      obj_zclnf.LSURNAMEFLAG   := v_y;
      obj_zclnf.LGIVNAMEFLAG   := v_y;
      obj_zclnf.ZKANASNMFLAG   := v_y;
      obj_zclnf.ZKANAGNMFLAG   := v_space;
      obj_zclnf.CLTSEXFLAG     := v_space;
      obj_zclnf.CLTPCODEFLAG   := v_y;
      obj_zclnf.ZKANADDR01FLAG := v_y;
      obj_zclnf.ZKANADDR02FLAG := v_y;
      obj_zclnf.ZKANADDR03FLAG := v_y;
      obj_zclnf.ZKANADDR04FLAG := v_y;
      obj_zclnf.CLTADDR01FLAG  := v_y;
      obj_zclnf.CLTADDR02FLAG  := v_y;
      obj_zclnf.CLTADDR03FLAG  := v_y;
      obj_zclnf.CLTADDR04FLAG  := v_y;
      obj_zclnf.CLTPHONE01FLAG := v_y;
      obj_zclnf.CLTPHONE02FLAG := v_y;
      obj_zclnf.ZWORKPLCEFLAG  := v_y;
      obj_zclnf.OCCPCODEFLAG   := v_space;
      obj_zclnf.OCCPCLASFLAG   := v_space;
      obj_zclnf.ZOCCDSCFLAG    := v_space;
      obj_zclnf.EFFDATE        := v_effdate;
      obj_zclnf.CLTSEX         := v_space;
      --  obj_zclnf.USRPRF  := userProfile; --?
      --  obj_zclnf.JOBNM   := scheduleName; --?
      --  obj_zclnf.DATIME  := sysdate; --?
      -- SIT BUG FIX
      obj_zclnf.ZWORKPLCE := IgSpaceValue;
      obj_zclnf.OCCPCODE := IgSpaceValue;
      obj_zclnf.ZOCCDSC := IgSpaceValue;
      obj_zclnf.OCCPCLAS := IgSpaceValue;

      INSERT INTO view_DM_ZCLNPF VALUES obj_zclnf;
      -- insert in  IG Jd1dta.ZCLNPF table end-

      -- VERSIONPF Insertion For SIT Bug Fix

      obj_versionpf.TRANNO := 1;
      obj_versionpf.CLNTNUM := v_clntnum;

      INSERT INTO VERSIONPF VALUES obj_versionpf;


      -- update IG  tables End
    END IF;
  END LOOP;
  CLOSE CORPORATECLIENT_cursor;
  NULL;
  -- EXCEPTION
  -- WHEN OTHERS THEN
  --  v_code := SQLCODE;
  --   v_errm := SUBSTR(SQLERRM, 1, 64);
  --   dbms_output.put_line('Exception occurs while program execution, ' ||
  --                      'SQL Code:' || v_code ||
  --                      ', Error Description:' || v_errm);
  ---dbms_output.put_line('Execution END ' || LOCALTIMESTAMP);
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
END BQ9Q7_CL01_CORPCLT;