  CREATE OR REPLACE EDITIONABLE PACKAGE "Jd1dta"."PKG_DM_AGENCY" as

  TYPE obj_itempf IS RECORD(
    v_accountclass  VARCHAR2(5),
    v_arcon         VARCHAR2(5),
    v_statementreqd VARCHAR2(5));

  TYPE itemschec IS TABLE OF obj_itempf INDEX BY VARCHAR2(16);

  PROCEDURE getitemvalue(itemexist OUT itemschec);

TYPE zigvaluetype IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype);

end PKG_DM_AGENCY;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "Jd1dta"."PKG_DM_AGENCY" as
  PROCEDURE getitemvalue(itemexist OUT itemschec)
  
   is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_table   itempf.itemtabl%type,
      i_item    itempf.itemitem%type,
      i_company itempf.itemcoy%type,
      i_genarea itempf.genarea%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    Select itemtabl, ITEMITEM, itemcoy, genarea
      BULK COLLECT
      into itempflist
      from itempf
     where TRIM(itemtabl) IN ('TQ9B6', 'TQ9Q9', 'T3595', 'T3692', 'T1692')
       and TRIM(itemcoy) IN (1, 9)
       and TRIM(itempfx) = 'IT';

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).v_accountclass := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                              .i_genarea),
                                                                                                                                                                     1,
                                                                                                                                                                     3));

      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).v_arcon := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                       .i_genarea),
                                                                                                                                                              34,
                                                                                                                                                              2));
      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).v_statementreqd := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                               .i_genarea),
                                                                                                                                                                      66,
                                                                                                                                                                      2));

    END LOOP;

  END;
  
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
      from Jd1dta.PAZDCLPF;

    FOR indexitems IN zigvaluelist.first .. zigvaluelist.last LOOP
      getzigvalue(TRIM(zigvaluelist(indexitems).zentity)) := TRIM(zigvaluelist(indexitems)
                                                                  .zigvalue);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      getzigvalue(' ') := TRIM(' ');
  END;
end PKG_DM_AGENCY;





/
-------------------