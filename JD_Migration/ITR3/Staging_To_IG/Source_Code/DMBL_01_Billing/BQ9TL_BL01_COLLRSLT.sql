create or replace PROCEDURE BQ9TL_BL01_COLLRSLT (i_scheduleName   IN VARCHAR2, 
                                                i_scheduleNumber IN VARCHAR2,
                                                i_zprvaldYN      IN VARCHAR2,
                                                i_company        IN VARCHAR2,
                                                i_usrprf         IN VARCHAR2,
                                                i_branch         IN VARCHAR2,
                                                i_transCode      IN VARCHAR2,
                                                i_vrcmTermid     IN VARCHAR2,
                                                i_array_size     IN PLS_INTEGER DEFAULT 1000,
                                                start_id         IN NUMBER,
                                                end_id           IN NUMBER)
                            AUTHID current_user AS 
                /*************************************************************************************************** 
                            * Amendment History: BL01 Collection Results 
                            * Date    Initials   Tag   Description 
                            * -----   --------   ---   --------------------------------------------------------------------------- 
                            * DEC24    CHO             PA ITR3 Implementation
                            * JAN31    CHO       CR1   Bug - added this declaration
                            * FEB01    CHO       CR2   Put table join in CURSOR instead of using pkg_common_dmbl for validation performance
							* AUG18    MKS       CR3   ZJNPG-9931 LNBILLNO is having null for unsuccessful collection due to TRFDATE missing in GBIHPF.
              *****************************************************************************************************/ 
                            ----------------------------VARIABLES DECLARATION START------------------------------------------------------------- 
                            v_timestart     number := dbms_utility.get_time; --Timecheck 
                            v_chdrnum       DMIGTITDMGCOLRES.CHDRNUM%type; 
                            v_trrefnum      DMIGTITDMGCOLRES.TRREFNUM%type; 
                            v_prbilfdt      DMIGTITDMGCOLRES.PRBILFDT%type; 
                            v_tfrdate       DMIGTITDMGCOLRES.TFRDATE%type; 
                            v_dshcde        DMIGTITDMGCOLRES.DSHCDE%type;
                            v_isDateValid       VARCHAR2(20 CHAR);
                            v_errorCount    NUMBER(1) DEFAULT 0; 
                            v_isAnyError    VARCHAR2(1) DEFAULT 'N'; 
                            v_ispolicyexist NUMBER(1) DEFAULT 0; 
                            v_isDuplicate   NUMBER(1) DEFAULT 0;
                            v_seq           NUMBER(15) DEFAULT 0;
                            v_zigvalue      PAZDRBPF.ZIGVALUE%type; 
                            v_refKey        VARCHAR2(100) DEFAULT NULL;
                            v_zuclpfAction  NUMBER(1) DEFAULT 1;
                            v_isZuclpfexstA NUMBER(1) DEFAULT 0;
                            v_isZuclpfexstB NUMBER(1) DEFAULT 0;
                            v_lnbillno                        ZCRHPF.LNBILLNO%type;
                            v_zendcde       gchppf.zendcde%type;
                            p_exitcode      NUMBER;
                            p_exittext      VARCHAR2(200);
                            v_pkvalzuclpf     ZUCLPF.UNIQUE_NUMBER%type;
                            v_zcolm                            ZENDRPF.ZCOLM%type;
                            ----------------------------VARIABLES DECLARATION END---------------------------------------------------------------- 

                            --------------------------------CONSTANTS---------------------------------------------------------------------------- 
                            C_PREFIX         constant varchar2(2) := GET_MIGRATION_PREFIX('CLRS', i_company); 
                            v_chdrpfx           VARCHAR2(20 CHAR); 
                            C_limit   PLS_INTEGER := i_array_size;

                            -----------------------------ERROR CONSTANTS------------------------------------------------------------------------- 
                            C_ERRORCOUNT constant number := 5;
                            C_Z013       constant VARCHAR2(4) := 'RQLT'; /* Invalid Date*/
                            C_Z113       constant varchar2(4) := 'RQOJ'; /*Missing REFNUM */ 
                            C_Z031       constant varchar2(4) := 'RQMB'; /*Policy is not yet migrated*/ 
                            C_Z114       constant varchar2(4) := 'RQOK'; /*Must be valid in TQ9JT */
                            C_RQZE       constant varchar2(4) := 'F771'; /*Invalid dishonor code */ -- NOTE: We will use F771 to aviod duplicate Error message in ERORPF table.
                            C_Z115       constant varchar2(4) := 'RQOL'; /*Collection Results has already migrated*/ 
                            C_BQ9TL      constant varchar2(5) := 'BQ9TL'; 

                            ----------------------------------IG TABLE OBJECT---------------------------------------------------------------------
                            obj_zuclpf                        Jd1dta.ZUCLPF%rowtype;
                            obj_pazdcrpf      Jd1dta.VIEW_DM_PAZDCRPF%rowtype;
                            obj_zcrhpf                        Jd1dta.VIEW_DM_ZCRHPF%rowtype;                 

                            --------------------------COMMON FUNCTION START-----------------------------------------------------------------------  
                            v_tableNametemp VARCHAR2(10); 
                            v_tableName     VARCHAR2(10); 
                            itemexist       pkg_dm_common_operations.itemschec; 
                            o_errortext     pkg_dm_common_operations.errordesc; 
                            i_zdoe_info     pkg_dm_common_operations.obj_zdoe; 
                            o_defaultvalues pkg_dm_common_operations.defaultvaluesmap; 
--                            getgchppf       pkg_common_dmbl.gchptype;
--                            obj_gchp        pkg_common_dmbl.OBJ_GCHP;
                            obj_zendrpf     pkg_common_dmbl.OBJ_ZENDRPF;
--                         getPgpdate                         pkg_common_dmbl.prbilfdttype;                          
--                         obj_gbihpf                          pkg_common_dmbl.OBJ_GBIHPF;
                            --getPazdcrpf     pkg_common_dmbl.duplicatePazdcrpf; --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
                            getendrtype                      pkg_common_dmbl.zendrpftype;
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
--                            checkchdrnum     pkg_common_dmbl.gchdtype; 
                            --------------------------COMMON FUNCTION END------------------------------------------------------------------------- 

                            -- Define a Cursor to read StageDB TITDMGCOLRES
                            CURSOR cur_billing_collection_res IS 
                              SELECT A.*, 
                              B.ZIGVALUE AS ZIGVALUE,
                              (SELECT MAX(C.BILLNO) FROM Jd1dta.GBIHPF C WHERE TRIM(C.CHDRNUM) = TRIM(A.CHDRNUM) AND A.TFRDATE = C.ZBKTRFDT) AS LNBILLNO,
                              C.CHDRNUM AS GCHPPF,
                              TRIM(C.ZENDCDE) AS ZENDCDE,
                              D.CHDRNUM AS GCHD
                              FROM Jd1dta.DMIGTITDMGCOLRES A 
                              LEFT OUTER JOIN Jd1dta.PAZDRBPF B 
                              ON TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM) 
                              AND TRIM(A.TRREFNUM) = TRIM(B.ZENTITY) 
                              AND A.PRBILFDT = B.PRBILFDT
                              LEFT OUTER JOIN Jd1dta.GCHPPF C
                              ON TRIM(A.CHDRNUM) = TRIM(C.CHDRNUM) 
                              AND TRIM(C.CHDRCOY) = TRIM(I_COMPANY)
                              LEFT OUTER JOIN Jd1dta.GCHD D
                              ON TRIM(A.CHDRNUM) = TRIM(D.CHDRNUM)
                              WHERE A.CHUNKSNUM BETWEEN START_ID AND END_ID
                              ORDER BY A.CHDRNUM ASC, A.TFRDATE ASC, A.PRBILFDT ASC; 
                            obj_billing cur_billing_collection_res%rowtype; 
                            TYPE t_collres_list IS TABLE OF cur_billing_collection_res%rowtype;
                            collres_list t_collres_list;

BEGIN 
  dbms_output.put_line('Start Execution of BQ9TL_BL01_COLLRSLT, SC NO:  ' ||
                         i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  --------------------------COMMON FUNCTION CALLING START----------------------------------------------------------------------- 

  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9TL,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'BQ9TL', 
                                          itemexist     => itemexist); 
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMBL', 
                                        o_errortext   => o_errortext);                                                                                                   
--  pkg_common_dmbl.getgchppf(getgchppf => getgchppf);
  pkg_common_dmbl.getendrtype(getendrtype => getendrtype); -- CR1
--  pkg_common_dmbl.getPgpdate(getPgpdate => getPgpdate);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || 
                     LPAD(TRIM(i_scheduleNumber), 4, '0');                                                 
  v_tableName     := TRIM(v_tableNametemp); 

-- NOTE: Uncomment for manual execution
--pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);

--pkg_common_dmbl.getPAZdcrpf(getPAZdcrpf => getPAZdcrpf);  --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
--  pkg_common_dmbl.checkpolicy(i_company    => i_company, 
--                              checkchdrnum => checkchdrnum); 
  --------------------------COMMON FUNCTION CALLING END----------------------------------------------------------------------- 
  ------------------FETCH ALL DEFAULT VALUES FROM TABLE TQ9Q9, ITEM BQ9TL----------------------------------------------------- 
  v_chdrpfx := o_defaultvalues('CHDRPFX'); 
  -----------------------------OPEN CURSOR------------------------------------------------------------------------------------ 
  OPEN cur_billing_collection_res; 
  LOOP
  FETCH cur_billing_collection_res BULK COLLECT INTO collres_list LIMIT C_limit;

  <<skipRecord>> 
  FOR i IN 1 .. collres_list.COUNT LOOP

    obj_billing := collres_list(i);

    ---------------------------INITIALIZATION START---------------------------------------------------------------------------- 
    v_chdrnum  := TRIM(obj_billing.chdrnum); 
    v_trrefnum := TRIM(obj_billing.trrefnum); 
    v_prbilfdt := TRIM(obj_billing.prbilfdt); 
    v_tfrdate  := TRIM(obj_billing.tfrdate); 
    v_dshcde   := obj_billing.dshcde;
    v_zigvalue := TRIM(obj_billing.zigvalue);
    v_lnbillno := TRIM(obj_billing.lnbillno);
    v_refKey   := v_chdrnum || '-' || v_trrefnum || '-' || v_prbilfdt || '-' || TRIM(v_tfrdate); 
    i_zdoe_info              := Null; 
    i_zdoe_info.i_zfilename  := 'TITDMGCOLRES'; 
    i_zdoe_info.i_prefix     := C_PREFIX; 
    i_zdoe_info.i_scheduleno := i_scheduleNumber; 
    i_zdoe_info.i_refKey     := v_refKey; 
    i_zdoe_info.i_tableName  := v_tableName; 
    v_isAnyError := 'N'; 
    v_errorCount := 0; 
    t_ercode(1) := null; 
    t_ercode(2) := null; 
    t_ercode(3) := null; 
    t_ercode(4) := null; 
    t_ercode(5) := null; 
    ---------------------------INITIALIZATION END--------------------------------------------------------------------------------

    -----------------------------DUPLICATE RECORD VALIDATION--------------------------------------------------------------------- 
--  IF (getPAZdcrpf.exists(TRIM(v_refKey))) THEN  --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
    IF TRIM(obj_billing.PAZ_REC) IS NOT NULL THEN --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
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

   -----------------Bil not migrated------------ 
              IF (TRIM(obj_billing.zigvalue) IS NULL) THEN 
      v_isAnyError                 := 'Y'; 
      i_zdoe_info.i_indic          := 'E'; 
      i_zdoe_info.i_error01        := 'BLNM'; 
      i_zdoe_info.i_errormsg01     := 'Bill Not migrated'; 
      i_zdoe_info.i_errorprogram01 := i_scheduleName; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info); 
      CONTINUE skipRecord; 

    END IF; 
    --------------Bil not migrated--------------- 

              ----------------------------PRBILFDT VALIDATION---------------------------------------------------------------------------- 
    v_isDateValid := VALIDATE_DATE(v_prbilfdt);
    IF v_isDateValid <> 'OK' THEN
      v_isAnyError                  := 'Y';
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z013;
      t_errorfield(v_errorCount)    := 'PRBILFDT';
      t_errormsg(v_errorCount)      := o_errortext(C_Z013);
      t_errorfieldval(v_errorCount) := v_prbilfdt;
      t_errorprogram(v_errorCount)  := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

              ----------------------------TFRDATE VALIDATION---------------------------------------------------------------------------- 
    v_isDateValid := VALIDATE_DATE(v_tfrdate);
    IF v_isDateValid <> 'OK' THEN
      v_isAnyError                  := 'Y';
      v_errorCount                  := v_errorCount + 1;
      t_ercode(v_errorCount)        := C_Z013;
      t_errorfield(v_errorCount)    := 'TFRDATE';
      t_errormsg(v_errorCount)      := o_errortext(C_Z013);
      t_errorfieldval(v_errorCount) := v_tfrdate;
      t_errorprogram(v_errorCount)  := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ----------------------------REFNUM VALIDATION---------------------------------------------------------------------------- 
    IF v_trrefnum IS NULL OR v_trrefnum = ' ' THEN
      v_isAnyError                  := 'Y'; 
      v_errorCount                  := v_errorCount + 1; 
      t_ercode(v_errorCount)        := C_Z113; 
      t_errorfield(v_errorCount)    := 'TRREFNUM'; 
      t_errormsg(v_errorCount)      := o_errortext(C_Z113); 
      t_errorfieldval(v_errorCount) := v_trrefnum; 
      t_errorprogram(v_errorCount)  := i_scheduleName; 
      IF v_errorCount >= C_ERRORCOUNT THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF; 

    ----------------------------CHDRNUM VALIDATION---------------------------------------------------------------------------- 
--    IF NOT (checkchdrnum.exists(TRIM(v_chdrnum))) THEN - CR2
    IF OBJ_BILLING.GCHD IS NULL THEN
      v_isAnyError                  := 'Y'; 
      v_errorCount                  := v_errorCount + 1; 
      t_ercode(v_errorCount)        := C_Z031; 
      t_errorfield(v_errorCount)    := 'CHDRNUM'; 
      t_errormsg(v_errorCount)      := o_errortext(C_Z031); 
      t_errorfieldval(v_errorCount) := v_chdrnum; 
      t_errorprogram(v_errorCount)  := i_scheduleName; 
      GOTO insertzdoe; 
    END IF; 

    -----------------------------RESULT CODE DSHCDE VALIDATION----------------------------------------------------------------- 
--    IF (getgchppf.exists(v_chdrnum || TRIM(i_company))) THEN - CR2
    IF OBJ_BILLING.GCHPPF IS NOT NULL THEN
--      obj_gchp  := getgchppf(v_chdrnum || TRIM(i_company)); 
--      v_zendcde := obj_gchp.zendcde; 

--      IF (getendrtype.exists(TRIM(v_zendcde))) THEN 
      IF (getendrtype.exists(OBJ_BILLING.ZENDCDE)) THEN 
        ---Checking in endorser list
--        obj_zendrpf := getendrtype(TRIM(v_zendcde));
        obj_zendrpf := getendrtype(OBJ_BILLING.ZENDCDE);
        v_zcolm := obj_zendrpf.ZCOLM;

--        IF (TRIM(v_zcolm) = 'DB') AND (TRIM(v_zendcde) <> 'SURUGA2') THEN 
        IF (TRIM(v_zcolm) = 'DB') AND (OBJ_BILLING.ZENDCDE <> 'SURUGA2') THEN 
          ---Checkin in Debit card and Non Suruga2
          IF NOT 
            (v_dshcde IN
            ('00', '0H', '09', '0D', '0F', '0G', '0E')) THEN 
            v_isAnyError                  := 'Y'; 
            v_errorCount                  := v_errorCount + 1; 
            t_ercode(v_errorCount)        := C_RQZE; 
            t_errorfield(v_errorCount)    := 'DSHCDE1'; 
            t_errormsg(v_errorCount)      := o_errortext(C_RQZE); 
            t_errorfieldval(v_errorCount) := v_dshcde; 
            t_errorprogram(v_errorCount)  := i_scheduleName; 
            IF v_errorCount >= C_ERRORCOUNT THEN 
              GOTO insertzdoe; 
            END IF; 
          END IF; 
        ELSE 
        ---Check in Non debit card 
          IF NOT 
            (v_dshcde IN 
            ('00', '01', '02', '03', '04', '07', '08', '09', '0A', '0E', '0D', '0F', '0G')) THEN 
            v_isAnyError                  := 'Y'; 
            v_errorCount                  := v_errorCount + 1; 
            t_ercode(v_errorCount)        := C_RQZE; 
            t_errorfield(v_errorCount)    := 'DSHCDE2'; 
            t_errormsg(v_errorCount)      := o_errortext(C_RQZE); 
            t_errorfieldval(v_errorCount) := v_dshcde; 
            t_errorprogram(v_errorCount)  := i_scheduleName; 
            IF v_errorCount >= C_ERRORCOUNT THEN 
              GOTO insertzdoe; 
            END IF; 
          END IF; 
        END IF; 
      END IF; 
    ELSE 
                            v_isAnyError                    := 'Y'; 
                            v_errorCount                    := v_errorCount + 1; 
                            t_ercode(v_errorCount)          := C_RQZE; 
                            t_errorfield(v_errorCount)      := 'DSHCDE'; 
                            t_errormsg(v_errorCount)        := o_errortext(C_RQZE); 
                            t_errorfieldval(v_errorCount)   := v_dshcde; 
                            t_errorprogram(v_errorCount)    := i_scheduleName; 
                            IF v_errorCount >= C_ERRORCOUNT THEN 
                                          GOTO insertzdoe; 
                            END IF;     
    END IF; 

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
    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF-----------------------------------------------------------

    ----------------------------INSERT PAZDCRPF REGISTRY TABLE-----------------------------------------------------------------------
    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN 

                            obj_pazdcrpf.ZENTITY   := v_refKey;
                            obj_pazdcrpf.ZIGVALUE               := v_zigvalue;
                            obj_pazdcrpf.JOBNUM   := i_scheduleNumber;
                            obj_pazdcrpf.JOBNAME := i_scheduleName;

                            INSERT INTO Jd1dta.VIEW_DM_PAZDCRPF VALUES obj_pazdcrpf;


                            ------------------------------INSERT IN ZCRHP IG TABLE START------------------------------------------------------------ 
                            -- Insert into ZCRHP IG Table
                            obj_zcrhpf.CHDRCOY  := i_company;
                            obj_zcrhpf.CHDRPFX      := v_chdrpfx;
                            obj_zcrhpf.CHDRNUM    := v_chdrnum;
                            obj_zcrhpf.BILLNO   := v_zigvalue;
                            obj_zcrhpf.TFRDATE       := v_tfrdate;
                            obj_zcrhpf.DSHCDE   := v_dshcde;
                            obj_zcrhpf.USRPRF   := i_usrprf;
                            obj_zcrhpf.JOBNM    := i_scheduleName;
                            obj_zcrhpf.DATIME   := CAST(sysdate AS TIMESTAMP);

                            IF v_dshcde = '00' THEN
                                          obj_zcrhpf.LNBILLNO := v_zigvalue;
                            ELSE
                                          obj_zcrhpf.LNBILLNO := v_lnbillno;
                            END IF;
							
							--START: CR3 - If LNBILLNO cannot be find due to TFRDATE is not exist in GBIHPF set  lnbillno=billno --
							IF (v_lnbillno IS NULL) AND ((TRIM(v_dshcde) <> '00') AND (TRIM(v_dshcde) IS NOT NULL)) THEN
								obj_zcrhpf.LNBILLNO := v_zigvalue;
							END IF;
							--END: CR3 - LNBILLNO fix --


                            INSERT INTO Jd1dta.VIEW_DM_ZCRHPF VALUES obj_zcrhpf;
      ------------------------------INSERT IN ZCRHP IG TABLE END------------------------------------------------------------ 


      ------------------------------INSERT/UPDATE IN ZUCLPF IG TABLE START--------------------------------------------------
      -- Check if policy does not exist in ZUCLPF table with ZCOMBILL = 0.
      SELECT COUNT(*)  INTO v_isZuclpfexstA 
      FROM Jd1dta.ZUCLPF a WHERE a.CHDRNUM = v_chdrnum AND a.ZCOMBILL = 0
      AND EXISTS(                                                                 --Ticket #ZJNPG-9739: RUAT perf improvment - add dmig as filter                                                          
        SELECT 1 FROM Jd1dta.DMIGTITDMGCOLRES col WHERE col.chdrnum = a.chdrnum); --Ticket #ZJNPG-9739: RUAT perf improvment - add dmig as filter

      IF v_isZuclpfexstA = 0 THEN

        Begin
        -- Check if policy exist in ZUCLPF table with VALIDFLAG = 1.
        SELECT NVL(a.ZCOMBILL, 0) INTO v_isZuclpfexstB 
        FROM Jd1dta.ZUCLPF a WHERE a.CHDRNUM = v_chdrnum AND TRIM(a.VALIDFLAG) = '1' AND ZCOMBILL <> 0
        AND EXISTS(                                                                   --Ticket #ZJNPG-9739: RUAT perf improvment - add dmig as filter
            SELECT 1 FROM Jd1dta.DMIGTITDMGCOLRES col WHERE col.chdrnum = a.chdrnum); --Ticket #ZJNPG-9739: RUAT perf improvment - add dmig as filter

        exception when no_data_found then
        v_isZuclpfexstB := 0;
        end;

        -- Unsuccessful collection:
        IF v_dshcde <> '00' AND v_dshcde <> ' ' THEN
          -- Get PGP date
          --SELECT SEQ_ZUCLPF.nextval INTO v_pkvalzuclpf FROM dual;
          v_pkvalzuclpf := SEQ_ZUCLPF.nextval; --PerfImprov

          obj_zuclpf.UNIQUE_NUMBER               := v_pkvalzuclpf;
          obj_zuclpf.CHDRPFX                    := v_chdrpfx;
          obj_zuclpf.CHDRCOY                   := i_company;
          obj_zuclpf.CHDRNUM                  := v_chdrnum;
          obj_zuclpf.ZCHDRPFX                               := v_chdrpfx;
          obj_zuclpf.ZCHDRCOY                               := i_company;
          obj_zuclpf.ZCHDRNUM                              := null;
          obj_zuclpf.ZNOSHFT                    := 0;
          obj_zuclpf.USRPRF                                     := i_usrprf;
          obj_zuclpf.JOBNM                                      := i_scheduleName;
          obj_zuclpf.DATIME                                     := CAST(sysdate AS TIMESTAMP);
          obj_zuclpf.VALIDFLAG                                       := '1';
          obj_zuclpf.ZENDPGP                    := v_prbilfdt;
          obj_zuclpf.ZSTRTPGP                  := v_prbilfdt;

          -- First FAILURE of billing collection.(INSERT Action)
          IF v_isZuclpfexstB = 0 THEN
            --insert into Jd1dta.ZUCLPF (ZCOMBILL) is set as 1.
            obj_zuclpf.ZCOMBILL := 1;
            INSERT INTO Jd1dta.ZUCLPF VALUES obj_zuclpf;

          -- Second FAILURE billing collection. (UPDATE Action)
          ELSE
            --update Jd1dta.ZUCLPF (ZCOMBILL) is set as 2.
                                          IF v_isZuclpfexstB = 1 THEN
                                                        obj_zuclpf.ZCOMBILL := 2;
                                                        UPDATE Jd1dta.ZUCLPF
                                                        SET ZCOMBILL  = obj_zuclpf.ZCOMBILL,
                                                                      VALIDFLAG   = obj_zuclpf.VALIDFLAG,
                                                                      ZENDPGP     = obj_zuclpf.ZENDPGP,
                                                                      ZSTRTPGP    = obj_zuclpf.ZSTRTPGP,
                                                                      USRPRF      = obj_zuclpf.USRPRF,
                                                                      JOBNM       = obj_zuclpf.JOBNM,
                                                                      DATIME      = obj_zuclpf.DATIME                                                   
                                                        WHERE TRIM(CHDRNUM) = v_chdrnum
                                                        AND TRIM(VALIDFLAG) = '1';
                                          END IF;
          END IF;
        END IF;              

        --Successful collection:
        IF v_dshcde = '00' THEN
          -- Second SUCCESSFUL billing collection(UPDATE action).
          IF v_isZuclpfexstB > 0 THEN   
                    obj_zuclpf.VALIDFLAG  := '2';
            UPDATE Jd1dta.ZUCLPF
            SET VALIDFLAG     = obj_zuclpf.VALIDFLAG,
                USRPRF      = obj_zuclpf.USRPRF,
                JOBNM       = obj_zuclpf.JOBNM,
                DATIME      = obj_zuclpf.DATIME
            WHERE TRIM(CHDRNUM) = v_chdrnum
            AND TRIM(VALIDFLAG) = '1';                                                                   
          END IF;
        END IF; 
      END IF;
                ------------------------------INSERT/UPDATE IN ZUCLPF IG TABLE END--------------------------------------------------

    END IF;
    END loop;
    EXIT WHEN cur_billing_collection_res%notfound;
    COMMIT;
  END LOOP; 
  CLOSE cur_billing_collection_res;  

  dbms_output.put_line('Procedure execution time = ' || 
                       (dbms_utility.get_time - v_timestart) / 100); 

  dbms_output.put_line('End execution of BQ9TL_BL01_COLLRSLT, SC NO:  ' ||
                        i_scheduleNumber || ' Flag :' || i_zprvaldYN);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9TL_BL01_COLLRSLT : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      INSERT INTO Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      VALUES
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      COMMIT;
      raise;

END BQ9TL_BL01_COLLRSLT;