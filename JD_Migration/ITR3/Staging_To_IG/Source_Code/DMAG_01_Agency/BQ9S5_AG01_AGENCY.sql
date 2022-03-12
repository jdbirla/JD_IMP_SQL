create or replace PROCEDURE                                    BQ9S5_AG01_AGENCY(i_scheduleName   IN VARCHAR2,
                                                i_scheduleNumber IN VARCHAR2,
                                                i_zprvaldYN      IN VARCHAR2,
                                                i_company        IN VARCHAR2,
                                                i_usrprf         IN VARCHAR2,
                                                i_branch         IN VARCHAR2,
                                                i_transCode      IN VARCHAR2,
                                                i_vrcmTermid     IN VARCHAR2,
                                                start_id         IN NUMBER,
                                                end_id           IN NUMBER)
    AUTHID current_user AS
   /***************************************************************************************************
    * Amenment History: AG01 Agency
    * Date    Initials   Tag   Decription
    * -----   --------   ---   ---------------------------------------------------------------------------
    * MMMDD    XXX       AG1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    * Mar24    JDB       AG1   Pa New Implementation
    * SEP18    JDB       AG2   ZREPSTNM can be null removing validation
    * SEP18    JDB       AG3   INSH validation for only old agents
    * JAN29    JDB       AG4   IG CR changes included
	* MAR01    JDB		 AG5   Post validation cosidaration
    *****************************************************************************************************/
    -- Local Variables Declaration
    v_timestart        NUMBER := dbms_utility.get_time;
    v_isDuplicate      NUMBER(1) DEFAULT 0;
    v_isValid          NUMBER(1) DEFAULT 0;
    v_isDateValid      VARCHAR2(20 CHAR);
    v_isAnyError       VARCHAR2(1) DEFAULT 'N';
    v_repagent01       VARCHAR2(20);
    v_qpad             VARCHAR2(14);
    v_ig_clntnum       VARCHAR2(10);
    v_accountclass     VARCHAR2(5);
    v_arcon            VARCHAR2(5);
    v_statementreqd    VARCHAR2(5);
    v_agntnum_agentcoy VARCHAR2(35);
    v_AgentType        VARCHAR2(1);
    errorCount         NUMBER(1) DEFAULT 0;
    v_busdate          busdpf.busdate%type;
    p_exitcode         number;
    p_exittext         varchar2(2000);
    v_existCount       number;
    v_pkValueClrrpf    CLRRPF.UNIQUE_NUMBER%type;

    v_shiagCount number;
    isSHIAgent   VARCHAR2(1) := 'N';
    isNewAgent   VARCHAR2(1) := 'N';
    isPAAgent    VARCHAR2(1) := 'N';
    isAddedAgent VARCHAR2(1) := 'N';

    ------Define Constant-----------
    C_PREFIX CONSTANT VARCHAR2(2 CHAR) := Jd1dta.GET_MIGRATION_PREFIX('AGCY',
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
    /* RQN0 Insurance Type a??g 1 cannot be blank */
    C_Z057 CONSTANT VARCHAR2(4) := 'RQN1';
    C_Z064 CONSTANT VARCHAR2(4) := 'RQN8';
    /* RQN1 Commission rate -1 cannot be blank */
    -- C_E036       CONSTANT VARCHAR2(4) := 'E036';
    
      C_PA01 CONSTANT VARCHAR2(4) := 'PA01';
     /* CPYNAME cannot blank*/
    
    ------Define Constant to read end
    C_CLRROLE CONSTANT VARCHAR2(4) := 'AG';
    C_SHI CONSTANT VARCHAR2(3) := 'SHI';
    --------Null and spaces-----------
    C_AGNTREL    CONSTANT CHAR(2 CHAR) := '  ';
    C_REPAGENT02 CONSTANT CHAR(12 CHAR) := '            ';
    C_REPAGENT03 CONSTANT CHAR(12 CHAR) := '            ';
    C_REPAGENT04 CONSTANT CHAR(12 CHAR) := '            ';
    C_REPAGENT05 CONSTANT CHAR(12 CHAR) := '            ';
    C_REPAGENT06 CONSTANT CHAR(12 CHAR) := '            ';
    C_REPORTAG02 CONSTANT CHAR(8 CHAR) := '        ';
    C_REPORTAG03 CONSTANT CHAR(8 CHAR) := '        ';
    C_REPORTAG04 CONSTANT CHAR(8 CHAR) := '        ';
    C_REPORTAG05 CONSTANT CHAR(8 CHAR) := '        ';
    C_REPORTAG06 CONSTANT CHAR(8 CHAR) := '        ';
    C_FGCOMMTABL CONSTANT CHAR(5 CHAR) := '     ';
    C_LIFAGNT    CONSTANT CHAR(1 CHAR) := ' ';
    C_STCC       CONSTANT CHAR(3 CHAR) := '   ';
    C_STCD       CONSTANT CHAR(3 CHAR) := '   ';
    C_STCE       CONSTANT CHAR(3 CHAR) := '   ';
    C_CONTPERS   CONSTANT CHAR(20 CHAR) := null;
    C_TAKOAGNT   CONSTANT CHAR(10 CHAR) := null;
    C_ARCON      CONSTANT CHAR(2 CHAR) := ' ';
    C_STREQ      CONSTANT CHAR(2 CHAR) := ' ';
    C_CRTERM     CONSTANT CHAR(1 CHAR) := null;
    C_STLBASIS   CONSTANT CHAR(1 CHAR) := ' ';
    C_RLRCOY     CONSTANT CHAR(1 CHAR) := ' ';
    C_MSAGNT     CONSTANT CHAR(8 CHAR) := '       ';
    C_REPORTTO   CONSTANT CHAR(8 CHAR) := '       ';
    C_ZBKIND     CONSTANT CHAR(2 CHAR) := ' ';
    C_ZDISTRICT  CONSTANT CHAR(3 CHAR) := '   ';
    C_ZFGCMTBN   CONSTANT CHAR(5 CHAR) := '     ';
    C_ZSTAFFCD   CONSTANT CHAR(6 CHAR) := '     ';
    C_BANKCODE01 CONSTANT CHAR(2 CHAR) := ' ';
    C_BANKCODE02 CONSTANT CHAR(2 CHAR) := ' ';
    C_BANKCODE03 CONSTANT CHAR(2 CHAR) := ' ';
    C_BANKCODE04 CONSTANT CHAR(2 CHAR) := ' ';
    C_BANKCODE05 CONSTANT CHAR(2 CHAR) := ' ';
    C_PRODCTCATG CONSTANT CHAR(8 CHAR) := '       ';
    C_AUTHBY     CONSTANT NCHAR(10 CHAR) := null;
    C_EXPNOT     CONSTANT CHAR(1 CHAR) := ' ';
    C_LICENCE    CONSTANT CHAR(15 CHAR) := '               ';
    C_RLRPFX     CONSTANT CHAR(2 CHAR) := ' ';
    C_RLRACC     CONSTANT CHAR(8 CHAR) := '       ';
    C_ZSTMTOSIND CONSTANT CHAR(1 CHAR) := ' ';
    C_ZTOFLG     CONSTANT CHAR(1 CHAR) := ' ';
    C_ACCSRC     CONSTANT CHAR(3 CHAR) := '   ';
    C_AGTLICNO   CONSTANT NCHAR(25 CHAR) := '                         ';
    C_GSTREG     CONSTANT CHAR(15 CHAR) := '               ';
    C_AGNTSTATUS CONSTANT NCHAR(1 CHAR) := ' ';
    C_VMAXCOM    CONSTANT CHAR(1 CHAR) := '';
    C_Z6SLFINV   CONSTANT NCHAR(16 CHAR) := '';
    C_VATFLG     CONSTANT NCHAR(1 CHAR) := '';
    C_USED2B     CONSTANT CHAR(1 CHAR) := ' ';
    ---------------------

    ------IG table obj start---
    obj_agntpf         Jd1dta.AGNTPF%rowtype;
    obj_agplpf         Jd1dta.AGPLPF%rowtype;
    obj_zacrpf         Jd1dta.ZACRPF%rowtype;
    obj_clrrpf         Jd1dta.CLRRPF%rowtype;
    obj_VIEW_DM_ZDROPF Jd1dta.VIEW_DM_PAZDROPF%rowtype;
    obj_audit_clrrpf   Jd1dta.AUDIT_CLRRPF%rowtype;

    ------IG table obj End---

    --------------------------COMMON FUNCTION START-----------------------------------------------------------------------
    --  v_tablecnt      NUMBER(1) := 0;
    v_tableNametemp VARCHAR2(10);
    v_tableName     VARCHAR2(10);
    --  itemexist pkg_dm_common_operations.itemschec;
    o_errortext     pkg_dm_common_operations.errordesc;
    itemexist       pkg_dm_agency.itemschec;
    i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
    o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
    getzigvalue     pkg_dm_agency.zigvaluetype;
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
      SELECT *
        FROM dmigtitdmgagentpj
       WHERE RECIDXAGENT between start_id and end_id
       order by ZAREFNUM ASC;
    obj_agency AGENCY_cursor%rowtype;
  BEGIN
    dbms_output.put_line('Start execution of BQ9S5_AG01_AGENCY, SC NO:  ' ||
                         i_scheduleNumber || ' Flag :' || i_zprvaldYN);

    p_exitcode := 0;
    p_exittext := NULL;
    select BUSDATE
      into v_busdate
      from busdpf
     where busdkey = 'DATE'
       and company = '1';
    --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------
    pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9S5,
                                       o_defaultvalues => o_defaultvalues);
    pkg_dm_common_operations.geterrordesc(i_module_name => 'DMAG',
                                          o_errortext   => o_errortext);
    pkg_dm_agency.getitemvalue(itemexist => itemexist);
    v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                       LPAD(TRIM(i_scheduleNumber), 4, '0');
    v_tableName     := TRIM(v_tableNametemp);
    -- pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
    pkg_dm_agency.getzigvalue(getzigvalue => getzigvalue);
    --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------
    v_qpad := CONCAT('QPAD', TO_NUMBER(TO_CHAR(sysdate, 'YYMMDDHHMM')));
    -- Open Cursor
    OPEN AGENCY_cursor;
    <<skipRecord>>
    LOOP
      FETCH AGENCY_cursor
        INTO obj_agency;
      EXIT WHEN AGENCY_cursor%notfound;
      v_agntnum_agentcoy := CONCAT(i_company, obj_agency.ZAREFNUM);
      v_repagent01 := CONCAT(o_defaultvalues('AGNTPFX'), v_agntnum_agentcoy);
      v_isAnyError := 'N';
      errorCount := 0;
      v_AgentType := 'N';
      i_zdoe_info := NULL;
      t_ercode(1) := ' ';
      t_ercode(2) := ' ';
      t_ercode(3) := ' ';
      t_ercode(4) := ' ';
      t_ercode(5) := ' ';
      i_zdoe_info.i_zfilename := 'TITDMGAGENTPJ';
      i_zdoe_info.i_prefix := C_PREFIX;
      i_zdoe_info.i_tableName := v_tableName;
      i_zdoe_info.i_refKey := TRIM(obj_agency.ZAREFNUM);

  v_shiagCount :=0;
    isSHIAgent    := 'N';
    isNewAgent    := 'N';
    isPAAgent    := 'N';
    isAddedAgent := 'N';
      -- Validatin Of Fields- Start
      -- 1) Duplicate Record if already Migrated in table PAZDROPF
      IF TRIM(obj_agency.ZAREFNUM) IS NULL THEN
        v_isAnyError                 := 'Y';
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z064;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z064);
        i_zdoe_info.i_errorfield01   := 'ZAREFNUM';
        i_zdoe_info.i_fieldvalue01   := obj_agency.ZAREFNUM;
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      ELSE
        SELECT COUNT(*)
          INTO v_isDuplicate
          FROM Jd1dta.PAZDROPF
         WHERE RTRIM(ZENTITY) = TRIM(obj_agency.ZAREFNUM)
           and prefix = 'AG';

        IF v_isDuplicate > 0 THEN
          v_isAnyError                 := 'Y';
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error01        := C_Z099;
          i_zdoe_info.i_errormsg01     := o_errortext(C_Z099);
          i_zdoe_info.i_errorfield01   := 'ZAREFNUM';
          i_zdoe_info.i_fieldvalue01   := obj_agency.ZAREFNUM;
          i_zdoe_info.i_errorprogram01 := i_scheduleName;
          pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
          CONTINUE skipRecord;
        END IF;
      END IF;

      select count(1)
        into v_existCount
        from Jd1dta.agntpf
       where trim(AGNTNUM) In (trim(obj_agency.ZAREFNUM));
      if (v_existCount > 0) THEN
        select count(1)
          into v_shiagCount
          from Jd1dta.zagppf
         where (TRIM(GAGNTSEL01) = trim(obj_agency.ZAREFNUM) OR
               TRIM(GAGNTSEL02) = trim(obj_agency.ZAREFNUM) OR
               TRIM(GAGNTSEL03) = trim(obj_agency.ZAREFNUM) OR
               TRIM(GAGNTSEL04) = trim(obj_agency.ZAREFNUM) OR
               TRIM(GAGNTSEL05) = trim(obj_agency.ZAREFNUM));
     IF ((v_shiagCount > 0) and (obj_agency.zinstyp01 != 'SHI')) THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := 'INSI';
        t_errormsg(errorCount) := 'Instype 1 must contain SHI';
        t_errorfield(errorCount) := 'instyp01';
        t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP01);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
        end if;



        if ((v_shiagCount > 0) and (obj_agency.zinstyp01 = 'SHI') and
           (trim(obj_agency.zinstyp02) IS NULL)) then
          isSHIAgent := 'Y'; --Consider as SHI agent and will update only direct handling flag: Case 3

        ELSIF ((v_shiagCount > 0) and (obj_agency.zinstyp01 = 'SHI') and
              (trim(obj_agency.zinstyp02) IS not NULL)) then

          isAddedAgent := 'Y'; --Consider as SHI and PA agent and update only PA insurance type and Comm rate :Case 4

        else
          isPAAgent := 'Y'; --Consider as PA agent and update all columns of all tables in IG : Case2

        end if;

      else
        isNewAgent := 'Y'; ---Will create new agent in IG case1

      END IF;

      -- 2) CLNTNUM is null
      IF TRIM(obj_agency.CLNTNUM) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z071;
        t_errormsg(errorCount) := o_errortext(C_Z071);
        t_errorfield(errorCount) := 'CLNTNUM';
        t_errorfieldval(errorCount) := TRIM(obj_agency.CLNTNUM);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      else
        -- 3) CLNTNUM is already Migrated or not


        IF NOT (getzigvalue.exists(obj_agency.CLNTNUM)) THEN
          v_isAnyError := 'Y';
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z002;
          t_errormsg(errorCount) := o_errortext(C_Z002);
          t_errorfield(errorCount) := 'CLNTNUM';
          t_errorfieldval(errorCount) := TRIM(obj_agency.CLNTNUM);
          t_errorprogram(errorCount) := i_scheduleName;
          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      end if;
      --4) AGTYPE is null
      IF TRIM(obj_agency.AGTYPE) IS NULL THEN
        v_isAnyError := 'Y';
        v_AgentType := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z065;
        t_errormsg(errorCount) := o_errortext(C_Z065);
        t_errorfield(errorCount) := 'AGTYPE';
        t_errorfieldval(errorCount) := TRIM(obj_agency.AGTYPE);
        t_errorprogram(errorCount) := i_scheduleName;

        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      ELSE

        IF NOT
            (itemexist.exists(TRIM(C_T3692) || TRIM(obj_agency.AGTYPE) || 1)) THEN
          v_isAnyError := 'Y';

          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z061;
          t_errormsg(errorCount) := o_errortext(C_Z061);
          t_errorfield(errorCount) := 'AGTYPE';
          t_errorfieldval(errorCount) := TRIM(obj_agency.AGTYPE);
          t_errorprogram(errorCount) := i_scheduleName;

          IF errorCount >= 5 THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      END IF;
      
      --AG5:start
       IF TRIM(obj_agency.CPYNAME) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_PA01;
        t_errormsg(errorCount) := 'CPYNAME cannot blank';
        t_errorfield(errorCount) := 'CPYNAME';
        t_errorfieldval(errorCount) := TRIM(obj_agency.CPYNAME);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
	   --AG5:end
      --6) AGNTBR is null
      IF TRIM(obj_agency.AGNTBR) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z066;
        t_errormsg(errorCount) := o_errortext(C_Z066);
        t_errorfield(errorCount) := 'AGNTBR';
        t_errorfieldval(errorCount) := TRIM(obj_agency.AGNTBR);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;

        IF NOT
            (itemexist.exists(TRIM(C_T1692) || TRIM(obj_agency.AGNTBR) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z062;
            t_errormsg(errorCount) := o_errortext(C_Z062);
            t_errorfield(errorCount) := 'AGNTBR';
            t_errorfieldval(errorCount) := TRIM(obj_agency.AGNTBR);
            t_errorprogram(errorCount) := i_scheduleName;
            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
        -- 11) SRDATE is blank, 0 or 99999999
        IF TRIM(obj_agency.SRDATE) IS NULL OR TRIM(obj_agency.SRDATE) = 0 OR
           TRIM(obj_agency.SRDATE) = 99999999 THEN
          v_isAnyError := 'Y';
          errorCount := errorCount + 1;
          t_ercode(errorCount) := C_Z067;
          t_errormsg(errorCount) := o_errortext(C_Z067);
          t_errorfield(errorCount) := 'SRDATE';
          t_errorfieldval(errorCount) := TRIM(obj_agency.SRDATE);
          t_errorprogram(errorCount) := i_scheduleName;
          IF errorCount >= 5 THEN
            GOTO insertzdoe;

          END IF;
          --16) SRDATE Date Formate
        ELSE
          v_isDateValid := VALIDATE_DATE(obj_agency.SRDATE);
          IF v_isDateValid <> 'OK' THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z013;
            t_errormsg(errorCount) := o_errortext(C_Z013);
            t_errorfield(errorCount) := 'SRDATE';
            t_errorfieldval(errorCount) := TRIM(obj_agency.SRDATE);
            t_errorprogram(errorCount) := i_scheduleName;
            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;

          END IF;
        END IF;
      END IF;
      -- 17) DATEEND Date Formate
      v_isDateValid := VALIDATE_DATE(obj_agency.DATEEND);
      IF v_isDateValid <> 'OK' THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z013;
        t_errormsg(errorCount) := o_errortext(C_Z013);
        t_errorfield(errorCount) := 'DATEEND';
        t_errorfieldval(errorCount) := TRIM(obj_agency.DATEEND);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      -- 18) ZCONSIDT Date Formate
      v_isDateValid := VALIDATE_DATE(obj_agency.ZCONSIDT);
      IF v_isDateValid <> 'OK' THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z013;
        t_errormsg(errorCount) := o_errortext(C_Z013);
        t_errorfield(errorCount) := 'ZCONSIDT';
        t_errorfieldval(errorCount) := TRIM(obj_agency.ZCONSIDT);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      --8) STCA is valid in T3595
      IF NOT (itemexist.exists(TRIM(C_T3595) || TRIM(obj_agency.STCA) || 1)) THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z063;
        t_errormsg(errorCount) := o_errortext(C_Z063);
        t_errorfield(errorCount) := 'STCA';
        t_errorfieldval(errorCount) := TRIM(obj_agency.STCA);
        t_errorprogram(errorCount) := i_scheduleName;

        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      ---Instyp01,02,03,04,05,06,07,08,09 must not contain SHI

  --AG3  : INSH validation for only old agents
      if(isSHIAgent = 'Y'  or isPAAgent = 'Y' or isAddedAgent='Y' )then
      IF (
        (TRIM(obj_agency.ZINSTYP02) IS NOt NULL and TRIM(obj_agency.ZINSTYP02)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP03) IS NOt NULL and TRIM(obj_agency.ZINSTYP03)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP04) IS NOt NULL and TRIM(obj_agency.ZINSTYP04)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP05) IS NOt NULL and TRIM(obj_agency.ZINSTYP05)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP06) IS NOt NULL and TRIM(obj_agency.ZINSTYP06)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP07) IS NOt NULL and TRIM(obj_agency.ZINSTYP07)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP08) IS NOt NULL and TRIM(obj_agency.ZINSTYP08)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP09) IS NOt NULL and TRIM(obj_agency.ZINSTYP09)= C_SHI) OR
(TRIM(obj_agency.ZINSTYP10) IS NOt NULL and TRIM(obj_agency.ZINSTYP10)= C_SHI)

        ) THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := 'INSH';
        t_errormsg(errorCount) := 'Instype 2 to 10 must not contain SHI';
        t_errorfield(errorCount) := 'INSTYP2_10';
        t_errorfieldval(errorCount) := TRIM(obj_agency.ZAREFNUM);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
        end if;
end if;
      --10) ZINSTYP is null or not
      IF TRIM(obj_agency.ZINSTYP01) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z056;
        t_errormsg(errorCount) := o_errortext(C_Z056);
        t_errorfield(errorCount) := 'ZINSTYP01';
        t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP01);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
        --9) ZINSTYP is valid in TQ9B6
      ELSE
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP01) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP01';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP01);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP02) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP02) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP02';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP02);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP03) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP03) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP03';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP03);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP04) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP04) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP04';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP04);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP05) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP05) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP05';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP05);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP06) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP06) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP06';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP06);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP07) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP07) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP07';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP07);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP08) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP08) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP08';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP08);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      IF TRIM(obj_agency.ZINSTYP09) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP09) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP09';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP09);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;

      IF TRIM(obj_agency.ZINSTYP10) IS NOT NULL THEN
        IF NOT
            (itemexist.exists(TRIM(C_TQ9B6) || TRIM(obj_agency.ZINSTYP10) || 1)) THEN
          IF v_isValid = 0 THEN
            v_isAnyError := 'Y';
            errorCount := errorCount + 1;
            t_ercode(errorCount) := C_Z038;
            t_errormsg(errorCount) := o_errortext(C_Z038);
            t_errorfield(errorCount) := 'ZINSTYP10';
            t_errorfieldval(errorCount) := TRIM(obj_agency.ZINSTYP10);
            t_errorprogram(errorCount) := i_scheduleName;

            IF errorCount >= 5 THEN
              GOTO insertzdoe;
            END IF;
          END IF;
        END IF;
      END IF;
      -- 12) RIDESC is null
      IF TRIM(obj_agency.RIDESC) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z068;
        t_errormsg(errorCount) := o_errortext(C_Z068);
        t_errorfield(errorCount) := 'RIDESC';
        t_errorfieldval(errorCount) := TRIM(obj_agency.RIDESC);
        t_errorprogram(errorCount) := i_scheduleName;

        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      -- 13) AGCLSD is null
      IF TRIM(obj_agency.AGCLSD) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z069;
        t_errormsg(errorCount) := o_errortext(C_Z069);
        t_errorfield(errorCount) := 'AGCLSD';
        t_errorfieldval(errorCount) := TRIM(obj_agency.AGCLSD);
        t_errorprogram(errorCount) := i_scheduleName;

        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      -- 14) ZREPSTNM is null
    /* AG2 : removing validation  :START
      IF TRIM(obj_agency.ZREPSTNM) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z070;
        t_errormsg(errorCount) := o_errortext(C_Z070);
        t_errorfield(errorCount) := 'ZREPSTNM';
        t_errorfieldval(errorCount) := TRIM(obj_agency.ZREPSTNM);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      AG2 : removing validation  :END
      */
      --15)CMRATE01 IS NULL
      IF TRIM(obj_agency.CMRATE01) IS NULL THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z057;
        t_errormsg(errorCount) := o_errortext(C_Z057);
        t_errorfield(errorCount) := 'CMRATE01';
        t_errorfieldval(errorCount) := TRIM(obj_agency.CMRATE01);
        t_errorprogram(errorCount) := i_scheduleName;
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
      IF (itemexist.exists(TRIM('T3692') || TRIM(obj_agency.AGTYPE) ||
                           TRIM('1'))) THEN
        v_accountclass  := itemexist(TRIM('T3692') || TRIM(obj_agency.AGTYPE) || TRIM('1'))
                           .v_accountclass;
        v_arcon         := itemexist(TRIM('T3692') || TRIM(obj_agency.AGTYPE) || TRIM('1'))
                           .v_arcon;
        v_statementreqd := itemexist(TRIM('T3692') || TRIM(obj_agency.AGTYPE) || TRIM('1'))
                           .v_statementreqd;
      END IF;
      IF (v_isAnyError = 'N') THEN
        i_zdoe_info.i_indic := 'S';
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      END IF;
      v_ig_clntnum := getzigvalue(obj_agency.clntnum);

      IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN
        --Insert Into Data Migration Registry  table - PAZDROPF
        ------CASE1,NEW Agent: START----------------
        if (isNewAgent = 'Y') THEN

          -----insert into PAZDROPF----

          obj_VIEW_DM_ZDROPF.RECSTATUS := 'OK';
          obj_VIEW_DM_ZDROPF.PREFIX    := 'AG';
          obj_VIEW_DM_ZDROPF.ZENTITY   := obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.ZIGVALUE  := 'CASE1_' ||obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
          obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
          Insert into View_Dm_PAZdropf values obj_VIEW_DM_ZDROPF;
          -----Insert in AGNTPF:START--------------------
          obj_agntpf.AGNTPFX   := o_defaultvalues('AGNTPFX');
          obj_agntpf.VALIDFLAG := o_defaultvalues('VALIDFLAG');
          obj_agntpf.CLNTPFX   := o_defaultvalues('CLNTPFX');
          obj_agntpf.CLNTCOY   := o_defaultvalues('CLNTCOY');
          obj_agntpf.AGNTREL   := C_AGNTREL;
          obj_agntpf.REPLVL    := o_defaultvalues('REPLVL');
          obj_agntpf.FGAGNT    := o_defaultvalues('FGAGNT');
          obj_agntpf.AGNTCOY   := i_company;
          obj_agntpf.AGNTNUM   := obj_agency.ZAREFNUM;
          obj_agntpf.TRANID    := v_qpad;
          obj_agntpf.CLNTNUM   := v_ig_clntnum; ---- same
          obj_agntpf.AGTYPE    := obj_agency.AGTYPE;
          obj_agntpf.AGNTBR    := obj_agency.AGNTBR;

          obj_agntpf.REPAGENT01 := v_repagent01;
          obj_agntpf.REPAGENT02 := C_REPAGENT02;
          obj_agntpf.REPAGENT03 := C_REPAGENT03;
          obj_agntpf.REPAGENT04 := C_REPAGENT04;
          obj_agntpf.REPAGENT05 := C_REPAGENT05;
          obj_agntpf.REPAGENT06 := C_REPAGENT06;
          obj_agntpf.REPORTAG01 := obj_agency.ZAREFNUM;
          obj_agntpf.REPORTAG02 := C_REPORTAG02;
          obj_agntpf.REPORTAG03 := C_REPORTAG03;
          obj_agntpf.REPORTAG04 := C_REPORTAG04;
          obj_agntpf.REPORTAG05 := C_REPORTAG05;
          obj_agntpf.REPORTAG06 := C_REPORTAG06;
          obj_agntpf.FGCOMMTABL := C_FGCOMMTABL;
          obj_agntpf.LIFAGNT    := C_LIFAGNT;
          obj_agntpf.SRDATE     := obj_agency.SRDATE;
          obj_agntpf.DATEEND    := obj_agency.DATEEND;
          obj_agntpf.STCA       := obj_agency.STCA;
          obj_agntpf.STCB       := v_accountclass;
          obj_agntpf.STCC       := C_STCC;
          obj_agntpf.STCD       := C_STCD;
          obj_agntpf.STCE       := C_STCE;
          obj_agntpf.ZBKIND     := C_ZBKIND;
          obj_agntpf.ZDISTRICT  := C_ZDISTRICT;
          obj_agntpf.ZFGCMTBN   := C_ZFGCMTBN;
          obj_agntpf.ZSTAFFCD   := C_ZSTAFFCD;
          obj_agntpf.BANKCODE01 := C_BANKCODE01;
          obj_agntpf.BANKCODE02 := C_BANKCODE02;
          obj_agntpf.BANKCODE03 := C_BANKCODE03;
          obj_agntpf.BANKCODE04 := C_BANKCODE04;
          obj_agntpf.BANKCODE05 := C_BANKCODE05;
          obj_agntpf.PRODCTCATG := C_PRODCTCATG;
          obj_agntpf.AGCLSD     := obj_agency.AGCLSD;
          obj_agntpf.ZCONSIDT   := obj_agency.ZCONSIDT;
          obj_agntpf.BLKLIMIT   := o_defaultvalues('BLKLIMIT');
          obj_agntpf.PROVSTAT   := o_defaultvalues('PROVSTAT');
          obj_agntpf.DCONSIGNEN := obj_agency.DCONSIGNEN;
          obj_agntpf.AUTHBY     := C_AUTHBY;
          obj_agntpf.CPYNAME    := obj_agency.CPYNAME;
          obj_agntpf.ZAGREGNO   := obj_agency.ZAGREGNO;
          obj_agntpf.ZTRGTFLG   := obj_agency.ZTRGTFLG;
          obj_agntpf.AUTHDATE   := o_defaultvalues('AUTHDATE');
          obj_agntpf.AUTHDATEG  := 99999999;
          obj_agntpf.DTECRT     := v_busdate;
          obj_agntpf.COUNT      := obj_agency.COUNT;
          obj_agntpf.CRTUSER    := i_usrprf;
          obj_agntpf.ZSKPAUTOC  := o_defaultvalues('ZSKPAUTOC');
          obj_agntpf.ZREPSTNM   := obj_agency.ZREPSTNM;
          obj_agntpf.USRPRF     := i_usrprf;
          obj_agntpf.JOBNM      := i_scheduleName;
          obj_agntpf.DATIME     := LOCALTIMESTAMP;
          obj_agntpf.Crlimit    := o_defaultvalues('CRLIMIT');
          obj_agntpf.ridesc     := obj_agency.RIDESC;
          obj_agntpf.credittrm  := o_defaultvalues('CREDTERM');
          obj_agntpf.CONTPERS   := C_CONTPERS;
          obj_agntpf.TAKOAGNT   := C_TAKOAGNT;
          obj_agntpf.ARCON      := C_ARCON;
          obj_agntpf.STREQ      := C_STREQ;
          obj_agntpf.CRTERM     := C_CRTERM;
          obj_agntpf.STLBASIS   := C_STLBASIS;
          obj_agntpf.EXPNOT     := C_EXPNOT;
          obj_agntpf.LICENCE    := C_LICENCE;
          obj_agntpf.RLRPFX     := C_RLRPFX;
          obj_agntpf.RLRCOY     := C_RLRCOY;
          obj_agntpf.RLRACC     := C_RLRACC;
          obj_agntpf.MSAGNT     := C_MSAGNT;
          obj_agntpf.REPORTTO   := C_REPORTTO;

          ---AG1:START----
          obj_agntpf.zdragnt := obj_agency.zdragnt;
          ---AG1:END----
          --AG4:START--
          obj_agntpf.amount := null;
          obj_agntpf.REIMBTYP := null;
            --AG4:END--

          INSERT INTO AGNTPF VALUES obj_agntpf;
          -----Insert in AGNTPF:END--------------------

          ----- Insert in  IG Jd1dta.AGPLPF table:Start----------------
          obj_agplpf.AGNTPFX    := o_defaultvalues('AGNTPFX');
          obj_agplpf.STLBASIS   := o_defaultvalues('STLBASIS');
          obj_agplpf.LICNEXDT   := o_defaultvalues('LICNEXDT');
          obj_agplpf.LOB        := o_defaultvalues('LOB');
          obj_agplpf.VALIDFLAG  := o_defaultvalues('VALIDFLAG');
          obj_agplpf.AGSTDATE   := o_defaultvalues('AGSTDATE');
          obj_agplpf.ENDDATE    := o_defaultvalues('ENDDATE');
          obj_agplpf.STRTDATE   := o_defaultvalues('STRTDATE');
          obj_agplpf.APRVDATE   := null;
          obj_agplpf.AGNTCOY    := i_company;
          obj_agplpf.AGNTNUM    := obj_agency.ZAREFNUM;
          obj_agplpf.ARCON      := v_arcon;
          obj_agplpf.CRLIMIT    := o_defaultvalues('CRLIMIT');
          obj_agplpf.CREDTERM   := o_defaultvalues('CREDTERM');
          obj_agplpf.EXPNOT     := C_EXPNOT;
          obj_agplpf.LICENCE    := C_LICENCE;
          obj_agplpf.RIDESC     := obj_agency.RIDESC;
          obj_agplpf.STREQ      := v_statementreqd;
          obj_agplpf.SRDATE     := obj_agency.SRDATE;
          obj_agplpf.DATEEND    := obj_agency.DATEEND;
          obj_agplpf.GSTREG     := C_GSTREG;
          obj_agplpf.AGNTSTATUS := C_AGNTSTATUS;
          obj_agplpf.TMPCRLMT   := o_defaultvalues('TMPCRLMT');
          obj_agplpf.VATFLG     := C_VATFLG;
          obj_agplpf.VMAXCOM    := C_VMAXCOM;
          obj_agplpf.Z6SLFINV   := C_Z6SLFINV;
         obj_agplpf.USRPRF     := i_usrprf;
          obj_agplpf.JOBNM      := i_scheduleName;
          obj_agplpf.DATIME     := LOCALTIMESTAMP;
          obj_agplpf.RLRPFX     := C_RLRPFX;
          obj_agplpf.RLRCOY     := C_RLRCOY;
          obj_agplpf.RLRACC     := C_RLRACC;
          obj_agplpf.ZSTMTOSIND := C_ZSTMTOSIND;
          obj_agplpf.ZTOFLG     := C_ZTOFLG;
          obj_agplpf.ACCSRC     := C_ACCSRC;
          obj_agplpf.AGTLICNO   := C_AGTLICNO;

          INSERT INTO AGPLPF VALUES obj_agplpf;
          -- insert in  IG Jd1dta.AGPLPF table end-
          -- insert in  IG Jd1dta.ZACRPF table start-
          obj_zacrpf.AGNTPFX   := o_defaultvalues('AGNTPFX');
          obj_zacrpf.VALIDFLAG := o_defaultvalues('VALIDFLAG');
          obj_zacrpf.AGNTCOY   := i_company;
          obj_zacrpf.GAGNTSEL  := obj_agency.ZAREFNUM;
          obj_zacrpf.EFFDATE   := obj_agency.SRDATE;
          -------AG1:START----------------------------

          IF (TRIM(obj_agency.ZINSTYP01) IS NULL) THEN
            obj_zacrpf.ZINSTYP01 := ' ';
          else
            obj_zacrpf.ZINSTYP01 := obj_agency.ZINSTYP01;
          end if;
          IF (TRIM(obj_agency.ZINSTYP02) IS NULL) THEN
            obj_zacrpf.ZINSTYP02 := ' ';
          else
            obj_zacrpf.ZINSTYP02 := obj_agency.ZINSTYP02;
          end if;
          IF (TRIM(obj_agency.ZINSTYP03) IS NULL) THEN
            obj_zacrpf.ZINSTYP03 := ' ';
          else
            obj_zacrpf.ZINSTYP03 := obj_agency.ZINSTYP03;
          end if;
          IF (TRIM(obj_agency.ZINSTYP04) IS NULL) THEN
            obj_zacrpf.ZINSTYP04 := ' ';
          else
            obj_zacrpf.ZINSTYP04 := obj_agency.ZINSTYP04;
          end if;
          IF (TRIM(obj_agency.ZINSTYP05) IS NULL) THEN
            obj_zacrpf.ZINSTYP05 := ' ';
          else
            obj_zacrpf.ZINSTYP05 := obj_agency.ZINSTYP05;
          end if;
          IF (TRIM(obj_agency.ZINSTYP06) IS NULL) THEN
            obj_zacrpf.ZINSTYP06 := ' ';
          else
            obj_zacrpf.ZINSTYP06 := obj_agency.ZINSTYP06;
          end if;
          IF (TRIM(obj_agency.ZINSTYP07) IS NULL) THEN
            obj_zacrpf.ZINSTYP07 := ' ';
          else
            obj_zacrpf.ZINSTYP07 := obj_agency.ZINSTYP07;
          end if;
          IF (TRIM(obj_agency.ZINSTYP08) IS NULL) THEN
            obj_zacrpf.ZINSTYP08 := ' ';
          else
            obj_zacrpf.ZINSTYP08 := obj_agency.ZINSTYP08;
          end if;
          IF (TRIM(obj_agency.ZINSTYP09) IS NULL) THEN
            obj_zacrpf.ZINSTYP09 := ' ';
          else
            obj_zacrpf.ZINSTYP09 := obj_agency.ZINSTYP09;
          end if;
          IF (TRIM(obj_agency.ZINSTYP10) IS NULL) THEN
            obj_zacrpf.ZINSTYP10 := ' ';
          else
            obj_zacrpf.ZINSTYP10 := obj_agency.ZINSTYP10;
          end if;

          obj_zacrpf.CMRATE01 := obj_agency.CMRATE01;
          obj_zacrpf.CMRATE02 := obj_agency.CMRATE02;
          obj_zacrpf.CMRATE03 := obj_agency.CMRATE03;
          obj_zacrpf.CMRATE04 := obj_agency.CMRATE04;
          obj_zacrpf.CMRATE05 := obj_agency.CMRATE05;
          obj_zacrpf.CMRATE06 := obj_agency.CMRATE06;
          obj_zacrpf.CMRATE07 := obj_agency.CMRATE07;
          obj_zacrpf.CMRATE08 := obj_agency.CMRATE08;
          obj_zacrpf.CMRATE09 := obj_agency.CMRATE09;
          obj_zacrpf.CMRATE10 := obj_agency.CMRATE10;
          -------AG1:END----------------------------
          obj_zacrpf.USRPRF := i_usrprf;
          obj_zacrpf.JOBNM  := i_scheduleName;
          obj_zacrpf.DATIME := LOCALTIMESTAMP;
          INSERT INTO ZACRPF VALUES obj_zacrpf;
          -- insert in  IG Jd1dta.ZACRPF table end-
          -- insert in  IG CLRRPF table start-
          --select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
          v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
          obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
          obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
          obj_clrrpf.CLNTCOY       := o_defaultvalues('CLNTCOY');
          obj_clrrpf.CLNTNUM       := v_ig_clntnum;
          obj_clrrpf.CLRRROLE      := C_CLRROLE;
          obj_clrrpf.FOREPFX       := C_CLRROLE;
          obj_clrrpf.FORECOY       := i_company;
          obj_clrrpf.FORENUM       := obj_agency.ZAREFNUM;
          obj_clrrpf.USED2B        := C_USED2B;
          obj_clrrpf.JOBNM         := i_scheduleName;
          obj_clrrpf.USRPRF        := i_usrprf;
          obj_clrrpf.DATIME        := sysdate;
          INSERT INTO CLRRPF VALUES obj_clrrpf;
          -- insert in  IG CLRRPF table end-

          ----AG3:Insert into audit_clrrpf :Start---------
 v_pkValueClrrpf := SEQ_CLRRPF.nextval; --PerfImprov
          obj_audit_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
          obj_audit_clrrpf.oldclntnum  := v_ig_clntnum;
          obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
          obj_audit_clrrpf.newclntcoy  := o_defaultvalues('CLNTCOY');
          obj_audit_clrrpf.newclntnum  := v_ig_clntnum;
          obj_audit_clrrpf.newclrrrole := C_CLRROLE;
          obj_audit_clrrpf.newforepfx  := C_CLRROLE;
          obj_audit_clrrpf.newforecoy  := i_company;
          obj_audit_clrrpf.newforenum  := obj_agency.ZAREFNUM;
          obj_audit_clrrpf.newused2b   := C_USED2B;
          obj_audit_clrrpf.newusrprf   := i_usrprf;
          obj_audit_clrrpf.newjobnm    := i_scheduleName;
          obj_audit_clrrpf.newdatime   := sysdate;
          obj_audit_clrrpf.userid      := null;
          obj_audit_clrrpf.action      := 'INSERT';
          obj_audit_clrrpf.tranno      := 2;
          obj_audit_clrrpf.systemdate  := sysdate;
          insert into audit_clrrpf values obj_audit_clrrpf;
          ----------AG3 :insert into audit_clrrfpf:end---------
        end if;
        ------CASE1,NEW Agent: END----------------
        ------------CASE2 ,ISPAAGENT:START-----------------------

        IF (isPAAgent = 'Y') THEN
          --update all coulmns of all tables
          -----insert into PAZDROPF----

          obj_VIEW_DM_ZDROPF.RECSTATUS := 'OK';
          obj_VIEW_DM_ZDROPF.PREFIX    := 'AG';
          obj_VIEW_DM_ZDROPF.ZENTITY   := obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.ZIGVALUE  := 'CASE2_'|| obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
          obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
         Insert into View_Dm_PAZdropf values obj_VIEW_DM_ZDROPF;
          -----Update in AGNTPF:START--------------------

          update Jd1dta.AGNTPF
             set AGNTPFX    = o_defaultvalues('AGNTPFX'),
                 VALIDFLAG  = o_defaultvalues('VALIDFLAG'),
                 CLNTPFX    = o_defaultvalues('CLNTPFX'),
                 CLNTCOY    = o_defaultvalues('CLNTCOY'),
                 AGNTREL    = C_AGNTREL,
                 REPLVL     = o_defaultvalues('REPLVL'),
                 FGAGNT     = o_defaultvalues('FGAGNT'),
                 AGNTCOY    = i_company,
                 AGNTNUM    = obj_agency.ZAREFNUM,
                 TRANID     = v_qpad,
                 CLNTNUM    = v_ig_clntnum, ---- same
                 AGTYPE     = obj_agency.AGTYPE,
                 AGNTBR     = obj_agency.AGNTBR,
                 REPAGENT01 = v_repagent01,
                 REPAGENT02 = C_REPAGENT02,
                 REPAGENT03 = C_REPAGENT03,
                 REPAGENT04 = C_REPAGENT04,
                 REPAGENT05 = C_REPAGENT05,
                 REPAGENT06 = C_REPAGENT06,
                 REPORTAG01 = obj_agency.ZAREFNUM,
                 REPORTAG02 = C_REPORTAG02,
                 REPORTAG03 = C_REPORTAG03,
                 REPORTAG04 = C_REPORTAG04,
                 REPORTAG05 = C_REPORTAG05,
                 REPORTAG06 = C_REPORTAG06,
                 FGCOMMTABL = C_FGCOMMTABL,
                 LIFAGNT    = C_LIFAGNT,
                 SRDATE     = obj_agency.SRDATE,
                 DATEEND    = obj_agency.DATEEND,
                 STCA       = obj_agency.STCA,
                 STCB       = v_accountclass,
                 STCC       = C_STCC,
                 STCD       = C_STCD,
                 STCE       = C_STCE,
                 ZBKIND     = C_ZBKIND,
                 ZDISTRICT  = C_ZDISTRICT,
                 ZFGCMTBN   = C_ZFGCMTBN,
                 ZSTAFFCD   = C_ZSTAFFCD,
                 BANKCODE01 = C_BANKCODE01,
                 BANKCODE02 = C_BANKCODE02,
                 BANKCODE03 = C_BANKCODE03,
                 BANKCODE04 = C_BANKCODE04,
                 BANKCODE05 = C_BANKCODE05,
                 PRODCTCATG = C_PRODCTCATG,
                 AGCLSD     = obj_agency.AGCLSD,
                 ZCONSIDT   = obj_agency.ZCONSIDT,
                 BLKLIMIT   = o_defaultvalues('BLKLIMIT'),
                 PROVSTAT   = o_defaultvalues('PROVSTAT'),
                 DCONSIGNEN = obj_agency.DCONSIGNEN,
                 AUTHBY     = C_AUTHBY,
                 CPYNAME    = obj_agency.CPYNAME,
                 ZAGREGNO   = obj_agency.ZAGREGNO,
                 ZTRGTFLG   = obj_agency.ZTRGTFLG,
                 AUTHDATE   = o_defaultvalues('AUTHDATE'),
                 AUTHDATEG  = 99999999,
                 DTECRT     = v_busdate,
                 COUNT      = obj_agency.COUNT,
                 CRTUSER    = i_usrprf,
                 ZSKPAUTOC  = o_defaultvalues('ZSKPAUTOC'),
                 ZREPSTNM   = obj_agency.ZREPSTNM,
                 USRPRF     = i_usrprf,
                 JOBNM      = i_scheduleName,
                 DATIME     = LOCALTIMESTAMP,
                 Crlimit    = o_defaultvalues('CRLIMIT'),
                 ridesc     = obj_agency.RIDESC,
                 credittrm  = o_defaultvalues('CREDTERM'),
                 CONTPERS   = C_CONTPERS,
                 TAKOAGNT   = C_TAKOAGNT,
                 ARCON      = C_ARCON,
                 STREQ      = C_STREQ,
                 CRTERM     = C_CRTERM,
                 STLBASIS   = C_STLBASIS,
                 EXPNOT     = C_EXPNOT,
                 LICENCE    = C_LICENCE,
                 RLRPFX     = C_RLRPFX,
                 RLRCOY     = C_RLRCOY,
                 RLRACC     = C_RLRACC,
                 MSAGNT     = C_MSAGNT,
                 REPORTTO   = C_REPORTTO,
                 zdragnt    = obj_agency.zdragnt

           where trim(agntnum) = trim(obj_agency.zarefnum);

          -----Update in AGNTPF:END--------------------

          ----- Update in  IG Jd1dta.AGPLPF table:Start----------------

          update Jd1dta.AGPLPF tab
             set AGNTPFX    = o_defaultvalues('AGNTPFX'),
                 STLBASIS   = o_defaultvalues('STLBASIS'),
                 LICNEXDT   = o_defaultvalues('LICNEXDT'),
                 LOB        = o_defaultvalues('LOB'),
                 VALIDFLAG  = o_defaultvalues('VALIDFLAG'),
                 AGSTDATE   = o_defaultvalues('AGSTDATE'),
                 ENDDATE    = o_defaultvalues('ENDDATE'),
                 STRTDATE   = o_defaultvalues('STRTDATE'),
                 APRVDATE   = null,
                 AGNTCOY    = i_company,
                 AGNTNUM    = obj_agency.ZAREFNUM,
                 ARCON      = v_arcon,
                 CRLIMIT    = o_defaultvalues('CRLIMIT'),
                 CREDTERM   = o_defaultvalues('CREDTERM'),
                 EXPNOT     = C_EXPNOT,
                 LICENCE    = C_LICENCE,
                 RIDESC     = obj_agency.RIDESC,
                 STREQ      = v_statementreqd,
                 SRDATE     = obj_agency.SRDATE,
                 DATEEND    = obj_agency.DATEEND,
                 GSTREG     = C_GSTREG,
                 AGNTSTATUS = C_AGNTSTATUS,
                 TMPCRLMT   = o_defaultvalues('TMPCRLMT'),
                 VATFLG     = C_VATFLG,
                 VMAXCOM    = C_VMAXCOM,
                 Z6SLFINV   = C_Z6SLFINV,
                 USRPRF     = i_usrprf,
                 JOBNM      = i_scheduleName,
                 DATIME     = LOCALTIMESTAMP,
                 RLRPFX     = C_RLRPFX,
                 RLRCOY     = C_RLRCOY,
                 RLRACC     = C_RLRACC,
                 ZSTMTOSIND = C_ZSTMTOSIND,
                 ZTOFLG     = C_ZTOFLG,
                 ACCSRC     = C_ACCSRC,
                 AGTLICNO   = C_AGTLICNO

           where trim(agntnum) = trim(obj_agency.zarefnum);

          -- Update in  IG Jd1dta.AGPLPF table end-
          -- Update in  IG Jd1dta.ZACRPF table start-

          update Jd1dta.zacrpf
             set AGNTPFX = o_defaultvalues('AGNTPFX'),
                 VALIDFLAG = o_defaultvalues('VALIDFLAG'),
                 AGNTCOY   = i_company,
                 GAGNTSEL  = obj_agency.ZAREFNUM,
                 EFFDATE   = obj_agency.SRDATE,
                 ZINSTYP01 = obj_agency.ZINSTYP01,
                 ZINSTYP02 = obj_agency.ZINSTYP02,
                 ZINSTYP03 = obj_agency.ZINSTYP03,
                 ZINSTYP04 = obj_agency.ZINSTYP04,
                 ZINSTYP05 = obj_agency.ZINSTYP05,
                 ZINSTYP06 = obj_agency.ZINSTYP06,
                 ZINSTYP07 = obj_agency.ZINSTYP07,
                 ZINSTYP08 = obj_agency.ZINSTYP08,
                 ZINSTYP09 = obj_agency.ZINSTYP09,
                 ZINSTYP10 = obj_agency.ZINSTYP10,
                 CMRATE01  = obj_agency.CMRATE01,
                 CMRATE02  = obj_agency.CMRATE02,
                 CMRATE03  = obj_agency.CMRATE03,
                 CMRATE04  = obj_agency.CMRATE04,
                 CMRATE05  = obj_agency.CMRATE05,
                 CMRATE06  = obj_agency.CMRATE06,
                 CMRATE07  = obj_agency.CMRATE07,
                 CMRATE08  = obj_agency.CMRATE08,
                 CMRATE09  = obj_agency.CMRATE09,
                 CMRATE10  = obj_agency.CMRATE10,
                 USRPRF    = i_usrprf,
                 JOBNM     = i_scheduleName,
                 DATIME    = LOCALTIMESTAMP

           where trim(GAGNTSEL) = trim(obj_agency.zarefnum);

          -- --Update in  IG Jd1dta.ZACRPF table END-------
        END if;
        ------------CASE2 ,ISPAAGENT:END-----------------------

        ------------Case3,ISSHIAGENT:START-----------------------
        IF (isSHIAgent = 'Y') THEN

          update Jd1dta.AGNTPF
             set zdragnt = obj_agency.zdragnt,
             USRPRF     = i_usrprf,
                 JOBNM      = i_scheduleName,
                 DATIME     = LOCALTIMESTAMP
           where trim(AGNTNUM) = trim(obj_agency.zarefnum);

            obj_VIEW_DM_ZDROPF.RECSTATUS := 'OK';
          obj_VIEW_DM_ZDROPF.PREFIX    := 'AG';
          obj_VIEW_DM_ZDROPF.ZENTITY   := obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.ZIGVALUE  := 'CASE3_'|| obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
          obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
          Insert into View_Dm_PAZdropf values obj_VIEW_DM_ZDROPF;
        END if;
        ------------Case3,ISSHIAGENT:END-----------------------



        ------------Case4,IS SHI and PA Agent :START-----------------------

        IF (isAddedAgent = 'Y') THEN
          -----insert into PAZDROPF----

          obj_VIEW_DM_ZDROPF.RECSTATUS := 'OK';
          obj_VIEW_DM_ZDROPF.PREFIX    := 'AG';
          obj_VIEW_DM_ZDROPF.ZENTITY   := obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.ZIGVALUE  := 'CASE4_'||obj_agency.ZAREFNUM;
          obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
          obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
          Insert into View_Dm_PAZdropf values obj_VIEW_DM_ZDROPF;
          -----Update in AGNTPF:START--------------------

          -- Update in  IG Jd1dta.ZACRPF table start-

          update Jd1dta.zacrpf
             set ZINSTYP02 = obj_agency.ZINSTYP02,
                 ZINSTYP03 = obj_agency.ZINSTYP03,
                 ZINSTYP04 = obj_agency.ZINSTYP04,
                 ZINSTYP05 = obj_agency.ZINSTYP05,
                 ZINSTYP06 = obj_agency.ZINSTYP06,
                 ZINSTYP07 = obj_agency.ZINSTYP07,
                 ZINSTYP08 = obj_agency.ZINSTYP08,
                 ZINSTYP09 = obj_agency.ZINSTYP09,
                 ZINSTYP10 = obj_agency.ZINSTYP10,
                 CMRATE02  = obj_agency.CMRATE02,
                 CMRATE03  = obj_agency.CMRATE03,
                 CMRATE04  = obj_agency.CMRATE04,
                 CMRATE05  = obj_agency.CMRATE05,
                 CMRATE06  = obj_agency.CMRATE06,
                 CMRATE07  = obj_agency.CMRATE07,
                 CMRATE08  = obj_agency.CMRATE08,
                 CMRATE09  = obj_agency.CMRATE09,
                 CMRATE10  = obj_agency.CMRATE10,
                 USRPRF    = i_usrprf,
                 JOBNM     = i_scheduleName,
                 DATIME    = LOCALTIMESTAMP

           where trim(GAGNTSEL) = trim(obj_agency.zarefnum);

          ----Update in  IG Jd1dta.ZACRPF table END-------
          ------------Case4,IS SHI and PA Agent :END-----------------------

        END if;
      END IF;
    END LOOP;
    CLOSE AGENCY_cursor;

    dbms_output.put_line('Procedure execution time = ' ||
                         (dbms_utility.get_time - v_timestart) / 100);

    dbms_output.put_line('End execution of BQ9S5_AG01_AGENCY, SC NO:  ' ||
                         i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  exception
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9S5_AG01_AGENCY : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      insert into Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      values
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      commit;
      raise;
  END BQ9S5_AG01_AGENCY;

/