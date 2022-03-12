create or replace PROCEDURE                                      "BQ9TV_CL02_2_CLNTHIST" (scheduleName   IN VARCHAR2,
                                                  scheduleNumber IN VARCHAR2,
                                                  zprvaldYN      IN VARCHAR2,
                                                  i_company      IN VARCHAR2,
                                                  userProfile    IN VARCHAR2,
                                                  i_branch       IN VARCHAR2,
                                                  i_transCode    IN VARCHAR2,
                                                  vrcmTermid     IN VARCHAR2) AS
                                                                                                                                     
  /**************************   *************************************************************************
  * Amenment History: CL02 Client History
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   CH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0502     SC   CH2   CHNAGE IN REGISTRY TABLE DDL TO GET CORRECT UNIQUE NUMBER FOR POLICY TRAN HIST.
  * 0504     PS   CH3   Initialized old values for AUDIT_CLNTPF, synced tranno, change N07 > P09.
  * 0718     SJ   CH4   If EFFDATE.TITDMGCLTRNH is more than Migration Date then set this as Migration date for EFFDATE.ZCLNPF
  * 0723     PS   CH5   Set all SRDATE to 19010101. 
  * 1015     SJ   CH6   Fix for sync the value of Unique_number in PAZDCHPF and ZCLNPF
  *****************************************************************************************************/

  v_timestart NUMBER := dbms_utility.get_time;
  --Values fron Staging Table Start
  n_cltdob       TITDMGCLTRNHIS.CLTDOB@DMSTAGEDBLINK%type;
  v_refnum       TITDMGCLTRNHIS.REFNUM@DMSTAGEDBLINK%type;
  v_zseqno       TITDMGCLTRNHIS.ZSEQNO@DMSTAGEDBLINK%type;
  v_lsurname     TITDMGCLTRNHIS.LSURNAME@DMSTAGEDBLINK%type;
  v_lgivname     TITDMGCLTRNHIS.LGIVNAME@DMSTAGEDBLINK%type;
  v_zkanagivname TITDMGCLTRNHIS.ZKANAGIVNAME@DMSTAGEDBLINK%type;
  v_zkanasurname TITDMGCLTRNHIS.ZKANASURNAME@DMSTAGEDBLINK%type;
  v_cltsex       TITDMGCLTRNHIS.CLTSEX@DMSTAGEDBLINK%type;
  v_cltpcode     TITDMGCLTRNHIS.CLTPCODE@DMSTAGEDBLINK%type;
  v_zkanaddr01   TITDMGCLTRNHIS.ZKANADDR01@DMSTAGEDBLINK%type;
  v_zkanaddr02   TITDMGCLTRNHIS.ZKANADDR02@DMSTAGEDBLINK%type;
  --v_zkanaddr03   TITDMGCLTRNHIS.ZKANADDR03@DMSTAGEDBLINK%type;
  v_cltaddr01 TITDMGCLTRNHIS.CLTADDR01@DMSTAGEDBLINK%type;
  v_cltaddr02 TITDMGCLTRNHIS.CLTADDR02@DMSTAGEDBLINK%type;
  v_cltaddr03 TITDMGCLTRNHIS.CLTADDR03@DMSTAGEDBLINK%type;

  v_cltphone01 TITDMGCLTRNHIS.CLTPHONE01@DMSTAGEDBLINK%type;
  v_cltphone02 TITDMGCLTRNHIS.CLTPHONE02@DMSTAGEDBLINK%type;
  v_zworkplce  TITDMGCLTRNHIS.ZWORKPLCE@DMSTAGEDBLINK%type;
  v_occpcode   TITDMGCLTRNHIS.OCCPCODE@DMSTAGEDBLINK%type;
  --v_occpclas STAGEDBUSR.TITDMGCLTRNHIS.OCCPCLAS%type; --not in table
  v_zoccdsc TITDMGCLTRNHIS.ZOCCDSC@DMSTAGEDBLINK%type;
  --  v_effdate STAGEDBUSR.TITDMGCLTRNHIS.EFFDATE%type;
  --v_zkanasnm STAGEDBUSR.TITDMGCLNTPRSN.ZKANASNM%type;   not in tsd

  v_addrtype      TITDMGCLTRNHIS.ADDRTYPE@DMSTAGEDBLINK%type;
  v_zaltrcde01    TITDMGCLTRNHIS.ZALTRCDE01@DMSTAGEDBLINK%type;
  v_newcltaddr03  TITDMGCLTRNHIS.ZKANADDR02@DMSTAGEDBLINK%type;
  v_newcltphone02 TITDMGCLTRNHIS.CLTPHONE02@DMSTAGEDBLINK%type;
  v_temprefnum    TITDMGCLTRNHIS.refnum@DMSTAGEDBLINK%type default ' ';
  --Values fron Staging Table End
  T_cltpcodeTemp VARCHAR2(10 CHAR);
  --  default values form TQ9Q9 Start
  v_clntpfx VARCHAR2(20 CHAR);
  v_clntcoy VARCHAR2(20 CHAR);
  --  default values form TQ9Q9 END
  C_ZERO CONSTANT NUMBER(1) := 0;
  -- v_tablecnt      NUMBER(1)          := 0;
  v_SEQ         NUMBER(15) DEFAULT 0;
  v_tableNametemp    VARCHAR2(10);
  v_tableName        VARCHAR2(10);
  v_clntnum          VARCHAR2(8 CHAR);
  b_isNoError        BOOLEAN := TRUE;
  errorCount         NUMBER(1) DEFAULT 0;
  isValid            NUMBER(1) DEFAULT 0;
  isDuplicate        NUMBER(1) DEFAULT 0;
  v_code             NUMBER;
  v_version_ctr      NUMBER(2) DEFAULT 0; -- CH3
  v_errm             VARCHAR2(64 CHAR);
  isValidName        VARCHAR2(10 CHAR);
  v_space            VARCHAR2(1 CHAR);
  v_effdate          NUMBER(10) DEFAULT 0;
  v_initials         VARCHAR2(5 CHAR);
  v_tranid           VARCHAR2(14 CHAR);
  isDateValid        VARCHAR2(20 CHAR);
  anum_cursor1       types.ref_cursor;
  AnRow              ANUMPF%ROWTYPE;
  v_nflag            VARCHAR2(1 CHAR) DEFAULT 'N';
  v_yflag            VARCHAR2(1 CHAR) DEFAULT 'Y';
  v_unq_audit_clntpf AUDIT_CLNTPF.Unique_Number%type;
  v_unq_audit_clexpf AUDIT_CLEXPF.Unique_Number%type;
  v_unq_zdch_zcln    ZCLNPF.UNIQUE_NUMBER%type; -- CH6

  ------Define Constant to read
  -- C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLPL', company);
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLHS', i_company);
  --C_BQ9TV  CONSTANT VARCHAR2(5) := 'BQ9TV';
  C_BQ9Q6 CONSTANT VARCHAR2(5) := 'BQ9Q6';
  C_Z017  CONSTANT VARCHAR2(4) := 'RQLX';
  C_H036  CONSTANT VARCHAR2(4) := 'H036';
  C_Z098  CONSTANT VARCHAR2(4) := 'RQO6'; --Z099
  C_Z020  CONSTANT VARCHAR2(4) := 'RQV3';
  C_Z073  CONSTANT VARCHAR2(4) := 'RQNH';
  C_Z021  CONSTANT VARCHAR2(4) := 'RQV4';
  C_Z016  CONSTANT VARCHAR2(4) := 'RQLW';
  C_G979  CONSTANT VARCHAR2(4) := 'G979';
  C_F992  CONSTANT VARCHAR2(4) := 'F992';
  C_Z013  CONSTANT VARCHAR2(4) := 'RQLT';
  C_E374  CONSTANT VARCHAR2(4) := 'E374';
  C_E186  CONSTANT VARCHAR2(4) := 'E186';
  C_D009  CONSTANT VARCHAR2(4) := 'D009';
  C_T3645 CONSTANT VARCHAR2(5) := 'T3645';
  C_T2241 CONSTANT VARCHAR2(5) := 'T2241';
  C_TR393 CONSTANT VARCHAR2(5) := 'TR393';
  C_T3644 CONSTANT VARCHAR2(5) := 'T3644';
  C_T3582 CONSTANT VARCHAR2(5) := 'T3582';
  C_DTSM  CONSTANT VARCHAR2(4) := 'DTSM';
  C_Z130  CONSTANT VARCHAR2(4) := 'RGKG';
  ------Define Constant to read end
  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  checkdupl       pkg_common_dmch.cpduplicate; --mps 4/12

-------------------CL2: START-----------------------------------------------------------------------
--  getzigvalue       pkg_common_dmmb.zigvaluetype; -- mps 4/12
   getzigvalue       pkg_common_dmch.zigvaluetype; -- mps 4/12
-------------------CL2: END-------------------------------------------------------------------------

  ---------------Common function end-----------
  ------IG table obj start---
  obj_zdclpf       PAZDCLPF%rowtype;
  obj_zclnf        VIEW_ZCLNPF%rowtype;
  obj_zdchpf       PAZDCHPF%rowtype;
  obj_audit_clntpf audit_clntpf%rowtype;
  obj_audit_clnt   audit_clnt%rowtype;
  obj_audit_clexp  audit_clexpf%rowtype;
  obj_client_old   TITDMGCLTRNHIS@DMSTAGEDBLINK%rowtype;
  --SIT CHANGES
  obj_clntpf    CLNTPF%rowtype;
  obj_versionpf VERSIONPF%rowtype;
  v_busdate   busdpf.busdate%type; -- CH4

  ------IG table obj End---
  CURSOR personalclient_cursor IS
    SELECT *
      FROM TITDMGCLTRNHIS@DMSTAGEDBLINK
    -- where TRIM(refnum) = '17621741'
     order by LPAD(REFNUM, 8, '0') asc, ZSEQNO asc;
  obj_client personalclient_cursor%rowtype;
  --error cont start
  t_index PLS_INTEGER;
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  type i_errorprogram_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram i_errorprogram_tab;
  --error cont end
BEGIN
  ---------Common Function------------


											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9Q6,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCP',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCP',
                                        o_errortext   => o_errortext);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  pkg_common_dmch.checkcpdup(checkdupl => checkdupl); -- mps 4/12
  -------------------CL2: START----------------------------------------------------------------------------------------------------------------------------------
--  pkg_common_dmmb.getzigvalue(getzigvalue => getzigvalue); -- mps 4/12
    pkg_common_dmch.getzigvalue(getzigvalue => getzigvalue); -- mps 4/12
  -------------------CL2: END----------------------------------------------------------------------------------------------------------------------------------
  /*SELECT COUNT(*)
  INTO v_tablecnt
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableName;*/
  -- Fetch All default values form TQ9Q9 Srart
  v_clntpfx := o_defaultvalues('CLNTPFX');
  v_clntcoy := o_defaultvalues('CLNTCOY');
  -- Fetch All default values form TQ9Q9 End
  v_tranid := concat('QPAD', TO_CHAR(sysdate, 'YYMMDDHHMM'));

  SELECT BUSDATE
    INTO v_busdate
    FROM busdpf
   WHERE TRIM(company) = TRIM(i_company); -- CH4


  -- Open Cursor
  OPEN personalclient_cursor;
  <<skipRecord>>
  LOOP
    FETCH personalclient_cursor
      INTO obj_client;
    EXIT WHEN personalclient_cursor%notfound;
    v_refnum := obj_client.refnum;
    IF (TRIM(v_refnum) <> TRIM(v_temprefnum)) THEN
      obj_client_old := null;
    END IF;
    v_temprefnum := TRIM(v_refnum);

    --dbms_output.put_line('v_refnum = ' || v_refnum);
    v_zseqno       := obj_client.zseqno;
    v_effdate      := obj_client.effdate;
    v_lsurname     := obj_client.lsurname;
    v_lgivname     := obj_client.lgivname;
    v_zkanagivname := obj_client.zkanagivname;
    v_zkanasurname := obj_client.zkanasurname;
    v_cltpcode     := obj_client.cltpcode;
    v_cltaddr01    := obj_client.cltaddr01;
    v_cltaddr02    := obj_client.cltaddr02;
    v_cltaddr03    := obj_client.cltaddr03;
    v_zkanaddr01   := obj_client.zkanaddr01;
    v_zkanaddr02   := obj_client.zkanaddr02;
    --v_zkanaddr03   := obj_client.ZKANADDR03;
    v_cltsex     := obj_client.cltsex;
    v_cltphone01 := obj_client.cltphone01;
    v_cltphone02 := obj_client.cltphone02;
    v_occpcode   := obj_client.occpcode;
    n_cltdob     := obj_client.cltdob;
    v_zoccdsc    := obj_client.zoccdsc;
    v_zworkplce  := obj_client.zworkplce;
    v_addrtype   := obj_client.ADDRTYPE;
    v_zaltrcde01 := obj_client.ZALTRCDE01;

    -- v_occpclas    :=obj_client.occpclas ; not in table
    v_space     := ' ';
    b_isNoError := TRUE;
    errorCount  := 0;

    v_initials := SUBSTR(v_lgivname, 1, 1);
    -- Initialize error  variables start
    /*t_index     := 0; */
    i_zdoe_info := NULL;
    --  i_zdoe_info.i_tablecnt   := v_tablecnt;
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info.i_zfilename := 'TITDMGCLTRNHIS';
    i_zdoe_info.i_prefix := C_PREFIX;
    i_zdoe_info.i_scheduleno := scheduleNumber;
    i_zdoe_info.i_tableName := v_tableName;
    i_zdoe_info.i_refKey := TRIM(v_refnum);
    -- Initialize error  variables end
    v_nflag := 'N';
    v_yflag := 'Y';

    --validation Start

    -- CH4 Start
    IF v_effdate > v_busdate Then
        v_effdate:= v_busdate;
    End IF;
    -- CH4 End
    IF TRIM(v_refnum) IS NULL THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_H036;
      i_zdoe_info.i_errormsg01     := o_errortext(C_H036);
      i_zdoe_info.i_errorfield01   := 'Refnum';
      i_zdoe_info.i_fieldvalue01   := TRIM(v_refnum);
      i_zdoe_info.i_errorprogram01 := scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;

       ELSE
      -- 2) Duplicate Record if already Migrated in table PAZDCLPF
       /* mps 4/12
      SELECT COUNT(*)
        INTO isDuplicate
        FROM Jd1dta.PAZDCHPF
       WHERE TRIM(ZENTITY) = TRIM(v_refnum || v_zseqno || v_effdate);

      IF (isDuplicate > 0) THEN
      mps 4/12 */

      IF (checkdupl.exists(TRIM(v_refnum))) THEN
        b_isNoError                  := FALSE;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z098;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
        i_zdoe_info.i_errorfield01   := 'Refnum';
        i_zdoe_info.i_fieldvalue01   := TRIM(v_refnum);
        i_zdoe_info.i_errorprogram01 := scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      END IF;
    END IF;

    --LSURNAME  ---As discussed with patrice this validation will be always true so we are removing
    /*  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lsurname) || 9)) THEN
    b_isNoError := FALSE;
    errorCount := errorCount + 1;
    t_ercode(errorCount) := C_Z020;
    t_errorfield(errorCount) := 'lsurname';
    t_errormsg(errorCount) := o_errortext(C_Z020);
    t_errorfieldval(errorCount) := TRIM(v_lsurname);
    t_errorprogram(errorCount) := scheduleName;
    IF errorCount >= 5 THEN
      GOTO insertzdoe;
    END IF;*/

    --Kanji character validation  Japanees charater not in TSD
    /*isValidName := VALIDATE_JAPANESE_TEXT(v_lsurname);
    IF isValidName = 'Invalid' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_lsurname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/

    -- validate lsurname
    IF TRIM(v_lsurname) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z020;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_Z020);
      t_errorfieldval(errorCount) := TRIM(v_lsurname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    --As discussed with patrice this validation will be always true so we are removing
    /* IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lgivname) || 9)) THEN
    b_isNoError := FALSE;
    errorCount := errorCount + 1;
    t_ercode(errorCount) := C_Z020;
    t_errorfield(errorCount) := 'lgivname';
    t_errormsg(errorCount) := o_errortext(C_Z020);
    t_errorfieldval(errorCount) := TRIM(v_lgivname);
    t_errorprogram(errorCount) := scheduleName;
    IF errorCount >= 5 THEN
      GOTO insertzdoe;
    END IF;*/

    /*     --Kanji character validation  Japanees charater not in TSD
    isValidName := VALIDATE_JAPANESE_TEXT(v_lgivname);
    IF isValidName = 'Invalid' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'lgivname';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_lgivname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;

    END IF;*/

    -- validate lsurname
    IF TRIM(v_lgivname) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z020;
      t_errorfield(errorCount) := 'lgivname';
      t_errormsg(errorCount) := o_errortext(C_Z020);
      t_errorfieldval(errorCount) := TRIM(v_lgivname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    --3) ZKANAGIVNAME is  Null
    IF TRIM(v_zkanagivname) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'ZKNAGIVNAM';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(v_zkanagivname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 4) ZKANASURNAME is  Null
    IF TRIM(v_zkanasurname) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'ZKNASURNAM';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(v_zkanasurname);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- CLTADDR01 ( Have Doubt for Addtess Rule in T2241vv--- --As discussed with patrice this validation will be always true so we are removing
    /* IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_cltaddr01) || 9)) THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'CLTADDR01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    ELSE
    isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr01);
    IF isValidName = 'Invalid' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'cltaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/

    IF TRIM(v_cltaddr01) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    -- 5) CLTADDR02 is Null
    IF TRIM(v_cltaddr02) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr02);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /*  ELSE
      --Kanji character validation
      isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr02);
      IF isValidName = 'Invalid' THEN
        b_isNoError := FALSE;
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z073;
        t_errorfield(errorCount) := 'cltaddr02';
        t_errormsg(errorCount) := o_errortext(C_Z073);
        t_errorfieldval(errorCount) := TRIM(v_cltaddr02);
        t_errorprogram(errorCount) := scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;*/
    -- 6)CLTADDR03 is Null
    --    IF TRIM(v_cltaddr03) IS NULL THEN
    --      b_isNoError := FALSE;
    --      errorCount := errorCount + 1;
    --      t_ercode(errorCount) := C_Z016;
    --      t_errorfield(errorCount) := 'cltaddr03';
    --      t_errormsg(errorCount) := o_errortext(C_Z016);
    --      t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --      t_errorprogram(errorCount) := scheduleName;
    --      IF errorCount >= 5 THEN
    --        GOTO insertzdoe;
    --      END IF;
    --    END IF;
    /*ELSE
      --Kanji character validation
      isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr03);
      IF isValidName = 'Invalid' THEN
        b_isNoError := FALSE;
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z073;
        t_errorfield(errorCount) := 'cltaddr03';
        t_errormsg(errorCount) := o_errortext(C_Z073);
        t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
        t_errorprogram(errorCount) := scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;*/
    -- 7) ZKANADDR01 is Null
    IF TRIM(v_zkanaddr01) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(v_zkanaddr01);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 8) ZKANADDR02 is Null
    --SIT changes removed in requirement
    /* IF TRIM(v_zkanaddr02) IS NULL THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(v_zkanaddr02);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/
    -- 9) CLTSEX valid in Smart T-table T3582
    -- Read T-table T3582
    IF NOT (itemexist.exists(TRIM(C_T3582) || TRIM(v_cltsex) || 9)) THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_G979;
      t_errorfield(errorCount) := 'CLTSEX';
      t_errormsg(errorCount) := o_errortext(C_G979);
      t_errorfieldval(errorCount) := TRIM(v_cltsex);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /*  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(n_cltdob) || 9)) THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdob';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(n_cltdob);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/

    isDateValid := VALIDATE_DATE(n_cltdob);
    IF isDateValid <> 'OK' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdob';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(n_cltdob);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    isDateValid := VALIDATE_DATE(v_effdate);
    IF isDateValid <> 'OK' THEN
      b_isNoError := FALSE;
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z130;
      t_errorfield(errorCount) := 'effdate';
      t_errormsg(errorCount) := o_errortext(C_Z130);
      t_errorfieldval(errorCount) := TRIM(v_effdate);
      t_errorprogram(errorCount) := scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    --validation End
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
    -- Updateing IG- Tables And Migration Registry table with filter data
    -- Updating S indicator
    IF b_isNoError = TRUE AND zprvaldYN = 'N' THEN
    /* mps 4/12
      SELECT ZIGVALUE
        INTO v_clntnum
        FROM Jd1dta.PAZDCLPF
       WHERE TRIM(ZENTITY) = TRIM(v_refnum)
         and TRIM(prefix) = TRIM('CP');  
    mps 4/12 */
   IF NOT (getzigvalue.exists(TRIM(v_refnum))) THEN
         CONTINUE skipRecord;
      ELSE
        v_clntnum := getzigvalue(TRIM(v_refnum));
      END IF;

-------------------CL2: START----------------------------------------------------------------------------------------------------------------------------------      
      --Insert Value Migration Registry Table
--      INSERT INTO Jd1dta.PAZDCHPF
--        (RECSTATUS,
--         ZENTITY, -- actual: 11, maximum: 8 --30
--         ZIGVALUE, -- actual: 11, maximum: 8 -- 30
--         JOBNUM,
--         JOBNAME)
--      VALUES
--        ('New',
--         (v_refnum || v_zseqno || v_effdate), --?? This will be the application number/policy number from staging db + sequence number + effective date
--         concat(v_clntnum, v_effdate), --  ??      v_clntnum +v_effdate, This will be the IG client number + effective date
--         scheduleNumber,
--         scheduleName);

    SELECT SEQ_ZCLN_ZDCH.nextval INTO v_unq_zdch_zcln FROM dual; -- CH6


   INSERT INTO Jd1dta.PAZDCHPF
        ( RECIDXCLNTHIS,
         ZENTITY, 
         ZIGVALUE,
         ZSEQNO,
         EFFDATE,
         JOBNUM,
         JOBNAME)
      VALUES
        ( v_unq_zdch_zcln,
          v_refnum,
          v_clntnum,
          v_zseqno,
          v_effdate,
          scheduleNumber,
          scheduleName);      

-------------------CL2: START----------------------------------------------------------------------------------------------------------------------------------    
      /* -- CLNTPF Table--- SIT Fix
      IF v_zseqno = 0 THEN
        obj_clntpf.CLNTPFX   := o_defaultvalues('CLNTPFX');
        obj_clntpf.CLNTCOY   := o_defaultvalues('CLNTCOY');
        obj_clntpf.VALIDFLAG := o_defaultvalues('VALIDFLAG');
        obj_clntpf.CLTTYPE   := o_defaultvalues('CLTTYPE');
        obj_clntpf.SURNAME   := v_lsurname;
        obj_clntpf.GIVNAME   := v_lgivname;
        obj_clntpf.CTRYCODE  := 'JPN';
        obj_clntpf.NATLTY    := o_defaultvalues('NATLTY');
        obj_clntpf.MAILING   := o_defaultvalues('MAILING');
        obj_clntpf.DIRMAIL   := o_defaultvalues('DIRMAIL');
        obj_clntpf.VIP       := o_defaultvalues('VIP');
        obj_clntpf.STATCODE  := o_defaultvalues('STATCODE');
        obj_clntpf.SOE       := o_defaultvalues('SOE');
        obj_clntpf.DOCNO     := o_defaultvalues('DOCNO');
        obj_clntpf.CLTDOD    := o_defaultvalues('CLTDOD');
        obj_clntpf.CLTSTAT   := o_defaultvalues('CLTSTAT');
        obj_clntpf.CLTMCHG   := o_defaultvalues('CLTMCHG');
        obj_clntpf.MARRYD    := o_defaultvalues('MARRYD');
        obj_clntpf.BIRTHP    := o_defaultvalues('BIRTHP');
        obj_clntpf.TAXFLAG   := o_defaultvalues('TAXFLAG');
        obj_clntpf.FAO       := o_defaultvalues('FAO');
        obj_clntpf.ETHORIG   := o_defaultvalues('ETHORIG');
        obj_clntpf.LANGUAGE  := o_defaultvalues('LANGUAGE');
        obj_clntpf.ABUSNUM   := o_defaultvalues('ABUSNUM');
        obj_clntpf.BRANCHID  := o_defaultvalues('BRANCHID');
        IF TRIM(v_zkanagivname) IS NOT NULL THEN
          obj_clntpf.ZKANAGNM := v_zkanagivname;
        ELSE
          obj_clntpf.ZKANAGNM := v_space;
        END IF;
        obj_clntpf.ZKANAGNMNOR := v_zkanagivname;
        obj_clntpf.CLNTNUM     := v_clntnum;
        obj_clntpf.TRANID      := v_tranid;
        obj_clntpf.CLTIND      := 'C';
        obj_clntpf.SECUITYNO   := v_space;
        obj_clntpf.INITIALS    := v_initials; -- INITIALS,               --Defaulted as First character of Name
        obj_clntpf.CLTSEX      := v_cltsex;
        IF TRIM(v_cltaddr01) IS NOT NULL THEN
          obj_clntpf.CLTADDR01 := v_cltaddr01;
        ELSE
          obj_clntpf.CLTADDR01 := v_space;
        END IF;
        IF TRIM(v_cltaddr02) IS NOT NULL THEN
          obj_clntpf.CLTADDR02 := v_cltaddr02;
        ELSE
          obj_clntpf.CLTADDR02 := v_space;
        END IF;
        IF TRIM(v_cltaddr03) IS NOT NULL THEN
          obj_clntpf.CLTADDR03 := v_cltaddr03;
        ELSE
          obj_clntpf.CLTADDR03 := v_space;
        END IF;
        obj_clntpf.CLTADDR04 := v_space;
        obj_clntpf.CLTADDR05 := v_space;
        IF TRIM(v_cltpcode) IS NOT NULL THEN
          obj_clntpf.CLTPCODE := v_cltpcode;
        ELSE
          obj_clntpf.CLTPCODE := v_space;
        END IF;
        IF TRIM(v_addrtype) IS NOT NULL THEN
          obj_clntpf.ADDRTYPE := v_addrtype;
        ELSE
          obj_clntpf.ADDRTYPE := v_space;
        END IF;
        --IF TRIM(v_cltphone01) IS NOT NULL THEN
        --obj_clntpf.CLTPHONE01 := v_cltphone01;
        --ELSE
        obj_clntpf.CLTPHONE01 := v_space;
        --END IF;
        IF TRIM(v_cltphone02) IS NOT NULL THEN
          obj_clntpf.CLTPHONE02 := v_cltphone02;
        ELSE
          obj_clntpf.CLTPHONE02 := v_space;
        END IF;
        IF TRIM(v_occpcode) IS NOT NULL THEN
          obj_clntpf.OCCPCODE := v_occpcode;
        ELSE
          obj_clntpf.OCCPCODE := v_space;
        END IF;
        obj_clntpf.SERVBRH    := '31';
        obj_clntpf.CLTDOB     := n_cltdob;
        obj_clntpf.ROLEFLAG01 := v_space;
        obj_clntpf.ROLEFLAG02 := v_space;
        obj_clntpf.ROLEFLAG03 := v_space;
        obj_clntpf.ROLEFLAG04 := v_space;
        obj_clntpf.ROLEFLAG05 := v_space;
        obj_clntpf.ROLEFLAG06 := v_space;
        obj_clntpf.ROLEFLAG07 := v_space;
        obj_clntpf.ROLEFLAG08 := v_space;
        obj_clntpf.ROLEFLAG09 := v_space;
        obj_clntpf.ROLEFLAG10 := v_space;
        obj_clntpf.ROLEFLAG11 := v_space;
        obj_clntpf.ROLEFLAG12 := v_space;
        obj_clntpf.ROLEFLAG13 := v_space;
        obj_clntpf.ROLEFLAG14 := 'Y';
        obj_clntpf.ROLEFLAG15 := v_space;
        obj_clntpf.ROLEFLAG16 := v_space;
        obj_clntpf.ROLEFLAG17 := v_space;
        obj_clntpf.ROLEFLAG18 := 'Y';
        obj_clntpf.ROLEFLAG19 := v_space;
        obj_clntpf.ROLEFLAG20 := v_space;
        obj_clntpf.ROLEFLAG21 := v_space;
        obj_clntpf.ROLEFLAG22 := v_space;
        obj_clntpf.ROLEFLAG23 := v_space;
        obj_clntpf.ROLEFLAG24 := v_space;
        obj_clntpf.ROLEFLAG25 := v_space;
        obj_clntpf.ROLEFLAG26 := v_space;
        obj_clntpf.ROLEFLAG27 := v_space;
        obj_clntpf.ROLEFLAG28 := v_space;
        obj_clntpf.ROLEFLAG29 := v_space;
        obj_clntpf.ROLEFLAG30 := v_space;
        obj_clntpf.ROLEFLAG31 := v_space;
        obj_clntpf.ROLEFLAG32 := v_space;
        obj_clntpf.ROLEFLAG33 := v_space;
        obj_clntpf.ROLEFLAG34 := v_space;
        obj_clntpf.ROLEFLAG35 := v_space;
        obj_clntpf.SRDATE     := v_effdate; --   SRDATE, --EFFDATE?,
        obj_clntpf.TERMID     := trim(vrcmTermid);
        obj_clntpf.TRDT       := TO_CHAR(sysdate, 'YYMMDD');
        obj_clntpf.TRTM       := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
        obj_clntpf.USRPRF     := userProfile;
        obj_clntpf.JOBNM      := scheduleName;
        obj_clntpf.DATIME     := LOCALTIMESTAMP;
        IF TRIM(v_lsurname) IS NOT NULL THEN
          obj_clntpf.LSURNAME := v_lsurname;
        ELSE
          obj_clntpf.LSURNAME := v_space;
        END IF;
        IF TRIM(v_lgivname) IS NOT NULL THEN
          obj_clntpf.LGIVNAME := v_lgivname;
        ELSE
          obj_clntpf.LGIVNAME := v_space;
        END IF;
        IF TRIM(v_zkanaddr01) IS NOT NULL THEN
          obj_clntpf.ZKANADDR01 := v_zkanaddr01;
        ELSE
          obj_clntpf.ZKANADDR01 := v_space;
        END IF;
        IF TRIM(v_zkanaddr02) IS NOT NULL THEN
          obj_clntpf.ZKANADDR02 := v_zkanaddr02;
        ELSE
          obj_clntpf.ZKANADDR02 := v_space;
        END IF;
        --IF TRIM(v_zkanaddr03) IS NOT NULL THEN
        --obj_clntpf.ZKANADDR03 := v_zkanaddr03;
        --ELSE
        obj_clntpf.ZKANADDR03 := v_space;
        --END IF;
        obj_clntpf.ZKANADDR04 := v_space;
        obj_clntpf.ZKANADDR05 := v_space;
        IF TRIM(v_zkanasurname) IS NOT NULL THEN
          obj_clntpf.ZKANASNM := v_zkanasurname;
        ELSE
          obj_clntpf.ZKANASNM := v_space;
        END IF;
        obj_clntpf.ZKANASNMNOR := v_zkanasurname;
        IF TRIM(v_zoccdsc) IS NOT NULL THEN
          obj_clntpf.ZOCCDSC := v_zoccdsc;
        ELSE
          obj_clntpf.ZOCCDSC := v_space;
        END IF;
        IF TRIM(v_zworkplce) IS NOT NULL THEN
          obj_clntpf.ZWORKPLCE := v_zworkplce;
        ELSE
          obj_clntpf.ZWORKPLCE := v_space;
        END IF;
        obj_clntpf.OCCPCLAS := v_space; --mps
        --SIT BUG FIX
        obj_clntpf.PAYROLLNO     := v_space;
        obj_clntpf.MIDDL01       := v_space;
        obj_clntpf.MIDDL02       := v_space;
        obj_clntpf.TLXNO         := v_space;
        obj_clntpf.TGRAM         := v_space;
        obj_clntpf.SALUTL        := v_space;
        obj_clntpf.STCA          := v_space;
        obj_clntpf.STCB          := v_space;
        obj_clntpf.STCC          := v_space;
        obj_clntpf.STCD          := v_space;
        obj_clntpf.STCE          := v_space;
        obj_clntpf.SNDXCDE       := v_space;
        obj_clntpf.STATE         := v_space;
        obj_clntpf.CTRYORIG      := v_space;
        obj_clntpf.ZADDRCD       := v_space;
        obj_clntpf.TELECTRYCODE  := v_space;
        obj_clntpf.TELECTRYCODE1 := v_space;
        obj_clntpf.ZDLIND        := v_space;
        obj_clntpf.DIRMKTMTD     := v_space;
        obj_clntpf.PREFCONMTD    := v_space;
        obj_clntpf.CLNTSTATECD   := v_space;
        obj_clntpf.FUNDADMINFLAG := v_space;
        obj_clntpf.FAXNO         := v_space;
        obj_clntpf.ECACT         := v_space;
        obj_clntpf.STAFFNO       := v_space;
        obj_clntpf.IDTYPE        := v_space;
        obj_clntpf.Z1GSTREGN     := v_space;
        obj_clntpf.Z1GSTREGD     := 0;
        obj_clntpf.CAPITAL       := 0;
        obj_clntpf.EXCEP         := v_space;

        INSERT INTO CLNTPF VALUES obj_clntpf;
      END IF;*/

      -- insert in  IG ZCLNPF table start-
      obj_zclnf.CLNTPFX := v_clntpfx;
      obj_zclnf.CLNTCOY := v_clntcoy;
      obj_zclnf.CLNTNUM := v_clntnum;
      obj_zclnf.CLTDOB  := n_cltdob;
      IF TRIM(v_lsurname) IS NOT NULL THEN
        obj_zclnf.LSURNAME := v_lsurname;
      ELSE
        obj_zclnf.LSURNAME := v_space;
      END IF;
      IF TRIM(v_lgivname) IS NOT NULL THEN
        obj_zclnf.LGIVNAME := v_lgivname;
      ELSE
        obj_zclnf.LGIVNAME := v_space;
      END IF;

      IF TRIM(v_zkanasurname) IS NOT NULL THEN
        obj_zclnf.ZKANASNM := v_zkanasurname;
      ELSE
        obj_zclnf.ZKANASNM := v_space;
      END IF;

      IF TRIM(v_zkanagivname) IS NOT NULL THEN
        obj_zclnf.ZKANAGNM := v_zkanagivname;
      ELSE
        obj_zclnf.ZKANAGNM := v_space;
      END IF;

      obj_zclnf.CLTSEX := v_cltsex;
      IF TRIM(v_cltpcode) IS NOT NULL THEN
        obj_zclnf.CLTPCODE := v_cltpcode;
      ELSE
        obj_zclnf.CLTPCODE := v_space;
      END IF;
      IF TRIM(v_zkanaddr01) IS NOT NULL THEN
        obj_zclnf.ZKANADDR01 := v_zkanaddr01;
      ELSE
        obj_zclnf.ZKANADDR01 := v_space;
      END IF;
      IF TRIM(v_zkanaddr02) IS NOT NULL THEN
        obj_zclnf.ZKANADDR02 := v_zkanaddr02;
      ELSE
        obj_zclnf.ZKANADDR02 := v_space;
      END IF;

      obj_zclnf.ZKANADDR04 := v_space; --v_zkanaddr04;not in stage table
      IF TRIM(v_cltaddr01) IS NOT NULL THEN
        obj_zclnf.CLTADDR01 := v_cltaddr01;
      ELSE
        obj_zclnf.CLTADDR01 := v_space;
      END IF;
      IF TRIM(v_cltaddr02) IS NOT NULL THEN
        obj_zclnf.CLTADDR02 := v_cltaddr02;
      ELSE
        obj_zclnf.CLTADDR02 := v_space;
      END IF;
      IF TRIM(v_cltaddr03) IS NOT NULL THEN
        obj_zclnf.CLTADDR03 := v_cltaddr03;
      ELSE
        obj_zclnf.CLTADDR03 := v_space;
      END IF;
      obj_zclnf.CLTADDR04 := v_space; --v_cltaddr04;not in stage table
      IF TRIM(v_cltphone01) IS NOT NULL THEN
        obj_zclnf.CLTPHONE01 := v_cltphone01;
      ELSE
        obj_zclnf.CLTPHONE01 := v_space;
      END IF;
      IF TRIM(v_cltphone02) IS NOT NULL THEN
        obj_zclnf.CLTPHONE02 := v_cltphone02;
      ELSE
        obj_zclnf.CLTPHONE02 := v_space;
      END IF;
      IF TRIM(v_zworkplce) IS NOT NULL THEN
        obj_zclnf.ZWORKPLCE := v_zworkplce;
      ELSE
        obj_zclnf.ZWORKPLCE := v_space;
      END IF;
      IF TRIM(v_occpcode) IS NOT NULL THEN
        obj_zclnf.OCCPCODE := v_occpcode;
      ELSE
        obj_zclnf.OCCPCODE := v_space;
      END IF;
      obj_zclnf.OCCPCLAS := v_space; ---v_occpclas  not in stage table
      IF TRIM(v_zoccdsc) IS NOT NULL THEN
        obj_zclnf.ZOCCDSC := v_zoccdsc;
      ELSE
        obj_zclnf.ZOCCDSC := v_space;
      END IF;
      -- IF TRIM(v_zaltrcde01) = 'N07' THEN -- CH3
      IF TRIM(v_zaltrcde01) = 'P09' THEN  -- CH3
        obj_zclnf.CLTDOBFLAG := v_yflag;
      ELSE
        obj_zclnf.CLTDOBFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N02' THEN
        obj_zclnf.LSURNAMEFLAG := v_yflag;
      ELSE
        obj_zclnf.LSURNAMEFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N02' THEN
        obj_zclnf.LGIVNAMEFLAG := v_yflag;
      ELSE
        obj_zclnf.LGIVNAMEFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N02' THEN
        obj_zclnf.ZKANASNMFLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANASNMFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N02' THEN
        obj_zclnf.ZKANAGNMFLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANAGNMFLAG := v_nflag;
      END IF;
      -- IF TRIM(v_zaltrcde01) = 'N07' THEN  -- CH3
      IF TRIM(v_zaltrcde01) = 'P09' THEN  --CH3
        obj_zclnf.CLTSEXFLAG := v_yflag;
      ELSE
        obj_zclnf.CLTSEXFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTPCODEFLAG := v_yflag;
      ELSE
        obj_zclnf.CLTPCODEFLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.ZKANADDR01FLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANADDR01FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.ZKANADDR02FLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANADDR02FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.ZKANADDR03FLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANADDR03FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.ZKANADDR04FLAG := v_yflag;
      ELSE
        obj_zclnf.ZKANADDR04FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTADDR01FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTADDR01FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTADDR02FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTADDR02FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTADDR03FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTADDR03FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTADDR04FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTADDR04FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTPHONE01FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTPHONE01FLAG := v_nflag;
      END IF;
      IF TRIM(v_zaltrcde01) = 'N01' THEN
        obj_zclnf.CLTPHONE02FLAG := v_yflag;
      ELSE
        obj_zclnf.CLTPHONE02FLAG := v_nflag;
      END IF;
      obj_zclnf.ZWORKPLCEFLAG := v_nflag;
      obj_zclnf.OCCPCODEFLAG  := v_nflag;
      obj_zclnf.OCCPCLASFLAG  := v_nflag;
      obj_zclnf.ZOCCDSCFLAG   := v_nflag;
      obj_zclnf.EFFDATE       := v_effdate;

      --SIT BUG FIX
      obj_zclnf.ZKANADDR03 := v_space;

      obj_zclnf.DATIME := CURRENT_TIMESTAMP;
      obj_zclnf.JOBNM := 'G1ZDCLTHIS';
      obj_zclnf.USRPRF := 'UNDERWR1';
      obj_zclnf.UNIQUE_NUMBER := v_unq_zdch_zcln; -- CH6

      INSERT INTO VIEW_ZCLNPF VALUES obj_zclnf;
      -- insert in  IG Jd1dta.ZCLNPF table end-

      -- VERSIONPF Insertion For SIT Bug Fix
      -- CH3 START --
      -- obj_versionpf.TRANNO  := v_zseqno + 1;  

      IF (v_zseqno = 0) THEN
         v_version_ctr         := 1;
      ELSE
         v_version_ctr         := v_version_ctr + 1;
      END IF;
      obj_versionpf.TRANNO  := v_version_ctr;
      -- CH3 END --
      obj_versionpf.CLNTNUM := v_clntnum;

      INSERT INTO VERSIONPF VALUES obj_versionpf;

      ---NEw business 
      IF (v_zseqno = 0) THEN
        --   obj_audit_clntpf. unique_number := 'a';

        obj_audit_clntpf. oldclntnum := v_clntnum;
        -- CH3 START --
        obj_audit_clntpf. oldclntpfx        := null;
        obj_audit_clntpf. oldclntcoy        := null;
        obj_audit_clntpf. oldtranid         := null;
        obj_audit_clntpf. oldvalidflag      := null;
        obj_audit_clntpf. oldclttype        := null;
        obj_audit_clntpf. oldsecuityno      := null;
        obj_audit_clntpf. oldpayrollno      := null;
        obj_audit_clntpf. oldsurname        := null;
        obj_audit_clntpf. oldgivname        := null;
        obj_audit_clntpf. oldsalut          := null;
        obj_audit_clntpf. oldinitials       := null;
        obj_audit_clntpf. oldcltsex         := null;
        obj_audit_clntpf. oldcltaddr01      := null;
        obj_audit_clntpf. oldcltaddr02      := null;
        obj_audit_clntpf. oldcltaddr03      := null;
        obj_audit_clntpf. oldcltaddr04      := null;
        obj_audit_clntpf. oldcltaddr05      := null;
        obj_audit_clntpf. oldcltpcode       := null;
        obj_audit_clntpf. oldctrycode       := null;
        obj_audit_clntpf. oldmailing        := null;
        obj_audit_clntpf. olddirmail        := null;
        obj_audit_clntpf. oldaddrtype       := null;
        obj_audit_clntpf. oldcltphone01     := null;
        obj_audit_clntpf. oldcltphone02     := null;
        obj_audit_clntpf. oldvip            := null;
        obj_audit_clntpf. oldoccpcode       := null;
        obj_audit_clntpf. oldservbrh        := null;
        obj_audit_clntpf. oldstatcode       := null;
        obj_audit_clntpf. oldcltdob         := 0;
        obj_audit_clntpf. oldsoe            := null;
        obj_audit_clntpf. olddocno          := null;
        obj_audit_clntpf. oldcltdod         := 0;
        obj_audit_clntpf. oldcltstat        := null;
        obj_audit_clntpf. oldcltmchg        := null;
        obj_audit_clntpf. oldmiddl01        := null;
        obj_audit_clntpf. oldmiddl02        := null;
        obj_audit_clntpf. oldmarryd         := null;
        obj_audit_clntpf. oldtlxno          := null;
        obj_audit_clntpf. oldfaxno          := null;
        obj_audit_clntpf. oldtgram          := null;
        obj_audit_clntpf. oldbirthp         := null;
        obj_audit_clntpf. oldsalutl         := null;
        obj_audit_clntpf. oldroleflag01     := null;
        obj_audit_clntpf. oldroleflag02     := null;
        obj_audit_clntpf. oldroleflag03     := null;
        obj_audit_clntpf. oldroleflag04     := null;
        obj_audit_clntpf. oldroleflag05     := null;
        obj_audit_clntpf. oldroleflag06     := null;
        obj_audit_clntpf. oldroleflag07     := null;
        obj_audit_clntpf. oldroleflag08     := null;
        obj_audit_clntpf. oldroleflag09     := null;
        obj_audit_clntpf. oldroleflag10     := null;
        obj_audit_clntpf. oldroleflag11     := null;
        obj_audit_clntpf. oldroleflag12     := null;
        obj_audit_clntpf. oldroleflag13     := null;
        obj_audit_clntpf. oldroleflag14     := null;
        obj_audit_clntpf. oldroleflag15     := null;
        obj_audit_clntpf. oldroleflag16     := null;
        obj_audit_clntpf. oldroleflag17     := null;
        obj_audit_clntpf. oldroleflag18     := null;
        obj_audit_clntpf. oldroleflag19     := null;
        obj_audit_clntpf. oldroleflag20     := null;
        obj_audit_clntpf. oldroleflag21     := null;
        obj_audit_clntpf. oldroleflag22     := null;
        obj_audit_clntpf. oldroleflag23     := null;
        obj_audit_clntpf. oldroleflag24     := null;
        obj_audit_clntpf. oldroleflag25     := null;
        obj_audit_clntpf. oldroleflag26     := null;
        obj_audit_clntpf. oldroleflag27     := null;
        obj_audit_clntpf. oldroleflag28     := null;
        obj_audit_clntpf. oldroleflag29     := null;
        obj_audit_clntpf. oldroleflag30     := null;
        obj_audit_clntpf. oldroleflag31     := null;
        obj_audit_clntpf. oldroleflag32     := null;
        obj_audit_clntpf. oldroleflag33     := null;
        obj_audit_clntpf. oldroleflag34     := null;
        obj_audit_clntpf. oldroleflag35     := null;
        obj_audit_clntpf. oldstca           := null;
        obj_audit_clntpf. oldstcb           := null;
        obj_audit_clntpf. oldstcc           := null;
        obj_audit_clntpf. oldstcd           := null;
        obj_audit_clntpf. oldstce           := null;
        obj_audit_clntpf. oldprocflag       := null;
        obj_audit_clntpf. oldtermid         := null;
        obj_audit_clntpf. olduser_t         := 0;
        obj_audit_clntpf. oldtrdt           := 0;
        obj_audit_clntpf. oldtrtm           := 0;
        obj_audit_clntpf. oldsndxcde        := null;
        obj_audit_clntpf. oldnatlty         := null;
        obj_audit_clntpf. oldfao            := null;
        obj_audit_clntpf. oldcltind         := null;
        obj_audit_clntpf. oldstate          := null;
        obj_audit_clntpf. oldlanguage       := null;
        obj_audit_clntpf. oldcapital        := 0;
        obj_audit_clntpf. oldctryorig       := null;
        obj_audit_clntpf. oldecact          := null;
        obj_audit_clntpf. oldethorig        := null;
        obj_audit_clntpf. oldsrdate         := 0;
        obj_audit_clntpf. oldstaffno        := null;
        obj_audit_clntpf. oldlsurname       := null;
        obj_audit_clntpf. oldlgivname       := null;
        obj_audit_clntpf. oldtaxflag        := null;
        obj_audit_clntpf. oldusrprf         := userProfile;
        obj_audit_clntpf. oldjobnm          := scheduleName;
        obj_audit_clntpf. olddatime         := LOCALTIMESTAMP;
        obj_audit_clntpf. oldidtype         := null;
        obj_audit_clntpf. oldz1gstregn      := null;
        obj_audit_clntpf. oldz1gstregd      := 0;
        obj_audit_clntpf. oldkanjisurname   := null;
        obj_audit_clntpf. oldkanjigivname   := null;
        obj_audit_clntpf. oldkanjicltaddr01 := null;
        obj_audit_clntpf. oldkanjicltaddr02 := null;
        obj_audit_clntpf. oldkanjicltaddr03 := null;
        obj_audit_clntpf. oldkanjicltaddr04 := null;
        obj_audit_clntpf. oldkanjicltaddr05 := null;
        obj_audit_clntpf. oldexcep 	        := null;
        obj_audit_clntpf. oldzkanasnm       := null;
        obj_audit_clntpf. oldzkanagnm       := null;
        obj_audit_clntpf. oldzkanaddr01     := null;
        obj_audit_clntpf. oldzkanaddr02     := null;
        obj_audit_clntpf. oldzkanaddr03     := null;
        obj_audit_clntpf. oldzkanaddr04     := null;
        obj_audit_clntpf. oldzkanaddr05     := null;
        obj_audit_clntpf. oldzaddrcd        := null;
        obj_audit_clntpf. oldabusnum        := null;
        obj_audit_clntpf. oldbranchid       := null;
        obj_audit_clntpf. oldzkanasnmnor    := null;
        obj_audit_clntpf. oldzkanagnmnor    := null;
        obj_audit_clntpf. oldtelectrycode   := null;
        obj_audit_clntpf. oldtelectrycode1  := null;
        -- CH3 END --
        obj_audit_clntpf. newclntpfx := o_defaultvalues('CLNTPFX');
        obj_audit_clntpf. newclntcoy := o_defaultvalues('CLNTCOY');
        obj_audit_clntpf. newclntnum := v_clntnum;
        obj_audit_clntpf. newtranid := v_tranid;
        obj_audit_clntpf. newvalidflag := o_defaultvalues('VALIDFLAG');
        obj_audit_clntpf. newclttype := o_defaultvalues('CLTTYPE');
        obj_audit_clntpf. newsecuityno := v_space;
        obj_audit_clntpf. newpayrollno := v_space;
        obj_audit_clntpf. newsurname := v_lsurname;
        obj_audit_clntpf. newgivname := v_lgivname;
        obj_audit_clntpf. newsalut := v_space;
        obj_audit_clntpf. newinitials := v_initials;
        obj_audit_clntpf. newcltsex := v_cltsex;
        obj_audit_clntpf. newcltaddr01 := v_cltaddr01;
        obj_audit_clntpf. newcltaddr02 := v_cltaddr02;
        obj_audit_clntpf. newcltaddr03 := v_cltaddr03;
        obj_audit_clntpf. newcltaddr04 := v_space;
        obj_audit_clntpf. newcltaddr05 := v_space;
        obj_audit_clntpf. newcltpcode := v_cltpcode;
        obj_audit_clntpf. newctrycode := 'JPN';
        obj_audit_clntpf. newmailing := o_defaultvalues('MAILING');
        obj_audit_clntpf.newdirmail := o_defaultvalues('DIRMAIL');
        obj_audit_clntpf. newaddrtype := v_addrtype;
        obj_audit_clntpf. newcltphone01 := v_space;
        obj_audit_clntpf. newcltphone02 := v_cltphone02;
        obj_audit_clntpf. newvip := o_defaultvalues('VIP');
        obj_audit_clntpf. newoccpcode := v_occpcode;
        obj_audit_clntpf. newservbrh := '31';
        obj_audit_clntpf. newstatcode := o_defaultvalues('STATCODE');
        obj_audit_clntpf. newcltdob := n_cltdob;
        obj_audit_clntpf. newsoe := o_defaultvalues('SOE');
        obj_audit_clntpf. newdocno := o_defaultvalues('DOCNO');
        obj_audit_clntpf. newcltdod := o_defaultvalues('CLTDOD');
        obj_audit_clntpf. newcltstat := o_defaultvalues('CLTSTAT');
        obj_audit_clntpf. newcltmchg := o_defaultvalues('CLTMCHG');
        obj_audit_clntpf. newmiddl01 := v_space;
        obj_audit_clntpf. newmiddl02 := v_space;
        obj_audit_clntpf. newmarryd := o_defaultvalues('MARRYD');
        obj_audit_clntpf. newtlxno := v_space;
        obj_audit_clntpf. newfaxno := v_space;
        obj_audit_clntpf. newtgram := v_space;
        obj_audit_clntpf. newbirthp := o_defaultvalues('BIRTHP');
        obj_audit_clntpf. newsalutl := v_space;
        obj_audit_clntpf. newroleflag01 := v_space;
        obj_audit_clntpf. newroleflag02 := v_space;
        obj_audit_clntpf. newroleflag03 := v_space;
        obj_audit_clntpf. newroleflag04 := v_space;
        obj_audit_clntpf. newroleflag05 := v_space;
        obj_audit_clntpf. newroleflag06 := v_space;
        obj_audit_clntpf. newroleflag07 := v_space;
        obj_audit_clntpf. newroleflag08 := v_space;
        obj_audit_clntpf. newroleflag09 := v_space;
        obj_audit_clntpf. newroleflag10 := v_space;
        obj_audit_clntpf. newroleflag11 := v_space;
        obj_audit_clntpf. newroleflag12 := v_space;
        obj_audit_clntpf. newroleflag13 := v_space;
        obj_audit_clntpf. newroleflag14 := 'Y';
        obj_audit_clntpf. newroleflag15 := v_space;
        obj_audit_clntpf. newroleflag16 := v_space;
        obj_audit_clntpf. newroleflag17 := v_space;
        obj_audit_clntpf. newroleflag18 := 'Y';
        obj_audit_clntpf. newroleflag19 := v_space;
        obj_audit_clntpf. newroleflag20 := v_space;
        obj_audit_clntpf. newroleflag21 := v_space;
        obj_audit_clntpf. newroleflag22 := v_space;
        obj_audit_clntpf. newroleflag23 := v_space;
        obj_audit_clntpf. newroleflag24 := v_space;
        obj_audit_clntpf. newroleflag25 := v_space;
        obj_audit_clntpf. newroleflag26 := v_space;
        obj_audit_clntpf. newroleflag27 := v_space;
        obj_audit_clntpf. newroleflag28 := v_space;
        obj_audit_clntpf. newroleflag29 := v_space;
        obj_audit_clntpf. newroleflag30 := v_space;
        obj_audit_clntpf. newroleflag31 := v_space;
        obj_audit_clntpf. newroleflag32 := v_space;
        obj_audit_clntpf. newroleflag33 := v_space;
        obj_audit_clntpf. newroleflag34 := v_space;
        obj_audit_clntpf. newroleflag35 := v_space;
        obj_audit_clntpf. newstca := v_space;
        obj_audit_clntpf. newstcb := v_space;
        obj_audit_clntpf. newstcc := v_space;
        obj_audit_clntpf. newstcd := v_space;
        obj_audit_clntpf. newstce := v_space;
        obj_audit_clntpf. newprocflag := null;
        obj_audit_clntpf. newtermid := trim(vrcmTermid);
        --  obj_audit_clntpf. newuser_t := v_space;
        obj_audit_clntpf. newtrdt := TO_CHAR(sysdate, 'YYMMDD');
        obj_audit_clntpf. newtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
        obj_audit_clntpf. newsndxcde := v_space;
        obj_audit_clntpf. newnatlty := o_defaultvalues('NATLTY');
        obj_audit_clntpf. newfao := o_defaultvalues('FAO');
        obj_audit_clntpf. newcltind := 'C';
        obj_audit_clntpf. newstate := v_space;
        obj_audit_clntpf. newlanguage := o_defaultvalues('LANGUAGE');
        obj_audit_clntpf. newcapital := 0;
        obj_audit_clntpf. newctryorig := v_space;
        obj_audit_clntpf. newecact := v_space;
        obj_audit_clntpf. newethorig := o_defaultvalues('ETHORIG');
        obj_audit_clntpf. newsrdate := 19010101; --CH5
        obj_audit_clntpf. newstaffno := v_space;
        obj_audit_clntpf. newlsurname := v_lsurname;
        obj_audit_clntpf. newlgivname := v_lgivname;
        obj_audit_clntpf. newtaxflag := o_defaultvalues('TAXFLAG');
        obj_audit_clntpf. newusrprf := userProfile;
        obj_audit_clntpf. newjobnm := scheduleName;
        obj_audit_clntpf. newdatime := LOCALTIMESTAMP;
        obj_audit_clntpf. newidtype := v_space;
        obj_audit_clntpf. newz1gstregn := v_space;
        obj_audit_clntpf. newz1gstregd := 0;
        obj_audit_clntpf. newkanjisurname := v_space; --?
        obj_audit_clntpf. newkanjigivname := v_space; --?
        obj_audit_clntpf. newkanjicltaddr01 := v_space; --?
        obj_audit_clntpf. newkanjicltaddr02 := v_space; --?
        obj_audit_clntpf. newkanjicltaddr03 := v_space; --?
        obj_audit_clntpf. newkanjicltaddr04 := v_space; --?
        obj_audit_clntpf. newkanjicltaddr05 := v_space; --?
        obj_audit_clntpf. newexcep := v_space;
        obj_audit_clntpf. newzkanasnm := v_zkanasurname;
        obj_audit_clntpf. newzkanagnm := v_zkanagivname;
        obj_audit_clntpf. newzkanaddr01 := v_zkanaddr01;
        obj_audit_clntpf. newzkanaddr02 := v_zkanaddr02;
        obj_audit_clntpf. newzkanaddr03 := v_space;
        obj_audit_clntpf. newzkanaddr04 := v_space;
        obj_audit_clntpf. newzkanaddr05 := v_space;
        obj_audit_clntpf. newzaddrcd := v_space;
        obj_audit_clntpf. newabusnum := o_defaultvalues('ABUSNUM');
        obj_audit_clntpf. newbranchid := o_defaultvalues('BRANCHID');
        obj_audit_clntpf. newzkanasnmnor := v_zkanasurname;
        obj_audit_clntpf. newzkanagnmnor := v_zkanagivname;
        obj_audit_clntpf. newtelectrycode := v_space;
        obj_audit_clntpf. newtelectrycode1 := v_space;
        --  obj_audit_clntpf. userid := 'a';
        obj_audit_clntpf. action := 'INSERT';
        obj_audit_clntpf. tranno := v_version_ctr;   --CH3
        obj_audit_clntpf. systemdate := sysdate;
        --  obj_audit_clntpf. oldoccpclas := 'a';
        --  obj_audit_clntpf. newoccpclas := 'a';

        Insert into audit_clntpf values obj_audit_clntpf;

        --   obj_audit_clexp. unique_number := 'a';

        obj_audit_clexp. oldclntnum := v_clntnum;

        obj_audit_clexp. newclntpfx := o_defaultvalues('CLNTPFX');
        obj_audit_clexp. newclntcoy := o_defaultvalues('CLNTCOY');
        obj_audit_clexp. newclntnum := v_clntnum;
        obj_audit_clexp. newrdidtelno := o_defaultvalues('RDIDTELNO');

        IF TRIM(v_cltphone01) IS NOT NULL THEN
          obj_audit_clexp. newrmblphone := v_cltphone01;
        ELSE
          obj_audit_clexp. newrmblphone := v_space;
        END IF;

        obj_audit_clexp. newrpager := o_defaultvalues('RPAGER');
        obj_audit_clexp. newfaxno := o_defaultvalues('FAXNO');
        obj_audit_clexp. newrinternet := o_defaultvalues('RINTERNET');
        obj_audit_clexp. newrtaxidnum := o_defaultvalues('RTAXIDNUM');
        obj_audit_clexp. newrstaflag := o_defaultvalues('RSTAFLAG');
        obj_audit_clexp. newsplindic := v_space;
        obj_audit_clexp. newzspecind := o_defaultvalues('ZSPECIND');
        obj_audit_clexp. newoldidno := o_defaultvalues('OLDIDNO');
        obj_audit_clexp. newusrprf := userProfile;
        obj_audit_clexp. newjobnm := scheduleName;
        obj_audit_clexp. newdatime := sysdate;
        obj_audit_clexp. newvalidflag := o_defaultvalues('VALIDFLAG');
        -- obj_audit_clexp. userid := 'a';
        obj_audit_clexp. action := 'INSERT';
        obj_audit_clexp. tranno := v_version_ctr;   --CH3
        obj_audit_clexp. systemdate := sysdate;

        insert into audit_clexpf values obj_audit_clexp;
      END IF;
      ---alteration
      IF (v_zseqno > 0) THEN
        IF ((TRIM(v_zaltrcde01) = 'N01') OR (TRIM(v_zaltrcde01) = 'N02') OR
        -- (TRIM(v_zaltrcde01) = 'N07')) THEN  -- CH3
           (TRIM(v_zaltrcde01) = 'P09')) THEN   -- CH3
          SELECT SEQ_CLNTPF.nextval INTO v_unq_audit_clntpf FROM dual;
          obj_audit_clntpf. unique_number := v_unq_audit_clntpf;
          obj_audit_clntpf. oldclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clntpf. oldclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clntpf. oldclntnum := v_clntnum;
          obj_audit_clntpf. oldtranid := v_tranid;
          obj_audit_clntpf. oldvalidflag := o_defaultvalues('VALIDFLAG');
          obj_audit_clntpf. oldclttype := o_defaultvalues('CLTTYPE');
          obj_audit_clntpf. oldsecuityno := v_space;
          obj_audit_clntpf. oldpayrollno := v_space;
          obj_audit_clntpf. oldsurname := obj_client_old.lsurname;
          obj_audit_clntpf. oldgivname := obj_client_old.lgivname;
          obj_audit_clntpf. oldsalut := v_space;
          obj_audit_clntpf. oldinitials := v_initials;
          obj_audit_clntpf. oldcltsex := obj_client_old.cltsex;
          obj_audit_clntpf. oldcltaddr01 := obj_client_old.cltaddr01;
          obj_audit_clntpf. oldcltaddr02 := obj_client_old.cltaddr02;
          obj_audit_clntpf. oldcltaddr03 := obj_client_old.cltaddr03;
          obj_audit_clntpf. oldcltaddr04 := v_space;
          obj_audit_clntpf. oldcltaddr05 := v_space;
          obj_audit_clntpf. oldcltpcode := obj_client_old.cltpcode;
          obj_audit_clntpf. oldctrycode := 'JPN';
          obj_audit_clntpf. oldmailing := o_defaultvalues('MAILING');
          obj_audit_clntpf. olddirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clntpf. oldaddrtype := obj_client_old.addrtype;
          obj_audit_clntpf. oldcltphone01 := v_space;
          obj_audit_clntpf. oldcltphone02 := obj_client_old.cltphone02;
          obj_audit_clntpf. oldvip := o_defaultvalues('VIP');
          obj_audit_clntpf. oldoccpcode := obj_client_old.occpcode;
          obj_audit_clntpf. oldservbrh := '31';
          obj_audit_clntpf. oldstatcode := o_defaultvalues('STATCODE');
          obj_audit_clntpf. oldcltdob := obj_client_old.cltdob;
          obj_audit_clntpf. oldsoe := o_defaultvalues('SOE');
          obj_audit_clntpf. olddocno := o_defaultvalues('DOCNO');
          obj_audit_clntpf. oldcltdod := o_defaultvalues('CLTDOD');
          obj_audit_clntpf. oldcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clntpf. oldcltmchg := o_defaultvalues('CLTMCHG');
          obj_audit_clntpf. oldmiddl01 := v_space;
          obj_audit_clntpf. oldmiddl02 := v_space;
          obj_audit_clntpf. oldmarryd := o_defaultvalues('MARRYD');
          obj_audit_clntpf. oldtlxno := v_space;
          obj_audit_clntpf. oldfaxno := v_space;
          obj_audit_clntpf. oldtgram := v_space;
          obj_audit_clntpf. oldbirthp := o_defaultvalues('BIRTHP');
          obj_audit_clntpf. oldsalutl := v_space;
          obj_audit_clntpf. oldroleflag01 := v_space;
          obj_audit_clntpf. oldroleflag02 := v_space;
          obj_audit_clntpf. oldroleflag03 := v_space;
          obj_audit_clntpf. oldroleflag04 := v_space;
          obj_audit_clntpf. oldroleflag05 := v_space;
          obj_audit_clntpf. oldroleflag06 := v_space;
          obj_audit_clntpf. oldroleflag07 := v_space;
          obj_audit_clntpf. oldroleflag08 := v_space;
          obj_audit_clntpf. oldroleflag09 := v_space;
          obj_audit_clntpf. oldroleflag10 := v_space;
          obj_audit_clntpf. oldroleflag11 := v_space;
          obj_audit_clntpf. oldroleflag12 := v_space;
          obj_audit_clntpf. oldroleflag13 := v_space;
          obj_audit_clntpf. oldroleflag14 := 'Y';
          obj_audit_clntpf. oldroleflag15 := v_space;
          obj_audit_clntpf. oldroleflag16 := v_space;
          obj_audit_clntpf. oldroleflag17 := v_space;
          obj_audit_clntpf. oldroleflag18 := 'Y';
          obj_audit_clntpf. oldroleflag19 := v_space;
          obj_audit_clntpf. oldroleflag20 := v_space;
          obj_audit_clntpf. oldroleflag21 := v_space;
          obj_audit_clntpf. oldroleflag22 := v_space;
          obj_audit_clntpf. oldroleflag23 := v_space;
          obj_audit_clntpf. oldroleflag24 := v_space;
          obj_audit_clntpf. oldroleflag25 := v_space;
          obj_audit_clntpf. oldroleflag26 := v_space;
          obj_audit_clntpf. oldroleflag27 := v_space;
          obj_audit_clntpf. oldroleflag28 := v_space;
          obj_audit_clntpf. oldroleflag29 := v_space;
          obj_audit_clntpf. oldroleflag30 := v_space;
          obj_audit_clntpf. oldroleflag31 := v_space;
          obj_audit_clntpf. oldroleflag32 := v_space;
          obj_audit_clntpf. oldroleflag33 := v_space;
          obj_audit_clntpf. oldroleflag34 := v_space;
          obj_audit_clntpf. oldroleflag35 := v_space;
          obj_audit_clntpf. oldstca := v_space;
          obj_audit_clntpf. oldstcb := v_space;
          obj_audit_clntpf. oldstcc := v_space;
          obj_audit_clntpf. oldstcd := v_space;
          obj_audit_clntpf. oldstce := v_space;
          obj_audit_clntpf. oldprocflag := null;
          obj_audit_clntpf. oldtermid := trim(vrcmTermid);
          -- obj_audit_clntpf. olduser_t := v_space;
          obj_audit_clntpf. oldtrdt := TO_CHAR(sysdate, 'YYMMDD');
          obj_audit_clntpf. oldtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
          obj_audit_clntpf. oldsndxcde := v_space;
          obj_audit_clntpf. oldnatlty := o_defaultvalues('NATLTY');
          obj_audit_clntpf. oldfao := o_defaultvalues('FAO');
          obj_audit_clntpf. oldcltind := 'C';
          obj_audit_clntpf. oldstate := v_space;
          obj_audit_clntpf. oldlanguage := o_defaultvalues('LANGUAGE');
          obj_audit_clntpf. oldcapital := 0;
          obj_audit_clntpf. oldctryorig := v_space;
          obj_audit_clntpf. oldecact := v_space;
          obj_audit_clntpf. oldethorig := o_defaultvalues('ETHORIG');
          obj_audit_clntpf. oldsrdate := 19010101; --CH5
          obj_audit_clntpf. oldstaffno := v_space;
          obj_audit_clntpf. oldlsurname := obj_client_old.lsurname;
          obj_audit_clntpf. oldlgivname := obj_client_old.lgivname;
          obj_audit_clntpf. oldtaxflag := o_defaultvalues('TAXFLAG');
          obj_audit_clntpf. oldusrprf := userProfile;
          obj_audit_clntpf. oldjobnm := scheduleName;
          obj_audit_clntpf. olddatime := LOCALTIMESTAMP;
          obj_audit_clntpf. oldidtype := v_space;
          obj_audit_clntpf. oldz1gstregn := v_space;
          obj_audit_clntpf. oldz1gstregd := 0;
          obj_audit_clntpf. oldkanjisurname := v_space;
          obj_audit_clntpf. oldkanjigivname := v_space;
          obj_audit_clntpf. oldkanjicltaddr01 := v_space;
          obj_audit_clntpf. oldkanjicltaddr02 := v_space;
          obj_audit_clntpf. oldkanjicltaddr03 := v_space;
          obj_audit_clntpf. oldkanjicltaddr04 := v_space;
          obj_audit_clntpf. oldkanjicltaddr05 := v_space;
          obj_audit_clntpf. oldexcep := v_space;
          obj_audit_clntpf. oldzkanasnm := obj_client_old.zkanasurname;
          obj_audit_clntpf. oldzkanagnm := obj_client_old.zkanagivname;
          obj_audit_clntpf. oldzkanaddr01 := obj_client_old.zkanaddr01;
          obj_audit_clntpf. oldzkanaddr02 := obj_client_old.zkanaddr02;
          obj_audit_clntpf. oldzkanaddr03 := v_space;
          obj_audit_clntpf. oldzkanaddr04 := v_space;
          obj_audit_clntpf. oldzkanaddr05 := v_space;
          obj_audit_clntpf. oldzaddrcd := v_space;
          obj_audit_clntpf. oldabusnum := o_defaultvalues('ABUSNUM');
          obj_audit_clntpf. oldbranchid := o_defaultvalues('BRANCHID');
          obj_audit_clntpf. oldzkanasnmnor := obj_client_old.zkanasurname;
          obj_audit_clntpf. oldzkanagnmnor := obj_client_old.zkanagivname;
          obj_audit_clntpf. oldtelectrycode := v_space;
          obj_audit_clntpf. oldtelectrycode1 := v_space;
          -----------------NEW -----------------------
          obj_audit_clntpf. newclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clntpf. newclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clntpf. newclntnum := v_clntnum;
          obj_audit_clntpf. newtranid := v_tranid;
          obj_audit_clntpf. newvalidflag := o_defaultvalues('VALIDFLAG');
          obj_audit_clntpf. newclttype := o_defaultvalues('CLTTYPE');
          obj_audit_clntpf. newsecuityno := v_space;
          obj_audit_clntpf. newpayrollno := v_space;
          obj_audit_clntpf. newsurname := v_lsurname;
          obj_audit_clntpf. newgivname := v_lgivname;
          obj_audit_clntpf. newsalut := v_space;
          obj_audit_clntpf. newinitials := v_initials;
          obj_audit_clntpf. newcltsex := v_cltsex;
          obj_audit_clntpf. newcltaddr01 := v_cltaddr01;
          obj_audit_clntpf. newcltaddr02 := v_cltaddr02;
          obj_audit_clntpf. newcltaddr03 := v_cltaddr03;
          obj_audit_clntpf. newcltaddr04 := v_space;
          obj_audit_clntpf. newcltaddr05 := v_space;
          obj_audit_clntpf. newcltpcode := v_cltpcode;
          obj_audit_clntpf. newctrycode := 'JPN';
          obj_audit_clntpf. newmailing := o_defaultvalues('MAILING');
          obj_audit_clntpf.newdirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clntpf. newaddrtype := v_addrtype;
          obj_audit_clntpf. newcltphone01 := v_space;
          obj_audit_clntpf. newcltphone02 := v_cltphone02;
          obj_audit_clntpf. newvip := o_defaultvalues('VIP');
          obj_audit_clntpf. newoccpcode := v_occpcode;
          obj_audit_clntpf. newservbrh := '31';
          obj_audit_clntpf. newstatcode := o_defaultvalues('STATCODE');
          obj_audit_clntpf. newcltdob := n_cltdob;
          obj_audit_clntpf. newsoe := o_defaultvalues('SOE');
          obj_audit_clntpf. newdocno := o_defaultvalues('DOCNO');
          obj_audit_clntpf. newcltdod := o_defaultvalues('CLTDOD');
          obj_audit_clntpf. newcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clntpf. newcltmchg := o_defaultvalues('CLTMCHG');
          obj_audit_clntpf. newmiddl01 := v_space;
          obj_audit_clntpf. newmiddl02 := v_space;
          obj_audit_clntpf. newmarryd := o_defaultvalues('MARRYD');
          obj_audit_clntpf. newtlxno := v_space;
          obj_audit_clntpf. newfaxno := v_space;
          obj_audit_clntpf. newtgram := v_space;
          obj_audit_clntpf. newbirthp := o_defaultvalues('BIRTHP');
          obj_audit_clntpf. newsalutl := v_space;
          obj_audit_clntpf. newroleflag01 := v_space;
          obj_audit_clntpf. newroleflag02 := v_space;
          obj_audit_clntpf. newroleflag03 := v_space;
          obj_audit_clntpf. newroleflag04 := v_space;
          obj_audit_clntpf. newroleflag05 := v_space;
          obj_audit_clntpf. newroleflag06 := v_space;
          obj_audit_clntpf. newroleflag07 := v_space;
          obj_audit_clntpf. newroleflag08 := v_space;
          obj_audit_clntpf. newroleflag09 := v_space;
          obj_audit_clntpf. newroleflag10 := v_space;
          obj_audit_clntpf. newroleflag11 := v_space;
          obj_audit_clntpf. newroleflag12 := v_space;
          obj_audit_clntpf. newroleflag13 := v_space;
          obj_audit_clntpf. newroleflag14 := 'Y';
          obj_audit_clntpf. newroleflag15 := v_space;
          obj_audit_clntpf. newroleflag16 := v_space;
          obj_audit_clntpf. newroleflag17 := v_space;
          obj_audit_clntpf. newroleflag18 := 'Y';
          obj_audit_clntpf. newroleflag19 := v_space;
          obj_audit_clntpf. newroleflag20 := v_space;
          obj_audit_clntpf. newroleflag21 := v_space;
          obj_audit_clntpf. newroleflag22 := v_space;
          obj_audit_clntpf. newroleflag23 := v_space;
          obj_audit_clntpf. newroleflag24 := v_space;
          obj_audit_clntpf. newroleflag25 := v_space;
          obj_audit_clntpf. newroleflag26 := v_space;
          obj_audit_clntpf. newroleflag27 := v_space;
          obj_audit_clntpf. newroleflag28 := v_space;
          obj_audit_clntpf. newroleflag29 := v_space;
          obj_audit_clntpf. newroleflag30 := v_space;
          obj_audit_clntpf. newroleflag31 := v_space;
          obj_audit_clntpf. newroleflag32 := v_space;
          obj_audit_clntpf. newroleflag33 := v_space;
          obj_audit_clntpf. newroleflag34 := v_space;
          obj_audit_clntpf. newroleflag35 := v_space;
          obj_audit_clntpf. newstca := v_space;
          obj_audit_clntpf. newstcb := v_space;
          obj_audit_clntpf. newstcc := v_space;
          obj_audit_clntpf. newstcd := v_space;
          obj_audit_clntpf. newstce := v_space;
          obj_audit_clntpf. newprocflag := null;
          obj_audit_clntpf. newtermid := trim(vrcmTermid);
          --  obj_audit_clntpf. newuser_t := v_space;
          obj_audit_clntpf. newtrdt := TO_CHAR(sysdate, 'YYMMDD');
          obj_audit_clntpf. newtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
          obj_audit_clntpf. newsndxcde := v_space;
          obj_audit_clntpf. newnatlty := o_defaultvalues('NATLTY');
          obj_audit_clntpf. newfao := o_defaultvalues('FAO');
          obj_audit_clntpf. newcltind := 'C';
          obj_audit_clntpf. newstate := v_space;
          obj_audit_clntpf. newlanguage := o_defaultvalues('LANGUAGE');
          obj_audit_clntpf. newcapital := 0;
          obj_audit_clntpf. newctryorig := v_space;
          obj_audit_clntpf. newecact := v_space;
          obj_audit_clntpf. newethorig := o_defaultvalues('ETHORIG');
          obj_audit_clntpf. newsrdate := 19010101;  -- CH5
          obj_audit_clntpf. newstaffno := v_space;
          obj_audit_clntpf. newlsurname := v_lsurname;
          obj_audit_clntpf. newlgivname := v_lgivname;
          obj_audit_clntpf. newtaxflag := o_defaultvalues('TAXFLAG');
          obj_audit_clntpf. newusrprf := userProfile;
          obj_audit_clntpf. newjobnm := scheduleName;
          obj_audit_clntpf. newdatime := LOCALTIMESTAMP;
          obj_audit_clntpf. newidtype := v_space;
          obj_audit_clntpf. newz1gstregn := v_space;
          obj_audit_clntpf. newz1gstregd := 0;
          obj_audit_clntpf. newkanjisurname := v_space; --?
          obj_audit_clntpf. newkanjigivname := v_space; --?
          obj_audit_clntpf. newkanjicltaddr01 := v_space; --?
          obj_audit_clntpf. newkanjicltaddr02 := v_space; --?
          obj_audit_clntpf. newkanjicltaddr03 := v_space; --?
          obj_audit_clntpf. newkanjicltaddr04 := v_space; --?
          obj_audit_clntpf. newkanjicltaddr05 := v_space; --?
          obj_audit_clntpf. newexcep := v_space;
          obj_audit_clntpf. newzkanasnm := v_zkanasurname;
          obj_audit_clntpf. newzkanagnm := v_zkanagivname;
          obj_audit_clntpf. newzkanaddr01 := v_zkanaddr01;
          obj_audit_clntpf. newzkanaddr02 := v_zkanaddr02;
          obj_audit_clntpf. newzkanaddr03 := v_space;
          obj_audit_clntpf. newzkanaddr04 := v_space;
          obj_audit_clntpf. newzkanaddr05 := v_space;
          obj_audit_clntpf. newzaddrcd := v_space;
          obj_audit_clntpf. newabusnum := o_defaultvalues('ABUSNUM');
          obj_audit_clntpf. newbranchid := o_defaultvalues('BRANCHID');
          obj_audit_clntpf. newzkanasnmnor := v_zkanasurname;
          obj_audit_clntpf. newzkanagnmnor := v_zkanagivname;
          obj_audit_clntpf. newtelectrycode := v_space;
          obj_audit_clntpf. newtelectrycode1 := v_space;
          --  obj_audit_clntpf. userid := 'a';
          obj_audit_clntpf. action := 'UPDATE';
          obj_audit_clntpf. tranno := v_version_ctr;  -- CH3
          obj_audit_clntpf. systemdate := sysdate;

          Insert into audit_clntpf values obj_audit_clntpf;

          obj_audit_clnt. unique_number := v_unq_audit_clntpf;
          obj_audit_clnt. clntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clnt. clntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clnt. clntnum := v_clntnum;
          obj_audit_clnt. tranid := v_tranid;
          obj_audit_clnt. oldsurname := obj_client_old.lsurname;
          obj_audit_clnt. oldgivname := obj_client_old.lgivname;
          obj_audit_clnt. oldcltaddr01 := obj_client_old.cltaddr01;
          obj_audit_clnt. oldcltaddr02 := obj_client_old.cltaddr02;
          obj_audit_clnt. oldcltaddr03 := obj_client_old.cltaddr03;
          obj_audit_clnt. oldcltaddr04 := v_space;
          obj_audit_clnt. oldcltaddr05 := v_space;
          obj_audit_clnt. oldclttyp := o_defaultvalues('CLTTYPE');
          obj_audit_clnt. oldctrycode := 'JPN';
          obj_audit_clnt. oldmailing := o_defaultvalues('MAILING');
          obj_audit_clnt. olddirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clnt. oldaddrtype := obj_client_old.addrtype;
          obj_audit_clnt. oldcltphone01 := v_space;
          obj_audit_clnt. oldcltphone02 := obj_client_old.cltphone02;
          obj_audit_clnt. oldcltdob := obj_client_old.cltdob;
          obj_audit_clnt. oldcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clnt. oldsalutl := v_space;
          -------------------NEW ----------------
          obj_audit_clnt. newsurname := v_lsurname;
          obj_audit_clnt. newgivname := v_lgivname;
          obj_audit_clnt. newcltaddr01 := v_cltaddr01;
          obj_audit_clnt. newcltaddr02 := v_cltaddr02;
          obj_audit_clnt. newcltaddr03 := v_cltaddr03;
          obj_audit_clnt. newcltaddr04 := v_space;
          obj_audit_clnt. newcltaddr05 := v_space;
          obj_audit_clnt. newclttyp := o_defaultvalues('CLTTYPE');
          obj_audit_clnt. newctrycode := 'JPN';
          obj_audit_clnt. newmailing := o_defaultvalues('MAILING');
          obj_audit_clnt. newdirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clnt. newaddrtype := v_addrtype;
          obj_audit_clnt. newcltphone01 := v_space;
          obj_audit_clnt. newcltphone02 := obj_client_old.cltphone02;
          obj_audit_clnt. newcltdob := n_cltdob;
          obj_audit_clnt. newcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clnt. newsalutl := v_space;
          obj_audit_clnt. usrprf := userProfile;
          obj_audit_clnt. jobnm := scheduleName;
          -- obj_audit_clnt. userid := 'a';
          obj_audit_clnt. action := 'UPDATE';
          obj_audit_clnt. systemdate := sysdate;

          insert into audit_clnt values obj_audit_clnt;

        END IF;
        IF ((TRIM(v_zaltrcde01) = 'N01') and
           (TRIM(obj_client_old.cltphone01) != TRIM(obj_client.cltphone01))) THEN
          select SEQ_CLEXPF.nextval into v_unq_audit_clexpf from dual;
          obj_audit_clexp. unique_number := v_unq_audit_clexpf;

          obj_audit_clexp. oldclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clexp. oldclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clexp. oldclntnum := v_clntnum;
          obj_audit_clexp. oldrdidtelno := o_defaultvalues('RDIDTELNO');
          obj_audit_clexp. oldrmblphone := obj_client_old.cltphone01;
          obj_audit_clexp. oldrpager := o_defaultvalues('RPAGER');
          obj_audit_clexp. oldfaxno := o_defaultvalues('FAXNO');
          obj_audit_clexp. oldrinternet := o_defaultvalues('RINTERNET');
          obj_audit_clexp. oldrtaxidnum := o_defaultvalues('RTAXIDNUM');
          obj_audit_clexp. oldrstaflag := o_defaultvalues('RSTAFLAG');
          obj_audit_clexp. oldsplindic := v_space;
          obj_audit_clexp. oldzspecind := o_defaultvalues('ZSPECIND');
          obj_audit_clexp. oldoldidno := o_defaultvalues('OLDIDNO');
          obj_audit_clexp. oldusrprf := userProfile;
          obj_audit_clexp. oldjobnm := scheduleName;
          obj_audit_clexp. olddatime := sysdate;
          obj_audit_clexp. oldvalidflag := o_defaultvalues('VALIDFLAG');
          ---------------NEW-------------
          obj_audit_clexp. newclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clexp. newclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clexp. newclntnum := v_clntnum;
          obj_audit_clexp. newrdidtelno := o_defaultvalues('RDIDTELNO');

          IF TRIM(v_cltphone01) IS NOT NULL THEN
            obj_audit_clexp. newrmblphone := v_cltphone01;
          ELSE
            obj_audit_clexp. newrmblphone := v_space;
          END IF;

          obj_audit_clexp. newrpager := o_defaultvalues('RPAGER');
          obj_audit_clexp. newfaxno := o_defaultvalues('FAXNO');
          obj_audit_clexp. newrinternet := o_defaultvalues('RINTERNET');
          obj_audit_clexp. newrtaxidnum := o_defaultvalues('RTAXIDNUM');
          obj_audit_clexp. newrstaflag := o_defaultvalues('RSTAFLAG');
          obj_audit_clexp. newsplindic := v_space;
          obj_audit_clexp. newzspecind := o_defaultvalues('ZSPECIND');
          obj_audit_clexp. newoldidno := o_defaultvalues('OLDIDNO');
          obj_audit_clexp. newusrprf := userProfile;
          obj_audit_clexp. newjobnm := scheduleName;
          obj_audit_clexp. newdatime := sysdate;
          obj_audit_clexp. newvalidflag := o_defaultvalues('VALIDFLAG');
          -- obj_audit_clexp. userid := 'a';
          obj_audit_clexp. action := 'UPDATE';
          obj_audit_clexp. tranno := v_version_ctr;  --CH3
          obj_audit_clexp. systemdate := sysdate;
          Insert Into audit_clexpf values obj_audit_clexp;
        END IF;

      END IF;

      ---- For Alteration Code N01 ------
      /* IF v_zseqno > 0 AND TRIM(v_zaltrcde01) = 'N01' THEN
        IF TRIM(v_cltaddr03) IS NOT NULL THEN
          v_newcltaddr03 := v_cltaddr03;
        ELSE
          v_newcltaddr03 := v_space;
        END IF;

        IF TRIM(v_cltphone02) IS NOT NULL THEN
          v_newcltphone02 := v_cltphone02;
        ELSE
          v_newcltphone02 := v_space;
        END IF;
        UPDATE Jd1dta.CLNTPF
           SET CLTADDR01  = v_cltaddr01,
               CLTADDR02  = v_cltaddr02,
               CLTADDR03  = v_newcltaddr03,
               ZKANADDR01 = v_zkanaddr01,
               ZKANADDR02 = v_zkanaddr02,
               CLTPHONE02 = v_newcltphone02,
               CLTPCODE   = v_cltpcode
         WHERE TRIM(CLNTNUM) = v_clntnum;

        UPDATE Jd1dta.CLEXPF
           SET RMBLPHONE = v_cltphone01
         WHERE TRIM(CLNTNUM) = v_clntnum;
      END IF;

      ---- For Alteration Code N02 ------
      IF v_zseqno > 0 AND TRIM(v_zaltrcde01) = 'N02' THEN
        UPDATE Jd1dta.CLNTPF
           SET SURNAME     = v_lsurname,
               GIVNAME     = v_lgivname,
               LSURNAME    = v_lsurname,
               LGIVNAME    = v_lgivname,
               ZKANASNM    = v_zkanasurname,
               ZKANAGNM    = v_zkanagivname,
               ZKANASNMNOR = v_zkanasurname,
               ZKANAGNMNOR = v_zkanagivname
         WHERE TRIM(CLNTNUM) = v_clntnum;
      END IF;

      ---- For Alteration Code N07 ------    
      IF v_zseqno > 0 AND TRIM(v_zaltrcde01) = 'N07' THEN
        UPDATE Jd1dta.CLNTPF
           SET CLTSEX = v_cltsex, CLTDOB = n_cltdob
         WHERE TRIM(CLNTNUM) = v_clntnum;
      END IF;*/
      obj_client_old := obj_client;
    END IF;
  END LOOP;
  CLOSE personalclient_cursor;

  /*EXCEPTION
  WHEN OTHERS THEN
  v_code := SQLCODE;
  v_errm := SUBSTR(SQLERRM, 1, 64);
  dbms_output.put_line('Exception occurs while program execution, ' || 'SQL Code:' || v_code || ', Error Description:' || v_errm);
  */
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
END BQ9TV_CL02_2_CLNTHIST;