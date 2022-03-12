create or replace package                                    Jd1dta.PKG_DM_COMMON_OPERATIONS  
  AUTHID current_user AS

  /**************************************************************************************************************************
  * File Name        : PKG_DM_COMMON_OPERATIONS
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in Data Migration
  **************************************************************************************************************************/
  --****************Create ZDOEPF Dynamic: START ********************

  PROCEDURE createzdoepf(i_tableName IN VARCHAR2);

  --****************Create ZDOEPF Dynamic : END ********************

  --****************Get Default Values : START ********************
  /*TYPE defaultvaluesmap1 IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(20);

  PROCEDURE getdefaultvalues(i_itemName      IN VARCHAR2,
                             i_company       IN varchar2,
                             o_defaultvalues OUT defaultvaluesmap1);*/

  --****************Get Default Values : END ********************
  --****************checkItemExist : START **********************
  TYPE itemschec IS TABLE OF VARCHAR2(16) INDEX BY VARCHAR2(16);

  PROCEDURE checkItemExist(i_module_name IN VARCHAR2,
                           --   i_company_name IN VARCHAR2,
                           itemexist OUT itemschec);
  --****************checkItemExist : END *************************
  --****************geterrordesc : START **************************
  TYPE errordesc IS TABLE OF VARCHAR2(250) INDEX BY VARCHAR2(6);

  PROCEDURE geterrordesc(i_module_name IN VARCHAR2,
                         o_errortext   OUT errordesc);

  --****************geterrordesc : END **************************
  --****************insertintozdoe : START **********************

  TYPE obj_zdoe IS RECORD(

    -- i_tablecnt NUMBER(1),
    i_tableName  VARCHAR2(10),
    i_refKey     zdoepf.zrefkey%type,
    i_zfilename  zdoepf.zfilenme%type,
    i_indic      zdoepf.indic%type,
    i_prefix     VARCHAR2(2),
    i_scheduleno zdoepf.jobnum%type,

    i_error01        zdoepf.eror01%type,
    i_errormsg01     zdoepf.errmess01%type,
    i_errorfield01   zdoepf.erorfld01%type,
    i_fieldvalue01   zdoepf.fldvalu01%type,
    i_errorprogram01 zdoepf.erorprog01%type,

    i_error02        zdoepf.eror01%type,
    i_errormsg02     zdoepf.errmess01%type,
    i_errorfield02   zdoepf.erorfld01%type,
    i_fieldvalue02   zdoepf.fldvalu01%type,
    i_errorprogram02 zdoepf.erorprog01%type,

    i_error03        zdoepf.eror01%type,
    i_errormsg03     zdoepf.errmess01%type,
    i_errorfield03   zdoepf.erorfld01%type,
    i_fieldvalue03   zdoepf.fldvalu01%type,
    i_errorprogram03 zdoepf.erorprog01%type,

    i_error04        zdoepf.eror01%type,
    i_errormsg04     zdoepf.errmess01%type,
    i_errorfield04   zdoepf.erorfld01%type,
    i_fieldvalue04   zdoepf.fldvalu01%type,
    i_errorprogram04 zdoepf.erorprog01%type,

    i_error05        zdoepf.eror01%type,
    i_errormsg05     zdoepf.errmess01%type,
    i_errorfield05   zdoepf.erorfld01%type,
    i_fieldvalue05   zdoepf.fldvalu01%type,
    i_errorprogram05 zdoepf.erorprog01%type);

  PROCEDURE insertintozdoe(i_zdoe_info IN obj_zdoe);

--****************insertintozdoe : END **************************



------------------------getdefval:START------------------------------


TYPE defaultvaluesmap IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(20);
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE getdefval(i_module_name IN VARCHAR2,
                         o_defaultvalues OUT defaultvaluesmap);
------------------------getdefval:END------------------------------

/* --****************TEMP START ********************

     TYPE obj_anumpf IS RECORD(
    i_table itempf.itemtabl%type,
    i_item itempf.itemitem%type
   );
TYPE v_array IS TABLE OF obj_anumpf;


  PROCEDURE tempbulk(i_itemName      IN VARCHAR2,
                             i_company       IN varchar2,
                             ais_array OUT v_array);

  --****************TEMP  END ********************
  */
end PKG_DM_COMMON_OPERATIONS;

/
create or replace package body                                    Jd1dta.PKG_DM_COMMON_OPERATIONS 
 AS

  /**************************************************************************************************************************
  * File Name        : PKG_DM_COMMON_OPERATIONS
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in Data Migration
  **************************************************************************************************************************/
  --****************Create ZDOEPF Dynamic: START ********************

  PROCEDURE createzdoepf(i_tableName IN VARCHAR2) is
    v_ddlquery VARCHAR2(500) ;
  BEGIN
    v_ddlquery := 'CREATE TABLE Jd1dta.' || i_tableName ||
                  ' AS (SELECT * FROM Jd1dta.ZDOEPF)';
    EXECUTE IMMEDIATE v_ddlquery;
  END;
  --****************Create ZDOEPF Dynamic : END ******************** 

  --****************Get Default Values : START *********************************
 /* PROCEDURE getdefaultvalues(i_itemName      IN VARCHAR2,
                             i_company       IN varchar2,
                             o_defaultvalues OUT defaultvaluesmap1)

   is
    C_SPACE constant varchar2(1) := ' ';

    field1     VARCHAR2(15 CHAR);
    field2     VARCHAR2(15 CHAR);
    field3     VARCHAR2(15 CHAR);
    field4     VARCHAR2(15 CHAR);
    field5     VARCHAR2(15 CHAR);
    field6     VARCHAR2(15 CHAR);
    field7     VARCHAR2(15 CHAR);
    field8     VARCHAR2(15 CHAR);
    field9     VARCHAR2(15 CHAR);
    field10    VARCHAR2(15 CHAR);
    field11    VARCHAR2(15 CHAR);
    field12    VARCHAR2(15 CHAR);
    field13    VARCHAR2(15 CHAR);
    field14    VARCHAR2(15 CHAR);
    field15    VARCHAR2(15 CHAR);
    field16    VARCHAR2(15 CHAR);
    field17    VARCHAR2(15 CHAR);
    field18    VARCHAR2(15 CHAR);
    value1     VARCHAR2(15 CHAR);
    value2     VARCHAR2(15 CHAR);
    value3     VARCHAR2(15 CHAR);
    value4     VARCHAR2(15 CHAR);
    value5     VARCHAR2(15 CHAR);
    value6     VARCHAR2(15 CHAR);
    value7     VARCHAR2(15 CHAR);
    value8     VARCHAR2(15 CHAR);
    value9     VARCHAR2(15 CHAR);
    value10    VARCHAR2(15 CHAR);
    value11    VARCHAR2(15 CHAR);
    value12    VARCHAR2(15 CHAR);
    value13    VARCHAR2(15 CHAR);
    value14    VARCHAR2(15 CHAR);
    value15    VARCHAR2(15 CHAR);
    value16    VARCHAR2(15 CHAR);
    value17    VARCHAR2(15 CHAR);
    value18    VARCHAR2(15 CHAR);
    contitem   VARCHAR2(8 CHAR);
    itemVal    VARCHAR2(8);
    all_fields VARCHAR2(1000 CHAR);
    all_values VARCHAR2(1000 CHAR);
  BEGIN

    all_fields := '';
    all_values := '';
    itemVal    := i_itemName;

    <<readAgain>>
    select TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 1, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 181, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 11, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 191, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 21, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 201, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 31, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 211, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 41, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 221, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 51, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 231, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 61, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 241, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 71, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 251, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 81, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 261, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 91, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 271, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 101, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 281, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 111, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 291, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 121, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 301, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 131, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 311, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 141, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 321, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 151, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 331, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 161, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 341, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 171, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 351, 10)),
           TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA), 361, 8))
      INTO field1,
           value1,
           field2,
           value2,
           field3,
           value3,
           field4,
           value4,
           field5,
           value5,
           field6,
           value6,
           field7,
           value7,
           field8,
           value8,
           field9,
           value9,
           field10,
           value10,
           field11,
           value11,
           field12,
           value12,
           field13,
           value13,
           field14,
           value14,
           field15,
           value15,
           field16,
           value16,
           field17,
           value17,
           field18,
           value18,
           contitem
      FROM ITEMPF
     WHERE RTRIM(ITEMTABL) = 'TQ9Q9'
       and RTRIM(ITEMITEM) = TRIM(itemVal)
       and RTRIM(ITEMCOY) = TRIM(i_company);

    IF field1 IS NOT NULL THEN
      IF value1 IS NUll THEN
        o_defaultvalues(field1) := C_SPACE;
      ELSE
        o_defaultvalues(field1) := value1;
      END IF;

    END IF;

    IF field2 IS NOT NULL THEN

      IF value2 IS NUll THEN
        o_defaultvalues(field2) := C_SPACE;
      ELSE
        o_defaultvalues(field2) := value2;
      END IF;
    END IF;

    IF field3 IS NOT NULL THEN

      IF value3 IS NUll THEN
        o_defaultvalues(field3) := C_SPACE;
      ELSE
        o_defaultvalues(field3) := value3;
      END IF;
    END IF;

    IF field4 IS NOT NULL THEN

      IF value4 IS NUll THEN
        o_defaultvalues(field4) := C_SPACE;
      ELSE
        o_defaultvalues(field4) := value4;
      END IF;
    END IF;

    IF field5 IS NOT NULL THEN

      IF value5 IS NUll THEN
        o_defaultvalues(field5) := C_SPACE;
      ELSE
        o_defaultvalues(field5) := value5;
      END IF;
    END IF;

    IF field6 IS NOT NULL THEN

      IF value6 IS NUll THEN
        o_defaultvalues(field6) := C_SPACE;
      ELSE
        o_defaultvalues(field6) := value6;
      END IF;
    END IF;

    IF field7 IS NOT NULL THEN

      IF value7 IS NUll THEN
        o_defaultvalues(field7) := C_SPACE;
      ELSE
        o_defaultvalues(field7) := value7;
      END IF;
    END IF;

    IF field8 IS NOT NULL THEN

      IF value8 IS NUll THEN
        o_defaultvalues(field8) := C_SPACE;
      ELSE
        o_defaultvalues(field8) := value8;
      END IF;
    END IF;

    IF field9 IS NOT NULL THEN

      IF value9 IS NUll THEN
        o_defaultvalues(field9) := C_SPACE;
      ELSE
        o_defaultvalues(field9) := value9;
      END IF;
    END IF;

    IF field10 IS NOT NULL THEN

      IF value10 IS NUll THEN
        o_defaultvalues(field10) := C_SPACE;
      ELSE
        o_defaultvalues(field10) := value10;
      END IF;
    END IF;

    IF field11 IS NOT NULL THEN

      IF value11 IS NUll THEN
        o_defaultvalues(field11) := C_SPACE;
      ELSE
        o_defaultvalues(field11) := value11;
      END IF;
    END IF;

    IF field12 IS NOT NULL THEN

      IF value12 IS NUll THEN
        o_defaultvalues(field12) := C_SPACE;
      ELSE
        o_defaultvalues(field12) := value12;
      END IF;
    END IF;

    IF field13 IS NOT NULL THEN

      IF value13 IS NUll THEN
        o_defaultvalues(field13) := C_SPACE;
      ELSE
        o_defaultvalues(field13) := value13;
      END IF;
    END IF;

    IF field14 IS NOT NULL THEN

      IF value14 IS NUll THEN
        o_defaultvalues(field14) := C_SPACE;
      ELSE
        o_defaultvalues(field14) := value14;
      END IF;
    END IF;

    IF field15 IS NOT NULL THEN

      IF value15 IS NUll THEN
        o_defaultvalues(field15) := C_SPACE;
      ELSE
        o_defaultvalues(field15) := value15;
      END IF;
    END IF;

    IF field16 IS NOT NULL THEN

      IF value16 IS NUll THEN
        o_defaultvalues(field16) := C_SPACE;
      ELSE
        o_defaultvalues(field16) := value16;
      END IF;
    END IF;

    IF field17 IS NOT NULL THEN

      IF value17 IS NUll THEN
        o_defaultvalues(field17) := C_SPACE;
      ELSE
        o_defaultvalues(field17) := value17;
      END IF;
    END IF;

    IF field18 IS NOT NULL THEN

      IF value18 IS NUll THEN
        o_defaultvalues(field18) := C_SPACE;
      ELSE
        o_defaultvalues(field18) := value18;
      END IF;
    END IF;

    IF contitem IS NOT NULL THEN
      itemVal := contitem;
      GOTO readAgain;
    END IF;

  end;*/
  --****************Get Default Values : END *********************************
  --****************checkItemExist: START ************************************

  PROCEDURE checkItemExist(i_module_name IN VARCHAR2,
                           --     i_company_name IN VARCHAR2,
                           itemexist OUT itemschec)

   is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_table   itempf.itemtabl%type,
      i_item    itempf.itemitem%type,
      i_company itempf.itemcoy%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN
    ----------DMCL  : START------
    IF (TRIM(i_module_name) = TRIM('DMCL')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('T3643', 'T1658', 'T3645')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMCL  : END------
    ----------DMBL,BQ9TK: START------
    IF (TRIM(i_module_name) = TRIM('BQ9TK')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('T9797')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMBL,BQ9TK  : END------
    --(SELECT SUBSTR(ITEMITEM,5,2) FROM ITEMPF WHERE ITEMTABL='TQ9JT' AND ITEMPFX='IT' AND ITEMCOY='1')
    ----------DMBL,BQ9TL: START------
    IF (TRIM(i_module_name) = TRIM('BQ9TL')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('TQ9JT')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
                 itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                        .i_item);
      END LOOP;
    END IF;
    ----------DMBL,BQ9TL  : END------
    ----------DMCM: START------
    IF (TRIM(i_module_name) = TRIM('DMCM')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('T9799','TQ9R9','TQ9RA','TQ9RB','TQ9BR')--itr4 changes
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMCM : END------
    ----------DMAG: START------
    IF (TRIM(i_module_name) = TRIM('DMAG')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN
             ('TQ9B6', 'TQ9Q9', 'T3595', 'T3692', 'T1692')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMAG : END------

    ----------DMCP: START------
    IF (TRIM(i_module_name) = TRIM('DMCP')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN
             ('T3645', 'T2241', 'TR393', 'T3644', 'T3582')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMCP : END------
    ----------DMSP: START------
    IF (TRIM(i_module_name) = TRIM('DMSP')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('T9797', 'TQ9B6')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMSP : END------
    ----------DMCB: START------
    IF (TRIM(i_module_name) = TRIM('DMCB')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('TR338', 'T3684')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMCB : END------
    ----------DMLT: START------
    IF (TRIM(i_module_name) = TRIM('DMLT')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN
             ('TQ9I3', 'TQ9IM', 'TQ9IT', 'TQ9IN', 'TQ9IU','TQ9IR')--ITR4 CHANGES
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMLT : END------
    ----------DMPH: START------
    IF (TRIM(i_module_name) = TRIM('DMPH')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('TQ9MP', 'TQ9FT', 'TQ9FU', 'T3584', 'TQ9FW')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMPH : END------
    ----------DMRF: START------
    IF (TRIM(i_module_name) = TRIM('DMRF')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('TQ9G7', 'TQ9NW', 'T9797', 'TR338', 'TQ9MP')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMRF : END------
	
	 ----------DMPC: START------
    IF (TRIM(i_module_name) = TRIM('DMPC')) THEN
      Select itemtabl, ITEMITEM, itemcoy
        BULK COLLECT
        into itempflist
        from Jd1dta.itempf
       where TRIM(itemtabl) IN ('T9797')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR indexitems IN itempflist.first .. itempflist.last LOOP
        itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                                                                 .i_item);
      END LOOP;
    END IF;
    ----------DMPC : END------

  END;
  --****************checkItemExist: END *********************************************
  --****************geterrordesc: START *********************************************

  PROCEDURE geterrordesc(i_module_name IN VARCHAR2,
                         o_errortext   OUT errordesc)

   is

    indexerror PLS_INTEGER;
    TYPE obj_error IS RECORD(
      errorcode  Jd1dta.ERORPF.EROREROR%type,
      errordesc  Jd1dta.ERORPF.ERORDESC%type);
    TYPE v_array IS TABLE OF obj_error;
    errorlist v_array;

  BEGIN
    -----DMCL Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMCL')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQLX',
                                'RQO6',
                                'RQMO',
                                'RQNH',
                                'RPOH',
                                'RQLW',
                                'RQLT',
                                'E186',
                                'D009',
                                'RQLZ',
                                'H036',
                                'H366',
                                'RQV3',
                                'RQV4',
                                'E299',
								'E091',
                                'RFQY',
                                'TR9GW',
                                'E299',
								'RQSQ' );
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMCL Error Desc : END------------------
    -----DMBL Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMBL')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQMB',
                                'RQM8',
                                'RQLT',
                                'RQMA',
                                'RQLU',
                                'RQM3',
                                'RQMD',
                                'RQN1',
                                'RQNI',
                                'RQLK',
                                'RQOJ',
                                'RQOK',
                                'RQOL',
                                'RQWJ','RQZE','F771');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMBL Error Desc : END------------------
    -----DMCM Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMCM')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQLQ',
                        		'RQLT',
								'RQMG',
								'RQMH',
								'RQN2',
								'RQN3',
								'RQN4',
								'RQO6',
								'RQZO',
								'RQZP',
								'RQZQ',
								'RQZR',
								'RQZS',
								'RQZT',
								'RQZU',
								'RQZV',
								'RQZW',
								'RQZX',
								'RQZY',
								'RQZZ',
								'RR01',
								'RR02',
								'RR03',
								'RR04',
								'RR05',
								'RR06',
								'RQM8',
								'RQQX',
								'RQM1',
								'RQMK',
								'RQY9'
							);--itr4 changes
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMCM Error Desc : END------------------
    -----DMAG Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMAG')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQO6',
                                'RQNF',
                                'RQLI',
                                'RQN9',
                                'RQN5',
                                'RQNA',
                                'RQN6',
                                'RQN7',
                                'RQMI',
                                'RQNB',
                                'RQNC',
                                'RQND',
                                'RQNE',
                                'RQLT',
                                'RQN0',
                                'RQN1',
                                'RQN8');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMAG Error Desc : END------------------
    -----DMCP Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMCP')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQLX',
                                'H036',
                                'RQO6',
                                'RQM0',
                                'RQNH',
                                'RQM1',
                                'RQLW',
                                'G979',
                                'F992',
                                'RQLT',
                                'E374',
                                'E186',
                                'D009',
                                'RPOI',
                                'RQV3',
                                'RQV4',
                                'RGKG',
								'H366',
                                'G844',
								'RQLI');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMCP Error Desc : END------------------
   -----DMSP Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMSP')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN
             ('RQMK', 'RQMJ', 'RQO6', 'RQML', 'RQM1', 'RQLU', 'RQMI',
             /**** ITR-4 :  MOD : condition change due to new requirement : START ****/
     'RQNZ', 'RQZ9','RQZA','RQZB','RQZC','RQZD'
      /**** ITR-4 :  MOD: condition change due to new requirement : END ****/
             );
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMSP Error Desc : END------------------
    -----DMCB Error Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMCB')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('E081',
                                'E186',
                                'F665',
                                'H007',
                                'F907',
                                'F906',
                                'E081',
                                'RQLI',
                                'RQO6',
                                'RQOS',
                                'RQOT',
                                'RQLT');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMCB Error Desc : END------------------
    -----DMLT Error Desc : START------------------
     IF (TRIM(i_module_name) = TRIM('DMLT')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQMF',
                                'RQLT',
                                'RQMB',
                                'RQM0',
                                'RQNG',
                                'RQME',
                                'RQO6',
                                'RQLI',
                                'RQYF',
                                'RQYR',
                                'RQYS',
                                'RQYT',
                                'E186',--ITR4 CHANGES
                                'RR32',----ITR4 CHANGES
                                'RQM8');--ITR4 CHANGES
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMLT Error Desc : END------------------
    -----DMMB Error Desc : START------------------

    IF (TRIM(i_module_name) = TRIM('DMMB')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
          AND TRIM(EROREROR) IN (
		  'RQLH',
        'RQLI',
        'RQLJ',
        'RQLL',
        'RQLM',
        'RQLN',
        'RQLO',
        'RQLP',
        'RQLQ',
        'RQQ1',
        'RQLS',
        'RQLT',
        'RQM1',
        'RQO6',
        'RQNQ',
        'RQNR',
        'RQNS',
        'RQNT',
        'RQNU',
        'RQNV',
        'RQNW',
        'RQNX',
        'RQNY',
        'RQNZ',
        'RQO0',
        'E315',
        'F623',
        'S008',
        'RQO1',
        'RQOQ',
        'RQO3',
        'RQO2',
        'E186',
        'RQOR',
		'PA01',
        'RQO4',
        'PA02',
        'RQO5',
        'PA03',
        'RRYA',
        'RSAZ',
        'PA04',
        'PA05',
        'PA06',
        'PA07',
        'PA08',
        'RSBU',
        'G788',
        'RQLK',
        'RQLU',
        'E186'
		 );
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMMB Error Desc : END------------------
    -----DMMB PD policy Dishonor  Desc : START------------------
    IF (TRIM(i_module_name) = TRIM('DMPD')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQO7', 'RQO6');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMMB PD policy Dishonor Error Desc : END------------------
    -----DMPH PH policy history : START------------------
    IF (TRIM(i_module_name) = TRIM('DMPH')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQO7',
                                'RQO6',
                                'RQLT',
                                'RQOA',
                                'RQLN',
                                'RQLO',
                                'RQQ1',
                                'RQNJ',
                                'RFTQ',
                                'RQNK',
                                'RQNL',
                                'F826',
								'RQLM', 
								'RQNY',
								'RQM1',
								'E186',
								'RQLL',
								'E631',
								'RSAZ'
								);
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMPH PH policy history Error Desc : END------------------
    -----DMRF : START------------------
    IF (TRIM(i_module_name) = TRIM('DMRF')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQOJ',
                                'RQMB',
                                'RQLT',
                                'RQOB',
                                'RQOC',
                                'Z108',
                                'RQOF',
                                'RQOG',
                                'Z035',
                                'RQM8',
                                'RQOH',
								'RQOM',
								'RQON',
								'RQOO',
								'RQOP',
                                'RQOI',
                                'RQLU',
                                'RQM3',
                                'RQMD',
                                'RQN1',
                                'RQNI',
                                'RQLK',
                                'RQMF',
                                'RQOE',
                                'RQOD',
                                'RQWJ');
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMRF : END------------------
	
	-----DMPC : START---------------- 
    IF (TRIM(i_module_name) = TRIM('DMPC')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQNZ','RQLU','E315','RSAZ','RQO6', 'RQO7');
         
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----DMPC : END------------------	
	
	-----RWRD : START---------------- 
    IF (TRIM(i_module_name) = TRIM('RWRD')) THEN
      Select eroreror, erordesc
        BULK COLLECT
        into errorlist
        from  Jd1dta.ERORPF
       WHERE TRIM(ERORLANG) = TRIM('E')
         AND TRIM(ERORDESC) IS NOT NULL
         AND TRIM(EROREROR) IN ('RQW3','W247','RQNW','RQLP','RSBU', 'RQO6', 'RQRN','RQMB');
         
      FOR indexerror IN errorlist.first .. errorlist.last LOOP
        o_errortext(TRIM(errorlist(indexerror).errorcode)) := TRIM(errorlist(indexerror)
                                                                   .errordesc);
      END LOOP;
    END IF;
    -----RWRD : END------------------	
	
  END;

  --****************geterrordesc: END ************************************************

  --****************insertintozdoe: START *********************************************

  PROCEDURE insertintozdoe(i_zdoe_info IN obj_zdoe) IS

    -- v_zdoeddl       clob;
    v_sqlQuery VARCHAR2(4000);
    v_ddlquery VARCHAR2(500);
    --v_pkconstraint VARCHAR2(500);
    v_RECIDX NUMBER(27) DEFAULT 0;
  BEGIN
    --   dbms_output.put_line('i_zdoe_info -->' || i_zdoe_info.i_prefix);

    /* IF (TRIM(i_zdoe_info.i_tablecnt) = 0) THEN
      v_ddlquery := 'CREATE TABLE Jd1dta.' || i_zdoe_info.i_tableName ||
                    ' AS (SELECT * FROM Jd1dta.ZDOEPF)';
      EXECUTE IMMEDIATE v_ddlquery;
      \*  v_pkconstraint := 'alter TABLE Jd1dta.' || v_tableName ||
      ' add constraint ' || 'PK_' || v_tableName ||
      ' primary key (RECIDXOKEROR)';*\
      --   dbms_output.put_line('v_pkconstraint==>' || v_pkconstraint);
      --  EXECUTE IMMEDIATE v_pkconstraint;
    END IF;*/

    --select Jd1dta.SEQ_ZDOEPF.nextval into v_RECIDX from dual;
    --JD EXP
    v_RECIDX := Jd1dta.SEQ_ZDOEPF.nextval;
    v_sqlQuery := 'INSERT INTO Jd1dta.' || i_zdoe_info.i_tableName ||
                  '     (RECIDXOKEROR , RECSTATUS, ZREFKEY, EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,ZFILENME )
values (' || v_RECIDX || ',' || '''NEW''' || ',''' ||
                  i_zdoe_info.i_refKey || ''',''' || i_zdoe_info.i_error01 ||
                  ''',''' || i_zdoe_info.i_errormsg01 || ''',''' ||
                  i_zdoe_info.i_errorfield01 || ''',''' ||
                  i_zdoe_info.i_fieldvalue01 || ''',''' ||
                  i_zdoe_info.i_errorprogram01 || ''',''' ||
                  i_zdoe_info.i_error02 || ''',''' ||
                  i_zdoe_info.i_errormsg02 || ''',''' ||
                  i_zdoe_info.i_errorfield02 || ''',''' ||
                  i_zdoe_info.i_fieldvalue02 || ''',''' ||
                  i_zdoe_info.i_errorprogram02 || ''',''' ||
                  i_zdoe_info.i_error03 || ''',''' ||
                  i_zdoe_info.i_errormsg03 || ''',''' ||
                  i_zdoe_info.i_errorfield03 || ''',''' ||
                  i_zdoe_info.i_fieldvalue03 || ''',''' ||
                  i_zdoe_info.i_errorprogram03 || ''',''' ||
                  i_zdoe_info.i_error04 || ''',''' ||
                  i_zdoe_info.i_errormsg04 || ''',''' ||
                  i_zdoe_info.i_errorfield04 || ''',''' ||
                  i_zdoe_info.i_fieldvalue04 || ''',''' ||
                  i_zdoe_info.i_errorprogram04 || ''',''' ||
                  i_zdoe_info.i_error05 || ''',''' ||
                  i_zdoe_info.i_errormsg05 || ''',''' ||
                  i_zdoe_info.i_errorfield05 || ''',''' ||
                  i_zdoe_info.i_fieldvalue05 || ''',''' ||
                  i_zdoe_info.i_errorprogram05 || ''',''' ||
                  i_zdoe_info.i_scheduleno || ''',''' ||
                  i_zdoe_info.i_indic || ''',''' || i_zdoe_info.i_zfilename || '''' || ')';

    EXECUTE IMMEDIATE v_sqlQuery;

  END;
  --****************insertintozdoe: END *********************************************

/* PROCEDURE tempbulk(i_itemName IN VARCHAR2,
                     i_company  IN varchar2,
                     ais_array  OUT v_array)

   IS
  BEGIN

    Select itemtabl, ITEMITEM
      BULK COLLECT
      into ais_array
      from ITEMPF
     where ITEMTABL = 'T3643'
       and ITEMPFX = 'IT';
    dbms_output.put_line('v_pkconstraint==>');
  END;*/

   --***************************************************getdefval:START*****************************************************

   PROCEDURE getdefval(i_module_name IN VARCHAR2,
                         o_defaultvalues OUT defaultvaluesmap)

   is

    indexdefval PLS_INTEGER;
    TYPE obj_defval IS RECORD(
      defvalcode Jd1dta.DMDEFVALPF.KEYCOL%type,
      defvaldesc Jd1dta.DMDEFVALPF.VALCOL%type);
    TYPE v_array IS TABLE OF obj_defval;
    defvallist v_array;

  BEGIN


   select KEYCOL,VALCOL 
    BULK COLLECT
        into defvallist
		from Jd1dta.DMDEFVALPF
where trim(moduleid)=trim(i_module_name) ;


      FOR indexdefval IN defvallist.first .. defvallist.last LOOP
        o_defaultvalues(TRIM(defvallist(indexdefval).defvalcode)) := TRIM(defvallist(indexdefval)
                                                                   .defvaldesc);
      END LOOP;

  END;
  --***************************************************getdefval:END*****************************************************

end PKG_DM_COMMON_OPERATIONS;
/