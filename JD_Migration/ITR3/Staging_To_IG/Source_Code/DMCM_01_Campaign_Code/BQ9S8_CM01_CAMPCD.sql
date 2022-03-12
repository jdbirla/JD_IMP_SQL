create or replace PROCEDURE Jd1dta.BQ9S8_CM01_CAMPCD(i_scheduleName   IN VARCHAR2,
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
		* Amendment History: CM01 Campaign Code
		* Date    Initials   Tag   Decription
		* -----   --------   ---   ---------------------------------------------------------------------------
		* MMMDD    XXX       CM0   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		* Mar27    SRI       CM1   PA New Implementation
		* Feb26	   Prabu	 CM2   ITR3 FT fixes to default the status to AP as per the MSD
		* Mar10	   MKS		 CM3   Performance Improvement
        * Jul07    Prabu     CM4   ZJNPG-9739 Memory issue on registry table fix
		*****************************************************************************************************/
		-- Local Variables Declaration for Campaign Code START ------------
		v_timestart 			NUMBER := dbms_utility.get_time;
		v_isDuplicate       	NUMBER(1) DEFAULT 0;
		v_isValid          		NUMBER(1) DEFAULT 0;
		v_isDateValid       	VARCHAR2(20 CHAR);
		v_isAnyError        	VARCHAR2(1) DEFAULT 'N';
		v_errorCount        	NUMBER(1) DEFAULT 0;
		v_zcmpcode 				VARCHAR2(6 CHAR);
		v_temp_zcmpcode 		VARCHAR2(6 CHAR);
		v_zcmpcode_cc 			VARCHAR2(6 CHAR);
		v_zcmpcode_len			NUMBER;
		v_zcmpcode_len1			NUMBER;
		v_isendrcodeexist     	NUMBER(1) DEFAULT 0;
		v_issalesplanexist		NUMBER DEFAULT 0;
		v_ispolicyexist       	NUMBER(1) DEFAULT 0;
		v_isagency_ptrn_exist 	NUMBER(1) DEFAULT 0;
		v_refKey				VARCHAR2(6 CHAR);
		v_zcrtusr				VARCHAR2(10 CHAR);
		v_zappdate				NUMBER(8,0);
		v_zccodind				VARCHAR2(1 CHAR);
		v_effdate				NUMBER(8,0);
		v_status				VARCHAR2(2 CHAR);
		p_exitcode         		NUMBER;
		p_exittext         		VARCHAR2(200);
        v_SEQ_ZCSLPF     zcslpf.unique_number%type;
		-- Local Variables Declaration for Campaign Code END ------------
		
		-- Local Variables Declaration for Sales Plan2 START --------------------
    
		b_isError2  			VARCHAR2(1) DEFAULT 'N';
		n_isValid     			NUMBER(1) DEFAULT 0;
		isDuplicate   			NUMBER(1) DEFAULT 0;
		v_code        			NUMBER;
		v_errm        			VARCHAR2(64 CHAR);
		v_errorCount2 			NUMBER(1) DEFAULT 0;
		n_zcampcode   			NUMBER(3) DEFAULT 0;
		v_pkValue				NUMBER(18,0);
		v_zsalplan2 			VARCHAR2(30 CHAR);
		v_OLD_ZSALPLAN			VARCHAR2(30 CHAR);
		v_zcmpcode1 			VARCHAR2(6 CHAR);
		v_zcmpcode_sp2 			VARCHAR2(6 CHAR);
  
		-- Local Variables Declaration for Sales Plan2 END --------------------
    
		------Define Constant to read Start for Campaign Code -------
		C_PREFIX     	CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CMCD',i_company); /* Migration Prefix for Campaign CODE */
		C_ERRORCOUNT 	CONSTANT NUMBER := 5;
		C_TQ9BR  		CONSTANT VARCHAR2(5 CHAR) := 'TQ9BR'; /* Campaign Vehicle */
		C_TQ9R9  		CONSTANT VARCHAR2(5 CHAR) := 'TQ9R9'; /* Campaign Stage */
		C_TQ9RA  		CONSTANT VARCHAR2(6 CHAR) := 'TQ9RA'; /* Campaign Scheme-1 */
		C_TQ9RB  		CONSTANT VARCHAR2(6 CHAR) := 'TQ9RB'; /* Campaign Scheme-2 */
		C_T9799  		CONSTANT VARCHAR2(5 CHAR) := 'T9799'; /* Policy Type */
		C_Z010 			CONSTANT VARCHAR2(4) := 'RQLQ'; /*Endorser Code Not Valid */
		C_Z013 			CONSTANT VARCHAR2(4) := 'RQLT'; /* Invalid Date*/
		C_Z036 			CONSTANT VARCHAR2(4) := 'RQMG'; /*Invalid Grp Master */
		C_Z037 			CONSTANT VARCHAR2(4) := 'RQMH'; /*Invalid Product code */
		C_Z058 			CONSTANT VARCHAR2(4) := 'RQN2'; /* Must be G or I only.*/
		C_Z059 			CONSTANT VARCHAR2(4) := 'RQN3'; /* Invalid Agency Pattern ID*/
		C_Z060 			CONSTANT VARCHAR2(4) := 'RQN4'; /*Must be in TQ9RA */--UPDATE THE ERROR DESCRIPTION
		C_Z099 			CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicate record found. */
		C_Z133 			CONSTANT VARCHAR2(4) := 'RQZO'; /*Campaign Code is mandatory	                */ 
		C_Z134 			CONSTANT VARCHAR2(4) := 'RQZP'; /*Pet name is mandatory	                    */ 
		C_Z135 			CONSTANT VARCHAR2(4) := 'RQZQ'; /*Policy Classification is mandatory		    */ 
		C_Z136 			CONSTANT VARCHAR2(4) := 'RQZR'; /*Endorser Code is mandatory		            */ 
		C_Z137 			CONSTANT VARCHAR2(4) := 'RQZS'; /*Group Policy Number is mandatory.		    */ 
		C_Z138 			CONSTANT VARCHAR2(4) := 'RQZT'; /*Product Code is mandatory.		            */ 
		C_Z139 			CONSTANT VARCHAR2(4) := 'RQZU'; /*Agent Pattern ID is mandatory.		        */ 
		C_Z140 			CONSTANT VARCHAR2(4) := 'RQZV'; /*Risk Commencement is mandatory.		    */ 
		C_Z141 			CONSTANT VARCHAR2(4) := 'RQZW'; /*Campaign Period(From) is mandatory.		 */
		C_Z142 			CONSTANT VARCHAR2(4) := 'RQZX'; /*Campaign Period(To) is mandatory.		    */ 
		C_Z143 			CONSTANT VARCHAR2(4) := 'RQZY'; /*Mailout Date is mandatory.		            */ 
		C_Z144 			CONSTANT VARCHAR2(4) := 'RQZZ'; /*Announce Closure Date is mandatory.		 */
		C_Z145 			CONSTANT VARCHAR2(4) := 'RR01'; /*Delivery Date Campaign Data is mandatory. */
		C_Z146 			CONSTANT VARCHAR2(4) := 'RR02'; /*Campaign Stage not in TQ9R9.		   */ 
		C_Z147 			CONSTANT VARCHAR2(4) := 'RR03'; /*Campaign Scheme 2 not in TQ9RB.	  */ 
		C_Z148 			CONSTANT VARCHAR2(4) := 'RR04'; /*Creation User is mandatory.		      */ 
		C_Z149 			CONSTANT VARCHAR2(4) := 'RR05'; /*Campaign Approval Date is mandatory.	*/
		C_Z150 			CONSTANT VARCHAR2(4) := 'RR06'; /*Must be ‘PN’ or ‘AP’ only.		      */ 
		C_Z028 			CONSTANT VARCHAR2(4) := 'RQM8'; /*Value must be ‘Y’ or ‘N’    */ 
		C_Z151 			CONSTANT VARCHAR2(4) := 'RQQX'; /*Invalid Vehicle   */ 
		C_limit	   PLS_INTEGER := i_array_size; --CR3

		------Define Constant to read END for Campaign Code -------

		------Define Constant to read Start for Sales Plan2-------
		C_Z040   CONSTANT VARCHAR2(4) := 'RQMK'; /* SalePlan must not be blank */
		C_Z098   CONSTANT VARCHAR2(4) := 'RQO6'; /* Duplicate Record Found */
		C_Z041   CONSTANT VARCHAR2(4) := 'RQML'; /*Campaign Code is mandatory	  */ 
		C_RQY9   CONSTANT VARCHAR2(4) := 'RQY9'; /* 'C-Code Mismatch' */
		C_RQM1   CONSTANT VARCHAR2(4) := 'RQM1'; /* Campaign Code not Valid */
  
		------Define Constant to read END for Sales Plan2-------

		--------Null and spaces START-----------
		-- For Campaign Code & Sales Plan2: Not Applicable
 
		
  
		------IG table obj start-----------------
		obj_zcpnpf Jd1dta.ZCPNPF%rowtype;
		obj_zcslpf Jd1dta.ZCSLPF%rowtype;
		obj_VIEW_DM_ZCPNPF Jd1dta.VIEW_DM_ZCPNPF%rowtype;
		obj_VIEW_DM_ZDROPF Jd1dta.VIEW_DM_PAZDROPF%rowtype;
		obj_zcpnpf1	pkg_common_dmcm.OBJ_ZCPNPF;
		------IG table obj End----------------

  --------------Common Function Start---------
	  v_tableNametemp 		VARCHAR2(10);
	  v_tableName     		VARCHAR2(10);
	  itemexist    pkg_dm_common_operations.itemschec;
	  o_errortext  pkg_dm_common_operations.errordesc;
	  i_zdoe_info  pkg_dm_common_operations.obj_zdoe;
--	  checkchdrnum pkg_common_dmcm.gchdtype; --CR3
--	  checkdupl    pkg_common_dmcm.cmduplicate; -- CM4
	  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
	  t_ercode ercode_tab;
	  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
	  t_errorfield errorfield_tab;
	  type errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
	  t_errormsg errormsg_tab;
	  type errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
	  t_errorfieldval errorfieldvalue_tab;
	  type errorprofram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
	  t_errorprogram errorprofram_tab;
	  getzcpnpf1		PKG_COMMON_DMCM.zcpnpftype;--CR3	
	  checkZCSLPF1		PKG_COMMON_DMCM.ZCSLPFtype;--CR3	
  ---------------Common Function end-----------
  
  -- Define a Cursor to read StageDB TITDMGCAMPCDE
  -- Below cursor is changed for CM4
 /* CURSOR cur_campaign_code IS
    SELECT * FROM Jd1dta.DMIGTITDMGCAMPCDE --CM3
	WHERE recidxcamp BETWEEN start_id AND end_id; --CM3
  */

    CURSOR cur_campaign_code IS
    SELECT cm.*,rcm.zentity mig_cm FROM Jd1dta.DMIGTITDMGCAMPCDE cm left outer join
    Jd1dta.view_dm_pazdropf rcm on cm.zcmpcode = rcm.zentity
                               and rcm.prefix = 'CM'
	WHERE recidxcamp BETWEEN start_id AND end_id;  
  
  obj_campaigncode cur_campaign_code%rowtype;
  TYPE t_campcde_list IS TABLE OF cur_campaign_code%rowtype; --CM3
  cmpcde_list t_campcde_list; --CM3


   -- Define a Cursor to read StageDB TITDMGZCSLPF
  CURSOR salesPlan_cursor2 IS
      SELECT * FROM Jd1dta.DMIGTITDMGZCSLPF --CM3
	  WHERE recchunknum BETWEEN start_id AND end_id; --CM3
  obj_salesPlan2 salesPlan_cursor2%rowtype;
  TYPE t_salpln_list IS TABLE OF salesPlan_cursor2%rowtype; --CM3
  salpln_list t_salpln_list; --CM3 


BEGIN
  dbms_output.put_line('Start Execution of BQ9S8_CM01_CAMPCD, SC NO:  ' ||
                         i_scheduleNumber || ' Flag :' || i_zprvaldYN);

   --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------

  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCM',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCM',
                                        o_errortext   => o_errortext);
--  pkg_common_dmcm.checkmasterpol(checkchdrnum => checkchdrnum); --CR3: add to loading
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
--  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName); --CM3
--  pkg_common_dmcm.checkcmdup(checkdupl => checkdupl);-- CM4
   
  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------
  OPEN cur_campaign_code; 
  LOOP
	--CR3: Apply Bulk Collect: START--
    FETCH cur_campaign_code BULK COLLECT INTO cmpcde_list LIMIT C_limit;
    --EXIT WHEN cur_campaign_code%notfound;
	<<skipRecord>>
	FOR i IN 1..cmpcde_list.COUNT LOOP

	obj_campaigncode := cmpcde_list(i);
	--CR3: Apply Bulk Collect: END-- 

    v_zcmpcode := obj_campaigncode.zcmpcode;
    v_zcmpcode_len := LENGTH(TRIM(v_zcmpcode));
	IF v_zcmpcode_len = 5 THEN
		v_zcmpcode_cc := substr(TRIM(v_zcmpcode),1,5)||'0';
	ELSIF v_zcmpcode_len = 6 THEN
		v_zcmpcode_cc := TRIM(v_zcmpcode);
	ELSE
		dbms_output.put_line('Invalid Campaign Code = '|| TRIM(v_zcmpcode));
	END IF;
	
	
    v_refKey   		:= TRIM(v_zcmpcode);
 --   v_zcrtusr       := TRIM(obj_campaigncode.ZCRTUSR);   /*Creation User */
    v_zappdate      := TRIM(obj_campaigncode.ZAPPDATE);  /*Campaign Approval Date */
    v_effdate       := TRIM(obj_campaigncode.EFFDATE); /*Effective Date */
    v_status        := TRIM(obj_campaigncode.STATUS);   /*Status */

	
    ----------Initialization  START for Campaign Code-------
    i_zdoe_info              	:= Null;
    i_zdoe_info.i_zfilename  	:= 'TITDMGCAMPCDE';
    i_zdoe_info.i_prefix     	:= C_PREFIX;
    i_zdoe_info.i_scheduleno 	:= i_scheduleNumber;
    i_zdoe_info.i_refKey     	:= v_refKey;
    i_zdoe_info.i_tableName  	:= v_tableName;
    v_isAnyError 				:= 'N';
    v_errorCount 				:= 0;
    t_ercode(1) 				:= null;
    t_ercode(2) 				:= null;
    t_ercode(3) 				:= null;
    t_ercode(4) 				:= null;
    t_ercode(5) 				:= null;
	----------Initialization  END for Campaign Code-------
 
	-- Validatin Of Fields: Start----------- 
	-- 1) CHECK IF ZCMPCODE-Campaign Code  IS BLANK or NULL---
	IF (TRIM(v_zcmpcode) IS NULL) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z133;
		  t_errorfield(v_errorCount) := 'ZCMPCODE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z133);
		  t_errorfieldval(v_errorCount) := v_zcmpcode;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;
    
    -- 2) Check for Duplicate records
    -- Below condition is changed for CM4
	--IF (checkdupl.exists(TRIM(v_zcmpcode))) THEN
     IF obj_campaigncode.mig_cm is not null then
		  v_isAnyError                 := 'Y';
		  i_zdoe_info.i_indic          := 'E';
		  i_zdoe_info.i_error01        := C_Z099;
		  i_zdoe_info.i_errormsg01     := o_errortext(C_Z099);
		  i_zdoe_info.i_errorfield01   := 'ZCMPCODE';
		  i_zdoe_info.i_fieldvalue01   := v_zcmpcode;
		  i_zdoe_info.i_errorprogram01 := i_scheduleName;
		  pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
		  CONTINUE skipRecord;

    END IF;
    


	--3) CHECK IF ZPETNAME-Pet Name IS BLANK-----
	IF (TRIM(obj_campaigncode.ZPETNAME) IS NULL) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z134;
		  t_errorfield(v_errorCount) := 'ZPETNAME';
		  t_errormsg(v_errorCount) := o_errortext(C_Z134);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZPETNAME;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

	-- 4) CHECK IF ZPOLCLS-Policy Classification  IS BLANK-----
	IF (TRIM(obj_campaigncode.ZPOLCLS) IS NULL) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z135;
		  t_errorfield(v_errorCount) := 'ZPOLCLS';
		  t_errormsg(v_errorCount) := o_errortext(C_Z135);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZPOLCLS;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


    -- 5) Policy Classification  Validation
    IF (TRIM(obj_campaigncode.zpolcls) IS NOT NULL AND
       ((TRIM(obj_campaigncode.zpolcls) <> 'G') AND
       (TRIM(obj_campaigncode.zpolcls) <> 'I'))) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z058;
		  t_errorfield(v_errorCount) := 'ZCMPCODE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z058);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zpolcls;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;

    END IF;


	-- 6) CHECK IF ZENDCODE-Endorser Code  IS BLANK-----
	IF (TRIM(obj_campaigncode.ZENDCODE) IS NULL) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z136;
		  t_errorfield(v_errorCount) := 'ZENDCODE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z136);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZENDCODE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

    -- 7) Endorser Code  Validation

    --SELECT count(*) into v_isendrcodeexist FROM Jd1dta.ZENDRPF --CR3
	--	where TRIM(zendcde) = TRIM(obj_campaigncode.zendcode); --CR3

    --IF (v_isendrcodeexist < 1) THEN --CR3
	IF TRIM(obj_campaigncode.zendcode) IS NULL THEN --CR3
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z010;
		  t_errorfield(v_errorCount) := 'ZENDCDE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z010);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zendcode;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;


	--8) Group CHDRNUM-Policy Number is a mandatory field if Policy Classification = ‘G’---
	IF ((TRIM(obj_campaigncode.ZPOLCLS) = 'G') AND (TRIM(obj_campaigncode.CHDRNUM) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z137;
		  t_errorfield(v_errorCount) := 'CHDRNUM';
		  t_errormsg(v_errorCount) := o_errortext(C_Z137);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.CHDRNUM;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

    --9) Group Policy Number Validation

	IF (TRIM(obj_campaigncode.ZPOLCLS) = 'G') THEN
		IF TRIM(obj_campaigncode.gc_chdrnum) IS NULL THEN --CR3
		--IF NOT (checkchdrnum.exists(TRIM(obj_campaigncode.chdrnum) || --CR3
									--TRIM(i_company))) THEN --CR3
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z036;
		  t_errorfield(v_errorCount) := 'CHDRNUM';
		  t_errormsg(v_errorCount) := o_errortext(C_Z036);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.chdrnum;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;

		END IF;
	END IF;

	-- 10) Group GPOLTYP-Product Code is a mandatory field if Policy Classification = ‘I’---
	IF ((TRIM(obj_campaigncode.ZPOLCLS) = 'I') AND (TRIM(obj_campaigncode.GPOLTYP) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z138;
		  t_errorfield(v_errorCount) := 'GPOLTYP';
		  t_errormsg(v_errorCount) := o_errortext(C_Z138);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.GPOLTYP;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

    --11) Product Code Validation
    IF NOT
        (itemexist.exists(TRIM(C_T9799) || TRIM(obj_campaigncode.gpoltyp) || 1)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z037;
		  t_errorfield(v_errorCount) := 'GPOLTYP';
		  t_errormsg(v_errorCount) := o_errortext(C_Z037);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.gpoltyp;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;

    END IF;


	--12) Group ZAGPTID-Agent Pattern ID is a mandatory field if Policy Classification = ‘I’.---
	IF ((TRIM(obj_campaigncode.ZPOLCLS) = 'I') AND (TRIM(obj_campaigncode.ZAGPTID) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z139;
		  t_errorfield(v_errorCount) := 'ZAGPTID';
		  t_errormsg(v_errorCount) := o_errortext(C_Z139);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZAGPTID;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

    --13) Agency Pattern ID Validation
    /* CR3: Add this query to cursor
	select count(*) into v_isagency_ptrn_exist from Jd1dta.ZAGPPF 
		where TRIM(ZAGPTPFX) = TRIM('AP')
		   and TRIM(ZAGPTNUM) = TRIM(obj_campaigncode.zagptid)
		   and TRIM(ZAGPTCOY) = TRIM(i_company)
		   and TRIM(VALIDFLAG) = TRIM('1');
	*/	   

		  IF ((TRIM(obj_campaigncode.ZPOLCLS) = 'I') and (TRIM(obj_campaigncode.zagptnum) IS NULL))THEN --CR3
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z059;
		  t_errorfield(v_errorCount) := 'ZAGPTID';
		  t_errormsg(v_errorCount) := o_errortext(C_Z059);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zagptid;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;



	--14) Group RCDATE-Risk Commencement Date is a mandatory field if Policy Classification = ‘G’ or ‘I’.---
	IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.RCDATE) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z140;
		  t_errorfield(v_errorCount) := 'RCDATE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z140);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.RCDATE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


    --15) Risk Commencement Date Validation
	v_isDateValid := VALIDATE_DATE(obj_campaigncode.rcdate);
	IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'RCDATE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.rcdate;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;

	--16) Group ZCMPFRM-Campaign Period(From) is a mandatory field if Policy Classification = ‘G’ or ‘I’.---
	IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.ZCMPFRM) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z141;
		  t_errorfield(v_errorCount) := 'ZCMPFRM';
		  t_errormsg(v_errorCount) := o_errortext(C_Z141);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZCMPFRM;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


    --17) Campaign Period(From) Validation
    v_isDateValid := VALIDATE_DATE(obj_campaigncode.zcmpfrm);
    IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZCMPFRM';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zcmpfrm;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;


	--18) Group ZCMPTO-Campaign Period(To) is a mandatory field if Policy Classification = ‘G’ or ‘I’.---
	IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.ZCMPTO) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z142;
		  t_errorfield(v_errorCount) := 'ZCMPTO';
		  t_errormsg(v_errorCount) := o_errortext(C_Z142);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZCMPTO;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


    --19) Campaign Period (To) Validation
    v_isDateValid := VALIDATE_DATE(obj_campaigncode.zcmpto);
    IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZCMPTO';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zcmpto;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;



	--20) Group ZMAILDAT-Mailout Date is a mandatory field if Policy Classification = ‘G’ or ‘I’..---
	IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.ZMAILDAT) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z143;
		  t_errorfield(v_errorCount) := 'ZMAILDAT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z143);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZMAILDAT;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

    --21) Mailout Date Validation
    v_isDateValid := VALIDATE_DATE(obj_campaigncode.zmaildat);
    IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZMAILDAT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zmaildat;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;

	--22) Group ZACLSDAT-Announce Closure Date is a mandatory field if Policy Classification = ‘G’ or ‘I’.---
	 IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.ZACLSDAT) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z144;
		  t_errorfield(v_errorCount) := 'ZACLSDAT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z144);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZACLSDAT;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
		END IF;


    --23) Announced Closure Date validation
    v_isDateValid := VALIDATE_DATE(obj_campaigncode.zaclsdat);
    IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZACLSDAT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zaclsdat;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;



	--24) Group ZDLVCDDT-Delivery Date Campaign Data is a mandatory field if Policy Classification = ‘G’ or ‘I’..---
	IF (((TRIM(obj_campaigncode.ZPOLCLS) = 'G') OR (TRIM(obj_campaigncode.ZPOLCLS) = 'I')) AND (TRIM(obj_campaigncode.ZDLVCDDT) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z145;
		  t_errorfield(v_errorCount) := 'ZDLVCDDT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z145);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZDLVCDDT;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


    --25) Delivery Date Campaign Date validation
    v_isDateValid := VALIDATE_DATE(obj_campaigncode.zdlvcddt);
    IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZDLVCDDT';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.zdlvcddt;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
    END IF;


	--26) Group ZSTAGE-Stage	Must be in table TQ9R9.---
	IF NOT (itemexist.exists(TRIM(C_TQ9R9) || TRIM(obj_campaigncode.ZSTAGE) || 1)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z146;
		  t_errorfield(v_errorCount) := 'ZSTAGE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z146);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZSTAGE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

	--27) Group ZSCHEME01  -Campaign scheme 1	Must be in table TQ9RA.---
	IF NOT (itemexist.exists(TRIM(C_TQ9RA) || TRIM(obj_campaigncode.ZSCHEME01) || 1)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z060;
		  t_errorfield(v_errorCount) := 'ZSCHEME01';
		  t_errormsg(v_errorCount) := o_errortext(C_Z060);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZSCHEME01;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

	--28) Group ZSCHEME02-Campaign scheme 2	Must be in table TQ9RB.---
	IF NOT (itemexist.exists(TRIM(C_TQ9RB) || TRIM(obj_campaigncode.ZSCHEME02) || 1)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z147;
		  t_errorfield(v_errorCount) := 'ZSCHEME02';
		  t_errormsg(v_errorCount) := o_errortext(C_Z147);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZSCHEME02;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


	--29) Group ZCRTUSR-Creation User is a mandatory field. Must not be blank.---
	IF ((TRIM(obj_campaigncode.ZCRTUSR) IS NULL)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z148;
		  t_errorfield(v_errorCount) := 'ZCRTUSR';
		  t_errormsg(v_errorCount) := o_errortext(C_Z148);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZCRTUSR;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


	--30) Group ZAPPDATE-Campaign Approval Date is a mandatory field. Must not be blank.---
	IF (TRIM(obj_campaigncode.ZAPPDATE) IS NULL) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z149;
		  t_errorfield(v_errorCount) := 'ZAPPDATE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z149);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZAPPDATE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;


	--31) Group ZAPPDATE-Must be a valid date and in correct format YYYYMMDD---
	v_isDateValid := VALIDATE_DATE(obj_campaigncode.ZAPPDATE);
	IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'ZAPPDATE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZAPPDATE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

	--32) Group ZCCODIND-Must be ‘Y’ or ‘N’---
	 IF ((TRIM(obj_campaigncode.ZCCODIND) <> 'Y') AND (TRIM(obj_campaigncode.ZCCODIND) <> 'N')) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z028;
		  t_errorfield(v_errorCount) := 'ZCCODIND';
		  t_errormsg(v_errorCount) := o_errortext(C_Z028);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZCCODIND;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;

	--33) Group EFFDATE-Agent Pattern ID is a mandatory field if Policy Classification = ‘I’.---
	v_isDateValid := VALIDATE_DATE(obj_campaigncode.EFFDATE);
	IF v_isDateValid <> 'OK' THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z013;
		  t_errorfield(v_errorCount) := 'EFFDATE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z013);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.EFFDATE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;
/* CM2 changes, no need of validation for the status as the campaign code status is always set as AP as per the MSD

	--34) Group STATUS-Valid Value = ‘PN’ (Pending) or ‘AP’(Approved)---
	IF ((TRIM(obj_campaigncode.STATUS) <> 'PN') AND (TRIM(obj_campaigncode.STATUS) <> 'AP')) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z150;
		  t_errorfield(v_errorCount) := 'STATUS';
		  t_errormsg(v_errorCount) := o_errortext(C_Z150);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.STATUS;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
			GOTO insertzdoe;
		  END IF;
	END IF;
	*/
	
	--35) CHECK IF VEHICLE Must be in table TQ9RB or NOT---
	IF NOT (itemexist.exists(TRIM(C_TQ9BR) || TRIM(obj_campaigncode.ZVEHICLE) || 1)) THEN
		  v_isAnyError := 'Y';
		  v_errorCount := v_errorCount + 1;
		  t_ercode(v_errorCount) := C_Z151;
		  t_errorfield(v_errorCount) := 'ZVEHICLE';
		  t_errormsg(v_errorCount) := o_errortext(C_Z151);
		  t_errorfieldval(v_errorCount) := obj_campaigncode.ZVEHICLE;
		  t_errorprogram(v_errorCount) := i_scheduleName;
		  IF v_errorCount >= C_ERRORCOUNT THEN
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
      CONTINUE skipRecord;
    END IF;
    IF (v_isAnyError = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;

    ----Common Business logic for inserting into ZDOEPF---

    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN

      ---Insert into Data Migration Registry  table - PAZDROPF START ---------
            
		obj_VIEW_DM_ZDROPF.RECSTATUS := 'NEW';
        obj_VIEW_DM_ZDROPF.PREFIX    := 'CM';
        obj_VIEW_DM_ZDROPF.ZENTITY   := v_zcmpcode;
        obj_VIEW_DM_ZDROPF.ZIGVALUE  := v_zcmpcode_cc;
        obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
        obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
        Insert into Jd1dta.VIEW_DM_PAZDROPF values obj_VIEW_DM_ZDROPF;
		
	 ---Insert into Data Migration Registry  table - PAZDROPF END ---------
        
      ------Insert Into IG table: ZCPNPF START ---------------------
      
		obj_VIEW_DM_ZCPNPF.ZCMPCODE := v_zcmpcode_cc;
		obj_VIEW_DM_ZCPNPF.ZPETNAME := obj_campaigncode.zpetname;
        obj_VIEW_DM_ZCPNPF.ZPOLCLS 	:= obj_campaigncode.zpolcls;
        obj_VIEW_DM_ZCPNPF.ZENDCDE 	:= obj_campaigncode.zendcode;
        obj_VIEW_DM_ZCPNPF.CHDRNUM	:= obj_campaigncode.chdrnum;
        obj_VIEW_DM_ZCPNPF.GPLOTYP	:= obj_campaigncode.gpoltyp;
        obj_VIEW_DM_ZCPNPF.ZAGPTID	:= obj_campaigncode.zagptid;
        obj_VIEW_DM_ZCPNPF.RCDATE 	:= obj_campaigncode.rcdate;
        obj_VIEW_DM_ZCPNPF.ZCMPFRM	:= obj_campaigncode.zcmpfrm;
        obj_VIEW_DM_ZCPNPF.ZCMPTO	:= obj_campaigncode.zcmpto;
        obj_VIEW_DM_ZCPNPF.ZMAILDAT	:= obj_campaigncode.zmaildat;
        obj_VIEW_DM_ZCPNPF.ZACLSDAT	:= obj_campaigncode.zaclsdat;
        obj_VIEW_DM_ZCPNPF.ZDLVCDDT	:= obj_campaigncode.zdlvcddt;
        obj_VIEW_DM_ZCPNPF.ZVEHICLE	:= obj_campaigncode.zvehicle;
        obj_VIEW_DM_ZCPNPF.ZSTAGE	:= obj_campaigncode.zstage;
        obj_VIEW_DM_ZCPNPF.ZSCHEME01 := obj_campaigncode.zscheme01;
        obj_VIEW_DM_ZCPNPF.ZSCHEME02 := obj_campaigncode.zscheme02;
        obj_VIEW_DM_ZCPNPF.EFFDATE	:= obj_campaigncode.EFFDATE;
        obj_VIEW_DM_ZCPNPF.USRPRF	:= i_usrprf;
        obj_VIEW_DM_ZCPNPF.JOBNM	:= i_scheduleName;
		obj_VIEW_DM_ZCPNPF.DATIME	:= CAST(sysdate AS TIMESTAMP);
        obj_VIEW_DM_ZCPNPF.ZCRTUSR	:= i_usrprf;
        obj_VIEW_DM_ZCPNPF.ZAPPDATE	:= obj_campaigncode.ZAPPDATE;
        obj_VIEW_DM_ZCPNPF.ZCCODIND	:= obj_campaigncode.ZCCODIND;
        obj_VIEW_DM_ZCPNPF.STATUS 	:= 'AP';--obj_campaigncode.STATUS; --- CM2 Changes to default status to AP
      
	--	INSERT INTO Jd1dta.ZCPNPF VALUES obj_zcpnpf;
     
        INSERT INTO Jd1dta.VIEW_DM_ZCPNPF VALUES obj_VIEW_DM_ZCPNPF;
		
	END IF;
	END LOOP; -- CR3
	EXIT WHEN cur_campaign_code%notfound; -- CR3
	
  END LOOP;
 COMMIT;-- CR3
  CLOSE cur_campaign_code;
  
	-------------2nd Cursor Open for Sales Plan2-----------
	-- 2nd loop
  pkg_common_dmcm.getzcpnpf(getzcpnpf1 => getzcpnpf1); 
  pkg_common_dmcm.checkZCSLPF(checkZCSLPF1 => checkZCSLPF1);

  OPEN salesPlan_cursor2;
  --CR3 - Apply Bulk Collect:START--
  --<<skipRecord2>>
  LOOP
	  FETCH salesPlan_cursor2 BULK COLLECT INTO salpln_list LIMIT C_limit;
	  <<skipRecord2>>
	  FOR i IN 1..salpln_list.COUNT LOOP

	  obj_salesPlan2 := salpln_list(i);
  --  FETCH salesPlan_cursor2 INTO obj_salesPlan2;
  --  EXIT WHEN salesPlan_cursor2%notfound;

  --CR3 - Apply Bulk Collect:END--
	v_OLD_ZSALPLAN :=obj_salesPlan2.OLD_ZSALPLAN;
    v_zsalplan2 :=obj_salesPlan2.zsalplan;
    v_zcmpcode1  :=obj_salesPlan2.zcmpcode;
	
	v_zcmpcode_len1 := LENGTH(TRIM(v_zcmpcode1));
	IF v_zcmpcode_len1 = 5 THEN
		v_zcmpcode_sp2 := substr(TRIM(v_zcmpcode1),1,5)||'0';
	END IF;
	
	IF v_zcmpcode_len1 = 6 THEN
		v_zcmpcode_sp2 := TRIM(v_zcmpcode1);
	END IF;

 
	----------Initialization Start-------
	i_zdoe_info :=NULL;
	i_zdoe_info.i_zfilename  := 'TITDMGZCSLPF';
	i_zdoe_info.i_prefix     := C_PREFIX;
    i_zdoe_info.i_scheduleno := i_scheduleNumber;
	i_zdoe_info.i_refKey     := TRIM(v_OLD_ZSALPLAN) ||TRIM(v_zcmpcode1) ; 
    i_zdoe_info.i_tableName  := v_tableName;
    
	b_isError2             := 'N';
	v_errorCount2            :=0;
	t_ercode(1) := ' ';
    t_ercode(2) := ' ';
    t_ercode(3) := ' ';
    t_ercode(4) := ' ';
    t_ercode(5) := ' ';
    isDuplicate := 0;
    n_zcampcode              :=0;
	
	 ----------Initialization End-------
	 --------------Sales Plan 2 Validation Starts ------------SP-----------
	 
	--36) CHECK IF ZCMPCODE-Campaign Code  IS BLANK/NULL---

	IF TRIM(v_zcmpcode1)              IS NULL THEN
		  b_isError2                   	 := 'Y';
		  i_zdoe_info.i_indic          	 := 'E';
		  v_errorCount2                  := v_errorCount2 + 1;
		  t_ercode(v_errorCount2)        := C_Z041;
		  t_errormsg(v_errorCount2)      := o_errortext(C_Z041);
		  t_errorfield(v_errorCount2)    := 'ZCMPCODE';
		  t_errorfieldval(v_errorCount2) := TRIM(v_zcmpcode1);
		  t_errorprogram (v_errorCount2) := i_scheduleName;
		  IF v_errorCount2               >= 5 THEN
			GOTO insertzdoe2;
		  END IF;
	
	ELSE    
   

		-- 37) Check for "Campaign Code not Valid" Condition 
		

		--SELECT COUNT(ZCMPCODE)  INTO n_zcampcode
		--FROM Jd1dta.ZCPNPF WHERE TRIM(ZCMPCODE) = substr(TRIM(v_zcmpcode1),1,5)||'0' ; 

	--	IF v_temp_zcmpcode                is NOT NULL THEN
	--	IF n_zcampcode  = 0 THEN --CR3
		IF NOT (getzcpnpf1.EXISTS(substr(TRIM(v_zcmpcode1),1,5)||'0'))  THEN --CR3
			b_isError2                 	 := 'Y';
			i_zdoe_info.i_indic          := 'E';
			i_zdoe_info.i_error01        := C_RQM1;
			i_zdoe_info.i_errormsg01     := o_errortext('RQM1');
			i_zdoe_info.i_errorfield01   := 'ZCMPCODE';
			i_zdoe_info.i_fieldvalue01   := TRIM(v_zcmpcode1);
			i_zdoe_info.i_errorprogram01 := i_scheduleName;
			pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
			CONTINUE skipRecord2;
		ELSE
			obj_zcpnpf1 := getzcpnpf1(substr(TRIM(v_zcmpcode1),1,5)||'0');
			v_zccodind := TRIM(obj_zcpnpf1.ZCCODIND);
		END IF;
		
		
      
   
	-- 38) CHECK IF zccodind = 'Y' THEN Not to INSERT the Records in ZCSLPF : C-Code Mismatch
		
		

	  --SELECT ZCCODIND INTO v_zccodind --CR3
		--FROM Jd1dta.ZCPNPF WHERE TRIM(ZCMPCODE) = substr(TRIM(v_zcmpcode1),1,5)||'0' ; --CR3
		IF v_zccodind                     = 'Y'    THEN
			b_isError2                     := 'Y';
			v_errorCount2                  := v_errorCount2 + 1;
			t_ercode(v_errorCount2)        := C_RQY9;
			t_errorfield(v_errorCount2)    := 'zcmpcode';
			t_errormsg(v_errorCount2)      := o_errortext('RQY9');
			t_errorfieldval(v_errorCount2) := TRIM(v_zcmpcode1);
			t_errorprogram (v_errorCount2) := i_scheduleName;
			IF v_errorCount2               >= 5 THEN
			  GOTO insertzdoe2;
			END IF;
		END IF;
	END IF;

	-- 39) CHECK IF "SalePlan must not be blank" ---------------
    IF TRIM(v_OLD_ZSALPLAN)           IS NULL THEN
        b_isError2                 	 := 'Y';
		v_errorCount2                := v_errorCount2 + 1;
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := C_Z040;
        i_zdoe_info.i_errormsg01     := o_errortext(C_Z040);
        i_zdoe_info.i_errorfield01   := 'zsalplan2';
        i_zdoe_info.i_fieldvalue01   := TRIM(v_OLD_ZSALPLAN);
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        CONTINUE skipRecord2;
    ELSE
	--40) Duplicate Record Found  of Sales Plan2----
		--SELECT COUNT(*) INTO isDuplicate FROM Jd1dta.ZCSLPF
			--WHERE ZSALPLAN                  = v_zsalplan2
			--AND ZCMPCODE                    = v_zcmpcode_sp2;
		--IF isDuplicate                  > 0 THEN
		IF checkZCSLPF1.EXISTS(v_zsalplan2 ||  v_zcmpcode_sp2) THEN
			  b_isError2                   := 'Y';
			  i_zdoe_info.i_indic          := 'E';
			  i_zdoe_info.i_error01        := C_Z098;
			  i_zdoe_info.i_errormsg01     := o_errortext(C_Z098);
			  i_zdoe_info.i_errorfield01   := 'zsalplan2';
			  i_zdoe_info.i_fieldvalue01   := TRIM(v_zsalplan2);
			  i_zdoe_info.i_errorprogram01 := i_scheduleName;
			  pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
			  CONTINUE skipRecord2;
		END IF;
   END IF;  
	 -- 41) Sales Plan 2 Exists in Sales Plan Master Table: ZSLPPF  or not 

	--SELECT count(*) into v_issalesplanexist FROM Jd1dta.ZSLPPF --CR3: Move this to cursor
	--	where ZSALPLAN = v_zsalplan2;

    --IF (v_issalesplanexist < 1) THEN --CR3
	IF TRIM(obj_salesPlan2.zsl_zsalplan) IS NULL THEN
		  b_isError2                 	:= 'Y';
		  v_errorCount2 				:= v_errorCount2 + 1;
		  t_ercode(v_errorCount2) 		:= C_Z010;
		  t_errorfield(v_errorCount2) 	:= 'ZSALPLAN2';
		  t_errormsg(v_errorCount2) 	:= o_errortext(C_Z010);
		  t_errorfieldval(v_errorCount2) := obj_campaigncode.zendcode;
		  t_errorprogram(v_errorCount2) := i_scheduleName;
		  IF v_errorCount2 >= 5 THEN
			GOTO insertzdoe2;
		  END IF;
    END IF;
	 
      --validation End
      -- END IF; -- for  zprvaldYN
	  
	  ----Common Business logic for inserting into ZDOEPF---
      <<insertzdoe2>>
      IF (b_isError2                  = 'Y') THEN
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
      IF (b_isError2       = 'N') THEN
        i_zdoe_info.i_indic := 'S';
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      END IF;
	  
      -- Updating IG- Tables And Migration Registry table with filter data
      -- Updating S indicator
      IF b_isError2 = 'N' AND i_zprvaldYN = 'N' THEN
       
      -- insert into  IG Jd1dta.ZDROPF - Migration Registry table Start-
     	
		obj_VIEW_DM_ZDROPF.RECSTATUS := 'NEW';
        obj_VIEW_DM_ZDROPF.PREFIX    := 'CM';
        obj_VIEW_DM_ZDROPF.ZENTITY   := v_OLD_ZSALPLAN;
        obj_VIEW_DM_ZDROPF.ZIGVALUE  := v_zsalplan2;
        obj_VIEW_DM_ZDROPF.JOBNUM    := i_scheduleNumber;
        obj_VIEW_DM_ZDROPF.JOBNAME   := i_scheduleName;
        Insert into Jd1dta.VIEW_DM_PAZDROPF values obj_VIEW_DM_ZDROPF;
      -- insert into  IG Jd1dta.ZDROPF table End-

	------Insert Into IG table

v_SEQ_ZCSLPF := SEQ_ZCSLPF.nextval ;
     obj_zcslpf.unique_number := v_SEQ_ZCSLPF;
     
		obj_zcslpf.ZSALPLAN 	:= v_zsalplan2;
        obj_zcslpf.ZCMPCODE 	:= v_zcmpcode_sp2;
        obj_zcslpf.JOBNM 		:= i_scheduleName;
        obj_zcslpf.USRPRF		:= i_usrprf;
        obj_zcslpf.DATIME		:= sysdate;
         
		Insert into Jd1dta.ZCSLPF values obj_zcslpf;  	 
    
	 END IF;
	 END LOOP; --CR3
	 EXIT WHEN salesPlan_cursor2%notfound;--CR3
	 COMMIT; --CR3
    END LOOP;
    CLOSE salesPlan_cursor2;
	commit;

 ----------2nd Cursor Close for Sales Plan2------------
  
  
	dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

	dbms_output.put_line('End execution of BQ9S8_CM01_CAMPCD, SC NO:  ' ||
                         i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9S8_CM01_CAMPCD : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    
      insert into Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      values
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);
    
      commit;
      RAISE; --CR3
END BQ9S8_CM01_CAMPCD;