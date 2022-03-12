CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9UY_RD01_RWRD_VALID" (
                                   i_schedulename     IN   VARCHAR2 DEFAULT 'Renewal',
                                   i_schedulenumber   IN   NUMBER DEFAULT 1,
                                   i_err_table_hdr   IN   VARCHAR2 DEFAULT 'ZDOERD0000',
                                   i_err_table_cov   IN   VARCHAR2 DEFAULT 'ZDOERC0000'
)  AUTHID CURRENT_USER AS
 	
  /***************************************************************************************************
		* Amendment History: RD01 Renewal Determination
		* Date    Initials  	Tag   	Decription
		* -----   ---------  	----  	----------------------------------------------------------------------------
		* MMMDD   XXX   		  RF0   	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		* JAN08   JAY        	RD01   	PA New Implementation
		*******************************************************************************************************/
  ----------Constant--------------
  C_RQ06 CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicate record found. */
  C_RQ06_DESC  VARCHAR2(30) := 'Duplicated record found';

  C_RQW3 CONSTANT VARCHAR2(4) := 'RQW3';
  C_RQW3_DESC  VARCHAR2(30) := 'Policy Terminated';

  C_W247 CONSTANT VARCHAR2(4) := 'W247';
  C_W247_DESC  VARCHAR2(30) := 'Mmbr already terminated';

  C_RQNW CONSTANT VARCHAR2(4) := 'RQNW';
  C_RQNW_DESC  VARCHAR2(30) := 'ZPLANCDE is mandatory';

  C_RQLP CONSTANT VARCHAR2(4) := 'RQLP';
  C_RQLP_DESC  VARCHAR2(30) := 'Sales Plan not valid';

  C_RSBU CONSTANT VARCHAR2(4) := 'RSBU';
  C_RSBU_DESC  VARCHAR2(30) := 'InsType nt eqlto SetPlan';

  C_PA71 CONSTANT VARCHAR2(4) := 'PA71';
  C_PA71_DESC CONSTANT VARCHAR2(30) := 'Policy HeaderInsured error';

  C_PA72 CONSTANT VARCHAR2(4) := 'PA72';
  C_PA72_DESC CONSTANT VARCHAR2(30) := 'CoverageSubcoverage error';

  C_RQRN CONSTANT VARCHAR2(4) := 'RQRN';
  C_RQRN_DESC VARCHAR2(30) := 'cancellation TRX in pol';
  
   C_RQMB CONSTANT VARCHAR2(4) := 'RQMB';
  C_RQMB_DESC  VARCHAR2(30) := 'Pol is not yet migr GCHD';

  C_FILENAME_DMIGTITDMGRNWDT1 CONSTANT VARCHAR2(20) := 'DMIGTITDMGRNWDT1';
  C_FILENAME_DMIGTITDMGRNWDT2 CONSTANT VARCHAR2(20) := 'DMIGTITDMGRNWDT2';

  v_sqlQuery VARCHAR2(4000 CHAR);
  --------------Common Function Start---------
  o_errortext     pkg_dm_common_operations.errordesc;

BEGIN
  COMMIT;

  dbms_output.put_line('*********  BQ9UY_RD01_RWRD_VALID : START  ***************' );

  ---------Get Error Description ------------
  pkg_dm_common_operations.geterrordesc(i_module_name => 'RWRD',
                                        o_errortext   => o_errortext);
  C_RQ06_DESC :=  o_errortext(C_RQ06);
  C_RQW3_DESC :=  o_errortext(C_RQW3);
  C_W247_DESC :=  o_errortext(C_W247);
  C_RQNW_DESC :=  o_errortext(C_RQNW);
  C_RQLP_DESC :=  o_errortext(C_RQLP);
  C_RSBU_DESC :=  o_errortext(C_RSBU);
  C_RQRN_DESC :=  o_errortext(C_RQRN);
  C_RQMB_DESC :=  o_errortext(C_RQMB);

  dbms_output.put_line('i_schedulename : ' || i_schedulename );
  dbms_output.put_line(' i_schedulenumber ' || i_schedulenumber);
  dbms_output.put_line(' i_err_table_hdr ' || i_err_table_hdr);
  dbms_output.put_line(' i_err_table_cov ' || i_err_table_cov);


  -- Step 1 :  Truncate intermediate error table  ZDOERD_INT, ZDOERC_INT
    EXECUTE IMMEDIATE ' TRUNCATE TABLE ZDOERD_INT ';
    EXECUTE IMMEDIATE ' TRUNCATE TABLE ZDOERC_INT ';
    COMMIT;

--- ============================================================================================================
--- ================================= Validate DMIGTITDMGRNWDT1_INT ============================================

  --- Validation 1 : C_RQ06 = Record is already processed recrods (Present in Registery table)
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
        (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
    SELECT /*+  PARALLEL  */  
          CHDRNUM, MBRNO, ZREFKEY,  'CHDRNUM' AS ERRFLD, CHDRNUM AS FLDVALU
          , C_RQ06, C_RQ06_DESC, INPUT_SOURCE_TABLE , I_SCHEDULENAME, I_SCHEDULENUMBER
    FROM  DMIGTITDMGRNWDT1_INT HDR
    WHERE EXISTS
          ( SELECT 1 FROM PAZDRDPF PAZDRD WHERE HDR.CHDRNUM = PAZDRD.CHDRNUM )
    ;
    COMMIT;

  --- Validation 2  : C_RQW3 = Policy is Cancalled or Lapsed.
   INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
        (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
   SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,  'STATCODE' as ERRFLD, STATCODE as FLDVALU
        , C_RQW3, C_RQW3_DESC, INPUT_SOURCE_TABLE , i_schedulename, i_schedulenumber
    FROM  DMIGTITDMGRNWDT1_INT
    WHERE STATCODE in ('LA', 'CA')
  ;
  COMMIT;

  --- Validation 3 : C_RQRN = Policy has future dated termination.
   INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
        (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
   SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,  'STATCODE' as ERRFLD, STATCODE as FLDVALU, C_RQRN, C_RQRN_DESC, INPUT_SOURCE_TABLE , i_schedulename, i_schedulenumber
    FROM  DMIGTITDMGRNWDT1_INT
    WHERE STATCODE = 'IF' 
          AND (  ZPOLTDATE IS NOT NULL AND ZPOLTDATE <> 0 AND ZPOLTDATE <> '99999999' )
    ;
    COMMIT;

  --- Validation 3 : C_W247 = Insured is terminated

    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
       (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
    SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY, 'MBR_DTETRM' as ERRFLD, MBR_DTETRM as FLDVALU, C_W247, C_W247_DESC
        , INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
    FROM  DMIGTITDMGRNWDT1_INT
    WHERE MBR_DTETRM IS NULL OR MBR_DTETRM = 0 OR MBR_DTETRM <> '99999999' 
    ;
    COMMIT;

  --- Validation 4 : C_RQNW = Sales Plan is not present other than ASRF case
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
        (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
     SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,  'ZSALPLAN' as ERRFLD, ZSALPLAN as FLDVALU, C_RQNW, C_RQNW_DESC
        , INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
      FROM  DMIGTITDMGRNWDT1_INT
      WHERE INPUT_SOURCE_TABLE <> 'ASRF_RNW_DTRM' AND ( TRIM(ZSALPLAN) IS NULL  )
    ;
    COMMIT;


  --- Validation 5 : SalesPlan code is not present in SalesPlan Master ZSLPPF
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
          (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
     SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,  'ZSALPLAN' as ERRFLD, ZSALPLAN as FLDVALU, C_RQLP, C_RQLP_DESC
        , INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
      FROM  DMIGTITDMGRNWDT1_INT HDR
      WHERE  NOT EXISTS (
          SELECT 1 FROM ZSLPPF WHERE ZSLPPF.ZSALPLAN  = HDR.ZSALPLAN
      );
      COMMIT;
      
    --- VALIDATION 6 : POLICY IS NOT PRESENT IN GCHD. 
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
          (CHDRNUM, MBRNO, ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
     SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,  'ZSALPLAN' AS ERRFLD, ZSALPLAN AS FLDVALU, C_RQMB, C_RQMB_DESC
        , INPUT_SOURCE_TABLE, I_SCHEDULENAME, I_SCHEDULENUMBER
      FROM  DMIGTITDMGRNWDT1_INT HDR
       WHERE  NOT EXISTS (
          SELECT 1 FROM CHDRPF GCHD WHERE GCHD.CHDRNUM  = HDR.CHDRNUM
      );
      COMMIT;

--- ============================================================================================================
--- ================================= Validate DMIGTITDMGRNWDT2_INT ============================================
  --- Validation 1 : C_RQ06 = Record is already processed recrods (Present in Registery table)

    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERC_INT 
        (CHDRNUM, MBRNO, PRODTYP,  ZREFKEY,  ZFILENME, JOBNAME, JOBNUM 
              , ERRFLD, FLDVALU, ERRCD, ERRMSG )
    SELECT /*+  PARALLEL  */  
         COV.CHDRNUM, COV.MBRNO, COV.PRODTYP, COV.ZREFKEY, COV.INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
        , 'CHDRNUM' as ERRFLD, COV.CHDRNUM as FLDVALU , C_RQ06, C_RQ06_DESC
      FROM  DMIGTITDMGRNWDT2_INT COV
      WHERE EXISTS  
        ( SELECT 1 FROM PAZDRCPF PAZDRC WHERE COV.CHDRNUM = PAZDRC.CHDRNUM )
    ;
    COMMIT;

  --- Validation 2 : C_RQLP = product code is not matching with SalesPlan Master for main insured
 --- Fixed by JD : start
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERC_INT 
        (CHDRNUM, MBRNO,DPNTNO, PRODTYP,  ZREFKEY,  ZFILENME, JOBNAME, JOBNUM 
          , ERRFLD, FLDVALU, ERRCD, ERRMSG )
     SELECT /*+  PARALLEL  */  
        COV.CHDRNUM, COV.MBRNO,COV.DPNTNO, COV.PRODTYP, COV.ZREFKEY, COV.INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
        ,  'PRODTYP' as ERRFLD, COV.PRODTYP as FLDVALU, C_RQLP, C_RQLP_DESC
      FROM  DMIGTITDMGRNWDT2_INT COV
          LEFT OUTER JOIN ZSLPPF ZSLP ON (ZSLP.ZSALPLAN = COV.ZSALPLAN AND ZSLP.PRODTYP = COV.PRODTYP)
      WHERE (COV.SUMINS <> ZSLP.SUMINS OR COV.ZINSTYPE <> ZSLP.ZINSTYPE
            OR ZSLP.SUMINS IS NULL) AND COV.DPNTNO='00';
      COMMIT;

      
        --- Validation 2 : C_RQLP = product code is not matching with SalesPlan Master for main spouse

  INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERC_INT 
        (CHDRNUM, MBRNO, DPNTNO,PRODTYP,  ZREFKEY,  ZFILENME, JOBNAME, JOBNUM 
          , ERRFLD, FLDVALU, ERRCD, ERRMSG )
     SELECT /*+  PARALLEL  */  
        COV.CHDRNUM, COV.MBRNO,COV.DPNTNO, COV.PRODTYP, COV.ZREFKEY, COV.INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
        ,  'PRODTYP' as ERRFLD, COV.PRODTYP as FLDVALU, C_RQLP, C_RQLP_DESC
      FROM  DMIGTITDMGRNWDT2_INT COV
          LEFT OUTER JOIN ZSLPPF ZSLP ON (ZSLP.ZSALPLAN = COV.ZSALPLAN AND ZSLP.PRODTYP = COV.PRODTYP)
      WHERE (COV.SUMINS <> ZSLP.ZSUMINUSP OR COV.ZINSTYPE <> ZSLP.ZINSTYPE
            OR ZSLP.ZSUMINUSP IS NULL) AND COV.DPNTNO='01';
      COMMIT;

         --- Validation 2 : C_RQLP = product code is not matching with SalesPlan Master for main relative

  INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERC_INT 
        (CHDRNUM, MBRNO, DPNTNO,PRODTYP,  ZREFKEY,  ZFILENME, JOBNAME, JOBNUM 
          , ERRFLD, FLDVALU, ERRCD, ERRMSG )
     SELECT /*+  PARALLEL  */  
        COV.CHDRNUM, COV.MBRNO, COV.DPNTNO,COV.PRODTYP, COV.ZREFKEY, COV.INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
        ,  'PRODTYP' as ERRFLD, COV.PRODTYP as FLDVALU, C_RQLP, C_RQLP_DESC
      FROM  DMIGTITDMGRNWDT2_INT COV
          LEFT OUTER JOIN ZSLPPF ZSLP ON (ZSLP.ZSALPLAN = COV.ZSALPLAN AND ZSLP.PRODTYP = COV.PRODTYP)
      WHERE (COV.SUMINS <> ZSLP.ZSUMINURV OR COV.ZINSTYPE <> ZSLP.ZINSTYPE
            OR ZSLP.ZSUMINURV IS NULL) AND COV.DPNTNO='02';
       
      
      COMMIT;
--- Fixed by JD : END
--- ============================================================================================================
--- ================================= Common Error processing ==================================================

--------- Common Processing for DMIGTITDMGRNWDT1_INT and ZDOERD_INT  -------------------------

    --- update ERRINSCNT : insured level error count 
    MERGE INTO  DMIGTITDMGRNWDT1_INT HDR 
     USING 
     ( select CHDRNUM, MBRNO, ZREFKEY, count(1) cnt  from ZDOERD_INT 
        group by CHDRNUM, MBRNO, ZREFKEY ) HDR_ERR
        ON (HDR.CHDRNUM = HDR_ERR.CHDRNUM AND HDR.MBRNO = HDR_ERR.MBRNO 
            AND HDR.ZREFKEY = HDR_ERR.ZREFKEY    )
    WHEN MATCHED THEN
       UPDATE SET ERRINSCNT = HDR_ERR.CNT
    ;
    COMMIT;


    ---- update DMIGTITDMGRNWDT1_INT set ISCOVERR -------------------------
    UPDATE DMIGTITDMGRNWDT1_INT HDR
        SET HDR.ISCOVERR = 1
    WHERE HDR.CHDRNUM IN (SELECT CHDRNUM FROM ZDOERC_INT );
    COMMIT;

    --- If coverage has error then corresponding Insured / header record should move to erorr
    -- so set ISCOVERR = 1
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERD_INT 
     (CHDRNUM, MBRNO,  ZREFKEY, ERRFLD, FLDVALU, ERRCD, ERRMSG, ZFILENME, JOBNAME, JOBNUM  )
     SELECT /*+  PARALLEL  */  
        CHDRNUM, MBRNO, ZREFKEY,   'ISCOVERR' as ERRFLD, ISCOVERR as FLDVALU, C_PA72, C_PA72_DESC
        , INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
      FROM  DMIGTITDMGRNWDT1_INT HDR
      where ISCOVERR = 1
    ;
    COMMIT;

    --- Update MBRERRCNT
    MERGE INTO ZDOERD_INT ERD
    USING (
         SELECT ROWID, CHDRNUM, MBRNO, ERRCD, ZREFKEY, MBR_ERR_CNT 
         , ROW_NUMBER() OVER (PARTITION BY CHDRNUM,MBRNO ORDER BY DATIME, MBRNO ) RN
         FROM ZDOERD_INT
      ) RNW_NUM
      ON (ERD.ROWID = RNW_NUM.ROWID )
      WHEN MATCHED THEN 
          UPDATE SET ERD.MBR_ERR_CNT = RNW_NUM.RN
       ;
     COMMIT;

    -- update ERRCHDR and indicator for error recrods
    UPDATE  DMIGTITDMGRNWDT1_INT HDR
      SET HDR.ERRCHDR = 1, HDR.INDIC = 'E'
    WHERE ( ISCOVERR > 0 OR ERRINSCNT > 0 )
    ;
    COMMIT;

  -- update indicator for valid recrods
    UPDATE  DMIGTITDMGRNWDT1_INT HDR
      SET HDR.INDIC = 'S'
    WHERE ( ERRCHDR = 0 )
    ;
    COMMIT;

--------- Common Processing for DMIGTITDMGRNWDT2_INT and ZDOERC_INT  -------------------------

    --------- Set total Coverage error count : ERRCOVCNT 
     MERGE INTO  DMIGTITDMGRNWDT2_INT COV 
     USING 
     ( SELECT CHDRNUM, MBRNO, DPNTNO, PRODTYP, COUNT(1) CNT  FROM ZDOERC_INT 
        GROUP BY CHDRNUM, MBRNO, DPNTNO, PRODTYP ) COV_ERR
        ON (COV.CHDRNUM = COV_ERR.CHDRNUM AND COV.MBRNO = COV_ERR.MBRNO 
            AND COV.DPNTNO = COV_ERR.DPNTNO AND COV.PRODTYP = COV_ERR.PRODTYP    )
    WHEN MATCHED THEN
       UPDATE SET ERRCOVCNT = COV_ERR.CNT
    ;
   COMMIT;

    ------ update ISHDRERR error form DMIGTITDMGRNWDT2_INT 
      UPDATE DMIGTITDMGRNWDT2_INT COV
      SET COV.ISHDRERR = 1
      WHERE COV.CHDRNUM IN (SELECT CHDRNUM FROM DMIGTITDMGRNWDT1_INT WHERE ERRINSCNT > 0);
      COMMIT;


    --- If HEADER has error then corresponding coverages record should move to erorr
    INSERT /*+ APPEND PARALLEL(ZDOERD_INT)  */  INTO ZDOERC_INT 
         (CHDRNUM, MBRNO, PRODTYP,  ZREFKEY,  ZFILENME, JOBNAME, JOBNUM 
           , ERRFLD, FLDVALU, ERRCD, ERRMSG )
     SELECT /*+  PARALLEL  */  
        COV.CHDRNUM, COV.MBRNO, COV.PRODTYP, COV.ZREFKEY, COV.INPUT_SOURCE_TABLE, i_schedulename, i_schedulenumber
        ,  'ISHDRERR' as ERRFLD, COV.ISHDRERR as FLDVALU, C_PA71, C_PA71_DESC
      FROM  DMIGTITDMGRNWDT2_INT COV
        WHERE ISHDRERR = 1
     ;
    COMMIT;


    ---UPDATE MBRERRCNT
    MERGE INTO ZDOERC_INT ERD
    USING (
           SELECT CHDRNUM, MBRNO, DPNTNO, PRODTYP, ERRCD, ROWID, ZREFKEY
          , ROW_NUMBER() OVER (PARTITION BY CHDRNUM,MBRNO, DPNTNO, PRODTYP ORDER BY DATIME, MBRNO ) RN
          FROM ZDOERC_INT
     ) RNW_NUM
        ON (ERD.ROWID = RNW_NUM.ROWID )
    WHEN MATCHED THEN 
      UPDATE SET ERD.COV_ERR_CNT = RNW_NUM.RN
    ;
    COMMIT;

    -- update ERRCHDR and indicator for error recrods
    UPDATE  DMIGTITDMGRNWDT2_INT COV
    SET COV.ERRCHDR = 1, COV.INDIC='E'
    WHERE ( ISHDRERR > 0 OR ERRCOVCNT > 0 )
    ;
    COMMIT;

    -- update indicator for valid recrods
    UPDATE  DMIGTITDMGRNWDT2_INT COV
       SET COV.INDIC='S'
    WHERE ( COV.ERRCHDR = 0 )
    ;
    COMMIT;


    --- INSERT DATA INTO Header Error Table : i_err_table_hdr

    v_sqlQuery := '
    INSERT /*+ APPEND PARALLEL(' || i_err_table_hdr || ' )  */ INTO ' || i_err_table_hdr || '  
    (  RECIDXOKEROR,  RECSTATUS,  ZREFKEY,  ZFILENME
    ,  EROR01,  ERRMESS01,  ERORFLD01,  FLDVALU01,  ERORPROG01
    ,  EROR02,  ERRMESS02,  ERORFLD02,  FLDVALU02,  ERORPROG02
    ,  EROR03,  ERRMESS03,  ERORFLD03,  FLDVALU03,  ERORPROG03
    ,  EROR04,  ERRMESS04,  ERORFLD04,  FLDVALU04,  ERORPROG04
    ,  EROR05,  ERRMESS05,  ERORFLD05,  FLDVALU05,  ERORPROG05
    ,  JOBNUM,  INDIC 
    )

    SELECT /*+  PARALLEL  */  
    Jd1dta.SEQ_ZDOEPF.nextval as RECIDXOKEROR , ''New'' as RECSTATUS
    , ER1.ZREFKEY AS ZREFKEY , '''||C_FILENAME_DMIGTITDMGRNWDT1||''' AS ZFILENME
    , ER1.ERRCD AS EROR01, ER1.ERRMSG AS ERRMESS01 , ER1.ERRFLD AS ERORFLD01,  ER1.FLDVALU AS  FLDVALU01, ER1.JOBNAME  AS ERORPROG01
    , ER2.ERRCD AS EROR02, ER2.ERRMSG AS ERRMESS02 , ER2.ERRFLD AS ERORFLD02,  ER2.FLDVALU AS  FLDVALU02, ER2.JOBNAME  AS ERORPROG02
    , ER3.ERRCD AS EROR03, ER3.ERRMSG AS ERRMESS03 , ER3.ERRFLD AS ERORFLD03,  ER3.FLDVALU AS  FLDVALU03, ER3.JOBNAME  AS ERORPROG03
    , ER4.ERRCD AS EROR04, ER4.ERRMSG AS ERRMESS04 , ER4.ERRFLD AS ERORFLD04,  ER4.FLDVALU AS  FLDVALU04, ER4.JOBNAME  AS ERORPROG04
    , ER5.ERRCD AS EROR05, ER5.ERRMSG AS ERRMESS05 , ER5.ERRFLD AS ERORFLD05,  ER5.FLDVALU AS  FLDVALU05, ER5.JOBNAME  AS ERORPROG05
    , ER1.JOBNUM  AS JOBNUM  , ''E'' AS INDIC
    from ZDOERD_INT ER1
    LEFT OUTER JOIN ZDOERD_INT ER2 ON (ER2.MBR_ERR_CNT = 2 AND ER2.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERD_INT ER3 ON (ER3.MBR_ERR_CNT = 3 AND ER3.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERD_INT ER4 ON (ER4.MBR_ERR_CNT = 4 AND ER4.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERD_INT ER5 ON (ER5.MBR_ERR_CNT = 5 AND ER5.ZREFKEY = ER1.ZREFKEY )
    WHERE ER1.MBR_ERR_CNT =1
    '
    ;
    EXECUTE IMMEDIATE v_sqlQuery;
    COMMIT;

     --- INSERT DATA INTO Coverage Error Table : i_err_table_cov
    v_sqlQuery := '
    INSERT /*+ APPEND PARALLEL(' || i_err_table_cov || ' )  */ INTO ' || i_err_table_cov || '  
    (  RECIDXOKEROR,  RECSTATUS,  ZREFKEY,  ZFILENME
    ,  EROR01,  ERRMESS01,  ERORFLD01,  FLDVALU01,  ERORPROG01
    ,  EROR02,  ERRMESS02,  ERORFLD02,  FLDVALU02,  ERORPROG02
    ,  EROR03,  ERRMESS03,  ERORFLD03,  FLDVALU03,  ERORPROG03
    ,  EROR04,  ERRMESS04,  ERORFLD04,  FLDVALU04,  ERORPROG04
    ,  EROR05,  ERRMESS05,  ERORFLD05,  FLDVALU05,  ERORPROG05
    ,  JOBNUM,  INDIC 
    )

    select /*+  PARALLEL  */  
    Jd1dta.SEQ_ZDOEPF.nextval as RECIDXOKEROR , ''New'' as RECSTATUS
    , ER1.ZREFKEY AS ZREFKEY , '''||C_FILENAME_DMIGTITDMGRNWDT2||''' AS ZFILENME
    , ER1.ERRCD AS EROR01, ER1.ERRMSG AS ERRMESS01 , ER1.ERRFLD AS ERORFLD01,  ER1.FLDVALU AS  FLDVALU01, ER1.JOBNAME  AS ERORPROG01
    , ER2.ERRCD AS EROR02, ER2.ERRMSG AS ERRMESS02 , ER2.ERRFLD AS ERORFLD02,  ER2.FLDVALU AS  FLDVALU02, ER2.JOBNAME  AS ERORPROG02
    , ER3.ERRCD AS EROR03, ER3.ERRMSG AS ERRMESS03 , ER3.ERRFLD AS ERORFLD03,  ER3.FLDVALU AS  FLDVALU03, ER3.JOBNAME  AS ERORPROG03
    , ER4.ERRCD AS EROR04, ER4.ERRMSG AS ERRMESS04 , ER4.ERRFLD AS ERORFLD04,  ER4.FLDVALU AS  FLDVALU04, ER4.JOBNAME  AS ERORPROG04
    , ER5.ERRCD AS EROR05, ER5.ERRMSG AS ERRMESS05 , ER5.ERRFLD AS ERORFLD05,  ER5.FLDVALU AS  FLDVALU05, ER5.JOBNAME  AS ERORPROG05
    , ER1.JOBNUM  AS JOBNUM  , ''E'' AS INDIC
    from ZDOERC_INT ER1
    LEFT OUTER JOIN ZDOERC_INT ER2 ON (ER2.COV_ERR_CNT = 2 AND ER2.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERC_INT ER3 ON (ER3.COV_ERR_CNT = 3 AND ER3.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERC_INT ER4 ON (ER4.COV_ERR_CNT = 4 AND ER4.ZREFKEY = ER1.ZREFKEY )
    LEFT OUTER JOIN ZDOERC_INT ER5 ON (ER5.COV_ERR_CNT = 5 AND ER5.ZREFKEY = ER1.ZREFKEY )
    WHERE ER1.COV_ERR_CNT =1
    '
    ;
    EXECUTE IMMEDIATE v_sqlQuery;
    COMMIT;


    ---- Insert  successful recrod in error tables with indic =S
    v_sqlQuery := '
    INSERT /*+ APPEND PARALLEL(' || i_err_table_hdr || ' )  */ INTO ' || i_err_table_hdr || '  
        (  RECIDXOKEROR,  RECSTATUS,  ZREFKEY,  ZFILENME,  JOBNUM,  INDIC )
    SELECT /*+  PARALLEL  */  
         Jd1dta.SEQ_ZDOEPF.nextval as RECIDXOKEROR , ''New'' as RECSTATUS
            , HDR.ZREFKEY AS ZREFKEY , '''||C_FILENAME_DMIGTITDMGRNWDT1||''' AS ZFILENME
            , ' || i_schedulenumber || '    AS JOBNUM  , ''S'' AS INDIC
     FROM DMIGTITDMGRNWDT1_INT HDR
     WHERE HDR.INDIC =  ''S'' 
     '
    ;
    EXECUTE IMMEDIATE v_sqlQuery;
    COMMIT;

    --- INSERT DATA INTO ZDOERC0000
    v_sqlQuery := '
      INSERT /*+ APPEND PARALLEL(' || i_err_table_cov || ' )  */ INTO ' || i_err_table_cov || '  
          (  RECIDXOKEROR,  RECSTATUS,  ZREFKEY,  ZFILENME,  JOBNUM,  INDIC )
      SELECT /*+  PARALLEL  */  
          Jd1dta.SEQ_ZDOEPF.nextval as RECIDXOKEROR , ''New'' as RECSTATUS
          , COV.ZREFKEY AS ZREFKEY , '''||C_FILENAME_DMIGTITDMGRNWDT2||''' AS ZFILENME
          , ' || i_schedulenumber || '    AS JOBNUM    , ''S'' AS INDIC
      FROM DMIGTITDMGRNWDT2_INT COV
      WHERE COV.INDIC =  ''S'' 
      '
      ;
    EXECUTE IMMEDIATE v_sqlQuery;
    COMMIT;


dbms_output.put_line('*********  BQ9UY_RD01_RWRD_VALID : END  ***************' );

END BQ9UY_RD01_RWRD_VALID;

/