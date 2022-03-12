create or replace PACKAGE    DM_bulkcopy_cmp AS

  PROCEDURE DM_Campaign_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
  PROCEDURE DM_Salesplan2_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_cmp;
/

create or replace PACKAGE BODY   DM_bulkcopy_cmp IS
 v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
-- Procedure for DM Campaign code IG movement <STARTS> Here
PROCEDURE dm_campaign_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgcampcde%rowtype;
  cd_data ig_array;
  v_app titdmgcampcde%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE ccode_rc
IS
  REF
  CURSOR;
    cur_cmpcde ccode_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGCAMPCDE';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCAMPCDE DT WHERE DT.ZCMPCODE=T.ZCMPCODE and DT.ZCMPCODE in(select ZCMPCODE from TMP_TITDMGCAMPCDE))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGCAMPCDE for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGCAMPCDE where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.ZCMPCODE=TITDMGCAMPCDE.ZCMPCODE) ORDER BY TITDMGCAMPCDE.CHDRNUM';
    OPEN cur_cmpcde FOR sqlstmt;
    LOOP
      FETCH cur_cmpcde BULK COLLECT INTO cd_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + cd_data.count;
      FORALL i                      IN 1..cd_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' ( ZCMPCODE,                                                      
ZPETNAME,                                                      
ZPOLCLS,                                                      
ZENDCODE,                                                      
CHDRNUM,                                                      
GPOLTYP,                                                      
ZAGPTID,                                                      
RCDATE,                                                      
ZCMPFRM,                                                      
ZCMPTO,                                                      
ZMAILDAT,                                                      
ZACLSDAT,                                                      
ZDLVCDDT,                                                      
ZVEHICLE,                                                      
ZSTAGE,                                                      
ZSCHEME01,                                                      
ZSCHEME02,                                                      
ZCRTUSR,                                                      
ZAPPDATE,                                                      
ZCCODIND,                                                      
EFFDATE,                                                      
STATUS                                                      
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
:22)'
      USING cd_data(i).zcmpcode,
      cd_data(i).zpetname,
      cd_data(i).zpolcls,
      cd_data(i).zendcode,
      cd_data(i).chdrnum ,
      cd_data(i).gpoltyp,
      cd_data(i).zagptid,
      cd_data(i).rcdate,
      cd_data(i).zcmpfrm,
      cd_data(i).zcmpto,
      cd_data (i).zmaildat,
      cd_data(i).zaclsdat,
      cd_data(i).zdlvcddt,
      cd_data(i).zvehicle,
      cd_data(i).zstage,
      cd_data(i ).zscheme01,
      cd_data(i).zscheme02,
      cd_data(i).zcrtusr,
      cd_data(i).zappdate,
      cd_data(i).zccodind,
      cd_data( i).effdate,
      cd_data(i).status;
      --V_OUTPUT_COUNT := V_OUTPUT_COUNT + CD_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGCAMPCDE_IG', SUBSTR(cd_data(SQL%bulk_exceptions(beindx).error_index).zcmpcode, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := cd_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_cmpcde%notfound;
  END LOOP;
  CLOSE cur_cmpcde;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_campaign_to_ig;
-- Procedure for DM Campaign code IG movement <ENDS> Here


-- Procedure for DM Sales plan 2 IG movement <STARTS> Here
PROCEDURE dm_salesplan2_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgzcslpf%rowtype;
  sp2_data ig_array;
  v_app titdmgzcslpf%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE spln2_rc
IS
  REF
  CURSOR;
    cur_slpln2 spln2_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGZCSLPF';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGZCSLPF DT WHERE DT.ZSALPLAN=T.ZSALPLAN and DT.ZSALPLAN in(select distinct ZSALPLAN from TMP_TITDMGZCSLPF))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGSALEPLN2 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGZCSLPF where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.ZSALPLAN=TITDMGZCSLPF.ZSALPLAN ) ORDER BY TITDMGZCSLPF.ZSALPLAN';
    OPEN cur_slpln2 FOR sqlstmt;
    LOOP
      FETCH cur_slpln2 BULK COLLECT INTO sp2_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + sp2_data.count;
      FORALL i                      IN 1..sp2_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' ( ZCMPCODE,                                                     
OLD_ZSALPLAN,                                                      
ZSALPLAN)                                 
VALUES                                           
(:1,                                            
:2,                                            
:3)' USING sp2_data(i).zcmpcode,
      sp2_data(i).old_zsalplan,
      sp2_data(i).zsalplan;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGZCSLPF_IG', SUBSTR(sp2_data(SQL%bulk_exceptions(beindx).error_index).zsalplan, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := sp2_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_slpln2%notfound;
  END LOOP;
  CLOSE cur_slpln2;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_salesplan2_to_ig;
-- Procedure for DM Sales plan 2 IG movement <ENDS> Here


END DM_bulkcopy_cmp;
/
