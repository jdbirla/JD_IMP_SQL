create or replace PROCEDURE                                      "BQ9UT_MB01_DISHONOR" (i_scheduleName   IN VARCHAR2,
                                                  i_scheduleNumber IN VARCHAR2,
                                                  i_zprvaldYN      IN VARCHAR2,
                                                  i_company        IN VARCHAR2,
                                                  i_usrprf         IN VARCHAR2,
                                                  i_branch         IN VARCHAR2,
                                                  i_transCode      IN VARCHAR2,
                                                  i_vrcmTermid     IN VARCHAR2,
												  i_array_size     IN PLS_INTEGER DEFAULT 1000,
												  start_id         IN NUMBER,
                                                  end_id           IN NUMBER) AS
												  
  /*************************************************************************************************** 
  * Amenment History: MB01 Dishonor 
  * Date    Init   Tag   Decription 
  * -----   -----  ---   --------------------------------------------------------------------------- 
  * MMMDD   XXX    DH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 **********************************************SHI_START******************************************************  
  * APR28   JB     DH2   Records without dishonour count will be thrown into ZDOE as exception record 
  * MAY18   PS     DH3   Initialize variales record 
  * MAY22   PS     DH4   Include Cancelled policies when dishonor count > 0 
  * 0730    JDB    DH5   PGPEND date setting with calculation
  * 1001    SK     DH6   Re-initilize the variables
  * 1205    SK     DH7   Fix for #13927
  **********************************************SHI_END******************************************************

  **********************************************PA_START****************************************************** 
  * MMMDD   XXX    DHXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
  * 0813    ABG	   DH8   PA New Implementation
  * 0101    BSINGH DH9	 ITR3  Implementation
  * 0708    PRABU  DH10  ZJNPG-9739, Adding the registry table into the cursor
  **********************************************PA_END******************************************************
  *****************************************************************************************************/  

  ---- Time Check 
  v_timestart number := dbms_utility.get_time;
  ---- Local Vairables   
  v_errorCount  NUMBER(1) DEFAULT 0;
  v_isAnyError  VARCHAR2(1) DEFAULT 'N';

  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
 -- v_oldpolnum     TITDMGMBRINDP3.OLDPOLNUM@DMSTAGEDBLINK%type;
 -- v_refKey        TITDMGMBRINDP3.OLDPOLNUM@DMSTAGEDBLINK%type;
    v_oldpolnum        dmigtitdmgmbrindp3.oldpolnum%TYPE;
    v_refkey           dmigtitdmgmbrindp3.oldpolnum%TYPE;
  p_exitcode      NUMBER;
  p_exittext      VARCHAR2(200);
  v_pkValue       NUMBER;
    
     
  ------ Constants
  C_PREFIX constant varchar2(2) := GET_MIGRATION_PREFIX('PDSH', i_company);
  C_ERRORCOUNT constant number := 5;
  C_limit PLS_INTEGER := i_array_size;

  C_BQ9UT         constant varchar2(5) := 'BQ9UT';
  C_ERROR         constant varchar2(3) := 'E';

 -- C_RQO6 constant varchar2(4) := 'RQO6'; /*Duplicate record found. */
  c_rqmb             CONSTANT VARCHAR2(4) := 'RQMB'; /*Duplicate record found. */
     
  C_PA01 constant varchar2(4) := 'PA01'; /*Skipped because new policy*/

  -------------------------------------- START- Common Functions ----------------------------------------------

  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  --getgchd         pkg_common_dmmb_pdsh.gchdtype;
  getzdpd         pkg_common_dmmb_pdsh.zdpdtype;

  type ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  type errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  type errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  type errorfieldvalue_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  type errorprofram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprofram_tab;
  ---------IG tables---- 
  obj_zuclpf Jd1dta.ZUCLPF%rowtype;
  obj_pazdpdpf  Jd1dta.VIEW_DM_PAZDPDPF%rowtype;
  --------------------------------------- END- Common Functions ------------------------------------------------ 
 -- Changes to the cursor for DH10
  CURSOR cur_mbr_ind_pdpa IS
--    SELECT DISTINCT(OLDPOLNUM) FROM DMIGTITDMGMBRINDP3 WHERE 
--	RECIDXMBINDP3 BETWEEN start_id AND end_id AND OLDPOLNUM != ' ' AND OLDPOLNUM IS NOT NULL;
SELECT DISTINCT
                ( tit.oldpolnum ),
                gchd.zprvchdr,
                gchd.chdrnum,
                mig.oldchdrnum mig_pol
        FROM
                dmigtitdmgmbrindp3 tit
                LEFT OUTER JOIN gchd gchd ON tit.oldpolnum = gchd.zprvchdr
                                             AND TRIM(gchd.chdrpfx) = TRIM('CH')
                                             AND TRIM(gchd.chdrcoy) = TRIM('1')
                LEFT OUTER JOIN PAZDPDPF mig on   tit.oldpolnum = mig.oldchdrnum                                           
        WHERE
                TRIM(tit.oldpolnum) IS NOT NULL
                AND recidxmbindp3 BETWEEN start_id AND end_id;

  obj_mbr_ind_pdpa cur_mbr_ind_pdpa%rowtype;

  type t_mbrind_list is table of cur_mbr_ind_pdpa%rowtype;
  mbrind_list t_mbrind_list;


BEGIN
  ------------------------------------------ START- Common Function Calling --------------------------------------------------
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPD',
                                        o_errortext   => o_errortext);
  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9UT,
                                     o_defaultvalues => o_defaultvalues);
  --pkg_common_dmmb_pdsh.getpolicy(getgchd => getgchd);
  --pkg_common_dmmb_pdsh.getPAZDPDPF(getzdpd => getzdpd);--- Changes for DH10
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  --pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
  -------------------------------------------- END- Common Function Calling --------------------------------------------------- 

  ----------------------------------------------- Open Cursor ------------------------------------------------------
  OPEN cur_mbr_ind_pdpa;

  LOOP
    FETCH cur_mbr_ind_pdpa bulk collect
      INTO mbrind_list limit C_limit;

	  <<skipRecord>>

	  for i in 1 .. mbrind_list.count loop

      obj_mbr_ind_pdpa := mbrind_list(i);


    --v_oldpolnum := TRIM(obj_mbr_ind_pdpa.oldpolnum);
    v_refKey := TRIM(obj_mbr_ind_pdpa.oldpolnum);

    ----------------------------------------------------- START- Initialization ------------------------------------------- 
    i_zdoe_info              := Null;
    i_zdoe_info.i_zfilename  := 'TITDMGMBRINDP3';
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
    ---------------------------------------------------- END- Initialization ------------------------------------------------- 

	------------------------------------------------- START- Pre Validations ------------------------------------------------
    ---------- 1. Skipped OLDPOLNUM: Policy not in IG -----------
  --  IF NOT (getgchd.exists(TRIM(v_oldpolnum))) THEN
  IF ( obj_mbr_ind_pdpa.zprvchdr IS NULL ) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_PA01;      
      t_errormsg(v_errorCount) := 'Skipped because new policy';
	    t_errorfield(v_errorCount) := 'OLDPOLNUM';
      t_errorfieldval(v_errorCount) := obj_mbr_ind_pdpa.oldpolnum;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

	-------- 2. Duplicate OLDPOLNUM: Policy already processed i.e. added in PAZDPDPF or duplicate entry in staging table TITDMGMBRINDP3 ---------
  --  IF (getgchd.exists(TRIM(v_oldpolnum))) THEN --DH9
	IF ( TRIM(obj_mbr_ind_pdpa.oldpolnum) IS NOT NULL ) THEN
   --  IF (getgchd(TRIM(v_oldpolnum)).ZPRVCHDR != TRIM(v_oldpolnum)) THEN --DH9
     -- v_isAnyError := 'Y';
	   -- i_zdoe_info.i_indic    := C_ERROR;
     -- i_zdoe_info.i_error01  := C_PA01;      
      --i_zdoe_info.i_errormsg01 := 'Skipped because new policy';
	  --  i_zdoe_info.i_errorfield01 := 'OLDPOLNUM';
     -- i_zdoe_info.i_fieldvalue01 := obj_mbr_ind_pdpa.oldpolnum;
     -- i_zdoe_info.i_errorprogram01 := i_scheduleName;
      --  GOTO insertzdoe;
    -- END IF;  

	-- IF (getzdpd.exists(TRIM(v_oldpolnum)))THEN --DH9
	-- IF ( getzdpd.EXISTS(trim(obj_mbr_ind_pdpa.oldpolnum)) ) THEN
    IF obj_mbr_ind_pdpa.mig_pol is not null THEN -- DH10
        v_isAnyError             := 'Y';
        i_zdoe_info.i_indic      := C_ERROR;
	    --	i_zdoe_info.i_error01        := C_RQO6;
       -- i_zdoe_info.i_errormsg01    := o_errortext(C_RQO6); 
	    i_zdoe_info.i_error01 := c_rqmb;
        i_zdoe_info.i_errormsg01 := 'Duplicated record found'; --o_errortext(c_rqmb);
        i_zdoe_info.i_errorfield01   := 'OLDPOLNUM';
        i_zdoe_info.i_fieldvalue01   := obj_mbr_ind_pdpa.oldpolnum;
        i_zdoe_info.i_errorprogram01 := i_scheduleName;
        GOTO insertzdoe;
      END IF;
	END IF;
    -------------------------------------------------- END- Pre Validations ------------------------------------------------

    ------------- START- Common Business logic for inserting into ZDOEPF for successful and unsuccessful records ------------------- 
    <<insertzdoe>>
    IF (v_isAnyError = 'Y') THEN
      IF TRIM(t_ercode(1)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := C_ERROR;
        i_zdoe_info.i_error01        := t_ercode(1);
        i_zdoe_info.i_errormsg01     := t_errormsg(1);
        i_zdoe_info.i_errorfield01   := t_errorfield(1);
        i_zdoe_info.i_fieldvalue01   := t_errorfieldval(1);
        i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
      END IF;
      IF TRIM(t_ercode(2)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := C_ERROR;
        i_zdoe_info.i_error02        := t_ercode(2);
        i_zdoe_info.i_errormsg02     := t_errormsg(2);
        i_zdoe_info.i_errorfield02   := t_errorfield(2);
        i_zdoe_info.i_fieldvalue02   := t_errorfieldval(2);
        i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
      END IF;
      IF TRIM(t_ercode(3)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := C_ERROR;
        i_zdoe_info.i_error03        := t_ercode(3);
        i_zdoe_info.i_errormsg03     := t_errormsg(3);
        i_zdoe_info.i_errorfield03   := t_errorfield(3);
        i_zdoe_info.i_fieldvalue03   := t_errorfieldval(3);
        i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
      END IF;
      IF TRIM(t_ercode(4)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := C_ERROR;
        i_zdoe_info.i_error04        := t_ercode(4);
        i_zdoe_info.i_errormsg04     := t_errormsg(4);
        i_zdoe_info.i_errorfield04   := t_errorfield(4);
        i_zdoe_info.i_fieldvalue04   := t_errorfieldval(4);
        i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
      END IF;
      IF TRIM(t_ercode(5)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := C_ERROR;
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
    ------------------------------------- END- Common Business logic for inserting into ZDOEPF --------------------------------------- 

    ---------- START- Common Business logic for inserting successful records into ZUCLPF and PAZDPDPF after pre validations ----------- 
    IF i_zprvaldYN = 'N' AND v_isAnyError = 'N' THEN

      -------------------------- Insert into ZUCLPF -------------------------------
      --select SEQ_ZUCLPF.nextval into v_pkValue from dual;
      v_pkValue := SEQ_ZUCLPF.nextval; --PerfImprov
      obj_zuclpf.UNIQUE_NUMBER := v_pkValue;
      obj_zuclpf.CHDRCOY  := i_company;
			obj_zuclpf.CHDRPFX  := o_defaultvalues('CHDRPFX');
			--obj_zuclpf.CHDRNUM  := getgchd(TRIM(obj_mbr_ind_pdpa.oldpolnum)).ZPRVCHDR; --DH9
			obj_zuclpf.chdrnum := trim(obj_mbr_ind_pdpa.zprvchdr);
			obj_zuclpf.ZCHDRCOY  := i_company;
			obj_zuclpf.ZCHDRPFX  := o_defaultvalues('CHDRPFX');
			--obj_zuclpf.ZCHDRNUM := getgchd(TRIM(obj_mbr_ind_pdpa.oldpolnum)).CHDRNUM; --DH9
			obj_zuclpf.zchdrnum := trim(obj_mbr_ind_pdpa.chdrnum);
      obj_zuclpf.ZNOSHFT  := 1;
			obj_zuclpf.ZENDPGP   := 99999999;
      obj_zuclpf.ZCOMBILL := 0; 
			obj_zuclpf.VALIDFLAG := o_defaultvalues('VALIDFLAG');
      obj_zuclpf.USRPRF    := i_usrprf;
			obj_zuclpf.JOBNM     := i_scheduleName;
      obj_zuclpf.DATIME    := CAST(sysdate AS TIMESTAMP);
			obj_zuclpf.ZSTRTPGP  := 99999999;	

      Insert into ZUCLPF values obj_zuclpf;

			--------------------------- Insert into PAZDPDPF -----------------------------
		--	obj_pazdpdpf.OLDCHDRNUM  := getgchd(TRIM(obj_mbr_ind_pdpa.oldpolnum)).ZPRVCHDR; --DH9
			--obj_pazdpdpf.NEWCHDRNUM  := getgchd(TRIM(obj_mbr_ind_pdpa.oldpolnum)).CHDRNUM; --DH9
			obj_pazdpdpf.OLDCHDRNUM := trim(obj_mbr_ind_pdpa.zprvchdr);
			obj_pazdpdpf.NEWCHDRNUM := trim(obj_mbr_ind_pdpa.chdrnum);
			obj_pazdpdpf.JOBNUM  := i_scheduleNumber;
			obj_pazdpdpf.JOBNAME  := i_scheduleName;
			obj_pazdpdpf.USRPRF  := i_usrprf;
			obj_pazdpdpf.DATIME  := CAST(sysdate AS TIMESTAMP);

			Insert into VIEW_DM_PAZDPDPF values obj_pazdpdpf;			

	END IF;
	---------------------------- END- Common Business logic for inserting into ZUCLPF and PAZDPDPF ----------------------------------------- 

  END loop;

  EXIT WHEN cur_mbr_ind_pdpa%notfound;  

  END LOOP;
  CLOSE cur_mbr_ind_pdpa;
  ---------------------------------------------------------------- Close Cursor -------------------------------------------------------------

  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

  COMMIT;				   

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9UT_MB01_DISHONOR : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      INSERT INTO Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      VALUES
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

  COMMIT;
END BQ9UT_MB01_DISHONOR;