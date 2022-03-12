create or replace PROCEDURE        Jd1dta.BQ9TK_BL01_BILLHIST (
    i_scheduleName   IN VARCHAR2,
    i_scheduleNumber IN VARCHAR2,
    i_zprvaldYN      IN VARCHAR2,
    i_company        IN VARCHAR2,
    i_usrprf         IN VARCHAR2,
    i_branch         IN VARCHAR2,
    i_transCode      IN VARCHAR2,
    i_vrcmTermid     IN VARCHAR2,
    i_user_t         IN NUMBER, 
    i_vrcmtime       IN NUMBER, 
    i_vrcmuser       IN NUMBER,
    i_acctYear       IN NUMBER,
    i_acctMonth      IN NUMBER,
    i_array_size     IN PLS_INTEGER DEFAULT 1000,
    start_id         IN NUMBER,
    end_id           IN NUMBER)
AUTHID current_user AS

/***************************************************************************************************
    Amendment History: BL01 Billing History
    Date    Initials   Tag   Description
    -----   --------   ---   ---------------------------------------------------------------------------
   Dec22	   CHO          	 PA ITR3 Implementation
   Jan04     CHO             MSD SHI issue 2-9 (SP9) - changed from > to <>
                             IG product functionality and SHI issue P26 - removed
   Jan06     CHO             Move MSD SHI issue 2-9 (SP8) : for assigning of PTDATE to PV script
                             Move MSD SHI issue 2-9 (SP9) : for assigning of BTDATE to PV script
                             Move MSD SHI issue 2-8 : for assigning of PTDATE to PV script
   Jan29     CHO       BL1   Put table join in CURSOR instead of using pkg_common_dmbl for validation performance
   Apr6		 KLP	   BL2	 ZJNPG-9348, Changed the logic to get the bank transfer date using the posting month and year instead of bill from date
   Apr21  	 KLP	   BL3   ZJNPG-9139, Refactored the code to improve the performance and avoid inner loops for large set of data
   Jun21     KLP       BL4   ZJNPG-9739, Added commit and to ingore the pre-validation checks for cursor 2 and 3 
   Jul02     KLP       BL5   ZJNPG-9739, Changes to cursor 2 and 3 and made single cursor for performance improvement 
   Jul07     KLP       BL6   ZJNPG-9739, Changes to include the registry table in the cursor to avoid mem issue 
   Jul12     KLP       BL7   ZJNPG-9739, Fixed the code to comment the cursor 3 and change to cursor 2 variable for GBIDPF insertion
   Aug16	 KLP	   BL8   ZJNPG-9923 ,Fixed the code to set the bprem value correctly
   Nov24     KLP       BL9   ZJNPG-9739, Fixed the code to get the premium value from bill2 instead of GPMD to insert into GBIDPF
   Feb28-22  KLP       BL10  ZJNPG-10449, Changed the new altearation code as per the new alteration code mapping
  *****************************************************************************************************/

  --------Local Variable : Start---------
  p_exitcode         number;
  p_exittext         varchar2(2000);
  v_timestart        NUMBER := dbms_utility.get_time;  

  v_tableNametemp    VARCHAR2(10);
  v_tableName        VARCHAR2(10);
  v_date             VARCHAR2(20);
  n_errorCount       NUMBER(1) DEFAULT 0;
  n_errorCount2      NUMBER(1) DEFAULT 0;
  n_errorCount3      NUMBER(1) DEFAULT 0;
  b_isNoError        BOOLEAN := TRUE;
  b_isNoError2       BOOLEAN := TRUE;
  b_isNoError3       BOOLEAN := TRUE;

  C_limit     PLS_INTEGER := i_array_size;
  n_billno    ANUMPF.AUTONUM%type;
  n_trdt      GBIHPF.TRDT%type;
  v_billduedt GBIHPF.BILLDUEDT%type;
  v_ptdate    gchd.ptdate%type;
  v_btdate    gchd.btdate%type;  
  --------Local Variable : End---------

  -----------Unique numbers : Start-----------
  v_seq_gbihpf gbihpf.unique_number%type;
  v_seq_gpmdpf gpmdpf.unique_number%type;
  v_seq_gbidpf gbidpf.unique_number%type;
  -----------Unique numbers : End-----------

  ------IG table obj : Start------		  
  obj_VIEW_DM_GBIHPF    Jd1dta.VIEW_DM_GBIHPF%rowtype;
  obj_VIEW_DM_GBIDPF    Jd1dta.VIEW_DM_GBIDPF%rowtype;
  obj_VIEW_DM_GPMDPF    Jd1dta.VIEW_DM_GPMDPF%rowtype;
  obj_VIEW_DM_PAZDRBPF  Jd1dta.VIEW_DM_PAZDRBPF%rowtype;
  ------IG table obj : End------ 

  --------------Constant : Start------------
  C_BQ9TK         CONSTANT VARCHAR2(5)        := 'BQ9TK';
  C_PREFIX        CONSTANT VARCHAR2(2)        := GET_MIGRATION_PREFIX('BILL', i_company);
  C_RECORDSUCCESS CONSTANT VARCHAR2(20)       := 'Record successful';
  C_SUCCESS       CONSTANT VARCHAR2(1)        := 'S';
  C_ERROR         CONSTANT VARCHAR2(1)        := 'E';
  C_MAXDATE       CONSTANT NUMBER(8)          := 99999999;
  --------------Constant : End-------------

  --------------Common Function : Start-------------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info1    pkg_dm_common_operations.obj_zdoe;
  i_zdoe_info2    pkg_dm_common_operations.obj_zdoe;
  i_zdoe_info3    pkg_dm_common_operations.obj_zdoe;

--  checkchdrnum  pkg_common_dmbl.gchdtype;
--   getZdrbpf     pkg_common_dmbl.duplicateZdrbpf;--- changes for BL6
--  getGpmdpf     pkg_common_dmbl.duplicateGpmdpf;
  getGbidpf     pkg_common_dmbl.duplicateGbidpf;
--  getZtrapf     pkg_common_dmbl.existZtrapf;
  --------------Common Function : End------------

  --------------Error Type : Start------------
  type ercode_tab
  IS
    TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  t_ercode2 ercode_tab;
  t_ercode3 ercode_tab;

  type errorfield_tab
  IS
    TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  t_errorfield2 errorfield_tab;
  t_errorfield3 errorfield_tab;

  type errormsg_tab
  IS
    TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  t_errormsg2 errormsg_tab;
  t_errormsg3 errormsg_tab;

  type errorfieldvalue_tab
  IS
    TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  t_errorfieldval2 errorfieldvalue_tab;
  t_errorfieldval3 errorfieldvalue_tab;

  type errorprogram_tab
  IS
    TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;
  t_errorprogram2 errorprogram_tab;
  t_errorprogram3 errorprogram_tab;
  --------------Error Type : End-------------

  --------------------Cursor for TITDMGBILL1 : Start------------------
/*  CURSOR c_billing1
  IS
    SELECT A.*, B.CHDRNUM GCHD, C.CHDRNUM ZTRAPF
      FROM Jd1dta.DMIGTITDMGBILL1 A
      LEFT JOIN Jd1dta.GCHD B
        ON A.CHDRNUM = B.CHDRNUM
      LEFT JOIN Jd1dta.ZTRAPF C
        ON A.CHDRNUM = C.CHDRNUM
       AND C.ZCSTPBIL = 'Y'
       AND C.ZALTRCDE01 IN ('T0B', 'T0D', 'T0F', 'T0Z', 'T04', 'T08')
     WHERE A.REFNUMCHUNK BETWEEN START_ID AND END_ID -- for parallel processing
     ORDER BY A.CHDRNUM, A.PRBILFDT;
*/
-- Changed below cursor for BL3
-- Changed below cursor for BL6, to include registry table to check dup rec
    CURSOR c_billing1 IS
    SELECT
        a.*,
        b.chdrnum   gchd,
        c.chdrnum   ztrapf,
        e.zcolmcls,
        e.hldcount,
        e.zbktrfdt,
        mig.chdrnum mig_bill
    FROM
        Jd1dta.dmigtitdmgbill1   a
        LEFT JOIN Jd1dta.gchd              b ON a.chdrnum = b.chdrnum
        LEFT JOIN Jd1dta.ztrapf            c ON a.chdrnum = c.chdrnum
                                     AND c.zcstpbil = 'Y'
                                     --AND c.zaltrcde01 IN ('T0B','T0D','T0F','T0Z','T04','T08')
									 AND c.zaltrcde01 IN ('ZTB','ZTD','ZTF','ZTZ','ZT4','ZT8')--  Changes for BL10
        LEFT JOIN (
                    SELECT
                        b.chdrnum,
                        d.zposbdsm,
                        d.zposbdsy,
                        b.zcolmcls,
                        b.hldcount,
                        d.zbktrfdt
                    FROM
                        Jd1dta.gchppf    b,
                        Jd1dta.zendrpf   c,
                        Jd1dta.zesdpf    d
                    WHERE
                        b.zendcde = c.zendcde
                        AND c.zendscid = d.zendscid
                   ) e  
                ON a.chdrnum = e.chdrnum
                       AND a.zposbdsm = e.zposbdsm
                       AND a.zposbdsy = e.zposbdsy
          LEFT JOIN  Jd1dta.PAZDRBPF mig
          ON mig.chdrnum = a.chdrnum
          and mig.prbilfdt =  a.prbilfdt
          and mig.PREFIX = 'BL'
    WHERE
        a.refnumchunk BETWEEN start_id AND end_id -- for parallel processing
    ORDER BY
        a.chdrnum,
        a.prbilfdt;
--- Changes ended for BL3

  obj_billing1 c_billing1%rowtype;
  type t_billing1_list is table of c_billing1%rowtype;
  billing1_list t_billing1_list;

--- BL2 Changes started  
--- BL3 Changes started 
/*  CURSOR c_billing1a (i_chdrnum varchar2, i_prbilfdt number)
  IS
    SELECT b.zcolmcls, b.hldcount, d.zbktrfdt
      FROM Jd1dta.GCHPPF b, Jd1dta.ZENDRPF c, Jd1dta.ZESDPF d
     WHERE i_chdrnum = b.chdrnum
       AND b.zendcde = c.zendcde
       AND c.zendscid = d.zendscid
       AND i_prbilfdt = d.zcovcmdt;      */

	/*CURSOR c_billing1a (i_chdrnum varchar2, i_posbdsm number, i_posbdsy number)
	IS 
	SELECT b.zcolmcls, b.hldcount, d.zbktrfdt
		FROM Jd1dta.GCHPPF b, Jd1dta.ZENDRPF c, Jd1dta.ZESDPF d
	WHERE  b.chdrnum = i_chdrnum
		AND b.zendcde = c.zendcde
		AND c.zendscid = d.zendscid
		AND d.zposbdsm = i_posbdsm 
		AND d.zposbdsy = i_posbdsy;
        */
--- BL3 Changes ended



--- BL2 Changes Ended	   
  --------------------Cursor for TITDMGBILL1 : End---------------------

  --------------------Cursor for TITDMGBILL2 : Start-------------------
-- Changes for BL5
-- Changes for BL9
  CURSOR c_billing2
  IS
SELECT A.*, B.ZIGVALUE, B.PRBILTDT, C.CHDRNUM GPMDPF,
 D.BILLNO GBID_BILLNO,
SUM(A.BPREM)  OVER (PARTITION BY A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP)  GBID_PREM,
ROW_NUMBER() OVER (PARTITION BY A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP order by A.CHDRNUM, A.PRODTYP) CNT_REC

      FROM Jd1dta.DMIGTITDMGBILL2 A
      LEFT JOIN Jd1dta.PAZDRBPF B
        ON A.CHDRNUM = B.CHDRNUM
       AND TRIM(A.TRREFNUM) = TRIM(B.ZENTITY)
       AND A.PRBILFDT = B.PRBILFDT
      LEFT JOIN Jd1dta.gpmdpf C
        ON A.CHDRNUM = C.CHDRNUM
       AND A.PRBILFDT = C.PRMFRDT
         and C.BILLTYP = 'N'
       AND TRIM(A.PRODTYP) = TRIM(C.PRODTYP)
       AND TRIM(A.MBRNO) = TRIM(C.MBRNO)
       AND TRIM(A.DPNTNO) = TRIM(C.DPNTNO)
      LEFT JOIN Jd1dta.GBIDPF D
      ON D.BILLNO = B.ZIGVALUE 
      AND D.PRODTYP = TRIM(A.PRODTYP)
     WHERE  A.REFNUMCHUNK BETWEEN START_ID AND END_ID -- for parallel processing
     ORDER BY A.CHDRNUM, A.PRBILFDT, A.TRANNO, B.ZIGVALUE, A.PRODTYP;

  /*CURSOR c_billing2
  IS
    SELECT A.*, B.ZIGVALUE, B.PRBILTDT, C.CHDRNUM GPMDPF
      FROM Jd1dta.DMIGTITDMGBILL2 A
      LEFT JOIN Jd1dta.PAZDRBPF B
        ON A.CHDRNUM = B.CHDRNUM
       AND TRIM(A.TRREFNUM) = TRIM(B.ZENTITY)
       AND A.PRBILFDT = B.PRBILFDT
      LEFT JOIN Jd1dta.GPMDPF C
        ON A.CHDRNUM = C.CHDRNUM
       AND A.PRBILFDT = C.PRMFRDT
         and C.BILLTYP = 'N'
       AND TRIM(A.PRODTYP) = TRIM(C.PRODTYP)
       AND TRIM(A.MBRNO) = TRIM(C.MBRNO)
       AND TRIM(A.DPNTNO) = TRIM(C.DPNTNO)
     WHERE A.REFNUMCHUNK BETWEEN START_ID AND END_ID -- for parallel processing
     ORDER BY A.CHDRNUM, A.PRBILFDT;
     */


  obj_billing2 c_billing2%rowtype;
  type t_billing2_list is table of c_billing2%rowtype;
  billing2_list t_billing2_list;

--- Added commit variables for BL5
  v_commit_interval pls_integer := 50000;
  v_commit_limit    pls_integer := 50000;
  cntr              pls_integer;
-- Changed for BL7
/*
  CURSOR c_billing3
  IS
    SELECT A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP, SUM(A.BPREM) BPREM
      FROM Jd1dta.DMIGTITDMGBILL2 A
      LEFT JOIN Jd1dta.PAZDRBPF B
        ON A.CHDRNUM = B.CHDRNUM
       AND TRIM(A.TRREFNUM) = TRIM(B.ZENTITY)
       AND A.PRBILFDT = B.PRBILFDT
     WHERE A.REFNUMCHUNK BETWEEN START_ID AND END_ID -- for parallel processing
     GROUP BY A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP
     ORDER BY A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP;

  obj_billing3 c_billing3%rowtype;
  type t_billing3_list is table of c_billing3%rowtype;
  billing3_list t_billing3_list;

*/
  --------------------Cursor for TITDMGBILL2 : End-------------------

BEGIN
  dbms_output.put_line('Start execution of BQ9TK_BL01_BILLHIST, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  ---------Common Function Calling : Start------------
  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9TK,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMBL', 
                                        o_errortext   => o_errortext);
  pkg_dm_common_operations.checkitemexist(i_module_name => C_BQ9TK, 
                                          itemexist     => itemexist);

--  pkg_common_dmbl.checkpolicy(i_company     => i_company, 
--                              checkchdrnum  => checkchdrnum);
--   pkg_common_dmbl.getZdrbpf(getZdrbpf => getZdrbpf);-- Changes for BL6
--  pkg_common_dmbl.getGpmdpf(getGpmdpf => getGpmdpf);
--   pkg_common_dmbl.getGbidpf(getGbidpf => getGbidpf);--- BL5 Commented for memory issue
--  pkg_common_dmbl.getZtrapf(getZtrapf => getZtrapf);
  ---------Common Function Calling : End------------

  v_tableNametemp := 'ZDOE' || TRIM(C_PREFIX) || LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_tableName     := TRIM(v_tableNametemp);

  ---------------------TRDT From BSUDPF--------------------
  SELECT TO_CHAR(to_date(BUSDATE, 'YYYYMMDD'), 'YYMMDD')
  INTO n_trdt
  FROM BUSDPF
  WHERE COMPANY = '1';
/*
  -------------- BILLNO From ANUMPF --------------------------
  SELECT AUTONUM + 1
  INTO n_billno
  FROM ANUMPF
  WHERE COMPANY = i_company
  AND PREFIX    = 'PR';
*/  
  OPEN c_billing1;

  LOOP
    FETCH c_billing1 BULK COLLECT 
    INTO billing1_list LIMIT C_limit;

    <<again_start>>
    for i in 1 .. billing1_list.count loop

      obj_billing1 := billing1_list(i);

      i_zdoe_info1              := NULL;
      i_zdoe_info1.i_zfilename  := 'TITDMGBILL1';
      i_zdoe_info1.i_prefix     := C_PREFIX;
      i_zdoe_info1.i_scheduleno := i_scheduleNumber;
      i_zdoe_info1.i_refKey     := obj_billing1.PRBILFDT || '-' || obj_billing1.CHDRNUM;
      i_zdoe_info1.i_tableName  := v_tableName;
      n_errorCount              := 0;
      t_ercode(1)               := NULL;
      t_ercode(2)               := NULL;
      t_ercode(3)               := NULL;
      t_ercode(4)               := NULL;
      t_ercode(5)               := NULL;
      b_isNoError               := TRUE;

      ---------------------TITDMGBILL1 Validations : Start------------------
      -----------------Duplicate Record Validation----------------
     -- IF (getZdrbpf.exists(obj_billing1.PRBILFDT || TRIM(obj_billing1.CHDRNUM))) THEN
       IF obj_billing1.mig_bill is not NULL THEN -- Changes for BL06 
        b_isNoError                   := FALSE;
        n_errorCount                  := n_errorCount + 1;
        t_ercode(n_errorCount)        := 'RQMA';
        t_errorfield(n_errorCount)    := 'CHDRNUM';
        t_errormsg(n_errorCount)      := o_errortext('RQMA');
        t_errorfieldval(n_errorCount) := obj_billing1.CHDRNUM;
        t_errorprogram(n_errorCount)  := i_scheduleName;
        GOTO insertzdoe;
      END IF;

      -----------------CHDRNUM Validation----------------
--      IF NOT (checkchdrnum.exists(TRIM(obj_billing1.CHDRNUM))) THEN - BL1
      IF obj_billing1.GCHD IS NULL THEN
        b_isNoError                   := FALSE;
        n_errorCount                  := n_errorCount + 1;
        t_ercode(n_errorCount)        := 'RQMB';
        t_errorfield(n_errorCount)    := 'CHDRNUM';
        t_errormsg(n_errorCount)      := o_errortext('RQMB');
        t_errorfieldval(n_errorCount) := obj_billing1.CHDRNUM;
        t_errorprogram(n_errorCount)  := i_scheduleName;
        GOTO insertzdoe;
      END IF;

      -------------------PREMIUM OUTSTANDING Validation----------------
      IF obj_billing1.PREMOUT         <> 'Y' AND obj_billing1.PREMOUT <> 'N' THEN
        b_isNoError                   := FALSE;
        n_errorCount                  := n_errorCount + 1;
        t_ercode(n_errorCount)        := 'RQM8';
        t_errorfield(n_errorCount)    := 'PREMOUT';
        t_errormsg(n_errorCount)      := o_errortext('RQM8');
        t_errorfieldval(n_errorCount) := obj_billing1.PREMOUT;
        t_errorprogram(n_errorCount)  := i_scheduleName;
        IF n_errorCount               >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;

      ------------------------PERIOD OF BILLING Validation---------------------
      v_date                          := VALIDATE_DATE(obj_billing1.PRBILFDT);
      IF v_date                       <> 'OK' THEN
        b_isNoError                   := FALSE;
        n_errorCount                  := n_errorCount + 1;
        t_ercode(n_errorCount)        := 'RQLT';
        t_errorfield(n_errorCount)    := 'PRBILFDT';
        t_errormsg(n_errorCount)      := o_errortext('RQLT');
        t_errorfieldval(n_errorCount) := obj_billing1.PRBILFDT;
        t_errorprogram(n_errorCount)  := i_scheduleName;
        IF n_errorCount               >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;

      v_date                          := VALIDATE_DATE(obj_billing1.PRBILTDT);
      IF v_date                       <> 'OK' THEN
        b_isNoError                   := FALSE;
        n_errorCount                  := n_errorCount + 1;
        t_ercode(n_errorCount)        := 'RQLT';
        t_errorfield(n_errorCount)    := 'PRBILTDT';
        t_errormsg(n_errorCount)      := o_errortext('RQLT');
        t_errorfieldval(n_errorCount) := obj_billing1.PRBILTDT;
        t_errorprogram(n_errorCount)  := i_scheduleName;
        IF n_errorCount               >= 5 THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      ---------------------TITDMGBILL1 Validations : End------------------

      ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGBILL1---
      <<insertzdoe>>
      IF (b_isNoError                    = FALSE) THEN
        IF TRIM(t_ercode(1))            IS NOT NULL THEN
          i_zdoe_info1.i_indic          := C_ERROR;
          i_zdoe_info1.i_error01        := t_ercode(1);
          i_zdoe_info1.i_errormsg01     := t_errormsg(1);
          i_zdoe_info1.i_errorfield01   := t_errorfield(1);
          i_zdoe_info1.i_fieldvalue01   := t_errorfieldval(1);
          i_zdoe_info1.i_errorprogram01 := t_errorprogram(1);
        END IF;
        IF TRIM(t_ercode(2))            IS NOT NULL THEN
          i_zdoe_info1.i_indic          := C_ERROR;
          i_zdoe_info1.i_error02        := t_ercode(2);
          i_zdoe_info1.i_errormsg02     := t_errormsg(2);
          i_zdoe_info1.i_errorfield02   := t_errorfield(2);
          i_zdoe_info1.i_fieldvalue02   := t_errorfieldval(2);
          i_zdoe_info1.i_errorprogram02 := t_errorprogram(2);
        END IF;
        IF TRIM(t_ercode(3))            IS NOT NULL THEN
          i_zdoe_info1.i_indic          := C_ERROR;
          i_zdoe_info1.i_error03        := t_ercode(3);
          i_zdoe_info1.i_errormsg03     := t_errormsg(3);
          i_zdoe_info1.i_errorfield03   := t_errorfield(3);
          i_zdoe_info1.i_fieldvalue03   := t_errorfieldval(3);
          i_zdoe_info1.i_errorprogram03 := t_errorprogram(3);
        END IF;
        IF TRIM(t_ercode(4))            IS NOT NULL THEN
          i_zdoe_info1.i_indic          := C_ERROR;
          i_zdoe_info1.i_error04        := t_ercode(4);
          i_zdoe_info1.i_errormsg04     := t_errormsg(4);
          i_zdoe_info1.i_errorfield04   := t_errorfield(4);
          i_zdoe_info1.i_fieldvalue04   := t_errorfieldval(4);
          i_zdoe_info1.i_errorprogram04 := t_errorprogram(4);
        END IF;
        IF TRIM(t_ercode(5))            IS NOT NULL THEN
          i_zdoe_info1.i_indic          := C_ERROR;
          i_zdoe_info1.i_error05        := t_ercode(5);
          i_zdoe_info1.i_errormsg05     := t_errormsg(5);
          i_zdoe_info1.i_errorfield05   := t_errorfield(5);
          i_zdoe_info1.i_fieldvalue05   := t_errorfieldval(5);
          i_zdoe_info1.i_errorprogram05 := t_errorprogram(5);
        END IF;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1);
        CONTINUE again_start;
      END IF;

      IF b_isNoError               = TRUE THEN
        i_zdoe_info1.i_indic      := C_SUCCESS;
        i_zdoe_info1.i_errormsg01 := C_RECORDSUCCESS;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1);
      END IF;

      IF b_isNoError = TRUE AND i_zprvaldYN = 'N' THEN

        ---------------------IG Table GBIHPF Values-----------------

        SELECT SEQ_BILLNO.nextval INTO n_billno FROM dual; 
        select SEQ_GBIHPF.nextval into v_seq_gbihpf from dual;

        obj_VIEW_DM_GBIHPF.UNIQUE_NUMBER  := v_seq_gbihpf;
        obj_VIEW_DM_GBIHPF.BILLNO         := n_billno;
        obj_VIEW_DM_GBIHPF.CHDRCOY        := i_company;
        obj_VIEW_DM_GBIHPF.CHDRNUM        := obj_billing1.CHDRNUM;
        obj_VIEW_DM_GBIHPF.SUBSCOY        := ' ';
        obj_VIEW_DM_GBIHPF.SUBSNUM        := '        ';
        obj_VIEW_DM_GBIHPF.MBRNO          := '     ';
        obj_VIEW_DM_GBIHPF.BILLTYP        := o_defaultvalues('BILLTYP');
        obj_VIEW_DM_GBIHPF.PRBILFDT       := obj_billing1.PRBILFDT;
        obj_VIEW_DM_GBIHPF.PRBILTDT       := obj_billing1.PRBILTDT;
        obj_VIEW_DM_GBIHPF.INSTNO         := obj_billing1.TRREFNUM;
        obj_VIEW_DM_GBIHPF.PBILLNO        := '0';
        obj_VIEW_DM_GBIHPF.TERMID         := i_vrcmTermid;
        obj_VIEW_DM_GBIHPF.TRDT           := n_trdt;
        obj_VIEW_DM_GBIHPF.TRTM           := i_vrcmtime;
        obj_VIEW_DM_GBIHPF.TRANNO         := obj_billing1.TRANNO;
        obj_VIEW_DM_GBIHPF.GRPGST         := '0';
        obj_VIEW_DM_GBIHPF.GRPSDUTY       := '0';
        obj_VIEW_DM_GBIHPF.VALIDFLAG      := o_defaultvalues('VALIDFLAG');
        obj_VIEW_DM_GBIHPF.BILFLAG        := o_defaultvalues('BILFLAG');
        obj_VIEW_DM_GBIHPF.NRFLG          := obj_billing1.NRFLAG;
        obj_VIEW_DM_GBIHPF.TGTPCNT        := '0';
        obj_VIEW_DM_GBIHPF.REVFLAG        := o_defaultvalues('REVFLAG');
        obj_VIEW_DM_GBIHPF.USER_T         := i_user_t;
        obj_VIEW_DM_GBIHPF.PREMOUT        := obj_billing1.PREMOUT;
        obj_VIEW_DM_GBIHPF.ZGSTAFEE       := '0';
        obj_VIEW_DM_GBIHPF.ZGSTCOM        := '0';
        obj_VIEW_DM_GBIHPF.ZCOLFLAG       := obj_billing1.ZCOLFLAG;
        obj_VIEW_DM_GBIHPF.ZACMCLDT       := obj_billing1.ZACMCLDT;
        obj_VIEW_DM_GBIHPF.PAYDATE        := C_MAXDATE;
        obj_VIEW_DM_GBIHPF.ZPOSBDSM       := obj_billing1.ZPOSBDSM;
        obj_VIEW_DM_GBIHPF.ZPOSBDSY       := obj_billing1.ZPOSBDSY;
        obj_VIEW_DM_GBIHPF.RDOCPFX        := '  ';
        obj_VIEW_DM_GBIHPF.RDOCCOY        := ' ';
        obj_VIEW_DM_GBIHPF.RDOCNUM        := '         ';
        obj_VIEW_DM_GBIHPF.DATIME         := CAST(sysdate AS TIMESTAMP);
        obj_VIEW_DM_GBIHPF.JOBNM          := i_scheduleName;
        obj_VIEW_DM_GBIHPF.USRPRF         := i_usrprf;

        --MSD SHI issue 2-2 and 2-3 : for assigning of ZBKTRFDT and BILLDUEDT : Start
        obj_VIEW_DM_GBIHPF.ZBKTRFDT       := obj_billing1.TFRDATE;
        obj_VIEW_DM_GBIHPF.BILLDUEDT      := obj_billing1.PRBILFDT;

		-- Changes for the BL2
		-- Commented the c_billing1a cursor for the changes BL3
       -- for r1 in c_billing1a(obj_billing1.chdrnum, obj_billing1.ZPOSBDSM, obj_billing1.ZPOSBDSY) loop
          if obj_billing1.zcolmcls = 'F' then
            obj_VIEW_DM_GBIHPF.ZBKTRFDT   := obj_billing1.ZBKTRFDT;          
            obj_VIEW_DM_GBIHPF.BILLDUEDT  := obj_billing1.ZBKTRFDT;

          elsif obj_billing1.zcolmcls = 'C' then
            obj_VIEW_DM_GBIHPF.ZBKTRFDT   := C_MAXDATE;          

            if obj_billing1.hldcount is not null and obj_billing1.ZBKTRFDT <> C_MAXDATE then
              if obj_billing1.hldcount in (-1, 0) then
                select to_char(add_months(to_date(substr(obj_billing1.PRBILFDT, 0, 6) || '10', 'yyyymmdd'), obj_billing1.hldcount), 'yyyymmdd')
                into v_billduedt from dual;

                obj_VIEW_DM_GBIHPF.BILLDUEDT := v_billduedt;
              end if;
            end if;
          end if;
      --  end loop;
	  -- changes ended for BL3
        --MSD SHI issue 2-2 and 2-3 : for assigning of ZBKTRFDT and BILLDUEDT : End

        --MSD SHI issue 2-5 : for assigning of ZSTPBLYN : Start
        obj_VIEW_DM_GBIHPF.ZSTPBLYN     := ' ';
        IF obj_billing1.PREMOUT = 'Y' THEN
--          IF (getZtrapf.exists(TRIM(obj_billing1.CHDRNUM))) THEN - BL1
          IF obj_billing1.ZTRAPF IS NOT NULL THEN
            obj_VIEW_DM_GBIHPF.ZSTPBLYN := 'Y';
          END IF;
        END IF;
        --MSD SHI issue 2-5 : for assigning of ZSTPBLYN : End

        INSERT INTO Jd1dta.VIEW_DM_GBIHPF VALUES obj_VIEW_DM_GBIHPF;

        ---------------------IG Table PAZDRBPF Values-----------------
        obj_VIEW_DM_PAZDRBPF.PREFIX       := C_PREFIX;
        obj_VIEW_DM_PAZDRBPF.ZENTITY      := obj_billing1.TRREFNUM;
        obj_VIEW_DM_PAZDRBPF.CHDRNUM      := obj_billing1.CHDRNUM;
        obj_VIEW_DM_PAZDRBPF.ZIGVALUE     := TRIM(n_billno);
        obj_VIEW_DM_PAZDRBPF.JOBNUM       := i_scheduleNumber;
        obj_VIEW_DM_PAZDRBPF.JOBNAME      := i_scheduleName;
        obj_VIEW_DM_PAZDRBPF.PRBILFDT     := obj_billing1.PRBILFDT;
        obj_VIEW_DM_PAZDRBPF.PRBILTDT     := obj_billing1.PRBILTDT;
        obj_VIEW_DM_PAZDRBPF.ZPDATATXFLG  := obj_billing1.ZPDATATXFLG;

        INSERT INTO Jd1dta.VIEW_DM_PAZDRBPF VALUES obj_VIEW_DM_PAZDRBPF;

  --      n_billno := n_billno + 1;
      END IF;

    END LOOP;

    EXIT WHEN c_billing1%notfound;
  END LOOP;

  CLOSE c_billing1;
  commit; -- ZJNPG-9739
/*  
  --------------------------- ANUMPF Updation -----------------------
  UPDATE Jd1dta.ANUMPF
  SET AUTONUM   = n_billno - 1,
    USRPRF      = i_usrprf,
    JOBNM       = i_scheduleName,
    DATIME      = CURRENT_TIMESTAMP
  WHERE COMPANY = i_company
  AND PREFIX    = 'PR';
 COMMIT;
 */
  ---------------------------OPEN TITDMGBILL2 FOR GPMDPF-----------------------
if i_zprvaldYN = 'N' then --- ZJNPG-9739

  OPEN c_billing2;

  LOOP
    FETCH c_billing2 BULK COLLECT 
    INTO billing2_list LIMIT C_limit;

    <<again_start2>>
    for i in 1 .. billing2_list.count loop
      cntr := i;-- Added for BL5

      obj_billing2 := billing2_list(i);

      i_zdoe_info2              := NULL;
      i_zdoe_info2.i_zfilename  := 'TITDMGBILL2';
      i_zdoe_info2.i_refKey     := obj_billing2.PRBILFDT || '-' || obj_billing2.CHDRNUM || '-' || obj_billing2.PRODTYP
                                   || '-' || obj_billing2.MBRNO || '-' || obj_billing2.DPNTNO;
      i_zdoe_info2.i_tableName  := v_tableName;
      i_zdoe_info2.i_scheduleno := i_scheduleNumber;
      b_isNoError2              := TRUE;
      n_errorCount2             := 0;
      t_ercode2(1)              := NULL;
      t_ercode2(2)              := NULL;
      t_ercode2(3)              := NULL;
      t_ercode2(4)              := NULL;
      t_ercode2(5)              := NULL;

      ---------------------TITDMGBILL2 Validations : Start-------------------
      -----------------Bill Not Migrated----------------
      IF (TRIM(obj_billing2.ZIGVALUE) IS NULL) THEN
        b_isNoError2                    := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'BLNM';
        t_errorfield2(n_errorCount2)    := ' ';
        t_errormsg2(n_errorCount2)      := 'Bill Not Migrated';
        t_errorfieldval2(n_errorCount2) := ' ';
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        GOTO insertzdoe2;
      END IF;

      -----------------Duplicate Record Validation----------------
--      IF (getGpmdpf.exists(obj_billing2.PRBILFDT || TRIM(obj_billing2.CHDRNUM) || TRIM(obj_billing2.PRODTYP)
--         || TRIM(obj_billing2.MBRNO) || TRIM(obj_billing2.DPNTNO))) THEN - BL1
      IF obj_billing2.GPMDPF IS NOT NULL THEN
        b_isNoError2                    := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQMA';
        t_errorfield2(n_errorCount2)    := 'CHDRNUM';
        t_errormsg2(n_errorCount2)      := o_errortext('RQMA');
        t_errorfieldval2(n_errorCount2) := obj_billing2.CHDRNUM;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        GOTO insertzdoe2;
      END IF;

-- Changes for BL5
      -----------------Duplicate Record Validation----------------
      -- Below check for the GBIDP

     -- IF (getGbidpf.exists(TRIM(obj_billing2.ZIGVALUE) || TRIM(obj_billing2.PRODTYP)) and obj_billing2.cnt_rec = 1) THEN
      IF (obj_billing2.gbid_billno is not null and obj_billing2.cnt_rec = 1) THEN
        b_isNoError3                    := FALSE;
        n_errorCount3                   := n_errorCount3 + 1;
        t_ercode3(n_errorCount3)        := 'RQMA';
        t_errorfield3(n_errorCount3)    := 'BILLNO';
        t_errormsg3(n_errorCount3)      := o_errortext('RQMA');
        t_errorfieldval3(n_errorCount3) := obj_billing2.ZIGVALUE;-- Changed for BL7
        t_errorprogram3(n_errorCount3)  := i_scheduleName;
        GOTO insertzdoe2;
      END IF;    


      ----------------Product Code Validation----------------
      IF NOT (itemexist.exists(TRIM('T9797') || TRIM(obj_billing2.PRODTYP) || 1)) THEN
        b_isNoError2                    := FALSE;
        n_errorCount2                   := n_errorCount2 + 1;
        t_ercode2(n_errorCount2)        := 'RQLU';
        t_errorfield2(n_errorCount2)    := 'PRODTYP';
        t_errormsg2(n_errorCount2)      := o_errortext('RQLU');
        t_errorfieldval2(n_errorCount2) := obj_billing2.PRODTYP;
        t_errorprogram2(n_errorCount2)  := i_scheduleName;
        IF n_errorCount2                >= 5 THEN
          GOTO insertzdoe2;
        END IF;
      END IF;
      ---------------------TITDMGBILL2 Validations : End---------------------

      ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGBILL2---
      <<insertzdoe2>>
      IF (b_isNoError2                   = FALSE) THEN
        IF TRIM(t_ercode2(1))           IS NOT NULL THEN
          i_zdoe_info2.i_indic          := C_ERROR;
          i_zdoe_info2.i_error01        := t_ercode2(1);
          i_zdoe_info2.i_errormsg01     := t_errormsg2(1);
          i_zdoe_info2.i_errorfield01   := t_errorfield2(1);
          i_zdoe_info2.i_fieldvalue01   := t_errorfieldval2(1);
          i_zdoe_info2.i_errorprogram01 := t_errorprogram2(1);
        END IF;
        IF TRIM(t_ercode2(2))           IS NOT NULL THEN
          i_zdoe_info2.i_indic          := C_ERROR;
          i_zdoe_info2.i_error02        := t_ercode2(2);
          i_zdoe_info2.i_errormsg02     := t_errormsg2(2);
          i_zdoe_info2.i_errorfield02   := t_errorfield2(2);
          i_zdoe_info2.i_fieldvalue02   := t_errorfieldval2(2);
          i_zdoe_info2.i_errorprogram02 := t_errorprogram2(2);
        END IF;
        IF TRIM(t_ercode2(3))           IS NOT NULL THEN
          i_zdoe_info2.i_indic          := C_ERROR;
          i_zdoe_info2.i_error03        := t_ercode2(3);
          i_zdoe_info2.i_errormsg03     := t_errormsg2(3);
          i_zdoe_info2.i_errorfield03   := t_errorfield2(3);
          i_zdoe_info2.i_fieldvalue03   := t_errorfieldval2(3);
          i_zdoe_info2.i_errorprogram03 := t_errorprogram2(3);
        END IF;
        IF TRIM(t_ercode2(4))           IS NOT NULL THEN
          i_zdoe_info2.i_indic          := C_ERROR;
          i_zdoe_info2.i_error04        := t_ercode2(4);
          i_zdoe_info2.i_errormsg04     := t_errormsg2(4);
          i_zdoe_info2.i_errorfield04   := t_errorfield2(4);
          i_zdoe_info2.i_fieldvalue04   := t_errorfieldval2(4);
          i_zdoe_info2.i_errorprogram04 := t_errorprogram2(4);
        END IF;
        IF TRIM(t_ercode2(5))           IS NOT NULL THEN
          i_zdoe_info2.i_indic          := C_ERROR;
          i_zdoe_info2.i_error05        := t_ercode2(5);
          i_zdoe_info2.i_errormsg05     := t_errormsg2(5);
          i_zdoe_info2.i_errorfield05   := t_errorfield2(5);
          i_zdoe_info2.i_fieldvalue05   := t_errorfieldval2(5);
          i_zdoe_info2.i_errorprogram05 := t_errorprogram2(5);
        END IF;

        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2);
        CONTINUE again_start2;
      END IF;

      IF b_isNoError2              = TRUE THEN
        i_zdoe_info2.i_indic      := C_SUCCESS;
        i_zdoe_info2.i_errormsg01 := C_RECORDSUCCESS;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2);
      END IF;

      IF b_isNoError2 = TRUE AND i_zprvaldYN = 'N' THEN

        select SEQ_GPMDPF.nextval into v_seq_gpmdpf from dual;
        --------------------IG Table GPMDPF Values------------------
        obj_VIEW_DM_GPMDPF.UNIQUE_NUMBER  := v_seq_gpmdpf;
        obj_VIEW_DM_GPMDPF.CHDRCOY        := i_company;
        obj_VIEW_DM_GPMDPF.CHDRNUM        := obj_billing2.CHDRNUM;
        obj_VIEW_DM_GPMDPF.PRODTYP        := obj_billing2.PRODTYP;
        obj_VIEW_DM_GPMDPF.HEADCNTIND     := o_defaultvalues('HEADCNTIND');
        obj_VIEW_DM_GPMDPF.MBRNO          := obj_billing2.MBRNO;
        obj_VIEW_DM_GPMDPF.DPNTNO         := obj_billing2.DPNTNO;
        obj_VIEW_DM_GPMDPF.TRANNO         := obj_billing2.TRANNO;
        obj_VIEW_DM_GPMDPF.RECNO          := o_defaultvalues('RECNO');
        obj_VIEW_DM_GPMDPF.PLANNO         := o_defaultvalues('PLANNO');
        obj_VIEW_DM_GPMDPF.SUBSCOY        := ' ';
        obj_VIEW_DM_GPMDPF.SUBSNUM        := '        ';
        obj_VIEW_DM_GPMDPF.BILLTYP        := o_defaultvalues('BILLTYP');
        obj_VIEW_DM_GPMDPF.BILLNO         := obj_billing2.ZIGVALUE;
        obj_VIEW_DM_GPMDPF.EFFDATE        := obj_billing2.PRBILFDT;
        obj_VIEW_DM_GPMDPF.PPREM          := obj_billing2.BPREM;
        obj_VIEW_DM_GPMDPF.PEMXTPRM       := '0';
        obj_VIEW_DM_GPMDPF.POAXTPRM       := '0';
        obj_VIEW_DM_GPMDPF.INSTNO         := obj_billing2.TRREFNUM;
        obj_VIEW_DM_GPMDPF.PRMFRDT        := obj_billing2.PRBILFDT;
        obj_VIEW_DM_GPMDPF.PRMTODT        := obj_billing2.PRBILTDT;
        obj_VIEW_DM_GPMDPF.PNIND          := o_defaultvalues('PNIND');
        obj_VIEW_DM_GPMDPF.MMIND          := o_defaultvalues('MMIND');
        obj_VIEW_DM_GPMDPF.SRCDATA        := o_defaultvalues('SRCDATA');
        obj_VIEW_DM_GPMDPF.BATCCOY        := i_company;
        obj_VIEW_DM_GPMDPF.BATCBRN        := i_branch;
        obj_VIEW_DM_GPMDPF.BATCACTYR      := i_acctYear;
        obj_VIEW_DM_GPMDPF.BATCACTMN      := i_acctMonth;

        if obj_billing2.TRANNO = 1 then
          obj_VIEW_DM_GPMDPF.BATCTRCD     := 'T903';
        else
          obj_VIEW_DM_GPMDPF.BATCTRCD     := 'B920';
        end if;

        obj_VIEW_DM_GPMDPF.BATCBATCH      := '     ';
        obj_VIEW_DM_GPMDPF.RECTYPE        := o_defaultvalues('RECTYPE');
        obj_VIEW_DM_GPMDPF.JOBNOUD        := '0';
        obj_VIEW_DM_GPMDPF.FLATFEE        := '0';
        obj_VIEW_DM_GPMDPF.FEES           := '0';
        obj_VIEW_DM_GPMDPF.EVNTFEE        := '0';
        obj_VIEW_DM_GPMDPF.MFJOBNO        := '0';
        obj_VIEW_DM_GPMDPF.JOBNOISS       := i_scheduleNumber;
        obj_VIEW_DM_GPMDPF.BBJOBNO        := '0';
        obj_VIEW_DM_GPMDPF.JOBNOTPA       := '0';
        obj_VIEW_DM_GPMDPF.DATIME         := CAST(sysdate AS TIMESTAMP);
        obj_VIEW_DM_GPMDPF.JOBNM          := i_scheduleName;
        obj_VIEW_DM_GPMDPF.USRPRF         := i_usrprf;

        INSERT INTO Jd1dta.VIEW_DM_GPMDPF VALUES obj_VIEW_DM_GPMDPF;
--- Changes for BL5
        if obj_billing2.cnt_rec = 1 then

                 select SEQ_GBIDPF.nextval into v_seq_gbidpf from dual;
                ---------------------IG Table GBIDPF Values-------------------
                obj_VIEW_DM_GBIDPF.UNIQUE_NUMBER  := v_seq_gbidpf;
                obj_VIEW_DM_GBIDPF.CHDRCOY        := i_company;
                obj_VIEW_DM_GBIDPF.BILLNO         := obj_billing2.ZIGVALUE;
                obj_VIEW_DM_GBIDPF.PRODTYP        := obj_billing2.PRODTYP;
                obj_VIEW_DM_GBIDPF.PLANNO         := o_defaultvalues('PLANNO');
                obj_VIEW_DM_GBIDPF.CLASSINS       := '  ';
                obj_VIEW_DM_GBIDPF.BPREM          := obj_billing2.GBID_PREM;-- Changed for BL8
                obj_VIEW_DM_GBIDPF.BEXTPRM        := '0';
                obj_VIEW_DM_GBIDPF.BCOMM          := '0';
                obj_VIEW_DM_GBIDPF.BOVCOMM01      := '0';
                obj_VIEW_DM_GBIDPF.BOVCOMM02      := '0';
                obj_VIEW_DM_GBIDPF.DISCRATE       := '0';       
                obj_VIEW_DM_GBIDPF.DISCAMT        := '0';
                obj_VIEW_DM_GBIDPF.BATCCOY        := i_company;
                obj_VIEW_DM_GBIDPF.BATCBRN        := i_branch;
                obj_VIEW_DM_GBIDPF.BATCACTYR      := i_acctYear;
                obj_VIEW_DM_GBIDPF.BATCACTMN      := i_acctMonth;

                if obj_billing2.TRANNO = 1 then-- Changed for BL7
                  obj_VIEW_DM_GBIDPF.BATCTRCDE    := 'T903';
                else
                  obj_VIEW_DM_GBIDPF.BATCTRCDE    := 'B920';
      END IF;    

                obj_VIEW_DM_GBIDPF.BATCBATCH      := '     ';
                obj_VIEW_DM_GBIDPF.TERMID         := i_vrcmTermid;
                obj_VIEW_DM_GBIDPF.TRDT           := n_trdt;
                obj_VIEW_DM_GBIDPF.TRTM           := i_vrcmtime;
                obj_VIEW_DM_GBIDPF.TRANNO         := obj_billing2.TRANNO;-- Changed for BL7
                obj_VIEW_DM_GBIDPF.FEES           := '0';
                obj_VIEW_DM_GBIDPF.VALIDFLAG      := o_defaultvalues('VALIDFLAG');
                obj_VIEW_DM_GBIDPF.WKLADM         := '0';
                obj_VIEW_DM_GBIDPF.DISCAMT1       := '0';
                obj_VIEW_DM_GBIDPF.DISCAMT2       := '0';
                obj_VIEW_DM_GBIDPF.DISCRATE1      := '0';
                obj_VIEW_DM_GBIDPF.DISCRATE2      := '0';
                obj_VIEW_DM_GBIDPF.RIBFEE         := '0';
                obj_VIEW_DM_GBIDPF.RIBFGST        := '0';
                obj_VIEW_DM_GBIDPF.USER_T         := i_user_t;
                obj_VIEW_DM_GBIDPF.ZCTAXAMT01     := '0';
                obj_VIEW_DM_GBIDPF.ZCTAXAMT02     := '0';
                obj_VIEW_DM_GBIDPF.ZCTAXAMT03     := '0';
                obj_VIEW_DM_GBIDPF.BADVRFUND      := 0;
                obj_VIEW_DM_GBIDPF.DATIME         := CAST(sysdate AS TIMESTAMP);
                obj_VIEW_DM_GBIDPF.JOBNM          := i_scheduleName;
                obj_VIEW_DM_GBIDPF.USRPRF         := i_usrprf;

              --   INSERT INTO Jd1dta.VIEW_DM_GBIDPF VALUES obj_VIEW_DM_GBIDPF;
                INSERT INTO Jd1dta.VIEW_DM_GBIDPF VALUES obj_VIEW_DM_GBIDPF;

         end if;

      END IF;  

      if cntr >= v_commit_limit then
        commit;
        v_commit_limit := v_commit_limit + v_commit_interval;
      end if;


    END LOOP;

    EXIT WHEN c_billing2%notfound;            
  END LOOP;



  CLOSE c_billing2;
  commit;-- ZJNPG-9739
  ---------------------------OPEN TITDMGBILL2 FOR GBIDPF-----------------------
--  Changes to comment below code for BL5
/*
  OPEN c_billing3;

  LOOP
    FETCH c_billing3 BULK COLLECT 
    INTO billing3_list LIMIT C_limit;

    <<again_start3>>
    for i in 1 .. billing3_list.count loop

      obj_billing3 := billing3_list(i);

      i_zdoe_info3              := NULL;
      i_zdoe_info3.i_zfilename  := 'TITDMGBILL2';
      i_zdoe_info3.i_refKey     := obj_billing3.ZIGVALUE || '-' || obj_billing3.CHDRNUM || '-' || obj_billing3.PRODTYP;
      i_zdoe_info3.i_tableName  := v_tableName;
      i_zdoe_info3.i_scheduleno := i_scheduleNumber;
      b_isNoError3              := TRUE;
      n_errorCount3             := 0;
      t_ercode3(1)              := NULL;
      t_ercode3(2)              := NULL;
      t_ercode3(3)              := NULL;
      t_ercode3(4)              := NULL;
      t_ercode3(5)              := NULL;

      ---------------------TITDMGBILL2 Validations : Start-------------------
      -----------------Bill Not Migrated----------------
      IF (TRIM(obj_billing3.ZIGVALUE) IS NULL) THEN
        b_isNoError3                    := FALSE;
        n_errorCount3                   := n_errorCount3 + 1;
        t_ercode3(n_errorCount3)        := 'BLNM';
        t_errorfield3(n_errorCount3)    := ' ';
        t_errormsg3(n_errorCount3)      := 'Bill Not Migrated - GBIDPF';
        t_errorfieldval3(n_errorCount3) := ' ';
        t_errorprogram3(n_errorCount3)  := i_scheduleName;
        GOTO insertzdoe3;
      END IF;

      -----------------Duplicate Record Validation----------------
      IF (getGbidpf.exists(TRIM(obj_billing3.ZIGVALUE) || TRIM(obj_billing3.PRODTYP))) THEN
        b_isNoError3                    := FALSE;
        n_errorCount3                   := n_errorCount3 + 1;
        t_ercode3(n_errorCount3)        := 'RQMA';
        t_errorfield3(n_errorCount3)    := 'BILLNO';
        t_errormsg3(n_errorCount3)      := o_errortext('RQMA');
        t_errorfieldval3(n_errorCount3) := obj_billing3.ZIGVALUE;
        t_errorprogram3(n_errorCount3)  := i_scheduleName;
        GOTO insertzdoe3;
      END IF;      
      ---------------------TITDMGBILL2 Validations : End---------------------

      ----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGBILL2---
      <<insertzdoe3>>
      IF (b_isNoError3                   = FALSE) THEN
        IF TRIM(t_ercode3(1))           IS NOT NULL THEN
          i_zdoe_info3.i_indic          := C_ERROR;
          i_zdoe_info3.i_error01        := t_ercode3(1);
          i_zdoe_info3.i_errormsg01     := t_errormsg3(1);
          i_zdoe_info3.i_errorfield01   := t_errorfield3(1);
          i_zdoe_info3.i_fieldvalue01   := t_errorfieldval3(1);
          i_zdoe_info3.i_errorprogram01 := t_errorprogram3(1);
        END IF;
        IF TRIM(t_ercode3(2))           IS NOT NULL THEN
          i_zdoe_info3.i_indic          := C_ERROR;
          i_zdoe_info3.i_error02        := t_ercode3(2);
          i_zdoe_info3.i_errormsg02     := t_errormsg3(2);
          i_zdoe_info3.i_errorfield02   := t_errorfield3(2);
          i_zdoe_info3.i_fieldvalue02   := t_errorfieldval3(2);
          i_zdoe_info3.i_errorprogram02 := t_errorprogram3(2);
        END IF;
        IF TRIM(t_ercode3(3))           IS NOT NULL THEN
          i_zdoe_info3.i_indic          := C_ERROR;
          i_zdoe_info3.i_error03        := t_ercode3(3);
          i_zdoe_info3.i_errormsg03     := t_errormsg3(3);
          i_zdoe_info3.i_errorfield03   := t_errorfield3(3);
          i_zdoe_info3.i_fieldvalue03   := t_errorfieldval3(3);
          i_zdoe_info3.i_errorprogram03 := t_errorprogram3(3);
        END IF;
        IF TRIM(t_ercode3(4))           IS NOT NULL THEN
          i_zdoe_info3.i_indic          := C_ERROR;
          i_zdoe_info3.i_error04        := t_ercode3(4);
          i_zdoe_info3.i_errormsg04     := t_errormsg3(4);
          i_zdoe_info3.i_errorfield04   := t_errorfield3(4);
          i_zdoe_info3.i_fieldvalue04   := t_errorfieldval3(4);
          i_zdoe_info3.i_errorprogram04 := t_errorprogram3(4);
        END IF;
        IF TRIM(t_ercode3(5))           IS NOT NULL THEN
          i_zdoe_info3.i_indic          := C_ERROR;
          i_zdoe_info3.i_error05        := t_ercode3(5);
          i_zdoe_info3.i_errormsg05     := t_errormsg3(5);
          i_zdoe_info3.i_errorfield05   := t_errorfield3(5);
          i_zdoe_info3.i_fieldvalue05   := t_errorfieldval3(5);
          i_zdoe_info3.i_errorprogram05 := t_errorprogram3(5);
        END IF;

        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info3);
        CONTINUE again_start3;
      END IF;

      IF b_isNoError3              = TRUE THEN
        i_zdoe_info3.i_indic      := C_SUCCESS;
        i_zdoe_info3.i_errormsg01 := C_RECORDSUCCESS;
        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info3);
      END IF;

      IF b_isNoError3 = TRUE AND i_zprvaldYN = 'N' THEN

        select SEQ_GBIDPF.nextval into v_seq_gbidpf from dual;
        ---------------------IG Table GBIDPF Values-------------------
        obj_VIEW_DM_GBIDPF.UNIQUE_NUMBER  := v_seq_gbidpf;
        obj_VIEW_DM_GBIDPF.CHDRCOY        := i_company;
        obj_VIEW_DM_GBIDPF.BILLNO         := obj_billing3.ZIGVALUE;
        obj_VIEW_DM_GBIDPF.PRODTYP        := obj_billing3.PRODTYP;
        obj_VIEW_DM_GBIDPF.PLANNO         := o_defaultvalues('PLANNO');
        obj_VIEW_DM_GBIDPF.CLASSINS       := '  ';
        obj_VIEW_DM_GBIDPF.BPREM          := obj_billing3.BPREM;
        obj_VIEW_DM_GBIDPF.BEXTPRM        := '0';
        obj_VIEW_DM_GBIDPF.BCOMM          := '0';
        obj_VIEW_DM_GBIDPF.BOVCOMM01      := '0';
        obj_VIEW_DM_GBIDPF.BOVCOMM02      := '0';
        obj_VIEW_DM_GBIDPF.DISCRATE       := '0';
        obj_VIEW_DM_GBIDPF.DISCAMT        := '0';
        obj_VIEW_DM_GBIDPF.BATCCOY        := i_company;
        obj_VIEW_DM_GBIDPF.BATCBRN        := i_branch;
        obj_VIEW_DM_GBIDPF.BATCACTYR      := i_acctYear;
        obj_VIEW_DM_GBIDPF.BATCACTMN      := i_acctMonth;

        if obj_billing3.TRANNO = 1 then
          obj_VIEW_DM_GBIDPF.BATCTRCDE    := 'T903';
        else
          obj_VIEW_DM_GBIDPF.BATCTRCDE    := 'B920';
        end if;

        obj_VIEW_DM_GBIDPF.BATCBATCH      := '     ';
        obj_VIEW_DM_GBIDPF.TERMID         := i_vrcmTermid;
        obj_VIEW_DM_GBIDPF.TRDT           := n_trdt;
        obj_VIEW_DM_GBIDPF.TRTM           := i_vrcmtime;
        obj_VIEW_DM_GBIDPF.TRANNO         := obj_billing3.TRANNO;
        obj_VIEW_DM_GBIDPF.FEES           := '0';
        obj_VIEW_DM_GBIDPF.VALIDFLAG      := o_defaultvalues('VALIDFLAG');
        obj_VIEW_DM_GBIDPF.WKLADM         := '0';
        obj_VIEW_DM_GBIDPF.DISCAMT1       := '0';
        obj_VIEW_DM_GBIDPF.DISCAMT2       := '0';
        obj_VIEW_DM_GBIDPF.DISCRATE1      := '0';
        obj_VIEW_DM_GBIDPF.DISCRATE2      := '0';
        obj_VIEW_DM_GBIDPF.RIBFEE         := '0';
        obj_VIEW_DM_GBIDPF.RIBFGST        := '0';
        obj_VIEW_DM_GBIDPF.USER_T         := i_user_t;
        obj_VIEW_DM_GBIDPF.ZCTAXAMT01     := '0';
        obj_VIEW_DM_GBIDPF.ZCTAXAMT02     := '0';
        obj_VIEW_DM_GBIDPF.ZCTAXAMT03     := '0';
        obj_VIEW_DM_GBIDPF.BADVRFUND      := 0;
        obj_VIEW_DM_GBIDPF.DATIME         := CAST(sysdate AS TIMESTAMP);
        obj_VIEW_DM_GBIDPF.JOBNM          := i_scheduleName;
        obj_VIEW_DM_GBIDPF.USRPRF         := i_usrprf;

        INSERT INTO Jd1dta.VIEW_DM_GBIDPF VALUES obj_VIEW_DM_GBIDPF;

      END IF;
    END LOOP;

    EXIT WHEN c_billing3%notfound;        
  END LOOP;

  CLOSE c_billing3;
  
    commit;
*/
end if;

  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

  dbms_output.put_line('End execution of BQ9TK_BL01_BILLHIST, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  exception
    WHEN OTHERS THEN
      ROLLBACK;

      dbms_output.put_line('error:'||sqlerrm);  
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9TK_BL01_BILLHIST : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

      insert into Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      values
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      commit;
      raise;

END BQ9TK_BL01_BILLHIST;