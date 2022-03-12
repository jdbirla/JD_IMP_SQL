create or replace PACKAGE "PKG_COMMON_DMCB" AS

    -----------Get Bankkey:START--------
TYPE bankkey
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE getbankkey(
      getbankkey OUT bankkey);
  -----------Get Bankkey:END--------
-----------Client Migrated:START--------
TYPE zdclpf_cp01
IS
  TABLE OF VARCHAR2(60) INDEX BY VARCHAR2(60);
  PROCEDURE checkclient(
      checkclient OUT zdclpf_cp01);
  -----------Client Migrated:END--------
   ---- Check master ploicy:START-----------
  TYPE cbduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkcbdup(checkdupl OUT cbduplicate);
  ---- Check master ploicy:END----------
  ----PAZDCLPF Check:START-----------
  TYPE zigvaluetype IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype);
  ----PAZDCLPF Check:END-----------
 -----------Get CLBAPF FOR CREDIT CARD:START--------
  TYPE OBJ_CLBAPF_CC IS RECORD(
    clntnum    clbapf.clntnum%type,
    BANKKEY    clbapf.BANKKEY%type,
    bankacckey clbapf.bankacckey%type
    );
  TYPE clbatype IS TABLE OF OBJ_CLBAPF_CC INDEX BY VARCHAR2(50);
  PROCEDURE getclbapforcc(getclbapforcc OUT clbatype);
  -----------Get CLBAPF:END--------

END PKG_COMMON_DMCB;
/
create or replace PACKAGE BODY        "PKG_COMMON_DMCB" AS



------------- BankKey Start-----------------
  PROCEDURE getbankkey(
      getbankkey OUT bankkey) 
      IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    bank_key BABRPF.BANKKEY%type );
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  BEGIN
  SELECT BANKKEY BULK COLLECT INTO itempflist FROM Jd1dta.BABRPF;
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getbankkey(TRIM(itempflist(indexitems).bank_key)) := TRIM(itempflist(indexitems).bank_key);
  END LOOP;
  END getbankkey;
---------------- BankKey End ------------------------

-------------------Client Migrated Start ----------------
  PROCEDURE checkclient(
      checkclient OUT zdclpf_cp01) 
      IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    zdcl_client PAZDCLPF.ZENTITY%type );
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
  BEGIN


  SELECT a.zentity  BULK COLLECT INTO itempflist FROM Jd1dta.PAZDCLPF A
  WHERE
  exists (select 1 from Jd1dta.CLNTPF B where rtrim(b.clntnum) = RTRIM(a.zigvalue)) and
  PREFIX = 'CP';
  
  
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    checkclient(TRIM(itempflist(indexitems).zdcl_client)) := TRIM(itempflist(indexitems).zdcl_client);
  END LOOP;
  END checkclient;


------------------ Client Migrated End ---------------------
  ------------Duplicate check----------

  PROCEDURE checkcbdup(checkdupl OUT cbduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDCLPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select zentity
      BULK COLLECT
      into itempflist
      from Jd1dta.PAZDCLPF
     where prefix = 'CB';

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;
  --------------Duplicate check--------------
  ----PAZDCLPF Check:START-----------
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype)

   is
    indexitems PLS_INTEGER;
    TYPE obj_zigvalue IS RECORD(
      zentity  PAZDCLPF.ZENTITY%type,
      zigvalue PAZDCLPF.ZIGVALUE%type);
    TYPE v_array IS TABLE OF obj_zigvalue;
    zigvaluelist v_array;
  BEGIN

    Select ZENTITY, ZIGVALUE
      BULK COLLECT
      into zigvaluelist
      from Jd1dta.PAZDCLPF
     WHERE PREFIX = 'CP';

    FOR indexitems IN zigvaluelist.first .. zigvaluelist.last LOOP
      getzigvalue(TRIM(zigvaluelist(indexitems).zentity)) := TRIM(zigvaluelist(indexitems)
                                                                  .zigvalue);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      getzigvalue(' ') := TRIM(' ');
  END;
  ----PAZDCLPF Check:END-----------
  
  -----------Get CLBAPF FOR CREDIT CARD:START--------
         -----------Get CLBA FOR CREDIT CARD:START------------
  PROCEDURE getclbapforcc(getclbapforcc OUT clbatype) is
  	idx PLS_INTEGER;
    --TYPE clbatype IS TABLE OF OBJ_CLBAPF_CC INDEX BY VARCHAR2(50);
    TYPE v_array IS TABLE OF OBJ_CLBAPF_CC;
    clbalist v_array;
    clbatype v_array;
    BEGIN
      SELECT  clntnum,BANKKEY, bankacckey
      BULK COLLECT
      into clbalist
      FROM CLBAPF
      where TRIM(Clntpfx) = TRIM('CN')
      and TRIM(validflag) = TRIM('1');
     -- and TRIM(bnkactyp) = TRIM('CC');

      IF clbalist.count > 0 THEN  --- PH13
        FOR idx IN clbalist.first .. clbalist.last LOOP
          getclbapforcc(TRIM(clbalist(idx).clntnum)||TRIM(clbalist(idx).bankkey)||TRIM(clbalist(idx).bankacckey)) := clbalist(idx);
        END LOOP;
      END IF;  -- PH13
	  -- PH11 [END]

  END;
  -----------Get CLBA:END------------

  -----------Get CLBAPF:END--------
END PKG_COMMON_DMCB;