CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9UY_RD01_RWRD" (i_scheduleName   IN VARCHAR2 DEFAULT 'G1ZDRNWDTM',
                                                i_scheduleNumber IN VARCHAR2 DEFAULT '0001',
                                                i_zprvaldYN      IN VARCHAR2 DEFAULT 'Y',
                                                i_company        IN VARCHAR2 DEFAULT '1',
                                                i_usrprf         IN VARCHAR2 DEFAULT 'JPAJHA',
                                                i_branch         IN VARCHAR2 DEFAULT '31',
                                                i_transCode      IN VARCHAR2 DEFAULT 'BAJA',
                                                i_vrcmTermid     IN VARCHAR2
                                                )

  AUTHID CURRENT_USER AS
 	/***************************************************************************************************
		* Amendment History: RD01 Renewal Determination
		* Date    Initials  	Tag   	Decription
		* -----   ---------  	----  	----------------------------------------------------------------------------
		* MMMDD   XXX   		  RF0   	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		* JAN08   JAY        	RD01   	PA New Implementation
		*******************************************************************************************************/
  -----Local Vairables-----
  v_timestart          NUMBER := dbms_utility.get_time;
  p_exitcode           NUMBER;
  p_exittext           VARCHAR2(4000);

  C_PREFIX        CONSTANT VARCHAR2(2 CHAR) := Jd1dta.GET_MIGRATION_PREFIX('RWRD', i_company);
  C_PREFIX_COV    CONSTANT VARCHAR2(2 CHAR) := Jd1dta.GET_MIGRATION_PREFIX('RWRC', i_company);
  C_BQ9UY        CONSTANT VARCHAR2(5 CHAR) := 'BQ9UY';

  v_err_tableNametemp_hdr 		VARCHAR2(10);
  v_err_tableName_hdr     		VARCHAR2(10);
  v_err_tableNametemp_cov 		VARCHAR2(10);
  v_err_tableName_cov     		VARCHAR2(10);


BEGIN
  dbms_output.put_line('Start execution of BQ9UY_RD01_RWRD, SC NO:  ' ||
                       i_scheduleNumber || ' Flag :' || i_zprvaldYN);

  --- create Error Tables
  v_err_tableNametemp_hdr := 'ZDOE' || TRIM(C_PREFIX) || LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_err_tableName_hdr     := TRIM(v_err_tableNametemp_hdr);
  v_err_tableNametemp_cov := 'ZDOE' || TRIM(C_PREFIX_COV) || LPAD(TRIM(i_scheduleNumber), 4, '0');
  v_err_tableName_cov     := TRIM(v_err_tableNametemp_cov);

  dbms_output.put_line ('v_err_tableName_hdr' || v_err_tableName_hdr );
  dbms_output.put_line ('v_err_tableName_cov' || v_err_tableName_cov );

  pkg_dm_common_operations.createzdoepf(i_tablename => v_err_tableName_hdr);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_err_tableName_cov);



--- ================ INIT ========================
    -- STEP 1 : Load Data Into Intermediate table  : DMIGTITDMGRNWDT1_INT, DMIGTITDMGRNWDT2_INT
    -- perform transformation logic
    BQ9UY_RD01_RWRD_INIT(i_scheduleName, i_schedulenumber);

--- ================= VALIDATE  =======================
    -- performa validation and load data into error table
    BQ9UY_RD01_RWRD_VALID(  i_schedulename, i_schedulenumber
              , i_err_table_hdr => v_err_tableName_hdr
              , i_err_table_cov => v_err_tableName_cov
    );

--- ================= PROCESS  =======================
    -- process valid data only.
    -- process only if i_zprvaldYN = 'N'
    IF i_zprvaldYN = 'N' THEN
        SAVEPOINT BQ9UY_process_start;

        ---- Assign Renewal number
        ---- Update ZRNDTNUM number FOR DMIGTITDMGRNWDT1_INT
         MERGE INTO DMIGTITDMGRNWDT1_INT HDR
          USING (
                  WITH
                    B AS ( SELECT NVL(ZRNDTNUM,0) AS ZRNDTNUM FROM ZRNWPERDPF ),
                    A AS ( SELECT CHDRNUM, ROWNUM RN  
                            FROM DMIGTITDMGRNWDT1_INT
                            WHERE HEADER_RECORD = 1
                          )
                  SELECT A.CHDRNUM, A.RN, LPAD( (A.RN + B.ZRNDTNUM ), 8, '0' ) RENEWAL_NUM
                  FROM  A, B
                ) RNW_NUM
              ON (HDR.CHDRNUM = RNW_NUM.CHDRNUM   )
            WHEN MATCHED THEN
              UPDATE SET HDR.ZRNDTNUM = RNW_NUM.RENEWAL_NUM
          ;
          COMMIT;

          ---- UPDATE ZRNDTNUM NUMBER FOR DMIGTITDMGRNWDT1_INT
          MERGE INTO DMIGTITDMGRNWDT2_INT COV
          USING (
                  SELECT  COV2.CHDRNUM, COV2.MBRNO, COV2.DPNTNO, COV2.PRODTYP, HDR.ZRNDTNUM
                  FROM DMIGTITDMGRNWDT2_INT COV2
                  INNER JOIN DMIGTITDMGRNWDT1_INT HDR ON (HDR.CHDRNUM = COV2.CHDRNUM AND HDR.MBRNO = COV2.MBRNO)
                ) RNW_NUM
            ON (  COV.CHDRNUM = RNW_NUM.CHDRNUM AND COV.MBRNO = RNW_NUM.MBRNO
                  AND COV.DPNTNO = RNW_NUM.DPNTNO AND COV.PRODTYP = RNW_NUM.PRODTYP  )
          WHEN MATCHED THEN
            UPDATE SET COV.ZRNDTNUM = RNW_NUM.ZRNDTNUM
          ;
          COMMIT;

        -- Load data in IG table, DM Registery Table
         BQ9UY_RD01_RWRD_PROCESS(i_schedulename, i_schedulenumber, i_company, i_usrprf, i_branch, i_transCode);

        --- update Renewal Number in ZRNWPERDPF
          UPDATE ZRNWPERDPF
              SET ZRNDTNUM = (SELECT MAX(ZRNDTNUM) FROM DMIGTITDMGRNWDT1_INT )
          ;
        COMMIT;
    END IF;

-------------------------------------------------------------------

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    p_exitcode := SQLCODE;
    p_exittext := 'BQ9UY_RD01_RWRD : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

     dbms_output.put_line('**** ERRROR ****** ' ||
                       i_scheduleNumber || ' p_exitcode :' || p_exitcode
                       || ' p_exittext :' || p_exittext
                       );
    INSERT INTO Jd1dta.DMBERPF
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    VALUES
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

    COMMIT;

    RAISE;
END BQ9UY_RD01_RWRD;

/