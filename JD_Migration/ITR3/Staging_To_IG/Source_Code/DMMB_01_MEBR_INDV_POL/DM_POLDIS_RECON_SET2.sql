create or replace PROCEDURE                                                    DM_POLDIS_RECON_SET2 (p_detail_batch_id IN VARCHAR2, p_summary_batch_id IN VARCHAR2) 
AS
    
  /*
  **************************************************************************************************
  * Amendment History: Policy Dishonor Reconciliation Set 2
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD   XXX    PD0   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * NOV10	  ABG	   PD1   Initial Version
  **************************************************************************************************
  */    

  -------------------------------- START - Variables and Constants ---------------------------------
  c_module_name        varchar2(30)  := 'Policy Dishonor';
  c_statcode           varchar2(30)  := 'OLD_POLICY_STATCODE';
  c_chdrnum            varchar2(30)  := 'CHDRNUM';
  c_eff_desc           varchar2(30)  := 'Commencement Date';
  c_created_by         varchar2(10)  := 'JPAAGP';
  c_job_name           varchar2(30)  := 'DM_POLDIS_RECON_SET2';
  c_prog_name          varchar2(50)  := 'RECON_SET2_PD_G1ZDPOLDSH';
  c_limit              PLS_INTEGER   := 1000;

  v_src_value          varchar2(10);
  v_stg_value          varchar2(10);
  v_ig_value           varchar2(10);

  p_exitcode           number;
  p_exittext           varchar2(2000);

  --------------------------------- END - Variables and Constants ------------------------------------

  ----------------------------------- Cursor for STATCODE attribute -----------------------------------
  CURSOR cur_statcode IS  
    SELECT TRIM(pdsrc.OLDPOLNUM) AS OLDPOLNUM, TRIM(reconsrc.V_PRD_CDE) AS PROD_CDE, 
    TRIM(reconsrc.D_POL_START_DT) AS POL_COMMDT, TRIM(reconsrc.V_POL_STATUS) AS POL_STATUS, 
    TRIM(ig.STATCODE) AS IG_STATCODE, TRIM(stg.STATCODE) AS STG_STATCODE, TRIM(src.STATCODE) AS SRC_STATCODE
    FROM STAGEDBUSR2.TITDMGMBRINDP3@DMSTGUSR2DBLINK pdsrc 
    INNER JOIN STAGEDBUSR2.DM_POLICY_RECON@DMSTGUSR2DBLINK reconsrc ON TRIM(pdsrc.OLDPOLNUM) = TRIM(reconsrc.V_POLICY_NO) 
    INNER JOIN Jd1dta.GCHD ig ON TRIM(pdsrc.OLDPOLNUM) = TRIM(ig.CHDRNUM)
    INNER JOIN STAGEDBUSR.TITDMGMBRINDP1@DMSTAGEDBLINK stg ON TRIM(pdsrc.OLDPOLNUM) = TRIM(SUBSTR(stg.REFNUM,1,8)) 
    AND SUBSTR(stg.REFNUM,9,3) = (SELECT MAX(SUBSTR(stg1.REFNUM,9,3)) FROM STAGEDBUSR.TITDMGMBRINDP1@DMSTAGEDBLINK stg1 
    WHERE SUBSTR(stg.REFNUM,1,8) = SUBSTR(stg1.REFNUM,1,8)) AND stg.CLIENT_CATEGORY = 0 
    INNER JOIN 
    (SELECT     CASE
                            WHEN c.rptfpst = 'F' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        'IF'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'CA', 'IF')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'IF'
                                    WHEN a.apblst = '5' THEN
                                        'CA'
                            END
                            WHEN c.rptfpst = 'P' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        nvl2(pj.btdate, pj.statcode, 'XN')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) = '*' THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NULL THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        'IF'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        nvl2(pj.btdate, pj.statcode, 'XN')
                                    WHEN a.apblst = '5' THEN
                                        'CA'
                            END
                        END STATCODE, SUBSTR(A.APCUCD,1,8) AS OLDPOLNUM 
                  FROM STAGEDBUSR2.ZMRAP00@DMSTGUSR2DBLINK a LEFT JOIN STAGEDBUSR2.ZMRRPT00@DMSTGUSR2DBLINK c 
                  ON a.APC7CD = c.RPTBTCD LEFT JOIN STAGEDBUSR2.BTDATE_PTDATE_LIST@DMSTGUSR2DBLINK pj ON SUBSTR(a.APCUCD,1,8) = pj.CHDRNUM
                  WHERE SUBSTR(a.APCUCD,9,3) = (SELECT MAX(SUBSTR(d.APCUCD,9,3)) FROM STAGEDBUSR2.ZMRAP00@DMSTGUSR2DBLINK d 
                  WHERE SUBSTR(a.APCUCD,1,8) = SUBSTR(d.APCUCD,1,8))) src 
                  ON TRIM(pdsrc.OLDPOLNUM) = TRIM(src.OLDPOLNUM);

  TYPE typ_cur_statcode IS TABLE OF cur_statcode%ROWTYPE;
   cur_statcode_list typ_cur_statcode;
   
  --------------------------------------- Cursor for CHDRNUM attribute --------------------------------
   CURSOR cur_chdrnum IS  
    SELECT TRIM(src.OLDPOLNUM) AS OLDPOLNUM, TRIM(reconsrc.V_PRD_CDE) AS PROD_CDE, TRIM(reconsrc.D_POL_START_DT) AS POL_COMMDT, 
    TRIM(reconsrc.V_POL_STATUS) AS POL_STATUS, TRIM(ig.CHDRNUM) AS IG_CHDRNUM, TRIM(stg.OLDPOLNUM) AS STG_OLDPOLNUM 
    FROM STAGEDBUSR2.TITDMGMBRINDP3@DMSTGUSR2DBLINK src 
    INNER JOIN STAGEDBUSR2.DM_POLICY_RECON@DMSTGUSR2DBLINK reconsrc ON TRIM(src.OLDPOLNUM) = TRIM(reconsrc.V_POLICY_NO)
    LEFT JOIN Jd1dta.ZUCLPF ig ON TRIM(src.OLDPOLNUM) = TRIM(ig.CHDRNUM)
    LEFT JOIN STAGEDBUSR.TITDMGMBRINDP3@DMSTAGEDBLINK stg ON TRIM(src.OLDPOLNUM) = TRIM(stg.OLDPOLNUM);

  TYPE typ_cur_chdrnum IS TABLE OF cur_chdrnum%ROWTYPE;
   cur_chdrnum_list typ_cur_chdrnum;

 BEGIN

  --------------------- START - POLDIS 01 : Reconciliation for attribute OLD_POLICY_STATCODE ----------------------
  OPEN cur_statcode;
  LOOP
    FETCH cur_statcode BULK COLLECT INTO cur_statcode_list LIMIT c_limit;
    FOR i IN 1..cur_statcode_list.COUNT LOOP 

    v_src_value          := cur_statcode_list(i).SRC_STATCODE;
    v_stg_value          := cur_statcode_list(i).STG_STATCODE;
    v_ig_value           := cur_statcode_list(i).IG_STATCODE;

  ----------------- Insert data into recon detail table i.e. dm_pol_dishnr_recon_det ------------------
    
   IF(v_src_value IS NULL OR v_stg_value IS NULL OR v_ig_value IS NULL OR v_src_value != v_stg_value OR v_src_value != v_ig_value) THEN   
    INSERT INTO Jd1dta.DM_POL_DISHNR_RECON_DET
                    (V_BATCH_ID, V_POLICY_NO, V_PROD_CDE, V_POL_COMMDT, V_ATTRIB_NAME, 
                    V_POL_STATUS, V_MODULE_NAME, V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL, 
                    V_IG_VAL, V_SUMMARY_BATCH_ID, D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)
                VALUES
                    (p_detail_batch_id, cur_statcode_list(i).OLDPOLNUM, cur_statcode_list(i).PROD_CDE,
                    cur_statcode_list(i).POL_COMMDT, c_statcode, cur_statcode_list(i).POL_STATUS, 
                    c_module_name, cur_statcode_list(i).POL_COMMDT, c_eff_desc, v_src_value, v_stg_value, 
                    v_ig_value, p_summary_batch_id, SYSDATE, c_created_by, c_job_name);
   END IF;                  
                    
  END LOOP;
  EXIT WHEN cur_statcode%notfound; 
  COMMIT;
  END LOOP;
  COMMIT;
  CLOSE cur_statcode;

  --------------------- END - POLDIS 01 : Reconciliation for attribute OLD_POLICY_STATCODE -----------------------
  
    ------------------------ START - POLDIS 02 : Reconciliation for attribute CHDRNUM -------------------------
  OPEN cur_chdrnum;
  LOOP
    FETCH cur_chdrnum BULK COLLECT INTO cur_chdrnum_list LIMIT c_limit;
    FOR i IN 1..cur_chdrnum_list.COUNT LOOP 

    v_src_value          := cur_chdrnum_list(i).OLDPOLNUM;
    v_stg_value          := cur_chdrnum_list(i).STG_OLDPOLNUM;
    v_ig_value           := cur_chdrnum_list(i).IG_CHDRNUM;

  ----------------- Insert data into recon detail table i.e. dm_pol_dishnr_recon_det ------------------
    
   IF(v_src_value IS NULL OR v_stg_value IS NULL OR v_ig_value IS NULL OR v_src_value != v_stg_value OR v_src_value != v_ig_value) THEN   
    INSERT INTO Jd1dta.DM_POL_DISHNR_RECON_DET
                    (V_BATCH_ID, V_POLICY_NO, V_PROD_CDE, V_POL_COMMDT, V_ATTRIB_NAME, 
                    V_POL_STATUS, V_MODULE_NAME, V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL, 
                    V_IG_VAL, V_SUMMARY_BATCH_ID, D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)
                VALUES
                    (p_detail_batch_id, cur_chdrnum_list(i).OLDPOLNUM, cur_chdrnum_list(i).PROD_CDE,
                    cur_chdrnum_list(i).POL_COMMDT, c_chdrnum, cur_chdrnum_list(i).POL_STATUS, 
                    c_module_name, cur_chdrnum_list(i).POL_COMMDT, c_eff_desc, v_src_value, v_stg_value, 
                    v_ig_value, p_summary_batch_id, SYSDATE, c_created_by, c_job_name);
   END IF;                  
                    
  END LOOP;
  EXIT WHEN cur_chdrnum%notfound; 
  COMMIT;
  END LOOP;
  COMMIT;
  CLOSE cur_chdrnum;

  ------------------------- END - POLDIS 02 : Reconciliation for attribute CHDRNUM ---------------------------

  dbms_output.put_line('Procedure Executed Successfully');

  EXCEPTION
  WHEN OTHERS THEN
    p_exitcode := SQLCODE;
    p_exittext := SQLERRM;

    ---------- Add error into error log table  -------------
    insert_error_log(p_exitcode, p_exittext, c_prog_name);
    dbms_output.put_line(p_exitcode || ' - ' || p_exittext);

 END DM_POLDIS_RECON_SET2;