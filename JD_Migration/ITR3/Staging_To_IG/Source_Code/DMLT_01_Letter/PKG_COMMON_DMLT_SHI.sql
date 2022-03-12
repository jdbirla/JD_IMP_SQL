create or replace PACKAGE          "PKG_COMMON_DMLT" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMLT
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM Policy TSD
  **************************************************************************************************************************/

  ---- Check master ploicy:START-----------
  TYPE ltduplicate IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
  PROCEDURE checkcpdup(checkdupl OUT ltduplicate);
  ---- Check master ploicy:END----------
  ----------- PAZDCLPF Client Start ------------
  TYPE newzdclpf
IS
  TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE getClntnum(
      getClntnum OUT newzdclpf);
  ----------- PAZDCLPF Client End ------------

end PKG_COMMON_DMLT;





/

create or replace PACKAGE BODY          "PKG_COMMON_DMLT" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMLT
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  **************************************************************************************************************************/

  ----ITEMPF Check:START-----------
  PROCEDURE checkcpdup(checkdupl OUT ltduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum  pazdltpf.chdrnum%type,
      i_hlettype pazdltpf.hlettype%type,
      i_lreqdate pazdltpf.lreqdate%type,
      i_zletvern pazdltpf.zletvern%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select chdrnum, hlettype, lreqdate, zletvern
      BULK COLLECT
      into itempflist
      from PAZDLTPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_hlettype) || TRIM(itempflist(indexitems).i_lreqdate) || TRIM(itempflist(indexitems).i_zletvern)) := TRIM(itempflist(indexitems)
                                                                                                                                                                                                 .i_chdrnum) ||
                                                                                                                                                                                            TRIM(itempflist(indexitems)
                                                                                                                                                                                                 .i_hlettype) ||
                                                                                                                                                                                            TRIM(itempflist(indexitems)
                                                                                                                                                                                                 .i_lreqdate) ||
                                                                                                                                                                                            TRIM(itempflist(indexitems)
                                                                                                                                                                                                 .i_zletvern);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;
---------

-----------PAZDCLPF Client Start --------
PROCEDURE getClntnum(
    getClntnum OUT newzdclpf)
IS
  indexitems PLS_INTEGER;
TYPE obj_itempf
IS
  RECORD
  (
    i_zigvalue PAZDCLPF.ZIGVALUE%type,
    i_zentity PAZDCLPF.ZENTITY%type);
TYPE v_array
IS
  TABLE OF obj_itempf;
  itempflist v_array;
BEGIN
  SELECT ZIGVALUE,
    ZENTITY BULK COLLECT
  INTO itempflist
  FROM Jd1dta.PAZDCLPF WHERE prefix ='CP';
  FOR indexitems IN itempflist.first .. itempflist.last
  LOOP
    getClntnum(TRIM(itempflist(indexitems).i_zentity)) := (itempflist(indexitems).i_zigvalue);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getClntnum(' ') := TRIM(' ');
END;
-----------PAZDCLPF Client Start--------

end PKG_COMMON_DMLT;








/