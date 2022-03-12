create or replace PACKAGE          "PKG_COMMON_DMCM" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCM
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM Policy TSD
  **************************************************************************************************************************/

  ---- Check master ploicy:START-----------
  TYPE gchdtype IS TABLE OF VARCHAR2(15) INDEX BY VARCHAR2(15);
  PROCEDURE checkmasterpol(checkchdrnum OUT gchdtype);
  ---- Check master ploicy:END----------

---- Check duplicate camp code:START-----------
  TYPE cmduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkcmdup(checkdupl OUT cmduplicate);
  ---- Check duplicate camp code:END-----------

  ---- Get ZCPNPF:START-----------
  TYPE OBJ_ZCPNPF IS RECORD(
	ZCMPCODE	ZCPNPF.ZCMPCODE%type,
	ZCCODIND	ZCPNPF.ZCCODIND%type);
  TYPE zcpnpftype IS TABLE OF OBJ_ZCPNPF INDEX BY VARCHAR2(60);
  PROCEDURE getzcpnpf(getzcpnpf1 OUT zcpnpftype);
  ---- Get ZCPNPF:START-----------

  ---- Check duplicate ZCSLPF:START-----------
  TYPE ZCSLPFtype IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkZCSLPF(checkZCSLPF1 OUT ZCSLPFtype);
  ---- Check duplicate ZCSLPF:END-----------
end PKG_COMMON_DMCM;

/
create or replace PACKAGE BODY          "PKG_COMMON_DMCM" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCM
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  **************************************************************************************************************************/

  ----ITEMPF Check:START-----------

  PROCEDURE checkmasterpol(checkchdrnum OUT gchdtype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum gchd.CHDRNUM%type,
      i_company itempf.itemcoy%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select CHDRNUM, CHDRCOY
      BULK COLLECT
      into itempflist
      from GCHD
     where TRIM(CHDRPFX) = TRIM('CH')
       AND TRIM(CHDRCOY) = TRIM('1');

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkchdrnum(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)                                                                                                .i_chdrnum);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
      checkchdrnum(' ') := TRIM(' ');
  END;

----Duplicate  Check:START-----------
  PROCEDURE checkcmdup(checkdupl OUT cmduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDROPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select zentity BULK COLLECT into itempflist from PAZDROPF WHERE PREFIX='CM';

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;


  -----------Get ZCPNP Record START----  
  PROCEDURE getzcpnpf(getzcpnpf1 OUT zcpnpftype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZCPNPF;
    itempflist v_array;

  BEGIN
    SELECT ZCMPCODE, ZCCODIND
    BULK COLLECT into itempflist
    FROM Jd1dta.ZCPNPF;


      FOR idx IN itempflist.first .. itempflist.last LOOP
        getzcpnpf1(TRIM(itempflist(idx).ZCMPCODE)):= itempflist(idx);
      END LOOP;	

    EXCEPTION
        WHEN OTHERS THEN
          getzcpnpf1(' '):= null;
    END;
  -----------Get ZCPNP Record END----  

----Duplicate  Check:START-----------
   PROCEDURE checkZCSLPF(checkZCSLPF1 OUT ZCSLPFtype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity VARCHAR2(60));
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    SELECT (ZSALPLAN ||  ZCMPCODE) zenentity BULK COLLECT INTO itempflist FROM Jd1dta.ZCSLPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkZCSLPF1(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkZCSLPF1(' ') := TRIM(' ');
  END;

end PKG_COMMON_DMCM;
/



