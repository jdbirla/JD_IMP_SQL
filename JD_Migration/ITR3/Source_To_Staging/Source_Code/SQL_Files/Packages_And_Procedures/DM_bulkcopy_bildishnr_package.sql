create or replace PACKAGE       DM_bulkcopy_bildishnr AS

 PROCEDURE DM_Policydishonor_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');

END DM_bulkcopy_bildishnr;

/

create or replace PACKAGE BODY   DM_bulkcopy_bildishnr IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;

-- Procedure for DM  DM_Policydishonor_to_ig IG movement <Starts> Here
PROCEDURE dm_policydishonor_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgmbrindp3%rowtype;
  pd_data ig_array;
  v_app titdmgmbrindp3%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE poldis_rc
IS
  REF
  CURSOR;
    cur_poldis poldis_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGMBRINDP3';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP3 DT WHERE DT.OLDPOLNUM=T.OLDPOLNUM and DT.OLDPOLNUM in (select OLDPOLNUM from TMP_TITDMGMBRINDP3))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGMBRINDP3 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGMBRINDP3 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.OLDPOLNUM=TITDMGMBRINDP3.OLDPOLNUM ) ORDER BY TITDMGMBRINDP3.OLDPOLNUM';
    OPEN cur_poldis FOR sqlstmt;
    LOOP
      FETCH cur_poldis BULK COLLECT INTO pd_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + pd_data.count;
      FORALL i                      IN 1..pd_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' (OLDPOLNUM)                                 
VALUES                                           
(:1                                            
)' USING pd_data(i).oldpolnum;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + PD_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGMBRINDP3_IG', SUBSTR(pd_data(SQL%bulk_exceptions(beindx).error_index).oldpolnum, 1, 15 ), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := pd_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_poldis%notfound;
  END LOOP;
  CLOSE cur_poldis;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.oldpolnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.oldpolnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.oldpolnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_policydishonor_to_ig;
-- Procedure for DM  DM_Policydishonor_to_ig IG movement <ENDS> Here

END DM_bulkcopy_bildishnr;

/