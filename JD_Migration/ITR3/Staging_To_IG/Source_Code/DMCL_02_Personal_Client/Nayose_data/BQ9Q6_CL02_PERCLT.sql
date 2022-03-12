CREATE OR REPLACE PROCEDURE "BQ9Q6_CL02_PERCLT"(i_scheduleName   IN VARCHAR2,
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
  * Amenment History: CL02 Personal Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * Mar26    JDB       CP1   PA New implementation
  
  *****************************************************************************************************/
  ----------------Local Variables:START------------- 
  v_timestart     NUMBER := dbms_utility.get_time;
  v_pkValue       CLEXPF.UNIQUE_NUMBER%type;
  v_isAnyError    VARCHAR2(1) DEFAULT 'N';
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  errorCount      NUMBER(1) DEFAULT 0;
  v_tranid        VARCHAR2(14 CHAR);
  v_clntnum       VARCHAR2(8 CHAR);
  p_exitcode      number;
  p_exittext      varchar2(200);
  v_occpclass     varchar2(2);
  ----------------Local Variables:END------------- 

  ----------------CONSTANT:START------------- 
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLPL', i_company);
  C_BQ9Q6  CONSTANT VARCHAR2(5) := 'BQ9Q6';
  C_Z017   CONSTANT VARCHAR2(4) := 'RQLX';
  /* Missing of Kana Address*/
  C_H366 CONSTANT VARCHAR2(4) := 'H366';
  /*Field cannot be blank    */
  C_Z098 CONSTANT VARCHAR2(4) := 'RQO6';
  /*Duplicated record found*/
  C_Z020 CONSTANT VARCHAR2(4) := 'RQV3';
  /*Missing of Kanji name*/
  C_Z073 CONSTANT VARCHAR2(4) := 'RQNH'; --Not used
  /*Invalid Kanji Character*/
  C_Z021 CONSTANT VARCHAR2(4) := 'RQV4';
  /*Missing of Kana name*/
  C_Z016 CONSTANT VARCHAR2(4) := 'RQLW';
  /*Missing of Kanji Address*/
  C_G979 CONSTANT VARCHAR2(4) := 'G979';
  /*Sex not on T3582*/
  C_F992 CONSTANT VARCHAR2(4) := 'F992';
  /*Occup. code not in T3644*/
  C_Z013 CONSTANT VARCHAR2(4) := 'RQLT';
  /*Invalid Date*/
  C_E374 CONSTANT VARCHAR2(4) := 'E374'; --Not used
  /*Value Should be Empty*/
  C_E186 CONSTANT VARCHAR2(4) := 'E186';
  /*Field must be entered*/
  C_D009 CONSTANT VARCHAR2(4) := 'D009'; --not used
  /*Addr. rules not in T2241*/
  C_RQLI CONSTANT VARCHAR2(4) := 'RQLI';
  /*Client not yet migrated */
  C_T3645 CONSTANT VARCHAR2(5) := 'T3645'; --nnot used
  C_T2241 CONSTANT VARCHAR2(5) := 'T2241'; -- not used
  C_TR393 CONSTANT VARCHAR2(5) := 'TR393'; --not used
  C_T3644 CONSTANT VARCHAR2(5) := 'T3644';
  C_T3582 CONSTANT VARCHAR2(5) := 'T3582';
  C_DTSM  CONSTANT VARCHAR2(4) := 'DTSM'; --not used
  ------Constant----
  C_IDEXPIREDATE  CONSTANT NUMBER(8, 0) := null;
  C_ISPERMANENTID CONSTANT CHAR(1 CHAR) := null;
  C_SECUITYNO     CONSTANT CHAR(24 CHAR) := '                        ';
  C_PAYROLLNO     CONSTANT CHAR(10 CHAR) := '          ';
  C_SALUT         CONSTANT CHAR(6 CHAR) := null;
  C_CLTADDR04     CONSTANT NCHAR(50 CHAR) := '                                                  ';
  C_CLTADDR05     CONSTANT NCHAR(50 CHAR) := '                                                  ';
  C_MAILING       CONSTANT CHAR(1 CHAR) := ' ';
  C_DIRMAIL       CONSTANT CHAR(1 CHAR) := ' ';
  C_VIP           CONSTANT CHAR(1 CHAR) := ' ';
  C_STATCODE      CONSTANT CHAR(2 CHAR) := '  ';
  C_SOE           CONSTANT CHAR(10 CHAR) := '          ';
  C_DOCNO         CONSTANT CHAR(8 CHAR) := '        ';
  C_MIDDL01       CONSTANT CHAR(20 CHAR) := '                    ';
  C_MIDDL02       CONSTANT CHAR(20 CHAR) := '                    ';
  C_MARRYD        CONSTANT CHAR(1 CHAR) := ' ';
  C_TLXNO         CONSTANT CHAR(16 CHAR) := '                ';
  C_FAXNO         CONSTANT CHAR(16 CHAR) := '                ';
  C_TGRAM         CONSTANT CHAR(16 CHAR) := '                ';
  C_BIRTHP        CONSTANT CHAR(20 CHAR) := '                    ';
  C_SALUTL        CONSTANT CHAR(8 CHAR) := '        ';
  C_ROLEFLAG01    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG02    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG03    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG04    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG06    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG07    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG08    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG09    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG10    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG11    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG12    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG13    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG15    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG16    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG17    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG19    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG20    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG21    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG22    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG23    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG24    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG25    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG26    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG27    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG28    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG29    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG30    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG31    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG32    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG33    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG34    CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG35    CONSTANT CHAR(1 CHAR) := ' ';
  C_STCA          CONSTANT CHAR(3 CHAR) := '   ';
  C_STCB          CONSTANT CHAR(3 CHAR) := '   ';
  C_STCC          CONSTANT CHAR(3 CHAR) := '   ';
  C_STCD          CONSTANT CHAR(3 CHAR) := '   ';
  C_STCE          CONSTANT CHAR(3 CHAR) := '   ';
  C_PROCFLAG      CONSTANT CHAR(2 CHAR) := null;
  C_TERMID        CONSTANT CHAR(4 CHAR) := null;

  C_USER_T         CONSTANT NUMBER(6, 0) := null;
  C_TRDT           CONSTANT NUMBER(6, 0) := null;
  C_TRTM           CONSTANT NUMBER(6, 0) := null;
  C_SNDXCDE        CONSTANT CHAR(4 CHAR) := '    ';
  C_NATLTY         CONSTANT CHAR(3 CHAR) := '   ';
  C_FAO            CONSTANT CHAR(30 CHAR) := '                              ';
  C_STATE          CONSTANT CHAR(4 CHAR) := '    ';
  C_CTRYORIG       CONSTANT CHAR(3 CHAR) := '   ';
  C_ECACT          CONSTANT CHAR(4 CHAR) := '    ';
  C_STAFFNO        CONSTANT CHAR(6 CHAR) := '      ';
  C_IDTYPE         CONSTANT NCHAR(2 CHAR) := '  ';
  C_Z1GSTREGN      CONSTANT CHAR(16 CHAR) := '                ';
  C_KANJISURNAME   CONSTANT CHAR(60 CHAR) := null;
  C_KANJIGIVNAME   CONSTANT CHAR(60 CHAR) := null;
  C_KANJICLTADDR01 CONSTANT CHAR(30 CHAR) := null;
  C_KANJICLTADDR02 CONSTANT CHAR(30 CHAR) := null;
  C_KANJICLTADDR03 CONSTANT CHAR(30 CHAR) := null;
  C_KANJICLTADDR04 CONSTANT CHAR(30 CHAR) := null;
  C_KANJICLTADDR05 CONSTANT CHAR(30 CHAR) := null;
  C_ZKANADDR03     CONSTANT VARCHAR2(60 CHAR) := '                                                            ';
  C_ZKANADDR04     CONSTANT VARCHAR2(60 CHAR) := '                                                            ';
  C_ZKANADDR05     CONSTANT VARCHAR2(60 CHAR) := '                                                            ';
  C_ABUSNUM        CONSTANT NCHAR(11 CHAR) := '           ';
  C_BRANCHID       CONSTANT NCHAR(3 CHAR) := '   ';
  C_TELECTRYCODE   CONSTANT VARCHAR2(3 BYTE) := '   ';
  C_TELECTRYCODE1  CONSTANT VARCHAR2(3 BYTE) := '   ';
  C_ZDLIND         CONSTANT CHAR(2 BYTE) := '  ';
  C_DIRMKTMTD      CONSTANT NCHAR(8 CHAR) := '        ';
  C_PREFCONMTD     CONSTANT NCHAR(8 CHAR) := '        ';
  C_WORKUNIT       CONSTANT NCHAR(60 CHAR) := null;
  C_CLNTSTATECD    CONSTANT VARCHAR2(8 CHAR) := '        ';
  C_FUNDADMINFLAG  CONSTANT VARCHAR2(1 BYTE) := ' ';
  C_PROVINCE       CONSTANT NCHAR(15 CHAR) := '               ';
  C_SEQNO          CONSTANT NCHAR(8 CHAR) := '        ';

  C_RDIDTELNO   CONSTANT CHAR(16 CHAR) := '                ';
  C_RPAGER      CONSTANT CHAR(16 CHAR) := '                ';
  C_RINTERNET   CONSTANT CHAR(50 CHAR) := '                                                  ';
  C_RTAXIDNUM   CONSTANT VARCHAR2(40 CHAR) := '                    ';
  C_RSTAFLAG    CONSTANT CHAR(2 CHAR) := '  ';
  C_SPLINDIC    CONSTANT CHAR(2 CHAR) := '  ';
  C_ZSPECIND    CONSTANT CHAR(2 CHAR) := '  ';
  C_OLDIDNO     CONSTANT CHAR(24 CHAR) := '                        ';
  C_OTHIDNO     CONSTANT NCHAR(24 CHAR) := '                        ';
  C_OTHIDTYPE   CONSTANT NCHAR(2 CHAR) := '  ';
  C_AMLSTATUS   CONSTANT CHAR(2 CHAR) := '  ';
  C_ZDMAILTO01  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILTO02  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC01  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC02  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC03  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC04  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC05  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC06  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_ZDMAILCC07  CONSTANT CHAR(40 BYTE) := '                                        ';
  C_RINTERNET2  CONSTANT NCHAR(50 CHAR) := '                                                  ';
  C_ZFATHERNAME CONSTANT NCHAR(30 CHAR) := '                              ';
  ----------------CONSTANT:END------------- 
  --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  checkdupl       pkg_common_dmcp.cpduplicate;
  pitemexist      pkg_common_dmcp.itemschec;
  getnypf         pkg_common_dmcp.nypftype;
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
  ---------------Common function end-----------
  ------IG table obj start---
  obj_pazdclpf VIEW_DM_PAZDCLPF%rowtype;
  obj_clntpf   CLNTPF%rowtype;
  obj_clexpf   CLEXPF%rowtype;
  obj_nypf    pkg_common_dmcp.obj_nypf;
  
  ------IG table obj End---
  CURSOR Cur_StageTable IS
    select *
      from ((select * from Jd1dta.DMIGTITDMGCLTRNHIS where transhist = '1') A left
            outer join (select POSTALCD, min(ADDRCD) as MINADDRCD
                          from Jd1dta.zadrpf
                         group by POSTALCD) POST on
            trim(a.cltpcode) = POST.POSTALCD)
     WHERE RECIDXCLHIS between start_id and end_id
     order by LPAD(REFNUM, 8, '0') asc, ZSEQNO desc;

  obj_cur_Stagetab Cur_StageTable%rowtype;

BEGIN

  dbms_output.put_line('Start execution of BQ9Q6_CL02_PERCLT, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  ---------Common Function:Calling------------
  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9Q6,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCP',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCP',
                                        o_errortext   => o_errortext);
  pkg_common_dmcp.getnyval(getnypf => getnypf);

  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');

  v_tableName := TRIM(v_tableNametemp);
  -- pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  pkg_common_dmcp.checkcpdup(checkdupl => checkdupl);
  pkg_common_dmcp.getitemvalue(itemexist => pitemexist);

  ---------Common Function:Calling------------
  v_tranid := concat('QPAD', TO_CHAR(sysdate, 'YYMMDDHHMM'));
  -- Open Cursor

  OPEN Cur_StageTable;
  <<skipRecord>>
  LOOP
    FETCH Cur_StageTable
      INTO obj_cur_Stagetab;
    EXIT WHEN Cur_StageTable%notfound;
    v_isAnyError := 'N';
    errorCount := 0;
    i_zdoe_info := NULL;
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info.i_zfilename := 'TITDMGCLTRNHIS';
    i_zdoe_info.i_prefix := C_PREFIX;
    i_zdoe_info.i_scheduleno := i_scheduleNumber;
    i_zdoe_info.i_tableName := v_tableName;
    i_zdoe_info.i_refKey := TRIM(obj_cur_Stagetab.REFNUM);
    -------Validation:Start------------------
  
    IF TRIM(obj_cur_Stagetab.refnum) IS NULL THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_H366;
      i_zdoe_info.i_errormsg01     := o_errortext(C_H366);
      i_zdoe_info.i_errorfield01   := 'Refnum';
      i_zdoe_info.i_fieldvalue01   := TRIM(obj_cur_Stagetab.refnum);
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skipRecord;
    ELSIF  (checkdupl.exists(TRIM(obj_cur_Stagetab.refnum))) THEN
        --  IF isDuplicate > 0 THEN
        v_isAnyError                 := 'Y';
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z098;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
        i_zdoe_info.i_errorfield01   := 'Refnum';
        i_zdoe_info.i_fieldvalue01   := TRIM(obj_cur_Stagetab.refnum);
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
         END IF;

     if not (getnypf.exists(TRIM(obj_cur_Stagetab.refnum))) THEN
        v_isAnyError                 := 'Y';
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_RQLI;
        i_zdoe_info.i_errormsg01     := 'Client not migrated';
        i_zdoe_info.i_errorfield01   := 'REFNUM';
        i_zdoe_info.i_fieldvalue01   := TRIM(obj_cur_Stagetab.refnum);
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      end if;
      
    --LSURNAME
    --  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lsurname) || 9)) THEN
    IF TRIM(obj_cur_Stagetab.lsurname) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z020;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_Z020);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.lsurname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --  ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_lsurname);
    --      IF isValidName                 = 'Invalid' THEN
    --        v_isAnyError                 := 'Y';
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'lsurname';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_lsurname);
    --        t_errorprogram(errorCount)  := i_scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lgivname) || 9)) THEN
    IF TRIM(obj_cur_Stagetab.lgivname) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z020;
      t_errorfield(errorCount) := 'lgivname';
      t_errormsg(errorCount) := o_errortext(C_Z020);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.lgivname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_lgivname);
    --      IF isValidName                 = 'Invalid' THEN
    --        v_isAnyError                 := 'Y';
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'lgivname';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_lgivname);
    --        t_errorprogram(errorCount)  := i_scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    --3) ZKANAGIVNAME is  Null
    IF TRIM(obj_cur_Stagetab.zkanagivname) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'ZKNAGIVNAM';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.zkanagivname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 4) ZKANASURNAME is  Null
    IF TRIM(obj_cur_Stagetab.zkanasurname) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'ZKNASURNAM';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.zkanasurname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- CLTADDR01 ( Have Doubt for Addtess Rule in T2241
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_cltaddr01) || 9)) THEN
    IF TRIM(obj_cur_Stagetab.cltaddr01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'CLTADDR01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.cltaddr01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr01);
    --      IF isValidName                 = 'Invalid' THEN
    --        v_isAnyError                 := 'Y';
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr01';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
    --        t_errorprogram(errorCount)  := i_scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- 5) CLTADDR02 is Null
    IF TRIM(obj_cur_Stagetab.cltaddr02) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.cltaddr02);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --    ELSE
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr02);
    --      IF isValidName                 = 'Invalid' THEN
    --        v_isAnyError                 := 'Y';
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr02';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr02);
    --        t_errorprogram(errorCount)  := i_scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- 6)CLTADDR03 is Null --27/02/2018 as per the business hamma said
    --    IF TRIM(v_cltaddr03)          IS NULL THEN
    --      v_isAnyError                 := 'Y';
    --      errorCount                  := errorCount + 1;
    --      t_ercode(errorCount)        := C_Z016;
    --      t_errorfield(errorCount)    := 'cltaddr03';
    --      t_errormsg(errorCount)      := o_errortext(C_Z016);
    --      t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --      t_errorprogram(errorCount)  := i_scheduleName;
    --      IF errorCount               >= 5 THEN
    --        GOTO insertzdoe;
    --      END IF;
    --
    --     IF TRIM(v_cltaddr03)          IS NOT NULL THEN
    --      --Kanji character validation
    --      isValidName                   := VALIDATE_JAPANESE_TEXT(v_cltaddr03);
    --      IF isValidName                 = 'Invalid' THEN
    --        v_isAnyError                 := 'Y';
    --        errorCount                  := errorCount + 1;
    --        t_ercode(errorCount)        := C_Z073;
    --        t_errorfield(errorCount)    := 'cltaddr03';
    --        t_errormsg(errorCount)      := o_errortext(C_Z073);
    --        t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --        t_errorprogram(errorCount)  := i_scheduleName;
    --        IF errorCount               >= 5 THEN
    --          GOTO insertzdoe;
    --        END IF;
    --      END IF;
    --    END IF;
    -- 7) ZKANADDR01 is Null
    IF TRIM(obj_cur_Stagetab.zkanaddr01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.zkanaddr01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 8) ZKANADDR02 is Null
    ---SIT Changes Removed by requirment
    /*  IF TRIM(v_zkanaddr02) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z017;
      t_errorfield(errorCount) := 'zkanaddr02';
      t_errormsg(errorCount) := o_errortext(C_Z017);
      t_errorfieldval(errorCount) := TRIM(v_zkanaddr02);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/
    -- 9) CLTSEX valid in Smart T-table T3582
    -- Read T-table T3582
    IF NOT
        (itemexist.exists(TRIM(C_T3582) || TRIM(obj_cur_Stagetab.cltsex) || 9)) THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_G979;
      t_errorfield(errorCount) := 'CLTSEX';
      t_errormsg(errorCount) := o_errortext(C_G979);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.cltsex);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 10) OCCPCODE valid in T-Table T3644
    -- Read T-Table T3644
    IF (TRIM(obj_cur_Stagetab.occpcode) IS NOT NULL) THEN
      -- CP4
      IF NOT
          (itemexist.exists(TRIM(C_T3644) || TRIM(obj_cur_Stagetab.occpcode) || 9)) THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_F992;
        t_errorfield(errorCount) := 'OCCPCODE';
        t_errormsg(errorCount) := o_errortext(C_F992);
        t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.occpcode);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF; -- CP4
    -- IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(n_cltdob) || 9)) THEN
    IF TRIM(obj_cur_Stagetab.cltdob) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdob';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.cltdob);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --CLTPCODE validation PA
    IF TRIM(obj_cur_Stagetab.CLTPCODE) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E186;
      t_errorfield(errorCount) := 'CLTPCODE';
      t_errormsg(errorCount) := o_errortext(C_E186);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.CLTPCODE);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    --CLTPHONE01 validation PA
    IF TRIM(obj_cur_Stagetab.CLTPHONE01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E186;
      t_errorfield(errorCount) := 'CLTPHONE01';
      t_errormsg(errorCount) := o_errortext(C_E186);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.CLTPHONE01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    --validation End
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
  
    IF v_isAnyError = 'N' AND i_zprvaldYN = 'N' THEN
    
    obj_nypf :=  getnypf(TRIM(obj_cur_Stagetab.refnum));
                v_clntnum  := obj_nypf.zigvalue;
    If(obj_nypf.CLNTSTAS='EX')then
    --Insert Value Migration Registry Table
    
      obj_pazdclpf.RECSTATUS := obj_nypf.CLNTSTAS;
      obj_pazdclpf.PREFIX    := C_PREFIX;
      obj_pazdclpf.ZENTITY   := obj_cur_Stagetab.refnum;
      obj_pazdclpf.ZIGVALUE  := v_clntnum;
      obj_pazdclpf.JOBNUM    := i_scheduleNumber;
      obj_pazdclpf.JOBNAME   := i_scheduleName;
    
      insert into Jd1dta.VIEW_DM_PAZDCLPF values obj_pazdclpf;
    else
      --Insert Value Migration Registry Table
    
      obj_pazdclpf.RECSTATUS := obj_nypf.CLNTSTAS;
      obj_pazdclpf.PREFIX    := C_PREFIX;
      obj_pazdclpf.ZENTITY   := obj_cur_Stagetab.refnum;
      obj_pazdclpf.ZIGVALUE  := v_clntnum;
      obj_pazdclpf.JOBNUM    := i_scheduleNumber;
      obj_pazdclpf.JOBNAME   := i_scheduleName;
    
      insert into Jd1dta.VIEW_DM_PAZDCLPF values obj_pazdclpf;
 
      ------------Insert into CLNTPF : START------------------------
      obj_clntpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
      obj_clntpf.CLNTCOY       := o_defaultvalues('CLNTCOY');
      obj_clntpf.CLNTNUM       := v_clntnum;
      obj_clntpf.IDEXPIREDATE  := C_IDEXPIREDATE;
      obj_clntpf.ISPERMANENTID := C_ISPERMANENTID;
      obj_clntpf.TRANID        := v_TRANID;
      obj_clntpf.VALIDFLAG     := o_defaultvalues('VALIDFLAG');
      obj_clntpf.CLTTYPE       := o_defaultvalues('CLTTYPE');
      obj_clntpf.SECUITYNO     := C_SECUITYNO;
      obj_clntpf.PAYROLLNO     := C_PAYROLLNO;
      obj_clntpf.SURNAME       := obj_cur_Stagetab.lsurname;
      obj_clntpf.GIVNAME       := obj_cur_Stagetab.lGIVNAME;
      obj_clntpf.SALUT         := C_SALUT;
      obj_clntpf.INITIALS      := SUBSTR(obj_cur_Stagetab.lgivname, 1, 1);
      obj_clntpf.CLTSEX        := obj_cur_Stagetab.CLTSEX;
      obj_clntpf.CLTADDR01     := obj_cur_Stagetab.CLTADDR01;
      obj_clntpf.CLTADDR02     := obj_cur_Stagetab.CLTADDR02;
      obj_clntpf.CLTADDR03     := obj_cur_Stagetab.CLTADDR03;
      obj_clntpf.CLTADDR04     := C_CLTADDR04;
      obj_clntpf.CLTADDR05     := C_CLTADDR05;
      obj_clntpf.CLTPCODE      := obj_cur_Stagetab.CLTPCODE;
      obj_clntpf.CTRYCODE      := o_defaultvalues('CTRYCODE');
      obj_clntpf.MAILING       := C_MAILING;
      obj_clntpf.DIRMAIL       := C_DIRMAIL;
      obj_clntpf.ADDRTYPE      := obj_cur_Stagetab.ADDRTYPE;
      if (trim(obj_cur_Stagetab.CLTPHONE01) is not null) then
        obj_clntpf.CLTPHONE01 := obj_cur_Stagetab.CLTPHONE01;
      
      else
        obj_clntpf.CLTPHONE01 := '                ';
      
      end if;
    
      obj_clntpf.CLTPHONE02 := obj_cur_Stagetab.CLTPHONE02;
      obj_clntpf.VIP        := C_VIP;
      if (trim(obj_cur_Stagetab.Occpcode) is not null) then
        obj_clntpf.OCCPCODE := obj_cur_Stagetab.OCCPCODE;
      else
        obj_clntpf.OCCPCODE := '    ';
      end if;
    
      obj_clntpf.SERVBRH    := o_defaultvalues('SERVBRH');
      obj_clntpf.STATCODE   := C_STATCODE;
      obj_clntpf.CLTDOB     := obj_cur_Stagetab.CLTDOB;
      obj_clntpf.SOE        := C_SOE;
      obj_clntpf.DOCNO      := C_DOCNO;
      obj_clntpf.CLTDOD     := o_defaultvalues('CLTDOD');
      obj_clntpf.CLTSTAT    := o_defaultvalues('CLTSTAT');
      obj_clntpf.CLTMCHG    := o_defaultvalues('CLTMCHG');
      obj_clntpf.MIDDL01    := C_MIDDL01;
      obj_clntpf.MIDDL02    := C_MIDDL02;
      obj_clntpf.MARRYD     := C_MARRYD;
      obj_clntpf.TLXNO      := C_TLXNO;
      obj_clntpf.FAXNO      := C_FAXNO;
      obj_clntpf.TGRAM      := C_TGRAM;
      obj_clntpf.BIRTHP     := C_BIRTHP;
      obj_clntpf.SALUTL     := C_SALUTL;
      obj_clntpf.ROLEFLAG01 := C_ROLEFLAG01;
      obj_clntpf.ROLEFLAG02 := C_ROLEFLAG02;
      obj_clntpf.ROLEFLAG03 := C_ROLEFLAG03;
      obj_clntpf.ROLEFLAG04 := C_ROLEFLAG04;
      obj_clntpf.ROLEFLAG05 := o_defaultvalues('ROLEFLAG05');
      obj_clntpf.ROLEFLAG06 := C_ROLEFLAG06;
      obj_clntpf.ROLEFLAG07 := C_ROLEFLAG07;
      obj_clntpf.ROLEFLAG08 := C_ROLEFLAG08;
      obj_clntpf.ROLEFLAG09 := C_ROLEFLAG09;
      obj_clntpf.ROLEFLAG10 := C_ROLEFLAG10;
      obj_clntpf.ROLEFLAG11 := C_ROLEFLAG11;
      obj_clntpf.ROLEFLAG12 := C_ROLEFLAG12;
      obj_clntpf.ROLEFLAG13 := C_ROLEFLAG13;
      obj_clntpf.ROLEFLAG14 := o_defaultvalues('ROLEFLAG14');
      obj_clntpf.ROLEFLAG15 := C_ROLEFLAG15;
      obj_clntpf.ROLEFLAG16 := C_ROLEFLAG16;
      obj_clntpf.ROLEFLAG17 := C_ROLEFLAG17;
      obj_clntpf.ROLEFLAG18 := o_defaultvalues('ROLEFLAG18');
      obj_clntpf.ROLEFLAG19 := C_ROLEFLAG19;
      obj_clntpf.ROLEFLAG20 := C_ROLEFLAG20;
      obj_clntpf.ROLEFLAG21 := C_ROLEFLAG21;
      obj_clntpf.ROLEFLAG22 := C_ROLEFLAG22;
      obj_clntpf.ROLEFLAG23 := C_ROLEFLAG23;
      obj_clntpf.ROLEFLAG24 := C_ROLEFLAG24;
      obj_clntpf.ROLEFLAG25 := C_ROLEFLAG25;
      obj_clntpf.ROLEFLAG26 := C_ROLEFLAG26;
      obj_clntpf.ROLEFLAG27 := C_ROLEFLAG27;
      obj_clntpf.ROLEFLAG28 := C_ROLEFLAG28;
      obj_clntpf.ROLEFLAG29 := C_ROLEFLAG29;
      obj_clntpf.ROLEFLAG30 := C_ROLEFLAG30;
      obj_clntpf.ROLEFLAG31 := C_ROLEFLAG31;
      obj_clntpf.ROLEFLAG32 := C_ROLEFLAG32;
      obj_clntpf.ROLEFLAG33 := C_ROLEFLAG33;
      obj_clntpf.ROLEFLAG34 := C_ROLEFLAG34;
      obj_clntpf.ROLEFLAG35 := C_ROLEFLAG35;
      obj_clntpf.STCA       := C_STCA;
      obj_clntpf.STCB       := C_STCB;
      obj_clntpf.STCC       := C_STCC;
      obj_clntpf.STCD       := C_STCD;
      obj_clntpf.STCE       := C_STCE;
      obj_clntpf.PROCFLAG   := C_PROCFLAG;
      obj_clntpf.TERMID     := trim(i_vrcmTermid);
      obj_clntpf.USER_T     := C_USER_T;
      obj_clntpf.TRDT       := TO_CHAR(sysdate, 'YYMMDD');
      obj_clntpf.TRTM       := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
      obj_clntpf.SNDXCDE    := C_SNDXCDE;
      obj_clntpf.NATLTY     := C_NATLTY;
      obj_clntpf.FAO        := C_FAO;
      obj_clntpf.CLTIND     := o_defaultvalues('CLTIND');
      obj_clntpf.STATE      := C_STATE;
      obj_clntpf.LANGUAGE   := o_defaultvalues('LANGUAGE');
      obj_clntpf.CAPITAL    := o_defaultvalues('CAPITAL');
      obj_clntpf.CTRYORIG   := C_CTRYORIG;
      obj_clntpf.ECACT      := C_ECACT;
      obj_clntpf.ETHORIG    := o_defaultvalues('ETHORIG');
      obj_clntpf.SRDATE     := o_defaultvalues('SRDATE');
      obj_clntpf.STAFFNO    := C_STAFFNO;
      obj_clntpf.LSURNAME   := obj_cur_Stagetab.LSURNAME;
      obj_clntpf.LGIVNAME   := obj_cur_Stagetab.LGIVNAME;
      obj_clntpf.TAXFLAG    := o_defaultvalues('TAXFLAG');
    
      obj_clntpf.USRPRF         := i_usrprf;
      obj_clntpf.JOBNM          := i_scheduleName;
      obj_clntpf.DATIME         := sysdate;
      obj_clntpf.IDTYPE         := C_IDTYPE;
      obj_clntpf.Z1GSTREGN      := C_Z1GSTREGN;
      obj_clntpf.Z1GSTREGD      := o_defaultvalues('Z1GSTREGD');
      obj_clntpf.KANJISURNAME   := C_KANJISURNAME;
      obj_clntpf.KANJIGIVNAME   := C_KANJIGIVNAME;
      obj_clntpf.KANJICLTADDR01 := C_KANJICLTADDR01;
      obj_clntpf.KANJICLTADDR02 := C_KANJICLTADDR02;
      obj_clntpf.KANJICLTADDR03 := C_KANJICLTADDR03;
      obj_clntpf.KANJICLTADDR04 := C_KANJICLTADDR04;
      obj_clntpf.KANJICLTADDR05 := C_KANJICLTADDR05;
      obj_clntpf.EXCEP          := o_defaultvalues('EXCEP');
      obj_clntpf.ZKANAGNM       := obj_cur_Stagetab.Zkanagivname;
      obj_clntpf.ZKANASNM       := obj_cur_Stagetab.Zkanasurname;
      obj_clntpf.ZKANADDR01     := obj_cur_Stagetab.ZKANADDR01;
      obj_clntpf.ZKANADDR02     := obj_cur_Stagetab.ZKANADDR02;
      obj_clntpf.ZKANADDR03     := C_ZKANADDR03;
      obj_clntpf.ZKANADDR04     := C_ZKANADDR04;
      obj_clntpf.ZKANADDR05     := C_ZKANADDR05;
      obj_clntpf.ZADDRCD        := obj_cur_Stagetab.MINADDRCD;
      obj_clntpf.ABUSNUM        := C_ABUSNUM;
      obj_clntpf.BRANCHID       := C_BRANCHID;
      obj_clntpf.ZKANASNMNOR    := obj_cur_Stagetab.ZKANASNMNOR;
      obj_clntpf.ZKANAGNMNOR    := obj_cur_Stagetab.ZKANAGNMNOR;
      obj_clntpf.TELECTRYCODE   := C_TELECTRYCODE;
      obj_clntpf.TELECTRYCODE1  := C_TELECTRYCODE1;
      obj_clntpf.ZDLIND         := C_ZDLIND;
      obj_clntpf.DIRMKTMTD      := C_DIRMKTMTD;
      obj_clntpf.PREFCONMTD     := C_PREFCONMTD;
      if (trim(obj_cur_Stagetab.ZOCCDSC) is not null) then
        obj_clntpf.ZOCCDSC := obj_cur_Stagetab.ZOCCDSC;
      
      else
        obj_clntpf.ZOCCDSC := '                                                  ';
      
      end if;
    
      IF (pitemexist.exists(trim(obj_cur_Stagetab.Occpcode))) THEN
        --Need to check this logic
        v_occpclass := pitemexist(trim(obj_cur_Stagetab.Occpcode)).occclass;
      else
        v_occpclass := '  ';
      
      END IF;
    
      obj_clntpf.OCCPCLAS      := v_occpclass;
      obj_clntpf.ZWORKPLCE     := obj_cur_Stagetab.ZWORKPLCE;
      obj_clntpf.WORKUNIT      := C_WORKUNIT;
      obj_clntpf.CLNTSTATECD   := C_CLNTSTATECD;
      obj_clntpf.FUNDADMINFLAG := C_FUNDADMINFLAG;
      obj_clntpf.PROVINCE      := C_PROVINCE;
      obj_clntpf.SEQNO         := C_SEQNO;
    
      --------------------Insert into CLNTPF : END-------------------
    
      INSERT INTO CLNTPF VALUES obj_clntpf;
      -- insert in  IG Jd1dta.CLNTPF table end-
      -- insert in  IG Jd1dta.CLEXPF table Start-
      select SEQ_CLEXPF.nextval into v_pkValue from dual;
      obj_clexpf.UNIQUE_NUMBER := v_pkValue;
      obj_clexpf.CLNTPFX       := o_defaultvalues('CLNTPFX');
      obj_clexpf.CLNTCOY       := o_defaultvalues('CLNTCOY');
      obj_clexpf.CLNTNUM       := v_CLNTNUM;
      obj_clexpf.RDIDTELNO     := C_RDIDTELNO;
      obj_clexpf.RMBLPHONE     := obj_clntpf.cltphone01;
      obj_clexpf.RPAGER        := C_RPAGER;
      obj_clexpf.FAXNO         := C_FAXNO;
      obj_clexpf.RINTERNET     := C_RINTERNET;
      obj_clexpf.RTAXIDNUM     := C_RTAXIDNUM;
      obj_clexpf.RSTAFLAG      := C_RSTAFLAG;
      obj_clexpf.SPLINDIC      := C_SPLINDIC;
      obj_clexpf.ZSPECIND      := C_ZSPECIND;
      obj_clexpf.OLDIDNO       := C_OLDIDNO;
      obj_clexpf.JOBNM         := i_scheduleName;
      obj_clexpf.USRPRF        := i_usrprf;
      obj_clexpf.DATIME        := sysdate;
      obj_clexpf.VALIDFLAG     := o_defaultvalues('VALIDFLAG');
      obj_clexpf.OTHIDNO       := C_OTHIDNO;
      obj_clexpf.OTHIDTYPE     := C_OTHIDTYPE;
      obj_clexpf.AMLSTATUS     := C_AMLSTATUS;
      obj_clexpf.ZDMAILTO01    := C_ZDMAILTO01;
      obj_clexpf.ZDMAILTO02    := C_ZDMAILTO02;
      obj_clexpf.ZDMAILCC01    := C_ZDMAILCC01;
      obj_clexpf.ZDMAILCC02    := C_ZDMAILCC02;
      obj_clexpf.ZDMAILCC03    := C_ZDMAILCC03;
      obj_clexpf.ZDMAILCC04    := C_ZDMAILCC04;
      obj_clexpf.ZDMAILCC05    := C_ZDMAILCC05;
      obj_clexpf.ZDMAILCC06    := C_ZDMAILCC06;
      obj_clexpf.ZDMAILCC07    := C_ZDMAILCC07;
      obj_clexpf.RINTERNET2    := C_RINTERNET2;
      obj_clexpf.TELECTRYCODE  := C_TELECTRYCODE;
      obj_clexpf.ZFATHERNAME   := C_ZFATHERNAME;
    
      INSERT INTO CLEXPF VALUES obj_clexpf;
        end if;

    END IF;
  
  END LOOP;

  dbms_output.put_line('End execution of BQ9Q6_CL02_PERCLT, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);
  CLOSE Cur_StageTable;
exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'BQ9Q6_CL02_PERCLT : ' || i_scheduleName || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);
  
    commit;
    raise;
END BQ9Q6_CL02_PERCLT;
