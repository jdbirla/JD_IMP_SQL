create or replace PROCEDURE RECON_G1ZDRNWDTM (i_schedulenumber IN VARCHAR2 )
 AUTHID CURRENT_USER AS

  /***************************************************************************************************
  * Amendment History: RD01 Renewal Determination
  * Date    Initials  	Tag   	Decription
  * -----   ---------  	----  	----------------------------------------------------------------------------
  * MMMDD   XXX   		  RF0   	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * FEB03   JAY        	RD01   	PA New Implementation for Reconciliation Set 1 task
  *******************************************************************************************************/

  C_MODULE_NAME   CONSTANT  VARCHAR2(40 CHAR) := 'DMRD-Renewal Determination';
  C_PASS          CONSTANT  VARCHAR2(4 CHAR)  := 'PASS';
  C_FAIL          CONSTANT  VARCHAR2(4 CHAR)  := 'FAIL';

  v_srcCount          NUMBER;
  v_stgCount          NUMBER;
  v_igCount           NUMBER;
  v_query_id          VARCHAR2(20 CHAR);
  v_group_clause      VARCHAR2(255 CHAR);
  v_where_clause      VARCHAR2(255 CHAR);
  v_validation_type   VARCHAR2(255 CHAR);
  v_query_desc        VARCHAR2(500 CHAR);
  v_err_tableName_hdr VARCHAR2(10 CHAR);
  v_err_tableName_cov VARCHAR2(10 CHAR);
  v_sqlQuery          VARCHAR2(4000 CHAR);

  p_exitcode        NUMBER;
  p_exittext        VARCHAR2(2000 CHAR);



BEGIN

 DBMS_OUTPUT.PUT_LINE(' ****** Start execution of RECON_G1ZDRNWDTM, SC NO:  ' || i_schedulenumber || '  ****** ' );

 DBMS_OUTPUT.PUT_LINE('Truncating Table RECON_MASTER_RD  ' );

 EXECUTE IMMEDIATE ' TRUNCATE TABLE RECON_MASTER_RD ';
 COMMIT;

 v_err_tableName_hdr := TRIM( ('ZDOERD' || LPAD(TRIM(i_scheduleNumber), 4, '0')) );
 v_err_tableName_cov := TRIM( ('ZDOERC' || LPAD(TRIM(i_scheduleNumber), 4, '0')) );


-- ================================== RNDT01 : individual policy check : ZRNDTHPF =====================================
-- RNDT01 : individual policy check
  v_query_id := 'RNDT01-ZRNDTHPF';
  v_group_clause := '';
  v_validation_type := 'count';

 DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : START -------- ' );

 DBMS_OUTPUT.PUT_LINE(' loading header data from source ');

  INSERT /*+ APPEND PARALLEL(RECON_MASTER_RD)  */ INTO RECON_MASTER_RD
    ( CHDRNUM, ZINSROLE, MBRNO, ZRNDTFRM, ZRNDTTO, SOURCE_VALUE
      ,ZREFKEY , WHERE_CLAUSE
      , SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, VALIDATION_TYPE
    )
  SELECT /*+  PARALLEL  */
      CHDRNUM, ZINSROLE, MBRNO, ZRNDTFRM, ZRNDTTO, '1' AS SOURCE_VALUE
      , (SRC.CHDRNUM || '_' || SRC.ZRNDTFRM  || '_' || SRC.MBRNO || '_' || SRC.ZINSROLE || '_' || SRC.INPUT_SOURCE_TABLE ) AS ZREFKEY
      , ( 'CHDRNUM = ' || CHDRNUM || ' AND ZINSROLE = ' || ZINSROLE || ' AND MBRNO = ' || MBRNO  || ' AND ZRNDTFRM = ' || ZRNDTFRM || ' AND ZRNDTTO = ' || ZRNDTTO  || ' AND JOBNAME = G1ZDRNWDTM ' ) AS WHERE_CLAUSE
      , i_schedulenumber, v_query_id, C_MODULE_NAME, v_group_clause, v_validation_type
      FROM
      (
        SELECT CHDRNUM, ZINSROLE, MBRNO , ZRNDTFRM, ZRNDTTO, INPUT_SOURCE_TABLE
        FROM STAGEDBUSR2.TITDMGRNWDT1@DMSTGUSR2DBLINK
        where ZINSROLE= '1'
      ) SRC ;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('chek with stage table : STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK  ');

  UPDATE RECON_MASTER_RD SCR
  SET STAGING_VALUE = 1
  WHERE
    EXISTS (
      SELECT 1
         FROM STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK STG
          WHERE SCR.CHDRNUM = STG.CHDRNUM
            AND SCR.MBRNO = STG.MBRNO
            AND SCR.ZRNDTFRM = STG.ZRNDTFRM
            AND SCR.ZRNDTTO = STG.ZRNDTTO
            AND STG.ZINSROLE = 1
        )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- MIGRATED SUCESUFULLY
 DBMS_OUTPUT.PUT_LINE('chek with IG table : ZRNDTHPF ');

  UPDATE RECON_MASTER_RD SCR
  SET IG_VALUE = 1
  WHERE 
  EXISTS (
      SELECT 1
         FROM ZRNDTHPF  ZRNDT
          WHERE SCR.CHDRNUM = ZRNDT.CHDRNUM
            AND SCR.ZRNDTFRM = ZRNDT.ZRNDTFRM
            AND SCR.ZRNDTTO = ZRNDT.ZRNDTTO
      )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- PRESENT IN ERROR TABLE
  DBMS_OUTPUT.PUT_LINE('chek with  error table  : ' || v_err_tableName_hdr);

  v_sqlQuery := '
      UPDATE RECON_MASTER_RD SCR
       SET IG_VALUE = 1, IG_ERROR_VALUE = 1
      WHERE EXISTS (
      SELECT 1
         FROM ' || v_err_tableName_hdr || '   HDR_ERR
           WHERE SCR.ZREFKEY = HDR_ERR.ZREFKEY
          AND SCR.SCHEDULE_ID = HDR_ERR.JOBNUM
      )
      AND SCHEDULE_ID =  '''||i_schedulenumber||'''
      AND RECON_QUERY_ID =  '''||v_query_id||'''
    ' ;
    
  EXECUTE IMMEDIATE v_sqlQuery;
  COMMIT;

  ----  updated final status
  DBMS_OUTPUT.PUT_LINE(' Update STATUS ' );
  
  v_query_desc := 'ZINSROLE= 1 ->  IG count: PAZDRDPF/ZRNDTHPF  || Src count: STAGEDBUSR2.TITDMGRNWDT1@DMSTGUSR2DBLINK || Stg count: STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK ';

  UPDATE RECON_MASTER_RD
  SET STATUS = CASE
        WHEN ( SOURCE_VALUE = 1 AND STAGING_VALUE = 1 AND IG_VALUE = 1 )
            THEN C_PASS
        ELSE
            C_FAIL
        END
      , QUERY_DESC = v_query_desc
  WHERE SCHEDULE_ID = i_schedulenumber
  AND RECON_QUERY_ID = v_query_id
  ;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : END -------- ' );

-- ================================== RNDT02 : member level check : ZRNDTHPF =====================================

-- RNDT02 : member level check : ZRNDTHPF
  v_query_id := 'RNDT02-ZRNDTHPF';
  v_group_clause := '';
  v_validation_type := 'count';

  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : START -------- ' );
  
  DBMS_OUTPUT.PUT_LINE(' loading header data from source ');
  
  INSERT /*+ APPEND PARALLEL(RECON_MASTER_RD)  */ INTO RECON_MASTER_RD
    ( CHDRNUM, ZINSROLE, MBRNO, ZRNDTFRM, ZRNDTTO, SOURCE_VALUE
      ,ZREFKEY , WHERE_CLAUSE
      , SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, VALIDATION_TYPE
    )
  SELECT /*+  PARALLEL  */
      CHDRNUM, ZINSROLE, MBRNO, ZRNDTFRM, ZRNDTTO, '1' AS SOURCE_VALUE
      , (SRC.CHDRNUM || '_' || SRC.ZRNDTFRM  || '_' || SRC.MBRNO || '_' || SRC.ZINSROLE || '_' || SRC.INPUT_SOURCE_TABLE ) AS ZREFKEY
      , ( 'CHDRNUM = ' || CHDRNUM || ' AND ZINSROLE = ' || ZINSROLE || ' AND MBRNO = ' || MBRNO  || ' AND ZRNDTFRM = ' || ZRNDTFRM || ' AND ZRNDTTO = ' || ZRNDTTO  || ' AND JOBNAME = G1ZDRNWDTM ' ) AS WHERE_CLAUSE
      , i_schedulenumber, v_query_id, C_MODULE_NAME, v_group_clause, v_validation_type
      FROM
      (
        SELECT CHDRNUM, ZINSROLE, MBRNO , ZRNDTFRM, ZRNDTTO, INPUT_SOURCE_TABLE
        FROM STAGEDBUSR2.TITDMGRNWDT1@DMSTGUSR2DBLINK
      ) SRC ;
  COMMIT;

 DBMS_OUTPUT.PUT_LINE('check with stage table : STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK  ');

  UPDATE RECON_MASTER_RD SCR
  SET STAGING_VALUE = 1
  WHERE 
  EXISTS (
    SELECT 1
       FROM STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK STG
        WHERE SCR.CHDRNUM = STG.CHDRNUM
          AND SCR.MBRNO = STG.MBRNO
          AND SCR.ZRNDTFRM = STG.ZRNDTFRM
          AND SCR.ZRNDTTO = STG.ZRNDTTO
          AND SCR.ZINSROLE = STG.ZINSROLE
  )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- MIGRATED SUCESUFULLY
 DBMS_OUTPUT.PUT_LINE('chek with IG table : ZRNDTDPF ');

  UPDATE RECON_MASTER_RD SCR
  SET IG_VALUE = 1
  WHERE EXISTS (
    SELECT 1
       FROM ZRNDTDPF  ZRNDTD
         WHERE SCR.CHDRNUM = ZRNDTD.CHDRNUM
          AND SCR.MBRNO = ZRNDTD.MBRNO
          AND SCR.ZINSROLE = ZRNDTD.ZINSROLE
   )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
   ;

 ---- PRESENT IN ERROR TABLE
  DBMS_OUTPUT.PUT_LINE('chek with  error table  : ' || v_err_tableName_hdr);

  v_sqlQuery := '
      UPDATE RECON_MASTER_RD SCR
      SET IG_VALUE = 1, IG_ERROR_VALUE = 1
      WHERE EXISTS (
      SELECT 1
         FROM ' || v_err_tableName_hdr || '   HDR_ERR
           WHERE SCR.ZREFKEY = HDR_ERR.ZREFKEY
          AND SCR.SCHEDULE_ID = HDR_ERR.JOBNUM
      )
      AND SCHEDULE_ID =  '''||i_schedulenumber||'''
      AND RECON_QUERY_ID =  '''||v_query_id||'''
    ' ;
    
  EXECUTE IMMEDIATE v_sqlQuery;
  COMMIT;

  -- updated status
  DBMS_OUTPUT.PUT_LINE(' Update STATUS ' );
  v_query_desc := 'ZINSROLE= 1 ->  IG count: PAZDRDPF/ZRNDTDPF  || Src count: STAGEDBUSR2.TITDMGRNWDT1@DMSTGUSR2DBLINK || Stg count: STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK ';

  UPDATE RECON_MASTER_RD
  SET STATUS = CASE
        WHEN ( SOURCE_VALUE = 1 AND STAGING_VALUE = 1 AND IG_VALUE = 1 )
            THEN C_PASS
        ELSE
            C_FAIL
        END
      , QUERY_DESC = v_query_desc
  WHERE SCHEDULE_ID = i_schedulenumber
  AND RECON_QUERY_ID = v_query_id
  ;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : END -------- ' );

-- ================================== RNDT03 : chdrnum - member - Coverage level check : ZRNDTCOVPF =====================================

-- RNDT03 : chdrnum - member - Coverage level check : ZRNDTCOVPF
  v_query_id := 'RNDT03-ZRNDTCOVPF';
  v_group_clause := '';
  v_validation_type := 'count';

 DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : START -------- ' );

 DBMS_OUTPUT.PUT_LINE(' loading header data from source ');

  INSERT /*+ APPEND PARALLEL(RECON_MASTER_RD)  */ INTO RECON_MASTER_RD
    ( CHDRNUM,  MBRNO, DPNTNO,  PRODTYP, ZINSTYPE, SOURCE_VALUE
      ,ZREFKEY , WHERE_CLAUSE
      , SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, VALIDATION_TYPE
    )
  SELECT /*+  PARALLEL  */
      CHDRNUM,  MBRNO, DPNTNO, PRODTYP, ZINSTYPE, '1' AS SOURCE_VALUE
      , (SRC.CHDRNUM || '_' || SRC.MBRNO  || '_' || SRC.DPNTNO || '_' || SRC.PRODTYP  || '_' || SRC.INPUT_SOURCE_TABLE ) AS ZREFKEY
      , ( 'CHDRNUM = ' || CHDRNUM ||  ' AND MBRNO = ' || MBRNO ||  ' AND DPNTNO = ' || DPNTNO  || ' AND PRODTYP = ' || PRODTYP || ' AND ZINSTYPE = ' || ZINSTYPE  || ' AND JOBNAME = G1ZDRNWDTM ' ) AS WHERE_CLAUSE
      , i_schedulenumber, v_query_id, C_MODULE_NAME, v_group_clause, v_validation_type
      FROM
      (
        SELECT CHDRNUM, MBRNO , DPNTNO, PRODTYP, INPUT_SOURCE_TABLE,  ZINSTYPE
        FROM STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK
      ) SRC ;
  COMMIT;


  DBMS_OUTPUT.PUT_LINE('check with stage table : STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK  ');
  UPDATE RECON_MASTER_RD SCR
  SET STAGING_VALUE = 1
  WHERE 
    EXISTS (
        SELECT 1
           FROM STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK STG
            WHERE SCR.CHDRNUM = STG.CHDRNUM
              AND SCR.MBRNO = STG.MBRNO
              AND SCR.DPNTNO = STG.DPNTNO
              AND SCR.PRODTYP = STG.PRODTYP
              AND SCR.ZINSTYPE = STG.ZINSTYPE
      )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- MIGRATED SUCESUFULLY
 DBMS_OUTPUT.PUT_LINE('chek with IG table : ZRNDTCOVPF ');

  UPDATE RECON_MASTER_RD SCR
  SET IG_VALUE = 1
  WHERE 
  EXISTS (
    SELECT 1
       FROM ZRNDTCOVPF  ZRNDTCOV
         WHERE SCR.CHDRNUM = ZRNDTCOV.CHDRNUM
          AND SCR.MBRNO = ZRNDTCOV.MBRNO
          AND SCR.DPNTNO = ZRNDTCOV.DPNTNO
          AND SCR.PRODTYP = ZRNDTCOV.PRODTYP
          AND SCR.ZINSTYPE = ZRNDTCOV.ZINSTYPE
   )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
   ;

  ---- PRESENT IN ERROR TABLE
  DBMS_OUTPUT.PUT_LINE('chek with  error table  : ' || v_err_tableName_cov);

  v_sqlQuery := '
      UPDATE RECON_MASTER_RD SCR
       SET IG_VALUE = 1, IG_ERROR_VALUE = 1
      WHERE EXISTS (
      SELECT 1
         FROM ' || v_err_tableName_cov || '   COV_ERR
           WHERE SCR.ZREFKEY = COV_ERR.ZREFKEY
          AND SCR.SCHEDULE_ID = COV_ERR.JOBNUM
      )
      AND SCHEDULE_ID =  '''||i_schedulenumber||'''
      AND RECON_QUERY_ID =  '''||v_query_id||'''
    ' ;
  EXECUTE IMMEDIATE v_sqlQuery;
  COMMIT;

  ------ update status
  DBMS_OUTPUT.PUT_LINE(' Update STATUS ' );
  v_query_desc := 'IG count: ZRNDTCOVPF  || Src count: STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK || Stg count: STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK ';
  
  UPDATE RECON_MASTER_RD
  SET STATUS = CASE
        WHEN ( SOURCE_VALUE = 1 AND STAGING_VALUE = 1 AND IG_VALUE = 1 )
            THEN C_PASS
        ELSE
            C_FAIL
        END
      , QUERY_DESC = v_query_desc
  WHERE SCHEDULE_ID = i_schedulenumber
  AND RECON_QUERY_ID = v_query_id
  ;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : END -------- ' );


-- ================================== RNDT04 : chdrnum - member - Coverage - subCoverage level check : ZRNDTSUBCOVPF =====================================

-- RNDT04 : chdrnum - member - Coverage - subCoverage level check : ZRNDTSUBCOVPF
  v_query_id := 'RNDT04-ZRNDTSUBCOVPF';
  v_group_clause := '';
  v_validation_type := 'count';

 DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : START -------- ' );

 DBMS_OUTPUT.PUT_LINE(' loading header data from source ');

  INSERT /*+ APPEND PARALLEL(RECON_MASTER_RD)  */ INTO RECON_MASTER_RD
    ( CHDRNUM,  MBRNO, DPNTNO,  PRODTYP, ZINSTYPE, PRODTYP02, SOURCE_VALUE
      ,ZREFKEY , WHERE_CLAUSE
      , SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, VALIDATION_TYPE
    )
  SELECT /*+  PARALLEL  */
      CHDRNUM,  MBRNO, DPNTNO, PRODTYP, ZINSTYPE, PRODTYP02,  '1' AS SOURCE_VALUE
      , (SRC.CHDRNUM || '_' || SRC.MBRNO  || '_' || SRC.DPNTNO || '_' || SRC.PRODTYP  || '_' || SRC.INPUT_SOURCE_TABLE ) AS ZREFKEY
      , (  'PRODTYP02 IS NOT NULL  AND  CHDRNUM = ' || CHDRNUM ||  ' AND MBRNO = ' || MBRNO ||  ' AND DPNTNO = ' || DPNTNO
            || ' AND PRODTYP = ' || PRODTYP  || ' AND PRODTYP02 = ' || PRODTYP02 || ' AND ZINSTYPE = ' || ZINSTYPE  || ' AND JOBNAME = G1ZDRNWDTM ' ) AS WHERE_CLAUSE
      , i_schedulenumber, v_query_id, C_MODULE_NAME, v_group_clause, v_validation_type
  FROM
      (
        SELECT CHDRNUM, MBRNO , DPNTNO, PRODTYP, PRODTYP02, INPUT_SOURCE_TABLE,  ZINSTYPE
        FROM STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK
        WHERE PRODTYP02 IS NOT NULL
      ) SRC ;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('check with stage table PRODTYP02 : STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK  ');

  UPDATE RECON_MASTER_RD SCR
  SET STAGING_VALUE = 1
  WHERE 
    EXISTS (
      SELECT 1
         FROM STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK STG
          WHERE SCR.CHDRNUM = STG.CHDRNUM
            AND SCR.MBRNO = STG.MBRNO
            AND SCR.DPNTNO = STG.DPNTNO
            AND SCR.PRODTYP = STG.PRODTYP
            AND SCR.PRODTYP02 = STG.PRODTYP02
            AND SCR.ZINSTYPE = STG.ZINSTYPE
        )
  AND PRODTYP02 IS NOT NULL
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- MIGRATED SUCESUFULLY
 DBMS_OUTPUT.PUT_LINE('chek with IG table : ZRNDTSUBCOVPF ');

  UPDATE RECON_MASTER_RD SCR
  SET IG_VALUE = 1
  WHERE EXISTS (
  SELECT 1
     FROM ZRNDTSUBCOVPF  SUBCOVER
       WHERE SCR.CHDRNUM = SUBCOVER.CHDRNUM
          AND SCR.MBRNO = SUBCOVER.MBRNO
          AND SCR.DPNTNO = SUBCOVER.DPNTNO
          AND SCR.PRODTYP = SUBCOVER.PRODTYP01
          AND SCR.PRODTYP02 = SUBCOVER.PRODTYP02
  )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- PRESENT IN ERROR TABLE
  DBMS_OUTPUT.PUT_LINE('chek with  error table  : ' || v_err_tableName_cov);

  v_sqlQuery := '
      UPDATE RECON_MASTER_RD SCR
       SET IG_VALUE = 1, IG_ERROR_VALUE = 1
      WHERE EXISTS (
      SELECT 1
         FROM ' || v_err_tableName_cov || '   COV_ERR
           WHERE SCR.ZREFKEY = COV_ERR.ZREFKEY
          AND SCR.SCHEDULE_ID = COV_ERR.JOBNUM
      )
      AND SCHEDULE_ID =  '''||i_schedulenumber||'''
      AND RECON_QUERY_ID =  '''||v_query_id||'''
    ' ;
  EXECUTE IMMEDIATE v_sqlQuery;
  COMMIT;

  ------ update status
  DBMS_OUTPUT.PUT_LINE(' Update STATUS ' );
  v_query_desc := 'IG count: ZRNDTSUBCOVPF  || Src count: STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK || Stg count: STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK ';
  
  UPDATE RECON_MASTER_RD
  SET STATUS = CASE
        WHEN ( SOURCE_VALUE = 1 AND STAGING_VALUE = 1 AND IG_VALUE = 1 )
            THEN C_PASS
        ELSE
            C_FAIL
        END
      , QUERY_DESC = v_query_desc
  WHERE SCHEDULE_ID = i_schedulenumber
  AND RECON_QUERY_ID = v_query_id
  ;
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : END -------- ' );


-- ================================== RNDT05 : chdrnum -insurance Type   level check : ZODMPRMVERPF =====================================

-- RNDT04 :  chdrnum -insurance Type level check : ZRNDTSUBCOVPF
  v_query_id := 'RNDT05-ZODMPRMVERPF';
  v_group_clause := '';
  v_validation_type := 'count';

 DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : START -------- ' );

 DBMS_OUTPUT.PUT_LINE(' loading header data from source ');

  INSERT /*+ APPEND PARALLEL(RECON_MASTER_RD)  */ INTO RECON_MASTER_RD
    ( CHDRNUM,  ZINSTYPE,  SOURCE_VALUE
      ,ZREFKEY , WHERE_CLAUSE
      , SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, VALIDATION_TYPE
    )
  SELECT /*+  PARALLEL  */
      CHDRNUM,  ZINSTYPE,  '1' AS SOURCE_VALUE
      , ZREFKEY AS ZREFKEY
      , (  ' CHDRNUM = ' || CHDRNUM ||  ' AND ZINSTYPE = ' || ZINSTYPE  || ' AND JOBNAME = G1ZDRNWDTM ' ) AS WHERE_CLAUSE
      , i_schedulenumber, v_query_id, C_MODULE_NAME, v_group_clause, v_validation_type
      FROM
      (
       SELECT CHDRNUM, ZINSTYPE, MIN (ZREFKEY) AS ZREFKEY
        FROM (
          SELECT CHDRNUM, MBRNO , DPNTNO, PRODTYP, PRODTYP02, INPUT_SOURCE_TABLE,  ZINSTYPE,
          (CHDRNUM || '_' || MBRNO  || '_' || DPNTNO || '_' ||PRODTYP  || '_' || INPUT_SOURCE_TABLE ) AS ZREFKEY
          FROM STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK
          ) INNR
        GROUP BY CHDRNUM, ZINSTYPE
      ) SRC ;
  COMMIT;


 DBMS_OUTPUT.PUT_LINE('check with stage table ZODMPRMVERPF : STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK  ');
 UPDATE RECON_MASTER_RD SCR
  SET STAGING_VALUE = 1
  WHERE EXISTS (
    SELECT 1 FROM
      (  SELECT CHDRNUM, ZINSTYPE
        FROM STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK
        GROUP BY CHDRNUM, ZINSTYPE
       ) STG
        WHERE SCR.CHDRNUM = STG.CHDRNUM
        AND SCR.ZINSTYPE = STG.ZINSTYPE
  )
  AND SCR.SCHEDULE_ID = i_schedulenumber
  AND SCR.RECON_QUERY_ID = v_query_id
  ;

 ---- MIGRATED SUCESUFULLY
 DBMS_OUTPUT.PUT_LINE('chek with IG table : ZRNDTSUBCOVPF ');

    UPDATE RECON_MASTER_RD SCR
    SET IG_VALUE = 1
    WHERE EXISTS (
      SELECT 1
         FROM ZODMPRMVERPF  ZODMPRMVER
           WHERE SCR.CHDRNUM = ZODMPRMVER.CHDRNUM
            AND SCR.ZINSTYPE = ZODMPRMVER.ZINSTYPE
     )
     AND SCR.SCHEDULE_ID = i_schedulenumber
    AND SCR.RECON_QUERY_ID = v_query_id
     ;

 ---- PRESENT IN ERROR TABLE
  DBMS_OUTPUT.PUT_LINE('chek with  error table  : ' || v_err_tableName_cov);

  v_sqlQuery := '
      UPDATE RECON_MASTER_RD SCR
       SET IG_VALUE = 1, IG_ERROR_VALUE = 1
      WHERE EXISTS (
          SELECT 1
             FROM ' || v_err_tableName_cov || '   COV_ERR
               WHERE SCR.ZREFKEY = COV_ERR.ZREFKEY
              AND SCR.SCHEDULE_ID = COV_ERR.JOBNUM
      )
      AND SCHEDULE_ID =  '''||i_schedulenumber||'''
      AND RECON_QUERY_ID =  '''||v_query_id||'''
    ' ;
  EXECUTE IMMEDIATE v_sqlQuery;
  COMMIT;

  ------ update status
  DBMS_OUTPUT.PUT_LINE(' Update STATUS ' );
  v_query_desc := 'IG count: ZODMPRMVERPF  || Src count: STAGEDBUSR2.TITDMGRNWDT2@DMSTGUSR2DBLINK || Stg count: STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK ';
  
  UPDATE RECON_MASTER_RD
  SET STATUS = CASE
        WHEN ( SOURCE_VALUE = 1 AND STAGING_VALUE = 1 AND IG_VALUE = 1 )
            THEN C_PASS
        ELSE
            C_FAIL
        END
      , QUERY_DESC = v_query_desc
  WHERE SCHEDULE_ID = i_schedulenumber
  AND RECON_QUERY_ID = v_query_id
  ;
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE(' ----  '|| v_query_id ||' : END -------- ' );

  -- ================================== move data to RECON Table =====================================
  DBMS_OUTPUT.PUT_LINE(' inserting into RECON_MASTER  ' );
  INSERT  /*+ APPEND PARALLEL(RECON_MASTER)  */  INTO RECON_MASTER
  (     SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, WHERE_CLAUSE
      , VALIDATION_TYPE, SOURCE_VALUE, STAGING_VALUE, IG_VALUE, STATUS, RUNDATE, QUERY_DESC )
   SELECT /*+  PARALLEL  */
   SCHEDULE_ID, RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, WHERE_CLAUSE, VALIDATION_TYPE, SOURCE_VALUE, STAGING_VALUE, IG_VALUE, STATUS, RUNDATE, QUERY_DESC
   FROM RECON_MASTER_RD
   WHERE SCHEDULE_ID = i_schedulenumber
   ;
  
   DBMS_OUTPUT.PUT_LINE(' ****** Completed execution of RECON_G1ZDRNWDTM, SC NO:  ' || i_schedulenumber || '  ****** ' );
  
  -- ================================== Processing completed =====================================
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line('error: '||sqlerrm);
      p_exitcode := SQLCODE;
      p_exittext := 'DMRD-Renewal Determination' || ' ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
      raise_application_error(-20001, p_exitcode || p_exittext);

END RECON_G1ZDRNWDTM;