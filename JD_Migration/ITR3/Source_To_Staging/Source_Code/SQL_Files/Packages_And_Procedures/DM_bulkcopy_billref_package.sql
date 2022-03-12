create or replace PACKAGE    DM_bulkcopy_billref AS

  PROCEDURE DM_Refundhdr_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
  PROCEDURE DM_Refunddets_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_billref;

/

create or replace PACKAGE BODY   DM_bulkcopy_billref IS

v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Refund HDR IG movement <STARTS> Here
PROCEDURE dm_refundhdr_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgref1%rowtype;
  rh_data ig_array;
  v_app titdmgref1%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE rehd_rc
IS
  REF
  CURSOR;
    cur_refhdr rehd_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGREF1';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGREF1 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGREF1 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGREF1 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGREF1.CHDRNUM) ORDER BY TITDMGREF1.CHDRNUM';
    OPEN cur_refhdr FOR sqlstmt;
    LOOP
      FETCH cur_refhdr BULK COLLECT INTO rh_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + rh_data.count;
      FORALL i                      IN 1..rh_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' ( REFNUM,                                             
CHDRNUM,                                             
ZREFMTCD,                                             
EFFDATE,                                             
PRBILFDT,                                             
PRBILTDT,                                             
ZPOSBDSM,                                             
ZPOSBDSY,                                             
ZALTRCDE01,                                             
ZREFUNDBE,                                             
ZREFUNDBZ,                                             
ZENRFDST,                                             
ZZHRFDST,                                             
BANKKEY,                                             
BANKACOUNT,                                             
BANKACCDSC,                                             
BNKACTYP,                                             
ZRQBKRDF,                                             
REQDATE,                                             
ZCOLFLAG,                                             
PAYDATE,                                             
RDOCPFX,                                             
RDOCCOY,                                             
RDOCNUM,                                             
ZPDATATXFLG,
NRFLAG                                       
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
abs(:10),-- Added abs to fix the problem raised due to #7864 (-ve / +ve value should be +ve)           
abs(:11),-- Added abs to fix the problem raised due to #7864 (-ve / +ve value should be +ve)                                           
-- (-1*:10), -- Changed for converting positive value #7864                                           
-- (-1*:11),-- Changed for converting positive value #7864                                            
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
:25,
:26)'
      USING rh_data(i).refnum,
      rh_data(i).chdrnum,
      rh_data(i).zrefmtcd,
      rh_data(i).effdate,
      rh_data(i).prbilfdt ,
      rh_data(i).prbiltdt,
      rh_data(i).zposbdsm,
      rh_data(i).zposbdsy,
      rh_data(i).zaltrcde01,
      rh_data(i).zrefundbe ,
      rh_data(i).zrefundbz,
      rh_data(i).zenrfdst,
      rh_data(i).zzhrfdst,
      rh_data(i).bankkey,
      rh_data(i).bankacount ,
      rh_data(i).bankaccdsc,
      rh_data(i).bnkactyp,
      rh_data(i).zrqbkrdf,
      rh_data(i).reqdate,
      rh_data(i).zcolflag ,
      rh_data(i).paydate,
      rh_data(i).rdocpfx,
      rh_data(i).rdoccoy,
      rh_data(i).rdocnum,
      rh_data(i).zpdatatxflg,
	  rh_data(i).nrflag;
      --    V_OUTPUT_COUNT := V_OUTPUT_COUNT + RH_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGREF1_IG', SUBSTR(rh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := rh_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_refhdr%notfound;
  END LOOP;
  CLOSE cur_refhdr;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  --       ROLLBACK;
  temp_no := DM_data_trans_gen.ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  RETURN;
END dm_refundhdr_to_ig;
-- Procedure for DM Refund HDR IG movement <ENDS> Here


-- Procedure for DM Refund Details IG movement <STARTS> Here
PROCEDURE dm_refunddets_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgref2%rowtype;
  rd_data ig_array;
  v_app titdmgref2%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE ref2_rc
IS
  REF
  CURSOR;
    cur_refdet ref2_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGREF2';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGREF2 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGREF2 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGREF2 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGREF2.CHDRNUM ) ORDER BY TITDMGREF2.CHDRNUM ';
    OPEN cur_refdet FOR sqlstmt;
    LOOP
      FETCH cur_refdet BULK COLLECT INTO rd_data;-- LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + rd_data.count;
      FORALL i                      IN 1..rd_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (TRREFNUM,                                          
CHDRNUM,                                          
ZREFMTCD,                                          
PRODTYP,                                          
BPREM,                                          
GAGNTSEL01,                                          
GAGNTSEL02,                                          
GAGNTSEL03,                                          
GAGNTSEL04,                                          
GAGNTSEL05,                                          
CMRATE01,                                          
CMRATE02,                                          
CMRATE03,                                          
CMRATE04,                                          
CMRATE05,                                          
COMMN01,                                          
COMMN02,                                          
COMMN03,                                          
COMMN04,                                          
COMMN05,                                          
ZAGTGPRM01,                                          
ZAGTGPRM02,                                          
ZAGTGPRM03,                                          
ZAGTGPRM04,                                          
ZAGTGPRM05,                                          
ZCOLLFEE01,                                          
MBRNO,                                          
DPNTNO                                          
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
:22,                                            
:23,                                            
:24,                                            
:25,                                            
:26,                                            
:27,                                            
:28)'
      USING rd_data(i).trrefnum,
      rd_data(i).chdrnum,
      rd_data(i).zrefmtcd,
      rd_data(i).prodtyp,
      rd_data(i).bprem,
      rd_data(i).gagntsel01,
      rd_data(i).gagntsel02,
      rd_data(i).gagntsel03,
      rd_data(i).gagntsel04,
      rd_data(i).gagntsel05 ,
      rd_data(i).cmrate01,
      rd_data(i).cmrate02,
      rd_data(i).cmrate03,
      rd_data(i).cmrate04,
      rd_data(i).cmrate05 ,
      rd_data(i).commn01,
      rd_data(i).commn02,
      rd_data(i).commn03,
      rd_data(i).commn04,
      rd_data(i).commn05,
      rd_data (i).zagtgprm01,
      rd_data(i).zagtgprm02,
      rd_data(i).zagtgprm03,
      rd_data(i).zagtgprm04,
      rd_data(i).zagtgprm05 ,
      rd_data(i).zcollfee01,
      rd_data(i).mbrno,
      rd_data(i).dpntno;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + RD_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGREF2_IG', SUBSTR(rd_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := rd_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_refdet%notfound;
  END LOOP;
  CLOSE cur_refdet;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  RETURN;
END dm_refunddets_to_ig;
-- Procedure for DM Refund Details IG movement <ENDS> Here


END DM_bulkcopy_billref;

/