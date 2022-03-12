create or replace PROCEDURE                        "BQ9S5_AG01_AGENCY" (i_scheduleName   IN VARCHAR2,
                                              i_scheduleNumber IN VARCHAR2,
                                              i_zprvaldYN      IN VARCHAR2,
                                              i_company        IN VARCHAR2,
                                              i_usrprf         IN VARCHAR2,
                                              i_branch         IN VARCHAR2,
                                              i_transCode      IN VARCHAR2,
                                              i_vrcmTermid     IN VARCHAR2) AS
  /***************************************************************************************************
  * Amenment History: AG01 Agency
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       AG1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * May12    PS        AG2   Data verfication defaults
  * MAY15    JDB       AG3   Insert Into Audit_CLRRPF
  *****************************************************************************************************/
  -- Local Variables Declaration
  v_timestart        NUMBER := dbms_utility.get_time;
  v_zarefnum         TITDMGAGENTPJ.ZAREFNUM@DMSTAGEDBLINK%type;
  v_agtype           TITDMGAGENTPJ.AGTYPE@DMSTAGEDBLINK%type;
  v_agntbr           TITDMGAGENTPJ.AGNTBR@DMSTAGEDBLINK%type;
  v_srdate           TITDMGAGENTPJ.SRDATE@DMSTAGEDBLINK%type;
  v_dateend          TITDMGAGENTPJ.DATEEND@DMSTAGEDBLINK%type;
  v_stca             TITDMGAGENTPJ.STCA@DMSTAGEDBLINK%type;
  v_ridesc           TITDMGAGENTPJ.RIDESC@DMSTAGEDBLINK%type;
  v_agclsd           TITDMGAGENTPJ.AGCLSD@DMSTAGEDBLINK%type;
  v_zrepstnm         TITDMGAGENTPJ.ZREPSTNM@DMSTAGEDBLINK%type;
  v_zagregno         TITDMGAGENTPJ.ZAGREGNO@DMSTAGEDBLINK%type;
  v_cpyname          TITDMGAGENTPJ.CPYNAME@DMSTAGEDBLINK%type;
  v_ztrgtflg         TITDMGAGENTPJ.ZTRGTFLG@DMSTAGEDBLINK%type;
  v_count            TITDMGAGENTPJ.COUNT@DMSTAGEDBLINK%type;
  v_dconsignen       TITDMGAGENTPJ.DCONSIGNEN@DMSTAGEDBLINK%type;
  v_zconsidt         TITDMGAGENTPJ.ZCONSIDT@DMSTAGEDBLINK%type;
  v_zinstyp01        TITDMGAGENTPJ.ZINSTYP01@DMSTAGEDBLINK%type;
  v_cmrate01         TITDMGAGENTPJ.CMRATE01@DMSTAGEDBLINK%type;
  v_isDuplicate      NUMBER(1) DEFAULT 0;
  v_isValid          NUMBER(1) DEFAULT 0;
  v_isDateValid      VARCHAR2(20 CHAR);
  v_isAnyError       VARCHAR2(1) DEFAULT 'N';
  v_igintvalue       NUMBER(1) DEFAULT 0;
  v_igpacevalue      VARCHAR2(1) DEFAULT ' ';
  v_repagent01       VARCHAR2(20);
  v_qpad             VARCHAR2(14);
  v_clntnum          VARCHAR2(10);
  temp_clntnum       VARCHAR2(10);
  v_accountclass     VARCHAR2(5);
  v_arcon            VARCHAR2(5);
  v_statementreqd    VARCHAR2(5);
  v_clntnum1         VARCHAR2(15);
  v_agentcoy         VARCHAR2(1);
  v_agntnum_agentcoy VARCHAR2(35);
  v_AgentType        VARCHAR2(1);
  errorCount         NUMBER(1) DEFAULT 0;
  --  default values form TQ9Q9 Start
  v_agntpfx       VARCHAR2(20 CHAR);
  v_validflag     VARCHAR2(20 CHAR);
  v_clntpfx       VARCHAR2(20 CHAR);
  v_clntcoy       VARCHAR2(20 CHAR);
  v_agntrel       VARCHAR2(20 CHAR);
  v_replvl        VARCHAR2(20 CHAR);
  v_fgagnt        VARCHAR2(20 CHAR);
  v_stlbasis      VARCHAR2(20 CHAR);
  v_licnexdt      VARCHAR2(20 CHAR);
  v_lob           VARCHAR2(20 CHAR);
  v_agstdate      VARCHAR2(20 CHAR);
  v_enddate       VARCHAR2(20 CHAR);
  v_strtdate      VARCHAR2(20 CHAR);
  v_aprvdate      VARCHAR2(20 CHAR);
  v_busdate       busdpf.busdate%type;
  v_pkValueClrrpf CLRRPF.UNIQUE_NUMBER%type; -- AG3
  --  default values form TQ9Q9 End
  ------Define Constant
  C_PREFIX CONSTANT VARCHAR2(2 CHAR) := GET_MIGRATION_PREFIX('AGCY',
                                                             i_company);
  C_BQ9S5  CONSTANT VARCHAR2(6 CHAR) := 'BQ9S5';
  C_T3595  CONSTANT VARCHAR2(5 CHAR) := 'T3595';
  C_TQ9B6  CONSTANT VARCHAR2(5 CHAR) := 'TQ9B6';
  C_T3692  CONSTANT VARCHAR2(5 CHAR) := 'T3692';
  C_T1692  CONSTANT VARCHAR2(5 CHAR) := 'T1692';
  C_Z099   CONSTANT VARCHAR2(4 CHAR) := 'RQO6';
  /* RQO6 Duplicate record found*/
  C_Z071 CONSTANT VARCHAR2(4) := 'RQNF';
  /*  RQNF Client Number cannot be blank */
  C_Z002 CONSTANT VARCHAR2(4) := 'RQLI';
  /* RQLI Client not yet migrated */
  C_Z065 CONSTANT VARCHAR2(4) := 'RQN9';
  /* RQN9 Agent Type cannot be blank */
  C_Z061 CONSTANT VARCHAR2(4) := 'RQN5';
  /* RQN5 Agent Type not in T3692 */
  C_Z066 CONSTANT VARCHAR2(4) := 'RQNA';
  /* RQNA Agent Branch cannot be blank */
  C_Z062 CONSTANT VARCHAR2(4) := 'RQN6';
  /* RQN6 Agent Branch not in T1692 */
  C_Z063 CONSTANT VARCHAR2(4) := 'RQN7';
  /*  RQN7 Statistical code not valid in T3595 */
  C_Z038 CONSTANT VARCHAR2(4) := 'RQMI';
  /* RQMI Insurance Type not in TQ9B6 */
  C_Z067 CONSTANT VARCHAR2(4) := 'RQNB';
  /* RQNB Start date cannot be blank*/
  C_Z068 CONSTANT VARCHAR2(4) := 'RQNC';
  /* RQNC Agent Name (RIDESC) cannot be blank */
  C_Z069 CONSTANT VARCHAR2(4) := 'RQND';
  /* RQND Agent Commission Class cannot be blank */
  C_Z070 CONSTANT VARCHAR2(4) := 'RQNE';
  /* RQNE Representative Name cannot be blank*/
  C_Z013 CONSTANT VARCHAR2(4) := 'RQLT';
  /*  RQLT Invalid Date */
  C_Z056 CONSTANT VARCHAR2(4) := 'RQN0';
  /* RQN0 Insurance Type ??? 1 cannot be blank */
  C_Z057 CONSTANT VARCHAR2(4) := 'RQN1';
  C_Z064 CONSTANT VARCHAR2(4) := 'RQN8';
  /* RQN1 Commission rate -1 cannot be blank */
  -- C_E036       CONSTANT VARCHAR2(4) := 'E036';
  ------Define Constant to read end
  C_CLRROLE CONSTANT VARCHAR2(4) := 'AG';
  ------IG table obj start---
  obj_agntpf AGNTPF%rowtype;
  obj_agplpf AGPLPF%rowtype;
  obj_zacrpf ZACRPF%rowtype;
  obj_clrrpf CLRRPF%rowtype;
  ------IG table obj End---
  obj_audit_clrrpf AUDIT_CLRRPF%rowtype; --AG3
  --------------------------COMMON FUNCTION START-----------------------------------------------------------------------
  --  v_tablecnt      NUMBER(1) := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  --  itemexist pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  itemexist       pkg_dm_agency.itemschec;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  type errorprogram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;
  --------------------------COMMON FUNCTION END-------------------------------------------------------------------------
  -- Define a Cursor to read StageDB TITDMGAGENTPJ
  CURSOR AGENCY_cursor IS
    SELECT * FROM TITDMGAGENTPJ@DMSTAGEDBLINK;
  obj_agency AGENCY_cursor%rowtype;
BEGIN
  select BUSDATE
    into v_busdate
    from busdpf
   where busdkey = 'DATE'
     and company = '1';
  --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------
  pkg_dm_common_operations.getdefaultvalues(i_itemname      => C_BQ9S5,
                                            i_company       => i_company,
                                            o_defaultvalues => o_defaultvalues);
  -- pkg_dm_common_operations.checkitemexist(i_module_name => 'DMAG', itemexist => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMAG',
                                        o_errortext   => o_errortext);
  -- pkg_dm_agency.getitemvalue(itemexist=>itemschec);
  pkg_dm_agency.getitemvalue(itemexist => itemexist);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  /*SELECT COUNT(*)
  INTO v_tablecnt
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableName;*/
  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------
  -- Fetch All default values form Smart Table - TQ9Q9
  v_agntpfx   := o_defaultvalues('AGNTPFX');
  v_validflag := o_defaultvalues('VALIDFLAG');
  v_clntpfx   := o_defaultvalues('CLNTPFX');
  v_clntcoy   := o_defaultvalues('CLNTCOY');
  -- v_agntrel   := o_defaultvalues('AGNTREL'); -- AG2
  v_agntrel  := ' '; -- AG2
  v_replvl   := o_defaultvalues('REPLVL');
  v_fgagnt   := o_defaultvalues('FGAGNT');
  v_stlbasis := o_defaultvalues('STLBASIS');
  v_licnexdt := o_defaultvalues('LICNEXDT');
  v_lob      := o_defaultvalues('LOB');
  v_agstdate := o_defaultvalues('AGSTDATE');
  v_enddate  := o_defaultvalues('ENDDATE');
  v_strtdate := o_defaultvalues('STRTDATE');
  v_aprvdate := o_defaultvalues('APRVDATE');
  -- Fetch All default values form Smart Table - TQ9Q9 End
  v_qpad := CONCAT('QPAD', TO_NUMBER(TO_CHAR(sysdate, 'YYMMDDHHMM')));
  -- Open Cursor
  OPEN AGENCY_cursor;
  <<skipRecord>>
  LOOP
    FETCH AGENCY_cursor
      INTO obj_agency;
    EXIT WHEN AGENCY_cursor%notfound;
    -- Store In loacl Variable from Stage-DB
    v_zarefnum         := obj_agency.ZAREFNUM;
    v_agtype           := obj_agency.AGTYPE;
    v_agntbr           := obj_agency.AGNTBR;
    v_srdate           := obj_agency.SRDATE;
    v_dateend          := obj_agency.DATEEND;
    v_stca             := obj_agency.STCA;
    v_ridesc           := obj_agency.RIDESC;
    v_agclsd           := obj_agency.AGCLSD;
    v_zrepstnm         := obj_agency.ZREPSTNM;
    v_cpyname          := obj_agency.CPYNAME;
    v_ztrgtflg         := obj_agency.ZTRGTFLG;
    v_count            := obj_agency.COUNT;
    v_dconsignen       := obj_agency.DCONSIGNEN;
    v_zconsidt         := obj_agency.ZCONSIDT;
    v_zinstyp01        := obj_agency.ZINSTYP01;
    v_cmrate01         := obj_agency.CMRATE01;
    v_agentcoy         := i_company;
    v_clntnum          := obj_agency.CLNTNUM;
    v_agntnum_agentcoy := CONCAT(v_agentcoy, v_zarefnum);
    v_repagent01       := CONCAT(v_agntpfx, v_agntnum_agentcoy);
    v_isAnyError       := 'N';
    errorCount         := 0;
    v_zagregno         := obj_agency.ZAGREGNO;
    v_AgentType        := 'N';
    i_zdoe_info        := NULL;
    --i_zdoe_info.i_tablecnt   := v_tablecnt;
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info.i_zfilename := 'TITDMGAGENTPJ';
    i_zdoe_info.i_prefix := C_PREFIX;
    i_zdoe_info.i_tableName := v_tableName;
    i_zdoe_info.i_refKey := TRIM(v_zarefnum);
    v_igpacevalue := ' ';
    -- Validatin Of Fields- Start
    -- 1) Duplicate Record if already Migrated in table PAZDROPF
    IF TRIM(v_zarefnum) IS NULL THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_Z064;
      i_zdoe_info.i_errormsg01     := o_errortext(C_Z064);
      i_zdoe_info.i_errorfield01   := 'ZAREFNUM';
      i_zdoe_info.i_fieldvalue01   := v_zarefnum;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;
    ELSE
      SELECT COUNT(*)
        INTO v_isDuplicate
        FROM Jd1dta.PAZDROPF
       WHERE RTRIM(ZENTITY) = TRIM(v_zarefnum);
      IF v_isDuplicate > 0 THEN
        --      v_isAnyError      :='Y';
        --      v_errorcount      :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z099, 'ZAREFNUM', v_zarefnum, NULL, 'E');
        --      CONTINUE skipRecord;
        v_isAnyError                 := 'Y';
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z099;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z099);
        i_zdoe_info.i_errorfield01   := 'ZAREFNUM';
        i_zdoe_info.i_fieldvalue01   := v_zarefnum;
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      END IF;
    END IF;
    -- 2) CLNTNUM is null
    IF TRIM(v_clntnum) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z071;
      t_errormsg(errorCount) := o_errortext(C_Z071);
      t_errorfield(errorCount) := 'CLNTNUM';
      t_errorfieldval(errorCount) := TRIM(v_clntnum);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    ELSE
      -- 3) CLNTNUM is already Migrated or not
      SELECT COUNT(*)
        INTO v_clntnum1
        FROM Jd1dta.PAZDCLPF
       WHERE RTRIM(ZENTITY) = TRIM(v_clntnum);
      IF v_clntnum1 = 0 THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z002;
        t_errormsg(errorCount) := o_errortext(C_Z002);
        t_errorfield(errorCount) := 'CLNTNUM';
        t_errorfieldval(errorCount) := TRIM(v_clntnum);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
    --4) AGTYPE is null
    IF TRIM(v_agtype) IS NULL THEN
      v_isAnyError := 'Y';
      v_AgentType := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z065;
      t_errormsg(errorCount) := o_errortext(C_Z065);
      t_errorfield(errorCount) := 'AGTYPE';
      t_errorfieldval(errorCount) := TRIM(v_agtype);
      t_errorprogram(errorCount) := i_scheduleName;
      -- v_errorcount    :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z065, 'AGTYPE', v_agtype, NULL, 'E');
      --   IF(v_errorcount  = C_ERRORCOUNT) THEN
      --  CONTINUE skipRecord;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    ELSE
      -- END IF ;
      --5) AGTYPE is valid in T3692
      --  v_isValid         :=CHECK_TTABLE_ITEM(C_T3692, v_agtype, i_company);
      IF NOT (itemexist.exists(TRIM(C_T3692) || TRIM(v_agtype) || 1)) THEN
        --  IF v_isValid      = 0 THEN
        v_isAnyError := 'Y';
        --  v_AgentType    :='Y';
        --i_zdoe_info.i_indic         := 'E';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z061;
        t_errormsg(errorCount) := o_errortext(C_Z061);
        t_errorfield(errorCount) := 'AGTYPE';
        t_errorfieldval(errorCount) := TRIM(v_agtype);
        t_errorprogram(errorCount) := i_scheduleName;
        -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z061, 'AGTYPE', v_agtype, NULL, 'E');
        --IF(v_errorcount = C_ERRORCOUNT) THEN
        -- CONTINUE skipRecord;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
    --6) AGNTBR is null
    IF TRIM(v_agntbr) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z066;
      t_errormsg(errorCount) := o_errortext(C_Z066);
      t_errorfield(errorCount) := 'AGNTBR';
      t_errorfieldval(errorCount) := TRIM(v_agntbr);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
      --7) AGNTBR valid  in T1692
      --v_isValid         :=CHECK_TTABLE_ITEM(C_T1692, v_agntbr, i_company);
      IF NOT (itemexist.exists(TRIM(C_T1692) || TRIM(v_agntbr) || 1)) THEN
        IF v_isValid = 0 THEN
          v_isAnyError := 'Y';
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z062;
          t_errormsg(errorCount) := o_errortext(C_Z062);
          t_errorfield(errorCount) := 'AGNTBR';
          t_errorfieldval(errorCount) := TRIM(v_agntbr);
          t_errorprogram(errorCount) := i_scheduleName;
          -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z062, 'AGTYPE', v_agntbr, NULL, 'E');
          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      END IF;
      -- 11) SRDATE is blank, 0 or 99999999
      IF TRIM(v_srdate) IS NULL OR TRIM(v_srdate) = 0 OR
         TRIM(v_srdate) = 99999999 THEN
        v_isAnyError := 'Y';
        --   v_errorcount    :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z067, 'SRDATE', v_srdate, NULL, 'E');
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z067;
        t_errormsg(errorCount) := o_errortext(C_Z067);
        t_errorfield(errorCount) := 'SRDATE';
        t_errorfieldval(errorCount) := TRIM(v_srdate);
        t_errorprogram(errorCount) := i_scheduleName;
        -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z062, 'AGTYPE', v_agntbr, NULL, 'E');
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
          --        IF(v_errorcount = C_ERRORCOUNT) THEN
          --          CONTINUE skipRecord;
        END IF;
        --16) SRDATE Date Formate
      ELSE
        v_isDateValid := VALIDATE_DATE(v_srdate);
        IF v_isDateValid <> 'OK' THEN
          v_isAnyError := 'Y';
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z013;
          t_errormsg(errorCount) := o_errortext(C_Z013);
          t_errorfield(errorCount) := 'SRDATE';
          t_errorfieldval(errorCount) := TRIM(v_srdate);
          t_errorprogram(errorCount) := i_scheduleName;
          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
          --v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z013, 'SRDATE', v_srdate, NULL, 'E');
          --IF(v_errorcount = C_ERRORCOUNT) THEN
          --  CONTINUE skipRecord;
        END IF;
      END IF;
    END IF;
    -- 17) DATEEND Date Formate
    v_isDateValid := VALIDATE_DATE(v_dateend);
    IF v_isDateValid <> 'OK' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfield(errorCount) := 'DATEEND';
      t_errorfieldval(errorCount) := TRIM(v_dateend);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 18) ZCONSIDT Date Formate
    v_isDateValid := VALIDATE_DATE(v_zconsidt);
    IF v_isDateValid <> 'OK' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfield(errorCount) := 'ZCONSIDT';
      t_errorfieldval(errorCount) := TRIM(v_zconsidt);
      t_errorprogram(errorCount) := i_scheduleName;
      -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z013, 'ZCONSIDT', v_zconsidt, NULL, 'E');
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --8) STCA is valid in T3595
    --v_isValid        :=CHECK_TTABLE_ITEM(C_T3595, v_stca, i_company);
    IF NOT (itemexist.exists(TRIM(C_T3595) || TRIM(v_stca) || 1)) THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z063;
      t_errormsg(errorCount) := o_errortext(C_Z063);
      t_errorfield(errorCount) := 'STCA';
      t_errorfieldval(errorCount) := TRIM(v_stca);
      t_errorprogram(errorCount) := i_scheduleName;
      -- IF v_isValid      = 0 THEN
      --    v_isAnyError   :='Y';
      -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z063, 'STCA', v_stca, NULL, 'E');
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --10) ZINSTYP is null or not
    IF TRIM(v_zinstyp01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z056;
      t_errormsg(errorCount) := o_errortext(C_Z056);
      t_errorfield(errorCount) := 'ZINSTYP';
      t_errorfieldval(errorCount) := TRIM(v_zinstyp01);
      t_errorprogram(errorCount) := i_scheduleName;
      --v_errorcount       :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber,v_zarefnum, C_Z056, 'ZINSTYP', v_zinstyp01, NULL, 'E');
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
      --9) ZINSTYP is valid in TQ9B6
    ELSE
      --v_isValid            :=CHECK_TTABLE_ITEM(C_TQ9B6, v_zinstyp01, i_company);
      IF NOT (itemexist.exists(TRIM(C_TQ9B6) || TRIM(v_zinstyp01) || 1)) THEN
        IF v_isValid = 0 THEN
          v_isAnyError := 'Y';
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z038;
          t_errormsg(errorCount) := o_errortext(C_Z038);
          t_errorfield(errorCount) := 'ZINSTYP';
          t_errorfieldval(errorCount) := TRIM(v_zinstyp01);
          t_errorprogram(errorCount) := i_scheduleName;
          -- v_errorcount   :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z038, 'ZINSTYP', v_zinstyp01, NULL, 'E');
          -- IF(v_errorcount = C_ERRORCOUNT) THEN
          --CONTINUE skipRecord;
          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      END IF;
    END IF;
    -- 12) RIDESC is null
    IF TRIM(v_ridesc) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z068;
      t_errormsg(errorCount) := o_errortext(C_Z068);
      t_errorfield(errorCount) := 'RIDESC';
      t_errorfieldval(errorCount) := TRIM(v_ridesc);
      t_errorprogram(errorCount) := i_scheduleName;
      --  v_errorcount     :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z068, 'RIDESC', v_ridesc, NULL, 'E');
      --      IF(v_errorcount   = C_ERRORCOUNT) THEN
      --        CONTINUE skipRecord;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 13) AGCLSD is null
    IF TRIM(v_agclsd) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z069;
      t_errormsg(errorCount) := o_errortext(C_Z069);
      t_errorfield(errorCount) := 'AGCLSD';
      t_errorfieldval(errorCount) := TRIM(v_agclsd);
      t_errorprogram(errorCount) := i_scheduleName;
      --  v_errorcount     :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z069, 'AGCLSD', v_agclsd, NULL, 'E');
      -- IF(v_errorcount   = C_ERRORCOUNT) THEN
      -- CONTINUE skipRecord;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 14) ZREPSTNM is null
    IF TRIM(v_zrepstnm) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z070;
      t_errormsg(errorCount) := o_errortext(C_Z070);
      t_errorfield(errorCount) := 'ZREPSTNM';
      t_errorfieldval(errorCount) := TRIM(v_zrepstnm);
      t_errorprogram(errorCount) := i_scheduleName;
      -- v_errorcount       :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z070, 'ZREPSTNM', v_zrepstnm, NULL, 'E');
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --15)CMRATE01 IS NULL
    IF TRIM(v_cmrate01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z057;
      t_errormsg(errorCount) := o_errortext(C_Z057);
      t_errorfield(errorCount) := 'CMRATE01';
      t_errorfieldval(errorCount) := TRIM(v_cmrate01);
      t_errorprogram(errorCount) := i_scheduleName;
      -- v_errorcount       :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, C_Z057, 'CMRATE01', v_cmrate01, NULL, 'E');
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    <<insertzdoe>>
    IF (v_isAnyError = 'Y') THEN
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

    -- Insert Temp table with Indicator- S for Migrated data
    IF (itemexist.exists(TRIM('T3692') || TRIM(v_agtype) || TRIM('1'))) THEN
      v_accountclass  := itemexist(TRIM('T3692') || TRIM(v_agtype) || TRIM('1'))
                         .v_accountclass;
      v_arcon         := itemexist(TRIM('T3692') || TRIM(v_agtype) || TRIM('1'))
                         .v_arcon;
      v_statementreqd := itemexist(TRIM('T3692') || TRIM(v_agtype) || TRIM('1'))
                         .v_statementreqd;
    END IF;
    IF (v_isAnyError = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;
    --    IF v_isAnyError = 'N' THEN
    --      v_errorcount :=INSERT_ZDOE(C_PREFIX, i_scheduleNumber, v_zarefnum, NULL, NULL, NULL, NULL, 'S');
    --    END IF;
    -- Updateing IG- Tables And Migration Registry table with filter data
    -- Updating  Migration Registry table of Agency And IG Tables  IF zprvaldYN selected as NO and No validation fail
    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN
      --Insert Into Data Migration Registry  table - PAZDROPF
      SELECT COUNT(*)
        INTO v_isDuplicate
        FROM PAZDCLPF
       WHERE RTRIM(PREFIX) = TRIM('CC')
         AND RTRIM(ZENTITY) = TRIM(v_clntnum);
      IF v_isDuplicate > 0 THEN
        SELECT ZIGVALUE
          INTO temp_clntnum
          FROM PAZDCLPF
         WHERE RTRIM(PREFIX) = TRIM('CC')
           AND RTRIM(ZENTITY) = TRIM(v_clntnum);
      END IF;
      INSERT INTO Jd1dta.PAZDROPF
        (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
      VALUES
        ('OK',
         'AG',
         v_zarefnum,
         v_zarefnum,
         i_scheduleNumber,
         i_scheduleName);
      -- Updateing IG Table
      -- 1) ***Agntpf
      -- insert in  IG Jd1dta.Agntpf table start-
      obj_agntpf.AGNTPFX    := v_agntpfx;
      obj_agntpf.VALIDFLAG  := v_validflag;
      obj_agntpf.CLNTPFX    := v_clntpfx;
      obj_agntpf.CLNTCOY    := v_clntcoy;
      obj_agntpf.AGNTREL    := v_agntrel;
      obj_agntpf.REPLVL     := v_replvl;
      obj_agntpf.FGAGNT     := v_fgagnt;
      obj_agntpf.AGNTCOY    := i_company;
      obj_agntpf.AGNTNUM    := v_zarefnum;
      obj_agntpf.TRANID     := v_qpad;
      obj_agntpf.CLNTNUM    := temp_clntnum; ---- same
      obj_agntpf.AGTYPE     := v_agtype;
      obj_agntpf.AGNTBR     := v_agntbr;
      obj_agntpf.REPAGENT01 := v_repagent01;
      obj_agntpf.REPAGENT02 := v_igpacevalue;
      obj_agntpf.REPAGENT03 := v_igpacevalue;
      obj_agntpf.REPAGENT04 := v_igpacevalue;
      obj_agntpf.REPAGENT05 := v_igpacevalue;
      obj_agntpf.REPAGENT06 := v_igpacevalue;
      obj_agntpf.REPORTAG01 := v_zarefnum;
      obj_agntpf.REPORTAG02 := v_igpacevalue;
      obj_agntpf.REPORTAG03 := v_igpacevalue;
      obj_agntpf.REPORTAG04 := v_igpacevalue;
      obj_agntpf.REPORTAG05 := v_igpacevalue;
      obj_agntpf.REPORTAG06 := v_igpacevalue;
      obj_agntpf.FGCOMMTABL := v_igpacevalue;
      obj_agntpf.LIFAGNT    := v_igpacevalue;
      obj_agntpf.SRDATE     := v_srdate;
      obj_agntpf.DATEEND    := v_dateend;
      obj_agntpf.STCA       := v_stca;
      obj_agntpf.STCB       := v_accountclass;
      obj_agntpf.STCC       := v_igpacevalue;
      obj_agntpf.STCD       := v_igpacevalue;
      obj_agntpf.STCE       := v_igpacevalue;
      obj_agntpf.ZBKIND     := v_igpacevalue;
      obj_agntpf.ZDISTRICT  := v_igpacevalue;
      obj_agntpf.ZFGCMTBN   := v_igpacevalue;
      obj_agntpf.ZSTAFFCD   := v_igpacevalue;
      obj_agntpf.BANKCODE01 := v_igpacevalue;
      obj_agntpf.BANKCODE02 := v_igpacevalue;
      obj_agntpf.BANKCODE03 := v_igpacevalue;
      obj_agntpf.BANKCODE04 := v_igpacevalue;
      obj_agntpf.BANKCODE05 := v_igpacevalue;
      obj_agntpf.PRODCTCATG := v_igpacevalue;
      obj_agntpf.AGCLSD     := v_agclsd;
      obj_agntpf.ZCONSIDT   := v_zconsidt;
      obj_agntpf.BLKLIMIT   := v_igintvalue;
      --SIT Bug Fix
      obj_agntpf.PROVSTAT   := 'AP';
      obj_agntpf.DCONSIGNEN := v_dconsignen;
      obj_agntpf.AUTHBY     := v_igpacevalue;
      obj_agntpf.CPYNAME    := v_cpyname;
      obj_agntpf.ZAGREGNO   := v_zagregno;
      obj_agntpf.ZTRGTFLG   := v_ztrgtflg;
      --SIT BUG FIX
      obj_agntpf.AUTHDATE := 99999999;
      --   obj_agntpf.AUTHDATEG := 99999999; -- AG2
      --   obj_agntpf.AUTHDATEG := v_igpacevalue; -- AG2
      obj_agntpf.DTECRT := v_busdate;
      obj_agntpf.COUNT  := v_count;
      -- obj_agntpf.CRTUSER   := v_igpacevalue;  -- AG2
      obj_agntpf.CRTUSER := 'UNDERWR1'; -- AG2
      ---SIT Bug Fix
      obj_agntpf.ZSKPAUTOC := 'N';
      obj_agntpf.ZREPSTNM  := v_zrepstnm;
      obj_agntpf.USRPRF    := i_usrprf;
      obj_agntpf.JOBNM     := i_scheduleNumber;
      obj_agntpf.DATIME    := LOCALTIMESTAMP;
      ---SIT Bug fix
      obj_agntpf.Crlimit   := v_igintvalue;
      obj_agntpf.ridesc    := v_ridesc;
      obj_agntpf.credittrm := 0;

      --SIT Bug Fix
      obj_agntpf.CONTPERS := v_igpacevalue;
      obj_agntpf.TAKOAGNT := v_igpacevalue;
      obj_agntpf.ARCON    := v_igpacevalue;
      obj_agntpf.STREQ    := v_igpacevalue;
      obj_agntpf.CRTERM   := v_igpacevalue;
      obj_agntpf.STLBASIS := v_igpacevalue;
      obj_agntpf.EXPNOT   := v_igpacevalue;
      obj_agntpf.LICENCE  := v_igpacevalue;
      obj_agntpf.RLRPFX   := v_igpacevalue;
      obj_agntpf.RLRCOY   := v_igpacevalue;
      obj_agntpf.RLRACC   := v_igpacevalue;
      obj_agntpf.MSAGNT   := v_igpacevalue;
      obj_agntpf.REPORTTO := v_igpacevalue;

      INSERT INTO AGNTPF VALUES obj_agntpf;
      -- insert in  IG Jd1dta.Agntpf table end-
      -- insert in+  IG Jd1dta.AGPLPF table start-
      obj_agplpf.AGNTPFX   := v_agntpfx;
      obj_agplpf.STLBASIS  := v_stlbasis;
      obj_agplpf.LICNEXDT  := v_licnexdt;
      obj_agplpf.LOB       := v_lob;
      obj_agplpf.VALIDFLAG := v_validflag;
      obj_agplpf.AGSTDATE  := v_agstdate;
      obj_agplpf.ENDDATE   := v_enddate;
      obj_agplpf.STRTDATE  := v_strtdate;
      --obj_agplpf.APRVDATE   := v_aprvdate;  -- AG2
      obj_agplpf.AGNTCOY  := i_company;
      obj_agplpf.AGNTNUM  := v_zarefnum;
      obj_agplpf.ARCON    := v_arcon;
      obj_agplpf.CRLIMIT  := v_igintvalue;
      obj_agplpf.CREDTERM := v_igintvalue;
      --obj_agplpf.EXPNOT     := v_igintvalue;   -- AG2
      obj_agplpf.EXPNOT := v_igpacevalue; -- AG2
      --obj_agplpf.LICENCE    := v_igintvalue; -- AG2
      obj_agplpf.LICENCE    := v_igpacevalue; -- AG2
      obj_agplpf.RIDESC     := v_ridesc;
      obj_agplpf.STREQ      := v_statementreqd;
      obj_agplpf.SRDATE     := v_srdate;
      obj_agplpf.DATEEND    := v_dateend;
      obj_agplpf.GSTREG     := v_igpacevalue;
      obj_agplpf.AGNTSTATUS := v_igpacevalue;
      obj_agplpf.TMPCRLMT   := v_igintvalue;
      obj_agplpf.VATFLG     := v_igpacevalue;
      obj_agplpf.VMAXCOM    := v_igpacevalue;
      --obj_agplpf.Z6SLFINV   := v_igpacevalue; -- AG2
      obj_agplpf.USRPRF := i_usrprf;
      obj_agplpf.JOBNM  := i_scheduleNumber;
      obj_agplpf.DATIME := LOCALTIMESTAMP;

      --SIT Bug Fix
      obj_agplpf.RLRPFX     := v_igpacevalue;
      obj_agplpf.RLRCOY     := v_igpacevalue;
      obj_agplpf.RLRACC     := v_igpacevalue;
      obj_agplpf.ZSTMTOSIND := v_igpacevalue;
      obj_agplpf.ZTOFLG     := v_igpacevalue;
      obj_agplpf.ACCSRC     := v_igpacevalue;
      obj_agplpf.AGTLICNO   := v_igpacevalue;

      INSERT INTO AGPLPF VALUES obj_agplpf;
      -- insert in  IG Jd1dta.AGPLPF table end-
      -- insert in  IG Jd1dta.ZACRPF table start-
      obj_zacrpf.AGNTPFX   := v_agntpfx;
      obj_zacrpf.VALIDFLAG := v_validflag;
      obj_zacrpf.AGNTCOY   := i_company;
      obj_zacrpf.GAGNTSEL  := v_zarefnum;
      obj_zacrpf.EFFDATE   := v_srdate;
      obj_zacrpf.ZINSTYP01 := v_zinstyp01;
      obj_zacrpf.ZINSTYP02 := v_igpacevalue;
      obj_zacrpf.ZINSTYP03 := v_igpacevalue;
      obj_zacrpf.ZINSTYP04 := v_igpacevalue;
      obj_zacrpf.ZINSTYP05 := v_igpacevalue;
      obj_zacrpf.ZINSTYP06 := v_igpacevalue;
      obj_zacrpf.ZINSTYP07 := v_igpacevalue;
      obj_zacrpf.ZINSTYP08 := v_igpacevalue;
      obj_zacrpf.ZINSTYP09 := v_igpacevalue;
      obj_zacrpf.ZINSTYP10 := v_igpacevalue;
      obj_zacrpf.CMRATE01  := v_cmrate01;
      obj_zacrpf.CMRATE02  := v_igintvalue;
      obj_zacrpf.CMRATE03  := v_igintvalue;
      obj_zacrpf.CMRATE04  := v_igintvalue;
      obj_zacrpf.CMRATE05  := v_igintvalue;
      obj_zacrpf.CMRATE06  := v_igintvalue;
      obj_zacrpf.CMRATE07  := v_igintvalue;
      obj_zacrpf.CMRATE08  := v_igintvalue;
      obj_zacrpf.CMRATE09  := v_igintvalue;
      obj_zacrpf.CMRATE10  := v_igintvalue;
      obj_zacrpf.USRPRF    := i_usrprf;
      obj_zacrpf.JOBNM     := i_scheduleNumber;
      obj_zacrpf.DATIME    := LOCALTIMESTAMP;
      INSERT INTO ZACRPF VALUES obj_zacrpf;
      -- insert in  IG Jd1dta.ZACRPF table end-
      -- insert in  IG CLRRPF table start-
      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
      obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
      obj_clrrpf.CLNTPFX       := v_clntpfx;
      obj_clrrpf.CLNTCOY       := v_clntcoy;
      obj_clrrpf.CLNTNUM       := temp_clntnum;
      obj_clrrpf.CLRRROLE      := C_CLRROLE;
      obj_clrrpf.FOREPFX       := C_CLRROLE;
      obj_clrrpf.FORECOY       := i_company;
      obj_clrrpf.FORENUM       := v_zarefnum;
      obj_clrrpf.USED2B        := v_igpacevalue;
      obj_clrrpf.JOBNM         := i_scheduleNumber;
      obj_clrrpf.USRPRF        := i_usrprf;
      obj_clrrpf.DATIME        := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;
      -- insert in  IG CLRRPF table end-

      ----AG3:Insert into audit_clrrpf :Start---------

      obj_audit_clrrpf.oldclntnum  := temp_clntnum;
      obj_audit_clrrpf.newclntpfx  := v_clntpfx;
      obj_audit_clrrpf.newclntcoy  := v_clntcoy;
      obj_audit_clrrpf.newclntnum  := temp_clntnum;
      obj_audit_clrrpf.newclrrrole := C_CLRROLE;
      obj_audit_clrrpf.newforepfx  := C_CLRROLE;
      obj_audit_clrrpf.newforecoy  := i_company;
      obj_audit_clrrpf.newforenum  := v_zarefnum;
      obj_audit_clrrpf.newused2b   := v_igpacevalue;
      obj_audit_clrrpf.newusrprf   := i_usrprf;
      obj_audit_clrrpf.newjobnm    := i_scheduleNumber;
      obj_audit_clrrpf.newdatime   := sysdate;
      obj_audit_clrrpf.userid      := ' ';
      obj_audit_clrrpf.action      := 'INSERT';
      obj_audit_clrrpf.tranno      := 2;
      obj_audit_clrrpf.systemdate  := sysdate;
      insert into audit_clrrpf values obj_audit_clrrpf;
      ----------AG3 :insert into audit_clrrfpf:end---------
    END IF;
  END LOOP;
  CLOSE AGENCY_cursor;
  NULL;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
END BQ9S5_AG01_AGENCY;