create or replace PROCEDURE               BQ9SA_PC01_POLCOV (i_scheduleName   IN VARCHAR2, 
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
 * Amednment History: PC01 Policy Transaction Coverage
 * Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * AUG17	MKS		  PC1   PA New Implementation
 * OCT22	MKS		  ZJNPG-8211   	TRANNO fix for ZTEMPCOVPF and GXHIPF 
 *****************************************************************************************************
 **************  PA ITR#3 DEVELOPMENT  **************************************************************
 * AUG17	MKS		  PC2   PA ITR3 New Implementation
 *****************************************************************************************************/ 
  --------------------------VARIABLES DECLARATION START---------------------------------------------------------
  v_timestart	  NUMBER := dbms_utility.get_time; --Timecheck
  v_isAnyError	  VARCHAR2(1) DEFAULT 'N';
  v_errorCount    NUMBER(1) DEFAULT 0;
  v_space         VARCHAR2(2) DEFAULT ' ';
  v_zero          NUMBER(2) DEFAULT 0;
  v_maxdate       NUMBER(8) DEFAULT 99999999;
  v_migdate       VARCHAR2(6) DEFAULT ' ';
  v_refKey        VARCHAR2(100) DEFAULT NULL;
  v_planno        VARCHAR2(6);
  v_gxhseq		  NUMBER(18,0);
  v_tranno        GXHIPF.TRANNO%type;
  v_tranno_cncl   GXHIPF.TRANNO%type; --ZJNPG-8211
  v_chdrnum       GXHIPF.CHDRNUM%type;
  v_prodtyp       GXHIPF.PRODTYP%type;
  v_ztaxflg       GXHIPF.ZTAXFLG%type;
  v_mbrno         GXHIPF.MBRNO%type;
  v_dtetrm        GXHIPF.DTETRM%type;
  v_cncltranno	  ZTEMPCOVPF.TRANNO%type;
  v_ztrxstsind	  ZTEMPCOVPF.ZTRXSTSIND%type;
  v_prodtyp2      ZSUBCOVDTLS.PRODTYP02%type;
  v_effdcldt      GCHD.EFFDCLDT%type;
  v_statcode      GCHD.STATCODE%type;
  v_zpoltdate     GCHPPF.ZPOLTDATE%type;
  v_zplancde      GMHIPF.ZPLANCDE%type;
  p_exitcode      NUMBER;
  p_exittext      VARCHAR2(2000); 

  ---ITR3 New Variables--
  v_oldchdrnum	  GXHIPF.CHDRNUM%type;
  v_covkey        VARCHAR2(40);
  v_sumprem1      NUMBER(20,0);
  v_sumprem2      NUMBER(20,0);
  v_cnleffdate    ZTRAPF.EFFDATE%type;
  v_zinsrole	  ZINSDTLSPF.ZINSROLE%type;										
  --------------------------VARIABLES DECLARATION END-----------------------------------------------------------

  --------------------------OBJECT FOR IG TABLES START----------------------------------------------------------
  obj_pazdpcpf      Jd1dta.VIEW_DM_PAZDPCPF%rowtype;
  obj_gxhipf      	Jd1dta.GXHIPF%rowtype;
  obj_ztempcovpf    Jd1dta.VIEW_DM_ZTEMPCOVPF%rowtype;
  obj_zsubcovdtls   Jd1dta.VIEW_DM_ZSUBCOVDTLS%rowtype;
  obj_gchd          pkg_common_dmmb_phst.OBJ_GCHD;
  obj_gchp        	pkg_common_dmmb_phst.OBJ_GCHP;
  obj_gmhi        	pkg_common_dmmb_phst.OBJ_GMHI;-- obj_newbtran  obj_cncltran
--obj_newbtran      pkg_common_dmmb_phst.OBJ_NEWBTRAN;
  obj_cncltran      pkg_common_dmmb_phst.OBJ_CNCLTRAN;
  obj_zinsrole      pkg_common_dmmb_phst.OBJ_ZINSROLE;
  --------------------------OBJECT FOR IG TABLES END------------------------------------------------------------

  --------------------------CONSTANT VARIABLES START------------------------------------------------------------
  c_errorcount CONSTANT NUMBER := 5;
  C_limit	   PLS_INTEGER := i_array_size;
  c_prefix 	   CONSTANT VARCHAR2(2) := get_migration_prefix('PCHS', i_company);
  c_bq9sa      CONSTANT VARCHAR2(5) := 'BQ9SA';
  c_rqo7       CONSTANT VARCHAR2(4) := 'RQO7';  /*Policy not in IG */ 
  c_rqo6       CONSTANT VARCHAR2(4) := 'RQO6';  /*Duplicated record found*/
  c_rqnz       CONSTANT VARCHAR2(5) := 'RQNZ';  /*PRODTYP is mandatory*/
  c_rqlu       CONSTANT VARCHAR2(5) := 'RQLU';  /*Product code not in T9797*/
  c_e315       CONSTANT VARCHAR2(5) := 'E315';  /*Must be Y or N*/
  c_rsaz  	   CONSTANT VARCHAR2(5) := 'RSAZ';  /*Only 2 Active Insured are allowed*/
  --------------------------CONSTANT VARIABLES END--------------------------------------------------------------

  --------------------------COMMON FUNCTION START---------------------------------------------------------------
  v_tablenametemp VARCHAR2(10);
  v_tablename     VARCHAR2(10);
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  getgchd         pkg_common_dmmb_phst.gchdtype1;
  getgchppf       pkg_common_dmmb_phst.gchptype;
  getgmhipf       pkg_common_dmmb_phst.gmhitype;
--getnewbtran     pkg_common_dmmb_phst.newbtrantype;
  getcancltran    pkg_common_dmmb_phst.cancltrantype;
  getzinsrole     pkg_common_dmmb_phst.zinsroletype;
--checkpcdup      pkg_common_dmmb_phst.pcduplicate; --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
  checkmainprdcts pkg_common_dmmb_phst.mainprodtyp;	
  TYPE ercode_tab           IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER; 
  TYPE errorfield_tab       IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  TYPE errormsg_tab         IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  TYPE errorfieldvalue_tab 	IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER; 
  TYPE errorprogram_tab     IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_ercode            ercode_tab;
  t_errorfield        errorfield_tab;
  t_errormsg          errormsg_tab;
  t_errorfieldval     errorfieldvalue_tab;  
  t_errorprogram      errorprogram_tab; 
  --------------------------COMMON FUNCTION END-----------------------------------------------------------------    

  --Define a Cursor to read StageDB TITDMGMBRINDP2
  CURSOR cur_cov_polhist is
	  SELECT * FROM Jd1dta.dmigtitdmgmbrindp2
      WHERE RECCHUNCKBINDP2 BETWEEN start_id and end_id
      ORDER BY refnum ASC, mbrno ASC, dpntno ASC, tranno ASC;
  obj_covpolhist cur_cov_polhist%rowtype;
  TYPE t_polcov_list IS TABLE OF cur_cov_polhist%rowtype;
  polcov_list t_polcov_list;

--  TYPE covlist_type IS TABLE OF NUMBER INDEX BY VARCHAR(30);
--  covlist covlist_type;

 BEGIN
  dbms_output.put_line('Start Execution of BQ9SA_PC01_POLCOV, SC NO:  ' || i_scheduleNumber || ' Flag :' || i_zprvaldYN); 

  --------------------------COMMON FUNCTION CALLING START------------------------------------------------------
  pkg_dm_common_operations.getdefval(i_module_name   => c_bq9sa,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMPC',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPC',
                                        o_errortext   => o_errortext);									 
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || 
                     LPAD(TRIM(i_scheduleNumber), 4, '0'); 				 
  v_tableName     := TRIM(v_tableNametemp); 
-- NOTE: Uncomment for manual execution
--pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
--pkg_common_dmmb_phst.getgchd(getgchd => getgchd);
--pkg_common_dmmb_phst.getgchppf(getgchppf => getgchppf);
--pkg_common_dmmb_phst.getgmhipf(getgmhipf => getgmhipf);
--pkg_common_dmmb_phst.getnewbtran(getnewbtran => getnewbtran);
  pkg_common_dmmb_phst.checkmainprdcts(checkmainprdcts => checkmainprdcts); --PC2
  pkg_common_dmmb_phst.getcancltran(getcancltran => getcancltran);
--pkg_common_dmmb_phst.getzinsrole(getzinsrole => getzinsrole);
-- pkg_common_dmmb_phst.checkpcdupl(checkpcdup => checkpcdup); --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
  --------------------------COMMON FUNCTION CALLING END--------------------------------------------------------

  --------------------------VARIABLE INITIALIZATION START------------------------------------------------------
  --v_tranno		:= o_defaultvalues('TRANNO');
  v_planno    	:= o_defaultvalues('PLANNO');
  v_ztrxstsind	:= o_defaultvalues('ZTRXSTSIND');
  v_migdate   	:= TO_CHAR(sysdate, 'YYMMDD');    
  v_oldchdrnum	:= NULL;
  v_covkey      := NULL;
  v_zinsrole	:= NULL;  
  --------------------------VARIABLE INITIALIZATION END  ------------------------------------------------------

  --------------------------CURSOR CALLING START---------------------------------------------------------------
  OPEN cur_cov_polhist; 
  LOOP
  FETCH cur_cov_polhist BULK COLLECT INTO polcov_list LIMIT C_limit;

  <<skipRecord>> 
  FOR i IN 1 .. polcov_list.COUNT LOOP

    obj_covpolhist := polcov_list(i);

  --------------------------INITIALIZATION START---------------------------------------------------------------
    v_prodtyp				:= TRIM(obj_covpolhist.PRODTYP);
    v_ztaxflg				:= TRIM(obj_covpolhist.ZTAXFLG);
    v_mbrno					:= TRIM(obj_covpolhist.MBRNO);
    v_prodtyp2      		:= TRIM(obj_covpolhist.PRODTYP02);
    v_chdrnum				:= TRIM(obj_covpolhist.REFNUM);
	v_tranno				:= TRIM(obj_covpolhist.TRANNO); --PC2
	v_zplancde				:= TRIM(obj_covpolhist.ZPLANCDE); --PC2

    v_refKey                 := v_chdrnum || '-' || v_mbrno || '-' || TRIM(obj_covpolhist.DPNTNO) || '-' || v_prodtyp || '-' || TRIM(obj_covpolhist.EFFDATE);
    i_zdoe_info              := Null; 
    i_zdoe_info.i_zfilename  := 'TITDMGMBRINDP2'; 
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
  --------------------------INITIALIZATION END-----------------------------------------------------------------
    /*
	IF (getnewbtran.EXISTS(v_chdrnum)) THEN
	  obj_newbtran	:= getnewbtran(v_chdrnum);
	  v_tranno		:= obj_newbtran.TRANNO;
	END IF;
	*/
    /*
    IF (getgchd.EXISTS(v_chdrnum)) THEN
      obj_gchd    := getgchd(v_chdrnum);
	  v_effdcldt  := obj_gchd.effdcldt;
	  v_statcode  := obj_gchd.statcode;
    END IF;
    */
     v_effdcldt  := TRIM(obj_covpolhist.effdcldt);
     v_statcode  := TRIM(obj_covpolhist.statcode);
    /* 
    IF (getgchppf.EXISTS(v_chdrnum)) THEN
      obj_gchp		:= getgchppf(v_chdrnum);
      v_zpoltdate	:= obj_gchp.zpoltdate;
    END IF;
    */
    v_zpoltdate	:= TRIM(obj_covpolhist.zpoltdate);
    v_zinsrole := TRIM(obj_covpolhist.zinsrole);

	/* PC2 - Get from TITDMGPOLTRNH
    IF (getgmhipf.EXISTS(v_chdrnum||v_mbrno)) THEN
      obj_gmhi := getgmhipf(v_chdrnum||v_mbrno);
      v_zplancde   := obj_gmhi.zplancde;
    END IF; */ 
  --------------------------PRE-VALIDATION START---------------------------------------------------------------
    --1. Validate Policy Number:
    IF TRIM(v_statcode) IS NULL THEN
      v_isAnyError					:= 'Y';
      v_errorCount					:= v_errorCount + 1;
      t_ercode(v_errorCount)		:= c_rqo7;
      t_errorfield(v_errorCount)	:= 'CHDRNUM';
      t_errormsg(v_errorCount)		:= o_errortext(c_rqo7);
      t_errorfieldval(v_errorCount) := v_chdrnum;
      t_errorprogram(v_errorCount) 	:= i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    --2. Check Duplicate Record
	--IF (checkpcdup.exists(TRIM(v_refKey))) THEN       --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
   IF TRIM(obj_covpolhist.PAZ_REC) IS NOT NULL THEN   --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
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

	--3. Product Code 1st Validation: blank or null
	IF (v_prodtyp) IS NULL OR (v_prodtyp = ' ') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_rqnz;
      t_errorfield(v_errorcount) 	:= 'PRODTYP';
      t_errormsg(v_errorcount) 		:= o_errortext(c_rqnz);
      t_errorfieldval(v_errorcount) := v_prodtyp;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;

	--4. Product Code 2nd Validation: not in T9797
	IF NOT itemexist.EXISTS(TRIM('T9797') || v_prodtyp || i_company) THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_rqlu;
      t_errorfield(v_errorcount) 	:= 'PRODTYP';
      t_errormsg(v_errorcount) 		:= o_errortext(c_rqlu);
      t_errorfieldval(v_errorcount) := v_prodtyp;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;

	--5. Product Code 2 1st Validation: blank or null
/*	IF (v_prodtyp2) IS NULL OR (v_prodtyp2 = ' ') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_rqnz;
      t_errorfield(v_errorcount) 	:= 'PRODTYP';
      t_errormsg(v_errorcount) 		:= o_errortext(c_rqnz);
      t_errorfieldval(v_errorcount) := v_prodtyp2;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;*/

	--6. Product Code 2 2nd Validation: not in T9797
	IF TRIM(v_prodtyp2) IS NOT NULL THEN
	  IF NOT itemexist.EXISTS(TRIM('T9797') || v_prodtyp2 || i_company) THEN
		v_isanyerror 					:= 'Y';
		v_errorcount 					:= v_errorcount + 1;
		t_ercode(v_errorcount) 			:= c_rqlu;
		t_errorfield(v_errorcount) 		:= 'PRODTYP';
		t_errormsg(v_errorcount) 		:= o_errortext(c_rqlu);
		t_errorfieldval(v_errorcount) 	:= v_prodtyp2;
		t_errorprogram(v_errorcount) 	:= i_schedulename;
		IF v_errorcount >= c_errorcount THEN
			GOTO insertzdoe;
		END IF;
	  END IF;		
	END IF;

	--7. Tax Flag Validation: Must be Y or N
	IF TRIM(v_ztaxflg) NOT IN ('Y', 'N') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_e315;
      t_errorfield(v_errorcount) 	:= 'ZTAXFLG';
      t_errormsg(v_errorcount) 		:= o_errortext(c_e315);
      t_errorfieldval(v_errorcount) := v_ztaxflg;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;

	--PC2 8. Applicable product type for Secondary Insured
	IF (v_mbrno = '00002') THEN
	  IF checkmainprdcts.EXISTS(v_prodtyp) THEN
		  v_isanyerror 					:= 'Y';
		  v_errorcount 					:= v_errorcount + 1;
		  t_ercode(v_errorcount) 		:= 'PA03';
		  t_errorfield(v_errorcount) 	:= 'PRODTYP';
		  t_errormsg(v_errorcount) 		:= 'PRODTYP issue for 2nd insured';
		  t_errorfieldval(v_errorcount) := v_prodtyp;
		  t_errorprogram(v_errorcount) 	:= i_schedulename;
		  IF v_errorcount >= c_errorcount THEN
			GOTO insertzdoe;
		  END IF;
	  END IF;
    END IF;	

	--9. Member Number validation: must be <= 2
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

	--Sales Plan Validation
	IF TRIM(obj_covpolhist.zslptyp) IS NULL THEN	
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= 'PA04';
      t_errorfield(v_errorcount) 	:= 'ZPLANCDE';
      t_errormsg(v_errorcount) 		:= 'Not valid Sales Plan';
      t_errorfieldval(v_errorcount) := v_zplancde;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;		

	--Role Validation
	IF TRIM(obj_covpolhist.zslptyp) = 'N' THEN
		--IF getzinsrole.EXISTS(v_chdrnum || v_mbrno || TRIM(obj_covpolhist.DPNTNO)) THEN
		--	obj_zinsrole := getzinsrole(v_chdrnum || v_mbrno || TRIM(obj_covpolhist.DPNTNO)); 
		IF TRIM(v_zinsrole) IS NULL THEN
		  v_isanyerror 					:= 'Y';
		  v_errorcount 					:= v_errorcount + 1;
		  t_ercode(v_errorcount) 		:= 'PA05';
		  t_errorfield(v_errorcount) 	:= 'ZINSROLE';
		  t_errormsg(v_errorcount) 		:= 'ZINSROLE not exst in ZINS';
		  t_errorfieldval(v_errorcount) := v_chdrnum;
		  t_errorprogram(v_errorcount) 	:= i_schedulename;
		  IF v_errorcount >= c_errorcount THEN
            GOTO insertzdoe;
		  END IF;	
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
		-------------------Insert to Registry PAZDPCPF Start---------------------
		obj_pazdpcpf.ZENTITY	:= v_chdrnum;
		obj_pazdpcpf.MBRNO		:= v_mbrno;
		obj_pazdpcpf.DPNTNO		:= TRIM(obj_covpolhist.DPNTNO);
		obj_pazdpcpf.PRODTYP	:= v_prodtyp;
		obj_pazdpcpf.EFFDATE	:= TRIM(obj_covpolhist.EFFDATE);
		obj_pazdpcpf.JOBNUM		:= i_scheduleNumber;
		obj_pazdpcpf.JOBNAME	:= i_scheduleName;

		INSERT INTO Jd1dta.VIEW_DM_PAZDPCPF VALUES obj_pazdpcpf;
		-------------------Insert to Registry PAZDPCPF End-----------------------	

		-------------------Insert to GXHIPF Start--------------------------------
		--SELECT SEQ_GXHIPF.nextval INTO v_gxhseq FROM dual;
        v_gxhseq := SEQ_GXHIPF.nextval; --PerfImprov
		obj_gxhipf.UNIQUE_NUMBER 	:= v_gxhseq;
		obj_gxhipf.CHDRCOY			:= i_company;
		obj_gxhipf.CHDRNUM			:= v_chdrnum;
		obj_gxhipf.MBRNO			:= v_mbrno;	
		obj_gxhipf.PRODTYP			:= v_prodtyp;
		obj_gxhipf.PLANNO			:= o_defaultvalues('PLANNO');
		obj_gxhipf.EFFDATE			:= TRIM(obj_covpolhist.EFFDATE);
		obj_gxhipf.FMLYCDE			:= v_space;
		obj_gxhipf.DTEATT			:= TRIM(obj_covpolhist.EFFDATE);
		obj_gxhipf.DTETRM			:= v_maxdate;
		obj_gxhipf.REASONTRM		:= v_space;
		obj_gxhipf.XCESSSI			:= v_zero;
		obj_gxhipf.APRVDATE			:= TRIM(obj_covpolhist.EFFDATE);
		obj_gxhipf.SPECTRM			:= v_space;
		obj_gxhipf.EXTRPRM			:= v_zero;
		obj_gxhipf.SUMINSU			:= TRIM(obj_covpolhist.HSUMINSU);
		obj_gxhipf.DECFLG			:= v_space;
		obj_gxhipf.TERMID			:= v_space;
		obj_gxhipf.USER_T			:= v_zero;
		obj_gxhipf.TRDT				:= v_migdate;
		obj_gxhipf.TRTM				:= v_migdate;
		obj_gxhipf.TRANNO			:= v_tranno;
		obj_gxhipf.HEADNO			:= v_space;
		obj_gxhipf.DPNTNO			:= TRIM(obj_covpolhist.DPNTNO);
		obj_gxhipf.EMLOAD			:= v_zero;
		obj_gxhipf.OALOAD			:= v_zero;
		obj_gxhipf.BILLACTN			:= v_space;
		obj_gxhipf.IMPAIRCD01		:= v_space;
		obj_gxhipf.IMPAIRCD02		:= v_space;
		obj_gxhipf.IMPAIRCD03		:= v_space;
		obj_gxhipf.RIEMLOAD			:= v_zero;	
		obj_gxhipf.RIOALOAD			:= v_zero;
		obj_gxhipf.USERSI			:= v_zero;
		obj_gxhipf.USRPRF			:= i_usrprf;
		obj_gxhipf.JOBNM			:= i_scheduleName;
		obj_gxhipf.DATIME			:= CAST(sysdate AS TIMESTAMP);
		obj_gxhipf.RIPROCDT			:= v_zero;
		obj_gxhipf.STDPRMLOAD		:= v_zero;
		obj_gxhipf.DTECLAM			:= v_zero;
		obj_gxhipf.NCBSI			:= v_zero;
		obj_gxhipf.LOADREASON		:= v_space;
		obj_gxhipf.MBRIND			:= v_space;
		obj_gxhipf.DPREM			:= TRIM(obj_covpolhist.APREM);
		obj_gxhipf.ZINSTYPE			:= TRIM(obj_covpolhist.ZINSTYPE);
		obj_gxhipf.ZWAITPEDT		:= v_maxdate;
		obj_gxhipf.ZTAXFLG			:= v_ztaxflg;

		--START: PC2 - Change for DTETRM
		IF TRIM(v_statcode) IN ('CA', 'LA') THEN
			--obj_gxhipf.DTETRM		:= v_effdcldt;
			--obj_gxhipf.RIPROCDT	:= v_maxdate;

			IF v_effdcldt <= obj_covpolhist.CRDATE THEN
				obj_gxhipf.DTETRM	:= v_effdcldt;
				obj_gxhipf.RIPROCDT	:= v_maxdate;
			ELSE
				IF obj_covpolhist.periodno = 1 THEN
					obj_gxhipf.DTETRM	:= TO_NUMBER(TO_CHAR(TO_DATE(obj_covpolhist.CRDATE, 'yyyymmdd') + 1, 'yyyymmdd'));
					obj_gxhipf.RIPROCDT	:= v_maxdate;
				ELSE
					obj_gxhipf.DTETRM	:= obj_covpolhist.CCDATE;
					obj_gxhipf.RIPROCDT	:= v_maxdate;
				END IF;
			END IF;
		ELSE
			IF (obj_covpolhist.periodno = 1) AND (obj_covpolhist.periodcnt = 2) THEN
				obj_gxhipf.DTETRM	:= TO_NUMBER(TO_CHAR(TO_DATE(obj_covpolhist.CRDATE, 'yyyymmdd') + 1, 'yyyymmdd'));
				obj_gxhipf.RIPROCDT	:= v_maxdate;	
			ELSE
				obj_gxhipf.DTETRM	:= v_maxdate;
				obj_gxhipf.RIPROCDT	:= v_zero;
			END IF;
		END IF;
		--END: PC2 - Change for DTETRM

		obj_gxhipf.ACCPTDTE	:= obj_gxhipf.DTETRM;

		--Insert to GXHIPF
		INSERT INTO Jd1dta.GXHIPF VALUES obj_gxhipf;
		---------------------Insert to GXHIPF End----------------------------------

		---------------------Insert to ZTEMPCOVPF Start----------------------------

		obj_ztempcovpf.CHDRCOY		:= i_company;
		obj_ztempcovpf.CHDRNUM		:= v_chdrnum;
		obj_ztempcovpf.ALTQUOTENO	:= v_space;
		obj_ztempcovpf.TRANNO		:= v_tranno;
		obj_ztempcovpf.MBRNO		:= v_mbrno;
		obj_ztempcovpf.DPNTNO		:= TRIM(obj_covpolhist.DPNTNO);
		obj_ztempcovpf.PRODTYP		:= v_prodtyp;	
		obj_ztempcovpf.EFFDATE		:= TRIM(obj_covpolhist.EFFDATE);
		obj_ztempcovpf.DTEATT		:= TRIM(obj_covpolhist.EFFDATE);
		obj_ztempcovpf.DTETRM		:= v_maxdate;
		obj_ztempcovpf.SUMINS		:= TRIM(obj_covpolhist.HSUMINSU);
		obj_ztempcovpf.DPREM		:= TRIM(obj_covpolhist.APREM);	
		obj_ztempcovpf.ZWPENDDT		:= v_maxdate;
		--obj_ztempcovpf.ZCHGTYPE	:= 'A';
		obj_ztempcovpf.DSUMIN		:= TRIM(obj_covpolhist.HSUMINSU);
		obj_ztempcovpf.ZSALPLAN		:= v_zplancde;
		obj_ztempcovpf.USRPRF		:= i_usrprf;
		obj_ztempcovpf.JOBNM		:= i_scheduleName;
		obj_ztempcovpf.DATIME		:= CAST(sysdate AS TIMESTAMP);
		obj_ztempcovpf.ZINSTYPE		:= TRIM(obj_covpolhist.ZINSTYPE);
		obj_ztempcovpf.ZCVGSTRTDT	:= obj_ztempcovpf.DTEATT;
		obj_ztempcovpf.ZCVGENDDT	:= obj_ztempcovpf.DTETRM;
		obj_ztempcovpf.ZRFNDSDT		:= obj_ztempcovpf.DTETRM;
		obj_ztempcovpf.ZTRXSTSIND	:= v_ztrxstsind;
		obj_ztempcovpf.ZSMANDTE		:= v_maxdate;

		/*
		IF v_oldchdrnum <> v_chdrnum THEN
			covlist.DELETE;
		END IF;

		v_covkey := v_chdrnum || v_mbrno || TRIM(obj_covpolhist.DPNTNO) || TRIM(obj_covpolhist.ZINSTYPE) || v_prodtyp;

		IF obj_covpolhist.periodno = 1 THEN
			IF obj_covpolhist.periodcnt = 2 THEN -- Policy has renewed data
				covlist(v_covkey) := TRIM(obj_covpolhist.APREM) || TRIM(obj_covpolhist.HSUMINSU);
				obj_ztempcovpf.ZCHGTYPE	:= 'A';
			END IF;
			obj_ztempcovpf.ZCHGTYPE	:= 'A';
		ELSE  -- 2nd policy Period
			v_sumprem2 := TRIM(obj_covpolhist.APREM) || TRIM(obj_covpolhist.HSUMINSU);
			IF covlist.EXISTS(v_covkey) THEN
				v_sumprem1 := covlist(v_covkey);
				IF v_sumprem1 = v_sumprem2 THEN
					obj_ztempcovpf.ZCHGTYPE	:= 'N';
				ELSE
					obj_ztempcovpf.ZCHGTYPE	:= 'C';
				END IF;
			ELSE
				obj_ztempcovpf.ZCHGTYPE	:= 'C';
			END IF;
		END IF;
		*/
		--Change Type Logic
		IF obj_covpolhist.periodno = 1 THEN
			obj_ztempcovpf.ZCHGTYPE	:= 'A';
		ELSE
			obj_ztempcovpf.ZCHGTYPE	:= 'N';
		END IF;

		IF TRIM(obj_covpolhist.zslptyp) = 'N' THEN
			obj_ztempcovpf.ZINSROLE := v_zinsrole;
		ELSE
			IF TRIM(obj_covpolhist.DPNTNO) = '00' THEN
				obj_ztempcovpf.ZINSROLE := '1';
			END IF;

			IF TRIM(obj_covpolhist.DPNTNO) = '01' THEN
				obj_ztempcovpf.ZINSROLE := '2';
			END IF;

			IF TRIM(obj_covpolhist.DPNTNO) = '02' THEN
				obj_ztempcovpf.ZINSROLE := '3';
			END IF;
		END IF;

		--v_oldchdrnum := v_chdrnum;
		--Insert to ZTEMPCOVPF
		INSERT INTO VIEW_DM_ZTEMPCOVPF VALUES obj_ztempcovpf;	

		-- Approved Cancellation is Found:
		IF (getcancltran.EXISTS(v_chdrnum)) THEN
			obj_cncltran	:= getcancltran(v_chdrnum);
			v_tranno_cncl				:= obj_cncltran.TRANNO; --ZJNPG-8211
			v_cnleffdate				:= obj_cncltran.EFFDATE; --PC2

			IF v_cnleffdate <= obj_covpolhist.CRDATE THEN
				obj_ztempcovpf.DTETRM		:= v_zpoltdate;
				obj_ztempcovpf.ZCHGTYPE		:= 'T';

				--For Policy which are cancelled already
				IF TRIM(v_statcode) = 'CA' THEN
					obj_ztempcovpf.DTETRM		  := v_effdcldt;
				END IF;
				obj_ztempcovpf.TRANNO		:= v_tranno_cncl; --ZJNPG-8211
				obj_ztempcovpf.ZCVGENDDT	:= obj_ztempcovpf.DTETRM;
				obj_ztempcovpf.ZRFNDSDT		:= obj_ztempcovpf.DTETRM;

				--Insert to ZTEMPCOVPF
				INSERT INTO VIEW_DM_ZTEMPCOVPF VALUES obj_ztempcovpf;
			END IF;
		END IF; 	
		---------------------Insert to ZTEMPCOVPF End------------------------------

		---------------------Insert to ZSUBCOVDTLS Start---------------------------
		IF TRIM(obj_covpolhist.NDRPREM) > 0 THEN
			obj_zsubcovdtls.CHDRCOY		  := i_company;
			obj_zsubcovdtls.CHDRNUM		  := v_chdrnum;
			obj_zsubcovdtls.ALTQUOTENO	  := v_space;
			obj_zsubcovdtls.MBRNO		  := v_mbrno;
			obj_zsubcovdtls.DPNTNO		  := TRIM(obj_covpolhist.DPNTNO);
			obj_zsubcovdtls.TRANNO		  := v_tranno;
			obj_zsubcovdtls.EFFDATE		  := TRIM(obj_covpolhist.EFFDATE);
			obj_zsubcovdtls.PRODTYP01	  := v_prodtyp;
			obj_zsubcovdtls.PRODTYP02	  := v_prodtyp2;
			obj_zsubcovdtls.DPREM		  := TRIM(obj_covpolhist.NDRPREM);
			obj_zsubcovdtls.ZTRXSTSIND	  := v_ztrxstsind;
			obj_zsubcovdtls.USRPRF		  := i_usrprf;
			obj_zsubcovdtls.JOBNM		  := i_scheduleName;
			obj_zsubcovdtls.DATIME		  := CAST(sysdate AS TIMESTAMP);

			--Insert to ZSUBCOVDTLS
			INSERT INTO VIEW_DM_ZSUBCOVDTLS VALUES obj_zsubcovdtls;
		END IF;
		---------------------Insert to ZSUBCOVDTLS End-----------------------------

	  END IF;
  --------------------------MIGRATION END----------------------------------------------------------------------- 	
    END LOOP;
    EXIT WHEN cur_cov_polhist%notfound;
    --COMMIT; --Ticket #ZJNPG-9739: Comment this out due to ORA-01555. But monitor in future migration.
  END LOOP; 
  COMMIT;
  CLOSE cur_cov_polhist;  

  dbms_output.put_line('Procedure execution time = ' || 
                       (dbms_utility.get_time - v_timestart) / 100); 

  dbms_output.put_line('End execution of BQ9SA_PC01_POLCOV, SC NO:  ' ||
                        i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9SA_PC01_POLCOV : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      INSERT INTO Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      VALUES
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      COMMIT; 
	  RAISE;
 END BQ9SA_PC01_POLCOV;