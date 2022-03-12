create or replace PROCEDURE                                      "BQ9UT_MB01_DISHONOR" (i_scheduleName   IN VARCHAR2,
                                                  i_scheduleNumber IN VARCHAR2,
                                                  i_zprvaldYN      IN VARCHAR2,
                                                  i_company        IN VARCHAR2,
                                                  i_usrprf         IN VARCHAR2,
                                                  i_branch         IN VARCHAR2,
                                                  i_transCode      IN VARCHAR2,
                                                  i_vrcmTermid     IN VARCHAR2) AS
  /*************************************************************************************************** 
  * Amenment History: MB01 Dishonor 
  * Date    Init   Tag   Decription 
  * -----   -----  ---   --------------------------------------------------------------------------- 
  * MMMDD    XXX   DH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
  * APR28    JB    DH2   Records without dishonour count will be thrown into ZDOE as exception record 
  * MAY18    PS    DH3   Initialize variales record 
  * MAY22    PS    DH4   Include Cancelled policies when dishonor count > 0 
  * 0730    JDB    DH5   PGPEND date setting with calculation
  * 1001    SK     DH6   Re-initilize the variables
  * 1205    SK     DH7   Fix for #13927
  *****************************************************************************************************/
  --timecheck 
  v_timestart number := dbms_utility.get_time;
  ---local Vairables                                                   
  v_isDuplicate NUMBER(1) DEFAULT 0;
  v_SEQ         NUMBER(15) DEFAULT 0;
  v_errorCount  NUMBER(1) DEFAULT 0;
  v_isAnyError  VARCHAR2(1) DEFAULT 'N';

  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  v_refnum        TITDMGMBRINDP3.REFNUM@DMSTAGEDBLINK%type;
  v_refKey        TITDMGMBRINDP3.REFNUM@DMSTAGEDBLINK%type;
  -- v_zpgptodt      GCHPPF.ZPGPTODT%type; --DH5
  v_zpgptodt     TITDMGMBRINDP3.CURRFROM@DMSTAGEDBLINK%type; --DH5
  v_statcode     GCHD.STATCODE%type;
  v_zprvchdr     GCHD.zprvchdr%type;
  v_zprvchdrtemp GCHD.zprvchdr%type;
  v_zprvchdrtemp_new GCHD.zprvchdr%type;
  v_wascount     integer := 0;
  total          integer := 0;

  v_prefix_current   PAZDRPPF.PREFIX%type;
  v_prefix_prev      PAZDRPPF.PREFIX%type;
  v_prefix_prev_temp PAZDRPPF.PREFIX%type;

  ------Constant 
  C_PREFIX constant varchar2(2) := GET_MIGRATION_PREFIX('PDSH', i_company);
  -- C_PREFIX        constant varchar2(2) := 'PD'; 
  C_ERRORCOUNT constant number := 5;
  C_SPACE constant varchar2(2) := ' '; -- DH6

  C_BQ9SC         constant varchar2(5) := 'BQ9SC';
  C_RECORDSKIPPED constant varchar2(17) := 'Record skipped';
  C_ERROR         constant varchar2(3) := 'E';

  C_Z101 constant varchar2(4) := 'RQO7'; /*Policy not in IG */
  C_Z099 constant varchar2(4) := 'RQO6'; /*Duplicate record found. */
  C_RR78 constant varchar2(4) := 'RR78'; /*Skip-Dishnor not exists*/
  --------------Common Function Start--------- 

  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  getzpgptodt     pkg_common_dmmb_pdsh.zpgptype;
  getgchd         pkg_common_dmmb_pdsh.gchdtype;
  getzdrp         pkg_common_dmmb_pdsh.zdrptype;
  chkzprv         pkg_common_dmmb_pdsh.zprvtype;
  checkpoldup     pkg_common_dmmb_pdsh.polduplicatetype;

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
  obj_zuclpf ZUCLPF%rowtype;

  ---------------Common function end----------- 
  CURSOR cur_mbr_ind_pdsh IS
    SELECT * FROM TITDMGMBRINDP3@DMSTAGEDBLINK;

  obj_mbr_ind_pdsh cur_mbr_ind_pdsh%rowtype;

BEGIN
  /*DBMS_PROFILER.start_profiler('DM MBR NEW-5  ' || 
  TO_CHAR(SYSDATE, 'YYYYMMDD HH24:MI:SS'));*/

  ---------Common Function Calling------------ 
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPD',
                                        o_errortext   => o_errortext);

											
											  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9SC,
                                     o_defaultvalues => o_defaultvalues);
  pkg_common_dmmb_pdsh.getzpgptodt(getzpgptodt => getzpgptodt);
  pkg_common_dmmb_pdsh.getpolicy(getgchd => getgchd);
  pkg_common_dmmb_pdsh.getPAZDRPPF(getzdrp => getzdrp);
  pkg_common_dmmb_pdsh.checkzprv(chkzprv => chkzprv);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);

  pkg_common_dmmb_pdsh.checkpoldup(checkpoldup => checkpoldup);
  ---------Common Function Calling------------ 
  ---Open Cursor 
  OPEN cur_mbr_ind_pdsh;
  <<skipRecord>>
  LOOP
    FETCH cur_mbr_ind_pdsh
      INTO obj_mbr_ind_pdsh;
    EXIT WHEN cur_mbr_ind_pdsh%notfound;
    v_refnum := TRIM(obj_mbr_ind_pdsh.refnum);
    v_refKey := TRIM(obj_mbr_ind_pdsh.refnum);

    ----------Initialization ------- 
    i_zdoe_info              := Null;
    i_zdoe_info.i_zfilename  := 'TITDMGMBRINDP3';
    i_zdoe_info.i_prefix     := C_PREFIX;
    i_zdoe_info.i_scheduleno := i_scheduleNumber;
    i_zdoe_info.i_refKey     := v_refKey;
    i_zdoe_info.i_tableName  := v_tableName;
    -- i_zdoe_info.i_tablecnt := v_tablecnt; 
    --v_tablecnt := 1; 
    v_isAnyError := 'N';
    v_errorCount := 0;
    t_ercode(1) := null;
    t_ercode(2) := null;
    t_ercode(3) := null;
    t_ercode(4) := null;
    t_ercode(5) := null;
    v_zprvchdr := null;
    v_wascount := 0;
    -- DH6 -- Start
    v_prefix_current := C_SPACE;
    v_prefix_prev := C_SPACE;
    -- DH6 -- End
    ----------Initialization ------- 
    ---REFNUM validation: Policy not in IG 
    select Jd1dta.seqtmp.nextval INTO V_SEQ from dual; 
    IF NOT (getgchd.exists(TRIM(v_refnum) || TRIM(i_company))) THEN
      v_isAnyError := 'Y';
      v_errorCount := v_errorCount + 1;
      t_ercode(v_errorCount) := C_Z101;
      t_errorfield(v_errorCount) := 'REFNUM';
      t_errormsg(v_errorCount) := o_errortext(C_Z101);
      t_errorfieldval(v_errorCount) := obj_mbr_ind_pdsh.refnum;
      t_errorprogram(v_errorCount) := i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;
    IF (getgchd.exists(v_refnum || TRIM(i_company))) THEN
      v_statcode := getgchd(v_refnum || TRIM(i_company)).STATCODE;
      --IF ((TRIM(v_statcode) <> 'IF') AND (TRIM(v_statcode) <> 'XN')) THEN -- DH4 
      IF ((TRIM(v_statcode) <> 'IF') AND (TRIM(v_statcode) <> 'XN') AND
         (TRIM(v_statcode) <> 'CA')) THEN
        -- DH4 
        v_isAnyError             := 'Y';
        i_zdoe_info.i_indic      := C_ERROR;
        i_zdoe_info.i_errormsg01 := C_RECORDSKIPPED;
        GOTO insertzdoe;
      END IF;
      -- MB2 START -- 
      
      IF ((TRIM(v_statcode) = 'XN') AND (obj_mbr_ind_pdsh.ZDSHCNT = 0) AND
         (TRIM(obj_mbr_ind_pdsh.oldpolnum) = ' ')) THEN
        -- DH4 
        --(TRIM(obj_mbr_ind_pdsh.oldpolnum) IS NULL)) THEN 
        v_isAnyError             := 'Y';
        i_zdoe_info.i_indic      := C_ERROR;
        i_zdoe_info.i_errormsg01 := o_errortext(C_RR78);
        GOTO insertzdoe;
      END IF; 
      IF ((TRIM(v_statcode) = 'IF') AND (obj_mbr_ind_pdsh.ZDSHCNT = 0)) THEN
        v_isAnyError             := 'Y';
        i_zdoe_info.i_indic      := C_ERROR;
        i_zdoe_info.i_errormsg01 := o_errortext(C_RR78);
        GOTO insertzdoe;
      END IF; 
      -- MB2 END -- 
      -- DH4 START -- 
 /*ps     IF ((TRIM(v_statcode) = 'CA') AND (obj_mbr_ind_pdsh.ZDSHCNT = 0)) THEN
        v_isAnyError             := 'Y';
        i_zdoe_info.i_indic      := C_ERROR;
        i_zdoe_info.i_errormsg01 := o_errortext(C_RR78);
        GOTO insertzdoe;
      END IF; */
      
      
      IF ((TRIM(v_statcode) = 'CA')) THEN
            IF (chkzprv.exists(TRIM(obj_mbr_ind_pdsh.refnum))) THEN
                v_isAnyError             := 'Y';
                i_zdoe_info.i_indic      := C_ERROR;
                i_zdoe_info.i_errormsg01 := C_RECORDSKIPPED;
                GOTO insertzdoe;
            END IF;
      END IF; 
      -- DH4 END -- 
    ELSE
      v_isAnyError             := 'Y';
      i_zdoe_info.i_indic      := C_ERROR;
      i_zdoe_info.i_errormsg01 := C_RECORDSKIPPED;
      GOTO insertzdoe;
    END IF;
    ---Check for duplicate record in ZUCLPF 
    /*select count(CHDRNUM)
      into v_isDuplicate
      FROM Jd1dta.ZUCLPF
     WHERE TRIM(CHDRNUM) = TRIM(v_refnum); 
     
    IF v_isDuplicate > 0 THEN
      v_isAnyError                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := C_Z099;
      i_zdoe_info.i_errormsg01     := o_errortext(C_Z099);
      i_zdoe_info.i_errorfield01   := 'CHDRNUM';
      i_zdoe_info.i_fieldvalue01   := v_refnum;
      i_zdoe_info.i_errorprogram01 := i_scheduleName;
      GOTO insertzdoe;
    END IF;

    /* 
    IF NOT (checkchdrnum.exists(TRIM(obj_mbr_ind_pdsh.refnum) || 
                                TRIM(i_company))) THEN 

      v_isAnyError := 'Y'; 
      v_errorCount := v_errorCount + 1; 
      t_ercode(v_errorCount) := C_Z101; 
      t_errorfield(v_errorCount) := 'REFNUM'; 
      t_errormsg(v_errorCount) := o_errortext(C_Z101); 
      t_errorfieldval(v_errorCount) := obj_mbr_ind_pdsh.refnum; 
      t_errorprogram(v_errorCount) := i_scheduleName; 
      IF v_errorCount >= C_ERRORCOUNT THEN 
        GOTO insertzdoe; 
      END IF; 
    END IF;*/

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

    
        IF TRIM(obj_mbr_ind_pdsh.oldpolnum) <> ' '  THEN          
	        v_zprvchdrtemp     := TRIM(obj_mbr_ind_pdsh.oldpolnum);
            v_prefix_current   := getzdrp(TRIM(obj_mbr_ind_pdsh.refnum)).PREFIX;
		    v_wascount := 1;
        END IF;
	   
        IF TRIM(v_statcode) = 'CA' OR TRIM(v_statcode) = 'XN' THEN
		FOR i IN 1 .. 3 LOOP

		IF (getgchd.exists(TRIM(v_zprvchdrtemp) || TRIM(i_company))) THEN

			v_zprvchdrtemp_new := getgchd(TRIM(v_zprvchdrtemp) || TRIM(i_company)).ZPRVCHDR;
            v_prefix_prev      := getzdrp(TRIM(v_zprvchdrtemp)).PREFIX;
            
            IF TRIM(v_prefix_current) <> TRIM(v_prefix_prev) THEN
                EXIT;
            ELSE 
                v_wascount         := v_wascount + 1;
            END IF;
            
			IF (TRIM(v_zprvchdrtemp_new) IS NULL) THEN	
                EXIT;
            ELSE
           		v_zprvchdrtemp := v_zprvchdrtemp_new;
            END IF;
        ELSE
           	EXIT;
        END IF;
		END LOOP;
        END IF;
	END IF;


	IF TRIM(v_statcode) = 'CA' THEN

		IF    (obj_mbr_ind_pdsh.ZDSHCNT) = 0 THEN
	      		obj_zuclpf.znoshft  := 0;
	      		obj_zuclpf.zcombill := 3;
		END IF;

		IF    (obj_mbr_ind_pdsh.ZDSHCNT) > 0 THEN
		      obj_zuclpf.znoshft  := 0;
		      obj_zuclpf.zcombill := obj_mbr_ind_pdsh.ZDSHCNT; 
		END IF;

	        IF TRIM(obj_mbr_ind_pdsh.oldpolnum) <> ' '  THEN          
			obj_zuclpf.CHDRNUM  := substr(TRIM(v_zprvchdrtemp),1,8);
			obj_zuclpf.zchdrnum := SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum), 1, 8);
            obj_zuclpf.znoshft  := v_wascount;
            obj_zuclpf.zcombill := 0; 
		ELSE 
			obj_zuclpf.CHDRNUM  := SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum), 1, 8);
			obj_zuclpf.zchdrnum := NULL;
		END IF;
      
	      	obj_zuclpf.CHDRPFX  := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.CHDRCOY  := i_company;
	      	obj_zuclpf.zchdrpfx := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.zchdrcoy := i_company;

	      	obj_zuclpf.ZSTRTPGP  := 99999999;
	      	obj_zuclpf.ZENDPGP   := 99999999;
	      	obj_zuclpf.validflag := o_defaultvalues('VALIDFLAG');
	      	obj_zuclpf.usrprf    := i_usrprf;

	      	obj_zuclpf.jobnm     := i_scheduleName;
      		obj_zuclpf.datime    := CAST(sysdate AS TIMESTAMP);

	        Insert into ZUCLPF values obj_zuclpf;
	END IF;

    IF TRIM(v_statcode) = 'XN' THEN

        IF TRIM(obj_mbr_ind_pdsh.oldpolnum) <> ' '  THEN          
			obj_zuclpf.CHDRNUM  := SUBSTR(TRIM(v_zprvchdrtemp),1,8);
			obj_zuclpf.zchdrnum := SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum), 1, 8);
		END IF;
      
	      	obj_zuclpf.CHDRPFX  := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.CHDRCOY  := i_company;
	      	obj_zuclpf.zchdrpfx := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.zchdrcoy := i_company;

	      	obj_zuclpf.ZSTRTPGP  := 99999999;
	      	obj_zuclpf.ZENDPGP   := 99999999;
	      	obj_zuclpf.validflag := o_defaultvalues('VALIDFLAG');
	      	obj_zuclpf.usrprf    := i_usrprf;

	      	obj_zuclpf.jobnm     := i_scheduleName;
      		obj_zuclpf.datime    := CAST(sysdate AS TIMESTAMP);
	      	obj_zuclpf.znoshft   := v_wascount;
		obj_zuclpf.zcombill  := 0;

	        Insert into ZUCLPF values obj_zuclpf;
	END IF;

	IF TRIM(v_statcode) = 'IF' THEN

		obj_zuclpf.CHDRNUM  := SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum), 1, 8);
		obj_zuclpf.zchdrnum := NULL;
      
	      	obj_zuclpf.CHDRPFX  := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.CHDRCOY  := i_company;
	      	obj_zuclpf.zchdrpfx := o_defaultvalues('CHDRPFX');
	      	obj_zuclpf.zchdrcoy := i_company;

	      	obj_zuclpf.ZSTRTPGP  := 99999999;
	      	obj_zuclpf.ZENDPGP   := 99999999;
	      	obj_zuclpf.validflag := o_defaultvalues('VALIDFLAG');
	      	obj_zuclpf.usrprf    := i_usrprf;

	      	obj_zuclpf.jobnm     := i_scheduleName;
      		obj_zuclpf.datime    := CAST(sysdate AS TIMESTAMP);
	      	obj_zuclpf.znoshft   := 0;
		obj_zuclpf.zcombill  := obj_mbr_ind_pdsh.ZDSHCNT; 

	        Insert into ZUCLPF values obj_zuclpf;
	END IF;

---      checkpoldup(SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum), 1, 8)) := SUBSTR(TRIM(obj_mbr_ind_pdsh.refnum),
  END LOOP;
  CLOSE cur_mbr_ind_pdsh;

  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
  /*DBMS_PROFILER.stop_profiler;*/
END BQ9UT_MB01_DISHONOR;