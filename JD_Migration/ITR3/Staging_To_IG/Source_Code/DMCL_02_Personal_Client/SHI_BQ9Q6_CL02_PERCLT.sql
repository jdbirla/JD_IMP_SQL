create or replace PROCEDURE                               "BQ9Q6_CL02_PERCLT" (scheduleName   IN VARCHAR2,
                                              scheduleNumber IN VARCHAR2,
                                              zprvaldYN      IN VARCHAR2,
                                              company        IN VARCHAR2,
                                              userProfile    IN VARCHAR2,
                                              i_branch       IN VARCHAR2,
                                              i_transCode    IN VARCHAR2,
                                              vrcmTermid     IN VARCHAR2) AS
/***************************************************************************************************
  * Amenment History: CL02 Personal Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * May02    MPS       CP2   Applying missing codes: Adddress 3 & 4 will always be spaces (#7034)
  * May03    MPS       CP3   7840: Create missing client roles, OW and LF
  * May11    MPS       CP4   7426: Validate Occupational Code only if it is not null and not spaces
  * May11	 RC	       CP5	 Data Verification Changes
  * May12	 PS	       CP6	 Data Verification Changes
  * May16	 RC 	   CP7	 AUDIT_CLRRPF Changes
  *****************************************************************************************************/                                              
  v_timestart NUMBER := dbms_utility.get_time;
  --Values fron Staging Table Start
  v_refnum       TITDMGCLNTPRSN.REFNUM@DMSTAGEDBLINK%type;
  v_lsurname     TITDMGCLNTPRSN.LSURNAME@DMSTAGEDBLINK%type;
  v_lgivname     TITDMGCLNTPRSN.LGIVNAME@DMSTAGEDBLINK%type;
  v_zkanagivname TITDMGCLNTPRSN.ZKANAGIVNAME@DMSTAGEDBLINK%type;
  v_zkanasurname TITDMGCLNTPRSN.ZKANASURNAME@DMSTAGEDBLINK%type;
  v_cltpcode     TITDMGCLNTPRSN.CLTPCODE@DMSTAGEDBLINK%type;
  v_cltaddr01    TITDMGCLNTPRSN.CLTADDR01@DMSTAGEDBLINK%type;
  v_cltaddr02    TITDMGCLNTPRSN.CLTADDR02@DMSTAGEDBLINK%type;
  v_cltaddr03    TITDMGCLNTPRSN.CLTADDR03@DMSTAGEDBLINK%type;
  v_cltaddr04    TITDMGCLNTPRSN.CLTADDR04@DMSTAGEDBLINK%type;
  v_zkanaddr01   TITDMGCLNTPRSN.ZKANADDR01@DMSTAGEDBLINK%type;
  v_zkanaddr02   TITDMGCLNTPRSN.ZKANADDR02@DMSTAGEDBLINK%type;
  v_zkanaddr03   TITDMGCLNTPRSN.ZKANADDR03@DMSTAGEDBLINK%type;
  v_zkanaddr04   TITDMGCLNTPRSN.ZKANADDR04@DMSTAGEDBLINK%type;
  v_cltsex       TITDMGCLNTPRSN.CLTSEX@DMSTAGEDBLINK%type;
  v_addrtype     TITDMGCLNTPRSN.ADDRTYPE@DMSTAGEDBLINK%type;
  --v_rmblphone    TITDMGCLNTPRSN.RMBLPHONE@DMSTAGEDBLINK%type;
  v_cltphone01 TITDMGCLNTPRSN.CLTPHONE01@DMSTAGEDBLINK%type;
  v_cltphone02 TITDMGCLNTPRSN.CLTPHONE02@DMSTAGEDBLINK%type;
  v_occpcode   TITDMGCLNTPRSN.OCCPCODE@DMSTAGEDBLINK%type;
  v_servbrh    TITDMGCLNTPRSN.SERVBRH@DMSTAGEDBLINK%type;
  n_cltdob     TITDMGCLNTPRSN.CLTDOB@DMSTAGEDBLINK%type;
  v_zoccdsc    TITDMGCLNTPRSN.ZOCCDSC@DMSTAGEDBLINK%type;
  v_zworkplce  TITDMGCLNTPRSN.ZWORKPLCE@DMSTAGEDBLINK%type;
  --mps v_occpclas   TITDMGCLNTPRSN.OCCPCLAS@DMSTAGEDBLINK%type;
  v_transhist TITDMGCLNTPRSN.TRANSHIST@DMSTAGEDBLINK%type;
  v_asrf      TITDMGCLNTPRSN.ASRF@DMSTAGEDBLINK%type;
  v_pkValue   CLEXPF.UNIQUE_NUMBER%type;
  v_pkValueClrrpf   CLRRPF.UNIQUE_NUMBER%type;
  --v_rmblphone TITDMGCLNTPRSN.RMBLPHONE@DMSTAGEDBLINK%type;
  -- v_secuityno STAGEDBUSR.TITDMGCLNTPRSN.SECUITYNO%type; not in S table
  --v_zkanasnm STAGEDBUSR.TITDMGCLNTPRSN.ZKANASNM%type;   not in S table
  --Values fron Staging Table End
  T_cltpcodeTemp VARCHAR2(10 CHAR);
  --  default values form TQ9Q9 Start
  v_SEQ         NUMBER(15) DEFAULT 0;
  v_clntpfx     VARCHAR2(20 CHAR);
  v_clntcoy     VARCHAR2(20 CHAR);
  v_validflag   VARCHAR2(20 CHAR);
  v_clttype     VARCHAR2(20 CHAR);
  v_surname     VARCHAR2(20 CHAR);
  v_givname     VARCHAR2(20 CHAR);
  v_ctrycode    VARCHAR2(20 CHAR);
  v_natlty      VARCHAR2(20 CHAR);
  v_mailing     VARCHAR2(20 CHAR);
  v_dirmail     VARCHAR2(20 CHAR);
  v_vip         VARCHAR2(20 CHAR);
  v_statcode    VARCHAR2(20 CHAR);
  v_soe         VARCHAR2(20 CHAR);
  v_docno       VARCHAR2(20 CHAR);
  v_cltdod      VARCHAR2(20 CHAR);
  v_cltstat     VARCHAR2(20 CHAR);
  v_cltmchg     VARCHAR2(20 CHAR);
  v_marryd      VARCHAR2(20 CHAR);
  v_birthp      VARCHAR2(20 CHAR);
  v_taxflag     VARCHAR2(20 CHAR);
  v_fao         VARCHAR2(20 CHAR);
  v_ethorig     VARCHAR2(20 CHAR);
  v_language    VARCHAR2(20 CHAR);
  v_abusnum     VARCHAR2(20 CHAR);
  v_branchid    VARCHAR2(20 CHAR);
  v_zkanagnm    VARCHAR2(20 CHAR);
  v_zkanagnmnor VARCHAR2(20 CHAR);
  v_rdidtelno   VARCHAR2(20 CHAR);
  v_rpager      VARCHAR2(20 CHAR);
  v_faxno       VARCHAR2(20 CHAR);
  v_rinternet   VARCHAR2(20 CHAR);
  v_rtaxidnum   VARCHAR2(20 CHAR);
  v_rstaflag    VARCHAR2(20 CHAR);
  v_zspecind    VARCHAR2(20 CHAR);
  v_oldidno     VARCHAR2(20 CHAR);
  v_amlstatus   VARCHAR2(20 CHAR);
  v_othidno     VARCHAR2(20 CHAR);
  v_othidtype   VARCHAR2(20 CHAR);
  v_zfathername VARCHAR2(20 CHAR);
  v_forepfx     VARCHAR2(20 CHAR);
  v_forecoy     VARCHAR2(20 CHAR);
  v_forenum     VARCHAR2(20 CHAR);
  v_used2b      VARCHAR2(20 CHAR);
  --  default values form TQ9Q9 END
  C_ZERO CONSTANT NUMBER(1) := 0;
  --v_tablecnt      NUMBER(1)          := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  v_clntnum       VARCHAR2(8 CHAR);
  b_isNoError     BOOLEAN := TRUE;
  errorCount      NUMBER(1) DEFAULT 0;
  isValid         NUMBER(1) DEFAULT 0;
  isDuplicate     NUMBER(3) DEFAULT 0; --changed value from 1 to 3 as the value in this variable is coming 18
  v_code          NUMBER;
  v_errm          VARCHAR2(64 CHAR);
  isValidName     VARCHAR2(10 CHAR);
  v_space         VARCHAR2(1 CHAR);
  v_effdate       NUMBER(10) DEFAULT 0;
    v_initials      VARCHAR2(5 CHAR);
  v_tranid        VARCHAR2(14 CHAR);
  anum_cursor1    types.ref_cursor;
  AnRow           ANUMPF%ROWTYPE;
  ------Define Constant to read
  C_PREFIX  CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLPL', company);
  C_BQ9Q6   CONSTANT VARCHAR2(5) := 'BQ9Q6';
  C_Z017    CONSTANT VARCHAR2(4) := 'RQLX';
  C_H036    CONSTANT VARCHAR2(4) := 'H036';
  C_Z098    CONSTANT VARCHAR2(4) := 'RQO6'; --Z099
  C_Z020    CONSTANT VARCHAR2(4) := 'RQV3';
  C_Z073    CONSTANT VARCHAR2(4) := 'RQNH';
  C_Z021    CONSTANT VARCHAR2(4) := 'RQV4';
  C_Z016    CONSTANT VARCHAR2(4) := 'RQLW';
  C_G979    CONSTANT VARCHAR2(4) := 'G979';
  C_F992    CONSTANT VARCHAR2(4) := 'F992';
  C_Z013    CONSTANT VARCHAR2(4) := 'RQLT';
  C_E374    CONSTANT VARCHAR2(4) := 'E374';
  C_E186    CONSTANT VARCHAR2(4) := 'E186';
  C_D009    CONSTANT VARCHAR2(4) := 'D009';
  C_T3645   CONSTANT VARCHAR2(5) := 'T3645';
  C_T2241   CONSTANT VARCHAR2(5) := 'T2241';
  C_TR393   CONSTANT VARCHAR2(5) := 'TR393';
  C_T3644   CONSTANT VARCHAR2(5) := 'T3644';
  C_T3582   CONSTANT VARCHAR2(5) := 'T3582';
  C_DTSM    CONSTANT VARCHAR2(4) := 'DTSM';
  C_CLRROLE CONSTANT VARCHAR2(4) := 'MP';
  C_CLRROLE_OW CONSTANT VARCHAR2(4) := 'OW'; -- CP3
  C_CLRROLE_LF CONSTANT VARCHAR2(4) := 'LF'; -- CP3
  ------Define Constant to read end
  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  checkdupl       pkg_common_dmcp.cpduplicate;
  ---------------Common function end-----------
  ------IG table obj start---
  obj_zdclpf PAZDCLPF%rowtype;
  obj_clntpf CLNTPF%rowtype;
  --obj_auditClntpf AUDIT_CLNTPF%rowtype;
  obj_clexpf CLEXPF%rowtype;
  obj_clrrpf CLRRPF%rowtype;
  obj_auditClrrpf AUDIT_CLRRPF%rowtype; -- CP7
  ------IG table obj End---
  CURSOR PERSONALCLIENT_cursor IS
    SELECT * FROM TITDMGCLNTPRSN@DMSTAGEDBLINK;
  obj_client PERSONALCLIENT_cursor%rowtype;
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
  pkg_common_dmcp.checkcpdup(checkdupl => checkdupl);
  /* SELECT COUNT(*)
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
  v_ctrycode    := o_defaultvalues('CTRYCODE');
  v_natlty      := o_defaultvalues('NATLTY');
  v_mailing     := o_defaultvalues('MAILING');
  v_dirmail     := o_defaultvalues('DIRMAIL');
  v_vip         := o_defaultvalues('VIP');
  v_statcode    := o_defaultvalues('STATCODE');
  v_soe         := o_defaultvalues('SOE');
  v_docno       := o_defaultvalues('DOCNO');
  v_cltdod      := o_defaultvalues('CLTDOD');
  v_cltstat     := o_defaultvalues('CLTSTAT');
  v_cltmchg     := o_defaultvalues('CLTMCHG');
  v_marryd      := o_defaultvalues('MARRYD');
  v_birthp      := o_defaultvalues('BIRTHP');
  v_taxflag     := o_defaultvalues('TAXFLAG');
  v_fao         := o_defaultvalues('FAO');
  v_ethorig     := o_defaultvalues('ETHORIG');
  v_language    := o_defaultvalues('LANGUAGE');
  v_abusnum     := o_defaultvalues('ABUSNUM');
  v_branchid    := o_defaultvalues('BRANCHID');
  v_zkanagnm    := o_defaultvalues('ZKANAGNM');
  v_zkanagnmnor := o_defaultvalues('ZKANAGNMNO');
  v_rdidtelno   := o_defaultvalues('RDIDTELNO');
  v_rpager      := o_defaultvalues('RPAGER');
  v_faxno       := o_defaultvalues('FAXNO');
  v_rinternet   := o_defaultvalues('RINTERNET');
  v_rtaxidnum   := o_defaultvalues('RTAXIDNUM');
  v_rstaflag    := o_defaultvalues('RSTAFLAG');
  v_zspecind    := o_defaultvalues('ZSPECIND');
  v_oldidno     := o_defaultvalues('OLDIDNO');
  v_amlstatus   := o_defaultvalues('AMLSTATUS');
  v_othidno     := o_defaultvalues('OTHIDNO');
  v_othidtype   := o_defaultvalues('OTHIDTYPE');
  v_zfathername := o_defaultvalues('ZFATHERNAM');
  v_forepfx     := o_defaultvalues('FOREPFX');
  v_forecoy     := o_defaultvalues('FORECOY');
  --v_forenum     := o_defaultvalues('FORENUM');
  v_used2b := o_defaultvalues('USED2B');
  -- Fetch All default values form TQ9Q9 End
  v_tranid := concat('QPAD', TO_CHAR(sysdate, 'YYMMDDHHMM'));
  -- Open Cursor
  OPEN PERSONALCLIENT_cursor;
  <<skipRecord>>
  LOOP
    FETCH PERSONALCLIENT_cursor
      INTO obj_client;
    EXIT WHEN PERSONALCLIENT_cursor%notfound;
    v_refnum       := obj_client.refnum;
    v_lsurname     := obj_client.lsurname;
    v_lgivname     := obj_client.lgivname;
    v_zkanagivname := obj_client.zkanagivname;
    v_zkanasurname := obj_client.zkanasurname;
    v_cltpcode     := obj_client.cltpcode;
    v_cltaddr01    := obj_client.cltaddr01;
    v_cltaddr02    := obj_client.cltaddr02;
    v_cltaddr03    := obj_client.cltaddr03;
    v_cltaddr04    := obj_client.cltaddr04;
    v_zkanaddr01   := obj_client.zkanaddr01;
    v_zkanaddr02   := obj_client.zkanaddr02;
    v_zkanaddr03   := obj_client.zkanaddr03;
    v_zkanaddr04   := obj_client.zkanaddr04;
    v_cltsex       := obj_client.cltsex;
    v_addrtype     := obj_client.addrtype;
    --v_rmblphone    := obj_client.rmblphone;
    v_cltphone01   := obj_client.cltphone01;
    v_cltphone02   := obj_client.cltphone02;
    v_occpcode     := obj_client.occpcode;
    v_servbrh      := obj_client.servbrh;
    n_cltdob       := obj_client.cltdob;
    v_zoccdsc      := obj_client.zoccdsc;
    v_zworkplce    := obj_client.zworkplce;
    --mps v_occpclas   := obj_client.occpclas;
    v_transhist := obj_client.transhist;
    v_asrf      := obj_client.asrf;

    --   v_secuityno  :=obj_client.SECUITYNO;  -- ? Not in S table
    --  v_zkanasnm    :=obj_client.zkanasnm; --? Not in S table
    v_space     := ' ';
    b_isNoError := TRUE;
    errorCount  := 0;
    v_effdate   := 19010101;
    -- v_initials    :=SUBSTR(v_lgivname,1,1);
    v_initials := SUBSTR(v_lgivname, 1, 1);
    -- Initialize error  variables start
    /*t_index     := 0; */
    i_zdoe_info := NULL;
    -- i_zdoe_info.i_tablecnt   := v_tablecnt;
    t_ercode(1) := NULL;
    t_ercode(2) := NULL;
    t_ercode(3) := NULL;
    t_ercode(4) := NULL;
    t_ercode(5) := NULL;
    i_zdoe_info.i_zfilename := 'TITDMGCLNTPRSN';
    i_zdoe_info.i_prefix := C_PREFIX;
    i_zdoe_info.i_scheduleno := scheduleNumber;
    i_zdoe_info.i_tableName := v_tableName;
    i_zdoe_info.i_refKey := TRIM(v_refnum);
    -- Initialize error  variables end
    --validation Start
    
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
      /*SELECT COUNT(*)
       INTO isDuplicate
       FROM Jd1dta.PAZDCLPF
      WHERE ZENTITY = v_refnum;*/
      IF (checkdupl.exists(TRIM(v_refnum))) THEN
        --  IF isDuplicate > 0 THEN
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
    --LSURNAME
    --  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lsurname) || 9)) THEN
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
    --  ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_lsurname);
    --      IF isValidName                 = 'Invalid' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'lsurname';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_lsurname);
    --        t_errorprogram(errorCount)  := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lgivname) || 9)) THEN
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
    --    ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_lgivname);
    --      IF isValidName                 = 'Invalid' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'lgivname';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_lgivname);
    --        t_errorprogram(errorCount)  := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
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
    -- CLTADDR01 ( Have Doubt for Addtess Rule in T2241
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_cltaddr01) || 9)) THEN
    IF TRIM(v_cltaddr01) IS NULL THEN
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
    END IF;
    --    ELSE
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr01);
    --      IF isValidName                 = 'Invalid' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr01';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
    --        t_errorprogram(errorCount)  := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
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
    --    ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr02);
    --      IF isValidName                 = 'Invalid' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr02';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr02);
    --        t_errorprogram(errorCount)  := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- 6)CLTADDR03 is Null --27/02/2018 as per the business hamma said
    --    IF TRIM(v_cltaddr03)          IS NULL THEN
    --      b_isNoError                 := FALSE;
    --      errorCount                  := errorCount + 1;
    --      t_ercode(errorCount)        := C_Z016;
    --      t_errorfield(errorCount)    := 'cltaddr03';
    --      t_errormsg(errorCount)      := o_errortext(C_Z016);
    --      t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --      t_errorprogram(errorCount)  := scheduleName;
    --      IF errorCount               >= 5 THEN
    --        GOTO insertzdoe;
    --      END IF;
    --
    --     IF TRIM(v_cltaddr03)          IS NOT NULL THEN
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr03);
    --      IF isValidName                 = 'Invalid' THEN
    --        b_isNoError                 := FALSE;
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr03';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --        t_errorprogram(errorCount)  := scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
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
    ---SIT Changes Removed by requirment
    /*  IF TRIM(v_zkanaddr02) IS NULL THEN
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
    -- 10) OCCPCODE valid in T-Table T3644
    -- Read T-Table T3644
    IF TRIM(v_occpcode) IS NOT NULL AND TRIM(v_occpcode) <> ' ' THEN               -- CP4
        IF NOT (itemexist.exists(TRIM(C_T3644) || TRIM(v_occpcode) || 9)) THEN
          b_isNoError := FALSE;
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_F992;
          t_errorfield(errorCount) := 'OCCPCODE';
          t_errormsg(errorCount) := o_errortext(C_F992);
          t_errorfieldval(errorCount) := TRIM(v_occpcode);
          t_errorprogram(errorCount) := scheduleName;
          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
        END IF;     
    END IF;                                                                         -- CP4
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(n_cltdob) || 9)) THEN
    IF TRIM(n_cltdob) IS NULL THEN
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
      SELECT SEQANUMPF.nextval INTO v_clntnum FROM dual;
      --Insert Value Migration Registry Table
      INSERT INTO PAZDCLPF
        (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
      VALUES
        ('OK', C_PREFIX, v_refnum, v_clntnum, scheduleNumber, scheduleName);
      /*       INSERT
      INTO Jd1dta.PAZDCHPF
      (
      RECSTATUS,
      ZENTITY,
      ZIGVALUE,
      JOBNUM,
      JOBNAME
      )
      VALUES
      (
      'New',
      concat(v_refnum,v_zseqno,v_effdate ),--?? This will be the application number/policy number from staging db + sequence number + effective date
      concat(v_clntnum,v_effdate),   --  ??      v_clntnum +v_effdate, This will be the IG client number + effective date
      scheduleNumber,
      scheduleName
      );*/
      -- insert in  IG Jd1dta.CLNTPF table start-
      -- For SIT Bug

      obj_clntpf.CLNTPFX   := v_clntpfx;
      obj_clntpf.CLNTCOY   := v_clntcoy;
      obj_clntpf.VALIDFLAG := v_validflag;
      obj_clntpf.CLTTYPE   := v_clttype;
      obj_clntpf.SURNAME   := v_lsurname;
      obj_clntpf.GIVNAME   := v_lgivname;
      obj_clntpf.CTRYCODE  := 'JPN';
      obj_clntpf.NATLTY    := v_natlty;
      obj_clntpf.MAILING   := v_mailing;
      obj_clntpf.DIRMAIL   := v_dirmail;
      obj_clntpf.VIP       := v_vip;
      obj_clntpf.STATCODE  := v_statcode;
      obj_clntpf.SOE       := v_soe;
      obj_clntpf.DOCNO     := v_docno;
      obj_clntpf.CLTDOD    := v_cltdod;
      obj_clntpf.CLTSTAT   := v_cltstat;
      obj_clntpf.CLTMCHG   := v_cltmchg;
      obj_clntpf.MARRYD    := v_marryd;
      obj_clntpf.BIRTHP    := v_birthp;
      --obj_clntpf.TAXFLAG   := v_taxflag; -- CP5
	  obj_clntpf.TAXFLAG   := 'N'; -- CP5
      obj_clntpf.FAO       := v_fao;
      obj_clntpf.ETHORIG   := v_ethorig;
      obj_clntpf.LANGUAGE  := v_language;
      obj_clntpf.ABUSNUM   := v_abusnum;
      obj_clntpf.BRANCHID  := v_branchid;
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
      /* CP2 Start --
      IF TRIM(v_cltaddr04) IS NOT NULL THEN
        obj_clntpf.CLTADDR04 := v_cltaddr04;
      ELSE
        obj_clntpf.CLTADDR04 := v_space;
      END IF;
      */ -- CP2 End --
      obj_clntpf.CLTADDR04 := v_space; -- CP2

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

        obj_clntpf.CLTPHONE01 := v_space;

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
      IF TRIM(v_servbrh) IS NOT NULL THEN
        obj_clntpf.SERVBRH := v_servbrh;
      ELSE
        obj_clntpf.SERVBRH := v_space;
      END IF;
      obj_clntpf.CLTDOB     := n_cltdob;
      obj_clntpf.ROLEFLAG01 := v_space;
      obj_clntpf.ROLEFLAG02 := v_space;
      obj_clntpf.ROLEFLAG03 := v_space;
      obj_clntpf.ROLEFLAG04 := v_space;
      --obj_clntpf.ROLEFLAG05 := v_space;    -- CP5
      obj_clntpf.ROLEFLAG05 := 'Y';    -- CP5
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
      /* CP2 START --
      IF TRIM(v_zkanaddr03) IS NOT NULL THEN
        obj_clntpf.ZKANADDR03 := v_zkanaddr03;
      ELSE
        obj_clntpf.ZKANADDR03 := v_space;
      END IF;
      IF TRIM(v_zkanaddr04) IS NOT NULL THEN
        obj_clntpf.ZKANADDR04 := v_zkanaddr04;
      ELSE
        obj_clntpf.ZKANADDR04 := v_space;
      END IF;
      */ -- CP2 END --
      obj_clntpf.ZKANADDR03 := v_space;
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
      --obj_clntpf.EXCEP         := v_space; -- CP5
	  obj_clntpf.EXCEP         := 'N'; -- CP5

      INSERT INTO CLNTPF VALUES obj_clntpf; 
      -- insert in  IG Jd1dta.CLNTPF table end-
      -- insert in  IG Jd1dta.CLEXPF table Start-
      select SEQ_CLEXPF.nextval into v_pkValue from dual;
      obj_clexpf.UNIQUE_NUMBER := v_pkValue;
      obj_clexpf.CLNTPFX     := v_clntpfx;
      obj_clexpf.CLNTCOY     := v_clntcoy;
      obj_clexpf.VALIDFLAG   := v_validflag;
      obj_clexpf.RDIDTELNO   := v_rdidtelno;
      obj_clexpf.RPAGER      := v_rpager;
      obj_clexpf.FAXNO       := v_faxno;
      obj_clexpf.RINTERNET   := v_rinternet;
      obj_clexpf.RTAXIDNUM   := v_rtaxidnum;
      obj_clexpf.RSTAFLAG    := v_rstaflag;
      obj_clexpf.ZSPECIND    := v_zspecind;
      obj_clexpf.OLDIDNO     := v_oldidno;
      obj_clexpf.AMLSTATUS   := v_amlstatus;
      obj_clexpf.OTHIDNO     := v_othidno;
      obj_clexpf.OTHIDTYPE   := v_othidtype;
      obj_clexpf.ZFATHERNAME := v_zfathername;
      obj_clexpf.CLNTNUM     := v_clntnum;
      IF TRIM(v_cltphone01) IS NOT NULL THEN
        obj_clexpf.RMBLPHONE := v_cltphone01;
      ELSE
        obj_clexpf.RMBLPHONE := v_space;
      END IF;

      obj_clexpf.JOBNM  := scheduleName;
      obj_clexpf.USRPRF := userProfile;
      obj_clexpf.DATIME := sysdate;

      -- SIT Bug Fix
      obj_clexpf.OTHIDNO      := v_space;
      obj_clexpf.OTHIDTYPE    := v_space;
      obj_clexpf.ZDMAILTO01   := v_space;
      obj_clexpf.ZDMAILTO02   := v_space;
      obj_clexpf.ZDMAILCC01   := v_space;
      obj_clexpf.ZDMAILCC02   := v_space;
      obj_clexpf.ZDMAILCC03   := v_space;
      obj_clexpf.ZDMAILCC04   := v_space;
      obj_clexpf.ZDMAILCC05   := v_space;
      obj_clexpf.ZDMAILCC06   := v_space;
      obj_clexpf.ZDMAILCC07   := v_space;
      obj_clexpf.RINTERNET2   := v_space;
      obj_clexpf.TELECTRYCODE := v_space;
      obj_clexpf.ZFATHERNAME  := v_space;
      obj_clexpf.SPLINDIC     := v_space;

      INSERT INTO CLEXPF VALUES obj_clexpf;
      -- insert in  IG Jd1dta.CLEXPF table end-
      -- insert in  IG Jd1dta.CLRRPF table Start-
      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;

      obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
      obj_clrrpf.CLNTPFX  := v_clntpfx;
      obj_clrrpf.CLNTCOY  := v_clntcoy;
      obj_clrrpf.FOREPFX  := v_forepfx;
      obj_clrrpf.FORECOY  := v_forecoy;
      obj_clrrpf.FORENUM  := v_refnum;
      obj_clrrpf.USED2B   := v_used2b;
      obj_clrrpf.CLNTNUM  := v_clntnum;
      obj_clrrpf.CLRRROLE := C_CLRROLE;
      obj_clrrpf.JOBNM    := scheduleName;
      obj_clrrpf.USRPRF   := userProfile;
      obj_clrrpf.DATIME   := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;
      -- CP3 START --
      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;
      obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
      obj_clrrpf.CLNTPFX  := v_clntpfx;
      obj_clrrpf.CLNTCOY  := v_clntcoy;
      obj_clrrpf.FOREPFX  := v_forepfx;
      obj_clrrpf.FORECOY  := v_forecoy;
      obj_clrrpf.FORENUM  := v_refnum;
      obj_clrrpf.USED2B   := v_used2b;
      obj_clrrpf.CLNTNUM  := v_clntnum;
      obj_clrrpf.CLRRROLE := C_CLRROLE_OW;
      obj_clrrpf.JOBNM    := scheduleName;
      obj_clrrpf.USRPRF   := userProfile;
      obj_clrrpf.DATIME   := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;

      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;
      obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
      obj_clrrpf.CLNTPFX  := v_clntpfx;
      obj_clrrpf.CLNTCOY  := v_clntcoy;
      obj_clrrpf.FOREPFX  := v_forepfx;
      obj_clrrpf.FORECOY  := v_forecoy;
      obj_clrrpf.FORENUM  := v_refnum;
      obj_clrrpf.USED2B   := v_used2b;
      obj_clrrpf.CLNTNUM  := v_clntnum;
      obj_clrrpf.CLRRROLE := C_CLRROLE_LF;
      obj_clrrpf.JOBNM    := scheduleName;
      obj_clrrpf.USRPRF   := userProfile;
      obj_clrrpf.DATIME   := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;
      -- CP3 END --
      -- insert in  IG Jd1dta.CLRRPF table end-
      --     errorCount:=INSERT_ZDOE(C_PREFIX, scheduleNumber, v_refnum, C_DTSM, NULL, NULL, scheduleName, 'S');

	  ------ CP7 Start -------
	  select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;

      obj_auditClrrpf.UNIQUE_NUMBER	:=	v_pkValueClrrpf;
      obj_auditClrrpf.OLDCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLNTPFX	:= v_clntpfx;
      obj_auditClrrpf.NEWCLNTCOY	:= v_clntcoy;
      obj_auditClrrpf.NEWCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLRRROLE	:= C_CLRROLE_OW;
      obj_auditClrrpf.NEWFOREPFX	:= v_forepfx;
      obj_auditClrrpf.NEWFORECOY	:= v_forecoy;
      obj_auditClrrpf.NEWFORENUM	:= v_refnum;
      obj_auditClrrpf.NEWUSED2B	:= ' ';
      obj_auditClrrpf.NEWUSRPRF	:= userProfile;
      obj_auditClrrpf.NEWJOBNM	:= scheduleName;
      obj_auditClrrpf.NEWDATIME	:= sysdate;
      obj_auditClrrpf.USERID	:= userProfile;
      obj_auditClrrpf.ACTION	:= 'INSERT';
      obj_auditClrrpf.TRANNO	:= 2;
      obj_auditClrrpf.SYSTEMDATE	:= sysdate;

	  INSERT INTO AUDIT_CLRRPF VALUES obj_auditClrrpf;

      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;

      obj_auditClrrpf.UNIQUE_NUMBER	:=	v_pkValueClrrpf;
      obj_auditClrrpf.OLDCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLNTPFX	:= v_clntpfx;
      obj_auditClrrpf.NEWCLNTCOY	:= v_clntcoy;
      obj_auditClrrpf.NEWCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLRRROLE	:= C_CLRROLE;
      obj_auditClrrpf.NEWFOREPFX	:= v_forepfx;
      obj_auditClrrpf.NEWFORECOY	:= v_forecoy;
      obj_auditClrrpf.NEWFORENUM	:= v_refnum;
      obj_auditClrrpf.NEWUSED2B	:= ' ';
      obj_auditClrrpf.NEWUSRPRF	:= userProfile;
      obj_auditClrrpf.NEWJOBNM	:= scheduleName;
      obj_auditClrrpf.NEWDATIME	:= sysdate;
      obj_auditClrrpf.USERID	:= userProfile;
      obj_auditClrrpf.ACTION	:= 'INSERT';
      obj_auditClrrpf.TRANNO	:= 2;
      obj_auditClrrpf.SYSTEMDATE	:= sysdate;

      INSERT INTO AUDIT_CLRRPF VALUES obj_auditClrrpf;

      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;

      obj_auditClrrpf.UNIQUE_NUMBER	:=	v_pkValueClrrpf;
      obj_auditClrrpf.OLDCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLNTPFX	:= v_clntpfx;
      obj_auditClrrpf.NEWCLNTCOY	:= v_clntcoy;
      obj_auditClrrpf.NEWCLNTNUM	:= v_clntnum;
      obj_auditClrrpf.NEWCLRRROLE	:= C_CLRROLE_LF;
      obj_auditClrrpf.NEWFOREPFX	:= v_forepfx;
      obj_auditClrrpf.NEWFORECOY	:= v_forecoy;
      obj_auditClrrpf.NEWFORENUM	:= v_refnum;
      obj_auditClrrpf.NEWUSED2B	:= ' ';
      obj_auditClrrpf.NEWUSRPRF	:= userProfile;
      obj_auditClrrpf.NEWJOBNM	:= scheduleName;
      obj_auditClrrpf.NEWDATIME	:= sysdate;
      obj_auditClrrpf.USERID	:= userProfile;
      obj_auditClrrpf.ACTION	:= 'INSERT';
      obj_auditClrrpf.TRANNO	:= 2;
      obj_auditClrrpf.SYSTEMDATE	:= sysdate;

      INSERT INTO AUDIT_CLRRPF VALUES obj_auditClrrpf;

	  ------ CP7 End --------


    END IF;

  END LOOP;
  CLOSE PERSONALCLIENT_cursor;
  /*EXCEPTION
  WHEN OTHERS THEN
  v_code := SQLCODE;
  v_errm := SUBSTR(SQLERRM, 1, 64);
  dbms_output.put_line('Exception occurs while program execution, ' || 'SQL Code:' || v_code || ', Error Description:' || v_errm);
  */
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
END BQ9Q6_CL02_PERCLT;