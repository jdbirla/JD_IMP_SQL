  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9UY_RD01_RWRD_PROCESS" 
            (i_scheduleName   IN VARCHAR2 DEFAULT 'G1ZDRNWDTM',
             i_scheduleNumber IN VARCHAR2 DEFAULT '0001',
             i_company        IN VARCHAR2 DEFAULT '1',
             i_usrprf         IN VARCHAR2 DEFAULT 'JPAJHA',
             i_branch         IN VARCHAR2 DEFAULT '31',
             i_transCode      IN VARCHAR2 DEFAULT 'BAJA'
          )  AUTHID CURRENT_USER AS


  	/*************************************************************************************************** 
		* Amendment History: RD01 Renewal Determination 
		* Date    Initials  	Tag   	Decription 
		* -----   ---------  	----  	---------------------------------------------------------------------------- 
		* MMMDD   XXX   		  RF0   	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
		* JAN08   JAY        	RD01   	PA New Implementation
		*******************************************************************************************************/ 

  ----------Constant--------------
  C_PREFIX       CONSTANT VARCHAR2(2 CHAR) := Jd1dta.GET_MIGRATION_PREFIX('RWRD', i_company);
  C_BQ9UY        CONSTANT VARCHAR2(5 CHAR) := 'BQ9UY';

 -------------constant Vlaues---
  C_CHDRCOY      VARCHAR2(1 CHAR)   := i_company;
  C_ZRNDTSTS     VARCHAR2(2 CHAR)   := 'AW';
  C_TRANCDE      VARCHAR2(4 CHAR)   := 'BAXB';
  C_JOBNO        CHAR(10 CHAR)      := NULL;
  C_ZVLDRNDT     NUMBER(1,0)        := 1;
  C_THREADNO     NUMBER(2,0)        := NULL;
  C_ISPROCESSED  VARCHAR2(1 CHAR)   := NULL;
  C_DPNTNO       VARCHAR2(2 CHAR)   := '00';
  C_ODMRESP      VARCHAR2(5 CHAR)   := NULL;
 --------------Common Function Start---------
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  itemexist       pkg_dm_common_operations.itemschec;

BEGIN

   -- SET DEFAULT VALUES FROM TABLE : DMDEFVALPF ----- 
  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9UY,
                                     o_defaultvalues => o_defaultvalues); 

  ----------- INSERT DATA INTO IG TABLE : ZRNDTHPF
  C_CHDRCOY :=  o_defaultvalues('CHDRCOY');
  C_ZRNDTSTS :=  o_defaultvalues('ZRNDTSTS');
  C_TRANCDE :=  o_defaultvalues('TRANCDE');
  C_JOBNO :=  o_defaultvalues('JOBNO');
  C_ZVLDRNDT :=  o_defaultvalues('ZVLDRNDT');
  C_THREADNO :=  o_defaultvalues('THREADNO');
  C_ODMRESP :=  o_defaultvalues('ODMRESP');
  C_ISPROCESSED :=  o_defaultvalues('ISPROCESSED');
  C_DPNTNO :=  o_defaultvalues('DPNTNO');

--- ============================================================================================================
--- ================================= Update IG Tables  ========================================================

  ---- Insert recrod into ZRNDTHPF
  INSERT /*+ APPEND PARALLEL(ZRNDTHPF)  */ INTO  ZRNDTHPF
  (
    CHDRCOY, CHDRNUM, ZRNDTNUM, ZRNDTFRM, ZRNDTTO 
    , ZALTRCDE,  ZRNDTREG, ZRNDTAPP
    , JOBNO, TRANCDE, ZRNDTSTS, ZVLDRNDT, THREADNO, ODMRESP, ISPROCESSED
    , USRPRF, JOBNM, DATIME
  )
  SELECT /*+  PARALLEL  */  
      C_CHDRCOY, CHDRNUM, ZRNDTNUM, ZRNDTFRM, ZRNDTTO
    , ZALTRCDE ,ZRNDTREG, ZRNDTAPP
    , C_JOBNO, C_TRANCDE, C_ZRNDTSTS, C_ZVLDRNDT, C_THREADNO, C_ODMRESP, C_ISPROCESSED
    , i_usrprf, i_scheduleName, sysdate
  FROM DMIGTITDMGRNWDT1_INT HDR
  WHERE HDR.HEADER_RECORD = 1
  AND HDR.INDIC = 'S'
  ;


  ---- Insert recrod into ZRNDTDPF 
  INSERT /*+ APPEND PARALLEL(ZRNDTDPF)  */ INTO  ZRNDTDPF
  (
      CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, DPNTNO, ZINSROLE, ZSALPLAN
    , CLNTNUM, ZINSRNWAGE, ZASRFFLG, ZACCMFLG, ZTERMFLG,  ZRNDTRCD
    , USRPRF, JOBNM, DATIME
  )
  SELECT /*+  PARALLEL  */  
      C_CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, C_DPNTNO, ZINSROLE, ZSALPLAN
    , CLNTNUM ,ZINSRNWAGE, ZASRFFLG, ZACCMFLG, ZTERMFLG, ZRNDTRCD
    , i_usrprf, i_scheduleName, sysdate
  FROM DMIGTITDMGRNWDT1_INT HDR
  WHERE  HDR.INDIC = 'S'
  ;

  ---- Insert recrod into ZRNDTDPF 
  dbms_output.put_line(' Insert ZRNDTCOVPF : START ' );
  INSERT /*+ APPEND PARALLEL(ZRNDTCOVPF)  */ INTO  ZRNDTCOVPF
  (
     CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, DPNTNO
    , PRODTYP, SUMINS, DPREM
    , ZINSROLE, ZINSTYPE
    , USRPRF, JOBNM, DATIME
  )
  SELECT /*+  PARALLEL  */  
    C_CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, DPNTNO
    , PRODTYP, SUMINS, DPREM
    , ZINSROLE ,ZINSTYPE
    , i_usrprf, i_scheduleName, sysdate
  FROM DMIGTITDMGRNWDT2_INT COV
  WHERE COV.INDIC = 'S'
  ;

  ---- Insert recrod into ZRNDTSUBCOVPF
  dbms_output.put_line(' Insert ZRNDTSUBCOVPF : START ' );
  INSERT /*+ APPEND PARALLEL(ZRNDTSUBCOVPF)  */ INTO  ZRNDTSUBCOVPF
  (
     CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, DPNTNO
    , PRODTYP01, PRODTYP02, DPREM
    , USRPRF, JOBNM, DATIME
  )
  SELECT /*+  PARALLEL  */  
    C_CHDRCOY, CHDRNUM, ZRNDTNUM, MBRNO, DPNTNO
    , PRODTYP, PRODTYP02, NDR_DPREM
    , i_usrprf, i_scheduleName, sysdate
  FROM DMIGTITDMGRNWDT2_INT COV
  WHERE COV.INDIC = 'S'
    AND COV.PRODTYP02 IS NOT NULL
  ;

  ---- Insert recrod into ZODMPRMVERPF
  dbms_output.put_line(' Insert ZODMPRMVERPF : START ' );
  INSERT /*+ APPEND PARALLEL(ZODMPRMVERPF)  */ INTO  ZODMPRMVERPF
  (
     CHDRCOY, CHDRNUM, ZRNDTNUM, CCDATE, CRDATE
    , ZINSTYPE, ZODMPRMVER
    , USRPRF, JOBNM, DATIME
  )
  SELECT /*+  PARALLEL  */  
      C_CHDRCOY, CHDRNUM, ZRNDTNUM, ZRNDTFRM, ZRNDTTO
      , ZINSTYPE, ZODMPRMVER
   , i_usrprf, i_scheduleName, sysdate
  FROM ( 
    SELECT distinct
         CHDRNUM, ZRNDTNUM, ZRNDTFRM, ZRNDTTO
        , ZINSTYPE, ZODMPRMVER
    FROM DMIGTITDMGRNWDT2_INT COV
    WHERE COV.INDIC = 'S'
  ) ODM_PREM
 ;

--- ============================================================================================================
--- ================================= Update Registery Tables  ========================================================

  -- update PAZDRDPF table
  INSERT /*+ APPEND PARALLEL(PAZDRDPF)  */ INTO  PAZDRDPF
  (
    CHDRNUM, ZRNDTFRM, ZINSROLE, MBRNO, INPUT_SOURCE_TABLE, ZSALPLAN, ZRNDTNUM
    ,JOBNAME, JOBNUM, USRPRF, DATIME
  )
  SELECT /*+  PARALLEL  */  
      CHDRNUM, ZRNDTFRM, ZINSROLE, MBRNO, INPUT_SOURCE_TABLE, ZSALPLAN, ZRNDTNUM
     ,i_scheduleName, i_scheduleNumber, i_usrprf, sysdate
  FROM DMIGTITDMGRNWDT1_INT HDR
  WHERE HDR.INDIC = 'S'
  ;

  -- update PAZDRDPF table
  INSERT /*+ APPEND PARALLEL(PAZDRCPF)  */ INTO  PAZDRCPF
  (
    CHDRNUM, ZRNDTFRM, ZINSROLE, MBRNO, DPNTNO, PRODTYP, INPUT_SOURCE_TABLE, ZSALPLAN, ZRNDTNUM
    ,JOBNAME, JOBNUM, USRPRF, DATIME
  )
  SELECT /*+  PARALLEL  */  
      CHDRNUM, ZRNDTFRM, ZINSROLE, MBRNO, DPNTNO, PRODTYP, INPUT_SOURCE_TABLE, ZSALPLAN, ZRNDTNUM
     ,i_scheduleName, i_scheduleNumber, i_usrprf, sysdate
  FROM DMIGTITDMGRNWDT2_INT COV
  WHERE COV.INDIC = 'S'
  ;

END BQ9UY_RD01_RWRD_PROCESS;

/