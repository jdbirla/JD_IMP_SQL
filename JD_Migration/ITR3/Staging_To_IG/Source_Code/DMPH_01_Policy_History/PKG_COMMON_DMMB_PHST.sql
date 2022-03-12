create or replace PACKAGE                        "PKG_COMMON_DMMB_PHST" AS
 /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB_PHST
  * Author           : Sachin Chourasiya
  * Creation Date    : January 19, 2018
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are used in DMCM Part-Policy Transaction History
  **************************************************************************************************************************/
  /***************************************************************************************************
  * Amenment History: MB01 Policy Transaction
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   PH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0501     SC    PH2   Performance change for Dm rehearsal.
  * 0502     SC    PH3   LOGIC CHANGED TO GET UNIQUE_NUMBER FROM PAZDCHPF(PREVIOUSLY ZCLNPF).
  * 0504     SC    PH5   CHANGED FOR #7685 - [functional issue]screen validation incorrect. 
  * 0508     SC    PH9   Changes For Ticket #7852 -Incorrect Fields on ZTRAPF 
  * 0516     SK    PH10  Removed unused fields like company   
  * 0518     SK    PH11  Implemented Logic to fetch limited records to avoid PGA memory issue
  *****************************************************************************************************
  **************PA DEVELOPMENT CHANGES**************************************************************  
  * AUG11	 MKS   PH19  For PA Development changes
  * NOV12	 MKS   ZJNPG-8385   Use the EFFDATE of latest TERMINATION transaction to identify value for ZVLDTRXIND instead of GCHD.EFFCLDT.
  **************ITR3 PA DEVELOPMENT CHANGES**************************************************************  
  * FEB02  MKS   PH20   ITR3 PA Development changes
  * FEB16  MKS   PH22   Fix for P2-5569 removal of sub-cmapaign column in gmhd
  *****************************************************************************************************/
------------------ PH11: START Get Chdrnum range to fetch limited records ----------------
v_range_from GCHD.chdrnum%type;
v_range_to   GCHD.chdrnum%type;
PROCEDURE fetch_chdrnum_range;
------------------ PH11: END Get Chdrnum range to fetch limited records ----------------

-------------PH2:START-------------------------------------------------------------------
--DM REHEARSAL PERFORMANCE: START-----------------------------------------------------
-----------Get ZENCDE from GCHPPF:START--------
--  TYPE gchppftype IS TABLE OF VARCHAR2(15) INDEX BY VARCHAR2(15);
--  PROCEDURE checkgchppf(i_company IN varchar2, checkZendcde OUT gchppftype);
-----------Get ZENCDE from GCHPPF:END--------
--DM REHEARSAL PERFORMANCE: END-----------------------------------------------------
-------------PH2:END-------------------------------------------------------------------

-----------Get PAZDCLPF Data :START--------
-- PH12: commented as not required: discussed with Patrice May16
  TYPE OBJ_PAZDCLPF IS RECORD (
	zentity		PAZDCLPF.ZENTITY%type,
	zigvalue 	PAZDCLPF.ZIGVALUE%type);

  TYPE pazdclpftype IS TABLE OF OBJ_PAZDCLPF INDEX BY VARCHAR2(50);
  PROCEDURE checkzdclpf(checkzdclpf OUT pazdclpftype);
-----------Get PAZDCLPF Data:END--------
  -----------Get CLBAPF FOR CREDIT CARD:START--------
  /*TYPE clbatype IS TABLE OF CLBAPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getclbaforcc(getclbaforcc OUT clbatype);
  -----------Get CLBAPF:END--------
    -----------Get CLBAPF FOR BANK:START--------
  TYPE clbatype1 IS TABLE OF CLBAPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getclbaforbnk(getclbaforbnk OUT clbatype1); */
  -----------Get CLBAPF:END--------
  -----------Get Policy:START--------
/*  TYPE gchdtype1 IS TABLE OF GCHD%rowtype INDEX BY VARCHAR2(9);
  PROCEDURE getgchd(getgchd OUT gchdtype1);
  */
-----------Get Policy:END--------

--SIT CHANGE START-----
-----------Get ZCMPCODE  ZSOLCTFLG from GCHIPF :START--------
/*  TYPE gchitype IS TABLE OF GCHIPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getgchipf(getgchipf OUT gchitype);  */
-----------Get ZCMPCODE  from GCHIPF :END--------


-----------Get ZCPNSCDE  ZPLANCDE  from GMHIPF:START--------
/*  TYPE gmhitype IS TABLE OF GMHIPF%rowtype INDEX BY VARCHAR2(29);
  PROCEDURE getgmhipf(getgmhipf OUT gmhitype);  */
-----------Get ZCPNSCDE  ZPLANCDE  from GMHIPF:END--------


-----------Get ZCONVINDPOL from GCHPPF:START--------
--  TYPE gchptype IS TABLE OF GCHPPF%rowtype INDEX BY VARCHAR2(29);
--  PROCEDURE getgchppf(getgchppf OUT gchptype);
-----------Get ZCONVINDPOL from GCHPPF:END--------

-----------Get ZSALECHNL from GMHDPF:START--------
--  TYPE gmhdtype IS TABLE OF GMHDPF%rowtype INDEX BY VARCHAR2(29);
--  PROCEDURE getgmhdpf(getgmhdpf OUT gmhdtype);
-----------Get ZSALECHNL from GMHDPF:END--------
---SIT CHANGE END-----
 ---- Check duplicate ploicy:START-----------
  TYPE phduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkcpdup(checkdupl OUT phduplicate);
  ---- Check duplicate ploicy:END----------

--  TYPE OBJ_CLBAPF_TYPE_CC IS RECORD(
--	 clntnum		CLBAPF.clntnum%type,
--	 clntcoy		CLBAPF.clntcoy%type,
--	 bankacckey		CLBAPF.bankacckey%type,
--     mthto          CLBAPF.mthto%type,
--     yearto       CLBAPF.yearto%type   );
-- 
-- 
--  TYPE CLBACCTYPE IS TABLE OF OBJ_CLBAPF_TYPE_CC INDEX BY VARCHAR2(40);
--  PROCEDURE getclbapfccinfo(CLBACCINFO OUT CLBACCTYPE);  

  TYPE OBJ_GCHD IS RECORD(
    chdrnum   GCHD.chdrnum%type,
   -- chdrcoy   GCHD.chdrcoy%type, -- PH10
    cownnum   GCHD.cownnum%type,
    statcode  GCHD.statcode%type,
    tranlused GCHD.tranlused%type,
    mplnum    GCHD.mplnum%type,
    btdate    GCHD.btdate%type, --PH5: ONE MORE COLUMN ADDED BTDATE
	effdcldt  GCHD.effdcldt%type,
	occdate	  GCHD.OCCDATE%type);  --PH19 : ONE MORE COLUMN ADDED effdcldt

  TYPE gchdtype1 IS TABLE OF OBJ_GCHD INDEX BY VARCHAR2(60);
  PROCEDURE getgchd(getgchd OUT gchdtype1);


  /*
      IF (getgchipf.exists(v_chdrnum || TRIM(i_company))) THEN
      obj_gchi    := getgchipf(v_chdrnum || TRIM(i_company));
      v_zcmpcode  := obj_gchi.zcmpcode;
      v_zsolctflg := obj_gchi.zsolctflg;
      v_ccdate    := obj_gchi.ccdate;*/



   TYPE OBJ_GCHI IS RECORD(
    chdrnum   	GCHI.chdrnum%type,
   -- chdrcoy   GCHI.chdrcoy%type, -- PH10
    zcmpcode   	GCHI.zcmpcode%type,
    zsolctflg  	GCHI.zsolctflg%type,
    ccdate     	GCHI.ccdate%type,
	zpolperd   	GCHI.zpolperd%type, --PH19	
    agntnum     GCHI.AGNTNUM%type
	);

  TYPE gchItype1 IS TABLE OF OBJ_GCHI INDEX BY VARCHAR2(60);
  PROCEDURE getgchipf(getgchipf OUT gchItype1);


  TYPE OBJ_GMHI IS RECORD(
    chdrnum   gmhipf.chdrnum%type,
    --chdrcoy    gmhipf.chdrcoy%type, -- PH10
    mbrno     gmhipf.mbrno%type,	
    zplancde  gmhipf.zplancde%type);

    --zplancde   gmhipf.zplancde%type,
    --zcpnscde  gmhipf.zcpnscde%type
    --dcldate    gmhipf.dcldate%type,
    --zdclitem01 gmhipf.zdclitem01%type,
    --zdclitem02 gmhipf.zdclitem02%type,
    --zdeclcat   gmhipf.zdeclcat%type,
    --docrcdte   gmhipf.docrcdte%type,
    --hpropdte   gmhipf.hpropdte%type,
    --zdfcncy    gmhipf.zdfcncy%type,
    --zmargnflg  gmhipf.zmargnflg%type ); -- PH9: Not required anymore for PA

  TYPE gmhitype IS TABLE OF OBJ_GMHI INDEX BY VARCHAR2(60);
  PROCEDURE getgmhipf(getgmhipf OUT gmhitype);

-------------PH2:START-------------------------------------------------------------------
--TICKET- #7540- DM REHEARSAL STARTS-------------------
  TYPE OBJ_GCHP IS RECORD(
    chdrnum       GCHP.chdrnum%type,
    --chdrcoy       GCHP.chdrcoy%type, -- PH10
    --zconvindpol   GCHP.zconvindpol%type,
    zendcde       GCHP.zendcde%type,
    zplancls      GCHP.zplancls%type,
    zpgpfrdt      GCHP.zpgpfrdt%type,
    zpgptodt      GCHP.zpgptodt%type, --PH5 two more column added zpgpfrdt and zpgptodt
    zpoltdate     GCHP.zpoltdate%type,
	zsalechnl	  GCHP.zsalechnl%type); -- PH19 On more column added  "zsalechnl"


  TYPE gchptype IS TABLE OF OBJ_GCHP INDEX BY VARCHAR2(60);
  PROCEDURE getgchppf(getgchppf OUT gchptype);
--TICKET- #7540- DM REHEARSAL ENDS-------------------
-------------PH2:END----------------------------------------------------------------------

  TYPE OBJ_GMHD IS RECORD(
    chdrnum   GMHDPF.chdrnum%type,
    --chdrcoy   gmhd.chdrcoy%type, -- PH10
    --zsalechnl gmhd.zsalechnl%type, --PH19
	mbrno     GMHDPF.mbrno%type, --PH19
--	zcpnscde  GMHDPF.zcpnscde%type, --PH19 --PH22
	dteatt    GMHDPF.dteatt%type    --PH19
    --cltreln   GMHDPF.cltreln%type --PH7: new column added "CLTRELN"-------------------- PH19: This will be direct mapping
	);


  TYPE gmhdtype IS TABLE OF OBJ_GMHD INDEX BY VARCHAR2(60);
  PROCEDURE getgmhdpf(getgmhdpf OUT gmhdtype);

-----------------------CCand Bnk---------------
 -----------Get CLBAPF FOR CREDIT CARD:START--------
  TYPE OBJ_CLBAPF_CC IS RECORD(
    bankacckey clbapf.bankacckey%type,
    clntnum    clbapf.clntnum%type,
    --clntcoy    clbapf.clntcoy%type, -- PH10
    mthto      clbapf.mthto%type,
    yearto     clbapf.yearto%type);
  TYPE clbatype IS TABLE OF OBJ_CLBAPF_CC INDEX BY VARCHAR2(50);
  PROCEDURE getclbaforcc(getclbaforcc OUT clbatype);
  -----------Get CLBAPF:END--------
  -----------Get CLBAPF FOR BANK:START--------
  TYPE OBJ_CLBAPF_BN IS RECORD(
    bankacckey clbapf.bankacckey%type,
    clntnum    clbapf.clntnum%type,
    --clntcoy    clbapf.clntcoy%type, -- PH10
    bankaccdsc clbapf.bankaccdsc%type,
    bnkactyp   clbapf.bnkactyp%type,
    bankkey    clbapf.bankkey%type);
  TYPE clbatype1 IS TABLE OF OBJ_CLBAPF_BN INDEX BY VARCHAR2(60);
  PROCEDURE getclbaforbnk(getclbaforbnk OUT clbatype1);
  -----------Get CLBAPF:END--------

------------------------CC and bnk----------------

-------------PH2:START-------------------------------------------------------------------
-----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START--------
--  TYPE OBJ_ZCLNPF IS RECORD(
--
--        CLNTNUM        ZCLNPF.CLNTNUM%type,
--        CLNTCOY        ZCLNPF.CLNTCOY%type,
--        EFFDATE        ZCLNPF.EFFDATE%type,
--        CLNTPFX        ZCLNPF.CLNTPFX%type,
--        UNIQUE_NUMBER  ZCLNPF.UNIQUE_NUMBER%type);
--
--  TYPE zclnpftype IS TABLE OF OBJ_ZCLNPF INDEX BY VARCHAR2(29);
--  PROCEDURE getzclnpf(getzclnpf OUT zclnpftype); 
-----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END----------
-------------PH2:END-------------------------------------------------------------------

-------------PH2:START-----------------------------------------------------------------
-----------Get ZBNKFLAG, ZCCFLAG from ZENCIPF: DM_REHEARSAL_PERFORMANCE: START----
  TYPE OBJ_ZENCIPF IS RECORD(

        ZENDCDE        ZENCIPF.ZENDCDE%type,
        ZBNKFLAG       ZENCIPF.ZBNKFLAG%type,
        ZCCFLAG        ZENCIPF.ZCCFLAG%type);

  TYPE zencipftype IS TABLE OF OBJ_ZENCIPF INDEX BY VARCHAR2(29);
  PROCEDURE getzencipf(getzencipf OUT zencipftype);

-----------Get ZBNKFLAG, ZCCFLAG from ZENCIPF: DM_REHEARSAL_PERFORMANCE: END-------
-------------PH2:END-------------------------------------------------------------------

-------------PH3:START-------------------------------------------------------------------
-----------Get UNIQUE_NUMBER from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: START--------
  TYPE OBJ_ZDCHPF IS RECORD(

        ZIGVALUE        PAZDCHPF.ZIGVALUE%type,
        ZSEQNO          PAZDCHPF.ZSEQNO%type,
        EFFDATE         PAZDCHPF.EFFDATE%type,
        RECIDXCLNTHIS   PAZDCHPF.RECIDXCLNTHIS%type );

  TYPE zdchpftype IS TABLE OF OBJ_ZDCHPF INDEX BY VARCHAR2(50);
  PROCEDURE getzdchpf(getzdchpf OUT zdchpftype); 
-----------Get UNIQUE_NUMBER from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: END----------
-------------PH3:END-------------------------------------------------------------------
-------------PH9: START-------------------------------------------------------------------
  -------------get CLIENT DOB------------
  TYPE getclntdob IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE checkclntDOB(clntdob OUT getclntdob);
  -------------get CLIENT DOB------------
-------------PH9: END--------------------------------------------------------------------
-----------PH16:Get converted pol list:START--------
  TYPE conpoltype IS TABLE OF CONV_POL_HIST%rowtype INDEX BY VARCHAR2(50);
  PROCEDURE getconpolinfo(getconpol OUT conpoltype);
-----------PH16:Get converted pol list :END--------

  -----------PH19: Get TQ9MP TERM START----
  TYPE OBJ_TQ9MP IS RECORD(
		ITEMITEM	itempf.ITEMITEM%type,
		ZRCALTTY	VARCHAR(5));
  TYPE tq9mptype IS TABLE OF OBJ_TQ9MP INDEX BY VARCHAR2(60);
  PROCEDURE gettq9mp(gettq9mp OUT tq9mptype);
  -----------PH19: Get TQ9MP TERM END----

  -----------Check Campcode:START--------
  TYPE checkcampcode IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
  PROCEDURE checkcampcde(campcode OUT checkcampcode);
  -----------Get Campcode:END--------

  -----------PH19: Get Tranno of New Business  START----
  TYPE OBJ_NEWBTRAN IS RECORD(
		CHDRNUM		ztrapf.CHDRNUM%type,
		TRANNO		ztrapf.TRANNO%type);
  TYPE newbtrantype IS TABLE OF OBJ_NEWBTRAN INDEX BY VARCHAR2(30);
  PROCEDURE getnewbtran(getnewbtran OUT newbtrantype);
  -----------PH19: Get Tranno of New Business END----

  -----------PH19: Get Tranno of Cancellation  START----
  TYPE OBJ_CNCLTRAN IS RECORD(
		CHDRNUM		ztrapf.CHDRNUM%type,
		TRANNO		ztrapf.TRANNO%type,
    EFFDATE		ztrapf.EFFDATE%type);
  TYPE cancltrantype IS TABLE OF OBJ_CNCLTRAN INDEX BY VARCHAR2(50);
  PROCEDURE getcancltran(getcancltran OUT cancltrantype);
  -----------PH19: Get Tranno of New Business END----  

  -----------PH19: Get Insured Role  START----
  TYPE OBJ_ZINSROLE IS RECORD(
		CHDRNUM		ZINSDTLSPF.CHDRNUM%type,
		MBRNO		ZINSDTLSPF.MBRNO%type,
		DPNTNO		ZINSDTLSPF.DPNTNO%type,
		ZINSROLE	ZINSDTLSPF.ZINSROLE%type
		);
  TYPE zinsroletype IS TABLE OF OBJ_ZINSROLE INDEX BY VARCHAR2(50);
  PROCEDURE getzinsrole(getzinsrole OUT zinsroletype);
  -----------PH19: Get Insured Role END----

  -----------PH19: Get Total Refund  START----
  TYPE OBJ_ZREFUNDAM IS RECORD(
		CHDRNUM		ZTRAPF.CHDRNUM%type,
		ZREFUNDAM	ZTRAPF.ZREFUNDAM%type
		);
  TYPE zrefundamtype IS TABLE OF OBJ_ZREFUNDAM INDEX BY VARCHAR2(30);
  PROCEDURE getrefundam(getrefundam OUT zrefundamtype);
  -----------PH19: Get Total Refund END----   

  -----------PH19: Check Coverage Policy Duplicate START----
  TYPE pcduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkpcdupl(checkpcdup OUT pcduplicate);
  -----------PH19: Check Coverage Policy Duplicate END---- 

  -----------PH19: Get Cancellation Record START----
  TYPE OBJ_CANCTRAN IS RECORD(
		CHDRNUM		ZTRAPF.CHDRNUM%type,
		TRANNO		ZTRAPF.TRANNO%type,
		EFFDATE		ZTRAPF.EFFDATE%type);
  TYPE canctrantype IS TABLE OF OBJ_CANCTRAN INDEX BY VARCHAR2(30);
  PROCEDURE getcanctran(getcanctran OUT canctrantype);
  -----------PH19: Get Cancellation Record END----  

  -----------PH19: Check APIRNO Duplicate START----
  TYPE nrduplicate IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkapirnodup(checkpcduprn OUT nrduplicate);
  -----------PH19: Check APIRNO Duplicate END----  

  -----------PH19: Get Data Transfer Date  START----
  TYPE OBJ_ZESDPF IS RECORD(
		ZENDSCID		ZESDPF.ZENDSCID%type,
		ZCOVCMDT 		ZESDPF.ZCOVCMDT%type,
		ZBSTCSDT03 		ZESDPF.ZBSTCSDT03%type,
		ZBSTCSDT02 		ZESDPF.ZBSTCSDT02%type,
		ZACMCLDT		ZESDPF.ZACMCLDT%type
		);
  TYPE zesdpftype IS TABLE OF OBJ_ZESDPF INDEX BY VARCHAR2(60);
  PROCEDURE getdzesdpf(getdzesdpf OUT zesdpftype);
  -----------PH19: Get Data Transfer Date END----   
  
  -----------PH20: Get Data Transfer for Back Dated  START----
  TYPE OBJ_ZESDPF_BD IS RECORD(
		ZENDSCID		ZESDPF.ZENDSCID%type,
		ZACMCLDT		ZESDPF.ZACMCLDT%type,
		ZBSTCSDT03 	ZESDPF.ZBSTCSDT03%type,
		ZBSTCSDT02 		ZESDPF.ZBSTCSDT02%type
		);
  TYPE zesdpftype_bd IS TABLE OF OBJ_ZESDPF_BD INDEX BY VARCHAR2(60);
  PROCEDURE getdzesdpf_bd(getdzesdpf_bd OUT zesdpftype_bd);
  -----------PH20: Get Data Transfer for Back Dated END----   
  
  -----------PH19: Get agent flag START----
  TYPE OBJ_AGNTFLG IS RECORD(
		AGNTNUM		AGNTPF.AGNTNUM%type,
		ZTRGTFLG    AGNTPF.ZTRGTFLG%type);
  TYPE getagntflg_type IS TABLE OF OBJ_AGNTFLG INDEX BY VARCHAR2(30);
  PROCEDURE getagntflg(getagntflg OUT getagntflg_type);
  -----------PH19: Get agent flag END----  
  
  -----------PH20: Get bank details START----
  TYPE bankdetails_type IS TABLE OF VARCHAR2(52) INDEX BY VARCHAR2(52);
  PROCEDURE checkbank(checkbank OUT bankdetails_type);
  -----------PH20: Get bank details END---
  
  -----------PH20: Get Endorser details START----
  TYPE endorserdetails_type IS TABLE OF VARCHAR2(200) INDEX BY VARCHAR2(200);
  PROCEDURE checkendorser(checkendorser OUT endorserdetails_type);
  -----------PH20: Get Endorser details END---
  
  -----------PH20: Get Products for Main Insured only START----
  TYPE mainprodtyp IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(10);
  PROCEDURE checkmainprdcts(checkmainprdcts OUT mainprodtyp);
  -----------PH20: Get Products for Main Insured only END---  
END PKG_COMMON_DMMB_PHST;
/

create or replace PACKAGE BODY                        "PKG_COMMON_DMMB_PHST" AS
  /**************************************************************************************************************************
  * File Name        : PKG_COMMON_DMMB_PHST
  * Author           : Sachin Chourasiya
  * Creation Date    : January 19, 2018
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This package contains all the common operations which are used in DMCM Part-Policy Transaction History
  **************************************************************************************************************************/
  /***************************************************************************************************
  * Amenment History: MB01 Policy Transaction
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   PH1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0501     SC    PH2   Performance change for Dm rehearsal.
  * 0502     SC    PH3   LOGIC CHANGED TO GET UNIQUE_NUMBER FROM PAZDCHPF(PREVIOUSLY ZCLNPF).
  * 0504     SC    PH5   CHANGED FOR #7685 - [functional issue]screen validation incorrect. 
  * 0508     SC    PH9   Changes For Ticket #7852 -Incorrect Fields on ZTRAPF     
  * 0516     SK    PH10  Removed unused fields like company   
  * 0516     SK    PH11  Replaced Fetch to Bulk Collect
  * 0518     SK    PH12  Implemented Logic to fetch limited records to avoid PGA memory issue
  * 1008     PS    PH13  Added checking for Count.
  **************PA DEVELOPMENT CHANGES**************************************************************  
  * AUG11	   MKS   PH19  For PA Development changes
  *****************************************************************************************************
  **************ITR3 PA DEVELOPMENT CHANGES**************************************************************    
  * FEB02    MKS   PH20   ITR3 PA Development changes
  * FEB16  MKS   PH22   Fix for P2-5569 removal of sub-cmapaign column in gmhd  
  *****************************************************************************************************/
------------------ PH12: START Get Chdrnum range to fetch limited records --------------
PROCEDURE fetch_chdrnum_range is
BEGIN
    Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;
END;
------------------ PH12: END Get Chdrnum range to fetch limited records ----------------

-------------PH2:START-------------------------------------------------------------------
--DM REHEARSAL PERFORMANCE: START-----------------------------------------------------------------------------------------------
  -----------Get ZENCDE from GCHPPF:START--------
--  PROCEDURE checkgchppf(i_company IN varchar2, checkZendcde OUT gchppftype) is
--    indexitems PLS_INTEGER;
--    TYPE obj_itempf IS RECORD(
--      i_chdrnum gchppf.CHDRNUM%type,
--      i_company gchppf.CHDRCOY%type,
--      i_zendcde gchppf.ZENDCDE%type);
--    TYPE v_array IS TABLE OF obj_itempf;
--    itempflist v_array;
--
--  BEGIN
--
--    select CHDRNUM, CHDRCOY, ZENDCDE
--      BULK COLLECT
--      into itempflist
--      from GCHPPF
--     where TRIM(CHDRCOY) = TRIM(i_company);
--    FOR indexitems IN itempflist.first .. itempflist.last LOOP
--      checkZendcde(TRIM(itempflist(indexitems).i_chdrnum) || TRIM(itempflist(indexitems).i_company)) := TRIM(itempflist(indexitems)
--                                                                                                             .i_zendcde);
--    END LOOP;
--
--  END;
  -----------Get ZENCDE from GCHPPF:END--------
--DM REHEARSAL PERFORMANCE: END---------------------------------------------------------------------------------------------------------  
-------------PH2:END-------------------------------------------------------------------

  -----------Get PAZDCLPF Data :START------------
  -- PH12: commented as not required: discussed with Patrice May16
 PROCEDURE checkzdclpf(checkzdclpf OUT pazdclpftype) is
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_PAZDCLPF;
    itempflist v_array;

  BEGIN

    select ZENTITY, ZIGVALUE
      BULK COLLECT
      into itempflist
      from PAZDCLPF
     where TRIM(PREFIX) = TRIM('CP');
    FOR indx IN itempflist.first .. itempflist.last LOOP
      checkzdclpf(TRIM(itempflist(indx).zentity)) := itempflist(indx);
    END LOOP;

  END;
  -----------Get PAZDCLPF Data:END--------

  /*-----------Get CLBA FOR CREDIT CARD:START------------
  PROCEDURE getclbaforcc(getclbaforcc OUT clbatype) is
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
      getclbaforcc(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum) || TRIM(obj_clba.clntcoy)) := obj_clba;
    END LOOP;

    CLOSE clbalist;

  END;
  -----------Get CLBA:END------------
  -----------Get CLBA FOR BANK:START------------
  PROCEDURE getclbaforbnk(getclbaforbnk OUT clbatype1) is
    CURSOR clbalist IS
      SELECT *
        FROM CLBAPF
       where TRIM(Clntpfx) = TRIM('CN')
         and TRIM(validflag) = TRIM('1')
         and TRIM(bnkactyp) != TRIM('CC');
    obj_clba clbalist%rowtype;

  BEGIN
    OPEN clbalist;
    <<skipRecord>>
    LOOP
      FETCH clbalist
        INTO obj_clba;
      EXIT WHEN clbalist%notfound;
      getclbaforbnk(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum) || TRIM(obj_clba.clntcoy)) := obj_clba;
    END LOOP;

    CLOSE clbalist;

  END;
  -----------Get CLBA:END------------ */
  -----------Get GCHD:START------------
 /* PROCEDURE getgchd(getgchd OUT gchdtype1) is
    CURSOR gchdlist IS
      SELECT *
        FROM GCHD
       where TRIM(CHDRPFX) = TRIM('CH')
         and TRIM(VALIDFLAG) = TRIM('1')
         and TRIM(CHDRCOY) IN (1, 9);
    obj_gchd gchdlist%rowtype;

  BEGIN
    OPEN gchdlist;
    <<skipRecord>>
    LOOP
      FETCH gchdlist
        INTO obj_gchd;
      EXIT WHEN gchdlist%notfound;
      getgchd(TRIM(obj_gchd.chdrnum) || TRIM(obj_gchd.chdrcoy)) := obj_gchd;
    END LOOP;

    CLOSE gchdlist;

  END;
  */
  -----------Get GCHD:END------------


 --SIT CHANGE START-----

  -----------Get ZCMPCODE abc from GCHIPF :START--------
 /* PROCEDURE getgchipf(getgchipf OUT gchitype) is
    CURSOR gchipflist IS
      SELECT *
        FROM GCHIPF
         WHERE  TRIM(CHDRCOY) IN (1, 9);
    obj_gchi gchipflist%rowtype;

  BEGIN
    OPEN gchipflist;
    <<skipRecord>>
    LOOP
      FETCH gchipflist
        INTO obj_gchi;
      EXIT WHEN gchipflist%notfound;
      getgchipf(TRIM(obj_gchi.chdrnum) || TRIM(obj_gchi.chdrcoy)) := obj_gchi;
    END LOOP;

    CLOSE gchipflist;

  END;

  */
-----------Get ZCMPCODE  from GCHIPF :END--------


-----------Get ZCPNSCDE   from GMHIPF:START--------
 /* PROCEDURE getgmhipf(getgmhipf OUT gmhitype) is
    CURSOR gmhipflist IS
      SELECT *
        FROM GMHIPF
       where
         TRIM(CHDRCOY) IN (1, 9);
    obj_gmhi gmhipflist%rowtype;

  BEGIN
    OPEN gmhipflist;
    <<skipRecord>>
    LOOP
      FETCH gmhipflist
        INTO obj_gmhi;
      EXIT WHEN gmhipflist%notfound;
      getgmhipf(TRIM(obj_gmhi.chdrnum) || TRIM(obj_gmhi.chdrcoy)) := obj_gmhi;
    END LOOP;

    CLOSE gmhipflist;

  END;

  */
-----------Get ZCPNSCDE   from GMHIPF:END--------

-------------PH2:START-------------------------------------------------------------------
--TICKET- #7540- DM REHEARSAL STARTS-------------------
-----------Get ZENCDE, ZCONVINDPOL and ZPLANCLS  from GCHPPF:START--------
  PROCEDURE getgchppf(getgchppf OUT gchptype) is
   -- PH11 [START]
    /*CURSOR gchppflist IS
      SELECT chdrnum,zconvindpol,zendcde,zplancls, -- PH10 removed CHDRCOY
        zpgpfrdt, zpgptodt, --PH5 two more column added zpgpfrdt and zpgptodt
        zpoltdate --PH9 one more column added "ZPOLTDATE"
        FROM GCHPPF
         WHERE  TRIM(CHDRCOY) IN (1, 9);
    obj_gchp gchppflist%rowtype;

  BEGIN
    OPEN gchppflist;
    <<skipRecord>>
    LOOP
      FETCH gchppflist
        INTO obj_gchp;
      EXIT WHEN gchppflist%notfound;
      getgchppf(TRIM(obj_gchp.chdrnum)) := obj_gchp; -- PH10
    END LOOP;

    CLOSE gchppflist;*/

    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_GCHP;
    gchppflist v_array;

    BEGIN

     Select CHDRNUM_FROM, CHDRNUM_TO 
     into v_range_from, v_range_to 
     FROM MB01_POLHIST_RANGE;

      SELECT chdrnum,zendcde,zplancls,zpgpfrdt,zpgptodt,zpoltdate,zsalechnl
      BULK COLLECT
      into gchppflist
      FROM GCHPPF
      WHERE TRIM(CHDRCOY) IN (1, 9)
      AND CHDRNUM between v_range_from and v_range_to; -- PH12

      FOR idx IN gchppflist.first .. gchppflist.last LOOP
         getgchppf(TRIM(gchppflist(idx).chdrnum)) := gchppflist(idx);
      END LOOP;
      -- PH11 [END]

  END;
-----------Get ZENCDE, ZCONVINDPOL and ZPLANCLS  from GCHPPF:ENDS--------
--TICKET- #7540- DM REHEARSAL ENDS-------------------
-------------PH2:END-------------------------------------------------------------------

-----------Get ZSALECHNL from GMHDPF:START--------
  PROCEDURE getgmhdpf(getgmhdpf OUT gmhdtype) is
  -- PH11 [START]
--    CURSOR gmhdpflist IS
--      SELECT chdrnum, zsalechnl, cltreln -----PH6: new column added "CLTRELN"---- -- PH10 removed CHDRCOY
--        FROM GMHDPF
--         WHERE  TRIM(CHDRCOY) IN (1, 9);
--    obj_gmhd gmhdpflist%rowtype;
--
--  BEGIN
--    OPEN gmhdpflist;
--    <<skipRecord>>
--    LOOP
--      FETCH gmhdpflist
--        INTO obj_gmhd;
--      EXIT WHEN gmhdpflist%notfound;
--      getgmhdpf(TRIM(obj_gmhd.chdrnum)) := obj_gmhd; -- PH10
--    END LOOP;
--
--    CLOSE gmhdpflist;

    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_GMHD;
    gmhdpflist v_array;

    BEGIN

      Select CHDRNUM_FROM, CHDRNUM_TO into v_range_from, v_range_to 
	  FROM MB01_POLHIST_RANGE;

      SELECT chdrnum, mbrno, min(dteatt) --PH22
      BULK COLLECT
      into gmhdpflist
      FROM GMHDPF
      WHERE TRIM(CHDRCOY) IN (1, 9)
      AND CHDRNUM between v_range_from and v_range_to
      GROUP BY chdrnum, mbrno; -- PH12

      FOR idx IN gmhdpflist.first .. gmhdpflist.last LOOP
         getgmhdpf(TRIM(gmhdpflist(idx).chdrnum)||TRIM(gmhdpflist(idx).mbrno)) := gmhdpflist(idx);
      END LOOP;
      -- PH11 [END]

  END;
-----------Get ZSALECHNL from GMHDPF:END--------

---SIT CHANGE END-----
 ---------------Check duplicate policy--------------------

  PROCEDURE checkcpdup(checkdupl OUT phduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDPTPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select (zentity || '-' || zseqno || '-' || tranno || '-' || effdate || '-' || mbrno || '-' || zinsrole) zentity 
	BULK COLLECT into itempflist from PAZDPTPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkdupl(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkdupl(' ') := TRIM(' ');
  END;
  ---------------Check duplicate policy--------------------

  /*
  -----------Get PAZDCLPF Data :START------------
  PROCEDURE getzclnuniqueno(checkClntUN OUT zclnuniqueno) is
    indexitems PLS_INTEGER;
    TYPE obj_zclnpf IS RECORD(
      i_clntnum        ZCLNPF.CLNTNUM%type,
      i_effdate        ZCLNPF.EFFDATE%type,
      i_unique_number  ZCLNPF.UNIQUE_NUMBER%type);
    TYPE v_array IS TABLE OF obj_zclnpf;
    zclnpflist v_array;

  BEGIN

    select CLNTNUM, EFFDATE, UNIQUE_NUMBER
      BULK COLLECT
      into zclnpflist
      from ZCLNPF;

    FOR indexitems IN zclnpflist.first .. zclnpflist.last LOOP
      checkClntUN(TRIM(zclnpflist(indexitems).i_clntnum)) := TRIM(zclnpflist(indexitems)
                                                                  .i_clntnum);
    END LOOP;

  END;
  -----------Get PAZDCLPF Data:END--------
  -----------Get ZENCTPF Data :START------------
PROCEDURE getcardtype(checkZENCT OUT zcardtype) is
    indexitems PLS_INTEGER;
    TYPE obj_zenctpf IS RECORD(
      i_mplnum         ZENCTPF.ZPOLNMBR%type,
      i_tempcard       VARCHAR2(16),
      i_ZCNBRFRM       ZENCTPF.ZCNBRFRM%type,
      i_ZCNBRTO	       ZENCTPF.ZCNBRTO%type,
      i_cardtype       ZENCTPF.ZCRDTYPE%type);
    TYPE v_array IS TABLE OF obj_zenctpf;
    zenctpflist v_array;

  BEGIN

    select ZCRDTYPE
      BULK COLLECT
      into zenctpflist
      from ZENCTPF
     WHERE ZPOLNMBR = i_mplnum
     and ((TRIM(TO_NUMBER(i_ZCNBRFRM)) < TRIM(i_tempcard)  and
           TRIM(TO_NUMBER(i_ZCNBRTO))  > TRIM(i_tempcard)) OR
           TRIM(TO_NUMBER(i_ZCNBRFRM)) = TRIM(i_tempcard)  OR
           TRIM(TO_NUMBER(i_ZCNBRTO))  = TRIM(i_tempcard)) ;

    FOR indexitems IN zenctpflist.first .. zenctpflist.last LOOP
      checkZENCT(TRIM(zenctpflist(indexitems).i_mplnum)) := TRIM(zenctpflist(indexitems)
                                                                  .i_mplnum);
    END LOOP;

  END;
  -----------Get ZENCTPF Data:END--------   */



-- PROCEDURE getclbapfccinfo(CLBACCINFO OUT CLBACCTYPE) is
--    CURSOR clbalist IS
--      SELECT clntnum, clntcoy, bankacckey
--        FROM CLBAPF
--       where TRIM(Clntpfx) = TRIM('CN')
--         and TRIM(validflag) = TRIM('1')
--         and TRIM(bnkactyp) = TRIM('CC');
--    obj_clba clbalist%rowtype;
--  
--  BEGIN
--    OPEN clbalist;
--    <<skipRecord>>
--    LOOP
--      FETCH clbalist
--        INTO obj_clba;
--      EXIT WHEN clbalist%notfound;
--      CLBACCINFO(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum) || TRIM(obj_clba.clntcoy)) := obj_clba;
--    END LOOP;
--  
--    CLOSE clbalist;
--  
--  END;   

  PROCEDURE getgchd(getgchd OUT gchdtype1) is
   -- PH11 [START]
    /*CURSOR gchdlist IS
      SELECT chdrnum, cownnum, statcode, tranlused, mplnum, btdate --PH5: ONE MORE COLUMN ADDED BTDATE -- PH10 removed CHDRCOY
        FROM GCHD
       where TRIM(CHDRPFX) = TRIM('CH')
         and TRIM(VALIDFLAG) = TRIM('1')
         and TRIM(CHDRCOY) IN (1, 9);
    obj_gchd gchdlist%rowtype;

  BEGIN
    /*OPEN gchdlist;
    <<skipRecord>>
    LOOP
      FETCH gchdlist
        INTO obj_gchd;
      EXIT WHEN gchdlist%notfound;
      getgchd(TRIM(obj_gchd.chdrnum)) := obj_gchd; -- PH10
    END LOOP;

    CLOSE gchdlist;*/


	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_GCHD;
    gchdlist v_array;

    BEGIN

     Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;

      SELECT chdrnum, cownnum, statcode, tranlused, mplnum, btdate, effdcldt, occdate
      BULK COLLECT
      into gchdlist
      FROM GCHD
      where TRIM(CHDRPFX) = TRIM('CH')
      and TRIM(VALIDFLAG) = TRIM('1')
      and TRIM(CHDRCOY) IN (1, 9)
      AND CHDRNUM between v_range_from and v_range_to; -- PH12

      FOR idx IN gchdlist.first .. gchdlist.last LOOP
         getgchd(TRIM(gchdlist(idx).chdrnum)) := gchdlist(idx);
      END LOOP;
	  -- PH11 [END]

  END;


   PROCEDURE getgchipf(getgchipf OUT gchItype1) is
   -- PH11 [START]
    /*CURSOR gchipflist IS
      SELECT chdrnum,zcmpcode,zsolctflg,ccdate -- PH10 removed CHDRCOY
        FROM GCHIPF
         WHERE  CHDRCOY IN (1, 9);
    obj_gchi gchipflist%rowtype;

  BEGIN
    /*OPEN gchipflist;
    <<skipRecord>>
    LOOP
      FETCH gchipflist
        INTO obj_gchi;
      EXIT WHEN gchipflist%notfound;
      getgchipf(TRIM(obj_gchi.chdrnum)) := obj_gchi; -- PH10
    END LOOP;

    CLOSE gchipflist;*/

	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_GCHI;
    gchipflist v_array;

    BEGIN

     Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;

      SELECT DISTINCT chdrnum,zcmpcode,zsolctflg,ccdate,zpolperd,agntnum --PH19
      BULK COLLECT
      into gchipflist
      FROM GCHIPF
      WHERE CHDRCOY IN (1, 9)
      AND CHDRNUM between v_range_from and v_range_to;

      FOR idx IN gchipflist.first .. gchipflist.last LOOP
         getgchipf(TRIM(gchipflist(idx).chdrnum)) := gchipflist(idx); --PH12
      END LOOP;
	  -- PH11 [END]

  END;


  PROCEDURE getgmhipf(getgmhipf OUT gmhitype) is
    -- PH11 [START]
	/*CURSOR gmhipflist IS
      SELECT chdrnum,
             -- chdrcoy, -- PH10 removed CHDRCOY
             zcpnscde,
             zplancde,
             dcldate,
             zdclitem01,
             zdclitem02,
             zdeclcat,
             docrcdte,
             hpropdte,
             zdfcncy,
             zmargnflg

        FROM GMHIPF
       where TRIM(CHDRCOY) IN (1, 9);-- PH5: TWO MORE COLUMNS ADDED ZDFCNCY AND ZMARGNFLG
    obj_gmhi gmhipflist%rowtype;

  BEGIN
    OPEN gmhipflist;
    <<skipRecord>>
    LOOP
      FETCH gmhipflist
        INTO obj_gmhi;
      EXIT WHEN gmhipflist%notfound;
      getgmhipf(TRIM(obj_gmhi.chdrnum)) := obj_gmhi; --PH10
    END LOOP;

    CLOSE gmhipflist;*/

	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_GMHI;
    gmhipflist v_array;

    BEGIN

    Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;


      SELECT DISTINCT chdrnum, mbrno, TRIM(zplancde) zplancde
      BULK COLLECT
      into gmhipflist
      FROM GMHIPF
      where TRIM(CHDRCOY) IN (1, 9)
      AND CHDRNUM between v_range_from and v_range_to; -- PH12

      FOR idx IN gmhipflist.first .. gmhipflist.last LOOP
         getgmhipf(TRIM(gmhipflist(idx).chdrnum)||TRIM(gmhipflist(idx).mbrno)) := gmhipflist(idx);
      END LOOP;
	  -- PH11 [END]

  END;

  ---------------------CC and Bank----
   -----------Get CLBA FOR CREDIT CARD:START------------
  PROCEDURE getclbaforcc(getclbaforcc OUT clbatype) is
  -- PH11 [START]
    /*CURSOR clbalist IS
      SELECT bankacckey, clntnum, mthto, yearto -- PH10 removed CHDRCOY
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
      getclbaforcc(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum)) := obj_clba; -- PH10
    END LOOP;

    CLOSE clbalist;*/


	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_CLBAPF_CC;
    clbalist v_array;

    BEGIN
      SELECT bankacckey, clntnum, mthto, yearto
      BULK COLLECT
      into clbalist
      FROM CLBAPF
      where TRIM(Clntpfx) = TRIM('CN')
      and TRIM(validflag) = TRIM('1')
      and TRIM(bnkactyp) = TRIM('CC');

      IF clbalist.count > 0 THEN  --- PH13
        FOR idx IN clbalist.first .. clbalist.last LOOP
          getclbaforcc(TRIM(clbalist(idx).bankacckey) || TRIM(clbalist(idx).clntnum)) := clbalist(idx);
        END LOOP;
      END IF;  -- PH13
	  -- PH11 [END]

  END;
  -----------Get CLBA:END------------


  -----------Get CLBA FOR BANK:START------------
  PROCEDURE getclbaforbnk(getclbaforbnk OUT clbatype1) is
   -- PH11 [START]
    /*CURSOR clbalist IS
      SELECT bankacckey, clntnum, bankaccdsc, bnkactyp, bankkey -- PH10
        FROM CLBAPF
       where TRIM(Clntpfx) = TRIM('CN')
         and TRIM(validflag) = TRIM('1')
         and TRIM(bnkactyp) != TRIM('CB');
    obj_clba clbalist%rowtype;

  BEGIN
    OPEN clbalist;
    <<skipRecord>>
    LOOP
      FETCH clbalist
        INTO obj_clba;
      EXIT WHEN clbalist%notfound;
      getclbaforbnk(TRIM(obj_clba.bankacckey) || TRIM(obj_clba.clntnum)) := obj_clba; --PH10
    END LOOP;

    CLOSE clbalist;*/

	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_CLBAPF_BN;
    clbalist v_array;

    BEGIN
      SELECT bankacckey, clntnum, bankaccdsc, bnkactyp, bankkey
      BULK COLLECT
      into clbalist
      FROM CLBAPF
      where TRIM(Clntpfx) = TRIM('CN')
      and TRIM(validflag) = TRIM('1')
      --and TRIM(bnkactyp) != TRIM('CB');
	  and TRIM(bnkactyp) != TRIM('CC'); -- Changed CB to CC

      IF clbalist.count > 0 THEN  --- PH13
        FOR idx IN clbalist.first .. clbalist.last LOOP
           getclbaforbnk(TRIM(clbalist(idx).bankacckey) || TRIM(clbalist(idx).clntnum)) := clbalist(idx);
        END LOOP;
      END IF;  --- PH13
	  -- PH11 [END]

  END;
  -----------Get CLBA:END------------


  ------------------CC and Bank-----------------

-------------PH2:START-------------------------------------------------------------------
 -----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: START--------
--  PROCEDURE getzclnpf(getzclnpf OUT zclnpftype) is
--    CURSOR zclnpflist IS
--
--      SELECT CLNTNUM, CLNTCOY, EFFDATE, CLNTPFX, UNIQUE_NUMBER
--
--        FROM ZCLNPF
--
--         WHERE TRIM(CLNTPFX) = TRIM('CN')
--           and TRIM(CLNTCOY) IN (1, 9);
--
--    obj_zclnpf zclnpflist%rowtype;
--
--  BEGIN
--    OPEN zclnpflist;
--    <<skipRecord>>
--    LOOP
--      FETCH zclnpflist
--        INTO obj_zclnpf;
--      EXIT WHEN zclnpflist%notfound;
--      getzclnpf(TRIM(obj_zclnpf.CLNTNUM) || TRIM(obj_zclnpf.CLNTCOY) || TRIM(obj_zclnpf.EFFDATE)) := obj_zclnpf;
--    END LOOP;
--
--    CLOSE zclnpflist;
--
--  END;
-----------Get UNIQUE_NUMBER from zclnpf: DM_REHEARSAL_PERFORMANCE: END--------
-------------PH2:END-------------------------------------------------------------------

-------------PH2:START-------------------------------------------------------------------
-----------Get ZBNKFLAG, ZCCFLAG from ZENCIPF: DM_REHEARSAL_PERFORMANCE: START----

PROCEDURE getzencipf(getzencipf OUT zencipftype) is
    /*CURSOR zencipflist IS

  SELECT ZENDCDE, ZBNKFLAG, ZCCFLAG
        FROM ZENCIPF;

    obj_zencipf zencipflist%rowtype;

  BEGIN
    OPEN zencipflist;
    <<skipRecord>>
    LOOP
      FETCH zencipflist
        INTO obj_zencipf;
      EXIT WHEN zencipflist%notfound;
      getzencipf(TRIM(obj_zencipf.ZENDCDE)) := obj_zencipf;
    END LOOP;

    CLOSE zencipflist;*/


	idx PLS_INTEGER;
    TYPE v_array IS TABLE OF obj_zencipf;
    zencipflist v_array;

    BEGIN
      SELECT ZENDCDE, ZBNKFLAG, ZCCFLAG
      BULK COLLECT
      into zencipflist
      FROM ZENCIPF;

      FOR idx IN zencipflist.first .. zencipflist.last LOOP
         getzencipf(TRIM(zencipflist(idx).ZENDCDE)) := zencipflist(idx);
      END LOOP;
	  -- PH11 [END]

  END;
-----------Get ZBNKFLAG, ZCCFLAG from ZENCIPF: DM_REHEARSAL_PERFORMANCE: END-------
-------------PH2:END-------------------------------------------------------------------

-------------PH3:START-------------------------------------------------------------------
 PROCEDURE getzdchpf(getzdchpf OUT zdchpftype) is
 -- PH11 [START]
    /*CURSOR zdchpflist IS

      SELECT ZIGVALUE, ZSEQNO, EFFDATE, RECIDXCLNTHIS 

        FROM PAZDCHPF;

    obj_zdchpf zdchpflist%rowtype;

  BEGIN
    OPEN zdchpflist;
    <<skipRecord>>
    LOOP
      FETCH zdchpflist
        INTO obj_zdchpf;
      EXIT WHEN zdchpflist%notfound;
      getzdchpf(TRIM(obj_zdchpf.ZIGVALUE) || TRIM(obj_zdchpf.ZSEQNO) || TRIM(obj_zdchpf.EFFDATE)) := obj_zdchpf;
    END LOOP;

    CLOSE zdchpflist;*/


    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF obj_zdchpf;
    zdchpflist v_array;

    BEGIN
      SELECT ZIGVALUE, ZSEQNO, EFFDATE, RECIDXCLNTHIS 
      BULK COLLECT
      into zdchpflist
      FROM PAZDCHPF;

      FOR idx IN zdchpflist.first .. zdchpflist.last LOOP
         getzdchpf(TRIM(zdchpflist(idx).ZIGVALUE) || TRIM(zdchpflist(idx).ZSEQNO) || TRIM(zdchpflist(idx).EFFDATE)) := zdchpflist(idx);
      END LOOP;
	  -- PH11 [END]



  END;
-------------PH3:END-------------------------------------------------------------------
-------------PH9: START-------------------------------------------------------------------
        ------------GET CLNT DOB-------------
  PROCEDURE checkclntDOB(clntdob OUT getclntdob) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_clntnum CLNTPF.clntnum%type,
      i_cltdob  CLNTPF.Cltdob%type -- PH10
      );
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select clntnum, Cltdob BULK COLLECT into itempflist from CLNTPF -- PH10
    where TRIM(clntpfx) = TRIM('CN')
         and TRIM(clntcoy) = TRIM('9')
         and TRIM(clttype) = TRIM('P');

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      clntdob(TRIM(itempflist(indexitems).i_clntnum)) := TRIM(itempflist(indexitems)
                                                              .i_cltdob);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      clntdob(' ') := TRIM(' ');

  END;
         ---------GET CLNT DOB-------
-------------PH9: END----------------------------------------------------------------------
-----------PH16:Get converted pol list:START--------
  PROCEDURE getconpolinfo(getconpol OUT conpoltype) is
    CURSOR conpollist IS
      SELECT * FROM CONV_POL_HIST;

    obj_conpol conpollist%rowtype;

  BEGIN
    OPEN conpollist;
    <<skipRecord>>
    LOOP
      FETCH conpollist
        INTO obj_conpol;
      EXIT WHEN conpollist%notfound;
      getconpol(TRIM(obj_conpol.Ph_Chdrnum)) := obj_conpol;
    END LOOP;

    CLOSE conpollist;

  END;
  -----------PH16:Get converted pol list:START--------

  -----------PH19:Get TQ9MP Start--------
  PROCEDURE gettq9mp(gettq9mp OUT tq9mptype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_TQ9MP;
    itempflist v_array;

  BEGIN
    Select TRIM(ITEMITEM) ITEMITEM, SUBSTR(utl_raw.cast_to_varchar2(genarea),6,4) ZRCALTTY
    BULK COLLECT into itempflist
	  from itempf 
	  where  TRIM(itemtabl) = 'TQ9MP'
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1';

      FOR idx IN itempflist.first .. itempflist.last LOOP
        gettq9mp(TRIM(itempflist(idx).ITEMITEM)):= itempflist(idx);
      END LOOP;	
   END;
  -----------PH19:Get TQ9MP End--------

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

  -----------PH19: Get Tranno of new business Start--------
  PROCEDURE getnewbtran(getnewbtran OUT newbtrantype)IS


    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_NEWBTRAN;
    itempflist v_array;

  BEGIN
    Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;  

    SELECT CHDRNUM, MIN(TRANNO) TRANNO
    BULK COLLECT into itempflist
	  FROM ZTRAPF WHERE CHDRNUM between v_range_from and v_range_to
	  GROUP BY CHDRNUM;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getnewbtran(TRIM(itempflist(idx).CHDRNUM)):= itempflist(idx);
      END LOOP;	
   END;
  -----------PH19:Get Tranno of new business End--------  

  -----------PH19: Get Tranno of cancellation Start--------
  PROCEDURE getcancltran(getcancltran OUT cancltrantype)IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_CNCLTRAN;
    itempflist v_array;

  BEGIN
    Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE;  

    SELECT CHDRNUM, MAX(TRANNO) OVER(PARTITION BY CHDRNUM) TRANNO, EFFDATE
    BULK COLLECT into itempflist
    FROM ZTRAPF
	  WHERE ZRCALTTY = 'TERM' 
	  AND ZTRXSTAT = 'AP'
	  AND CHDRNUM between v_range_from and v_range_to;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getcancltran(TRIM(itempflist(idx).CHDRNUM)):= itempflist(idx);
      END LOOP;	
   END;
  -----------PH19:Get Tranno of cancellation End--------    

  -----------PH19: Get Insured Role Start--------
  PROCEDURE getzinsrole(getzinsrole OUT zinsroletype)IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZINSROLE;
    itempflist v_array;

  BEGIN
	Select CHDRNUM_FROM, CHDRNUM_TO 
    into v_range_from, v_range_to 
    FROM MB01_POLHIST_RANGE; 

    SELECT CHDRNUM, MBRNO, DPNTNO, ZINSROLE
    BULK COLLECT into itempflist
    FROM ZINSDTLSPF WHERE CHDRNUM between v_range_from and v_range_to;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getzinsrole(TRIM(itempflist(idx).CHDRNUM) || TRIM(itempflist(idx).MBRNO) || TRIM(itempflist(idx).DPNTNO)):= itempflist(idx);
      END LOOP;	
   END;
  -----------PH19:Get Insured Role End--------   

  -----------PH19: Get Total Refund Start--------
  PROCEDURE getrefundam(getrefundam OUT zrefundamtype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZREFUNDAM;
    itempflist v_array;

  BEGIN
    SELECT CHDRNUM, (SUM(ZREFUNDAM) + SUM(ZREFUNDAM)) ZREFUNDAM
    BULK COLLECT into itempflist
    FROM DMIGTITDMGPOLTRNH
    GROUP BY CHDRNUM;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getrefundam(TRIM(itempflist(idx).CHDRNUM)):= itempflist(idx);
      END LOOP;	
   END;
  -----------PH19:Get Total Refund End--------  

 ---------------Check duplicate policy coverage--------------------
  PROCEDURE checkpcdupl(checkpcdup OUT pcduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDPCPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select (zentity || '-' || mbrno || '-' || DPNTNO || '-' || prodtyp || '-' || EFFDATE) zentity 
	BULK COLLECT into itempflist from PAZDPCPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkpcdup(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkpcdup(' ') := TRIM(' ');
  END;
  ---------------Check duplicate policy coverage--------------------

  -----------PH19: Get Cancellation Record END----  
  PROCEDURE getcanctran(getcanctran OUT canctrantype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_CANCTRAN;
    itempflist v_array;

  BEGIN
	SELECT A.CHDRNUM CHDRNUM, MAX(A.TRANNO) TRANNO, A.EFFDATE EFFDATE
	BULK COLLECT into itempflist
	FROM DMIGTITDMGPOLTRNH A LEFT OUTER JOIN ITEMPF B
		ON TRIM(B.ITEMITEM) = TRIM(A.ZALTRCDE01)
		AND TRIM(B.ITEMTABL) = 'TQ9MP' 
		AND TRIM(B.ITEMCOY) IN (1, 9) 
		AND TRIM(B.ITEMPFX) = 'IT' 
		AND TRIM(B.VALIDFLAG)= '1'
	WHERE SUBSTR(UTL_RAW.CAST_TO_VARCHAR2(B.GENAREA),6,4) = 'TERM'
	GROUP BY A.CHDRNUM, A.EFFDATE;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getcanctran(TRIM(itempflist(idx).CHDRNUM)):= itempflist(idx);
      END LOOP;	
   END;	
  -----------PH19: Get Cancellation Record END----  

 ---------------Check APIRNO coverage START--------------------
  PROCEDURE checkapirnodup(checkpcduprn OUT nrduplicate) is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_zenentity PAZDRNPF.zentity%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    select (zentity || '-' || mbrno || '-' || zinstype || '-' || zinstype || '-' || zapirno || '-' || fullkanjiname) zentity 
	BULK COLLECT into itempflist from PAZDRNPF;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkpcduprn(TRIM(itempflist(indexitems).i_zenentity)) := TRIM(itempflist(indexitems)
                                                                  .i_zenentity);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkpcduprn(' ') := TRIM(' ');
  END;
  ---------------Check APIRNO coverage END-------------------- 

  -----------PH19: Get Data Transfer Date Start---------------- 
  PROCEDURE getdzesdpf(getdzesdpf OUT zesdpftype) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZESDPF;
    itempflist v_array;

  BEGIN
    SELECT ZENDSCID,ZCOVCMDT,ZBSTCSDT03,ZBSTCSDT02,ZACMCLDT		
    BULK COLLECT into itempflist
    FROM ZESDPF;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getdzesdpf(TRIM(itempflist(idx).ZENDSCID) || TRIM(itempflist(idx).ZCOVCMDT)):= itempflist(idx);
      END LOOP;	
   END;  
  -----------PH19: Get Data Transfer Date END----------------  
  
  -----------PH20: Get Data Transfer for Back Dated Start---------------- 
  PROCEDURE getdzesdpf_bd(getdzesdpf_bd OUT zesdpftype_bd) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_ZESDPF_BD;
    itempflist v_array;

  BEGIN
    SELECT ZENDSCID,ZACMCLDT,ZBSTCSDT03,ZBSTCSDT02	
    BULK COLLECT into itempflist
    FROM ZESDPF;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getdzesdpf_bd(TRIM(itempflist(idx).ZENDSCID) || TRIM(itempflist(idx).ZACMCLDT)):= itempflist(idx);
      END LOOP;	
   END;  
  -----------PH20: Get Data Transfer for Back Dated END----------------  

  -----------PH19: Get agent flag Start---- 
  PROCEDURE getagntflg(getagntflg OUT getagntflg_type) IS
    idx PLS_INTEGER;
    TYPE v_array IS TABLE OF OBJ_AGNTFLG;
    itempflist v_array;

  BEGIN
    SELECT TRIM(AGNTNUM), TRIM(ZTRGTFLG)		
    BULK COLLECT into itempflist
    FROM AGNTPF;

      FOR idx IN itempflist.first .. itempflist.last LOOP
        getagntflg(TRIM(itempflist(idx).AGNTNUM)):= itempflist(idx);
      END LOOP;	
   END;    
  -----------PH19: Get agent flag END----    

  -----------PH20: Get bank details START---  
    PROCEDURE checkbank(checkbank OUT bankdetails_type) IS
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      v_bannkey VARCHAR2(40));
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    SELECT TRIM(BANKACCKEY) || '-' || TRIM(BANKKEY) AS BANKKEY 
	BULK COLLECT into itempflist FROM clbapf WHERE TRIM(clntpfx) = 'CN' AND validflag = 1;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkbank(TRIM(itempflist(indexitems).v_bannkey)) := TRIM(itempflist(indexitems)
                                                                  .v_bannkey);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkbank(' ') := TRIM(' ');
  END;
  -----------PH20: Get bank details END---

  -----------PH20: Get Endorser details START---  
  PROCEDURE checkendorser(checkendorser OUT endorserdetails_type) IS
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      v_endcdedtls VARCHAR2(200));
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    SELECT CLNTNUM || '-' || ZENDCDE || '-' || TRIM(ZENSPCD01) || '-' || TRIM(ZENSPCD02) || '-' || TRIM(ZCIFCODE) AS ENDCDEDTLS
    BULK COLLECT into itempflist
    FROM ZCLEPF 
    WHERE TRIM(ZENSPCD01) IS NOT NULL OR 
    TRIM(ZENSPCD02) IS NOT NULL OR  
    TRIM(ZCIFCODE) IS NOT NULL;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkendorser(TRIM(itempflist(indexitems).v_endcdedtls)) := TRIM(itempflist(indexitems)
                                                                  .v_endcdedtls);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkendorser(' ') := TRIM(' ');
  END;
  -----------PH20: Get Endorser details END---
  
  -----------PH20: Get Products for Main Insured only START--- 
  PROCEDURE checkmainprdcts(checkmainprdcts OUT mainprodtyp) IS
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      v_prodtyp GXHIPF.PRODTYP%type);
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

  SELECT TRIM(ITEMITEM) 
  BULK COLLECT into itempflist
  FROM ITEMPF
  WHERE TRIM(ITEMTABL) = 'TQ9GY'
  AND SUBSTR(utl_raw.cast_to_varchar2(genarea),9,1) = 'Y'
  AND TRIM(VALIDFLAG) = 1;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
      checkmainprdcts(TRIM(itempflist(indexitems).v_prodtyp)) := TRIM(itempflist(indexitems)
                                                                  .v_prodtyp);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      checkmainprdcts(' ') := TRIM(' ');
  END;
  -----------PH20: Get Products for Main Insured only END---  
END PKG_COMMON_DMMB_PHST;