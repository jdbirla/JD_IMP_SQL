CREATE OR REPLACE PROCEDURE "BQ9Q5_CL_NAYOCL"(i_scheduleName   IN VARCHAR2,
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
  * Amenment History: CL Nayose Personal Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * APR13    JDB       NP1   PA New implementation for Nayose
  
  *****************************************************************************************************/
  ----------------Local Variables:START------------- 
  v_timestart     NUMBER := dbms_utility.get_time;
  v_isAnyError    VARCHAR2(1) DEFAULT 'N';
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  errorCount      NUMBER(1) DEFAULT 0;
  v_tranid        VARCHAR2(14 CHAR);
  v_clntnum       VARCHAR2(8 CHAR);
  p_exitcode      number;
  p_exittext      varchar2(200);
  v_CLNTSTAS      view_dm_pazdnypf.CLNTSTAS%type;
  ----------------Local Variables:END------------- 
  C_BQ9Q5 CONSTANT VARCHAR2(5) := 'BQ9Q5';

  C_H366 CONSTANT VARCHAR2(4) := 'H366';
  /*Field cannot be blank    */
  C_E186 CONSTANT VARCHAR2(4) := 'E186';
  /*Field must be entered*/
  C_Z021 CONSTANT VARCHAR2(4) := 'RQV4';
  /*Missing of Kana name*/
  C_Z013 CONSTANT VARCHAR2(4) := 'RQLT';
  /*Invalid Date*/
  C_Z098 CONSTANT VARCHAR2(4) := 'RQO6';

  ----------------CONSTANT:START------------- 
  C_PREFIX CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('NYCL', i_company);
  C_BQ9Q5  CONSTANT VARCHAR2(5) := 'BQ9Q5';

  ------Constant----
  C_NEWCLNT CONSTANT VARCHAR2(7) := 'NEWCLNT';
  C_NW      CONSTANT VARCHAR2(2) := 'NW';
  C_EX      CONSTANT VARCHAR2(2) := 'EX';

  ----------------CONSTANT:END------------- 
  --------------Common Function Start---------
  itemexist   pkg_dm_common_operations.itemschec;
  o_errortext pkg_dm_common_operations.errordesc;
  i_zdoe_info pkg_dm_common_operations.obj_zdoe;
  nycheckdupl pkg_common_dmcp.nyduplicate;

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
  obj_PAZDNYPF VIEW_DM_PAZDNYPF%rowtype;

  ------IG table obj End---
  CURSOR Cur_StageTable IS
    select *
      from Jd1dta.DMIGTITNYCLT
     WHERE uniqueid between start_id and end_id
     order by LPAD(REFNUM, 8, '0') asc;

  obj_cur_Stagetab Cur_StageTable%rowtype;

BEGIN

  dbms_output.put_line('Start execution of BQ9Q5_CL_NAYOCL, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  ---------Common Function:Calling------------

  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCP',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCP',
                                        o_errortext   => o_errortext);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  --pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  pkg_common_dmcp.checknydup(nycheckdupl => nycheckdupl);

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
    v_CLNTSTAS := null;
    i_zdoe_info := NULL;
    t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    i_zdoe_info.i_zfilename := 'DMIGTITNYCLT';
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
    ELSE
      IF (nycheckdupl.exists(TRIM(obj_cur_Stagetab.refnum))) THEN
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
    END IF;
  
    IF TRIM(obj_cur_Stagetab.dch_zendcde) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_H366;
      t_errorfield(errorCount) := 'zendcde';
      t_errormsg(errorCount) := o_errortext(C_H366);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_zendcde);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF TRIM(obj_cur_Stagetab.dch_zkanagnmnor) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'kanagnmnor';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_zkanagnmnor);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    -- 4) ZKANASURNAME is  Null
    IF TRIM(obj_cur_Stagetab.dch_zkanasnmnor) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z021;
      t_errorfield(errorCount) := 'kanasnmnor';
      t_errormsg(errorCount) := o_errortext(C_Z021);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_zkanasnmnor);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF TRIM(obj_cur_Stagetab.dch_cltdob) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_Z013;
      t_errorfield(errorCount) := 'cltdob';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_cltdob);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    IF TRIM(obj_cur_Stagetab.dch_cltsex) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_H366;
      t_errorfield(errorCount) := 'CLTSEX';
      t_errormsg(errorCount) := o_errortext(C_Z013);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_cltsex);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    --CLTPCODE validation PA
    IF TRIM(obj_cur_Stagetab.dch_CLTPCODE) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E186;
      t_errorfield(errorCount) := 'CLTPCODE';
      t_errormsg(errorCount) := o_errortext(C_E186);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_CLTPCODE);
      t_errorprogram(errorCount) := i_scheduleName;
      IF errorCount >= 5 THEN
        GOTO insertzdoe;
      END IF;
    END IF;
  
    --CLTPHONE01 validation PA
    IF TRIM(obj_cur_Stagetab.dch_CLTPHONE01) IS NULL THEN
      v_isAnyError := 'Y';
      errorCount := errorCount + 1;
      t_ercode(errorCount) := C_E186;
      t_errorfield(errorCount) := 'CLTPHONE01';
      t_errormsg(errorCount) := o_errortext(C_E186);
      t_errorfieldval(errorCount) := TRIM(obj_cur_Stagetab.dch_CLTPHONE01);
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
      if (TRIM(obj_cur_Stagetab.ig_clntnum) = C_NEWCLNT) THEN
        v_CLNTSTAS := C_NW;
      else
        v_CLNTSTAS := C_EX;
      
      end if;
    
      SELECT SEQANUMPF.nextval INTO v_clntnum FROM dual;
      --Insert Value Migration Registry Table
      obj_PAZDNYPF.PREFIX   := C_PREFIX;
      obj_PAZDNYPF.CLNTSTAS := v_CLNTSTAS;
      obj_PAZDNYPF.ZENTITY  := obj_cur_Stagetab.refnum;
      if (v_CLNTSTAS = C_NW) then
        obj_PAZDNYPF.ZIGVALUE := v_clntnum;
      
      else
        obj_PAZDNYPF.ZIGVALUE := obj_cur_Stagetab.Ig_Clntnum;
      
      end if;
      obj_PAZDNYPF.JOBNUM  := i_scheduleNumber;
      obj_PAZDNYPF.JOBNAME := i_scheduleName;
    
      insert into Jd1dta.View_DM_PAZDNYPF values obj_PAZDNYPF;
    end if;
  END LOOP;

  dbms_output.put_line('End execution of BQ9Q5_CL_NAYOCL, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);
  CLOSE Cur_StageTable;
exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'BQ9Q5_CL_NAYOCL : ' || i_scheduleName || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);
  
    raise;
    commit;
END BQ9Q5_CL_NAYOCL;
