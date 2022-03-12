CREATE OR REPLACE PROCEDURE "BQ9TV_CL02_2_CLNTHIST"(i_scheduleName   IN VARCHAR2,
                                                    i_scheduleNumber IN VARCHAR2,
                                                    i_zprvaldYN      IN VARCHAR2,
                                                    i_company        IN VARCHAR2,
                                                    i_usrprf         IN VARCHAR2,
                                                    i_branch         IN VARCHAR2,
                                                    i_transCode      IN VARCHAR2,
                                                    i_vrcmTermid     IN VARCHAR2)
  AUTHID current_user AS

  /**************************   *************************************************************************
  * Amenment History: CL02 Client History
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   CH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * APR02    JDB  CH1   PA New implementation
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
  v_refnum        TITDMGCLTRNHIS.REFNUM@DMSTAGEDBLINK%type;
  v_temprefnum    TITDMGCLTRNHIS.refnum@DMSTAGEDBLINK%type default ' ';
  isDateValid     VARCHAR2(20 CHAR);
  v_unq_zdch      PAZDCHPF.RECIDXCLNTHIS%type;
  v_incrVersion   NUMBER(2) DEFAULT 0;
  v_occpclass     varchar2(2);

  ----------------Local Variables:END------------- 
  ----------------CONSTANT:START------------- 
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLHS', i_company);

  C_BQ9TV CONSTANT VARCHAR2(5) := 'BQ9TV';
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
  C_D009  CONSTANT VARCHAR2(4) := 'D009';
  C_T3645 CONSTANT VARCHAR2(5) := 'T3645';
  C_T2241 CONSTANT VARCHAR2(5) := 'T2241';
  C_TR393 CONSTANT VARCHAR2(5) := 'TR393';
  C_T3644 CONSTANT VARCHAR2(5) := 'T3644';
  C_T3582 CONSTANT VARCHAR2(5) := 'T3582';
  C_DTSM  CONSTANT VARCHAR2(4) := 'DTSM';
  C_Z130  CONSTANT VARCHAR2(4) := 'RGKG';
  C_E186  CONSTANT VARCHAR2(4) := 'E186';
  /*Field must be entered*/

  C_N01            CONSTANT VARCHAR2(3) := 'N01'; --Change of Customer Address
  C_N02            CONSTANT VARCHAR2(3) := 'N02'; --Change/correction of customer’s name
  C_P09            CONSTANT VARCHAR2(3) := 'P09'; --Correction of DOB/gender
  C_NULL           CONSTANT VARCHAR2(3) := null;
  C_ZERO           constant number := 0;
  C_ONESPACE       CONSTANT VARCHAR2(1) := ' ';
  C_Y              CONSTANT VARCHAR2(1) := 'Y';
  C_N              CONSTANT VARCHAR2(1) := 'N';
  C_IDEXPIREDATE   CONSTANT NUMBER(8, 0) := null;
  C_ISPERMANENTID  CONSTANT CHAR(1 CHAR) := null;
  C_SECUITYNO      CONSTANT CHAR(24 CHAR) := '                        ';
  C_PAYROLLNO      CONSTANT CHAR(10 CHAR) := '          ';
  C_SALUT          CONSTANT CHAR(6 CHAR) := null;
  C_CLTADDR04      CONSTANT NCHAR(50 CHAR) := '                                                  ';
  C_CLTADDR05      CONSTANT NCHAR(50 CHAR) := '                                                  ';
  C_MAILING        CONSTANT CHAR(1 CHAR) := ' ';
  C_DIRMAIL        CONSTANT CHAR(1 CHAR) := ' ';
  C_VIP            CONSTANT CHAR(1 CHAR) := ' ';
  C_STATCODE       CONSTANT CHAR(2 CHAR) := '  ';
  C_SOE            CONSTANT CHAR(10 CHAR) := '          ';
  C_DOCNO          CONSTANT CHAR(8 CHAR) := '        ';
  C_MIDDL01        CONSTANT CHAR(20 CHAR) := '                    ';
  C_MIDDL02        CONSTANT CHAR(20 CHAR) := '                    ';
  C_MARRYD         CONSTANT CHAR(1 CHAR) := ' ';
  C_TLXNO          CONSTANT CHAR(16 CHAR) := '                ';
  C_FAXNO          CONSTANT CHAR(16 CHAR) := '                ';
  C_TGRAM          CONSTANT CHAR(16 CHAR) := '                ';
  C_BIRTHP         CONSTANT CHAR(20 CHAR) := '                    ';
  C_SALUTL         CONSTANT CHAR(8 CHAR) := '        ';
  C_ROLEFLAG01     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG02     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG03     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG04     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG06     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG07     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG08     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG09     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG10     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG11     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG12     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG13     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG15     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG16     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG17     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG19     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG20     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG21     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG22     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG23     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG24     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG25     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG26     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG27     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG28     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG29     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG30     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG31     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG32     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG33     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG34     CONSTANT CHAR(1 CHAR) := ' ';
  C_ROLEFLAG35     CONSTANT CHAR(1 CHAR) := ' ';
  C_STCA           CONSTANT CHAR(3 CHAR) := '   ';
  C_STCB           CONSTANT CHAR(3 CHAR) := '   ';
  C_STCC           CONSTANT CHAR(3 CHAR) := '   ';
  C_STCD           CONSTANT CHAR(3 CHAR) := '   ';
  C_STCE           CONSTANT CHAR(3 CHAR) := '   ';
  C_PROCFLAG       CONSTANT CHAR(2 CHAR) := null;
  C_TERMID         CONSTANT CHAR(4 CHAR) := null;
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
  checkdupl       pkg_common_dmch.cpduplicate;
  pitemexist      pkg_common_dmcp.itemschec;

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
  getzigvalue    pkg_common_dmch.zigvaluetype;

  ---------------Common function end-----------
  ------IG table obj start---
  obj_pazdclpf         PAZDCLPF%rowtype;
  obj_zclnpf           VIEW_DM_ZCLNPF%rowtype;
  obj_audit_clntpf     audit_clntpf%rowtype;
  obj_audit_clnt       audit_clnt%rowtype;
  obj_audit_clexp      audit_clexpf%rowtype;
  obj_versionpf        VERSIONPF%rowtype;
  obj_VIEW_DM_PAZDCHPF VIEW_DM_PAZDCHPF%rowtype;
  ------IG table obj End---
  /* CURSOR personalclient_cursor IS
    SELECT *
      FROM dmigtitdmgcltrnhis
     order by LPAD(REFNUM, 8, '0') asc, ZSEQNO asc;
  obj_cur_Stagetab personalclient_cursor%rowtype;*/
  CURSOR personalclient_cursor IS
    select *
      from (SELECT ROW_NUMBER() OVER(PARTITION BY refnum, effdate
                   
                   ORDER BY effdate, zseqno DESC) row_num,
                   
                   RECIDXCLHIS,
                   REFNUM,
                   ZSEQNO,
                   EFFDATE,
                   LSURNAME,
                   LGIVNAME,
                   ZKANAGIVNAME,
                   ZKANASURNAME,
                   ZKANASNMNOR,
                   ZKANAGNMNOR,
                   CLTPCODE,
                   CLTADDR01,
                   CLTADDR02,
                   CLTADDR03,
                   ZKANADDR01,
                   ZKANADDR02,
                   CLTSEX,
                   ADDRTYPE,
                   CLTPHONE01,
                   CLTPHONE02,
                   OCCPCODE,
                   CLTDOB,
                   ZOCCDSC,
                   ZWORKPLCE,
                   ZALTRCDE01,
                   TRANSHIST,
                   ZENDCDE,
                   CLNTROLEFLG,
                   POSTALCD,
                   MINADDRCD
            
              from (select *
                      from ((select *
                               from Jd1dta.DMIGTITDMGCLTRNHIS
                              where transhist = '1') A left outer join
                            (select POSTALCD, min(ADDRCD) as MINADDRCD
                               from Jd1dta.zadrpf
                              group by POSTALCD) POST on
                            trim(a.cltpcode) = POST.POSTALCD)))
     where row_num = 1
     order by LPAD(REFNUM, 8, '0') asc, ZSEQNO asc;
  obj_cur_Stagetab personalclient_cursor%rowtype;
  obj_client_old   personalclient_cursor%rowtype;

BEGIN
  ---------Common Function:Calling------------  
  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9TV,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCP',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCP',
                                        o_errortext   => o_errortext);
  pkg_common_dmch.checkcpdup(checkdupl => checkdupl);
  pkg_common_dmch.getzigvalue(getzigvalue => getzigvalue);
  pkg_common_dmcp.getitemvalue(itemexist => pitemexist);

  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);

  ---------Common Function:Calling------------
  -- Open Cursor
  OPEN personalclient_cursor;
  <<skipRecord>>
  LOOP
    FETCH personalclient_cursor
      INTO obj_cur_Stagetab;
    EXIT WHEN personalclient_cursor%notfound;
    v_refnum := obj_cur_Stagetab.refnum;
    IF (TRIM(v_refnum) <> TRIM(v_temprefnum)) THEN
      obj_client_old := null;
    END IF;
  
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
  
    ----Validation:Start
  
    ---1. Refnum
    IF TRIM(v_refnum) IS NULL THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_H036;
      i_zdoe_info.i_errormsg01     := o_errortext(C_H036);
      i_zdoe_info.i_errorfield01   := 'Refnum';
      i_zdoe_info.i_fieldvalue01   := TRIM(v_refnum);
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
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
        v_isAnyError                 := 'Y';
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z098;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
        i_zdoe_info.i_errorfield01   := 'Refnum';
        i_zdoe_info.i_fieldvalue01   := TRIM(v_refnum);
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord;
      END IF;
    END IF;
  
    --LSURNAME  ---As discussed with patrice this validation will be always true so we are removing
    /*  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lsurname) || 9)) THEN
    v_isAnyError := 'Y';
    errorCount := errorCount + 1;
    t_ercode(errorCount) := C_Z020;
    t_errorfield(errorCount) := 'lsurname';
    t_errormsg(errorCount) := o_errortext(C_Z020);
    t_errorfieldval(errorCount) := TRIM(v_lsurname);
    t_errorprogram(errorCount) := i_scheduleName;
    IF errorCount >= 5 THEN
      GOTO insertzdoe;
    END IF;*/
  
    --Kanji character validation  Japanees charater not in TSD
    /*isValidName := VALIDATE_JAPANESE_TEXT(v_lsurname);
    IF isValidName = 'Invalid' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_lsurname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/
  
    -- validate lsurname
    IF TRIM(obj_cur_Stagetab.lsurname) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E186;
      t_errorfield(errorCount) := 'lsurname';
      t_errormsg(errorCount) := o_errortext(C_E186);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.lsurname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    --As discussed with patrice this validation will be always true so we are removing
    /* IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_lgivname) || 9)) THEN
    v_isAnyError := 'Y';
    errorCount := errorCount + 1;
    t_ercode(errorCount) := C_Z020;
    t_errorfield(errorCount) := 'lgivname';
    t_errormsg(errorCount) := o_errortext(C_Z020);
    t_errorfieldval(errorCount) := TRIM(v_lgivname);
    t_errorprogram(errorCount) := i_scheduleName;
    IF errorCount >= 5 THEN
      GOTO insertzdoe;
    END IF;*/
  
    /*     --Kanji character validation  Japanees charater not in TSD
    isValidName := VALIDATE_JAPANESE_TEXT(v_lgivname);
    IF isValidName = 'Invalid' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'lgivname';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_lgivname);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    
    END IF;*/
  
    -- validate lsurname
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
    -- CLTADDR01 ( Have Doubt for Addtess Rule in T2241vv--- --As discussed with patrice this validation will be always true so we are removing
    /* IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(v_cltaddr01) || 9)) THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'CLTADDR01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    ELSE
    isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr01);
    IF isValidName = 'Invalid' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z073;
      t_errorfield(errorCount) := 'cltaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z073);
      t_errorfieldval(errorCount) := TRIM(v_cltaddr01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/
  
    IF TRIM(obj_cur_Stagetab.cltaddr01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z016;
      t_errorfield(errorCount) := 'cltaddr01';
      t_errormsg(errorCount) := o_errortext(C_Z016);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.cltaddr01);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
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
    /*  ELSE
      --Kanji character validation
      isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr02);
      IF isValidName = 'Invalid' THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z073;
        t_errorfield(errorCount) := 'cltaddr02';
        t_errormsg(errorCount) := o_errortext(C_Z073);
        t_errorfieldval(errorCount) := TRIM(v_cltaddr02);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;*/
    -- 6)CLTADDR03 is Null
    --    IF TRIM(v_cltaddr03) IS NULL THEN
    --      v_isAnyError := 'Y';
    --      errorCount := errorCount + 1;
    --      t_ercode(errorCount) := C_Z016;
    --      t_errorfield(errorCount) := 'cltaddr03';
    --      t_errormsg(errorCount) := o_errortext(C_Z016);
    --      t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
    --      t_errorprogram(errorCount) := i_scheduleName;
    --      IF errorCount >= 5 THEN
    --        GOTO insertzdoe;
    --      END IF;
    --    END IF;
    /*ELSE
      --Kanji character validation
      isValidName := VALIDATE_JAPANESE_TEXT(v_cltaddr03);
      IF isValidName = 'Invalid' THEN
        v_isAnyError := 'Y';
        errorCount := errorCount + 1;
        t_ercode(errorCount) := C_Z073;
        t_errorfield(errorCount) := 'cltaddr03';
        t_errormsg(errorCount) := o_errortext(C_Z073);
        t_errorfieldval(errorCount) := TRIM(v_cltaddr03);
        t_errorprogram(errorCount) := i_scheduleName;
        IF errorCount >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;*/
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
    --SIT changes removed in requirement
    /* IF TRIM(v_zkanaddr02) IS NULL THEN
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
    /*  IF NOT (itemexist.exists(TRIM(C_TR393) || TRIM(n_cltdob) || 9)) THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdob';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(n_cltdob);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;*/
  
    isDateValid := VALIDATE_DATE(obj_cur_Stagetab.cltdob);
    IF isDateValid <> 'OK' THEN
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
  
    isDateValid := VALIDATE_DATE(obj_cur_Stagetab.effdate);
    IF isDateValid <> 'OK' THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z130;
      t_errorfield(errorCount) := 'effdate';
      t_errormsg(errorCount) := o_errortext(C_Z130);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.effdate);
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
    -- Updateing IG- Tables And Migration Registry table with filter data
    -- Updating S indicator
    IF v_isAnyError = 'N' AND i_zprvaldYN = 'N' THEN
    
      IF NOT (getzigvalue.exists(TRIM(v_refnum))) THEN
        CONTINUE skipRecord;
      ELSE
        v_clntnum := getzigvalue(TRIM(v_refnum));
      END IF;
    
      IF (obj_cur_Stagetab.Zseqno = 0) THEN
        v_incrVersion := 1;
      ELSE
        v_incrVersion := v_incrVersion + 1;
      END IF;
    
      SELECT SEQ_ZCLN_ZDCH.nextval INTO v_unq_zdch FROM dual;
      --Insert Value Migration Registry Table:start----
    
      obj_VIEW_DM_PAZDCHPF.RECSTATUS := 'OK';
      obj_VIEW_DM_PAZDCHPF.ZENTITY   := obj_cur_Stagetab.refnum;
      obj_VIEW_DM_PAZDCHPF.ZIGVALUE  := v_clntnum;
      obj_VIEW_DM_PAZDCHPF.EFFDATE   := obj_cur_Stagetab.Effdate;
      obj_VIEW_DM_PAZDCHPF.ZSEQNO    := obj_cur_Stagetab.Zseqno;
      obj_VIEW_DM_PAZDCHPF.ZCLNUNINO := '';
      obj_VIEW_DM_PAZDCHPF.ZCLREL    := obj_cur_Stagetab.Clntroleflg;
      obj_VIEW_DM_PAZDCHPF.JOBNUM    := i_scheduleNumber;
      obj_VIEW_DM_PAZDCHPF.JOBNAME   := i_scheduleName;
    
      insert into Jd1dta.VIEW_DM_PAZDCHPF values obj_VIEW_DM_PAZDCHPF;
    
      --Insert Value Migration Registry Table:end----
    
      ---New business 
      IF (obj_cur_Stagetab.Zseqno = C_ZERO) THEN
        ------------Insert into Audit_CLNTPF : Start------------------------
        obj_audit_clntpf. oldclntnum := v_clntnum;
        obj_audit_clntpf. oldclntpfx := C_NULL;
        obj_audit_clntpf. oldclntcoy := C_NULL;
        obj_audit_clntpf. oldtranid := C_NULL;
        obj_audit_clntpf. oldvalidflag := C_NULL;
        obj_audit_clntpf. oldclttype := C_NULL;
        obj_audit_clntpf. oldsecuityno := C_NULL;
        obj_audit_clntpf. oldpayrollno := C_NULL;
        obj_audit_clntpf. oldsurname := C_NULL;
        obj_audit_clntpf. oldgivname := C_NULL;
        obj_audit_clntpf. oldsalut := C_NULL;
        obj_audit_clntpf. oldinitials := C_NULL;
        obj_audit_clntpf. oldcltsex := C_NULL;
        obj_audit_clntpf. oldcltaddr01 := C_NULL;
        obj_audit_clntpf. oldcltaddr02 := C_NULL;
        obj_audit_clntpf. oldcltaddr03 := C_NULL;
        obj_audit_clntpf. oldcltaddr04 := C_NULL;
        obj_audit_clntpf. oldcltaddr05 := C_NULL;
        obj_audit_clntpf. oldcltpcode := C_NULL;
        obj_audit_clntpf. oldctrycode := C_NULL;
        obj_audit_clntpf. oldmailing := C_NULL;
        obj_audit_clntpf. olddirmail := C_NULL;
        obj_audit_clntpf. oldaddrtype := C_NULL;
        obj_audit_clntpf. oldcltphone01 := C_NULL;
        obj_audit_clntpf. oldcltphone02 := C_NULL;
        obj_audit_clntpf. oldvip := C_NULL;
        obj_audit_clntpf. oldoccpcode := C_NULL;
        obj_audit_clntpf. oldservbrh := C_NULL;
        obj_audit_clntpf. oldstatcode := C_NULL;
        obj_audit_clntpf. oldcltdob := C_ZERO;
        obj_audit_clntpf. oldsoe := C_NULL;
        obj_audit_clntpf. olddocno := C_NULL;
        obj_audit_clntpf. oldcltdod := C_ZERO;
        obj_audit_clntpf. oldcltstat := C_NULL;
        obj_audit_clntpf. oldcltmchg := C_NULL;
        obj_audit_clntpf. oldmiddl01 := C_NULL;
        obj_audit_clntpf. oldmiddl02 := C_NULL;
        obj_audit_clntpf. oldmarryd := C_NULL;
        obj_audit_clntpf. oldtlxno := C_NULL;
        obj_audit_clntpf. oldfaxno := C_NULL;
        obj_audit_clntpf. oldtgram := C_NULL;
        obj_audit_clntpf. oldbirthp := C_NULL;
        obj_audit_clntpf. oldsalutl := C_NULL;
        obj_audit_clntpf. oldroleflag01 := C_NULL;
        obj_audit_clntpf. oldroleflag02 := C_NULL;
        obj_audit_clntpf. oldroleflag03 := C_NULL;
        obj_audit_clntpf. oldroleflag04 := C_NULL;
        obj_audit_clntpf. oldroleflag05 := C_NULL;
        obj_audit_clntpf. oldroleflag06 := C_NULL;
        obj_audit_clntpf. oldroleflag07 := C_NULL;
        obj_audit_clntpf. oldroleflag08 := C_NULL;
        obj_audit_clntpf. oldroleflag09 := C_NULL;
        obj_audit_clntpf. oldroleflag10 := C_NULL;
        obj_audit_clntpf. oldroleflag11 := C_NULL;
        obj_audit_clntpf. oldroleflag12 := C_NULL;
        obj_audit_clntpf. oldroleflag13 := C_NULL;
        obj_audit_clntpf. oldroleflag14 := C_NULL;
        obj_audit_clntpf. oldroleflag15 := C_NULL;
        obj_audit_clntpf. oldroleflag16 := C_NULL;
        obj_audit_clntpf. oldroleflag17 := C_NULL;
        obj_audit_clntpf. oldroleflag18 := C_NULL;
        obj_audit_clntpf. oldroleflag19 := C_NULL;
        obj_audit_clntpf. oldroleflag20 := C_NULL;
        obj_audit_clntpf. oldroleflag21 := C_NULL;
        obj_audit_clntpf. oldroleflag22 := C_NULL;
        obj_audit_clntpf. oldroleflag23 := C_NULL;
        obj_audit_clntpf. oldroleflag24 := C_NULL;
        obj_audit_clntpf. oldroleflag25 := C_NULL;
        obj_audit_clntpf. oldroleflag26 := C_NULL;
        obj_audit_clntpf. oldroleflag27 := C_NULL;
        obj_audit_clntpf. oldroleflag28 := C_NULL;
        obj_audit_clntpf. oldroleflag29 := C_NULL;
        obj_audit_clntpf. oldroleflag30 := C_NULL;
        obj_audit_clntpf. oldroleflag31 := C_NULL;
        obj_audit_clntpf. oldroleflag32 := C_NULL;
        obj_audit_clntpf. oldroleflag33 := C_NULL;
        obj_audit_clntpf. oldroleflag34 := C_NULL;
        obj_audit_clntpf. oldroleflag35 := C_NULL;
        obj_audit_clntpf. oldstca := C_NULL;
        obj_audit_clntpf. oldstcb := C_NULL;
        obj_audit_clntpf. oldstcc := C_NULL;
        obj_audit_clntpf. oldstcd := C_NULL;
        obj_audit_clntpf. oldstce := C_NULL;
        obj_audit_clntpf. oldprocflag := C_NULL;
        obj_audit_clntpf. oldtermid := C_NULL;
        obj_audit_clntpf. olduser_t := C_ZERO;
        obj_audit_clntpf. oldtrdt := C_ZERO;
        obj_audit_clntpf. oldtrtm := C_ZERO;
        obj_audit_clntpf. oldsndxcde := C_NULL;
        obj_audit_clntpf. oldnatlty := C_NULL;
        obj_audit_clntpf. oldfao := C_NULL;
        obj_audit_clntpf. oldcltind := C_NULL;
        obj_audit_clntpf. oldstate := C_NULL;
        obj_audit_clntpf. oldlanguage := C_NULL;
        obj_audit_clntpf. oldcapital := C_ZERO;
        obj_audit_clntpf. oldctryorig := C_NULL;
        obj_audit_clntpf. oldecact := C_NULL;
        obj_audit_clntpf. oldethorig := C_NULL;
        obj_audit_clntpf. oldsrdate := C_ZERO;
        obj_audit_clntpf. oldstaffno := C_NULL;
        obj_audit_clntpf. oldlsurname := C_NULL;
        obj_audit_clntpf. oldlgivname := C_NULL;
        obj_audit_clntpf. oldtaxflag := C_NULL;
        obj_audit_clntpf. oldusrprf := i_usrprf;
        obj_audit_clntpf. oldjobnm := i_scheduleName;
        obj_audit_clntpf. olddatime := LOCALTIMESTAMP;
        obj_audit_clntpf. oldidtype := C_NULL;
        obj_audit_clntpf. oldz1gstregn := C_NULL;
        obj_audit_clntpf. oldz1gstregd := C_ZERO;
        obj_audit_clntpf. oldkanjisurname := C_NULL;
        obj_audit_clntpf. oldkanjigivname := C_NULL;
        obj_audit_clntpf. oldkanjicltaddr01 := C_NULL;
        obj_audit_clntpf. oldkanjicltaddr02 := C_NULL;
        obj_audit_clntpf. oldkanjicltaddr03 := C_NULL;
        obj_audit_clntpf. oldkanjicltaddr04 := C_NULL;
        obj_audit_clntpf. oldkanjicltaddr05 := C_NULL;
        obj_audit_clntpf. oldexcep := C_NULL;
        obj_audit_clntpf. oldzkanasnm := C_NULL;
        obj_audit_clntpf. oldzkanagnm := C_NULL;
        obj_audit_clntpf. oldzkanaddr01 := C_NULL;
        obj_audit_clntpf. oldzkanaddr02 := C_NULL;
        obj_audit_clntpf. oldzkanaddr03 := C_NULL;
        obj_audit_clntpf. oldzkanaddr04 := C_NULL;
        obj_audit_clntpf. oldzkanaddr05 := C_NULL;
        obj_audit_clntpf. oldzaddrcd := C_NULL;
        obj_audit_clntpf. oldabusnum := C_NULL;
        obj_audit_clntpf. oldbranchid := C_NULL;
        obj_audit_clntpf. oldzkanasnmnor := C_NULL;
        obj_audit_clntpf. oldzkanagnmnor := C_NULL;
        obj_audit_clntpf. oldtelectrycode := C_NULL;
        obj_audit_clntpf. oldtelectrycode1 := C_NULL;
        --
        obj_audit_clntpf. newclntpfx := o_defaultvalues('CLNTPFX');
        obj_audit_clntpf. newclntcoy := o_defaultvalues('CLNTCOY');
        obj_audit_clntpf. newclntnum := v_clntnum;
        obj_audit_clntpf. newtranid := v_tranid;
        obj_audit_clntpf. newvalidflag := o_defaultvalues('VALIDFLAG');
        obj_audit_clntpf. newclttype := o_defaultvalues('CLTTYPE');
        obj_audit_clntpf. newsecuityno := C_SECUITYNO;
        obj_audit_clntpf. newpayrollno := C_PAYROLLNO;
        obj_audit_clntpf. newsurname := obj_cur_Stagetab.lsurname;
        obj_audit_clntpf. newgivname := obj_cur_Stagetab.lgivname;
        obj_audit_clntpf. newsalut := C_SALUT;
        obj_audit_clntpf. newinitials := SUBSTR(obj_cur_Stagetab.lgivname,
                                                1,
                                                1);
        obj_audit_clntpf. newcltsex := obj_cur_Stagetab.Cltsex;
        obj_audit_clntpf. newcltaddr01 := obj_cur_Stagetab.cltaddr01;
        obj_audit_clntpf. newcltaddr02 := obj_cur_Stagetab.cltaddr02;
        obj_audit_clntpf. newcltaddr03 := obj_cur_Stagetab.cltaddr03;
        obj_audit_clntpf. newcltaddr04 := C_CLTADDR04;
        obj_audit_clntpf. newcltaddr05 := C_CLTADDR05;
        obj_audit_clntpf. newcltpcode := obj_cur_Stagetab.cltpcode;
        obj_audit_clntpf. newctrycode := o_defaultvalues('CTRYCODE');
        obj_audit_clntpf. newmailing := o_defaultvalues('MAILING');
        obj_audit_clntpf.newdirmail := o_defaultvalues('DIRMAIL');
        obj_audit_clntpf. newaddrtype := obj_cur_Stagetab.addrtype;
        obj_audit_clntpf. newcltphone01 := obj_cur_Stagetab.cltphone01;
        obj_audit_clntpf. newcltphone02 := obj_cur_Stagetab.cltphone02;
        obj_audit_clntpf. newvip := o_defaultvalues('VIP');
        obj_audit_clntpf. newoccpcode := obj_cur_Stagetab.occpcode;
        obj_audit_clntpf. newservbrh := o_defaultvalues('SERVBRH');
        obj_audit_clntpf. newstatcode := o_defaultvalues('STATCODE');
        obj_audit_clntpf. newcltdob := obj_cur_Stagetab.cltdob;
        obj_audit_clntpf. newsoe := o_defaultvalues('SOE');
        obj_audit_clntpf. newdocno := o_defaultvalues('DOCNO');
        obj_audit_clntpf. newcltdod := o_defaultvalues('CLTDOD');
        obj_audit_clntpf. newcltstat := o_defaultvalues('CLTSTAT');
        obj_audit_clntpf. newcltmchg := o_defaultvalues('CLTMCHG');
        obj_audit_clntpf. newmiddl01 := C_MIDDL01;
        obj_audit_clntpf. newmiddl02 := C_MIDDL02;
        obj_audit_clntpf. newmarryd := o_defaultvalues('MARRYD');
        obj_audit_clntpf. newtlxno := C_TLXNO;
        obj_audit_clntpf. newfaxno := C_FAXNO;
        obj_audit_clntpf. newtgram := C_TGRAM;
        obj_audit_clntpf. newbirthp := o_defaultvalues('BIRTHP');
        obj_audit_clntpf. newsalutl := C_SALUTL;
        obj_audit_clntpf.newROLEFLAG01 := C_ROLEFLAG01;
        obj_audit_clntpf.newROLEFLAG02 := C_ROLEFLAG02;
        obj_audit_clntpf.newROLEFLAG03 := C_ROLEFLAG03;
        obj_audit_clntpf.newROLEFLAG04 := C_ROLEFLAG04;
        obj_audit_clntpf.newROLEFLAG05 := o_defaultvalues('ROLEFLAG05'); --Need to check
        obj_audit_clntpf.newROLEFLAG06 := C_ROLEFLAG06;
        obj_audit_clntpf.newROLEFLAG07 := C_ROLEFLAG07;
        obj_audit_clntpf.newROLEFLAG08 := C_ROLEFLAG08;
        obj_audit_clntpf.newROLEFLAG09 := C_ROLEFLAG09;
        obj_audit_clntpf.newROLEFLAG10 := C_ROLEFLAG10;
        obj_audit_clntpf.newROLEFLAG11 := C_ROLEFLAG11;
        obj_audit_clntpf.newROLEFLAG12 := C_ROLEFLAG12;
        obj_audit_clntpf.newROLEFLAG13 := C_ROLEFLAG13;
        obj_audit_clntpf.newROLEFLAG14 := o_defaultvalues('ROLEFLAG14');
        obj_audit_clntpf.newROLEFLAG15 := C_ROLEFLAG15;
        obj_audit_clntpf.newROLEFLAG16 := C_ROLEFLAG16;
        obj_audit_clntpf.newROLEFLAG17 := C_ROLEFLAG17;
        obj_audit_clntpf.newROLEFLAG18 := o_defaultvalues('ROLEFLAG18');
        obj_audit_clntpf.newROLEFLAG19 := C_ROLEFLAG19;
        obj_audit_clntpf.newROLEFLAG20 := C_ROLEFLAG20;
        obj_audit_clntpf.newROLEFLAG21 := C_ROLEFLAG21;
        obj_audit_clntpf.newROLEFLAG22 := C_ROLEFLAG22;
        obj_audit_clntpf.newROLEFLAG23 := C_ROLEFLAG23;
        obj_audit_clntpf.newROLEFLAG24 := C_ROLEFLAG24;
        obj_audit_clntpf.newROLEFLAG25 := C_ROLEFLAG25;
        obj_audit_clntpf.newROLEFLAG26 := C_ROLEFLAG26;
        obj_audit_clntpf.newROLEFLAG27 := C_ROLEFLAG27;
        obj_audit_clntpf.newROLEFLAG28 := C_ROLEFLAG28;
        obj_audit_clntpf.newROLEFLAG29 := C_ROLEFLAG29;
        obj_audit_clntpf.newROLEFLAG30 := C_ROLEFLAG30;
        obj_audit_clntpf.newROLEFLAG31 := C_ROLEFLAG31;
        obj_audit_clntpf.newROLEFLAG32 := C_ROLEFLAG32;
        obj_audit_clntpf.newROLEFLAG33 := C_ROLEFLAG33;
        obj_audit_clntpf.newROLEFLAG34 := C_ROLEFLAG34;
        obj_audit_clntpf.newROLEFLAG35 := C_ROLEFLAG35;
        obj_audit_clntpf.newSTCA := C_STCA;
        obj_audit_clntpf.newSTCB := C_STCB;
        obj_audit_clntpf.newSTCC := C_STCC;
        obj_audit_clntpf.newSTCD := C_STCD;
        obj_audit_clntpf.newSTCE := C_STCE;
        obj_audit_clntpf. newprocflag := C_PROCFLAG;
        obj_audit_clntpf. newtermid := trim(i_vrcmTermid);
        obj_audit_clntpf. newuser_t := null;
        obj_audit_clntpf. newtrdt := TO_CHAR(sysdate, 'YYMMDD');
        obj_audit_clntpf. newtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
        obj_audit_clntpf. newsndxcde := C_SNDXCDE;
        obj_audit_clntpf. newnatlty := o_defaultvalues('NATLTY');
        obj_audit_clntpf. newfao := o_defaultvalues('FAO');
        obj_audit_clntpf. newcltind := 'C';
        obj_audit_clntpf. newstate := C_STATE;
        obj_audit_clntpf. newlanguage := o_defaultvalues('LANGUAGE');
        obj_audit_clntpf. newcapital := C_ZERO;
        obj_audit_clntpf. newctryorig := C_CTRYORIG;
        obj_audit_clntpf. newecact := C_ECACT;
        obj_audit_clntpf. newethorig := o_defaultvalues('ETHORIG');
        obj_audit_clntpf. newsrdate := 19010101; --CH5
        obj_audit_clntpf. newstaffno := C_STAFFNO;
        obj_audit_clntpf. newlsurname := obj_cur_Stagetab.lsurname;
        obj_audit_clntpf. newlgivname := obj_cur_Stagetab.lgivname;
        obj_audit_clntpf. newtaxflag := o_defaultvalues('TAXFLAG');
        obj_audit_clntpf. newusrprf := i_usrprf;
        obj_audit_clntpf. newjobnm := i_scheduleName;
        obj_audit_clntpf. newdatime := LOCALTIMESTAMP;
        obj_audit_clntpf. newidtype := C_IDTYPE;
        obj_audit_clntpf. newz1gstregn := C_Z1GSTREGN;
        obj_audit_clntpf. newz1gstregd := C_ZERO;
        obj_audit_clntpf.newKANJISURNAME := C_KANJISURNAME;
        obj_audit_clntpf.newKANJIGIVNAME := C_KANJIGIVNAME;
        obj_audit_clntpf.newKANJICLTADDR01 := C_KANJICLTADDR01;
        obj_audit_clntpf.newKANJICLTADDR02 := C_KANJICLTADDR02;
        obj_audit_clntpf.newKANJICLTADDR03 := C_KANJICLTADDR03;
        obj_audit_clntpf.newKANJICLTADDR04 := C_KANJICLTADDR04;
        obj_audit_clntpf.newKANJICLTADDR05 := C_KANJICLTADDR05;
        obj_audit_clntpf. newexcep := o_defaultvalues('EXCEP');
        obj_audit_clntpf. newzkanasnm := obj_cur_Stagetab.zkanasurname;
        obj_audit_clntpf. newzkanagnm := obj_cur_Stagetab.zkanagivname;
        obj_audit_clntpf. newzkanaddr01 := obj_cur_Stagetab.zkanaddr01;
        obj_audit_clntpf. newzkanaddr02 := obj_cur_Stagetab.zkanaddr02;
        obj_audit_clntpf.newZKANADDR03 := C_ZKANADDR03;
        obj_audit_clntpf.newZKANADDR04 := C_ZKANADDR04;
        obj_audit_clntpf.newZKANADDR05 := C_ZKANADDR05;
        obj_audit_clntpf. newzaddrcd := obj_cur_Stagetab.Minaddrcd;
        obj_audit_clntpf. newabusnum := o_defaultvalues('ABUSNUM');
        obj_audit_clntpf. newbranchid := o_defaultvalues('BRANCHID');
        obj_audit_clntpf. newzkanasnmnor := obj_cur_Stagetab.zkanasurname;
        obj_audit_clntpf. newzkanagnmnor := obj_cur_Stagetab.zkanagivname;
        obj_audit_clntpf. newtelectrycode := C_TELECTRYCODE;
        obj_audit_clntpf. newtelectrycode1 := C_TELECTRYCODE1;
        obj_audit_clntpf. userid := i_usrprf;
        obj_audit_clntpf. action := 'INSERT';
        obj_audit_clntpf. tranno := v_incrVersion;
        obj_audit_clntpf. systemdate := sysdate;
        obj_audit_clntpf. oldoccpclas := C_NULL;
        obj_audit_clntpf. newoccpclas := C_NULL;
        obj_audit_clntpf.OLDCLNTSTATECD := C_NULL;
        obj_audit_clntpf.NEWCLNTSTATECD := C_NULL;
      
        Insert into audit_clntpf values obj_audit_clntpf;
        ------------Insert into Audit_CLNTPF : END------------------------
      
        ------------Insert into audit_clexp : Start------------------------
      
        obj_audit_clexp. oldclntnum := v_clntnum;
      
        obj_audit_clexp. newclntpfx := o_defaultvalues('CLNTPFX');
        obj_audit_clexp. newclntcoy := o_defaultvalues('CLNTCOY');
        obj_audit_clexp. newclntnum := v_clntnum;
        obj_audit_clexp. newrdidtelno := o_defaultvalues('RDIDTELNO');
        if (trim(obj_cur_Stagetab.CLTPHONE01) is not null) then
          obj_audit_clexp.newrmblphone := obj_cur_Stagetab.CLTPHONE01;
        
        else
          obj_audit_clexp.newrmblphone := '                ';
        
        end if;
      
        obj_audit_clexp. newrpager := o_defaultvalues('RPAGER');
        obj_audit_clexp. newfaxno := o_defaultvalues('FAXNO');
        obj_audit_clexp. newrinternet := o_defaultvalues('RINTERNET');
        obj_audit_clexp. newrtaxidnum := o_defaultvalues('RTAXIDNUM');
        obj_audit_clexp. newrstaflag := o_defaultvalues('RSTAFLAG');
        obj_audit_clexp. newsplindic := C_SPLINDIC;
        obj_audit_clexp. newzspecind := o_defaultvalues('ZSPECIND');
        obj_audit_clexp. newoldidno := o_defaultvalues('OLDIDNO');
        obj_audit_clexp. newusrprf := i_usrprf;
        obj_audit_clexp. newjobnm := i_scheduleName;
        obj_audit_clexp. newdatime := sysdate;
        obj_audit_clexp. newvalidflag := o_defaultvalues('VALIDFLAG');
        obj_audit_clexp. userid := i_usrprf;
        obj_audit_clexp. action := 'INSERT';
        obj_audit_clexp. tranno := v_incrVersion;
        obj_audit_clexp. systemdate := sysdate;
        insert into audit_clexpf values obj_audit_clexp;
        ------------Insert into audit_clexp : END------------------------
        ------------Insert into VERSIONPF : Start------------------------
      
        obj_versionpf.TRANNO  := v_incrVersion;
        obj_versionpf.CLNTNUM := v_clntnum;
        INSERT INTO VERSIONPF VALUES obj_versionpf;
        ------------Insert into VERSIONPF : END------------------------
      
        ------------Insert into ZCLNPF : START------------------------
      
        obj_zclnpf.CLNTPFX := o_defaultvalues('CLNTPFX');
        obj_zclnpf.CLNTCOY := o_defaultvalues('CLNTCOY');
        obj_zclnpf.CLNTNUM := v_clntnum;
        obj_zclnpf.CLTDOB  := obj_cur_Stagetab.Cltdob;
        IF TRIM(obj_cur_Stagetab.lsurname) IS NOT NULL THEN
          obj_zclnpf.LSURNAME := obj_cur_Stagetab.lsurname;
        ELSE
          obj_zclnpf.LSURNAME := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.lgivname) IS NOT NULL THEN
          obj_zclnpf.LGIVNAME := obj_cur_Stagetab.lgivname;
        ELSE
          obj_zclnpf.LGIVNAME := C_ONESPACE;
        END IF;
      
        IF TRIM(obj_cur_Stagetab.zkanasurname) IS NOT NULL THEN
          obj_zclnpf.ZKANASNM := obj_cur_Stagetab.zkanasurname;
        ELSE
          obj_zclnpf.ZKANASNM := C_ONESPACE;
        END IF;
      
        IF TRIM(obj_cur_Stagetab.zkanagivname) IS NOT NULL THEN
          obj_zclnpf.ZKANAGNM := obj_cur_Stagetab.zkanagivname;
        ELSE
          obj_zclnpf.ZKANAGNM := C_ONESPACE;
        END IF;
      
        obj_zclnpf.CLTSEX := obj_cur_Stagetab.cltsex;
        IF TRIM(obj_cur_Stagetab.cltpcode) IS NOT NULL THEN
          obj_zclnpf.CLTPCODE := obj_cur_Stagetab.cltpcode;
        ELSE
          obj_zclnpf.CLTPCODE := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.zkanaddr01) IS NOT NULL THEN
          obj_zclnpf.ZKANADDR01 := obj_cur_Stagetab.zkanaddr01;
        ELSE
          obj_zclnpf.ZKANADDR01 := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.zkanaddr02) IS NOT NULL THEN
          obj_zclnpf.ZKANADDR02 := obj_cur_Stagetab.zkanaddr02;
        ELSE
          obj_zclnpf.ZKANADDR02 := C_ONESPACE;
        END IF;
      
        obj_zclnpf.ZKANADDR04 := C_ZKANADDR04;
        IF TRIM(obj_cur_Stagetab.cltaddr01) IS NOT NULL THEN
          obj_zclnpf.CLTADDR01 := obj_cur_Stagetab.cltaddr01;
        ELSE
          obj_zclnpf.CLTADDR01 := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.cltaddr02) IS NOT NULL THEN
          obj_zclnpf.CLTADDR02 := obj_cur_Stagetab.cltaddr02;
        ELSE
          obj_zclnpf.CLTADDR02 := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.cltaddr03) IS NOT NULL THEN
          obj_zclnpf.CLTADDR03 := obj_cur_Stagetab.cltaddr03;
        ELSE
          obj_zclnpf.CLTADDR03 := C_ONESPACE;
        END IF;
        obj_zclnpf.CLTADDR04 := C_CLTADDR04; --v_cltaddr04;not in stage table
        IF TRIM(obj_cur_Stagetab.cltphone01) IS NOT NULL THEN
          obj_zclnpf.CLTPHONE01 := obj_cur_Stagetab.cltphone01;
        ELSE
          obj_zclnpf.CLTPHONE01 := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.cltphone02) IS NOT NULL THEN
          obj_zclnpf.CLTPHONE02 := obj_cur_Stagetab.cltphone02;
        ELSE
          obj_zclnpf.CLTPHONE02 := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.zworkplce) IS NOT NULL THEN
          obj_zclnpf.ZWORKPLCE := obj_cur_Stagetab.zworkplce;
        ELSE
          obj_zclnpf.ZWORKPLCE := C_ONESPACE;
        END IF;
        IF TRIM(obj_cur_Stagetab.occpcode) IS NOT NULL THEN
          obj_zclnpf.OCCPCODE := obj_cur_Stagetab.occpcode;
        ELSE
          obj_zclnpf.OCCPCODE := C_ONESPACE;
        END IF;
        IF (pitemexist.exists(obj_cur_Stagetab.Occpcode)) THEN
          --Need to check this logic
          v_occpclass := pitemexist(obj_cur_Stagetab.Occpcode).occclass;
        else
          v_occpclass := '  ';
        
        END IF;
        obj_zclnpf.OCCPCLAS := v_occpclass;
        IF TRIM(obj_cur_Stagetab.zoccdsc) IS NOT NULL THEN
          obj_zclnpf.ZOCCDSC := obj_cur_Stagetab.zoccdsc;
        ELSE
          obj_zclnpf.ZOCCDSC := C_ONESPACE;
        END IF;
      
        obj_zclnpf.CLTDOBFLAG     := C_N;
        obj_zclnpf.LSURNAMEFLAG   := C_N;
        obj_zclnpf.LGIVNAMEFLAG   := C_N;
        obj_zclnpf.ZKANASNMFLAG   := C_N;
        obj_zclnpf.ZKANAGNMFLAG   := C_N;
        obj_zclnpf.CLTSEXFLAG     := C_N;
        obj_zclnpf.CLTPCODEFLAG   := C_N;
        obj_zclnpf.ZKANADDR01FLAG := C_N;
        obj_zclnpf.ZKANADDR02FLAG := C_N;
        obj_zclnpf.ZKANADDR03FLAG := C_N;
        obj_zclnpf.ZKANADDR04FLAG := C_N;
        obj_zclnpf.CLTADDR01FLAG  := C_N;
        obj_zclnpf.CLTADDR02FLAG  := C_N;
        obj_zclnpf.CLTADDR03FLAG  := C_N;
        obj_zclnpf.CLTADDR04FLAG  := C_N;
        obj_zclnpf.CLTPHONE01FLAG := C_N;
        obj_zclnpf.CLTPHONE02FLAG := C_N;
        obj_zclnpf.CLTPHONE02FLAG := C_N;
        obj_zclnpf.ZWORKPLCEFLAG  := C_N;
        obj_zclnpf.OCCPCODEFLAG   := C_N;
        obj_zclnpf.OCCPCLASFLAG   := C_N;
        obj_zclnpf.ZOCCDSCFLAG    := C_N;
        obj_zclnpf.EFFDATE        := obj_cur_Stagetab.effdate;
        obj_zclnpf.ZKANADDR03     := C_ONESPACE;
        obj_zclnpf.DATIME         := CURRENT_TIMESTAMP;
        obj_zclnpf.JOBNM          := i_scheduleName;
        obj_zclnpf.USRPRF         := i_usrprf;
        INSERT INTO VIEW_DM_ZCLNPF VALUES obj_zclnpf;
        ------------Insert into ZCLNPF : END------------------------
      END IF;
    
      IF (obj_cur_Stagetab.zseqno > 0) THEN
        IF ((TRIM(obj_cur_Stagetab.zaltrcde01) = 'N01') OR
           (TRIM(obj_cur_Stagetab.zaltrcde01) = 'N02') OR
           (TRIM(obj_cur_Stagetab.zaltrcde01) = 'P09')) THEN
        
          ------------Insert into Audit_CLNTPF : Start------------------------
        
          obj_audit_clntpf. oldclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clntpf. oldclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clntpf. oldclntnum := v_clntnum;
          obj_audit_clntpf. oldtranid := v_tranid;
          obj_audit_clntpf. oldvalidflag := o_defaultvalues('VALIDFLAG');
          obj_audit_clntpf. oldclttype := o_defaultvalues('CLTTYPE');
          obj_audit_clntpf. oldsecuityno := C_SECUITYNO;
          obj_audit_clntpf. oldpayrollno := C_PAYROLLNO;
          obj_audit_clntpf. oldsurname := obj_client_old.lsurname;
          obj_audit_clntpf. oldgivname := obj_client_old.lgivname;
          obj_audit_clntpf. oldsalut := C_SALUT;
          obj_audit_clntpf. oldinitials := SUBSTR(obj_client_old.lgivname,
                                                  1,
                                                  1);
          obj_audit_clntpf. oldcltsex := obj_client_old.Cltsex;
          obj_audit_clntpf. oldcltaddr01 := obj_client_old.cltaddr01;
          obj_audit_clntpf. oldcltaddr02 := obj_client_old.cltaddr02;
          obj_audit_clntpf. oldcltaddr03 := obj_client_old.cltaddr03;
          obj_audit_clntpf. oldcltaddr04 := C_CLTADDR04;
          obj_audit_clntpf. oldcltaddr05 := C_CLTADDR05;
          obj_audit_clntpf. oldcltpcode := obj_client_old.cltpcode;
          obj_audit_clntpf. oldctrycode := o_defaultvalues('CTRYCODE');
          obj_audit_clntpf. oldmailing := o_defaultvalues('MAILING');
          obj_audit_clntpf.olddirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clntpf. oldaddrtype := obj_client_old.addrtype;
          obj_audit_clntpf. oldcltphone01 := obj_client_old.cltphone01;
          obj_audit_clntpf. oldcltphone02 := obj_client_old.cltphone02;
          obj_audit_clntpf. oldvip := o_defaultvalues('VIP');
          obj_audit_clntpf. oldoccpcode := obj_client_old.occpcode;
          obj_audit_clntpf. oldservbrh := o_defaultvalues('SERVBRH');
          obj_audit_clntpf. oldstatcode := o_defaultvalues('STATCODE');
          obj_audit_clntpf. oldcltdob := obj_client_old.cltdob;
          obj_audit_clntpf. oldsoe := o_defaultvalues('SOE');
          obj_audit_clntpf. olddocno := o_defaultvalues('DOCNO');
          obj_audit_clntpf. oldcltdod := o_defaultvalues('CLTDOD');
          obj_audit_clntpf. oldcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clntpf. oldcltmchg := o_defaultvalues('CLTMCHG');
          obj_audit_clntpf. oldmiddl01 := C_MIDDL01;
          obj_audit_clntpf. oldmiddl02 := C_MIDDL02;
          obj_audit_clntpf. oldmarryd := o_defaultvalues('MARRYD');
          obj_audit_clntpf. oldtlxno := C_TLXNO;
          obj_audit_clntpf. oldfaxno := C_FAXNO;
          obj_audit_clntpf. oldtgram := C_TGRAM;
          obj_audit_clntpf. oldbirthp := o_defaultvalues('BIRTHP');
          obj_audit_clntpf. oldsalutl := C_SALUTL;
          obj_audit_clntpf.oldROLEFLAG01 := C_ROLEFLAG01;
          obj_audit_clntpf.oldROLEFLAG02 := C_ROLEFLAG02;
          obj_audit_clntpf.oldROLEFLAG03 := C_ROLEFLAG03;
          obj_audit_clntpf.oldROLEFLAG04 := C_ROLEFLAG04;
          obj_audit_clntpf.oldROLEFLAG05 := o_defaultvalues('ROLEFLAG05'); --Need to check
          obj_audit_clntpf.oldROLEFLAG06 := C_ROLEFLAG06;
          obj_audit_clntpf.oldROLEFLAG07 := C_ROLEFLAG07;
          obj_audit_clntpf.oldROLEFLAG08 := C_ROLEFLAG08;
          obj_audit_clntpf.oldROLEFLAG09 := C_ROLEFLAG09;
          obj_audit_clntpf.oldROLEFLAG10 := C_ROLEFLAG10;
          obj_audit_clntpf.oldROLEFLAG11 := C_ROLEFLAG11;
          obj_audit_clntpf.oldROLEFLAG12 := C_ROLEFLAG12;
          obj_audit_clntpf.oldROLEFLAG13 := C_ROLEFLAG13;
          obj_audit_clntpf.oldROLEFLAG14 := o_defaultvalues('ROLEFLAG14');
          obj_audit_clntpf.oldROLEFLAG15 := C_ROLEFLAG15;
          obj_audit_clntpf.oldROLEFLAG16 := C_ROLEFLAG16;
          obj_audit_clntpf.oldROLEFLAG17 := C_ROLEFLAG17;
          obj_audit_clntpf.oldROLEFLAG18 := o_defaultvalues('ROLEFLAG18');
          obj_audit_clntpf.oldROLEFLAG19 := C_ROLEFLAG19;
          obj_audit_clntpf.oldROLEFLAG20 := C_ROLEFLAG20;
          obj_audit_clntpf.oldROLEFLAG21 := C_ROLEFLAG21;
          obj_audit_clntpf.oldROLEFLAG22 := C_ROLEFLAG22;
          obj_audit_clntpf.oldROLEFLAG23 := C_ROLEFLAG23;
          obj_audit_clntpf.oldROLEFLAG24 := C_ROLEFLAG24;
          obj_audit_clntpf.oldROLEFLAG25 := C_ROLEFLAG25;
          obj_audit_clntpf.oldROLEFLAG26 := C_ROLEFLAG26;
          obj_audit_clntpf.oldROLEFLAG27 := C_ROLEFLAG27;
          obj_audit_clntpf.oldROLEFLAG28 := C_ROLEFLAG28;
          obj_audit_clntpf.oldROLEFLAG29 := C_ROLEFLAG29;
          obj_audit_clntpf.oldROLEFLAG30 := C_ROLEFLAG30;
          obj_audit_clntpf.oldROLEFLAG31 := C_ROLEFLAG31;
          obj_audit_clntpf.oldROLEFLAG32 := C_ROLEFLAG32;
          obj_audit_clntpf.oldROLEFLAG33 := C_ROLEFLAG33;
          obj_audit_clntpf.oldROLEFLAG34 := C_ROLEFLAG34;
          obj_audit_clntpf.oldROLEFLAG35 := C_ROLEFLAG35;
          obj_audit_clntpf.oldSTCA := C_STCA;
          obj_audit_clntpf.oldSTCB := C_STCB;
          obj_audit_clntpf.oldSTCC := C_STCC;
          obj_audit_clntpf.oldSTCD := C_STCD;
          obj_audit_clntpf.oldSTCE := C_STCE;
          obj_audit_clntpf. oldprocflag := C_PROCFLAG;
          obj_audit_clntpf. oldtermid := trim(i_vrcmTermid);
          obj_audit_clntpf. olduser_t := null;
          obj_audit_clntpf. oldtrdt := TO_CHAR(sysdate, 'YYMMDD');
          obj_audit_clntpf. oldtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
          obj_audit_clntpf. oldsndxcde := C_SNDXCDE;
          obj_audit_clntpf. oldnatlty := o_defaultvalues('NATLTY');
          obj_audit_clntpf. oldfao := o_defaultvalues('FAO');
          obj_audit_clntpf. oldcltind := 'C';
          obj_audit_clntpf. oldstate := C_STATE;
          obj_audit_clntpf. oldlanguage := o_defaultvalues('LANGUAGE');
          obj_audit_clntpf. oldcapital := C_ZERO;
          obj_audit_clntpf. oldctryorig := C_CTRYORIG;
          obj_audit_clntpf. oldecact := C_ECACT;
          obj_audit_clntpf. oldethorig := o_defaultvalues('ETHORIG');
          obj_audit_clntpf. oldsrdate := 19010101; --CH5
          obj_audit_clntpf. oldstaffno := C_STAFFNO;
          obj_audit_clntpf. oldlsurname := obj_client_old.lsurname;
          obj_audit_clntpf. oldlgivname := obj_client_old.lgivname;
          obj_audit_clntpf. oldtaxflag := o_defaultvalues('TAXFLAG');
          obj_audit_clntpf. oldusrprf := i_usrprf;
          obj_audit_clntpf. oldjobnm := i_scheduleName;
          obj_audit_clntpf. olddatime := LOCALTIMESTAMP;
          obj_audit_clntpf. oldidtype := C_IDTYPE;
          obj_audit_clntpf. oldz1gstregn := C_Z1GSTREGN;
          obj_audit_clntpf. oldz1gstregd := C_ZERO;
          obj_audit_clntpf.oldKANJISURNAME := C_KANJISURNAME;
          obj_audit_clntpf.oldKANJIGIVNAME := C_KANJIGIVNAME;
          obj_audit_clntpf.oldKANJICLTADDR01 := C_KANJICLTADDR01;
          obj_audit_clntpf.oldKANJICLTADDR02 := C_KANJICLTADDR02;
          obj_audit_clntpf.oldKANJICLTADDR03 := C_KANJICLTADDR03;
          obj_audit_clntpf.oldKANJICLTADDR04 := C_KANJICLTADDR04;
          obj_audit_clntpf.oldKANJICLTADDR05 := C_KANJICLTADDR05;
          obj_audit_clntpf. oldexcep := o_defaultvalues('EXCEP');
          obj_audit_clntpf. oldzkanasnm := obj_client_old.zkanasurname;
          obj_audit_clntpf. oldzkanagnm := obj_client_old.zkanagivname;
          obj_audit_clntpf. oldzkanaddr01 := obj_client_old.zkanaddr01;
          obj_audit_clntpf. oldzkanaddr02 := obj_client_old.zkanaddr02;
          obj_audit_clntpf.oldZKANADDR03 := C_ZKANADDR03;
          obj_audit_clntpf.oldZKANADDR04 := C_ZKANADDR04;
          obj_audit_clntpf.oldZKANADDR05 := C_ZKANADDR05;
          obj_audit_clntpf. oldzaddrcd := obj_client_old.minaddrcd;
          obj_audit_clntpf. oldabusnum := o_defaultvalues('ABUSNUM');
          obj_audit_clntpf. oldbranchid := o_defaultvalues('BRANCHID');
          obj_audit_clntpf. oldzkanasnmnor := obj_client_old.zkanasurname;
          obj_audit_clntpf. oldzkanagnmnor := obj_client_old.zkanagivname;
          obj_audit_clntpf. oldtelectrycode := C_TELECTRYCODE;
          obj_audit_clntpf. oldtelectrycode1 := C_TELECTRYCODE1;
          --
          obj_audit_clntpf. newclntpfx := o_defaultvalues('CLNTPFX');
          obj_audit_clntpf. newclntcoy := o_defaultvalues('CLNTCOY');
          obj_audit_clntpf. newclntnum := v_clntnum;
          obj_audit_clntpf. newtranid := v_tranid;
          obj_audit_clntpf. newvalidflag := o_defaultvalues('VALIDFLAG');
          obj_audit_clntpf. newclttype := o_defaultvalues('CLTTYPE');
          obj_audit_clntpf. newsecuityno := C_SECUITYNO;
          obj_audit_clntpf. newpayrollno := C_PAYROLLNO;
          obj_audit_clntpf. newsurname := obj_cur_Stagetab.lsurname;
          obj_audit_clntpf. newgivname := obj_cur_Stagetab.lgivname;
          obj_audit_clntpf. newsalut := C_SALUT;
          obj_audit_clntpf. newinitials := SUBSTR(obj_cur_Stagetab.lgivname,
                                                  1,
                                                  1);
          obj_audit_clntpf. newcltsex := obj_cur_Stagetab.Cltsex;
          obj_audit_clntpf. newcltaddr01 := obj_cur_Stagetab.cltaddr01;
          obj_audit_clntpf. newcltaddr02 := obj_cur_Stagetab.cltaddr02;
          obj_audit_clntpf. newcltaddr03 := obj_cur_Stagetab.cltaddr03;
          obj_audit_clntpf. newcltaddr04 := C_CLTADDR04;
          obj_audit_clntpf. newcltaddr05 := C_CLTADDR05;
          obj_audit_clntpf. newcltpcode := obj_cur_Stagetab.cltpcode;
          obj_audit_clntpf. newctrycode := o_defaultvalues('CTRYCODE');
          obj_audit_clntpf. newmailing := o_defaultvalues('MAILING');
          obj_audit_clntpf.newdirmail := o_defaultvalues('DIRMAIL');
          obj_audit_clntpf. newaddrtype := obj_cur_Stagetab.addrtype;
          obj_audit_clntpf. newcltphone01 := obj_cur_Stagetab.cltphone01;
          obj_audit_clntpf. newcltphone02 := obj_cur_Stagetab.cltphone02;
          obj_audit_clntpf. newvip := o_defaultvalues('VIP');
          obj_audit_clntpf. newoccpcode := obj_cur_Stagetab.occpcode;
          obj_audit_clntpf. newservbrh := o_defaultvalues('SERVBRH');
          obj_audit_clntpf. newstatcode := o_defaultvalues('STATCODE');
          obj_audit_clntpf. newcltdob := obj_cur_Stagetab.cltdob;
          obj_audit_clntpf. newsoe := o_defaultvalues('SOE');
          obj_audit_clntpf. newdocno := o_defaultvalues('DOCNO');
          obj_audit_clntpf. newcltdod := o_defaultvalues('CLTDOD');
          obj_audit_clntpf. newcltstat := o_defaultvalues('CLTSTAT');
          obj_audit_clntpf. newcltmchg := o_defaultvalues('CLTMCHG');
          obj_audit_clntpf. newmiddl01 := C_MIDDL01;
          obj_audit_clntpf. newmiddl02 := C_MIDDL02;
          obj_audit_clntpf. newmarryd := o_defaultvalues('MARRYD');
          obj_audit_clntpf. newtlxno := C_TLXNO;
          obj_audit_clntpf. newfaxno := C_FAXNO;
          obj_audit_clntpf. newtgram := C_TGRAM;
          obj_audit_clntpf. newbirthp := o_defaultvalues('BIRTHP');
          obj_audit_clntpf. newsalutl := C_SALUTL;
          obj_audit_clntpf.newROLEFLAG01 := C_ROLEFLAG01;
          obj_audit_clntpf.newROLEFLAG02 := C_ROLEFLAG02;
          obj_audit_clntpf.newROLEFLAG03 := C_ROLEFLAG03;
          obj_audit_clntpf.newROLEFLAG04 := C_ROLEFLAG04;
          obj_audit_clntpf.newROLEFLAG05 := o_defaultvalues('ROLEFLAG05'); --Need to check
          obj_audit_clntpf.newROLEFLAG06 := C_ROLEFLAG06;
          obj_audit_clntpf.newROLEFLAG07 := C_ROLEFLAG07;
          obj_audit_clntpf.newROLEFLAG08 := C_ROLEFLAG08;
          obj_audit_clntpf.newROLEFLAG09 := C_ROLEFLAG09;
          obj_audit_clntpf.newROLEFLAG10 := C_ROLEFLAG10;
          obj_audit_clntpf.newROLEFLAG11 := C_ROLEFLAG11;
          obj_audit_clntpf.newROLEFLAG12 := C_ROLEFLAG12;
          obj_audit_clntpf.newROLEFLAG13 := C_ROLEFLAG13;
          obj_audit_clntpf.newROLEFLAG14 := o_defaultvalues('ROLEFLAG14');
          obj_audit_clntpf.newROLEFLAG15 := C_ROLEFLAG15;
          obj_audit_clntpf.newROLEFLAG16 := C_ROLEFLAG16;
          obj_audit_clntpf.newROLEFLAG17 := C_ROLEFLAG17;
          obj_audit_clntpf.newROLEFLAG18 := o_defaultvalues('ROLEFLAG18');
          obj_audit_clntpf.newROLEFLAG19 := C_ROLEFLAG19;
          obj_audit_clntpf.newROLEFLAG20 := C_ROLEFLAG20;
          obj_audit_clntpf.newROLEFLAG21 := C_ROLEFLAG21;
          obj_audit_clntpf.newROLEFLAG22 := C_ROLEFLAG22;
          obj_audit_clntpf.newROLEFLAG23 := C_ROLEFLAG23;
          obj_audit_clntpf.newROLEFLAG24 := C_ROLEFLAG24;
          obj_audit_clntpf.newROLEFLAG25 := C_ROLEFLAG25;
          obj_audit_clntpf.newROLEFLAG26 := C_ROLEFLAG26;
          obj_audit_clntpf.newROLEFLAG27 := C_ROLEFLAG27;
          obj_audit_clntpf.newROLEFLAG28 := C_ROLEFLAG28;
          obj_audit_clntpf.newROLEFLAG29 := C_ROLEFLAG29;
          obj_audit_clntpf.newROLEFLAG30 := C_ROLEFLAG30;
          obj_audit_clntpf.newROLEFLAG31 := C_ROLEFLAG31;
          obj_audit_clntpf.newROLEFLAG32 := C_ROLEFLAG32;
          obj_audit_clntpf.newROLEFLAG33 := C_ROLEFLAG33;
          obj_audit_clntpf.newROLEFLAG34 := C_ROLEFLAG34;
          obj_audit_clntpf.newROLEFLAG35 := C_ROLEFLAG35;
          obj_audit_clntpf.newSTCA := C_STCA;
          obj_audit_clntpf.newSTCB := C_STCB;
          obj_audit_clntpf.newSTCC := C_STCC;
          obj_audit_clntpf.newSTCD := C_STCD;
          obj_audit_clntpf.newSTCE := C_STCE;
          obj_audit_clntpf. newprocflag := C_PROCFLAG;
          obj_audit_clntpf. newtermid := trim(i_vrcmTermid);
          obj_audit_clntpf. newuser_t := null;
          obj_audit_clntpf. newtrdt := TO_CHAR(sysdate, 'YYMMDD');
          obj_audit_clntpf. newtrtm := TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDD');
          obj_audit_clntpf. newsndxcde := C_SNDXCDE;
          obj_audit_clntpf. newnatlty := o_defaultvalues('NATLTY');
          obj_audit_clntpf. newfao := o_defaultvalues('FAO');
          obj_audit_clntpf. newcltind := 'C';
          obj_audit_clntpf. newstate := C_STATE;
          obj_audit_clntpf. newlanguage := o_defaultvalues('LANGUAGE');
          obj_audit_clntpf. newcapital := C_ZERO;
          obj_audit_clntpf. newctryorig := C_CTRYORIG;
          obj_audit_clntpf. newecact := C_ECACT;
          obj_audit_clntpf. newethorig := o_defaultvalues('ETHORIG');
          obj_audit_clntpf. newsrdate := 19010101; --CH5
          obj_audit_clntpf. newstaffno := C_STAFFNO;
          obj_audit_clntpf. newlsurname := obj_cur_Stagetab.lsurname;
          obj_audit_clntpf. newlgivname := obj_cur_Stagetab.lgivname;
          obj_audit_clntpf. newtaxflag := o_defaultvalues('TAXFLAG');
          obj_audit_clntpf. newusrprf := i_usrprf;
          obj_audit_clntpf. newjobnm := i_scheduleName;
          obj_audit_clntpf. newdatime := LOCALTIMESTAMP;
          obj_audit_clntpf. newidtype := C_IDTYPE;
          obj_audit_clntpf. newz1gstregn := C_Z1GSTREGN;
          obj_audit_clntpf. newz1gstregd := C_ZERO;
          obj_audit_clntpf.newKANJISURNAME := C_KANJISURNAME;
          obj_audit_clntpf.newKANJIGIVNAME := C_KANJIGIVNAME;
          obj_audit_clntpf.newKANJICLTADDR01 := C_KANJICLTADDR01;
          obj_audit_clntpf.newKANJICLTADDR02 := C_KANJICLTADDR02;
          obj_audit_clntpf.newKANJICLTADDR03 := C_KANJICLTADDR03;
          obj_audit_clntpf.newKANJICLTADDR04 := C_KANJICLTADDR04;
          obj_audit_clntpf.newKANJICLTADDR05 := C_KANJICLTADDR05;
          obj_audit_clntpf. newexcep := o_defaultvalues('EXCEP');
          obj_audit_clntpf. newzkanasnm := obj_cur_Stagetab.zkanasurname;
          obj_audit_clntpf. newzkanagnm := obj_cur_Stagetab.zkanagivname;
          obj_audit_clntpf. newzkanaddr01 := obj_cur_Stagetab.zkanaddr01;
          obj_audit_clntpf. newzkanaddr02 := obj_cur_Stagetab.zkanaddr02;
          obj_audit_clntpf.newZKANADDR03 := C_ZKANADDR03;
          obj_audit_clntpf.newZKANADDR04 := C_ZKANADDR04;
          obj_audit_clntpf.newZKANADDR05 := C_ZKANADDR05;
          obj_audit_clntpf. newzaddrcd := ''; ---need to check 
          obj_audit_clntpf. newabusnum := o_defaultvalues('ABUSNUM');
          obj_audit_clntpf. newbranchid := o_defaultvalues('BRANCHID');
          obj_audit_clntpf. newzkanasnmnor := obj_cur_Stagetab.zkanasurname;
          obj_audit_clntpf. newzkanagnmnor := obj_cur_Stagetab.zkanagivname;
          obj_audit_clntpf. newtelectrycode := C_TELECTRYCODE;
          obj_audit_clntpf. newtelectrycode1 := C_TELECTRYCODE1;
          obj_audit_clntpf. userid := i_usrprf;
          obj_audit_clntpf. action := 'INSERT';
          obj_audit_clntpf. tranno := v_incrVersion;
          obj_audit_clntpf. systemdate := sysdate;
          obj_audit_clntpf. oldoccpclas := C_NULL;
          obj_audit_clntpf. newoccpclas := C_NULL;
          obj_audit_clntpf.OLDCLNTSTATECD := C_NULL;
          obj_audit_clntpf.NEWCLNTSTATECD := C_NULL;
        
          Insert into audit_clntpf values obj_audit_clntpf;
          ------------Insert into Audit_CLNTPF : END------------------------
        
          ------------Insert into Audit_CLEXPF: START------------------------
        
          IF ((TRIM(obj_cur_Stagetab.zaltrcde01) = 'N01') and
             (TRIM(obj_client_old.cltphone01) !=
             TRIM(obj_cur_Stagetab.cltphone01))) THEN
          
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
            obj_audit_clexp. oldsplindic := C_SPLINDIC;
            obj_audit_clexp. oldzspecind := o_defaultvalues('ZSPECIND');
            obj_audit_clexp. oldoldidno := o_defaultvalues('OLDIDNO');
            obj_audit_clexp. oldusrprf := i_usrprf;
            obj_audit_clexp. oldjobnm := i_scheduleName;
            obj_audit_clexp. olddatime := sysdate;
            obj_audit_clexp. oldvalidflag := o_defaultvalues('VALIDFLAG');
            obj_audit_clexp. newclntpfx := o_defaultvalues('CLNTPFX');
            obj_audit_clexp. newclntcoy := o_defaultvalues('CLNTCOY');
            obj_audit_clexp. newclntnum := v_clntnum;
            obj_audit_clexp. newrdidtelno := o_defaultvalues('RDIDTELNO');
            if (trim(obj_cur_Stagetab.CLTPHONE01) is not null) then
              obj_audit_clexp.newrmblphone := obj_cur_Stagetab.CLTPHONE01;
            
            else
              obj_audit_clexp.newrmblphone := '                ';
            
            end if;
          
            obj_audit_clexp. newrpager := o_defaultvalues('RPAGER');
            obj_audit_clexp. newfaxno := o_defaultvalues('FAXNO');
            obj_audit_clexp. newrinternet := o_defaultvalues('RINTERNET');
            obj_audit_clexp. newrtaxidnum := o_defaultvalues('RTAXIDNUM');
            obj_audit_clexp. newrstaflag := o_defaultvalues('RSTAFLAG');
            obj_audit_clexp. newsplindic := C_SPLINDIC;
            obj_audit_clexp. newzspecind := o_defaultvalues('ZSPECIND');
            obj_audit_clexp. newoldidno := o_defaultvalues('OLDIDNO');
            obj_audit_clexp. newusrprf := i_usrprf;
            obj_audit_clexp. newjobnm := i_scheduleName;
            obj_audit_clexp. newdatime := sysdate;
            obj_audit_clexp. newvalidflag := o_defaultvalues('VALIDFLAG');
            obj_audit_clexp. userid := i_usrprf;
            obj_audit_clexp. action := 'INSERT';
            obj_audit_clexp. tranno := v_incrVersion;
            obj_audit_clexp. systemdate := sysdate;
            Insert Into audit_clexpf values obj_audit_clexp;
            ------------Insert into Audit_CLEXPF: END------------------------
            ------------Insert into Zclnpf: START------------------------
          
            obj_zclnpf.CLNTPFX := o_defaultvalues('CLNTPFX');
            obj_zclnpf.CLNTCOY := o_defaultvalues('CLNTCOY');
            obj_zclnpf.CLNTNUM := v_clntnum;
            obj_zclnpf.CLTDOB  := obj_cur_Stagetab.Cltdob;
            IF TRIM(obj_cur_Stagetab.lsurname) IS NOT NULL THEN
              obj_zclnpf.LSURNAME := obj_cur_Stagetab.lsurname;
            ELSE
              obj_zclnpf.LSURNAME := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.lgivname) IS NOT NULL THEN
              obj_zclnpf.LGIVNAME := obj_cur_Stagetab.lgivname;
            ELSE
              obj_zclnpf.LGIVNAME := C_ONESPACE;
            END IF;
          
            IF TRIM(obj_cur_Stagetab.zkanasurname) IS NOT NULL THEN
              obj_zclnpf.ZKANASNM := obj_cur_Stagetab.zkanasurname;
            ELSE
              obj_zclnpf.ZKANASNM := C_ONESPACE;
            END IF;
          
            IF TRIM(obj_cur_Stagetab.zkanagivname) IS NOT NULL THEN
              obj_zclnpf.ZKANAGNM := obj_cur_Stagetab.zkanagivname;
            ELSE
              obj_zclnpf.ZKANAGNM := C_ONESPACE;
            END IF;
          
            obj_zclnpf.CLTSEX := obj_cur_Stagetab.cltsex;
            IF TRIM(obj_cur_Stagetab.cltpcode) IS NOT NULL THEN
              obj_zclnpf.CLTPCODE := obj_cur_Stagetab.cltpcode;
            ELSE
              obj_zclnpf.CLTPCODE := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.zkanaddr01) IS NOT NULL THEN
              obj_zclnpf.ZKANADDR01 := obj_cur_Stagetab.zkanaddr01;
            ELSE
              obj_zclnpf.ZKANADDR01 := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.zkanaddr02) IS NOT NULL THEN
              obj_zclnpf.ZKANADDR02 := obj_cur_Stagetab.zkanaddr02;
            ELSE
              obj_zclnpf.ZKANADDR02 := C_ONESPACE;
            END IF;
          
            obj_zclnpf.ZKANADDR04 := C_ZKANADDR04;
            IF TRIM(obj_cur_Stagetab.cltaddr01) IS NOT NULL THEN
              obj_zclnpf.CLTADDR01 := obj_cur_Stagetab.cltaddr01;
            ELSE
              obj_zclnpf.CLTADDR01 := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.cltaddr02) IS NOT NULL THEN
              obj_zclnpf.CLTADDR02 := obj_cur_Stagetab.cltaddr02;
            ELSE
              obj_zclnpf.CLTADDR02 := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.cltaddr03) IS NOT NULL THEN
              obj_zclnpf.CLTADDR03 := obj_cur_Stagetab.cltaddr03;
            ELSE
              obj_zclnpf.CLTADDR03 := C_ONESPACE;
            END IF;
            obj_zclnpf.CLTADDR04 := C_CLTADDR04; 
            IF TRIM(obj_cur_Stagetab.cltphone01) IS NOT NULL THEN
              obj_zclnpf.CLTPHONE01 := obj_cur_Stagetab.cltphone01;
            ELSE
              obj_zclnpf.CLTPHONE01 := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.cltphone02) IS NOT NULL THEN
              obj_zclnpf.CLTPHONE02 := obj_cur_Stagetab.cltphone02;
            ELSE
              obj_zclnpf.CLTPHONE02 := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.zworkplce) IS NOT NULL THEN
              obj_zclnpf.ZWORKPLCE := obj_cur_Stagetab.zworkplce;
            ELSE
              obj_zclnpf.ZWORKPLCE := C_ONESPACE;
            END IF;
            IF TRIM(obj_cur_Stagetab.occpcode) IS NOT NULL THEN
              obj_zclnpf.OCCPCODE := obj_cur_Stagetab.occpcode;
            ELSE
              obj_zclnpf.OCCPCODE := C_ONESPACE;
            END IF;
            obj_zclnpf.OCCPCLAS := ''; ---need to check
            IF TRIM(obj_cur_Stagetab.zoccdsc) IS NOT NULL THEN
              obj_zclnpf.ZOCCDSC := obj_cur_Stagetab.zoccdsc;
            ELSE
              obj_zclnpf.ZOCCDSC := C_ONESPACE;
            END IF;
            obj_zclnpf.ZKANADDR03 := C_ONESPACE;
          
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_P09 THEN
              obj_zclnpf.CLTDOBFLAG := C_Y;
            ELSE
              obj_zclnpf.CLTDOBFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N02 THEN
              obj_zclnpf.LSURNAMEFLAG := C_Y;
            ELSE
              obj_zclnpf.LSURNAMEFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N02 THEN
              obj_zclnpf.LGIVNAMEFLAG := C_Y;
            ELSE
              obj_zclnpf.LGIVNAMEFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N02 THEN
              obj_zclnpf.ZKANASNMFLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANASNMFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N02 THEN
              obj_zclnpf.ZKANAGNMFLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANAGNMFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_P09 THEN
              obj_zclnpf.CLTSEXFLAG := C_Y;
            ELSE
              obj_zclnpf.CLTSEXFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTPCODEFLAG := C_Y;
            ELSE
              obj_zclnpf.CLTPCODEFLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.ZKANADDR01FLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANADDR01FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.ZKANADDR02FLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANADDR02FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.ZKANADDR03FLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANADDR03FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.ZKANADDR04FLAG := C_Y;
            ELSE
              obj_zclnpf.ZKANADDR04FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTADDR01FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTADDR01FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTADDR02FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTADDR02FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTADDR03FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTADDR03FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTADDR04FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTADDR04FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTPHONE01FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTPHONE01FLAG := C_N;
            END IF;
            IF TRIM(obj_cur_Stagetab.zaltrcde01) = C_N01 THEN
              obj_zclnpf.CLTPHONE02FLAG := C_Y;
            ELSE
              obj_zclnpf.CLTPHONE02FLAG := C_N;
            END IF;
          
            obj_zclnpf.ZWORKPLCEFLAG := C_N;
            obj_zclnpf.OCCPCODEFLAG  := C_N;
            obj_zclnpf.OCCPCLASFLAG  := C_N;
            obj_zclnpf.ZOCCDSCFLAG   := C_N;
            obj_zclnpf.EFFDATE       := obj_cur_Stagetab.effdate;
            obj_zclnpf.DATIME        := CURRENT_TIMESTAMP;
            obj_zclnpf.JOBNM         := i_scheduleName;
            obj_zclnpf.USRPRF        := i_usrprf;
            INSERT INTO VIEW_DM_ZCLNPF VALUES obj_zclnpf;
            ------------Insert into Zclnpf: END------------------------
          
          END IF;
        
        END IF;
      END IF;
    
      obj_client_old := obj_cur_Stagetab;
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
