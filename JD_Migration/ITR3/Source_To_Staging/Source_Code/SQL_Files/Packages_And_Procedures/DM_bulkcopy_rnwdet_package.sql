create or replace PACKAGE                          DM_bulkcopy_rnwdet AS

  PROCEDURE DM_rnwdet1_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');

  PROCEDURE DM_rnwdet2_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_rnwdet;

/

create or replace PACKAGE BODY     DM_bulkcopy_rnwdet AS
  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Renewal determination DM_rnwdet1_to_ig IG movement <STARTS> Here
PROCEDURE DM_rnwdet1_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgrnwdt1%rowtype;
  mp_data ig_array;
  v_app titdmgrnwdt1%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE mpol_rc
IS
  REF
  CURSOR;
    cur_membrpol mpol_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGRNWDT1';
    
    dbms_output.put_line('temp_tablename '||temp_tablename);
    
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGRNWDT1 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in (select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGMBRINDP1 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGRNWDT1 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGRNWDT1.CHDRNUM) ORDER BY TITDMGRNWDT1.CHDRNUM';
    dbms_output.put_line('sqlstmt '||sqlstmt);
    
    OPEN cur_membrpol FOR sqlstmt;
    LOOP
      FETCH cur_membrpol BULK COLLECT INTO mp_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    
    dbms_output.put_line('v_errormsg '||v_errormsg);
    BEGIN
    
     dbms_output.put_line('mp_data.count '||mp_data.count);
     
      v_input_count := v_input_count + mp_data.count;
      FORALL i                      IN 1..mp_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (                                           
CHDRNUM, MBRNO, ZRNDTFRM, ZRNDTTO, ZALTRCDE, ZRNDTREG, ZRNDTAPP, ZINSROLE, STAGECLNTNO, ZTERMFLG, ZSALPLAN, ZRNDTRCD,
ZINSRNWAGE, INPUT_SOURCE_TABLE)                                 
VALUES                                           
(:1, :2, :3, :4,:5, :6, :7, :8, :9, :10,                                            
:11, :12,:13,:14)'
      USING mp_data(i).CHDRNUM,
      mp_data(i).MBRNO,
      mp_data(i).ZRNDTFRM,
      mp_data(i).ZRNDTTO,
      mp_data(i).ZALTRCDE ,
      mp_data(i).ZRNDTREG,
      mp_data(i).ZRNDTAPP,
      mp_data(i).ZINSROLE,
      mp_data(i).STAGECLNTNO,
      mp_data(i).ZTERMFLG,
      mp_data( i).ZSALPLAN,
      mp_data(i).ZRNDTRCD,
      mp_data(i).ZINSRNWAGE,
      mp_data(i).INPUT_SOURCE_TABLE;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + MP_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGRNWDT1_IG', SUBSTR(mp_data(SQL%bulk_exceptions(beindx).error_index).CHDRNUM, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := mp_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_membrpol%notfound;
  END LOOP;
  CLOSE cur_membrpol;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGRNWDT1', 'TITDMGRNWDT1_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGRNWDT1', 'TTITDMGRNWDT1_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGRNWDT1', 'TITDMGRNWDT1_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END DM_rnwdet1_to_ig;
-- Procedure for DM Renewal determination DM_rnwdet1_to_ig IG movement <ENDS> Here

-- Procedure for DM Renewal determination DM_rnwdet2_to_ig IG movement <STARTS> Here
PROCEDURE DM_rnwdet2_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgrnwdt2%rowtype;
  mp_data ig_array;
  v_app titdmgrnwdt2%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE mpol_rc
IS
  REF
  CURSOR;
    cur_membrpol mpol_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGRNWDT2';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGRNWDT2 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in (select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGMBRINDP1 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGRNWDT2 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGRNWDT2.CHDRNUM) ORDER BY TITDMGRNWDT2.CHDRNUM';
    OPEN cur_membrpol FOR sqlstmt;
    LOOP
      FETCH cur_membrpol BULK COLLECT INTO mp_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + mp_data.count;
      FORALL i                      IN 1..mp_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (                                           
CHDRNUM, MBRNO, DPNTNO, PRODTYP, SUMINS, DPREM, ZINSTYPE, PRODTYP02, NDR_DPREM, INPUT_SOURCE_TABLE)                                 
VALUES                                           
(:1, :2, :3, :4,:5, :6, :7, :8, :9, :10)'
      USING mp_data(i).CHDRNUM,
      mp_data(i).MBRNO,
      mp_data(i).DPNTNO,
      mp_data(i).PRODTYP,
      mp_data(i).SUMINS ,
      mp_data(i).DPREM,
      mp_data(i).ZINSTYPE,
      mp_data(i).PRODTYP02,
      mp_data(i).NDR_DPREM,
      mp_data(i).INPUT_SOURCE_TABLE;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + MP_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGRNWDT2_IG', SUBSTR(mp_data(SQL%bulk_exceptions(beindx).error_index).CHDRNUM, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := mp_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_membrpol%notfound;
  END LOOP;
  CLOSE cur_membrpol;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGRNWDT2', 'TITDMGRNWDT2_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGRNWDT2', 'TITDMGRNWDT2_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGRNWDT2', 'TITDMGRNWDT2_IG', systimestamp, v_app.CHDRNUM, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END DM_rnwdet2_to_ig;
-- Procedure for DM Renewal determination DM_rnwdet1_to_ig IG movement <ENDS> Here



END DM_bulkcopy_rnwdet;

/
