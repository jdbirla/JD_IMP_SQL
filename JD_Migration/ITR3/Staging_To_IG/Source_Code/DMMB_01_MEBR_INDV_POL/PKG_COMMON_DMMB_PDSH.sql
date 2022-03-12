 CREATE OR REPLACE EDITIONABLE PACKAGE "Jd1dta"."PKG_COMMON_DMMB_PDSH" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB_PDSH
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMMB Policy TSD
  **************************************************************************************************************************/

  -----------Get zpgptodt from GCHPPF :START--------
  TYPE zpgptype IS TABLE OF NUMBER(8) INDEX BY VARCHAR2(15);
  PROCEDURE getzpgptodt(getzpgptodt OUT zpgptype);
  -----------Get zpgptodt from GCHPPF :END--------
  -----------Get Policy:START--------
   TYPE obj_gchd IS RECORD(
    ZPRVCHDR VARCHAR2(8),
    CHDRNUM VARCHAR2(8)
    );
  TYPE gchdtype IS TABLE OF obj_gchd INDEX BY VARCHAR2(10);
  PROCEDURE getpolicy(getgchd OUT gchdtype);
  -----------Get Policy:END--------
---- Check  policy:START-----------
  TYPE polduplicatetype IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkpoldup(checkpoldup OUT polduplicatetype);
  ---- Check  policy:END----------
  -----------Get Prefix:START--------
   TYPE obj_zdrp IS RECORD(
    CHDRNUM VARCHAR2(8),
    PREFIX VARCHAR2(2)
    );
TYPE zdrptype IS TABLE OF obj_zdrp INDEX BY VARCHAR2(10);
  PROCEDURE getPAZDRPPF(getzdrp OUT zdrptype);
  -----------Get Prefix:END--------
  -----------Check if Policy is ZPRVCHDR:START--------
   TYPE obj_ZPRV IS RECORD(
    CHDRNUM VARCHAR(8),
    ZPRVCHDR VARCHAR2(8)
    );
TYPE zprvtype IS TABLE OF obj_zprv INDEX BY VARCHAR2(16);
  PROCEDURE checkzprv(chkzprv OUT zprvtype);
  -----------Get Check if Policy is ZPRVCHDR:END--------
  -----------Get oldchdrnum from PAZDPDPF :START--------
  TYPE obj_zdpd IS RECORD(
    OLDCHDRNUM VARCHAR2(8)
    );

  TYPE zdpdtype IS TABLE OF obj_zdpd INDEX BY VARCHAR2(10);
  PROCEDURE getPAZDPDPF(getzdpd OUT zdpdtype);
  -----------Get oldchdrnum from PAZDPDPF :END----------
end PKG_COMMON_DMMB_PDSH;

/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "Jd1dta"."PKG_COMMON_DMMB_PDSH" as
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB_PDSH
  * Author           : Jitendra Birla
  * Creation Date    : December 15, 2017
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are using in DMMB TSD
  **************************************************************************************************************************/
  -----------Get zpgptodt from GCHPPF :START--------
  PROCEDURE getzpgptodt(getzpgptodt OUT zpgptype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum  GCHPPF.CHDRNUM%type,
      i_company  GCHPPF.CHDRCOY%type,
      i_zpgptodt GCHPPF.ZPGPTODT%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select CHDRNUM, CHDRCOY, ZPGPTODT
      BULK COLLECT
      into itempflist
      from GCHPPF
     where TRIM(CHDRCOY) IN ('1');

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      getzpgptodt(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
                                                                                                            .i_zpgptodt);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
 getzpgptodt(' ') := TRIM(' ');
  END;
  -----------Get zpgptodt from GCHPPF :END--------
  --------------Get Policy:START--------
     PROCEDURE getpolicy(getgchd OUT gchdtype) is
    indexitems PLS_INTEGER;
    TYPE obj_gchd IS RECORD(
      i_zprvchdr gchd.ZPRVCHDR%type,
      i_chdrnum  gchd.CHDRNUM%type);
    TYPE v_array IS TABLE OF obj_gchd;
    gchdlist v_array;

  BEGIN

    select ZPRVCHDR, CHDRNUM
      BULK COLLECT
      into gchdlist
      from GCHD
     where TRIM(CHDRPFX) = TRIM('CH')
       AND TRIM(CHDRCOY) = TRIM('1')
       AND ZPRVCHDR != ' ' AND ZPRVCHDR IS NOT NULL;
    FOR indexitems IN gchdlist.first .. gchdlist.last LOOP
      getgchd(TRIM(gchdlist(indexitems).i_zprvchdr)).ZPRVCHDR := TRIM(gchdlist(indexitems).i_zprvchdr);
	    getgchd(TRIM(gchdlist(indexitems).i_zprvchdr)).CHDRNUM := TRIM(gchdlist(indexitems).i_chdrnum);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
  getgchd(' ').ZPRVCHDR  := TRIM(' ');
  getgchd(' ').CHDRNUM  := TRIM(' ');
  END;
  -----------Get Policy:END--------
   -------Check Duplicate policy : START-----------
  PROCEDURE checkpoldup(checkpoldup OUT polduplicatetype) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_chdrnum ZUCLPF.CHDRNUM%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select CHDRNUM BULK COLLECT into itempflist from ZUCLPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkpoldup(TRIM(itempflist(indexitems).i_chdrnum)) := TRIM(itempflist(indexitems)
                                                                  .i_chdrnum);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkpoldup(' ') := TRIM(' ');
  END;
  -------Check Duplicate policy : END-----------
  -----------Get Prefix:START--------
  PROCEDURE getPAZDRPPF(getzdrp OUT zdrptype) is
    indexitems PLS_INTEGER;
    TYPE obj_zdrp IS RECORD(
      i_chdrnum  PAZDRPPF.CHDRNUM%type,
      i_prefix   PAZDRPPF.PREFIX%type);
    TYPE v_array IS TABLE OF obj_zdrp;
    zdrplist v_array;

  BEGIN

    select CHDRNUM, PREFIX
      BULK COLLECT
      into zdrplist
      from PAZDRPPF;
    FOR indexitems IN zdrplist.first .. zdrplist.last LOOP
      getzdrp(TRIM(zdrplist(indexitems).i_chdrnum)).PREFIX := TRIM(zdrplist(indexitems).i_prefix);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
getzdrp(' ').PREFIX  := TRIM(' ');
  END;
  -----------Get Prefix:END--------
  
  -----------Check if Policy is ZPRVCHDR:START--------
  PROCEDURE checkzprv(chkzprv OUT zprvtype) is
    indexitems PLS_INTEGER;
    TYPE obj_zprv IS RECORD(
      i_chdrnum  gchd.CHDRNUM%type,
      i_zprvchdr gchd.ZPRVCHDR%type);
    TYPE v_array IS TABLE OF obj_zprv;
    zprvlist v_array;

  BEGIN

    select CHDRNUM, ZPRVCHDR
      BULK COLLECT
      into zprvlist
      from GCHD
     where TRIM(CHDRPFX) = TRIM('CH')
       AND TRIM(CHDRCOY) = TRIM('1')
       AND TRIM(ZPRVCHDR) IS NOT NULL;
    FOR indexitems IN zprvlist.first .. zprvlist.last LOOP
      chkzprv(TRIM(zprvlist(indexitems).i_zprvchdr)).zprvchdr := TRIM(zprvlist(indexitems).i_chdrnum);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
 chkzprv(' ').CHDRNUM := TRIM(' ');
  END;
  -----------Get Policy:END--------
  
  -------------Get PAZDPDPF:START--------
  PROCEDURE getPAZDPDPF(getzdpd OUT zdpdtype) is
    indexitems PLS_INTEGER;
    TYPE obj_zdpd IS RECORD(
      i_oldchdrnum  PAZDPDPF.OLDCHDRNUM%type);
    TYPE v_array IS TABLE OF obj_zdpd;
    zdpdlist v_array;

  BEGIN

    select OLDCHDRNUM
      BULK COLLECT
      into zdpdlist
      from PAZDPDPF;
    FOR indexitems IN zdpdlist.first .. zdpdlist.last LOOP
      getzdpd(TRIM(zdpdlist(indexitems).i_oldchdrnum)).OLDCHDRNUM := TRIM(zdpdlist(indexitems).i_oldchdrnum);
     END LOOP;
EXCEPTION
WHEN OTHERS THEN
 getzdpd(' ').OLDCHDRNUM := TRIM(' ');
  END;
  -----------Get PAZDPDPF:END--------
  
end PKG_COMMON_DMMB_PDSH;

/
-----