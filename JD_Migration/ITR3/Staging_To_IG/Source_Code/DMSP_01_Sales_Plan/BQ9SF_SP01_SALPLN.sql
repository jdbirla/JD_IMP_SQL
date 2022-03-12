create or replace PROCEDURE                        "BQ9SF_SP01_SALPLN" (
    v_scheduleName   IN VARCHAR2,
    v_scheduleNumber IN VARCHAR2,
    v_zprvaldYN      IN VARCHAR2,
    v_company        IN VARCHAR2,
    v_userProfile    IN VARCHAR2,
    v_i_branch       IN VARCHAR2,
    v_i_transCode    IN VARCHAR2,
    v_vrcmTermid     IN VARCHAR2 )
AS
  /***************************************************************************************************
  * Amenment History: SP02 Sales Plan
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       SP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  0628     BPS         SP2   ZCSLPF should not be created for C-CODE.
  *****************************************************************************************************/
  v_timestart NUMBER := dbms_utility.get_time;
  --------------Common Function Start---------
  -- o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist pkg_dm_common_operations.itemschec;
  o_errortext pkg_dm_common_operations.errordesc;
  i_zdoe_info pkg_dm_common_operations.obj_zdoe;
  ---------------Common function end-----------
  ------IG table obj start---
  v_zsalplan1 ZSLPPF.ZSALPLAN%TYPE;
  v_zinstype ZSLPPF.ZINSTYPE%TYPE;
  v_prodtyp ZSLPPF.PRODTYP%TYPE;
  v_sumins ZSLPPF.SUMINS%TYPE;
  /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
  v_zcovrid ZSLPPF.ZCOVRID%TYPE;
  v_zimbrplo ZSLPPF.ZIMBRPLO%TYPE;
  /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
  v_zsalplan2 ZCSLPF.ZSALPLAN%TYPE;
  v_zcmpcode ZCSLPF.ZCMPCODE%TYPE;
  v_zccodind ZCPNPF.ZCCODIND%TYPE;
  ------IG table obj END---
  b_isNoError   BOOLEAN := TRUE;
  b_isNoError2  BOOLEAN := TRUE;
  n_isValid     NUMBER(1) DEFAULT 0;
  isDuplicate   NUMBER(1) DEFAULT 0;
  v_code        NUMBER;
  v_errm        VARCHAR2(64 CHAR);
  v_errorCount  NUMBER(1) DEFAULT 0;
  v_errorCount2 NUMBER(1) DEFAULT 0;
  v_zsalplan    VARCHAR2(30 CHAR);
  -- v_tablecnt      NUMBER(1) := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  temp_zsalplan   VARCHAR2(60 CHAR);
  n_zcampcode     NUMBER(3) DEFAULT 0;
  ------Define Constant to read
  c_prefix CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('SLPL', v_company); --SP
  C_BQ9SF  CONSTANT VARCHAR2(5) := 'BQ9SF';
  C_T9797  CONSTANT VARCHAR2(6) := 'T9797';
  C_TQ9B6  CONSTANT VARCHAR2(6) := 'TQ9B6';
  C_Z040   CONSTANT VARCHAR2(4) := 'RQMK';
  C_Z039   CONSTANT VARCHAR2(4) := 'RQMJ';
  C_Z098   CONSTANT VARCHAR2(4) := 'RQO6';
  C_Z041   CONSTANT VARCHAR2(4) := 'RQML';
  C_Z021   CONSTANT VARCHAR2(4) := 'RQV4';
  C_Z014   CONSTANT VARCHAR2(4) := 'RQLU';
  C_Z038   CONSTANT VARCHAR2(4) := 'RQMI';
  /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
  C_Z091 CONSTANT VARCHAR2(4) := 'RQNZ'; --PRODTYP is mandatory.
  C_Z151 CONSTANT VARCHAR2(4) := 'RQZ9'; --Insurance Type is mandatory. --?
  C_Z152 CONSTANT VARCHAR2(4) := 'RQZA'; --Coverage/Rider is mandatory. --?
  C_Z153 CONSTANT VARCHAR2(4) := 'RQZB'; --Individual/Member Indicator is mandatory. --?
  C_Z154 CONSTANT VARCHAR2(4) := 'RQZC'; --Must be C or R only. --?
  C_Z155 CONSTANT VARCHAR2(4) := 'RQZD'; --Must be I or P only. --?
  /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
  --C_DTSM   CONSTANT VARCHAR2(4) := 'DTSM';
  ------IG table obj start---
  obj_zcslpf ZCSLPF%rowtype;
  obj_zslppf ZSLPPF%rowtype;
  ------IG table obj End---
  CURSOR salesPlan_cursor
  IS
    SELECT * FROM TITDMGSALEPLN1@DMSTAGEDBLINK;
  obj_salesPlan salesPlan_cursor%rowtype;
  CURSOR salesPlan_cursor2
  IS
    SELECT * FROM TITDMGSALEPLN2@DMSTAGEDBLINK;
  obj_salesPlan2 salesPlan_cursor2%rowtype;
  --error cont start
  t_index PLS_INTEGER;
type ercode_tab
IS
  TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
type errorfield_tab
IS
  TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
type errormsg_tab
IS
  TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
type errorfieldvalue_tab
IS
  TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
type i_errorprogram_tab
IS
  TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
  t_errorprogram i_errorprogram_tab;
  --error cont end
BEGIN
  ---------Common Function------------
  -- pkg_dm_common_operations.getdefaultvalues(i_itemname => C_BQ9SF, i_company => v_company, o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMSP', itemexist => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMSP', o_errortext => o_errortext);
  v_tableNametemp := 'ZDOE' || TRIM(c_prefix) || LPAD(TRIM(v_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  /*SELECT COUNT(*)
  INTO v_tablecnt
  FROM user_tables
  WHERE TRIM(TABLE_NAME) = v_tableName;*/
  OPEN salesPlan_cursor;
  <<skipRecord>>
  LOOP
    FETCH salesPlan_cursor INTO obj_salesPlan;
    EXIT
  WHEN salesPlan_cursor%notfound;
    v_zsalplan1 :=obj_salesPlan.zsalplan;
    v_zinstype  :=obj_salesPlan.zinstype;
    v_prodtyp   :=obj_salesPlan.prodtyp;
    v_sumins    :=obj_salesPlan.sumins;
    /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
    v_zcovrid  :=obj_salesPlan.zcovrid;
    v_zimbrplo :=obj_salesPlan.zimbrplo;
    /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
    --  v_tablecnt  := 1;
    /*t_index     := 0; */
    t_ercode(1)   := ' ';
    t_ercode(2)   := ' ';
    t_ercode(3)   := ' ';
    t_ercode(4)   := ' ';
    t_ercode(5)   := ' ';
    i_zdoe_info   :=NULL;
    isDuplicate   := 0;
    temp_zsalplan :=' ';
    temp_zsalplan :=(v_zsalplan1 || '$' || v_zinstype || '$' || v_prodtyp);
    -- i_zdoe_info.i_tablecnt         := v_tablecnt;
    i_zdoe_info.i_zfilename  := 'TITDMGSALEPLN1';
    i_zdoe_info.i_prefix     := c_prefix;
    i_zdoe_info.i_scheduleno := v_scheduleNumber;
    i_zdoe_info.i_tableName  := v_tableName;
    i_zdoe_info.i_refKey     := TRIM(v_zsalplan1)|| TRIM(v_prodtyp) ; ---?
    v_errorCount             :=0;
    b_isNoError              :=TRUE;
    --validation Start
    -- IF v_zprvaldYN         ='Y' THEN
    IF TRIM(v_zsalplan1)           IS NULL THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_Z040;
      i_zdoe_info.i_errormsg01     := o_errortext(C_Z040);
      i_zdoe_info.i_errorfield01   := 'zsalplan1';
      i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan1);
      i_zdoe_info.i_errorprogram01 := v_scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;
    ELSE
      SELECT COUNT(*)
      INTO isDuplicate
      FROM Jd1dta.PAZDROPF
      WHERE ZENTITY                   = temp_zsalplan
      AND PREFIX                      = c_prefix;
      IF isDuplicate                  > 0 THEN
        b_isNoError                  := FALSE;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z098;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
        i_zdoe_info.i_errorfield01   := 'zsalplan1';
        i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan1);
        i_zdoe_info.i_errorprogram01 := v_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      END IF;
    END IF;
    SELECT COUNT(*)
    INTO isDuplicate
    FROM Jd1dta.ZSLPPF
    WHERE ZSALPLAN                  = v_zsalplan1
    AND ZINSTYPE                    = v_zinstype
    AND PRODTYP                     = v_prodtyp;
    IF isDuplicate                  > 0 THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_Z098;
      i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
      i_zdoe_info.i_errorfield01   := 'zsalplan1';
      i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan1);
      i_zdoe_info.i_errorprogram01 := v_scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;
    END IF;
    IF TRIM(v_sumins)               IS NULL THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z039;
      t_errorfield(v_errorCount)    := 'sumins';
      t_errormsg(v_errorCount)      := o_errortext(C_Z039);
      t_errorfieldval(v_errorCount) := TRIM(v_sumins);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
    IF TRIM(v_prodtyp)              IS NULL THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z091;
      t_errorfield(v_errorCount)    := 'PRODTYP';
      t_errormsg(v_errorCount)      := o_errortext(C_Z091);
      t_errorfieldval(v_errorCount) := TRIM(v_prodtyp);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
    IF NOT (itemexist.exists(TRIM(C_T9797) || TRIM(v_prodtyp)||1)) THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z014;
      t_errorfield(v_errorCount)    := 'prodtyp';
      t_errormsg(v_errorCount)      := o_errortext(C_Z014);
      t_errorfieldval(v_errorCount) := TRIM(v_prodtyp);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
    IF TRIM(v_zinstype)             IS NULL THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z151;
      t_errorfield(v_errorCount)    := 'ZINSTYP';
      t_errormsg(v_errorCount)      := o_errortext(C_Z151);
      t_errorfieldval(v_errorCount) := TRIM(v_zinstype);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
    IF NOT (itemexist.exists(TRIM(C_TQ9B6) || TRIM(v_zinstype)||1)) THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z038;
      t_errorfield(v_errorCount)    := 'zinstype';
      t_errormsg(v_errorCount)      := o_errortext(C_Z038);
      t_errorfieldval(v_errorCount) := TRIM(v_zinstype);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
    IF TRIM(v_zcovrid)              IS NULL THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z152;
      t_errorfield(v_errorCount)    := 'zcovrid';
      t_errormsg(v_errorCount)      := o_errortext(C_Z152);
      t_errorfieldval(v_errorCount) := TRIM(v_zcovrid);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF TRIM(v_zcovrid)              <> 'C' AND TRIM(v_zcovrid) <> 'R' THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z154;
      t_errorfield(v_errorCount)    := 'zcovrid';
      t_errormsg(v_errorCount)      := o_errortext(C_Z154);
      t_errorfieldval(v_errorCount) := TRIM(v_zcovrid);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF TRIM(v_zimbrplo)             IS NULL THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z153;
      t_errorfield(v_errorCount)    := 'zimbrplo';
      t_errormsg(v_errorCount)      := o_errortext(C_Z153);
      t_errorfieldval(v_errorCount) := TRIM(v_zimbrplo);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF TRIM(v_zimbrplo)             <> 'I' AND TRIM(v_zimbrplo) <> 'P' THEN
      b_isNoError                   := FALSE;
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z155;
      t_errorfield(v_errorCount)    := 'zcovrid';
      t_errormsg(v_errorCount)      := o_errortext(C_Z155);
      t_errorfieldval(v_errorCount) := TRIM(v_zimbrplo);
      t_errorprogram (v_errorCount) := v_scheduleName;
      IF v_errorCount               >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
    --validation End
    -- END IF; -- for  zprvaldYN
    <<insertzdoe>>
    IF (b_isNoError                   = FALSE) THEN
      IF TRIM(t_ercode(1))           IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := t_ercode(1);
        i_zdoe_info.i_errormsg01     := t_errormsg(1);
        i_zdoe_info.i_errorfield01   := t_errorfield(1);
        i_zdoe_info.i_fieldvalue01   := t_errorfieldval(1);
        i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
      END IF;
      IF TRIM(t_ercode(2))           IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error02        := t_ercode(2);
        i_zdoe_info.i_errormsg02     := t_errormsg(2);
        i_zdoe_info.i_errorfield02   := t_errorfield(2);
        i_zdoe_info.i_fieldvalue02   := t_errorfieldval(2);
        i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
      END IF;
      IF TRIM(t_ercode(3))           IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error03        := t_ercode(3);
        i_zdoe_info.i_errormsg03     := t_errormsg(3);
        i_zdoe_info.i_errorfield03   := t_errorfield(3);
        i_zdoe_info.i_fieldvalue03   := t_errorfieldval(3);
        i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
      END IF;
      IF TRIM(t_ercode(4))           IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error04        := t_ercode(4);
        i_zdoe_info.i_errormsg04     := t_errormsg(4);
        i_zdoe_info.i_errorfield04   := t_errorfield(4);
        i_zdoe_info.i_fieldvalue04   := t_errorfieldval(4);
        i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
      END IF;
      IF TRIM(t_ercode(5))           IS NOT NULL THEN
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
    IF (b_isNoError        = TRUE) THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;
    -- Updateing IG- Tables And Migration Registry table with filter data
    -- Updating S indicator
    IF b_isNoError = TRUE AND v_zprvaldYN = 'N' THEN
      -- insert in  IG Jd1dta.PAZDROPF table Start-
      INSERT
      INTO Jd1dta.PAZDROPF
        (
          RECSTATUS,
          PREFIX,
          ZENTITY,
          ZIGVALUE,
          JOBNUM,
          JOBNAME
        )
        VALUES
        (
          'NEW',
          c_prefix,
          temp_zsalplan,
          temp_zsalplan,
          v_scheduleNumber,
          v_scheduleName
        );
      -- insert in  IG Jd1dta.PAZDROPF table End-
      -- insert in  IG Jd1dta.ZSLPPF table Start-
      obj_zslppf.ZSALPLAN:=v_zsalplan1;
      obj_zslppf.ZINSTYPE:=v_zinstype;
      obj_zslppf.PRODTYP :=v_prodtyp;
      obj_zslppf.SUMINS  :=v_sumins;
      obj_zslppf.USRPRF  :=v_userProfile;
      obj_zslppf.JOBNM   :=v_scheduleName;
      obj_zslppf.DATIME  :=sysdate;
      /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
      obj_zslppf.ZCOVRID  :=v_zcovrid;
      obj_zslppf.ZIMBRPLO :=v_zimbrplo;
      /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
      INSERT
      INTO ZSLPPF VALUES obj_zslppf;
      -- insert in  IG Jd1dta.ZSLPPF table End-
      /* INSERT
      INTO Jd1dta.ZSLPPF
      (
      ZSALPLAN,
      ZINSTYPE,
      PRODTYP,
      SUMINS,
      JOBNM,
      USRPRF,
      DATIME
      )
      VALUES
      (
      v_zsalplan1,
      v_zinstype,
      v_prodtyp,
      v_sumins,
      v_scheduleName,
      v_userProfile,
      sysdate
      );*/
    END IF;
  END LOOP;
  CLOSE salesPlan_cursor;
  -- 2nd loop
  OPEN salesPlan_cursor2;
  <<skipRecord2>>
  LOOP
    FETCH salesPlan_cursor2 INTO obj_salesPlan2;
    EXIT
  WHEN salesPlan_cursor2%notfound;
    v_zsalplan2 :=obj_salesPlan2.zsalplan;
    v_zcmpcode  :=obj_salesPlan2.zcmpcode;
    --   v_tablecnt  := 1;
    /*t_index     := 0; */
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info :=NULL;
    isDuplicate := 0;
    -- i_zdoe_info.i_tablecnt         := v_tablecnt;
    i_zdoe_info.i_zfilename  := 'TITDMGSALEPLN2';
    i_zdoe_info.i_prefix     := c_prefix;
    i_zdoe_info.i_scheduleno := v_scheduleNumber;
    i_zdoe_info.i_tableName  := v_tableName;
    i_zdoe_info.i_refKey     := TRIM(v_zsalplan2) ||TRIM(v_zcmpcode) ; ---?
    v_errorCount2            :=0;
    b_isNoError2             := TRUE;
    n_zcampcode              :=0;
    --validation Start
    --  IF v_zprvaldYN         ='Y' THEN
    IF TRIM(v_zcmpcode)              IS NULL THEN
      b_isNoError2                   := FALSE;
      v_errorCount2                  := v_errorCount2 + 1;
      t_ercode(v_errorCount2)        := C_Z041;
      t_errorfield(v_errorCount2)    := 'zcmpcode';
      t_errormsg(v_errorCount2)      := o_errortext(C_Z041);
      t_errorfieldval(v_errorCount2) := TRIM(v_zcmpcode);
      t_errorprogram (v_errorCount2) := v_scheduleName;
      IF v_errorCount2               >= 5 THEN
        GOTO insertzdoe2;
      END IF;
    ELSE
      --      SELECT COUNT(ZCMPCODE)
      --      INTO n_zcampcode
      --      FROM ZCPNPF
      --      WHERE TRIM(ZCMPCODE)            = TRIM(obj_salesPlan2.zcmpcode);
      SELECT ZCCODIND,
        COUNT(ZCMPCODE) over ()
      INTO v_zccodind,
        n_zcampcode
      FROM ZCPNPF
      WHERE TRIM(ZCMPCODE)            = TRIM(obj_salesPlan2.zcmpcode);
      IF n_zcampcode                  = 0 THEN
        b_isNoError2                 := FALSE;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := 'RQM1';
        i_zdoe_info.i_errormsg01     := o_errortext('RQM1');
        i_zdoe_info.i_errorfield01   := 'ZCMPCODE';
        i_zdoe_info.i_fieldvalue01   := TRIM(obj_salesPlan2.zcmpcode);
        i_zdoe_info.i_errorprogram01 := v_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord2;
        --  END IF;
      END IF;
      -- SP2 Start
      IF v_zccodind                     = 'Y' THEN
        b_isNoError2                   := FALSE;
        v_errorCount2                  := v_errorCount2 + 1;
        t_ercode(v_errorCount2)        :='RRD7';
        t_errorfield(v_errorCount2)    := 'zcmpcode';
        t_errormsg(v_errorCount2)      := o_errortext('RRD7');
        t_errorfieldval(v_errorCount2) := TRIM(obj_salesPlan2.zcmpcode);
        t_errorprogram (v_errorCount2) := v_scheduleName;
        IF v_errorCount2               >= 5 THEN
          GOTO insertzdoe2;
        END IF;
        END IF;
        -- SP2  END
      END IF;
      IF TRIM(v_zsalplan2)           IS NULL THEN
        b_isNoError2                 := FALSE;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z040;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z040);
        i_zdoe_info.i_errorfield01   := 'zsalplan2';
        i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan2);
        i_zdoe_info.i_errorprogram01 := v_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord2;
      ELSE
        SELECT COUNT(*)
        INTO isDuplicate
        FROM Jd1dta.ZCSLPF
        WHERE ZSALPLAN                  = v_zsalplan2
        AND ZCMPCODE                    = v_zcmpcode;
        IF isDuplicate                  > 0 THEN
          b_isNoError2                 := FALSE;
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error01        := C_Z098;
          i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
          i_zdoe_info.i_errorfield01   := 'zsalplan2';
          i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan2);
          i_zdoe_info.i_errorprogram01 := v_scheduleName;
          pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
          CONTINUE skipRecord2;
        END IF;
      END IF;
      /*  IF TRIM(v_zcmpcode)              IS NULL THEN
      b_isNoError2                   := FALSE;
      v_errorCount2                  := v_errorCount2 + 1;
      t_ercode(v_errorCount2)        := C_Z041;
      t_errorfield(v_errorCount2)    := 'zcmpcode';
      t_errormsg(v_errorCount2)      := o_errortext(C_Z041);
      t_errorfieldval(v_errorCount2) := TRIM(v_zcmpcode);
      t_errorprogram (v_errorCount2) := v_scheduleName;
      IF v_errorCount2               >= 5 THEN
      GOTO insertzdoe2;
      END IF;
      ELSE
      SELECT COUNT(*)
      INTO isDuplicate
      FROM Jd1dta.ZCPNPF
      WHERE ZCMPCODE                    = v_zcmpcode;
      IF isDuplicate                    < 0 THEN
      b_isNoError2                   := FALSE;
      v_errorCount2                  := v_errorCount2 + 1;
      t_ercode(v_errorCount2)        := C_Z021;
      t_errorfield(v_errorCount2)    := 'zcmpcode';
      t_errormsg(v_errorCount2)      := o_errortext(C_Z021);
      t_errorfieldval(v_errorCount2) := TRIM(v_zcmpcode);
      t_errorprogram (v_errorCount2) := v_scheduleName;
      IF v_errorCount2               >= 5 THEN
      GOTO insertzdoe2;
      END IF;
      END IF;
      END IF;*/
      --validation End
      -- END IF; -- for  zprvaldYN
      <<insertzdoe2>>
      IF (b_isNoError2                  = FALSE) THEN
        IF TRIM(t_ercode(1))           IS NOT NULL THEN
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error01        := t_ercode(1);
          i_zdoe_info.i_errormsg01     := t_errormsg(1);
          i_zdoe_info.i_errorfield01   := t_errorfield(1);
          i_zdoe_info.i_fieldvalue01   := t_errorfieldval(1);
          i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
        END IF;
        IF TRIM(t_ercode(2))           IS NOT NULL THEN
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error02        := t_ercode(2);
          i_zdoe_info.i_errormsg02     := t_errormsg(2);
          i_zdoe_info.i_errorfield02   := t_errorfield(2);
          i_zdoe_info.i_fieldvalue02   := t_errorfieldval(2);
          i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
        END IF;
        IF TRIM(t_ercode(3))           IS NOT NULL THEN
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error03        := t_ercode(3);
          i_zdoe_info.i_errormsg03     := t_errormsg(3);
          i_zdoe_info.i_errorfield03   := t_errorfield(3);
          i_zdoe_info.i_fieldvalue03   := t_errorfieldval(3);
          i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
        END IF;
        IF TRIM(t_ercode(4))           IS NOT NULL THEN
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error04        := t_ercode(4);
          i_zdoe_info.i_errormsg04     := t_errormsg(4);
          i_zdoe_info.i_errorfield04   := t_errorfield(4);
          i_zdoe_info.i_fieldvalue04   := t_errorfieldval(4);
          i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
        END IF;
        IF TRIM(t_ercode(5))           IS NOT NULL THEN
          i_zdoe_info.i_indic          := 'E';
          i_zdoe_info.i_error05        := t_ercode(5);
          i_zdoe_info.i_errormsg05     := t_errormsg(5);
          i_zdoe_info.i_errorfield05   := t_errorfield(5);
          i_zdoe_info.i_fieldvalue05   := t_errorfieldval(5);
          i_zdoe_info.i_errorprogram05 := t_errorprogram(5);
        END IF;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord2;
      END IF;
      IF (b_isNoError2       = TRUE) THEN
        i_zdoe_info.i_indic := 'S';
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      END IF;
      -- Updateing IG- Tables And Migration Registry table with filter data
      -- Updating S indicator
      IF b_isNoError2 = TRUE AND v_zprvaldYN = 'N' THEN
        /*
        -- insert in  IG Jd1dta.ZCSLPF table Start-
        obj_zcslpf.ZSALPLAN:=v_zsalplan2;
        obj_zcslpf.ZCMPCODE:=v_zcmpcode;
        obj_zcslpf.USRPRF  :=v_scheduleName;
        obj_zcslpf.JOBNM   :=v_userProfile;
        obj_zcslpf.DATIME  :=sysdate;
        INSERT INTO ZCSLPF VALUES obj_zcslpf;
        -- insert in  IG Jd1dta.ZCSLPF table End-
        */
        INSERT
        INTO Jd1dta.ZCSLPF
          (
            ZSALPLAN,
            ZCMPCODE,
            JOBNM,
            USRPRF,
            DATIME
          )
          VALUES
          (
            v_zsalplan2,
            v_zcmpcode,
            v_scheduleName,
            v_userProfile,
            sysdate
          );
      END IF;
    END LOOP;
    CLOSE salesPlan_cursor2;
    NULL;
    /*EXCEPTION
    WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    dbms_output.put_line('Exception occurs while program execution, ' || 'SQL Code:' || v_code || ', Error Description:' || v_errm);*/
    dbms_output.put_line('Procedure execution time = ' || (dbms_utility.get_time - v_timestart) / 100);
  END BQ9SF_SP01_SALPLN;