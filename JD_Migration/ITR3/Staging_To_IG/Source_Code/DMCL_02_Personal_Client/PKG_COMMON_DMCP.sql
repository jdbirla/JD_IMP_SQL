CREATE OR REPLACE PACKAGE Jd1dta."PKG_COMMON_DMCP" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCP
  * Author           : Jitendra Birla
  * Creation Date    : March 27, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM Policy TSD
  **************************************************************************************************************************/

  ---- Check master ploicy:START-----------
  TYPE cpduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkcpdup(checkdupl OUT cpduplicate);
  ---- Check master ploicy:END----------
  -------------GetItem:Start----------
  TYPE obj_itempf IS RECORD(
    occclass VARCHAR2(2));

  TYPE itemschec IS TABLE OF obj_itempf INDEX BY VARCHAR2(16);

  PROCEDURE getitemvalue(itemexist OUT itemschec);

  TYPE nyduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checknydup(nycheckdupl OUT nyduplicate);

  TYPE obj_nypf IS RECORD(
    Zentity  Jd1dta.pazdnypf.Zentity%type,
    CLNTSTAS Jd1dta.pazdnypf.CLNTSTAS%type,
    zigvalue Jd1dta.pazdnypf.ZIGVALUE%type);

  TYPE nypftype IS TABLE OF obj_nypf INDEX BY VARCHAR2(9);
  PROCEDURE getnyval(getnypf OUT nypftype);

--------------getItem:End-----
end PKG_COMMON_DMCP;


/

 CREATE OR REPLACE PACKAGE BODY Jd1dta."PKG_COMMON_DMCP" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCP
  * Author           : Jitendra Birla
  * Creation Date    : March 27 , 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  **************************************************************************************************************************/

  ----ITEMPF Check:START-----------
  PROCEDURE checkcpdup(checkdupl OUT cpduplicate) is
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
     where prefix = 'CP';
  
    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;

  --------------Getitem---------------
  ----ITEMPF Check:START-----------

  PROCEDURE getitemvalue(itemexist OUT itemschec)
  
   is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_item    itempf.itemitem%type,
      i_genarea itempf.genarea%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;
  
  BEGIN
  
    Select ITEMITEM, genarea
      BULK COLLECT
      into itempflist
      from Jd1dta.itempf
     where TRIM(itemtabl) IN ('T3644')
       and TRIM(itemcoy) = '9'
       and TRIM(itempfx) = 'IT'
       and TRIM(validflag) = '1';
  
    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      itemexist(TRIM(itempflist(indexitems).i_item)).occclass := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                      .i_genarea),
                                                                             501,
                                                                             2));
    
    END LOOP;
  
  END;
  ----------------------GetItem-----------
  PROCEDURE checknydup(nycheckdupl OUT nyduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDNYPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;
  
  BEGIN
  
    select zentity
      BULK COLLECT
      into itempflist
      from PAZDNYPF
     where prefix = 'NY';
  
    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      nycheckdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                    .i_zenentity);
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      nycheckdupl(' ') := TRIM(' ');
  END;

  PROCEDURE getnyval(getnypf OUT nypftype) is
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF obj_nypf;
    nylist v_array;
  
  BEGIN
  
    Select Zentity, CLNTSTAS, zigvalue
      BULK COLLECT
      into nylist
      from Jd1dta.pazdnypf;
  
    FOR idx IN nylist.first .. nylist.last LOOP
      getnypf(TRIM(nylist(idx).Zentity)) := nylist(idx);
    END LOOP;
    -- PH11 [END]
  
  END;

end PKG_COMMON_DMCP;

/

