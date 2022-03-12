CREATE OR REPLACE EDITIONABLE PACKAGE "Jd1dta"."PKG_COMMON_DMMB" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMMB Policy TSD
  **************************************************************************************************************************/
  ----ITEMPF Check:START-----------
  TYPE obj_itempf IS RECORD(
    template VARCHAR2(8),
    currency VARCHAR2(3),
    timech01 VARCHAR2(5),
    timech02 VARCHAR2(5),
    bnkacctyp VARCHAR2(2)); -- MB3

  TYPE itemschec IS TABLE OF obj_itempf INDEX BY VARCHAR2(16);

  PROCEDURE getitemvalue(
                         --i_company_Name IN VARCHAR2,
                         itemexist OUT itemschec);

  ----ITEMPF Check:END-----------
  ----P2 Check:START-----------
  TYPE refnumtype IS TABLE OF VARCHAR2(15) INDEX BY VARCHAR2(15);
  PROCEDURE checkrefnum(checkrefnum OUT refnumtype);
  ----P2 Check:END-----------
  ----PAZDCLPF Check:START-----------
  TYPE zigvaluetype IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE getzigvalue(getzigvalue OUT zigvaluetype);
  ----PAZDCLPF Check:END-----------
  ----ZSLPPF Check:START-----------
  TYPE salplantype IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
  PROCEDURE checksalplan(checksalplan OUT salplantype);
  ----ZSLPPF Check:END-----------
  ----ZSLPPF Get:START-----------
  TYPE zinstype IS TABLE OF VARCHAR2(3) INDEX BY VARCHAR2(34);
  PROCEDURE getzinstype(getzinstype OUT zinstype);
  ----ZSLPPF Get:END-----------
  /*----Polanv Get:START-----------
  TYPE plolanvtype IS TABLE OF VARCHAR(8) INDEX BY VARCHAR2(9);
  PROCEDURE getpolanv(getpolanv OUT plolanvtype);
  ----Polanv Get:END----------- */
  -----------Get DFPO:START--------
  TYPE dfpopftype IS TABLE OF DFPOPF%rowtype INDEX BY VARCHAR2(8);
  PROCEDURE getdfpo(getdfpo OUT dfpopftype);
  -----------Get DFPO:END--------
  -----------Get CLBAPF:START--------
  TYPE clbatype IS TABLE OF CLBAPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getclba(getclba OUT clbatype);
  -----------Get CLBAPF:END--------
  -----------Get Policy:START--------
  TYPE gchdtype IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(15);
  PROCEDURE checkpolicy(checkchdrnum OUT gchdtype);
  -----------Get Policy:END--------
  -----------Check Endorser:START--------
  TYPE checkzendcde IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE checkendorser(zendcde OUT checkzendcde);
  -----------Get Endorser:END--------
  -----------Check Campcode:START--------
  TYPE checkcampcode IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE checkcampcde(campcode OUT checkcampcode);
  -----------Get Campcode:END--------
  -----------Get ZCMPCODE  ZSOLCTFLG from GCHIPF :START--------
  TYPE mpoltype IS TABLE OF IG_DM_MASTERPOL%rowtype INDEX BY VARCHAR2(50);
  PROCEDURE getmpolinfo(getmpol OUT mpoltype);
  -----------Get ZCMPCODE  from GCHIPF :END--------
  -----------Get Clinet info   :START--------
  TYPE clntpftype IS TABLE OF CLNTPF%rowtype INDEX BY VARCHAR2(50);
  PROCEDURE getclientinfo(getclntinfo OUT clntpftype);
  -----------Get Clinet info  :END--------
   ---- Check master ploicy:START-----------
  TYPE polduplicatetype IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkpoldup(checkpoldup OUT polduplicatetype);
  ---- Check master ploicy:END----------
  -------------get DOB------------
  TYPE getclntdob IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE checkclntDOB(clntdob OUT getclntdob);
  -------------get DOB------------
 -----------Get P1 records   :START--------
  TYPE obj_mbrp1 IS RECORD(
    refnum    TITDMGMBRINDp1.refnum@DMSTAGEDBLINK%type,
    cnttypind TITDMGMBRINDp1.cnttypind@DMSTAGEDBLINK%type,
    mpolnum   TITDMGMBRINDp1.mpolnum@DMSTAGEDBLINK%type,
    statcode  TITDMGMBRINDp1.statcode@DMSTAGEDBLINK%type,
    dtetrm    TITDMGMBRINDp1.dtetrm@DMSTAGEDBLINK%type,
    zplancde  TITDMGMBRINDp1.zplancde@DMSTAGEDBLINK%type,
    ZWAITPEDT TITDMGMBRINDp1.ZWAITPEDT@DMSTAGEDBLINK%type,
    effdate   TITDMGMBRINDp1.effdate@DMSTAGEDBLINK%type,
    zpoltdate TITDMGMBRINDp1.zpoltdate@DMSTAGEDBLINK%type,
    zpdatatxflag TITDMGMBRINDp1.ZPDATATXFLG@DMSTAGEDBLINK%type,
    ztrxstat  TITDMGMBRINDp1.ztrxstat@DMSTAGEDBLINK%type);

  TYPE mbrinfotype IS TABLE OF obj_mbrp1 INDEX BY VARCHAR2(16);
  PROCEDURE getmbrp1info(mbrp1info OUT mbrinfotype);
  -----------Get P1 records  :END--------

  -- MB3: get facthouse from ZENDRPF : START ---
  TYPE zendfacthouse IS TABLE OF VARCHAR2(2) INDEX BY VARCHAR2(20);
  PROCEDURE getfacthouse(facthouse OUT zendfacthouse);
  -- MB3: get facthouse from zendrpf : END ---

end PKG_COMMON_DMMB;


/

 CREATE OR REPLACE EDITIONABLE PACKAGE BODY "Jd1dta"."PKG_COMMON_DMMB" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMMB TSD
  **************************************************************************************************************************/

  ----ITEMPF Check:START-----------

  PROCEDURE getitemvalue(
                         --i_company_Name IN VARCHAR2,
                         itemexist OUT itemschec)

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
     where TRIM(itemtabl) IN ('TQ9FK',
                              'TQ9GX',
                              'T9775',
                              'TQ9FW',
                              'T3584',
                              'TQ9FT',
                              'TQ9FU',
                              'T9797',
                              'T3684') -- MB3: to get bnkacctyp
       and TRIM(itemcoy) IN (1, 9)
       and TRIM(itempfx) = 'IT';

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).template := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                        .i_genarea),
                                                                                                                                                               9,
                                                                                                                                                               8));

      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).currency := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                        .i_genarea),
                                                                                                                                                               0,
                                                                                                                                                               3));
      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).timech01 := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                        .i_genarea),
                                                                                                                                                               0,
                                                                                                                                                               5));

      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).timech02 := TRIM(SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems)
                                                                                                                                                                                        .i_genarea),
                                                                                                                                                               6,
                                                                                                                                                               5));
      -- MB3                                                                                                                                                         
      itemexist(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)).bnkacctyp := SUBSTR(utl_raw.cast_to_varchar2(itempflist(indexitems).i_genarea),196,2);

    END LOOP;

  END;
  ----ITEMPF Check:END-----------
  ----P2 Check:START-----------
  PROCEDURE checkrefnum(checkrefnum OUT refnumtype) is
    indexitems PLS_INTEGER;
    TYPE obj_p2 IS RECORD(
      refnum TITDMGMBRINDP2.REFNUM@DMSTAGEDBLINK%type);
    TYPE v_array IS TABLE OF obj_p2;
    refprodlist v_array;
  BEGIN

    Select REFNUM
      BULK COLLECT
      into refprodlist
      from TITDMGMBRINDP2@DMSTAGEDBLINK;

    FOR indexitems IN refprodlist.first .. refprodlist.last LOOP
      checkrefnum(TRIM(refprodlist(indexitems).refnum)) := TRIM(refprodlist(indexitems)
                                                                .refnum);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkrefnum(' ') := TRIM(' ');
  END;
  ----P2 Check:END-----------
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
      from Jd1dta.PAZDCLPF;

    FOR indexitems IN zigvaluelist.first .. zigvaluelist.last LOOP
      getzigvalue(TRIM(zigvaluelist(indexitems).zentity)) := TRIM(zigvaluelist(indexitems)
                                                                  .zigvalue);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      getzigvalue(' ') := TRIM(' ');
  END;
  ----PAZDCLPF Check:END-----------
  ----ZSLPPF Check:START-----------
  PROCEDURE checksalplan(checksalplan OUT salplantype) is
    indexsal PLS_INTEGER;
    TYPE obj_salplan IS RECORD(
      zsalplan ZSLPPF.ZSALPLAN%type);
    TYPE v_array IS TABLE OF obj_salplan;
    salplanlist v_array;
  BEGIN

    Select ZSALPLAN BULK COLLECT into salplanlist from Jd1dta.ZSLPPF;

    FOR indexsal IN salplanlist.first .. salplanlist.last LOOP
      checksalplan(TRIM(salplanlist(indexsal).zsalplan)) := TRIM(salplanlist(indexsal)
                                                                 .zsalplan);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checksalplan(' ') := TRIM(' ');
  END;

  ----ZSLPPF Check:END-----------
  ----ZSLPPF get:START-----------
  PROCEDURE getzinstype(getzinstype OUT zinstype) is
    indexzins PLS_INTEGER;
    TYPE obj_zinstype IS RECORD(
      zinstype ZSLPPF.ZINSTYPE%type,
      prodtyp  ZSLPPF.PRODTYP%type,
      zsalplan ZSLPPF.ZSALPLAN%type);
    TYPE v_array IS TABLE OF obj_zinstype;
    zinstypelist v_array;
  BEGIN

    Select zinstype, prodtyp, ZSALPLAN
      BULK COLLECT
      into zinstypelist
      from Jd1dta.ZSLPPF;

    FOR indexzins IN zinstypelist.first .. zinstypelist.last LOOP
      getzinstype(TRIM(zinstypelist(indexzins).zsalplan) || TRIM(zinstypelist(indexzins).prodtyp)) := TRIM(zinstypelist(indexzins)
                                                                                                           .zinstype);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      getzinstype(' ') := TRIM(' ');
  END;

  ----ZSLPPF get:END-----------
  /*----Polanv get:START-----------
   PROCEDURE getpolanv(getpolanv OUT plolanvtype)IS
      indexpola PLS_INTEGER;
      TYPE obj_polanv IS RECORD(
        CHDRCOY GCHPPF.CHDRCOY%type,
        CHDRNUM  GCHPPF.CHDRNUM%type,
        POLANV GCHPPF.POLANV%type);
      TYPE v_array IS TABLE OF obj_polanv;
    polanvlist v_array;
    BEGIN

      Select CHDRCOY, CHDRNUM, POLANV
        BULK COLLECT
        into polanvlist
        from Jd1dta.GCHPPF;


      FOR indexpola IN polanvlist.first .. polanvlist.last LOOP
        getpolanv(NVL((TRIM(polanvlist(indexpola).CHDRNUM) || TRIM(polanvlist(indexpola).CHDRCOY)) , 'NA' )) :=  TRIM(polanvlist(indexpola).POLANV);
     END LOOP;

    END;

  ----Polanv get:END----------- */
  -----------Get DFPO:START--------
  PROCEDURE getdfpo(getdfpo OUT dfpopftype) is
    CURSOR dfpolist IS
      SELECT * FROM DFPOPF;
    obj_dfpo dfpolist%rowtype;

  BEGIN
    OPEN dfpolist;
    <<skipRecord>>
    LOOP
      FETCH dfpolist
        INTO obj_dfpo;
      EXIT WHEN dfpolist%notfound;
      getdfpo(TRIM(obj_dfpo.template)) := obj_dfpo;
    END LOOP;

    CLOSE dfpolist;

  END;
  -----------Get DFPO:END--------
  -----------Get CLBA:START--------
  PROCEDURE getclba(getclba OUT clbatype) is
    CURSOR clbalist IS
      SELECT *
        FROM CLBAPF
       where TRIM(Clntpfx) = TRIM('CN')
         and TRIM(validflag) = TRIM('1')
         and TRIM(bnkactyp) = TRIM('CC');
    obj_clba clbalist%rowtype;

  BEGIN
    OPEN clbalist;
    <<skipRecord>>
    LOOP
      FETCH clbalist
        INTO obj_clba;
      EXIT WHEN clbalist%notfound;
      getclba(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum) || TRIM(obj_clba.clntcoy)) := obj_clba;
    END LOOP;

    CLOSE clbalist;

  END;
  -----------Get CLBA:END--------
  -----------Get Policy:START--------
  PROCEDURE checkpolicy(i_company IN varchar2, checkchdrnum OUT gchdtype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum gchd.CHDRNUM%type,
      i_company gchd.CHDRCOY%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select CHDRNUM, CHDRCOY
      BULK COLLECT
      into itempflist
      from GCHD
     where TRIM(CHDRPFX) = TRIM('CH')
       AND TRIM(CHDRCOY) = TRIM(i_company);
    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkchdrnum(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                             .i_chdrnum);
    END LOOP;

  END;
  -----------Get Policy:END--------
  -----------Get Policy:START--------
  PROCEDURE checkpolicy(checkchdrnum OUT gchdtype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum gchd.CHDRNUM%type,
      i_company gchd.CHDRCOY%type);
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
      checkchdrnum(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                             .i_chdrnum);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkchdrnum(' ') := TRIM(' ');

  END;
  -----------Get Policy:END--------
  -----------Check Endorser:START--------
  PROCEDURE checkendorser(zendcde OUT checkzendcde) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zendcde ZENDRPF.Zendcde%type,
      i_zclntid ZENDRPF.zclntid%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select Zendcde, zclntid BULK COLLECT into itempflist from zendrpf;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      zendcde(TRIM(itempflist(indexitems).i_zendcde)) := TRIM(itempflist(indexitems)
                                                              .i_zclntid);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      zendcde(' ') := TRIM(' ');
  END;
  -----------Check Endorser:END--------

  -----------Check Endorser:START--------
  PROCEDURE checkcampcde(campcode OUT checkcampcode) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zcmpcode ZCPNPF.ZCMPCODE%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select ZCMPCODE BULK COLLECT into itempflist from Zcpnpf;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      campcode(TRIM(itempflist(indexitems).i_zcmpcode)) := TRIM(itempflist(indexitems)
                                                                .i_zcmpcode);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      campcode(' ') := TRIM(' ');

  END;
  -----------Check Endorser:END--------
  -------------Get Mpol Information-------
  PROCEDURE getmpolinfo(getmpol OUT mpoltype) is
    CURSOR mpollist IS
      SELECT * FROM IG_DM_MASTERPOL;

    obj_mpol mpollist%rowtype;

  BEGIN
    OPEN mpollist;
    <<skipRecord>>
    LOOP
      FETCH mpollist
        INTO obj_mpol;
      EXIT WHEN mpollist%notfound;
      getmpol(TRIM(obj_mpol.chdrnum)) := obj_mpol;
    END LOOP;

    CLOSE mpollist;

  END;
  -------------Get Mpol Information-------
 -------------Get clntpf Information-------
  PROCEDURE getclientinfo(getclntinfo OUT clntpftype) is
    CURSOR clntlist IS
      SELECT * FROM CLNTPF;

    obj_clnt clntlist%rowtype;

  BEGIN
    OPEN clntlist;
    <<skipRecord>>
    LOOP
      FETCH clntlist
        INTO obj_clnt;
      EXIT WHEN clntlist%notfound;
      getclntinfo(TRIM(obj_clnt.clntnum)) := obj_clnt;

    END LOOP;

    CLOSE clntlist;

  END;
  -------------Get clntpf Information-------
   -------Check Duplicate policy : START-----------
  PROCEDURE checkpoldup(checkpoldup OUT polduplicatetype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum PAZDRPPF.CHDRNUM%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select CHDRNUM
      BULK COLLECT
      into itempflist
      from PAZDRPPF
     where TRIM(prefix) IN ('MB', 'IN');

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkpoldup(TRIM(itempflist(indexitems).i_chdrnum)) := TRIM(itempflist(indexitems)
                                                                  .i_chdrnum);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkpoldup(' ') := TRIM(' ');
  END;
  -------Check Duplicate policy : END-----------
  ------------get CLNT DOB-------------
  PROCEDURE checkclntDOB(clntdob OUT getclntdob) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_clntnum CLNTPF.clntnum%type,
      i_cltdob  CLNTPF.Cltdob%type

      );
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select clntnum, Cltdob BULK COLLECT into itempflist from CLNTPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      clntdob(TRIM(itempflist(indexitems).i_clntnum)) := TRIM(itempflist(indexitems)
                                                              .i_cltdob);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      clntdob(' ') := TRIM(' ');

  END;

---------------------GET CLNT DOB-------
 -------------Get mbr p1 Information-------

  PROCEDURE getmbrp1info(
                         --i_company_Name IN VARCHAR2,
                         mbrp1info OUT mbrinfotype)

   is
    indexitems PLS_INTEGER;
    TYPE obj_mbrp1 IS RECORD(
      i_refnum    TITDMGMBRINDp1.refnum@DMSTAGEDBLINK%type,
      i_cnttypind TITDMGMBRINDp1.cnttypind@DMSTAGEDBLINK%type,
      i_mpolnum   TITDMGMBRINDp1.mpolnum@DMSTAGEDBLINK%type,
      i_statcode  TITDMGMBRINDp1.statcode@DMSTAGEDBLINK%type,
      i_dtetrm    TITDMGMBRINDp1.dtetrm@DMSTAGEDBLINK%type,
      i_zplancde  TITDMGMBRINDp1.zplancde@DMSTAGEDBLINK%type,
      i_ZWAITPEDT TITDMGMBRINDp1.ZWAITPEDT@DMSTAGEDBLINK%type,
      i_effdate   TITDMGMBRINDp1.effdate@DMSTAGEDBLINK%type,
      i_zpoltdate TITDMGMBRINDp1.zpoltdate@DMSTAGEDBLINK%type,
      i_zpdatatxflag TITDMGMBRINDp1.ZPDATATXFLG@DMSTAGEDBLINK%type,
      i_ztrxstat  TITDMGMBRINDp1.ztrxstat@DMSTAGEDBLINK%type

      );
    TYPE v_array IS TABLE OF obj_mbrp1;
    itempflist v_array;

  BEGIN

    Select
    --SUBSTR(TRIM(refnum), 1, 8),
     refnum,
     cnttypind,
     mpolnum,
     statcode,
     dtetrm,
     zplancde,
     ZWAITPEDT,
     effdate,
     zpoltdate,     
     ZPDATATXFLG,
     ztrxstat

      BULK COLLECT
      into itempflist
      from TITDMGMBRINDp1@DMSTAGEDBLINK;
    --where refnum = '00124625000';

    FOR indexitems IN itempflist.first .. itempflist.last LOOP

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).refnum := TRIM(itempflist(indexitems)
                                                                      .i_refnum);
      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).cnttypind := TRIM(itempflist(indexitems)
                                                                         .i_cnttypind);

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).mpolnum := TRIM(itempflist(indexitems)
                                                                       .i_mpolnum);

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).statcode := TRIM(itempflist(indexitems)
                                                                        .i_statcode);

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).dtetrm := TRIM(itempflist(indexitems)
                                                                      .i_dtetrm);

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).zplancde := TRIM(itempflist(indexitems)
                                                                        .i_zplancde);

      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).ZWAITPEDT := TRIM(itempflist(indexitems)
                                                                         .i_ZWAITPEDT);
      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).effdate := TRIM(itempflist(indexitems)
                                                                       .i_effdate);
      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).zpoltdate := TRIM(itempflist(indexitems)
                                                                       .i_zpoltdate);
      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).zpdatatxflag := TRIM(itempflist(indexitems)
                                                                       .i_zpdatatxflag);
      mbrp1info(TRIM(itempflist(indexitems).i_refnum)).ztrxstat := TRIM(itempflist(indexitems)
                                                                       .i_ztrxstat);

    END LOOP;

  END;
  -------------Get mbr p1 Information-------



  -- MB3: get facthouse from ZENDRPF : START ---
  PROCEDURE getfacthouse(facthouse OUT zendfacthouse) is indexitems PLS_INTEGER;
  TYPE obj_itempf IS RECORD(
      i_zendcde ZENDRPF.Zendcde%type,
      i_zfacthus ZENDRPF.zfacthus%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN
    select Zendcde, zfacthus BULK COLLECT into itempflist from zendrpf;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      facthouse(TRIM(itempflist(indexitems).i_zendcde)) := TRIM(itempflist(indexitems).i_zfacthus);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      facthouse(' ') := TRIM(' ');
  END;
-- MB3: get facthouse from ZENDRPF : END ---

end PKG_COMMON_DMMB;


/