CREATE OR REPLACE EDITIONABLE PACKAGE "Jd1dta"."PKG_COMMON_DMBL" 
AS
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMBL
  * Author           : Bhupendra Singh
  * Creation Date    : December 17, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  * Date    	Initials   Tag   Description
  * -----   	--------   ---   ---------------------------------------------------------------------------
  * Feb28/22  	 KLP       BL01  ZJNPG-10449, Changed the new altearation code as per the new alteration code mapping
  **************************************************************************************************************************/
  -- Get  trano Start--
TYPE trano
IS
  TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(60);
  PROCEDURE getTranNo(
      i_company_Name IN VARCHAR2,
      getTranno OUT trano);
  -- Get  trano End--
  -----------Get Policy:START--------
TYPE gchdtype
IS
  TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
  PROCEDURE checkpolicy(
      i_company IN VARCHAR2,
      checkchdrnum OUT gchdtype);
  -----------Get Policy:END--------
  -----------Get Duplicate Check. for zdrfpftype--------
TYPE zdrfpftype
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE checkduplicate(
      checkduplicate OUT zdrfpftype);
  -----------Get Duplicate:END--------
  -----------Get Duplicate Check for titdmgref2.--------
TYPE titdmgref2
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE checkduplicateIntitdmgref2(
      checkduplicateIntitdmgref2 OUT titdmgref2);
  -----------Get Duplicate:END--------
  -----------Get checkagent Check Agent.--------
TYPE agntpftype
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE checkagent(
      checkagent OUT agntpftype);
  -----------Get Agent:END--------
  -----------Get Duplicate Check. for zreppftype--------
TYPE zreppftype
IS
  TABLE OF VARCHAR2(70) INDEX BY VARCHAR2(70);
  PROCEDURE checkduplicateInzreppf(
      checkduplicateInzreppf OUT zreppftype);
  -----------Get Duplicate:END--------
  -----------Get getGagntsel--------
TYPE zagppftype
IS
  TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(500);
  PROCEDURE getGagntsel(
      getGagntsel OUT zagppftype);
  -----------getGagntsel:END--------
  -----------Get getZagptnum--------
TYPE typegchipf
IS
  TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(20);
  PROCEDURE getZagptnum(
      getZagptnum OUT typegchipf);
  -----------getZagptnum:END--------
  -----------Get getZagptnum--------
TYPE typezcpnpf
IS
  TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(20);
  PROCEDURE getZagptid(
      getZagptid OUT typezcpnpf);
  -----------getZagptnum:END--------
    -----------Get Dishonor from GCHPPF:START--------
/*  TYPE gchptype IS TABLE OF GCHPPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getgchppf(getgchppf OUT gchptype); */

   TYPE OBJ_GCHP IS RECORD(
    chdrnum GCHPPF.chdrnum%type,
    chdrcoy GCHPPF.chdrcoy%type,
    zendcde GCHPPF.zendcde%type);

  TYPE gchptype IS TABLE OF OBJ_GCHP INDEX BY VARCHAR2(29);
  PROCEDURE getgchppf(getgchppf OUT gchptype);
  -----------Get Dishonor from GCHPPF:END--------
  -----------File 2 Record Exists Billing Start------
TYPE titdmgbill
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE file2exists(
      file2exists OUT titdmgbill);
  -----------File 2 Record Exists Billing End--------
  -----------Validate BankACC:START--------
TYPE bankacc
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE validatebankacc(
      validatebankacc OUT bankacc);
  -----------Validate BankACC:END--------
  -----------ZAGPPF Changes Start--------
TYPE newzagppf
IS
  TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(500);
  PROCEDURE getZagppf(
      getZagppf OUT newzagppf);
  -----------ZAGPPF Changes End--------
  -----------Billing History Duplicate Start--------
TYPE duplicateZdrbpf
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getZdrbpf(
      getZdrbpf OUT duplicateZdrbpf);
  -----------Billing History Duplicate End--------
  -----------GPMDPF Duplicate Start--------
TYPE duplicateGpmdpf
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getGpmdpf(
      getGpmdpf OUT duplicateGpmdpf);
  -----------GPMDPF Duplicate End--------
  -----------GBIDPF Duplicate Start--------
TYPE duplicateGbidpf
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getGbidpf(
      getGbidpf OUT duplicateGbidpf);
  -----------GBIDPF Duplicate End--------
  -----------Stop bill for T-Cancellation Start--------
TYPE existZtrapf
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getZtrapf(
      getZtrapf OUT existZtrapf);
  -----------Stop bill for T-Cancellation End--------
  -----------Collection Result Duplicate Start--------
TYPE duplicatePazdcrpf
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getPaZdcrpf(
      getPaZdcrpf OUT duplicatePazdcrpf);
  -----------Collection Result Duplicate End--------
  -----------Get IG Bill Number START --------------
  TYPE billnomap IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE getbillno(getbillno OUT billnomap);                    
    -----------Get IG Bill Number END ---------------
    ----------- ZAGPTNUM Start ------------
  TYPE newgchipf
IS
  TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(500);
  PROCEDURE getZagptnum(
      getZagptnum OUT newgchipf);
  ----------- ZAGPTNUM End ------------
  -----------BILL1 Records START--------
  TYPE OBJ_BILL1_TYPE IS RECORD(

    chdrnum  TITDMGBILL1.CHDRNUM@DMSTAGEDBLINK%type,
    TRREFNUM TITDMGBILL1.TRREFNUM@DMSTAGEDBLINK%type,
    prbilfdt TITDMGBILL1.PRBILFDT@DMSTAGEDBLINK%type,
    prbiltdt TITDMGBILL1.PRBILTDT@DMSTAGEDBLINK%type);

  TYPE BILL1TYPE IS TABLE OF OBJ_BILL1_TYPE INDEX BY VARCHAR2(30);
  PROCEDURE getbill1info(BILL1INFO OUT BILL1TYPE);
  -----------BILL1 Records END-------- 
   -----------Get P1 records   :START--------
  TYPE OBJ_REFBILL_TYPE IS RECORD(

    chdrnum  TITDMGREF1.CHDRNUM@DMSTAGEDBLINK%type,
    refnum   TITDMGREF1.REFNUM@DMSTAGEDBLINK%type,
    zrefmtcd TITDMGREF1.ZREFMTCD@DMSTAGEDBLINK%type,
    effdate  TITDMGREF1.EFFDATE@DMSTAGEDBLINK%type,
    prbilfdt TITDMGREF1.PRBILFDT@DMSTAGEDBLINK%type,
    prbiltdt TITDMGREF1.PRBILTDT@DMSTAGEDBLINK%type);

  TYPE REFBILLTYPE IS TABLE OF OBJ_REFBILL_TYPE INDEX BY VARCHAR2(50);
  PROCEDURE getrefundbillinfo(REFBILINFO OUT REFBILLTYPE);
  -----------Get P1 records  :END-------- 

  -----------Get Endorser Type  :Start--------
  TYPE OBJ_ZENDRPF IS RECORD(
    zendcde ZENDRPF.ZENDCDE%type,
    zcolm   ZENDRPF.ZCOLM%type);

  TYPE zendrpftype IS TABLE OF OBJ_ZENDRPF INDEX BY VARCHAR2(29);
  PROCEDURE getendrtype(getendrtype OUT zendrpftype);
  -----------Get Endorser Type  :End----------
END PKG_COMMON_DMBL;

/

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "Jd1dta"."PKG_COMMON_DMBL" 
AS
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMBL
  * Author           : Bhupendra Singh
  * Creation Date    : December 17, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  **************************************************************************************************************************/
  -- Get  trano Start--
  PROCEDURE getTranNo(
      i_company_Name IN VARCHAR2,
      getTranno OUT trano)
  IS
    indextrano PLS_INTEGER;
  TYPE obj_trano
IS
  RECORD
  (
    i_chdrnum gchd.CHDRNUM%type,
    i_trano GCHD.TRANLUSED%type,
    i_ptdate GCHD.PTDATE%type,
    i_cownnum GCHD.COWNNUM%type,
    i_company_Name GCHD.CHDRCOY%type);
TYPE v_array
IS
  TABLE OF obj_trano;
  itemlist v_array;
BEGIN
  SELECT CHDRNUM,
    TRANLUSED,
    PTDATE,
    COWNNUM,
    CHDRCOY BULK COLLECT
  INTO itemlist
  FROM Jd1dta.GCHD
  WHERE TRIM(CHDRCOY) = TRIM(i_company_Name);
  FOR indextrano IN itemlist.first .. itemlist.last
  LOOP
    getTranno(TRIM(itemlist(indextrano).i_company_Name) || TRIM(itemlist(indextrano).i_chdrnum)) := ((itemlist(indextrano) .i_cownnum) || '$' || (itemlist(indextrano) .i_ptdate) || '$' || (itemlist(indextrano) .i_trano));
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
 getTranno(' ') := TRIM(' ');
END;
-----------Get Policy:START--------
PROCEDURE checkpolicy(
    i_company IN VARCHAR2,
    checkchdrnum OUT gchdtype)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum gchd.CHDRNUM%type,
    i_company gchd.CHDRCOY%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    CHDRCOY BULK COLLECT
  INTO itempflist
  FROM Jd1dta.GCHD
  WHERE TRIM(CHDRCOY) IN (1, 9);
  FOR indexitems      IN itempflist.first .. itempflist.last
  LOOP
    checkchdrnum(TRIM(itempflist(indexitems).i_chdrnum)) := TRIM(itempflist(indexitems) .i_chdrnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  checkchdrnum(' ') := TRIM(' ');
END;
-----------Get Policy:END--------
-----------Get Duplicate:START--------
PROCEDURE checkduplicate(
    checkduplicate OUT zdrfpftype)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum PAZDRFPF.CHDRNUM%type,
    --    i_company gchd.CHDRNUM%type,
    i_zrefmtcd PAZDRFPF.ZREFMTCD%type,
    i_zentity PAZDRFPF.ZENTITY%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM, ZREFMTCD, ZENTITY BULK COLLECT INTO itempflist FROM Jd1dta.PAZDRFPF;
  --  where
  --  TRIM(CHDRCOY) = TRIM(i_company);
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    checkduplicate(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_zrefmtcd) || TRIM(itempflist(indexitems).i_zentity)) := TRIM(itempflist(indexitems) .i_chdrnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  checkduplicate(' ') := TRIM(' ');
END;
-----------Get Duplicate:END--------
-----------Get Duplicate:START--------
PROCEDURE checkduplicateIntitdmgref2(
    checkduplicateIntitdmgref2 OUT titdmgref2)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum TITDMGREF2.CHDRNUM@DMSTAGEDBLINK%type,
    --    i_company gchd.CHDRNUM%type,
      i_zrefmtcd TITDMGREF2.ZREFMTCD@DMSTAGEDBLINK%type,
     i_trrefnum TITDMGREF2.TRREFNUM@DMSTAGEDBLINK%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    ZREFMTCD,
    TRREFNUM BULK COLLECT
  INTO itempflist
  FROM TITDMGREF2@DMSTAGEDBLINK;
  --  where
  --  TRIM(CHDRCOY) = TRIM(i_company);
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    checkduplicateIntitdmgref2(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_zrefmtcd) || TRIM(itempflist(indexitems).i_trrefnum)) := TRIM(itempflist(indexitems) .i_chdrnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  checkduplicateIntitdmgref2(' ') := TRIM(' ');
END;
-----------Get Duplicate:END--------
-----------Get checkagent Check Agent.--------
PROCEDURE checkagent(
    checkagent OUT agntpftype)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_agntnum Jd1dta.AGNTPF.AGNTNUM%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT AGNTNUM BULK COLLECT INTO itempflist FROM Jd1dta.AGNTPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    checkagent(TRIM(itempflist(indexitems).i_agntnum)) := TRIM(itempflist(indexitems) .i_agntnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  checkagent(' ') := TRIM(' ');
END;
-----------Get Agent:END--------
-----------Get checkduplicateInzreppf.--------
PROCEDURE checkduplicateInzreppf(
    checkduplicateInzreppf OUT zreppftype)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum ZREPPF.CHDRNUM%type,
    i_zrefundam ZREPPF.ZREFUNDAM%type,
    i_zrefmtcd ZREPPF.ZREFMTCD%type,
    i_zrefundbe ZREPPF.ZREFUNDBE%type,
    i_zrefundbz ZREPPF.ZREFUNDBZ%type,
    i_zenrfdst ZREPPF.ZENRFDST%type,
    i_zzhrfdst ZREPPF.ZZHRFDST%type,
    i_zrfdst ZREPPF.ZRFDST%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    ZREFUNDAM,
    ZREFMTCD,
    ZREFUNDBE,
    ZREFUNDBZ,
    ZENRFDST,
    ZZHRFDST,
    ZRFDST BULK COLLECT
  INTO itempflist
  FROM Jd1dta.ZREPPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    checkduplicateInzreppf(TRIM(itempflist(indexitems).i_chdrnum)) := (itempflist(indexitems) .i_zrefundam || '$' || itempflist(indexitems) .i_zrefmtcd || '$' || itempflist(indexitems) .i_zrefundbe || '$' || itempflist(indexitems) .i_zrefundbz || '$' || itempflist(indexitems) .i_zenrfdst || '$' || itempflist(indexitems) .i_zzhrfdst || '$' || itempflist(indexitems) .i_zrfdst);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  checkduplicateInzreppf(' ') := TRIM(' ');
END;
-----------Get checkduplicateInzreppf. END--------
-----------Get getGagntsel. --------
PROCEDURE getGagntsel(
    getGagntsel OUT zagppftype)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_zagptnum ZAGPPF.ZAGPTNUM%type,
    i_gagntsel01 ZAGPPF.GAGNTSEL01%type,
    i_gagntsel02 ZAGPPF.GAGNTSEL02%type,
    i_gagntsel03 ZAGPPF.GAGNTSEL03%type,
    i_gagntsel04 ZAGPPF.GAGNTSEL04%type,
    i_gagntsel05 ZAGPPF.GAGNTSEL05%type,
    i_splitc01 ZAGPPF.SPLITC01%type,
    i_splitc02 ZAGPPF.SPLITC02%type,
    i_splitc03 ZAGPPF.SPLITC03%type,
    i_splitc04 ZAGPPF.SPLITC04%type,
    i_splitc05 ZAGPPF.SPLITC05%type,
     i_zcolrate   ZAGPPF.Zcolrate%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT ZAGPTNUM,
    GAGNTSEL01,
    GAGNTSEL02,
    GAGNTSEL03,
    GAGNTSEL04,
    GAGNTSEL05,
    SPLITC01,
    SPLITC02,
    SPLITC03,
    SPLITC04,
    SPLITC05,zcolrate BULK COLLECT
  INTO itempflist
  FROM Jd1dta.ZAGPPF
  WHERE TRIM(ZAGPTCOY) IN (1, 9);
  FOR indexitems       IN itempflist.first .. itempflist.last
  LOOP
    getGagntsel(TRIM(itempflist(indexitems).i_zagptnum)) := (itempflist(indexitems) .i_gagntsel01 || '$' || itempflist(indexitems) .i_gagntsel02 || '$' || itempflist(indexitems) .i_gagntsel03 || '$' || itempflist(indexitems) .i_gagntsel04 || '$' || itempflist(indexitems) .i_gagntsel05 || '$' || itempflist(indexitems) .i_splitc01 || '$' || itempflist(indexitems) .i_splitc02 || '$' || itempflist(indexitems) .i_splitc04 || '$' || itempflist(indexitems) .i_splitc04 || '$' || itempflist(indexitems) .i_splitc05|| '$' || itempflist(indexitems)
                                                              .i_zcolrate);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getGagntsel(' ') := TRIM(' ');
END;
-----------Get getGagntsel. END --------
-----------Get getZagptnum. --------
PROCEDURE getZagptnum(
    getZagptnum OUT typegchipf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum GCHIPF.CHDRNUM%type,
    i_effdate GCHIPF.EFFDATE%type,
    i_zagptnum GCHIPF.ZAGPTNUM%type,
    i_zcmpcode GCHIPF.ZCMPCODE%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    EFFDATE,
    ZAGPTNUM,
    ZCMPCODE BULK COLLECT
  INTO itempflist
  FROM Jd1dta.GCHIPF
  ORDER BY EFFDATE DESC;
  --    (SELECT CHDRNUM,
  --      EFFDATE,
  --      ZAGPTNUM,
  --      ZCMPCODE
  --    FROM GCHIPF
  --      --   WHERE TRIM(EFFDATE) <= TRIM(v_effdate) --20170701 <= 99999999
  --      --   AND TRIM(CHDRNUM)    = TRIM(v_chdrnum1)
  --    ORDER BY EFFDATE DESC;
  --    )
  -- -- WHERE rownum = 1;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getZagptnum(TRIM(itempflist(indexitems).i_chdrnum)) := (itempflist(indexitems) .i_effdate || '$' || itempflist(indexitems) .i_zagptnum || '$' || itempflist(indexitems) .i_zcmpcode);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getZagptnum(' ') := TRIM(' ');
END;
-----------Get getZagptnum. END --------
-----------Get getZagptnum. --------
PROCEDURE getZagptid(
    getZagptid OUT typezcpnpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_zcmpcod ZCPNPF.ZCMPCODE%type,
    i_zagptid ZCPNPF.ZAGPTID%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT ZCMPCODE, ZAGPTID BULK COLLECT INTO itempflist FROM Jd1dta.ZCPNPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getZagptid(TRIM(itempflist(indexitems).i_zcmpcod)) := (itempflist(indexitems) .i_zagptid);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getZagptid(' ') := TRIM(' ');
END;
-----------Get getZagptnum. END --------
  -----------Get DISHONOR from GCHPPF:START--------
    PROCEDURE getgchppf(getgchppf OUT gchptype) is
    CURSOR gchppflist IS
      SELECT chdrnum, chdrcoy, zendcde GCHPPF
        FROM Jd1dta.GCHPPF
       WHERE TRIM(CHDRCOY) IN (1, 9);
    obj_gchp gchppflist%rowtype;

  BEGIN
    OPEN gchppflist;
    <<skipRecord>>
    LOOP
      FETCH gchppflist
        INTO obj_gchp;
      EXIT WHEN gchppflist%notfound;
      getgchppf(TRIM(obj_gchp.chdrnum) || TRIM(obj_gchp.chdrcoy)) := obj_gchp;
    END LOOP;

    CLOSE gchppflist;

  END;
  /*
  PROCEDURE getgchppf(getgchppf OUT gchptype) is
    CURSOR gchppflist IS
      SELECT * FROM GCHPPF WHERE TRIM(CHDRCOY) IN (1, 9);
    obj_gchp gchppflist%rowtype;

  BEGIN
    OPEN gchppflist;
    <<skipRecord>>
    LOOP
      FETCH gchppflist
        INTO obj_gchp;
      EXIT WHEN gchppflist%notfound;
      getgchppf(TRIM(obj_gchp.chdrnum) || TRIM(obj_gchp.chdrcoy)) := obj_gchp;
    END LOOP;

    CLOSE gchppflist;

  END; */
  -----------Get DISHONOR from GCHPPF:END--------
  -----------File 2 Record Exists Billing Start-----
PROCEDURE file2exists(
    file2exists OUT titdmgbill)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_chdrnum TITDMGBILL2.CHDRNUM@DMSTAGEDBLINK%type,
      i_trrefnum TITDMGBILL2.TRREFNUM@DMSTAGEDBLINK%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    TRREFNUM BULK COLLECT
  INTO itempflist
  FROM TITDMGBILL2@DMSTAGEDBLINK;
  --  where
  --  TRIM(CHDRCOY) = TRIM(i_company);
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    file2exists(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_trrefnum)) := TRIM(itempflist(indexitems) .i_chdrnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  file2exists(' ') := TRIM(' ');
END;
-----------File 2 Record Exists Billing END-----
------------- Validate BankACC:START-----------------
  PROCEDURE validatebankacc(
      validatebankacc OUT bankacc) 
      IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    bank_acc CLBAPF.BANKACCKEY%type );
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  BEGIN
  SELECT TRIM(BANKACCKEY) BULK COLLECT INTO itempflist FROM Jd1dta.CLBAPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    validatebankacc(TRIM(itempflist(indexitems).bank_acc)) := TRIM(itempflist(indexitems).bank_acc);
  END LOOP;
  END validatebankacc;
---------------- Validate BankACC:END ------------------------
-----------ZAGPPF Changes Start--------
PROCEDURE getZagppf(
    getZagppf OUT newzagppf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_zagptnum ZAGPPF.ZAGPTNUM%type,
    i_gagntsel01 ZAGPPF.GAGNTSEL01%type,
    i_gagntsel02 ZAGPPF.GAGNTSEL02%type,
    i_gagntsel03 ZAGPPF.GAGNTSEL03%type,
    i_gagntsel04 ZAGPPF.GAGNTSEL04%type,
    i_gagntsel05 ZAGPPF.GAGNTSEL05%type,
    i_splitc01 ZAGPPF.SPLITC01%type,
    i_splitc02 ZAGPPF.SPLITC02%type,
    i_splitc03 ZAGPPF.SPLITC03%type,
    i_splitc04 ZAGPPF.SPLITC04%type,
    i_splitc05 ZAGPPF.SPLITC05%type,
    i_zcolrate ZAGPPF.ZCOLRATE%type);    -- BL3
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT ZAGPTNUM,
    GAGNTSEL01,
    GAGNTSEL02,
    GAGNTSEL03,
    GAGNTSEL04,
    GAGNTSEL05,
    SPLITC01,
    SPLITC02,
    SPLITC03,
    SPLITC04,
    SPLITC05,
    ZCOLRATE BULK COLLECT   -- BL3
  INTO itempflist
  FROM Jd1dta.ZAGPPF
  WHERE TRIM(ZAGPTCOY) IN (1, 9);
  FOR indexitems       IN itempflist.first .. itempflist.last
  LOOP
    getZagppf(TRIM(itempflist(indexitems).i_zagptnum)) := (itempflist(indexitems) .i_gagntsel01 || '$' || itempflist(indexitems) .i_gagntsel02 || '$' || itempflist(indexitems) .i_gagntsel03 || '$' || itempflist(indexitems) .i_gagntsel04 || '$' || itempflist(indexitems) .i_gagntsel05 || '$' || itempflist(indexitems) .i_splitc01 || '$' || itempflist(indexitems) .i_splitc02 || '$' || itempflist(indexitems) .i_splitc04 || '$' || itempflist(indexitems) .i_splitc04 || '$' || itempflist(indexitems) .i_splitc05 || '$' || itempflist(indexitems) .i_zcolrate);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getZagppf(' ') := TRIM(' ');
END;
-----------ZAGPPF Changes End--------

-----------Billing History Duplicate Start--------
PROCEDURE getZdrbpf(
    getZdrbpf OUT duplicateZdrbpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_prbilfdt 	Jd1dta.PAZDRBPF.PRBILFDT%type,
      i_chdrnum 	Jd1dta.PAZDRBPF.CHDRNUM%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  
BEGIN
  SELECT PRBILFDT, CHDRNUM 
  BULK COLLECT INTO itempflist
  FROM Jd1dta.PAZDRBPF;
  --  where
  --  TRIM(CHDRCOY) = TRIM(i_company);
  
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getZdrbpf( TRIM(itempflist(indexitems).i_prbilfdt) || TRIM(itempflist(indexitems).i_chdrnum) ) := TRIM(itempflist(indexitems).i_chdrnum);
  END LOOP;
  
EXCEPTION
WHEN OTHERS THEN
  getZdrbpf(' ') := TRIM(' ');
END;
-----------Billing History Duplicate End--------

-----------GPMDPF Duplicate Start--------
PROCEDURE getGpmdpf(
    getGpmdpf OUT duplicateGpmdpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_prmfrdt 	Jd1dta.GPMDPF.PRMFRDT%type,
      i_chdrnum 	Jd1dta.GPMDPF.CHDRNUM%type,
      i_prodtyp 	Jd1dta.GPMDPF.PRODTYP%type,
      i_mbrno 		Jd1dta.GPMDPF.MBRNO%type,
      i_dpntno 		Jd1dta.GPMDPF.DPNTNO%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  
BEGIN
  SELECT PRMFRDT, CHDRNUM, PRODTYP, MBRNO, DPNTNO
  BULK COLLECT INTO itempflist
  FROM Jd1dta.GPMDPF;
  
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getGpmdpf( TRIM(itempflist(indexitems).i_prmfrdt) || TRIM(itempflist(indexitems).i_chdrnum)
    || TRIM(itempflist(indexitems).i_prodtyp) || TRIM(itempflist(indexitems).i_mbrno)
    || TRIM(itempflist(indexitems).i_dpntno) ) := TRIM(itempflist(indexitems).i_chdrnum);
  END LOOP;
  
EXCEPTION
WHEN OTHERS THEN
  getGpmdpf(' ') := TRIM(' ');
END;
-----------GPMDPF Duplicate End--------

-----------GBIDPF Duplicate Start--------
PROCEDURE getGbidpf(
    getGbidpf OUT duplicateGbidpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_billno Jd1dta.GBIDPF.BILLNO%type,
      i_prodtyp Jd1dta.GBIDPF.PRODTYP%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  
BEGIN
  SELECT BILLNO, PRODTYP
  BULK COLLECT INTO itempflist
  FROM Jd1dta.GBIDPF;
  
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getGbidpf( TRIM(itempflist(indexitems).i_billno)
    || TRIM(itempflist(indexitems).i_prodtyp) ) := TRIM(itempflist(indexitems).i_billno);
  END LOOP;
  
EXCEPTION
WHEN OTHERS THEN
  getGbidpf(' ') := TRIM(' ');
END;
-----------GBIDPF Duplicate End--------

-----------Stop bill for T-Cancellation Start--------
PROCEDURE getZtrapf(
    getZtrapf OUT existZtrapf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_chdrnum Jd1dta.ZTRAPF.CHDRNUM%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  
BEGIN
  SELECT CHDRNUM 
  BULK COLLECT INTO itempflist
  FROM Jd1dta.ZTRAPF
  where zcstpbil = 'Y'
  --and ZALTRCDE01 in ('T0B', 'T0D', 'T0F', 'T0Z', 'T04', 'T08');
  and ZALTRCDE01 in ('ZTB','ZTD','ZTF','ZTZ','ZT4','ZT8');-- BL01
  
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getZtrapf( TRIM(itempflist(indexitems).i_chdrnum) ) := TRIM(itempflist(indexitems).i_chdrnum);
  END LOOP;
  
EXCEPTION
WHEN OTHERS THEN
  getZtrapf(' ') := TRIM(' ');
END;
-----------Stop bill for T-Cancellation End--------

-----------Get Bill Number Start----------------
PROCEDURE getPaZdcrpf(
    getPaZdcrpf OUT duplicatePaZdcrpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
      i_zentity PAZDCRPF.ZENTITY%type); 
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT ZENTITY BULK COLLECT
  INTO itempflist
  FROM PAZDCRPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getPaZdcrpf(TRIM(itempflist(indexitems).i_zentity)) := TRIM(itempflist(indexitems) .i_zentity);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getPaZdcrpf(' ') := TRIM(' ');
END;
-----------Collection Result Duplicate End--------
-----------Get Bill Number START -----------------
 PROCEDURE getbillno(getbillno OUT billnomap)

   is
    indexitems PLS_INTEGER;
    TYPE obj_zigvalue IS RECORD(
      zentity  PAZDRBPF.ZENTITY%type,
      chdrnum  PAZDRBPF.CHDRNUM%type,
      zigvalue PAZDRBPF.ZIGVALUE%type);
    TYPE v_array IS TABLE OF obj_zigvalue;
    zigvaluelist v_array;
  BEGIN

    Select ZENTITY, CHDRNUM, ZIGVALUE
      BULK COLLECT
      into zigvaluelist
      from Jd1dta.PAZDRBPF;

    FOR indexitems IN zigvaluelist.first .. zigvaluelist.last LOOP
      getbillno(TRIM(zigvaluelist(indexitems).zentity)) := TRIM(zigvaluelist(indexitems)
                                                                  .zigvalue);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      getbillno(' ') := TRIM(' ');
  END;
  -----------Get Bill Number END -----------------
-----------ZAGPTNUM Start --------
PROCEDURE getZagptnum(
    getZagptnum OUT newgchipf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_chdrnum GCHIPF.CHDRNUM%type,
    i_zagptnum GCHIPF.ZAGPTNUM%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT CHDRNUM,
    ZAGPTNUM BULK COLLECT
  INTO itempflist
  FROM Jd1dta.GCHIPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getZagptnum(TRIM(itempflist(indexitems).i_chdrnum)) := (itempflist(indexitems).i_zagptnum);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getZagptnum(' ') := TRIM(' ');
END;
-----------ZAGPTNUM END --------
-------------BILL1 Records START-------

PROCEDURE getbill1info(
                          BILL1INFO OUT BILL1TYPE)

   is
    indexitems PLS_INTEGER;
    TYPE obj_bill1 IS RECORD(
      i_trrefnum   TITDMGBILL1.TRREFNUM@DMSTAGEDBLINK%type,
      i_chdrnum  TITDMGBILL1.CHDRNUM@DMSTAGEDBLINK%type,
      i_prbilfdt TITDMGBILL1.PRBILFDT@DMSTAGEDBLINK%type,
      i_prbiltdt TITDMGBILL1.PRBILTDT@DMSTAGEDBLINK%type);
    TYPE v_array IS TABLE OF obj_bill1;
    bill1list v_array;

  BEGIN

    Select TRIM(TRREFNUM), CHDRNUM, PRBILFDT, PRBILTDT
      BULK COLLECT
      into bill1list
      from TITDMGBILL1@DMSTAGEDBLINK;

    FOR indexitems IN bill1list.first .. bill1list.last LOOP

      BILL1INFO(TRIM(bill1list(indexitems).i_trrefnum) || TRIM(bill1list(indexitems).i_chdrnum)).trrefnum := TRIM(bill1list(indexitems).i_trrefnum);

      BILL1INFO(TRIM(bill1list(indexitems).i_trrefnum) || TRIM(bill1list(indexitems).i_chdrnum)).chdrnum := TRIM(bill1list(indexitems).i_chdrnum);

      BILL1INFO(TRIM(bill1list(indexitems).i_trrefnum) || TRIM(bill1list(indexitems).i_chdrnum)).prbilfdt := TRIM(bill1list(indexitems).i_prbilfdt);

      BILL1INFO(TRIM(bill1list(indexitems).i_trrefnum) || TRIM(bill1list(indexitems).i_chdrnum)).prbiltdt := TRIM(bill1list(indexitems).i_prbiltdt);

    END LOOP;

  END;
  -------------BILL1 Records END-------
  -------------Get mbr p1 Information-------

  PROCEDURE getrefundbillinfo(
                              --i_company_Name IN VARCHAR2,
                              REFBILINFO OUT REFBILLTYPE)

   is
    indexitems PLS_INTEGER;
    TYPE obj_refbilp1 IS RECORD(
      i_refnum   TITDMGREF1.REFNUM@DMSTAGEDBLINK%type,
      i_chdrnum  TITDMGREF1.CHDRNUM@DMSTAGEDBLINK%type,
      i_zrefmtcd TITDMGREF1.ZREFMTCD@DMSTAGEDBLINK%type,
      i_effdate  TITDMGREF1.EFFDATE@DMSTAGEDBLINK%type,
      i_prbilfdt TITDMGREF1.PRBILFDT@DMSTAGEDBLINK%type,
      i_prbiltdt TITDMGREF1.PRBILTDT@DMSTAGEDBLINK%type);
    TYPE v_array IS TABLE OF obj_refbilp1;
    refbilp1list v_array;

  BEGIN

    Select TRIM(refnum), chdrnum, zrefmtcd, effdate, prbilfdt, prbiltdt

      BULK COLLECT
      into refbilp1list
      from TITDMGREF1@DMSTAGEDBLINK;

    FOR indexitems IN refbilp1list.first .. refbilp1list.last LOOP

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).refnum := TRIM(refbilp1list(indexitems)
                                                                                                                                                                  .i_refnum);

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).chdrnum := TRIM(refbilp1list(indexitems)
                                                                                                                                                                   .i_chdrnum);

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).zrefmtcd := TRIM(refbilp1list(indexitems)
                                                                                                                                                                    .i_zrefmtcd);

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).effdate := TRIM(refbilp1list(indexitems)
                                                                                                                                                                   .i_effdate);

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).prbilfdt := TRIM(refbilp1list(indexitems)
                                                                                                                                                                    .i_prbilfdt);

      REFBILINFO(TRIM(refbilp1list(indexitems).i_chdrnum) || TRIM(refbilp1list(indexitems).i_refnum) || TRIM(refbilp1list(indexitems).i_zrefmtcd)).prbiltdt := TRIM(refbilp1list(indexitems)
                                                                                                                                                                    .i_prbiltdt);

    END LOOP;

  END;
  -------------Get mbr p1 Information-------
  
  -------------Get Endorser Type------------
  PROCEDURE getendrtype(getendrtype OUT zendrpftype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZENDRPF;
    itempflist v_array;

  BEGIN
	SELECT TRIM(a.ZENDCDE) ZENDCDE,  SUBSTR( utl_raw.cast_to_varchar2(b.GENAREA), 200, 2) ZCOLM
	    BULK COLLECT into itempflist
	FROM ZENDRPF a LEFT OUTER JOIN itempf b ON trim(b.itemitem) = trim(a.ZFACTHUS)
	AND TRIM(b.itemtabl) = 'T3684' AND b.validflag = 1;	
  
      FOR idx IN itempflist.first .. itempflist.last LOOP
        getendrtype(TRIM(itempflist(idx).ZENDCDE)):= itempflist(idx);
      END LOOP;	
   END; 
  -------------Get Endorser Type------------   
END PKG_COMMON_DMBL;

/