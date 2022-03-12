CREATE OR REPLACE PACKAGE Jd1dta."PKG_COMMON_DMCH" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCH
  * Author           : Patrice Santiago
  * Creation Date    : April 12, 2018
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCP-Client History
  **************************************************************************************************************************/

  ---- Check client history duplicate:START-----------
  TYPE cpduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkcpdup(checkdupl OUT cpduplicate);
  ---- Check  client history duplicate:END----------

 ----PAZDCLPF Check:START-----------
 
  TYPE obj_nzdf IS RECORD(
    Zentity  Jd1dta.PAZDCLPF.Zentity%type,
    Recstatus Jd1dta.PAZDCLPF.Recstatus%type,
    zigvalue Jd1dta.pazdnypf.ZIGVALUE%type);

 
 
  TYPE zigvaluetype IS TABLE OF obj_nzdf INDEX BY VARCHAR2(50);
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype);
  ----PAZDCLPF Check:END-----------
end PKG_COMMON_DMCH;


/
CREATE OR REPLACE PACKAGE BODY Jd1dta."PKG_COMMON_DMCH" as
 /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMCP
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMCM TSD
  **************************************************************************************************************************/

  ----PAZDCHPF Check:START-----------
  PROCEDURE checkcpdup(checkdupl OUT cpduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAzdchpf.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select zentity BULK COLLECT into itempflist from Jd1dta.PAzdchpf;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;
  ----PAZDCHPF Check:END-------------

  ----PAZDCLPF Check:START-----------
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype)

   is
    indexitems PLS_INTEGER;
    TYPE v_array IS TABLE OF obj_nzdf;
    zigvaluelist v_array;
    
    i binary_integer;

  BEGIN

    Select ZENTITY, RECSTATUS, ZIGVALUE
      BULK COLLECT
      into zigvaluelist
      from Jd1dta.PAZDCLPF
     where prefix = 'CP';
     i := zigvaluelist.first;
     if(i > 0)then
    FOR indexitems IN zigvaluelist.first .. zigvaluelist.last LOOP
      getzigvalue(TRIM(zigvaluelist(indexitems).zentity)) := zigvaluelist(indexitems);
    END LOOP;
end if;
  
  END;
  ----PAZDCLPF Check:END-----------

end PKG_COMMON_DMCH;


/