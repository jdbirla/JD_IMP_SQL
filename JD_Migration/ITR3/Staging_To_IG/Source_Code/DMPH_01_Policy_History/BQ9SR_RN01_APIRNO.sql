create or replace PROCEDURE BQ9SR_RN01_APIRNO (i_scheduleName   IN VARCHAR2, 
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
 * Amednment History: RN01 Policy Transaction - APIRNO
 * Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       RN#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * AUG17	MKS		  RN1   PA New Implementation
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * FEB04	MKS		  RN2   ITR3 PA Implementation
 *****************************************************************************************************/ 
  --------------------------VARIABLES DECLARATION START---------------------------------------------------------
  --------------------------VARIABLES DECLARATION START---------------------------------------------------------
  v_timestart 		NUMBER := dbms_utility.get_time; --Timecheck
  v_isAnyError		VARCHAR2(1) DEFAULT 'N';
  v_errorCount		NUMBER(1) DEFAULT 0;
  v_space			VARCHAR2(2) DEFAULT ' ';
  v_zero            NUMBER(2) DEFAULT 0;
  v_maxdate         NUMBER(8) DEFAULT 99999999;
  v_refKey			VARCHAR2(100) DEFAULT NULL;
  v_chdrnum			ZAPIRNOPF.CHDRNUM%type;
  v_mbrno			ZAPIRNOPF.MBRNO%type;
  v_zinstype		ZAPIRNOPF.ZINSTYPE%type;
  v_zapirno			ZAPIRNOPF.ZAPIRNO%type;
  v_fullkanjiname	PAZDRNPF.FULLKANJINAME%type;  
  v_tranno			ZTRAPF.TRANNO%type;
  v_dteatt          GMHDPF.DTEATT%type;
  p_exitcode        NUMBER;
  p_exittext        VARCHAR2(200); 
  --------------------------VARIABLES DECLARATION END-----------------------------------------------------------

  --------------------------OBJECT FOR IG TABLES START----------------------------------------------------------
  obj_pazdrnpf    	Jd1dta.VIEW_DM_PAZDRNPF%rowtype;
  obj_zapirnopf		Jd1dta.VIEW_DM_ZAPIRNOPF%rowtype;
--obj_gmhd        	pkg_common_dmmb_phst.OBJ_GMHD;
--obj_newbtran		pkg_common_dmmb_phst.OBJ_NEWBTRAN;

  --------------------------OBJECT FOR IG TABLES END------------------------------------------------------------

  --------------------------CONSTANT VARIABLES START------------------------------------------------------------
  C_limit	   PLS_INTEGER := i_array_size;
  c_errorcount CONSTANT NUMBER := 5;
  c_prefix 	   CONSTANT VARCHAR2(2) := get_migration_prefix('RNHS', i_company);
  c_bq9sr      CONSTANT VARCHAR2(5) := 'BQ9SA';
  c_rqo7       CONSTANT VARCHAR2(4) := 'RQO7';  /*Policy not in IG */ 
  c_rqo6       CONSTANT VARCHAR2(4) := 'RQO6';  /*Duplicated record found*/
  c_rsaz  	   CONSTANT VARCHAR2(5) := 'RSAZ';  /*Only 2 Active Insured are allowed*/
  --------------------------CONSTANT VARIABLES END--------------------------------------------------------------

  --------------------------COMMON FUNCTION START---------------------------------------------------------------
  v_tablenametemp			VARCHAR2(10);
  v_tablename				VARCHAR2(10); 
  itemexist					pkg_dm_common_operations.itemschec;
  o_errortext				pkg_dm_common_operations.errordesc;
  i_zdoe_info				pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues			pkg_dm_common_operations.defaultvaluesmap;
  TYPE ercode_tab			IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER; 
  TYPE errorfield_tab 		IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER; 
  TYPE errormsg_tab 		IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  TYPE errorfieldvalue_tab 	IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  TYPE errorprogram_tab 	IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_ercode			ercode_tab;
  t_errorfield		errorfield_tab;
  t_errormsg		errormsg_tab;
  t_errorfieldval	errorfieldvalue_tab;  
  t_errorprogram	errorprogram_tab; 

--checkpcduprn		pkg_common_dmmb_phst.nrduplicate; --#ZJNPG-9739 - RUAT change
  getgmhdpf         pkg_common_dmmb_phst.gmhdtype;
  getgchd			pkg_common_dmmb_phst.gchdtype1;
--getnewbtran   	pkg_common_dmmb_phst.newbtrantype;
  --------------------------COMMON FUNCTION END-----------------------------------------------------------------   

  --Define a Cursor to read StageDB TITDMGAPIRNO
  CURSOR cur_apirno is
			SELECT * FROM Jd1dta.DMIGTITDMGAPIRNO WHERE RECIDXAPIRNO BETWEEN start_id and end_id;
  obj_apirno cur_apirno%rowtype;
  TYPE t_apirno_list IS TABLE OF cur_apirno%rowtype;
  apirno_list t_apirno_list;

 BEGIN
  dbms_output.put_line('Start Execution of BQ9SR_RN01_APIRNO, SC NO:  ' || i_scheduleNumber || ' Flag :' || i_zprvaldYN); 

  --------------------------COMMON FUNCTION CALLING START------------------------------------------------------
  pkg_dm_common_operations.getdefval(i_module_name   => c_bq9sr,
                                   o_defaultvalues => o_defaultvalues);
--pkg_dm_common_operations.checkitemexist(i_module_name => 'DMRN',
--                                        itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPC',
                                        o_errortext   => o_errortext);									 
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || 
                     LPAD(TRIM(i_scheduleNumber), 4, '0'); 				 
  v_tableName     := TRIM(v_tableNametemp); 
-- NOTE: Uncomment for manual execution
--pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
--pkg_common_dmmb_phst.getgmhdpf(getgmhdpf => getgmhdpf);
--pkg_common_dmmb_phst.getnewbtran(getnewbtran => getnewbtran);
--pkg_common_dmmb_phst.getgchd(getgchd => getgchd);
--pkg_common_dmmb_phst.checkapirnodup(checkpcduprn => checkpcduprn); --#ZJNPG-9739 - RUAT change
  --------------------------COMMON FUNCTION CALLING END--------------------------------------------------------

  --	:= o_defaultvalues('TRANNO');
  --------------------------CURSOR CALLING START---------------------------------------------------------------
  OPEN cur_apirno; 
  LOOP
  FETCH cur_apirno BULK COLLECT INTO apirno_list LIMIT C_limit;

  <<skipRecord>> 
  FOR i IN 1 .. apirno_list.COUNT LOOP

    obj_apirno := apirno_list(i);

  --------------------------INITIALIZATION START---------------------------------------------------------------
	v_chdrnum				:= TRIM(obj_apirno.CHDRNUM);
	v_mbrno					:= TRIM(obj_apirno.MBRNO);
	v_zinstype				:= TRIM(obj_apirno.ZINSTYPE);
	v_zapirno				:= TRIM(obj_apirno.ZAPIRNO);
	v_fullkanjiname			:= TRIM(obj_apirno.FULLKANJINAME);
	v_tranno				:= TRIM(obj_apirno.TRANNO); --RN2

	v_refKey				 := v_chdrnum || '-' || v_mbrno || '-' || v_zinstype || '-' || v_zapirno; --to be remoced || '-' || v_fullkanjiname;
    i_zdoe_info              := Null; 
    i_zdoe_info.i_zfilename  := 'TITDMGAPIRNO'; 
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

	/*IF (getnewbtran.EXISTS(v_chdrnum)) THEN
	  obj_newbtran	:= getnewbtran(v_chdrnum);
	  v_tranno		:= obj_newbtran.TRANNO;
	END IF;*/
/*
    IF (getgmhdpf.exists(v_chdrnum || v_mbrno)) THEN
      obj_gmhd		:= getgmhdpf(v_chdrnum || v_mbrno); --PH12
      v_dteatt		:= obj_gmhd.DTEATT;
    END IF;*/
    v_dteatt := TRIM(obj_apirno.DTEATT);
  --------------------------INITIALIZATION END-----------------------------------------------------------------

  --------------------------PRE-VALIDATION START---------------------------------------------------------------
    --1. Validate Policy Number:
    IF TRIM(TRIM(obj_apirno.GC_CHDRNUM)) IS NULL THEN --#ZJNPG-9739 - RUAT change
      v_isAnyError 					:= 'Y';
      v_errorCount 					:= v_errorCount + 1;
      t_ercode(v_errorCount) 		:= c_rqo7;
      t_errorfield(v_errorCount) 	:= 'CHDRNUM';
      t_errormsg(v_errorCount) 		:= o_errortext(c_rqo7);
      t_errorfieldval(v_errorCount) := v_chdrnum;
      t_errorprogram(v_errorCount) 	:= i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    --2. Check Duplicate Record
	--IF (checkpcduprn.exists(TRIM(v_refKey))) THEN  --#ZJNPG-9739 - RUAT change
   IF TRIM(obj_apirno.PAZ_REC) IS NOT NULL THEN    --#ZJNPG-9739 - RUAT change
      v_isAnyError                 := 'Y'; 
      i_zdoe_info.i_indic          := 'E'; 
      i_zdoe_info.i_error01        := c_rqo6; 
      i_zdoe_info.i_errormsg01     := o_errortext(c_rqo6); 
      i_zdoe_info.i_errorfield01   := 'ZENTITY'; 
      i_zdoe_info.i_fieldvalue01   := v_refKey; 
      i_zdoe_info.i_errorprogram01 := i_scheduleName; 
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info); 
      CONTINUE skipRecord; 
    END IF;

	--3. Member Number validation: must be <= 2
	IF (v_mbrno > '00002') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= C_RSAZ;
      t_errorfield(v_errorcount) 	:= 'MBRNO';
      t_errormsg(v_errorcount) 		:= 'Only 2 Active insured are allowed.';
      t_errorfieldval(v_errorcount) := v_mbrno;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;	

    IF (TRIM(v_dteatt) is NULL) THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= 'PA01';
      t_errorfield(v_errorcount) 	:= 'DTEATT';
      t_errormsg(v_errorcount) 		:= 'Missing DTEATT from GMHDPF';
      t_errorfieldval(v_errorcount) := v_chdrnum || '-' || v_mbrno;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;	
  --------------------------PRE-VALIDATION END-----------------------------------------------------------------

  --------------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF START------------------------------
    <<insertzdoe>>
    IF (v_isanyerror = 'Y') THEN
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
      CONTINUE skiprecord;
    END IF;

	--Insert record in ZDOE table for successfuly validated records.
    IF (v_isanyerror = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;
  --------------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF END---------------------------------

  --------------------------MIGRATION START---------------------------------------------------------------------

	IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN
	---------------------Insert to Registry PAZDRNPF Start------------------------
	  obj_pazdrnpf.ZENTITY			:= v_chdrnum;
	  obj_pazdrnpf.MBRNO			:= v_mbrno;
	  obj_pazdrnpf.ZINSTYPE			:= v_zinstype;
	  obj_pazdrnpf.ZAPIRNO			:= v_zapirno;
	  obj_pazdrnpf.FULLKANJINAME	:= v_fullkanjiname;
	  obj_pazdrnpf.JOBNUM			:= i_scheduleNumber;
	  obj_pazdrnpf.JOBNAME			:= i_scheduleName;

	  INSERT INTO Jd1dta.VIEW_DM_PAZDRNPF VALUES obj_pazdrnpf;
    ---------------------Insert to Registry PAZDRNPF End--------------------------

	---------------------Insert to ZAPIRNOPF Start--------------------------------
	  obj_zapirnopf.CHDRCOY		:= i_company;
	  obj_zapirnopf.CHDRNUM		:= v_chdrnum;
	  obj_zapirnopf.ZINSTYPE	:= v_zinstype;
	  obj_zapirnopf.ZAPIRNO		:= v_zapirno;
	  obj_zapirnopf.MBRNO		:= v_mbrno;
	  obj_zapirnopf.TRANNO		:= v_tranno;
	  obj_zapirnopf.EFFDATE		:= v_dteatt; -- from GMHDPF
	  obj_zapirnopf.DTETRM		:= v_maxdate;
	  obj_zapirnopf.USRPRF		:= i_usrprf;
	  obj_zapirnopf.JOBNM		:= i_scheduleName;
	  obj_zapirnopf.DATIME		:= CAST(sysdate AS TIMESTAMP);

	  INSERT INTO Jd1dta.VIEW_DM_ZAPIRNOPF VALUES obj_zapirnopf;
	---------------------Insert to ZAPIRNOPF End----------------------------------

	END IF;
  --------------------------MIGRATION END----------------------------------------------------------------------- 	

    END LOOP;
    EXIT WHEN cur_apirno%notfound;
    COMMIT;
  END LOOP; 
  CLOSE cur_apirno;  

  dbms_output.put_line('Procedure execution time = ' || 
                       (dbms_utility.get_time - v_timestart) / 100); 

  dbms_output.put_line('End execution of BQ9SR_RN01_APIRNO, SC NO:  ' ||
                        i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9SR_RN01_APIRNO : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      INSERT INTO Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      VALUES
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      COMMIT; 
	  RAISE;
 END BQ9SR_RN01_APIRNO;