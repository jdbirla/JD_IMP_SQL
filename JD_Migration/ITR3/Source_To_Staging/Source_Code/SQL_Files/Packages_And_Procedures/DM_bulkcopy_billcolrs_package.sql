create or replace PACKAGE   DM_bulkcopy_billcolrs AS

  PROCEDURE DM_Billcolres_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      

END DM_bulkcopy_billcolrs;

/

create or replace PACKAGE BODY   DM_bulkcopy_billcolrs IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM BILL Collection res IG movement <STARTS> Here
PROCEDURE dm_billcolres_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgcolres%rowtype;
  bc_data ig_array;
  v_app titdmgcolres%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE bc_rc
IS
  REF
  CURSOR;
    cur_colres bc_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGCOLRES';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCOLRES DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_PJ_TITDMGCOLRES A WHERE A.CHDRNUM=DT.CHDRNUM))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGCOLRES for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGCOLRES where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGCOLRES.CHDRNUM and DT.TRREFNUM = TITDMGCOLRES.TRREFNUM and DT.PRBILFDT = TITDMGCOLRES.PRBILFDT) ORDER BY TITDMGCOLRES.CHDRNUM' ;
    OPEN cur_colres FOR sqlstmt;
    LOOP
      FETCH cur_colres BULK COLLECT INTO bc_data;-- LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + bc_data.count;
      FORALL i                      IN 1..bc_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' (                                              
CHDRNUM,                                              
TRREFNUM,                                              
TFRDATE,                                              
DSHCDE,
PRBILFDT)                                 
VALUES                                           
(:1,                                            
:2,                                            
:3,                                            
:4,
:5                                            
)' USING bc_data(i).chdrnum,
      bc_data(i).trrefnum,
      bc_data(i).tfrdate,
      bc_data(i).dshcde,
      bc_data(i).prbilfdt;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BC_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGCOLRES_IG', SUBSTR(bc_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := bc_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_colres%notfound;
  END LOOP;
  CLOSE cur_colres;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_billcolres_to_ig;
-- Procedure for DM BILL Collection res IG movement <ENDS> Here

END DM_bulkcopy_billcolrs;

/