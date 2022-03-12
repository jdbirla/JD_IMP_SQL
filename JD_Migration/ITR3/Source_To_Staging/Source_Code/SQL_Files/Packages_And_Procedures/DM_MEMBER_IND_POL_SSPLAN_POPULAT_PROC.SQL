create or replace PROCEDURE DM_SSPLAN_POPULAT( 
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
AS
  /* Following cursor is to fetch rows to populate into apcucd, credit_card_cd, relationship_cd, hcr_flag, oldzsalplan, newzsalplan */
  CURSOR CUR_MASTER_SRC_SSPLAN
  IS
  WITH data_1 AS
    (SELECT src_data.apcucd ,
      src_data.chdrnum ,
      src_data.mbrno,
      src_data.oldzsalplan,
      src_data.relationship ,
      src_data.crdt_card_ridr ,
      src_data.hcr_coverage ,
      ssp.newzsalplan
    FROM
      (SELECT p.apcucd,
        SUBSTR(p.apcucd,1,8) chdrnum,
        '000'
        ||SUBSTR(ris.iscicd,-2) mbrno,
        ris.iscjcd oldzsalplan,
        ris.isa4st                       AS relationship,
        DECODE (rrs.rsbvcd,NULL,'N','Y') AS crdt_card_ridr,
        CASE
          WHEN SUBSTR(p.apyob1,1,1) IN (' ','N')
          THEN 'N'
          WHEN SUBSTR(p.apyob1,1,1) IN ('A','B','C','D','E')
          THEN SUBSTR(p.apyob1,1,1)
          ELSE 'N'
        END AS hcr_coverage
      FROM zmrap00 p
      LEFT OUTER JOIN zmris00 ris
      ON p.apcucd = ris.iscucd
      LEFT OUTER JOIN
        (SELECT b.rsbtcd,
          b.rsbucd,
          b.rsfocd,
          b.rsbvcd,
          b.rsgacd ,
          b.rsb0cd,
          b.rsb1cd,
          b.rsb2cd,
          b.rsb3cd,
          b.rsb4cd,
          b.rsb5cd
        FROM zmrrs00 b
        WHERE (b.rsgacd IN ('PO')
        AND 351         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PTA')
        AND 352         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PFT')
        AND 353         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PFA')
        AND 354         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('CLP')
        AND 355         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('SPA')
        AND 356         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        ) rrs
    ON p.apc7cd              = rrs.rsbtcd
    AND p.apc8cd             = rrs.rsbucd
    AND p.apc6cd             = rrs.rsfocd
    AND ris.iscjcd           = rrs.rsbvcd
    WHERE SUBSTR(p.apcucd,-1)='0'
      --and ris.isa4st ='1'
      ) src_data
    LEFT OUTER JOIN STAGEDBUSR2.SPPLANCONVERTION ssp
    ON ssp.oldzsalplan        = src_data.oldzsalplan
    AND ssp.relationship      = src_data.relationship
    AND ssp.CCSPECIALCONTRACT = src_data.crdt_card_ridr
    AND ssp.hcrflag           = src_data.hcr_coverage
      --WHERE SRC_DATA.OLDZSALPLAN NOT IN ('F15BXXX100X0-001','F19NXXX001X0-004')
    )
  SELECT APCUCD,
    CHDRNUM,
    mbrno,
    OLDZSALPLAN,
    RELATIONSHIP,
    crdt_card_ridr,
    hcr_coverage,
    NEWZSALPLAN
  FROM data_1;
  c_limit PLS_INTEGER := p_array_size;
Type Master_array
IS
  TABLE OF CUR_MASTER_SRC_SSPLAN%rowtype;
  PROCESS_DATA CUR_MASTER_SRC_SSPLAN%ROWTYPE;
TYPE zmrap00_cur_t
IS
  TABLE OF CUR_MASTER_SRC_SSPLAN%rowtype;
  zmrap00_l_appls zmrap00_cur_t;
  Err_desc       VARCHAR2(300);
  v_errormsg     VARCHAR2(300);
  v_input_count  NUMBER;
  v_output_count NUMBER:=0;
  temp_no        NUMBER ;
  stg_starttime  TIMESTAMP;
  stg_endtime    TIMESTAMP;
  g_err_flg      NUMBER := 0;
  rows_inserted  NUMBER;
  l_app_old      VARCHAR2(20);
  application_no VARCHAR2(13);
BEGIN
  /*----------------BEGIN - load data into TEMP_SSPLAN TABLE-------------------------------------------------------------------------------------------*/
  g_err_flg      := 0;
  dm_data_trans_gen.stg_starttime := systimestamp;
  v_input_count  := 0;
  v_output_count := 0;
  IF p_delta      = 'Y' THEN
    v_errormsg   := 'For MEM_IND_POLHIST_SSPLAN_INTRMDT TABLE Load:';
    OPEN CUR_MASTER_SRC_SSPLAN;
    LOOP
      FETCH CUR_MASTER_SRC_SSPLAN INTO PROCESS_DATA;
      EXIT
    WHEN CUR_MASTER_SRC_SSPLAN%notfound;
      DELETE
      FROM MEM_IND_POLHIST_SSPLAN_INTRMDT TRN
      WHERE TRN.apcucd = PROCESS_DATA.apcucd;
    END LOOP;
    CLOSE CUR_MASTER_SRC_SSPLAN;
    COMMIT;
    -- Delete the records for all the records exists in MEM_IND_POLHIST_SSPLAN_INTRMDT for Delta Load
  END IF;
  OPEN CUR_MASTER_SRC_SSPLAN;
  LOOP
    FETCH CUR_MASTER_SRC_SSPLAN BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
    v_input_count := v_input_count + zmrap00_l_appls.count;
    FOR l_apindx                  IN 1..zmrap00_l_appls.count
    LOOP
      Err_desc   :=NULL;
      v_errormsg :=NULL;
      l_app_old  := zmrap00_l_appls(l_apindx).APCUCD;
      V_ERRORMSG :='INSERT TARGET:';
      BEGIN
        INSERT
        INTO MEM_IND_POLHIST_SSPLAN_INTRMDT
          (
            APCUCD,
            CHDRNUM,
            MBRNO,
            OLDZSALPLAN,
            RELATIONSHIP,
            CRDT_CARD_RIDER,
            HCR_FLAG,
            NEWZSALPLAN
          )
          VALUES
          (
            zmrap00_l_appls(l_apindx).APCUCD,
            zmrap00_l_appls(l_apindx).CHDRNUM,
            zmrap00_l_appls(l_apindx).MBRNO,
            zmrap00_l_appls(l_apindx).OLDZSALPLAN,
            zmrap00_l_appls(l_apindx).RELATIONSHIP,
            zmrap00_l_appls(l_apindx).crdt_card_ridr,
            zmrap00_l_appls(l_apindx).hcr_coverage,
            zmrap00_l_appls(l_apindx).NEWZSALPLAN
          );
        v_output_count :=v_output_count +1;
      EXCEPTION
      WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
        v_errormsg := v_errormsg || '-' || sqlerrm;
        DM_data_trans_gen.error_logs('MEM_IND_POLHIST_SSPLAN_INTRMDT', zmrap00_l_appls(l_apindx).APCUCD, v_errormsg);
        g_err_flg := 1;
      END;
    END LOOP;
    EXIT
  WHEN CUR_MASTER_SRC_SSPLAN%notfound;
    COMMIT;
  END LOOP;
  CLOSE CUR_MASTER_SRC_SSPLAN;
  COMMIT;
  IF g_err_flg      = 0 THEN
    v_errormsg     := 'SUCCESS';
    application_no := NULL;
    temp_no        :=DM_data_trans_gen.control_log('ITR3 zmrap00, zmrrs00, sspplanconvertion', 'SSPLAN_INTRMDT', CURRENT_TIMESTAMP, application_no, v_errormsg, 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.control_log('ITR3 zmrap00, zmrrs00, sspplanconvertion', 'SSPLAN_INTRMDT', CURRENT_TIMESTAMP, application_no, v_errormsg, 'F', v_input_count, v_output_count);
    --dbms_output.put_line(v_errormsg);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  Err_desc:='Error while INSERT INTO MEM_IND_POLHIST_SSPLAN_INTRMDT TABLE '|| l_app_old;
  DM_data_trans_gen.error_logs('MEM_IND_POLHIST_SSPLAN_INTRMDT', NULL, v_errormsg);
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  DM_data_trans_gen.error_logs('MEM_IND_POLHIST_SSPLAN_INTRMDT', 'APCUCD', v_errormsg);
  temp_no := DM_data_trans_gen.control_log('MEM IND POL SSPLAN POPULATE', 'SSPLAN_INTRMDT', systimestamp, NULL, v_errormsg,'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);
END DM_SSPLAN_POPULAT;