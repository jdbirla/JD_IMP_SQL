create or replace PACKAGE                          DM_bulkcopy_letter AS

  PROCEDURE DM_Letterhist_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');

END DM_bulkcopy_letter;
/

create or replace PACKAGE BODY   DM_bulkcopy_letter IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM_Letterhist_to_ig IG movement <STARTS> Here
PROCEDURE dm_letterhist_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgletter%rowtype;
  lh_data ig_array;
  v_app titdmgletter%rowtype;
  ig_endtime TIMESTAMP;
  v_errormsg VARCHAR2(2000);
  dml_errors EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE stletter_rc
IS
  REF
  CURSOR;
    cur_stletter stletter_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    temp_tablename VARCHAR2(30)   := NULL;
    temp_no        NUMBER         := 0;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGLETTER';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGLETTER DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_ZMRLH00 WHERE SUBSTR(LHCUCD,1,8) = DT.CHDRNUM))' ;
      COMMIT;
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGLETTER where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGLETTER.CHDRNUM and DT.LETTYPE = TITDMGLETTER.LETTYPE) ORDER BY TITDMGLETTER.CHDRNUM' ;
    OPEN cur_stletter FOR sqlstmt;
    LOOP
      FETCH cur_stletter BULK COLLECT INTO lh_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + lh_data.count;
      FORALL i                      IN 1..lh_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' ( CHDRNUM,                                            
LETTYPE,                                            
LREQDATE,                                            
ZDSPCATG,                                            
ZLETVERN,                                            
ZLETDEST,                                            
ZCOMADDR,                                            
ZLETCAT,                                            
ZAPSTMPD,                                            
ZLETEFDT,                                            
ZLETTRNO,
STAGECLNTNO                                      
--ZDESPER                                            
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
:12                                            
)'
      USING lh_data(i).chdrnum,
      lh_data(i).lettype,
      lh_data(i).lreqdate,
      lh_data(i).zdspcatg,
      lh_data(i).zletvern ,
      lh_data(i).zletdest,
      lh_data(i).zcomaddr,
      lh_data(i).zletcat,
      lh_data(i).zapstmpd,
      lh_data(i).zletefdt,
      lh_data(i).ZLETTRNO,-- Added for ITR4 Lot2 change
	  lh_data(i).STAGECLNTNO;
      --  LH_DATA(i).ZDESPER;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + LH_DATA.COUNT;
    EXCEPTION
    WHEN OTHERS THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGLETTER_IG', SUBSTR(lh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum || lh_data(SQL%bulk_exceptions(beindx).error_index).lettype, 1, 15), v_errormsg);
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := lh_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_stletter%notfound;
  END LOOP;
  CLOSE cur_stletter;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg , 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg , 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_letterhist_to_ig;
-- Procedure for DM_Letterhist_to_ig IG movement <EndS> Here

END DM_bulkcopy_letter;
/