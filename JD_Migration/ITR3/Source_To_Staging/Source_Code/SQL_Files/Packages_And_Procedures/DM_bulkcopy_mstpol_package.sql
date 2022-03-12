create or replace PACKAGE   DM_bulkcopy_mstpol AS

  PROCEDURE DM_Mastpol1_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
  PROCEDURE DM_Mastpol2_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
  PROCEDURE DM_Mastpol3_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_mstpol;
/

create or replace PACKAGE BODY DM_bulkcopy_mstpol
IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
--- Procedure for DM_Mastpol1_to_ig < STARTS > Here
PROCEDURE dm_mastpol1_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE aj_array
IS
  TABLE OF titdmgmaspol%rowtype;
  ms1_data aj_array;
  v_app titdmgmaspol%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE master_policy_rc
IS
  REF
  CURSOR;
    cur_master1 master_policy_rc;
    ms1_sqlstmt    VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGMASPOL';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGMASPOL DT WHERE DT.CHDRNUM=T.CHDRNUM)';
      COMMIT;
      -- Delete the records for the records exists in TITDMGMASPOL for Delta Load
    END IF;
    ms1_sqlstmt := 'SELECT * FROM TITDMGMASPOL where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGMASPOL.CHDRNUM) ORDER BY TITDMGMASPOL.CHDRNUM';
    OPEN cur_master1 FOR ms1_sqlstmt;
    LOOP
      FETCH cur_master1 BULK COLLECT INTO ms1_data;--LIMIT p_array_size;
    v_input_count := v_input_count + ms1_data.count;
    v_errormsg    := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      FORALL i IN 1..ms1_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (                                               
-- RECIDXMPMSPOL ,               
CHDRNUM,               
CNTTYPE,               
STATCODE,                  
ZAGPTNUM,                  
CCDATE,                  
CRDATE,                  
RPTFPST,                  
ZENDCDE,                  
RRA2IG,                  
B8TJIG,               
ZBLNKPOL,                  
B8O9NB,                  
B8GPST,                  
B8GOST,                  
ZNBALTPR,                  
CANCELDT,                  
EFFDATE,                  
PNDATE,                  
OCCDATE,                  
INSENDTE,                  
ZPENDDT,               
ZCCDE,                  
ZCONSGNM,                  
ZBLADCD,                  
CLNTNUM)                                 
VALUES                                           
(:1,                                            
:2,                                            
:3,                                            
:4,                                            
:5,                                            
:6,                                            
:7,                                            
:8,                                            
:9,                                            
:10,                                            
:11,                                            
:12,                                            
:13,                                            
:14,                                            
:15,                                            
:16,                                            
:17,                                            
:18,                                            
:19,                                            
:20,                                            
:21,                                            
:22,                                            
:23,                                            
:24,                                            
:25                                            
)'
      USING ms1_data(i).chdrnum,
      ms1_data(i).cnttype,
      ms1_data(i).statcode,
      ms1_data(i).zagptnum,
      ms1_data(i).ccdate ,
      ms1_data(i).crdate,
      ms1_data(i).rptfpst,
      ms1_data(i).zendcde,
      ms1_data(i).rra2ig,
      ms1_data(i).b8tjig,
      ms1_data (i).zblnkpol,
      ms1_data(i).b8o9nb,
      ms1_data(i).b8gpst,
      ms1_data(i).b8gost,
      ms1_data(i).znbaltpr,
      ms1_data( i).canceldt,
      ms1_data(i).effdate,
      ms1_data(i).pndate,
      ms1_data(i).occdate,
      ms1_data(i).insendte,
      ms1_data (i).zpenddt,
      ms1_data(i).zccde,
      ms1_data(i).zconsgnm,
      ms1_data(i).zbladcd,
      ms1_data(i).clntnum;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS1_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGMASPOL_IG', SUBSTR(ms1_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := ms1_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_master1%notfound;
  END LOOP;
  CLOSE cur_master1;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_mastpol1_to_ig;
--- Procedure for DM_Mastpol1_to_ig < ENDS > Here
--- Procedure for DM_Mastpol2_to_ig < STARTS > Here
PROCEDURE dm_mastpol2_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE aj_array
IS
  TABLE OF titdmginsstpl%rowtype;
  ms2_data aj_array;
  v_app titdmginsstpl%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE master_policy_rc
IS
  REF
  CURSOR;
    cur_master2 master_policy_rc;
    ms2_sqlstmt    VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGINSSTPL';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGINSSTPL DT WHERE DT.CHDRNUM=T.CHDRNUM)';
      COMMIT;
      -- Delete the records for the records exists in TITDMGINSSTPL for Delta Load
    END IF;
    ms2_sqlstmt := 'SELECT * FROM TITDMGINSSTPL where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGINSSTPL.CHDRNUM) ORDER BY TITDMGINSSTPL.CHDRNUM';
    OPEN cur_master2 FOR ms2_sqlstmt;
    LOOP
      FETCH cur_master2 BULK COLLECT INTO ms2_data;--LIMIT p_array_size;
    v_input_count := v_input_count + ms2_data.count;
    v_errormsg    := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      FORALL i IN 1..ms2_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' (                                             
CHDRNUM,               
PLNSETNUM,               
ZINSTYPE1,               
ZINSTYPE2,               
ZINSTYPE3,            
ZINSTYPE4)                                 
VALUES                                           
(:1,                                            
:2,                                            
:3,                                            
:4,                                            
:5,                                            
:6                                            
)' USING ms2_data(i).chdrnum,
      ms2_data(i).plnsetnum,
      ms2_data(i).zinstype1,
      ms2_data(i).zinstype2,
      ms2_data( i).zinstype3,
      ms2_data(i).zinstype4;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS2_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGINSSTPL_IG', SUBSTR(ms2_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := ms2_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_master2%notfound;
  END LOOP;
  CLOSE cur_master2;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_mastpol2_to_ig;
--- Procedure for DM_Mastpol2_to_ig < ENDS > Here
--- Procedure for DM_Mastpol3_to_ig < STARTS > Here
PROCEDURE dm_mastpol3_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE aj_array
IS
  TABLE OF titdmgendctpf%rowtype;
  ms3_data aj_array;
  v_app titdmgendctpf%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE master_policy_rc
IS
  REF
  CURSOR;
    cur_master3 master_policy_rc;
    ms3_sqlstmt    VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGENDCTPF';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGENDCTPF DT WHERE DT.CHDRNUM=T.CHDRNUM)';
      COMMIT;
      -- Delete the records for the records exists in TITDMGENDCTPF for Delta Load
    END IF;
    ms3_sqlstmt := 'SELECT * FROM TITDMGENDCTPF where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGENDCTPF.CHDRNUM) ORDER BY TITDMGENDCTPF.CHDRNUM';
    OPEN cur_master3 FOR ms3_sqlstmt;
    LOOP
      FETCH cur_master3 BULK COLLECT INTO ms3_data;--LIMIT p_array_size;
    v_input_count := v_input_count + ms3_data.count;
    v_errormsg    := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      FORALL i IN 1..ms3_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' (CHDRNUM,              
ZCRDTYPE,              
ZCARDDC,              
ZCNBRFRM,              
ZCNBRTO,              
ZMSTID,              
ZMSTSNME,              
ZMSTIDV,              
ZMSTSNMEV                                              
)                                 
VALUES                                           
(:1,                                            
:2,                                            
:3,                                            
:4,                                            
:5,                                            
:6,                                            
:7,                                            
:8,                                            
:9                                            
)' USING ms3_data(i).chdrnum,
      ms3_data(i).zcrdtype,
      ms3_data(i).zcarddc,
      ms3_data(i).zcnbrfrm,
      ms3_data(i).zcnbrto ,
      ms3_data(i).zmstid,
      ms3_data(i).zmstsnme,
      ms3_data(i).zmstidv,
      ms3_data(i).zmstsnmev;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS3_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGENDCTPF_IG', SUBSTR(ms3_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := ms3_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_master3%notfound;
  END LOOP;
  CLOSE cur_master3;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_mastpol3_to_ig;
--- Procedure for DM_Mastpol3_to_ig < ENDS > Here

END DM_bulkcopy_mstpol;

/
