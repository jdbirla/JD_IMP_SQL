create or replace PROCEDURE                        "BQ9S8_CM01_CAMPCD" (i_scheduleName   IN VARCHAR2,
                                              i_scheduleNumber IN VARCHAR2,
                                              i_zprvaldYN      IN VARCHAR2,
                                              i_company        IN VARCHAR2,
                                              i_usrprf         IN VARCHAR2,
                                              i_branch         IN VARCHAR2,
                                              i_transCode      IN VARCHAR2,
                                              i_vrcmTermid     IN VARCHAR2) AS
/***************************************************************************************************
  * Amenment History: CM01 Campaign Code
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CM1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  *****************************************************************************************************/                                               

  --timecheck
  v_timestart number := dbms_utility.get_time;
  ---local Vairables
  v_zcmpcode            TITDMGCAMPCDE.ZCMPCODE@DMSTAGEDBLINK%type;
  v_isDuplicate         NUMBER(1) DEFAULT 0;
  v_errorCount          NUMBER(1) DEFAULT 0;
  v_isDateValid         VARCHAR2(20 CHAR);
  v_isAnyError          VARCHAR2(1) DEFAULT 'N';
  v_isendrcodeexist     NUMBER(1) DEFAULT 0;
  v_ispolicyexist       NUMBER(1) DEFAULT 0;
  v_isagency_ptrn_exist NUMBER(1) DEFAULT 0;
  --  v_tablecnt            NUMBER(1) := 0;
  v_tableNametemp VARCHAR2(10);
  v_tableName     VARCHAR2(10);
  v_refKey        TITDMGCAMPCDE.ZCMPCODE@DMSTAGEDBLINK%type;

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
 v_zcrtusr             TITDMGCAMPCDE.ZCRTUSR@DMSTAGEDBLINK%type; /*Creation User */
 v_zappdate            TITDMGCAMPCDE.ZAPPDATE@DMSTAGEDBLINK%type;/*Campaign Approval Date */
 v_zccodind            TITDMGCAMPCDE.ZCCODIND@DMSTAGEDBLINK%type;/*C-Code Indicator */
 v_effdate             TITDMGCAMPCDE.EFFDATE@DMSTAGEDBLINK%type; /*Effective Date */
 v_status              TITDMGCAMPCDE.STATUS@DMSTAGEDBLINK%type;  /*Status */
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/





  ------Constant
  C_PREFIX     constant varchar2(2) := GET_MIGRATION_PREFIX('CMCD',
                                                            i_company);
  C_ERRORCOUNT constant number := 5;

  C_Z010 constant varchar2(4) := 'RQLQ'; /*Endorser Code Not Valid */
  C_Z013 constant varchar2(4) := 'RQLT'; /* Invalid Date*/
  C_Z036 constant varchar2(4) := 'RQMG'; /*Invalid Grp Master */
  C_Z037 constant varchar2(4) := 'RQMH'; /*Invalid Product code */
  C_Z058 constant varchar2(4) := 'RQN2'; /* Must be G or I only.*/
  C_Z059 constant varchar2(4) := 'RQN3'; /* Invalid Agency Pattern ID*/
  C_Z060 constant varchar2(4) := 'RQN4'; /*Must be in TQ9RA */--UPDATE THE ERROR DESCRIPTION
  C_Z099 constant varchar2(4) := 'RQO6'; /*Duplicate record found. */

  /**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
  C_Z133 constant varchar2(4) := 'RQZO'; /*Campaign Code is mandatory	                */ 
  C_Z134 constant varchar2(4) := 'RQZP'; /*Pet name is mandatory	                    */ 
  C_Z135 constant varchar2(4) := 'RQZQ'; /*Policy Classification is mandatory		    */ 
  C_Z136 constant varchar2(4) := 'RQZR'; /*Endorser Code is mandatory		            */ 
  C_Z137 constant varchar2(4) := 'RQZS'; /*Group Policy Number is mandatory.		    */ 
  C_Z138 constant varchar2(4) := 'RQZT'; /*Product Code is mandatory.		            */ 
  C_Z139 constant varchar2(4) := 'RQZU'; /*Agent Pattern ID is mandatory.		        */ 
  C_Z140 constant varchar2(4) := 'RQZV'; /*Risk Commencement is mandatory.		    */ 
  C_Z141 constant varchar2(4) := 'RQZW'; /*Campaign Period(From) is mandatory.		 */
  C_Z142 constant varchar2(4) := 'RQZX'; /*Campaign Period(To) is mandatory.		    */ 
  C_Z143 constant varchar2(4) := 'RQZY'; /*Mailout Date is mandatory.		            */ 
  C_Z144 constant varchar2(4) := 'RQZZ'; /*Announce Closure Date is mandatory.		 */
  C_Z145 constant varchar2(4) := 'RR01'; /*Delivery Date Campaign Data is mandatory.	 */
  C_Z146 constant varchar2(4) := 'RR02'; /*Campaign Stage not in TQ9R9.		        */ 
  C_Z147 constant varchar2(4) := 'RR03'; /*Campaign Scheme 2 not in TQ9RB.		    */ 
  C_Z148 constant varchar2(4) := 'RR04'; /*Creation User is mandatory.		        */ 
  C_Z149 constant varchar2(4) := 'RR05'; /*Campaign Approval Date is mandatory.		 */
  C_Z150 constant varchar2(4) := 'RR06'; /*Must be 善N? or 羨P? only.		            */ 
  C_Z028 constant varchar2(4) := 'RQM8'; /*Value must be 塑? or 鮮?    */ 
    C_Z151 constant varchar2(4) := 'RR43'; /*Vehicle not  in TQ9BR   */ 
 /**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/


  --------------Common Function Start---------
  itemexist    pkg_dm_common_operations.itemschec;
  o_errortext  pkg_dm_common_operations.errordesc;
  i_zdoe_info  pkg_dm_common_operations.obj_zdoe;
  checkchdrnum pkg_common_dmcm.gchdtype;
   checkdupl    pkg_common_dmcm.cmduplicate;
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

  ---------------Common function end-----------
  CURSOR cur_campaign_code IS
    SELECT * FROM TITDMGCAMPCDE@DMSTAGEDBLINK;

  obj_campaigncode cur_campaign_code%rowtype;

BEGIN
  /* DBMS_PROFILER.start_profiler('DM MBR NEW-5  ' ||
  TO_CHAR(SYSDATE, 'YYYYMMDD HH24:MI:SS'));*/

  ---------Common Function Calling------------
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMCM',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMCM',
                                        o_errortext   => o_errortext);
  pkg_common_dmcm.checkmasterpol(checkchdrnum => checkchdrnum);
  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) ||
                     LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName);
    pkg_common_dmcm.checkcmdup(checkdupl => checkdupl);

  /*SELECT count(*)
   into v_tablecnt
   FROM user_tables
  where TRIM(TABLE_NAME) = v_tableName;*/
  ---------Common Function Calling------------
  ---Open Cursor
  --select count(1) into v_isendrcodeexist  from TITDMGCAMPCDE@DMSTAGEDBLINK;

  OPEN cur_campaign_code;
  <<skipRecord>>
  LOOP
    FETCH cur_campaign_code
      INTO obj_campaigncode;
    EXIT WHEN cur_campaign_code%notfound;
    v_zcmpcode := obj_campaigncode.zcmpcode;
    v_refKey   := TRIM(v_zcmpcode);

    /**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
    v_zcrtusr       := TRIM(obj_campaigncode.ZCRTUSR);   /*Creation User */
    v_zappdate      := TRIM(obj_campaigncode.ZAPPDATE);  /*Campaign Approval Date */
    v_zccodind      := TRIM(obj_campaigncode.ZCCODIND); /*C-Code Indicator */
    v_effdate       := TRIM(obj_campaigncode.EFFDATE); /*Effective Date */
    v_status        := TRIM(obj_campaigncode.STATUS);   /*Status */
    /**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----------Initialization -------
    i_zdoe_info              := Null;
    i_zdoe_info.i_zfilename  := 'TITDMGCAMPCDE';
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
    ----------Initialization -------

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--CHECK IF ZCMPCODE-Campaign Code  IS BLANK---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ---Check for duplicate record
    /* select count(RECIDXOTHERS)
      into v_isDuplicate
      FROM Jd1dta.PAZDROPF
     WHERE RTRIM(ZENTITY) = TRIM(v_zcmpcode);
    IF v_isDuplicate > 0 THEN*/
    IF (checkdupl.exists(TRIM(v_zcmpcode))) THEN
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/

--CHECK IF ZPETNAME-Pet Name IS BLANK-----
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--CHECK IF ZPOLCLS-Policy Classification  IS BLANK-----
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Policy Classification  Validation
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

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--CHECK IF ZENDCODE-Endorser Code  IS BLANK-----
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/



    ----Endorser Code  Validation

    SELECT count(*)
      into v_isendrcodeexist
      FROM ZENDRPF
     where RTRIM(zendcde) = TRIM(obj_campaigncode.zendcode);

    IF (v_isendrcodeexist < 1) THEN
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group CHDRNUM-Policy Number is a mandatory field if Policy Classification = 賎?---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/



    ----Group Policy Number Validation

    /*
    select count(*)
      into v_ispolicyexist
      from GCHD
    -- from CHDRPF  previously as per the Bq9br
     where TRIM(CHDRPFX) = TRIM('CH')
       AND TRIM(CHDRCOY) = TRIM(i_company)
       AND TRIM(CHDRNUM) = TRIM(obj_campaigncode.chdrnum);*/

      IF (TRIM(obj_campaigncode.ZPOLCLS) = 'G') THEN
      IF NOT (checkchdrnum.exists(TRIM(obj_campaigncode.chdrnum) ||
                                  TRIM(i_company))) THEN
        -- IF (v_ispolicyexist < 1) THEN
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group GPOLTYP-Product Code is a mandatory field if Policy Classification = 選?---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/



    ----Product Code Validation
    IF NOT
        (itemexist.exists(TRIM('T9799') || TRIM(obj_campaigncode.gpoltyp) || 1)) THEN---in current TSD the table is TQ9B6 "Check if product code exists in TQ9B6"
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZAGPTID-Agent Pattern ID is a mandatory field if Policy Classification = 選?.---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/


    ----Agency Pattern ID Validation
    select count(*)
      into v_isagency_ptrn_exist
      from ZAGPPF
     where TRIM(ZAGPTPFX) = TRIM('AP')
       and TRIM(ZAGPTNUM) = TRIM(obj_campaigncode.zagptid)
       and TRIM(ZAGPTCOY) = TRIM(i_company)
       and TRIM(VALIDFLAG) = TRIM('1');
    IF (v_isagency_ptrn_exist < 1) THEN
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group RCDATE-Risk Commencement Date is a mandatory field if Policy Classification = 賎? or 選?.---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Risk Commencement Date Validation
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZCMPFRM-Campaign Period(From) is a mandatory field if Policy Classification = 賎? or 選?.---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Campaign Period(From) Validation
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZCMPTO-Campaign Period(To) is a mandatory field if Policy Classification = 賎? or 選?.---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Campaign Period (To) Validation
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZMAILDAT-Mailout Date is a mandatory field if Policy Classification = 賎? or 選?..---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Mailout Date Validation
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZACLSDAT-Announce Closure Date is a mandatory field if Policy Classification = 賎? or 選?.---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Announced Closure Date validation
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


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZDLVCDDT-Delivery Date Campaign Data is a mandatory field if Policy Classification = 賎? or 選?..---
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

    ----Delivery Date Campaign Date validation
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

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZSTAGE-Stage	Must be in table TQ9R9.---
IF NOT (itemexist.exists(TRIM('TQ9R9') || TRIM(obj_campaigncode.ZSTAGE) || 1)) THEN
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZSCHEME01  -Campaign scheme 1	Must be in table TQ9BR.---
IF NOT (itemexist.exists(TRIM('TQ9RA') || TRIM(obj_campaigncode.ZSCHEME01) || 1)) THEN
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZSCHEME02-Campaign scheme 2	Must be in table TQ9BR.---
IF NOT (itemexist.exists(TRIM('TQ9RB') || TRIM(obj_campaigncode.ZSCHEME02) || 1)) THEN
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
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/

/**** ITR-4 :  MOD : condition change due to new requirement : START ****/
    ----Campaign scheme01 Validation
    ---Must be in table TXXXX. (To be updated in IT4) , This logic to be implemented after IT4 development
--    IF TRIM(obj_campaigncode.zscheme01) IS NULL THEN
--      v_isAnyError := 'Y';
--      v_errorCount := v_errorCount + 1;
--      t_ercode(v_errorCount) := C_Z060;
--      t_errorfield(v_errorCount) := 'ZSCHEME01';
--      t_errormsg(v_errorCount) := o_errortext(C_Z060);
--      t_errorfieldval(v_errorCount) := obj_campaigncode.zscheme01;
--      t_errorprogram(v_errorCount) := i_scheduleName;
--      IF v_errorCount >= C_ERRORCOUNT THEN
--        GOTO insertzdoe;
--      END IF;
--    END IF;

    ----Campaign scheme01 Validation
    ---Must be in table TXXXX. (To be updated in IT4) , This logic to be implemented after IT4 development
--    IF (TRIM(obj_campaigncode.zscheme02) IS NULL) THEN
--      v_isAnyError := 'Y';
--      v_errorCount := v_errorCount + 1;
--      t_ercode(v_errorCount) := C_Z060;
--      t_errorfield(v_errorCount) := 'ZSCHEME02';
--      t_errormsg(v_errorCount) := o_errortext(C_Z060);
--      t_errorfieldval(v_errorCount) := obj_campaigncode.zscheme02;
--      t_errorprogram(v_errorCount) := i_scheduleName;
--      IF v_errorCount >= C_ERRORCOUNT THEN
--        GOTO insertzdoe;
--      END IF;
--    END IF;
/**** ITR-4 :  MOD: condition change due to new requirement : END ****/


/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/
--Group ZCRTUSR-Creation User is a mandatory field. Must not be blank.---
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


--Group ZAPPDATE-Campaign Approval Date is a mandatory field. Must not be blank.---
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


--Group ZAPPDATE-Must be a valid date and in correct format YYYYMMDD---
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

--Group ZCCODIND-Must be 塑? or 鮮?---
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

--Group EFFDATE-Agent Pattern ID is a mandatory field if Policy Classification = 選?.---
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

--Group STATUS-Valid Value = 善N? (Pending) or 羨P?(Approved)---
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

--
IF NOT (itemexist.exists(TRIM('TQ9BR') || TRIM(obj_campaigncode.ZVEHICLE) || 1)) THEN
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

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/


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

      ---Inser into Registry table
      INSERT INTO Jd1dta.PAZDROPF
        (PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
      VALUES
        (C_PREFIX,
         v_zcmpcode,
         v_zcmpcode,
         i_scheduleNumber,
         i_scheduleName);

/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : START ****/         
      ------Insert Into IG table
      insert into Zcpnpf
        (ZCMPCODE,
         ZPETNAME,
         ZPOLCLS,
         ZENDCDE,
         CHDRNUM,
         GPLOTYP,
         ZAGPTID,
         RCDATE,
         ZCMPFRM,
         ZCMPTO,
         ZMAILDAT,
         ZACLSDAT,
         ZDLVCDDT,
         ZVEHICLE,
         ZSTAGE,
         ZSCHEME01,
         ZSCHEME02,
         EFFDATE,
         USRPRF,
         JOBNM,
         DATIME,
         ZCRTUSR,--ITR4 ADD
         ZAPPDATE,--ITR4 ADD
         ZCCODIND,--ITR4 ADD
         STATUS)--ITR4 ADD
      values
        (v_zcmpcode,
         obj_campaigncode.zpetname,
         obj_campaigncode.zpolcls,
         obj_campaigncode.zendcode,
         obj_campaigncode.chdrnum,
         obj_campaigncode.gpoltyp,
         obj_campaigncode.zagptid,
         obj_campaigncode.rcdate,
         obj_campaigncode.zcmpfrm,
         obj_campaigncode.zcmpto,
         obj_campaigncode.zmaildat,
         obj_campaigncode.zaclsdat,
         obj_campaigncode.zdlvcddt,
         obj_campaigncode.zvehicle,
         obj_campaigncode.zstage,
         obj_campaigncode.zscheme01,
         obj_campaigncode.zscheme02,
         obj_campaigncode.EFFDATE,--ITR4 CHANGE
         i_usrprf,
         i_scheduleName,
         CAST(sysdate AS TIMESTAMP),
         obj_campaigncode.ZCRTUSR,--ITR4 ADD
         obj_campaigncode.ZAPPDATE,--ITR4 ADD
         obj_campaigncode.ZCCODIND,--ITR4 ADD
         obj_campaigncode.STATUS)--ITR4 ADD
         ;
/**** ITR-4 :  ADD : new column added for TITDMGCAMPCDE table : END ****/
    END IF;

  END LOOP;
  CLOSE cur_campaign_code;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
  /* DBMS_PROFILER.stop_profiler;*/
END BQ9S8_CM01_CAMPCD;