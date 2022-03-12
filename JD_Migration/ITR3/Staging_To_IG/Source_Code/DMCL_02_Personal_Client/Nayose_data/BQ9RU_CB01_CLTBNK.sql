create or replace PROCEDURE "BQ9RU_CB01_CLTBNK"(i_scheduleName   IN VARCHAR2,
                                                i_scheduleNumber IN VARCHAR2,
                                                i_zprvaldYN      IN VARCHAR2,
                                                i_company        IN VARCHAR2,
                                                i_usrprf         IN VARCHAR2,
                                                i_branch         IN VARCHAR2,
                                                i_transCode      IN VARCHAR2,
                                                i_vrcmTermid     IN VARCHAR2,
                                                 start_id         IN NUMBER,
                                                end_id           IN NUMBER)
  AUTHID CURRENT_USER AS
  /***************************************************************************************************
  * Amenment History: CB01 Client Bank
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * Apr24    JDB       CB1   Pa New Implementation
  *****************************************************************************************************/
  -----Local Vairables-----
  v_isAnyError         VARCHAR2(1) DEFAULT 'N';
  v_timestart          NUMBER := dbms_utility.get_time;
  v_bankacckeycrdtcard VARCHAR2(20 CHAR);
  v_newigvalue         VARCHAR2(50 CHAR);
  v_clntrel            CHAR(2 CHAR);
  v_refnum             VARCHAR2(100);
  v_bankkey            CLBAPF.BANKKEY%type;
  v_date               VARCHAR2(100);
  v_refNo              VARCHAR2(15);
  v_unique_number      CLBAPF.UNIQUE_NUMBER%type; -- mps 4/13
  v_igvalue            VARCHAR2(50 CHAR);
  v_tableNametemp      VARCHAR2(10);
  v_tableName          VARCHAR2(10);
  v_errorCount         NUMBER(1) DEFAULT 0;
  n_currto             CLBAPF.CURRTO%type;
  n_mnthto             CLBAPF.MTHTO%type;
  n_yearto             CLBAPF.YEARTO%type;
  v_pkValueClrrpf      CLRRPF.UNIQUE_NUMBER%type;
  p_exitcode           number;
  p_exittext           varchar2(4000);
  ----------Constant--------------
  C_PREFIX       CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLCB',
                                                              i_company);
  C_BQ9RU        CONSTANT VARCHAR2(5) := 'BQ9RU';
  C_RQLI         CONSTANT VARCHAR2(4) := 'RQLI';
  C_CB_CLRROLE   CONSTANT VARCHAR2(4) := 'CB';
  C_CLNTNOTFOUND CONSTANT VARCHAR2(12) := 'CLNTNOTFOUND';
  /*Client not yet migrated*/
  C_RQO6 CONSTANT VARCHAR2(4) := 'RQO6';
  /*Duplicated record found*/
  C_E186 CONSTANT VARCHAR2(4) := 'E186';
  /*Field must be entered*/
  C_RQOS CONSTANT VARCHAR2(4) := 'RQOS';
  /*BnkAcc and CC are blank*/
  C_RQOT CONSTANT VARCHAR2(4) := 'RQOT';
  /*Both BnkAcc and CC given*/
  C_RQLT CONSTANT VARCHAR2(4) := 'RQLT';
  /*Invalid Date*/
  C_F907 CONSTANT VARCHAR2(4) := 'F907';
  /*Invalid factoring house*/
  C_F906 CONSTANT VARCHAR2(4) := 'F906';
  /*Bank/Branch not on file*/
  C_E081 CONSTANT VARCHAR2(4) := 'E081';
  /*Invalid Account Type*/
  -------------Constan Vlaues---
  C_BNKBRN     CONSTANT NCHAR(6 CHAR) := '      ';
  C_BSORTCDE   CONSTANT NCHAR(10 CHAR) := null;
  C_MRBNK      CONSTANT NCHAR(6 CHAR) := '      ';
  C_NEWRQST    CONSTANT CHAR(1 CHAR) := ' ';
  C_REMITTYPE  CONSTANT CHAR(1 CHAR) := ' ';
  C_SCTYCDE    CONSTANT CHAR(3 CHAR) := '   ';
  C_ZPBACNO    CONSTANT NCHAR(8 CHAR) := '        ';
  C_ZPBCODE    CONSTANT NCHAR(6 CHAR) := '      ';
  C_DDTRANCODE CONSTANT CHAR(2 CHAR) := null;
  C_ZFACTHOUS  CONSTANT CHAR(2 BYTE) := null;
  C_ACCNAME    CONSTANT VARCHAR2(30 CHAR) := null;
  C_FORECOY    CONSTANT CHAR(1 CHAR) := null;
  C_USED2B     CONSTANT CHAR(1 CHAR) := ' ';

  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  getbankkey      PKG_COMMON_DMCB.bankkey;
  checkclient     PKG_COMMON_DMCB.zdclpf_cp01;
  checkdupl       pkg_common_dmcb.cbduplicate;
  getzigvalue     pkg_common_dmcb.zigvaluetype;
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

  ----IG tables objects
  obj_pazdclpf     VIEW_DM_PAZDCLPF%rowtype;
  obj_CLBAPF       Jd1dta.clbapf%rowtype;
  obj_clrrpf       CLRRPF%rowtype;
  obj_audit_clrrpf AUDIT_CLRRPF%rowtype;

  ---------------Common function end-----------
  CURSOR c_bankcursor IS
    select *
      from (with CLIENT_BANK_SRC as (select clntbnk.*,
                                            clntbnk.BANKCD || '   ' ||
                                            clntbnk.BRANCHCD as bankkey,
                                            (CASE
                                              WHEN TRIm(ZENTITY) is null THEN
                                               'CLNTNOTFOUND'
                                              ELSE
                                               pazdcl.ZENTITY
                                            END) as BNKCLNTNO,
                                            (CASE
                                              WHEN TRIm(zigvalue) is null THEN
                                               'CLNTNOTFOUND'
                                              ELSE
                                               pazdcl.zigvalue
                                            END) as IG_CLNTNUM
                                       from Jd1dta.DMIGTITDMGCLNTBANK clntbnk
                                       left outer join (select zentity,
                                                              zigvalue
                                                         from Jd1dta.pazdclpf
                                                        where prefix = 'CP') pazdcl
                                         on clntbnk.refnum = pazdcl.zentity), CLIENT_BANK_SHI as (SELECT a.clntnum mem_clntnum,
                                                                                                         CASE
                                                                                                           WHEN b.bankkey =
                                                                                                                '9999   999' THEN
                                                                                                            b.bankacckey
                                                                                                           ELSE
                                                                                                            ''
                                                                                                         END AS SHI_crdtcardno,
                                                                                                         CASE
                                                                                                           WHEN b.bankkey !=
                                                                                                                '9999   999' THEN
                                                                                                            b.bankacckey
                                                                                                           ELSE
                                                                                                            ''
                                                                                                         END AS SHI_bankacckey,
                                                                                                         b.BANKKEY as SHI_BANKKEY
                                                                                                    FROM Jd1dta.clntpf a
                                                                                                   INNER JOIN Jd1dta.clbapf b
                                                                                                      ON a.clntnum =
                                                                                                         b.clntnum
                                                                                                     AND b.validflag = '1')
             select srcbnk.*,
                    shibnk.*,
                    (CASE
                      WHEN TRIM(shibnk.MEM_CLNTNUM) is null THEN
                       'CLNTNOTFOUND'
                      WHEN RTRIM(srcbnk.IG_CLNTNUM) =
                           RTRIM(shibnk.MEM_CLNTNUM) THEN
                       'MATCHING'
                      WHEN RTRIM(srcbnk.IG_CLNTNUM) !=
                           RTRIM(shibnk.MEM_CLNTNUM) THEN
                       IG_CLNTNUM
                      else
                       ''
                    END) as F_CLNTNUM,
                    (CASE
                      WHEN TRIM(shibnk.shi_bankacckey) is null THEN
                       'BANKNOTFOUND'
                      WHEN RTRIM(srcbnk.BANKACCKEY) =
                           RTRIM(shibnk.shi_bankacckey) THEN
                       'MATCHING'
                      WHEN RTRIM(srcbnk.BANKACCKEY) !=
                           RTRIM(shibnk.shi_bankacckey) THEN
                       srcbnk.BANKACCKEY
                      else
                       ''
                    END) as F_BANKACCKEY,
                    (CASE
                      WHEN TRIM(shibnk.shi_crdtcardno) is null THEN
                       'CRDTNOTFOUND'
                      WHEN RTRIM(srcbnk.CRDTCARD) =
                           RTRIM(shibnk.shi_crdtcardno) THEN
                       'MATCHING'
                      WHEN RTRIM(srcbnk.CRDTCARD) !=
                           RTRIM(shibnk.shi_crdtcardno) THEN
                       srcbnk.CRDTCARD
                      else
                       ''
                    END) as F_CRDTCARD
               from CLIENT_BANK_SRC srcbnk
               left outer join CLIENT_BANK_SHI shibnk
                 on srcbnk.ig_clntnum = shibnk.mem_clntnum
                and ((RTRIM(srcbnk.BANKACCKEY) =
                    RTRIM(shibnk.shi_bankacckey)) or
                    (RTRIM(srcbnk.CRDTCARD) = RTRIM(shibnk.shi_crdtcardno)))
                and (RTRIM(srcbnk.bankKey) = RTRIM(shibnk.SHI_BANKKEY)))where RECIDXCLBK  between start_id and end_id;


  obj_bank c_bankcursor%rowtype;
BEGIN
  dbms_output.put_line('Start execution of BQ9RU_CB01_CLTBNK, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);
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
  --pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  PKG_COMMON_DMCB.getbankkey(getbankkey => getbankkey);
  PKG_COMMON_DMCB.checkclient(checkclient => checkclient);
  pkg_common_dmcb.checkcbdup(checkdupl => checkdupl);
  pkg_common_dmcb.getzigvalue(getzigvalue => getzigvalue);
  ---------Common Function Calling------------
  OPEN c_bankcursor;
  <<again_start>>
  LOOP
    FETCH c_bankcursor
      INTO obj_bank;
    EXIT WHEN c_bankcursor%notfound;
  
    v_bankkey := concat(obj_bank.BANKCD, '   ' || obj_bank.BRANCHCD);
    v_refNo := TRIM(obj_bank.REFNUM);
    v_isAnyError := 'N';
    v_errorCount := 0;
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    v_refnum := NULL;
    i_zdoe_info := NULL;
  
    IF TRIM(obj_bank.BANKACCKEY) IS NULL THEN
      v_refnum             := TRIM(obj_bank.refnum) || '-' ||
                              TRIM(obj_bank.SEQNO) || '-' ||
                              TRIM(obj_bank.CRDTCARD);
      v_clntrel            := 'CC';
      v_bankacckeycrdtcard := TRIM(obj_bank.CRDTCARD);
    ELSE
      v_refnum             := TRIM(obj_bank.refnum) || '-' ||
                              TRIM(obj_bank.SEQNO) || '-' ||
                              TRIM(obj_bank.BANKACCKEY);
      v_clntrel            := 'CB';
      v_bankacckeycrdtcard := TRIM(obj_bank.BANKACCKEY);
    END IF;
    i_zdoe_info.i_refKey     := v_refnum;
    i_zdoe_info.i_zfilename  := 'TITDMGCLNTBANK';
    i_zdoe_info.i_prefix     := C_PREFIX;
    i_zdoe_info.i_scheduleno := i_scheduleNumber;
    i_zdoe_info.i_tableName  := v_tableName;
  
    ---Check client 
    IF NOT (checkclient.exists(TRIM(obj_bank.refnum))) THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_RQLI;
      i_zdoe_info.i_errormsg01     := o_errortext(C_RQLI);
      i_zdoe_info.i_errorfield01   := 'REFNUM';
      i_zdoe_info.i_fieldvalue01   := obj_bank.refnum;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      GOTO insertzdoe;
    END IF;
  
    IF (checkdupl.exists(TRIM(v_refnum))) THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_RQO6;
      i_zdoe_info.i_errormsg01     := o_errortext(C_RQO6);
      i_zdoe_info.i_errorfield01   := 'REFNUM';
      i_zdoe_info.i_fieldvalue01   := obj_bank.REFNUM;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      GOTO insertzdoe;
    END IF;
  
    -- Validate Account Number
    IF TRIM(obj_bank.BANKACCDSC) IS NULL THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_E186;
      t_errorfield(v_errorCount) := 'BANKACCDSC';
      t_errormsg(v_errorCount) := o_errortext(C_E186);
      t_errorfieldval(v_errorCount) := obj_bank.BANKACCDSC;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    -- Validation For BANKACCKEY and CRDTCARD
    IF TRIM(obj_bank.BANKACCKEY) IS NULL AND
       TRIM(obj_bank.CRDTCARD) IS NULL THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_RQOS;
      t_errorfield(v_errorCount) := 'REFNUM';
      t_errormsg(v_errorCount) := o_errortext(C_RQOS);
      t_errorfieldval(v_errorCount) := obj_bank.REFNUM;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF TRIM(obj_bank.BANKACCKEY) IS NOT NULL AND
       TRIM(obj_bank.CRDTCARD) IS NOT NULL THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_RQOT;
      t_errorfield(v_errorCount) := 'REFNUM';
      t_errormsg(v_errorCount) := o_errortext(C_RQOT);
      t_errorfieldval(v_errorCount) := obj_bank.REFNUM;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    -- Validate Date
    v_date := VALIDATE_DATE(obj_bank.CURRTO);
    IF v_date <> 'OK' THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_RQLT;
      t_errorfield(v_errorCount) := 'CURRTO';
      t_errormsg(v_errorCount) := o_errortext(C_RQLT);
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
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_E186;
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext(C_E186);
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF TRIM(obj_bank.BANKACCKEY) IS NOT NULL AND obj_bank.FACTHOUS <> '98' THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_F907;
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext(C_F907);
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF TRIM(obj_bank.CRDTCARD) IS NOT NULL AND obj_bank.FACTHOUS <> '99' THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_F907;
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext(C_F907);
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF NOT (itemexist.exists(TRIM('T3684') || TRIM(obj_bank.FACTHOUS) || 9)) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_F907;
      t_errorfield(v_errorCount) := 'FACTHOUS';
      t_errormsg(v_errorCount) := o_errortext(C_F907);
      t_errorfieldval(v_errorCount) := obj_bank.FACTHOUS;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF NOT (getbankkey.exists(v_bankkey)) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_F906;
      t_errorfield(v_errorCount) := 'BANKKEY';
      t_errormsg(v_errorCount) := o_errortext(C_F906);
      t_errorfieldval(v_errorCount) := v_bankkey;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    -- Validate Account Type
    IF NOT (itemexist.exists(TRIM('TR338') || TRIM(obj_bank.BNKACTYP) || 9)) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_E081;
      t_errorfield(v_errorCount) := 'BNKACTYP';
      t_errormsg(v_errorCount) := o_errortext(C_E081);
      t_errorfieldval(v_errorCount) := obj_bank.BNKACTYP;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    ----Common Business logic for inserting into ZDOEPF---
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
      CONTINUE again_start;
    END IF;
    IF (v_isAnyError = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    
    END IF;
    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN
      IF (obj_bank.f_clntnum = C_CLNTNOTFOUND) THEN
        IF NOT (getzigvalue.exists(TRIM(v_refNo))) THEN
          CONTINUE again_start;
        ELSE
          v_igvalue := getzigvalue(TRIM(v_refNo));
        END IF;
        v_newigvalue := concat(v_igvalue, '-' || v_bankacckeycrdtcard);
      
        ----Insert into registry table:start-----
        obj_pazdclpf.RECSTATUS := 'OK';
        obj_pazdclpf.PREFIX    := C_PREFIX;
        obj_pazdclpf.ZENTITY   := v_refnum;
        obj_pazdclpf.ZIGVALUE  := v_newigvalue;
        obj_pazdclpf.JOBNUM    := i_scheduleNumber;
        obj_pazdclpf.JOBNAME   := i_scheduleName;
      
        insert into Jd1dta.VIEW_DM_PAZDCLPF values obj_pazdclpf;
        ----Insert into registry table:end-----
      
        -- IG table insertion
        ----Insert into IG table:start-----
      
        select SEQ_CLBAPF.nextval into v_unique_number from dual; -- mps 4/13
      
        obj_CLBAPF.UNIQUE_NUMBER := v_unique_number;
        obj_CLBAPF.CLNTPFX       := o_defaultvalues('CLNTPFX');
        obj_CLBAPF.CLNTCOY       := o_defaultvalues('CLNTCOY');
        obj_CLBAPF.CLNTNUM       := v_igvalue;
        obj_CLBAPF.CURRFROM      := o_defaultvalues('CURRFROM');
        obj_CLBAPF.CURRTO        := n_currto;
        obj_CLBAPF.CLNTREL       := v_clntrel;
        obj_CLBAPF.VALIDFLAG     := o_defaultvalues('VALIDFLAG');
        obj_CLBAPF.BILLDATE01    := o_defaultvalues('BILLDATE01');
        obj_CLBAPF.BILLDATE02    := o_defaultvalues('BILLDATE02');
        obj_CLBAPF.BILLDATE03    := o_defaultvalues('BILLDATE03');
        obj_CLBAPF.BILLDATE04    := o_defaultvalues('BILLDATE04');
        obj_CLBAPF.BILLAMT01     := o_defaultvalues('BILLAMT01');
        obj_CLBAPF.BILLAMT02     := o_defaultvalues('BILLAMT02');
        obj_CLBAPF.BILLAMT03     := o_defaultvalues('BILLAMT03');
        obj_CLBAPF.BILLAMT04     := o_defaultvalues('BILLAMT04');
        obj_CLBAPF.REMITTYPE     := C_REMITTYPE;
        obj_CLBAPF.NEWRQST       := C_NEWRQST;
        obj_CLBAPF.FACTHOUS      := obj_bank.FACTHOUS;
        obj_CLBAPF.BANKKEY       := v_bankkey;
        obj_CLBAPF.BANKACCKEY    := v_bankacckeycrdtcard;
        obj_CLBAPF.BANKACCDSC    := obj_bank.BANKACCDSC;
        obj_CLBAPF.BNKACTYP      := obj_bank.BNKACTYP;
        obj_CLBAPF.CURRCODE      := o_defaultvalues('CURRCODE');
        obj_CLBAPF.DDTRANCODE    := C_DDTRANCODE;
        obj_CLBAPF.SCTYCDE       := C_SCTYCDE;
        obj_CLBAPF.USRPRF        := i_usrprf;
        obj_CLBAPF.JOBNM         := i_scheduleName;
        obj_CLBAPF.DATIME        := sysdate;
        obj_CLBAPF.CRCIND        := o_defaultvalues('CRCIND');
        obj_CLBAPF.BNKBRN        := C_BNKBRN;
        obj_CLBAPF.MRBNK         := C_MRBNK;
        obj_CLBAPF.BSORTCDE      := C_BSORTCDE;
        obj_CLBAPF.ZPBCODE       := C_ZPBCODE;
        obj_CLBAPF.ZPBACNO       := C_ZPBACNO;
        obj_CLBAPF.ZFACTHOUS     := C_ZFACTHOUS;
        obj_CLBAPF.MTHTO         := n_mnthto;
        obj_CLBAPF.YEARTO        := n_yearto;
        obj_CLBAPF.ACCNAME       := C_ACCNAME;
      
        insert into Jd1dta.clbapf values obj_CLBAPF;
      
        ----Insert into IG table:END-----
        -- insert in  IG CLRRPF table start-
        select SEQ_CLRRPF.nextval into v_pkValueClrrpf from dual; --AG3
        obj_clrrpf.UNIQUE_NUMBER := v_pkValueClrrpf;
        obj_clrrpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
        obj_clrrpf.CLNTCOY       := o_defaultvalues('CLNTCOY');
        obj_clrrpf.CLNTNUM       := v_igvalue;
        obj_clrrpf.CLRRROLE      := C_CB_CLRROLE;
        obj_clrrpf.FOREPFX       := o_defaultvalues('FOREPFX');
        obj_clrrpf.FORECOY       := C_FORECOY;
        obj_clrrpf.FORENUM       := concat(v_bankkey, v_bankacckeycrdtcard);
        obj_clrrpf.USED2B        := C_USED2B;
        obj_clrrpf.JOBNM         := i_scheduleName;
        obj_clrrpf.USRPRF        := i_usrprf;
        obj_clrrpf.DATIME        := sysdate;
        INSERT INTO CLRRPF VALUES obj_clrrpf;
        -- insert in  IG CLRRPF table end-
      
        ----:Insert into audit_clrrpf :Start---------
      
        obj_audit_clrrpf.oldclntnum  := obj_clrrpf.clntnum;
        obj_audit_clrrpf.newclntpfx  := o_defaultvalues('CLNTPFX');
        obj_audit_clrrpf.newclntcoy  := o_defaultvalues('CLNTCOY');
        obj_audit_clrrpf.newclntnum  := obj_clrrpf.clntnum;
        obj_audit_clrrpf.newclrrrole := C_CB_CLRROLE;
        obj_audit_clrrpf.newforepfx  := obj_clrrpf.forepfx;
        obj_audit_clrrpf.newforecoy  := obj_clrrpf.forecoy;
        obj_audit_clrrpf.newforenum  := obj_clrrpf.forenum;
        obj_audit_clrrpf.newused2b   := C_USED2B;
        obj_audit_clrrpf.newusrprf   := i_usrprf;
        obj_audit_clrrpf.newjobnm    := i_scheduleName;
        obj_audit_clrrpf.newdatime   := sysdate;
        obj_audit_clrrpf.userid      := i_usrprf;
        obj_audit_clrrpf.action      := 'INSERT';
        obj_audit_clrrpf.tranno      := 2;
        obj_audit_clrrpf.systemdate  := sysdate;
        insert into audit_clrrpf values obj_audit_clrrpf;
        ---------- :insert into audit_clrrfpf:end---------
      END iF;
    END IF;
  
  END LOOP;
  CLOSE c_bankcursor;

  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

  dbms_output.put_line('End execution of BQ9RU_CB01_CLTBNK, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);
exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'BQ9RU_CB01_CLTBNK : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);
  
    commit;
    raise;
END BQ9RU_CB01_CLTBNK;
