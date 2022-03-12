create or replace PACKAGE DM_bulkcopy_billhis AS

  PROCEDURE DM_Billheader1_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
  PROCEDURE DM_Billheader2_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_billhis;
/

create or replace PACKAGE BODY DM_bulkcopy_billhis IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Bill Header1 IG movement <STARTS> Here
PROCEDURE dm_billheader1_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgbill1%rowtype;
  bh_data ig_array;
  v_app titdmgbill1%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE bill1_rc
IS
  REF
  CURSOR;
    cur_billhdr bill1_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGBILL1';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGBILL1 DT WHERE DT.TRREFNUM = T.TRREFNUM and DT.CHDRNUM = T.CHDRNUM and (DT.TRREFNUM, DT.CHDRNUM) in (select DT.TRREFNUM, DT.CHDRNUM from TMP_TITDMGBILL1))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGBILL1 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGBILL1 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.TRREFNUM = TRREFNUM and DT.CHDRNUM = CHDRNUM ) order by trrefnum, chdrnum' ;
    OPEN cur_billhdr FOR sqlstmt;
    LOOP
      FETCH cur_billhdr BULK COLLECT INTO bh_data;-- LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + bh_data.count;
      FORALL i IN 1..bh_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (TRREFNUM,                                                      
		CHDRNUM,                                                      
		PRBILFDT,                                                      
		PRBILTDT,                                                      
		PREMOUT,                                                      
		ZCOLFLAG,                                                      
		ZACMCLDT,                                                      
		ZPOSBDSM,                                                      
		ZPOSBDSY,                                                      
		ENDSERCD,                                                      
		TFRDATE,                                                      
		POSTING,            
		NRFLAG,
		ZPDATATXFLG,                                                      
		TRANNO)                                 
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
		:15)'
      USING bh_data(i).trrefnum,
      bh_data(i).chdrnum,
      bh_data(i).prbilfdt,
      bh_data(i).prbiltdt,
      bh_data(i).premout,
      bh_data(i).zcolflag,
      bh_data(i).zacmcldt,
      bh_data(i).zposbdsm,
      bh_data(i).zposbdsy,
      bh_data(i).endsercd,
      bh_data(i).tfrdate,
      bh_data(i).posting,
      bh_data(i).nrflag,
      bh_data(i).zpdatatxflg,
      bh_data(i).tranno;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BH_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGBILL1_IG', SUBSTR(bh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := bh_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_billhdr%notfound;
  END LOOP;
  CLOSE cur_billhdr;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  RETURN;
END dm_billheader1_to_ig;
-- Procedure for DM Bill Header1 IG movement <ENDS> Here

-- Procedure for DM Bill Header2 IG movement <STARTS> Here
PROCEDURE dm_billheader2_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgbill2%rowtype;
  bd_data ig_array;
  v_app titdmgbill2%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE bill2_rc
IS
  REF
  CURSOR;
    cur_billhdr2 bill2_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGBILL2';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGBILL2 DT WHERE DT.TRREFNUM = T.TRREFNUM and DT.CHDRNUM = T.CHDRNUM and DT.CHDRNUM in (select distinct CHDRNUM from TMP_TITDMGBILL2))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGBILL2 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGBILL2 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.TRREFNUM = TITDMGBILL2.TRREFNUM and DT.CHDRNUM = TITDMGBILL2.CHDRNUM and DT.PRODTYP = TITDMGBILL2.PRODTYP                       
				and DT.MBRNO = TITDMGBILL2.MBRNO and DT.DPNTNO = TITDMGBILL2.DPNTNO) order by trrefnum, chdrnum, prodtyp, mbrno, dpntno' ;
    OPEN cur_billhdr2 FOR sqlstmt;
    LOOP
      FETCH cur_billhdr2 BULK COLLECT INTO bd_data LIMIT p_array_size;
    v_input_count := v_input_count + bd_data.count;
    v_errormsg    := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      FORALL i IN 1..bd_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (TRREFNUM,                                                     
		CHDRNUM,                                                     
		TRANNO,                                                     
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
		DPNTNO,                                                     
		PRBILFDT,                                                     
		REFNUMCHUNK)                                 
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
		:28,                                            
		:29,                                            
		:30)'
      USING bd_data(i).trrefnum,
      bd_data(i).chdrnum,
      bd_data(i).tranno,
      bd_data(i).prodtyp,
      bd_data(i).bprem,
      bd_data(i).gagntsel01,
      bd_data(i).gagntsel02,
      bd_data(i).gagntsel03,
      bd_data(i).gagntsel04,
      bd_data(i).gagntsel05,
      bd_data(i).cmrate01,
      bd_data(i).cmrate02,
      bd_data(i).cmrate03,
      bd_data(i).cmrate04,
      bd_data(i).cmrate05,
      bd_data(i).commn01,
      bd_data(i).commn02,
      bd_data(i).commn03,
      bd_data(i).commn04,
      bd_data(i).commn05,
      bd_data(i).zagtgprm01,
      bd_data(i).zagtgprm02,
      bd_data(i).zagtgprm03,
      bd_data(i).zagtgprm04,
      bd_data(i).zagtgprm05,
      bd_data(i).zcollfee01,
      bd_data(i).mbrno,
      bd_data(i).dpntno,
      bd_data(i).prbilfdt,
      bd_data(i).refnumchunk;
      -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BD_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGBILL2_IG', SUBSTR(bd_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_errormsg     := temp_tablename || '-Before getting appno:';
      v_app          := bd_data(bd_data.count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_billhdr2%notfound;
  END LOOP;
  CLOSE cur_billhdr2;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count, v_output_count);
  RETURN;
END dm_billheader2_to_ig;
-- Procedure for DM Bill Header2 IG movement <ENDS> Here

END DM_bulkcopy_billhis;

/
