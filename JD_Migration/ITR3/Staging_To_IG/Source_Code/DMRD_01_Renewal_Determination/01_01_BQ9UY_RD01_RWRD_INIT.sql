CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9UY_RD01_RWRD_INIT" (
                                   i_schedulename     IN   VARCHAR2 default 'Renewal',
                                   i_schedulenumber   IN   VARCHAR2 DEFAULT 1
                                   )
                            AUTHID CURRENT_USER AS

 	/***************************************************************************************************
		* Amendment History: RD01 Renewal Determination
		* Date    Initials  	Tag   	Decription
		* -----   ---------  	----  	----------------------------------------------------------------------------
		* MMMDD   XXX   		  RF0   	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		* JAN08   JAY        	RD01   	PA New Implementation
		*******************************************************************************************************/

BEGIN

--- ============================================================================================================
--- ================================= DMIGTITDMGRNWDT1_INT : START  ============================================
   dbms_output.put_line('BQ9UY_RD01_RWRD_INIT : START ' );

    ----- Step 1 truncate Table DMIGTITDMGRNWDT1_INT
    dbms_output.put_line('Truncate DMIGTITDMGRNWDT1_INT : START ' );
    EXECUTE IMMEDIATE ' TRUNCATE TABLE DMIGTITDMGRNWDT1_INT ';
    COMMIT;

    ----- Step 2 Load Data into  DMIGTITDMGRNWDT1_INT from DMIGTITDMGRNWDT1
    dbms_output.put_line('INSERT data into DMIGTITDMGRNWDT1_INT : START ' );

    INSERT  /*+ APPEND PARALLEL(DMIGTITDMGRNWDT1_INT)  */ INTO DMIGTITDMGRNWDT1_INT
         ( CHDRNUM, MBRNO, ZRNDTFRM, ZRNDTTO, ZALTRCDE, ZRNDTREG, ZRNDTAPP, ZINSROLE, STAGECLNTNO
         , ZTERMFLG, ZSALPLAN, ZRNDTRCD, ZINSRNWAGE, INPUT_SOURCE_TABLE)
    SELECT /*+  PARALLEL  */
         CHDRNUM, MBRNO, ZRNDTFRM, ZRNDTTO, ZALTRCDE, ZRNDTREG, ZRNDTAPP, ZINSROLE, STAGECLNTNO
          , ZTERMFLG, ZSALPLAN, ZRNDTRCD, ZINSRNWAGE, INPUT_SOURCE_TABLE
    FROM  DMIGTITDMGRNWDT1
    ;
    COMMIT;

    ---- Step 3 update Referece Key for error table
    dbms_output.put_line('set ZREFKEY : START ' );
     UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
          SET ZREFKEY = (HDR.CHDRNUM || '_' || HDR.ZRNDTFRM  || '_' || HDR.MBRNO || '_' || HDR.ZINSROLE || '_' || HDR.INPUT_SOURCE_TABLE )
      ;
  COMMIT;
    ----Step 4 : update HEADER_RECORD value
    dbms_output.put_line('set HEADER_RECORD : START ' );

    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT
        SET HEADER_RECORD = 1
    WHERE ZINSROLE = 1;
    COMMIT;

    ---Step 5 : update GCHD Status code
    dbms_output.put_line('set STATCODE : START ' );

    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
       SET (  STATCODE , ZPOLTDATE )
         = (SELECT /*+  PARALLEL  */
                GCHD.STATCODE, GCHP.ZPOLTDATE
            FROM CHDRPF GCHD
            INNER JOIN GCHPPF GCHP ON (GCHP.CHDRCOY = GCHD.CHDRCOY AND GCHP.CHDRNUM = GCHD.CHDRNUM)
            WHERE  HDR.CHDRNUM=GCHD.CHDRNUM
                    AND GCHD.CHDRCOY = 1
          )
          ;
    COMMIT;

    ---Step 5 : update data from GMHDPF
    --- update MBR_DTETRM : Insured Termination Date GMHDPF.DTETRM
    dbms_output.put_line('set MBR_DTETRM : START ' );

    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
    SET (  MBR_DTETRM )
       = ( SELECT /*+  PARALLEL  */
              GMHD.DTETRM
          FROM GMHDPF GMHD
          WHERE  HDR.CHDRNUM=GMHD.CHDRNUM 
              AND HDR.MBRNO=GMHD.MBRNO  AND GMHD.CHDRCOY = 1
        )
      ;
    COMMIT;

    --- Step 6 : update client number from PAZDCLPF 
    dbms_output.put_line('set CLNTNUM : START ' );
    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
      SET ( CLNTNUM  )
         = (  SELECT /*+  PARALLEL  */
              PAZDCL.ZIGVALUE
              FROM PAZDCLPF PAZDCL
              WHERE  HDR.STAGECLNTNO=PAZDCL.ZENTITY
            )
            ;
    COMMIT;

    --- Step 7 : update Accumulation check flag ZACCMFLG
    dbms_output.put_line('set ZACCMFLG : START ' );
    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
      SET ZACCMFLG = 'Y'
    WHERE ZRNDTRCD IN (  'A03' , 'A10' ) ;

    COMMIT;

    ---- Step 8 : update CLNTDOB
    dbms_output.put_line('set CLNTDOB : START ' );
    update  /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
    SET ( CLNTDOB ) =
        ( SELECT /*+  PARALLEL  */
            CLPF.CLTDOB
          FROM ZCLNPF CLPF
          WHERE CLPF.CLNTNUM = HDR.CLNTNUM
              AND CLPF.EFFDATE <= HDR.ZRNDTFRM
          ORDER BY  CLPF.EFFDATE DESC, CLPF.DATIME DESC
          FETCH FIRST 1 ROW ONLY
        )
    ;
    COMMIT;

    ---- Step 9 :  update INSURED AGE in case value is not received from source
    UPDATE DMIGTITDMGRNWDT1_INT  INT
      SET ZINSRNWAGE = FLOOR(MONTHS_BETWEEN(TO_DATE(ZRNDTFRM,'YYYYMMDD'),TO_DATE(CLNTDOB,'YYYYMMDD'))/12)
    WHERE TRIM(ZINSRNWAGE) IS NULL  ;
    COMMIT;


     ---- Step 10 : Update SalesPlan for ASRF case
    UPDATE  /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
    SET ( ZSALPLAN ) =
        ( SELECT /*+  PARALLEL  */
          ZINS.ZPLANCDE
            FROM ZINSDTLSPF ZINS
          WHERE ZINS.CHDRNUM = HDR.CHDRNUM
              AND ZINS.MBRNO = HDR.MBRNO
              AND ZINS.EFFDATE <= HDR.ZRNDTFRM
              AND ZINS.TRANNO > 0
          ORDER BY  ZINS.EFFDATE DESC, ZINS.DATIME DESC
          FETCH FIRST 1 ROW ONLY
        )
    WHERE HDR.INPUT_SOURCE_TABLE = 'ASRF_RNW_DTRM'
    ;
    COMMIT;

    ---- Step 11 : Update ASRF Flag
    dbms_output.put_line('set ZASRFFLG : START ' );
    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT1_INT)  */ DMIGTITDMGRNWDT1_INT  HDR
      SET ZASRFFLG = 'Y'
    WHERE ZRNDTRCD IN (  'Q01' , 'Q03' ) ;

    COMMIT;

--- ============================================================================================================
--- ================================= DMIGTITDMGRNWDT2_INT : Coverage and Sub - coverages  =====================
    dbms_output.put_line(' ' );
    dbms_output.put_line('**** DMIGTITDMGRNWDT2_INT Pocessing  : START ******  ' );

    ---- Step 1 : Truncate Table DMIGTITDMGRNWDT2_INT
    dbms_output.put_line(' TRUNCATE DMIGTITDMGRNWDT2_INT : START' );
    EXECUTE IMMEDIATE ' TRUNCATE TABLE DMIGTITDMGRNWDT2_INT ';
    COMMIT;

    ---- Step 2 : Load data into DMIGTITDMGRNWDT2_INT from DMIGTITDMGRNWDT2_INT
    dbms_output.put_line('INSERT data into DMIGTITDMGRNWDT2_INT : START ' );
    INSERT  /*+ APPEND PARALLEL(DMIGTITDMGRNWDT2_INT)  */ INTO DMIGTITDMGRNWDT2_INT
          ( CHDRNUM, MBRNO, DPNTNO, PRODTYP, SUMINS, DPREM, ZINSTYPE,PRODTYP02,NDR_DPREM, INPUT_SOURCE_TABLE)
    SELECT /*+  PARALLEL  */
          CHDRNUM, MBRNO, DPNTNO, PRODTYP, SUMINS, DPREM, ZINSTYPE,TRIM(PRODTYP02),NDR_DPREM, INPUT_SOURCE_TABLE
    FROM  DMIGTITDMGRNWDT2
    ;
    COMMIT;

    ---- Step 3 : update ZINSROLE, ZRNDTFRM FROM header data
    dbms_output.put_line('set ZINSROLE and ZRNDTFRM : START ' );
    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT2_INT)  */  DMIGTITDMGRNWDT2_INT COV
     SET (ZINSROLE, ZRNDTFRM, ZRNDTTO, ZSALPLAN)
          = ( SELECT /*+  PARALLEL  */
              ZINSROLE, ZRNDTFRM, ZRNDTTO, ZSALPLAN
          FROM DMIGTITDMGRNWDT1_INT HDR
         WHERE HDR.CHDRNUM = COV.CHDRNUM AND HDR.MBRNO = COV.MBRNO
      )
      ;
    COMMIT;

    ---- Step 4 : update ODM Premium version : ZODMPRMVER
    dbms_output.put_line('set ZODMPRMVER : START ' );
    UPDATE  /*+  PARALLEL(DMIGTITDMGRNWDT2_INT)  */   DMIGTITDMGRNWDT2_INT COV
        SET ZODMPRMVER =
          ( SELECT /*+  PARALLEL  */
              ODM.VERNO
            FROM DMIGODMVERSIONHIS ODM
            WHERE ODM.ZINSTYPE = COV.ZINSTYPE
            AND ( COV.ZRNDTFRM  BETWEEN ODM.FRMDTE  AND  ODM.TODTE )
          )
      ;
    COMMIT;

    ---- Step 5 : update ZREFKEY for error recrod
    dbms_output.put_line('set ZREFKEY : START ' );

    UPDATE /*+  PARALLEL(DMIGTITDMGRNWDT2_INT)  */ DMIGTITDMGRNWDT2_INT  COV
      SET ZREFKEY = (COV.CHDRNUM || '_' || COV.MBRNO  || '_' || COV.DPNTNO || '_' || COV.PRODTYP  || '_' || COV.INPUT_SOURCE_TABLE )
      ;
    dbms_output.put_line('BQ9UY_RD01_RWRD_INIT : END ' );
  COMMIT;
END BQ9UY_RD01_RWRD_INIT;

/