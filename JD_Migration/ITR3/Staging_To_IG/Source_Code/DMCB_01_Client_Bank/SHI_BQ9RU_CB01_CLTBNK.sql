create or replace PROCEDURE                               "BQ9RU_CB01_CLTBNK" (i_scheduleName   IN VARCHAR2,
                                              i_scheduleNumber IN VARCHAR2,
                                              i_zprvaldYN      IN VARCHAR2,
                                              i_company        IN VARCHAR2,
                                              i_usrprf         IN VARCHAR2,
                                              i_branch         IN VARCHAR2,
                                              i_transCode      IN VARCHAR2,
                                              vrcmTermid       IN VARCHAR2) AUTHID CURRENT_USER AS
  /***************************************************************************************************
  * Amenment History: CB01 Client Bank
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * MAY05    MPS       CB2   Create CLRRPF for role: CB
  * MAY08    MPS       CB3   Initialize variables
  * MAY10    RC        CB4   Data Verification Changes
  * MAY15    JDB       CB5   Insert Into Audit_CLRRPF
  *****************************************************************************************************/
  v_timestart          NUMBER := dbms_utility.get_time;
  v_bankacckeycrdtcard VARCHAR2(20 CHAR);
  v_newigvalue         VARCHAR2(50 CHAR);
  c_clntrel            CHAR(2 CHAR);
  v_refnum             VARCHAR2(100);
  v_bankkey            CLBAPF.BANKKEY%type;
  v_date               VARCHAR2(100);
  b_isNoError          BOOLEAN := TRUE;
  n_duplicate          NUMBER(3) DEFAULT 0;
  n_bankkeyExists      NUMBER(3) DEFAULT 0;
  v_refNo              VARCHAR2(15);
  v_migrationPrefix    VARCHAR2(2);
  v_unique_number      CLBAPF.UNIQUE_NUMBER%type; -- mps 4/13
  v_igvalue            VARCHAR2(50 CHAR);
  n_entity             NUMBER(1) DEFAULT 0;
  v_tableNametemp      VARCHAR2(10);
  v_tableName          VARCHAR2(10);
  v_errorCount         NUMBER(1) DEFAULT 0;
  v_seq                NUMBER(15) DEFAULT 0;
  n_currto             CLBAPF.CURRTO%type;
  n_mnthto             CLBAPF.MTHTO%type;
  n_yearto             CLBAPF.YEARTO%type;
  obj_clrrpf           CLRRPF%rowtype; -- CB2 --
  v_pkValueClrrpf      CLRRPF.UNIQUE_NUMBER%type; -- CB2 --
  C_CLRROLE_CB CONSTANT VARCHAR2(4) := 'CB'; -- CB2 --
  v_forenum        CLRRPF.FORENUM%type; -- CB2 --
  obj_audit_clrrpf AUDIT_CLRRPF%rowtype; --CB5
  -- Fetch the Migration Prefix value from TQ9Q8
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLCB', i_company);
  C_BQ9RU  CONSTANT VARCHAR2(5) := 'BQ9RU';
  temp_seq_val  NUMBER DEFAULT 0;
  
  --------------Common Function Start---------
  o_defaultvalues  pkg_dm_common_operations.defaultvaluesmap;
  itemexist        pkg_dm_common_operations.itemschec;
  o_errortext      pkg_dm_common_operations.errordesc;
  i_zdoe_info      pkg_dm_common_operations.obj_zdoe;
  i_zdoe_info_temp pkg_dm_common_operations.obj_zdoe;
  getbankkey       PKG_COMMON_DMCB.bankkey;
  checkclient      PKG_COMMON_DMCB.zdclpf_cp01;
  checkdupl        pkg_common_dmcb.cbduplicate;
  getzigvalue      pkg_common_dmcb.zigvaluetype;
  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  type errorprogram_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;

  type zdclpf_cp IS TABLE OF VARCHAR(8) INDEX BY BINARY_INTEGER;
  zdclpf_cp01 zdclpf_cp;

  ---------------Common function end-----------
  CURSOR c_bankcursor IS
    SELECT * FROM TITDMGCLNTBANK@DMSTAGEDBLINK;
  obj_bank c_bankcursor%rowtype;
BEGIN
  ---------Common Function Calling------------

											
											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9RU,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCB',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCB',
                                        o_errortext   => o_errortext);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  PKG_COMMON_DMCB.getbankkey(getbankkey => getbankkey);
  PKG_COMMON_DMCB.checkclient(checkclient => checkclient);
  pkg_common_dmcb.checkcbdup(checkdupl => checkdupl);
  pkg_common_dmcb.getzigvalue(getzigvalue => getzigvalue);
  --SELECT ZENTITY BULK COLLECT INTO zdclpf_cp01 FROM PAZDCLPF WHERE PREFIX = 'CP';
  ---------Common Function Calling------------
  
    -- Monitor the count of Processed records during batch runs
  EXECUTE IMMEDIATE ('DROP SEQUENCE Jd1dta.TEMP_DM_SEQ1');
  EXECUTE IMMEDIATE ('CREATE SEQUENCE Jd1dta.TEMP_DM_SEQ1 MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOPARTITION');
  -- Monitor the count of Processed records during batch run
  
  
  OPEN c_bankcursor;
  <<again_start>>
  LOOP
    FETCH c_bankcursor
      INTO obj_bank;
    EXIT WHEN c_bankcursor%notfound;
    i_zdoe_info := i_zdoe_info_temp;
    i_zdoe_info.i_zfilename := 'TITDMGCLNTBANK';
    i_zdoe_info.i_prefix := C_PREFIX;
    i_zdoe_info.i_scheduleno := i_scheduleNumber;
    i_zdoe_info.i_refKey := obj_bank.REFNUM;
    i_zdoe_info.i_tableName := v_tableName;
    v_bankkey := concat(obj_bank.BANKCD, '   ' || obj_bank.BRANCHCD);
    v_refNo := TRIM(obj_bank.REFNUM);
    b_isNoError := true;
    v_errorCount := 0;
    n_duplicate := 0;
    t_ercode(1) := NULL;
    t_ercode(2) := NULL;
    t_ercode(3) := NULL;
    t_ercode(4) := NULL;
    t_ercode(5) := NULL;
    n_entity := 0;
    n_bankkeyExists := 0;
    v_refnum := NULL; -- CB3
    c_clntrel := NULL; -- CB3
    v_bankacckeycrdtcard := NULL; -- CB3

    IF TRIM(obj_bank.BANKACCKEY) IS NULL THEN
      v_refnum             := TRIM(obj_bank.refnum) || '-' ||
                              TRIM(obj_bank.SEQNO) || '-' ||
                              TRIM(obj_bank.CRDTCARD);
      c_clntrel            := 'CC';
      v_bankacckeycrdtcard := TRIM(obj_bank.CRDTCARD);
    ELSE
      v_refnum             := TRIM(obj_bank.refnum) || '-' ||
                              TRIM(obj_bank.SEQNO) || '-' ||
                              TRIM(obj_bank.BANKACCKEY);
      c_clntrel            := 'CB';
      v_bankacckeycrdtcard := TRIM(obj_bank.BANKACCKEY);
    END IF;
    i_zdoe_info.i_refKey := v_refnum;

    -- Check For Client Migrated
    --    FOR i IN zdclpf_cp01.FIRST .. zdclpf_cp01.LAST
    --    LOOP
    --    IF TRIM(obj_bank.refnum) = zdclpf_cp01(i) THEN
    --    n_entity := 1;
    --    END IF;
    --    END LOOP;
    --IF n_entity                   = 0 THEN
    IF NOT (checkclient.exists(TRIM(obj_bank.refnum))) THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := 'RQLI';
      i_zdoe_info.i_errormsg01     := o_errortext('RQLI');
      i_zdoe_info.i_errorfield01   := 'REFNUM';
      i_zdoe_info.i_fieldvalue01   := obj_bank.refnum;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      GOTO insertzdoe;
    END IF;

    -- Duplicate Record Validation
    /* SELECT COUNT(ZENTITY)
      INTO n_duplicate
      FROM PAZDCLPF
     WHERE TRIM(ZENTITY) = v_refnum
       AND PREFIX = 'CB';
    IF n_duplicate = 1 THEN*/
    IF (checkdupl.exists(TRIM(v_refnum))) THEN
      b_isNoError                  := FALSE;
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := 'RQO6';
      i_zdoe_info.i_errormsg01     := o_errortext('RQO6');
      i_zdoe_info.i_errorfield01   := 'REFNUM';
      i_zdoe_info.i_fieldvalue01   := obj_bank.REFNUM;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      GOTO insertzdoe;
    END IF;

    -- Validate Account Number
    IF TRIM(obj_bank.BANKACCDSC) IS NULL THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'E186';
      t_errorfield(v_errorCount) := 'BANKACCDSC';
      t_errormsg(v_errorCount) := o_errortext('E186');
      t_errorfieldval(v_errorCount) := obj_bank.BANKACCDSC;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    -- Validation For BANKACCKEY and CRDTCARD
    IF TRIM(obj_bank.BANKACCKEY) IS NULL AND
       TRIM(obj_bank.CRDTCARD) IS NULL THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'RQOS';
      t_errorfield(v_errorCount) := 'REFNUM';
      t_errormsg(v_errorCount) := o_errortext('RQOS');
      t_errorfieldval(v_errorCount) := obj_bank.REFNUM;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    IF TRIM(obj_bank.BANKACCKEY) IS NOT NULL AND
       TRIM(obj_bank.CRDTCARD) IS NOT NULL THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'RQOT';
      t_errorfield(v_errorCount) := 'REFNUM';
      t_errormsg(v_errorCount) := o_errortext('RQOT');
      t_errorfieldval(v_errorCount) := obj_bank.REFNUM;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    -- Validate Date
    v_date := VALIDATE_DATE(obj_bank.CURRTO);
    IF v_date <> 'OK' THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'RQLT';
      t_errorfield(v_errorCount) := 'CURRTO';
      t_errormsg(v_errorCount) := o_errortext('RQLT');
      t_errorfieldval(v_errorCount) := obj_bank.CURRTO;
      t_errorprogram(v_errorCount) := i_scheduleName;
      n_currto := o_defaultvalues('CURRTO');
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    ELSE
      n_currto := obj_bank.CURRTO;
      IF n_currto <> 99999999 THEN
        n_yearto := SUBSTR(n_currto, 3, 2);
        n_mnthto := SUBSTR(n_currto, 5, 2);
      END IF;
      IF n_currto = 99999999 THEN
        n_yearto := o_defaultvalues('YEARTO');
        n_mnthto := o_defaultvalues('MTHTO');
      END IF;
    END IF;

    -- validate Factoring house
    IF TRIM(obj_bank.FACTHOUS) IS NULL THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'E186';
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext('E186');
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    IF TRIM(obj_bank.BANKACCKEY) IS NOT NULL AND obj_bank.FACTHOUS <> '98' THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'F907';
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext('F907');
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF TRIM(obj_bank.CRDTCARD) IS NOT NULL AND obj_bank.FACTHOUS <> '99' THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'F907';
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext('F907');
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    IF NOT (itemexist.exists(TRIM('T3684') || TRIM(obj_bank.FACTHOUS) || 9)) THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'F907';
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext('F907');
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    -- validate bank key
    --SELECT COUNT(BANKKEY) INTO n_bankkeyExists FROM babrpf WHERE BANKKEY = v_bankkey;
    --IF n_bankkeyExists               = 0 THEN
    IF NOT (getbankkey.exists(v_bankkey)) THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'F906';
      t_errorfield(v_errorCount) := 'BANKKEY';
      t_errormsg(v_errorCount) := o_errortext('F906');
      t_errorfieldval(v_errorCount) := v_bankkey;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    -- Validate Account Type
    IF NOT (itemexist.exists(TRIM('TR338') || TRIM(obj_bank.BNKACTYP) || 9)) THEN
      b_isNoError := FALSE;
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := 'E081';
      t_errorfield(v_errorCount) := 'BNKACTYP';
      t_errormsg(v_errorCount) := o_errortext('E081');
      t_errorfieldval(v_errorCount) := obj_bank.BNKACTYP;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ----Common Business logic for inserting into ZDOEPF---
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
      CONTINUE again_start;
    END IF;

    IF b_isNoError = TRUE THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);

      -- For CLNTNUM In Target Table
      /*    SELECT ZIGVALUE
       INTO v_igvalue
       FROM PAZDCLPF
      WHERE PREFIX = 'CP'
        AND TRIM(ZENTITY) = v_refNo;*/

      IF NOT (getzigvalue.exists(TRIM(v_refNo))) THEN
        CONTINUE again_start;
      ELSE
        v_igvalue := getzigvalue(TRIM(v_refNo));
      END IF;
    END IF;
    IF b_isNoError = TRUE AND i_zprvaldYN = 'N' THEN
      v_newigvalue := concat(v_igvalue, '-' || v_bankacckeycrdtcard);

      -- Registry table insertion
      INSERT INTO PAZDCLPF
        (PREFIX, ZENTITY, JOBNUM, JOBNAME, ZIGVALUE)
      VALUES
        (C_PREFIX,
         v_refnum,
         i_scheduleNumber,
         i_scheduleName,
         v_newigvalue);

      -- IG table insertion
      select SEQ_CLBAPF.nextval into v_unique_number from dual; -- mps 4/13
      INSERT INTO Jd1dta.CLBAPF
        (CLNTPFX,
         UNIQUE_NUMBER, -- mps 4/13
         CLNTCOY,
         CLNTNUM,
         CURRFROM,
         CURRTO,
         CLNTREL,
         VALIDFLAG,
         BILLDATE01,
         BILLDATE02,
         BILLDATE03,
         BILLDATE04,
         BILLAMT01,
         BILLAMT02,
         BILLAMT03,
         BILLAMT04,
         REMITTYPE,
         NEWRQST,
         FACTHOUS,
         BANKKEY,
         BANKACCKEY,
         BANKACCDSC,
         BNKACTYP,
         CURRCODE,
         SCTYCDE,
         USRPRF,
         JOBNM,
         DATIME,
         BNKBRN,
         MRBNK,
         BSORTCDE,
         ZPBCODE,
         ZPBACNO,
         --ZFACTHOUS, -- CB4
         MTHTO,
         YEARTO)
      VALUES
        (o_defaultvalues('CLNTPFX'),
         v_unique_number,
         o_defaultvalues('CLNTCOY'),
         v_igvalue,
         o_defaultvalues('CURRFROM'),
         n_currto,
         c_clntrel,
         o_defaultvalues('VALIDFLAG'),
         ------- CB4 Start --------
         --         o_defaultvalues('BILLDATE01'),
         --         o_defaultvalues('BILLDATE02'),
         --         o_defaultvalues('BILLDATE03'),
         --         o_defaultvalues('BILLDATE04'),
         0,
         0,
         0,
         0,
         ------- CB4 End --------
         o_defaultvalues('BILLAMT01'),
         o_defaultvalues('BILLAMT02'),
         o_defaultvalues('BILLAMT03'),
         o_defaultvalues('BILLAMT04'),
         o_defaultvalues('REMITTYPE'),
         o_defaultvalues('NEWRQST'),
         obj_bank.FACTHOUS,
         v_bankkey,
         v_bankacckeycrdtcard,
         obj_bank.BANKACCDSC,
         obj_bank.BNKACTYP,
         o_defaultvalues('CURRCODE'),
         o_defaultvalues('SCTYCDE'),
         i_usrprf,
         i_scheduleName,
         CAST(sysdate AS TIMESTAMP),
         o_defaultvalues('BNKBRN'),
         o_defaultvalues('MRBNK'),
         o_defaultvalues('BSORTCDE'),
         o_defaultvalues('ZPBCODE'),
         o_defaultvalues('ZPBACNO'),
         --o_defaultvalues('ZFACTHOUS'), --- CB4
         n_mnthto,
         n_yearto);

      -- CB2 START --
      select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual;
      obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
      obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
      obj_clrrpf.CLNTCOY       := o_defaultvalues('CLNTCOY');
      obj_clrrpf.FOREPFX       := '00';
      obj_clrrpf.FORECOY       := ' ';
      v_forenum                := concat(v_bankkey, v_bankacckeycrdtcard);
      obj_clrrpf.FORENUM       := v_forenum;
      obj_clrrpf.USED2B        := ' ';
      obj_clrrpf.CLNTNUM       := v_igvalue;
      obj_clrrpf.CLRRROLE      := C_CLRROLE_CB;
      obj_clrrpf.JOBNM         := i_scheduleName;
      obj_clrrpf.USRPRF        := i_usrprf;
      obj_clrrpf.DATIME        := sysdate;
      INSERT INTO CLRRPF VALUES obj_clrrpf;
      -- CB END --
      ----CB5:Insert into audit_clrrpf :Start---------

      obj_audit_clrrpf.oldclntnum  := v_igvalue;
      obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
      obj_audit_clrrpf.newclntcoy  := o_defaultvalues('CLNTCOY');
      obj_audit_clrrpf.newclntnum  := v_igvalue;
      obj_audit_clrrpf.newclrrrole := C_CLRROLE_CB;
      obj_audit_clrrpf.newforepfx  := '00';
      obj_audit_clrrpf.newforecoy  := ' ';
      obj_audit_clrrpf.newforenum  := v_forenum;
      obj_audit_clrrpf.newused2b   := ' ';
      obj_audit_clrrpf.newusrprf   := i_usrprf;
      obj_audit_clrrpf.newjobnm    := i_scheduleName;
      obj_audit_clrrpf.newdatime   := sysdate;
      obj_audit_clrrpf.userid      := ' ';
      obj_audit_clrrpf.action      := 'INSERT';
      obj_audit_clrrpf.tranno      := 2;
      obj_audit_clrrpf.systemdate  := sysdate;
      insert into audit_clrrpf values obj_audit_clrrpf;
      ----------CB5 :insert into audit_clrrfpf:end---------
    END IF;
    
    -- Monitor the count of Processed records during batch runs
    SELECT Jd1dta.TEMP_DM_SEQ1.nextval INTO temp_seq_val FROM dual;
    
  END LOOP;
  CLOSE c_bankcursor;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
END BQ9RU_CB01_CLTBNK;