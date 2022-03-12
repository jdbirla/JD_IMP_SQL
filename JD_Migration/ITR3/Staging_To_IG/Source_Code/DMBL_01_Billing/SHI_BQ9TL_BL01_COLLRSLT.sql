create or replace PROCEDURE                               "BQ9TL_BL01_COLLRSLT" (i_scheduleName   IN VARCHAR2, 
                                                i_scheduleNumber IN VARCHAR2, 
                                                i_zprvaldYN      IN VARCHAR2, 
                                                i_company        IN VARCHAR2, 
                                                i_usrprf         IN VARCHAR2, 
                                                i_branch         IN VARCHAR2, 
                                                i_transCode      IN VARCHAR2, 
                                                i_vrcmTermid     IN VARCHAR2) AS 
/*************************************************************************************************** 
  * Amenment History: BL01 Collection Results 
  * Date    Initials   Tag   Decription 
  * -----   --------   ---   --------------------------------------------------------------------------- 
  * MMMDD    XXX       CR1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
  * 2804     JB        CR2   Checking for Bill Not migrated 

  *****************************************************************************************************/ 
  ----------------------------VARIABLES DECLARATION START------------------------------------------------------------- 

  v_timestart     number := dbms_utility.get_time; --Timecheck 
  v_chdrnum       TITDMGCOLRES.CHDRNUM@DMSTAGEDBLINK%type; 
  v_trrefnum      TITDMGCOLRES.TRREFNUM@DMSTAGEDBLINK%type; 
  v_tfrdate       TITDMGCOLRES.TFRDATE@DMSTAGEDBLINK%type; 
  v_dshcde        TITDMGCOLRES.DSHCDE@DMSTAGEDBLINK%type; 
  v_errorCount    NUMBER(1) DEFAULT 0; 
  v_isAnyError    VARCHAR2(1) DEFAULT 'N'; 
  v_ispolicyexist NUMBER(1) DEFAULT 0; 
  v_isDuplicate   NUMBER(1) DEFAULT 0;
  v_seq           NUMBER(15) DEFAULT 0;
  v_zigvalue      ZDRBPF.ZIGVALUE%type; 
  v_refKey        VARCHAR2(100) DEFAULT NULL; 

  v_zendcde gchppf.zendcde%type; 

--  TYPE obj_billno IS RECORD( 
--       t_zentity  ZDRBPF.ZENTITY%type, 
--       t_chdrnum  ZDRBPF.CHDRNUM%type, 
--       t_zigvalue ZDRBPF.ZIGVALUE%type); 
--  TYPE t_billno IS TABLE OF obj_billno index by BINARY_INTEGER; 
--       billnolist t_billno; 
  ----------------------------VARIABLES DECLARATION END---------------------------------------------------------------- 

  --------------------------------CONSTANTS---------------------------------------------------------------------------- 
  C_PREFIX constant varchar2(2) := GET_MIGRATION_PREFIX('CLRS', i_company); 
  v_chdrpfx VARCHAR2(20 CHAR); 
  -----------------------------ERROR CONSTANTS------------------------------------------------------------------------- 
  C_ERRORCOUNT constant number := 5; 
  C_Z113       constant varchar2(4) := 'RQOJ'; /*Missing REFNUM */ 
  C_Z031       constant varchar2(4) := 'RQMB'; /*Policy is not yet migrated*/ 
  C_Z114       constant varchar2(4) := 'RQOK'; /*Must be valid in TQ9JT */ 
  C_RQZE       constant varchar2(4) := 'RQZE'; /*Invalid dishonor code */ 
  C_Z115       constant varchar2(4) := 'RQOL'; /*Collection Results has already migrated*/ 
  C_BQ9TL      constant varchar2(5) := 'BQ9TL'; 

  --------------------------COMMON FUNCTION START----------------------------------------------------------------------- 
  -- v_tablecnt      NUMBER(1) := 0; 
  v_tableNametemp VARCHAR2(10); 
  v_tableName     VARCHAR2(10); 
  itemexist       pkg_dm_common_operations.itemschec; 
  o_errortext     pkg_dm_common_operations.errordesc; 
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe; 
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap; 
  getgchppf       pkg_common_dmbl.gchptype; 
  -- obj_gchp        GCHPPF%rowtype; 
  obj_gchp  pkg_common_dmbl.OBJ_GCHP; 
  getZdcrpf       pkg_common_dmbl.duplicateZdcrpf; 
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER; 
  t_ercode ercode_tab; 
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER; 
  t_errorfield errorfield_tab; 
  type errormsg_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  t_errormsg errormsg_tab; 
  type errorfieldvalue_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  t_errorfieldval errorfieldvalue_tab; 
  type errorprogram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER; 
  t_errorprogram errorprogram_tab; 
  checkchdrnum     pkg_common_dmbl.gchdtype; 
  --------------------------COMMON FUNCTION END------------------------------------------------------------------------- 

--  CURSOR cur_billing_collection_res IS 
--    SELECT * FROM TITDMGCOLRES@DMSTAGEDBLINK; 
--  obj_billing cur_billing_collection_res%rowtype; 

        CURSOR cur_billing_collection_res IS 
                SELECT A.*, B.ZIGVALUE AS ZIGVALUE  FROM TITDMGCOLRES@DMSTAGEDBLINK A 
                left outer join Jd1dta.ZDRBPF B on TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM) 
                AND TRIM(A.TRREFNUM)=TRIM(B.ZENTITY) 
                order by A.chdrnum asc, A.trrefnum asc; 
    obj_billing cur_billing_collection_res%rowtype; 


BEGIN 

  --------------------------COMMON FUNCTION CALLING START----------------------------------------------------------------------- 


											
											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9TL,
                                     o_defaultvalues => o_defaultvalues);

  pkg_dm_common_operations.checkitemexist(i_module_name => 'BQ9TL', 
                                          itemexist     => itemexist); 

  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMBL', 
                                        o_errortext   => o_errortext); 
  pkg_common_dmbl.getgchppf(getgchppf => getgchppf); 

  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || 
                     LPAD(TRIM(i_scheduleNumber), 4, '0'); 
  v_tableName     := TRIM(v_tableNametemp); 
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName); 

  pkg_common_dmbl.getZdcrpf(getZdcrpf => getZdcrpf); 
  pkg_common_dmbl.checkpolicy(i_company    => i_company, 
                              checkchdrnum => checkchdrnum); 

--  SELECT ZENTITY, CHDRNUM, ZIGVALUE 
--      BULK COLLECT 
--      into billnolist 
--      from Jd1dta.ZDRBPF;                         
  --------------------------COMMON FUNCTION CALLING END----------------------------------------------------------------------- 
  ------------------FETCH ALL DEFAULT VALUES FROM TABLE TQ9Q9, ITEM BQ9TL----------------------------------------------------- 
  v_chdrpfx := o_defaultvalues('CHDRPFX'); 
  -----------------------------OPEN CURSOR------------------------------------------------------------------------------------ 
  OPEN cur_billing_collection_res; 
  <<skipRecord>> 

  LOOP 
    FETCH cur_billing_collection_res 
      INTO obj_billing; 
    EXIT WHEN cur_billing_collection_res%notfound; 
    ---------------------------INITIALIZATION START---------------------------------------------------------------------------- 
    v_chdrnum  := TRIM(obj_billing.chdrnum); 
    v_trrefnum := TRIM(obj_billing.trrefnum); 
    v_tfrdate  := TRIM(obj_billing.tfrdate); 
    v_dshcde   := TRIM(obj_billing.dshcde); 
    v_refKey   := v_chdrnum || '-' || v_trrefnum || '-' || TRIM(v_tfrdate); 

    i_zdoe_info              := Null; 
    i_zdoe_info.i_zfilename  := 'TITDMGCOLRES'; 
    i_zdoe_info.i_prefix     := C_PREFIX; 
    i_zdoe_info.i_scheduleno := i_scheduleNumber; 
    i_zdoe_info.i_refKey     := v_refKey; 
    i_zdoe_info.i_tableName  := v_tableName; 
    --    i_zdoe_info.i_tablecnt := v_tablecnt; 
    --    v_tablecnt := 1; 
    v_isAnyError := 'N'; 
    v_errorCount := 0; 
    t_ercode(1) := null; 
    t_ercode(2) := null; 
    t_ercode(3) := null; 
    t_ercode(4) := null; 
    t_ercode(5) := null; 
    ---------------------------INITIALIZATION END---------------------------------------------------------------------------- 
    -----------------------------DUPLICATE RECORD VALIDATION--------------------------------------------------------------------- 
--    select count(RECIDXCOLRES) 
--      into v_isDuplicate 
--      FROM Jd1dta.ZDCRPF 
--     WHERE RTRIM(ZENTITY) = TRIM(v_refKey); 
-- 
--    IF v_isDuplicate > 0 THEN 
    select SEQTMP.nextval into v_seq from dual;
    IF (getZdcrpf.exists(TRIM(v_refKey))) THEN 
      v_isAnyError                 := 'Y'; 
      i_zdoe_info.i_indic          := 'E'; 
      i_zdoe_info.i_error01        := C_Z115; 
      i_zdoe_info.i_errormsg01     := o_errortext(C_Z115); 
      i_zdoe_info.i_errorfield01   := 'ZENTITY'; 
      i_zdoe_info.i_fieldvalue01   := v_chdrnum; 
      i_zdoe_info.i_errorprogram01 := i_scheduleName; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info); 
      CONTINUE skipRecord; 

    END IF; 
   -----------------CR2:Bil not migrated------------ 
 IF (TRIM(obj_billing.zigvalue) IS NULL) THEN 
      v_isAnyError                 := 'Y'; 
      i_zdoe_info.i_indic          := 'E'; 
      i_zdoe_info.i_error01        := 'BLNM'; 
      i_zdoe_info.i_errormsg01     := 'Bill Not migrated'; 
      i_zdoe_info.i_errorprogram01 := i_scheduleName; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info); 
      CONTINUE skipRecord; 

    END IF; 
    --------------CR2:Bil not migrated--------------- 
    ----------------------------REFNUM VALIDATION---------------------------------------------------------------------------- 
    IF v_trrefnum IS NULL THEN 
      v_isAnyError := 'Y'; 
      v_errorCount := v_errorCount + 1; 
      t_ercode(v_errorCount) := C_Z113; 
      t_errorfield(v_errorCount) := 'TRREFNUM'; 
      t_errormsg(v_errorCount) := o_errortext(C_Z113); 
      t_errorfieldval(v_errorCount) := v_trrefnum; 
      t_errorprogram(v_errorCount) := i_scheduleName; 
      IF v_errorCount >= C_ERRORCOUNT THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    ----------------------------CHDRNUM VALIDATION---------------------------------------------------------------------------- 
    -- mps Apr 25 Start -- 
    IF NOT (checkchdrnum.exists(TRIM(v_chdrnum))) THEN 
      v_isAnyError := 'Y'; 
      v_errorCount := v_errorCount + 1; 
      t_ercode(v_errorCount) := C_Z031; 
      t_errorfield(v_errorCount) := 'CHDRNUM'; 
      t_errormsg(v_errorCount) := o_errortext(C_Z031); 
      t_errorfieldval(v_errorCount) := v_chdrnum; 
      t_errorprogram(v_errorCount) := i_scheduleName; 
      GOTO insertzdoe; 
    END IF; 

    /*   
    select count(*) 
      into v_ispolicyexist 
      from GCHD 
     where TRIM(CHDRPFX) = TRIM(v_chdrpfx) 
       AND TRIM(CHDRCOY) = TRIM(i_company) 
       AND TRIM(CHDRNUM) = TRIM(v_chdrnum); 

    IF (v_ispolicyexist < 1) THEN 
      v_isAnyError := 'Y'; 
      v_errorCount := v_errorCount + 1; 
      t_ercode(v_errorCount) := C_Z031; 
      t_errorfield(v_errorCount) := 'CHDRNUM'; 
      t_errormsg(v_errorCount) := o_errortext(C_Z031); 
      t_errorfieldval(v_errorCount) := v_chdrnum; 
      t_errorprogram(v_errorCount) := i_scheduleName; 
      IF v_errorCount >= C_ERRORCOUNT THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 
    */-- mps Apr 25 Start -- 
    -----------------------------RESULT CODE DSHCDE VALIDATION----------------------------------------------------------------- 
    IF (getgchppf.exists(v_chdrnum || TRIM(i_company))) THEN 
      obj_gchp  := getgchppf(v_chdrnum || TRIM(i_company)); 
      v_zendcde := obj_gchp.zendcde; 

      IF (TRIM(v_zendcde) IS NOT NUll) THEN 
        ---Checking in endorser list 
        IF (TRIM(v_zendcde) IN ('SURUGA2', 'EBANK2', 'RESONA_B')) THEN 
          ---Checkin in Debit card 
          IF NOT 
              (TRIM(v_dshcde) IN 
              ('00', '01', '02', '03', '04', '08', '09', '0D', '0F', '0G')) THEN 
            v_isAnyError := 'Y'; 
            v_errorCount := v_errorCount + 1; 
            t_ercode(v_errorCount) := C_RQZE; 
            t_errorfield(v_errorCount) := 'DSHCDE'; 
            t_errormsg(v_errorCount) := o_errortext(C_RQZE); 
            t_errorfieldval(v_errorCount) := v_dshcde; 
            t_errorprogram(v_errorCount) := i_scheduleName; 
            IF v_errorCount >= C_ERRORCOUNT THEN 
              GOTO insertzdoe; 
            END IF; 
          END IF; 
        ELSE 
          ---Check in Non debit card 
          IF NOT 
              (TRIM(v_dshcde) IN 
              ('00', '01', '02', '03', '04', '07', '08', '09', '0A', '0E')) THEN 
            v_isAnyError := 'Y'; 
            v_errorCount := v_errorCount + 1; 
            t_ercode(v_errorCount) := C_RQZE; 
            t_errorfield(v_errorCount) := 'DSHCDE'; 
            t_errormsg(v_errorCount) := o_errortext(C_RQZE); 
            t_errorfieldval(v_errorCount) := v_dshcde; 
            t_errorprogram(v_errorCount) := i_scheduleName; 
            IF v_errorCount >= C_ERRORCOUNT THEN 
              GOTO insertzdoe; 
            END IF; 
          END IF; 

        END IF; 
      ELSE 
        v_isAnyError := 'Y'; 
        v_errorCount := v_errorCount + 1; 
        t_ercode(v_errorCount) := C_RQZE; 
        t_errorfield(v_errorCount) := 'DSHCDE'; 
        t_errormsg(v_errorCount) := o_errortext(C_RQZE); 
        t_errorfieldval(v_errorCount) := v_dshcde; 
        t_errorprogram(v_errorCount) := i_scheduleName; 
        IF v_errorCount >= C_ERRORCOUNT THEN 
          GOTO insertzdoe; 
        END IF; 
      END IF; 

    END IF; 
    /*  IF NOT (itemexist.exists(TRIM('TQ9JT') || TRIM(v_dshcde) || i_company)) THEN 
      v_isAnyError := 'Y'; 
      v_errorCount := v_errorCount + 1; 
      t_ercode(v_errorCount) := C_Z114; 
      t_errorfield(v_errorCount) := 'DSHCDE'; 
      t_errormsg(v_errorCount) := o_errortext(C_Z114); 
      t_errorfieldval(v_errorCount) := v_dshcde; 
      t_errorprogram(v_errorCount) := i_scheduleName; 
      IF v_errorCount >= C_ERRORCOUNT THEN 
        GOTO insertzdoe; 
      END IF; 

    END IF;*/ 

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF-------------------------------------------------------- 
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
    IF (v_isAnyError = 'N') THEN 
      i_zdoe_info.i_indic := 'S'; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info); 
    END IF; 

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF--------------------------------------------------------- 
    ----------------------------INSERT ZDCRPF REGISTRY TABLE----------------------------------------------------------------------- 
    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN 
    -- mps Apr 25 START -- 
    /* 
      SELECT ZIGVALUE 
        into v_zigvalue 
        FROM ZDRBPF 
       WHERE RTRIM(ZENTITY) = v_trrefnum 
         AND RTRIM(CHDRNUM) = v_chdrnum; 
     */ 
--      For idx_billno IN billnolist.first .. billnolist.last 
--          LOOP 
--              IF TRIM(v_trrefnum) = billnolist(idx_billno).t_zentity 
--              AND TRIM(v_chdrnum) = billnolist(idx_billno).t_chdrnum THEN 
--                 v_zigvalue := billnolist(idx_billno).t_zigvalue; 
--              END IF; 
--      END LOOP; 
      -- mps Apr 25 END -- 

      INSERT INTO Jd1dta.ZDCRPF 
        (ZENTITY, ZIGVALUE, JOBNUM, JOBNAME) 
      VALUES 
        (v_refKey, v_zigvalue, i_scheduleNumber, i_scheduleName); 

      ------------------------------INSERT ZCRHPF IG TABLE-------------------------------------------------------------------------- 
      --  v_dshcde01 := SUBSTR(v_dshcde, 5); 
      INSERT INTO Jd1dta.ZCRHPF 
        (CHDRCOY, CHDRPFX, CHDRNUM, BILLNO, TFRDATE, DSHCDE, LNBILLNO,USRPRF,JOBNM,DATIME) 
      VALUES 
        (i_company, v_chdrpfx, v_chdrnum, obj_billing.ZIGVALUE, v_tfrdate, v_dshcde,obj_billing.ZIGVALUE,i_usrprf,i_scheduleName,CAST(sysdate AS TIMESTAMP)); 

    END IF; 
  END LOOP; 
  CLOSE cur_billing_collection_res; 
  dbms_output.put_line('Procedure execution time = ' || 
                       (dbms_utility.get_time - v_timestart) / 100); 
END BQ9TL_BL01_COLLRSLT;