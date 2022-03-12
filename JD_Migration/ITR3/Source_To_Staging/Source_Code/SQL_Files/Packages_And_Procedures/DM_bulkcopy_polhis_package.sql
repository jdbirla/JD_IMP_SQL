create or replace PACKAGE  DM_bulkcopy_polhis AS

  PROCEDURE dm_Policytran_transform_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_cov_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_apirno_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
      
END DM_bulkcopy_polhis;

/


create or replace PACKAGE BODY   DM_bulkcopy_polhis IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for dm_Policytran_transform_to_ig IG movement <STARTS> Here
PROCEDURE dm_Policytran_transform_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF TITDMGPOLTRNH%rowtype;
  st_data ig_array;
  v_app TITDMGPOLTRNH%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE clnt_rc
IS
  REF
  CURSOR;
    cur_POLTRNH clnt_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
    --CURSOR CUR_CLNTBANK IS
    --SELECT * FROM TITDMGPOLTRNH;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGPOLTRNH';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGPOLTRNH DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGPOLTRNH for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGPOLTRNH where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGPOLTRNH.CHDRNUM and DT.ZSEQNO = TITDMGPOLTRNH.ZSEQNO) ORDER BY TITDMGPOLTRNH.CHDRNUM,TITDMGPOLTRNH.ZSEQNO' ;
    OPEN cur_POLTRNH FOR sqlstmt;
    LOOP
      FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + st_data.count;
      FORALL i                      IN 1..st_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (            
CHDRNUM                                            
, ZSEQNO                                            
, EFFDATE                                            
, CLIENT_CATEGORY                                            
, MBRNO                                            
, CLTRELN                                            
, ZINSROLE                                            
, CLIENTNO                                            
, ZALTREGDAT                                            
, ZALTRCDE01                                            
, ZINHDSCLM                                            
, ZUWREJFLG                                            
, ZSTOPBPJ                                            
, ZTRXSTAT                                            
, ZSTATRESN                                            
, ZACLSDAT                                            
, APPRDTE                                            
, ZPDATATXDTE                                            
, ZPDATATXFLG                                            
, ZREFUNDAM                                            
, ZPAYINREQ                                            
, CRDTCARD                                            
, PREAUTNO                                            
, BNKACCKEY01                                            
, ZENSPCD01                                            
, ZENSPCD02                                            
, ZCIFCODE                                            
, ZDDREQNO                                            
, ZWORKPLCE2                                            
, BANKACCDSC01                                            
, BANKKEY                                            
, BNKACTYP01                                            
, CURRTO                                            
, B1_ZKNJFULNM                                            
, B2_ZKNJFULNM                                            
, B3_ZKNJFULNM                                            
, B4_ZKNJFULNM                                            
, B5_ZKNJFULNM                                            
, B1_CLTADDR01                                            
, B2_CLTADDR01                                            
, B3_CLTADDR01                                            
, B4_CLTADDR01                                            
, B5_CLTADDR01                                            
, B1_BNYPC                                            
, B2_BNYPC                                            
, B3_BNYPC                                            
, B4_BNYPC                                            
, B5_BNYPC                                            
, B1_BNYRLN                                            
, B2_BNYRLN                                            
, B3_BNYRLN                                            
, B4_BNYRLN                                            
, B5_BNYRLN                                            
,ZSOLCTFLG
,ZPLANCDE
,ZCMPCODE
,ZCPNSCDE
,ZSALECHNL
,TRANCDE
        
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
:28,                                            
:29,                                            
:30,                                            
:31,                                            
:32,                                            
:33,                                            
:34,                                            
:35,                                            
:36,                                            
:37,                                            
:38,                                            
:39,                                            
:40,                                            
:41,                                            
:42,                                            
:43,                                            
:44,                                            
:45,                                            
:46,                                            
:47,                                            
:48,                                            
:49,                                            
:50,                                            
:51,                                            
:52,                                            
:53,                                            
:54,
:55,
:56,
:57,
:58,
:59          
)'
      USING st_data(i).CHDRNUM,
      st_data(i).ZSEQNO,
      st_data(i).EFFDATE,
      st_data(i).CLIENT_CATEGORY,
      st_data(i).MBRNO,
      st_data(i).CLTRELN,
      st_data(i).ZINSROLE,
      st_data(i).CLIENTNO,
      st_data(i).ZALTREGDAT,
      st_data(i).ZALTRCDE01,
      st_data(i).ZINHDSCLM,
      st_data(i).ZUWREJFLG,
      st_data(i).ZSTOPBPJ,
      st_data(i).ZTRXSTAT,
      st_data(i).ZSTATRESN,
      st_data(i).ZACLSDAT,
      st_data(i).APPRDTE,
      st_data(i).ZPDATATXDTE,
      st_data(i).ZPDATATXFLG,
      st_data(i).ZREFUNDAM,
      st_data(i).ZPAYINREQ,
      st_data(i).CRDTCARD,
      st_data(i).PREAUTNO,
      st_data(i).BNKACCKEY01,
      st_data(i).ZENSPCD01,
      st_data(i).ZENSPCD02,
      st_data(i).ZCIFCODE,
      st_data(i).ZDDREQNO,
      st_data(i).ZWORKPLCE2,
      st_data(i).BANKACCDSC01,
      st_data(i).BANKKEY,
      st_data(i).BNKACTYP01,
      st_data(i).CURRTO,
      st_data(i).B1_ZKNJFULNM,
      st_data(i).B2_ZKNJFULNM,
      st_data(i).B3_ZKNJFULNM,
      st_data(i).B4_ZKNJFULNM,
      st_data(i).B5_ZKNJFULNM,
      st_data(i).B1_CLTADDR01,
      st_data(i).B2_CLTADDR01,
      st_data(i).B3_CLTADDR01,
      st_data(i).B4_CLTADDR01,
      st_data(i).B5_CLTADDR01,
      st_data(i).B1_BNYPC,
      st_data(i).B2_BNYPC,
      st_data(i).B3_BNYPC,
      st_data(i).B4_BNYPC,
      st_data(i).B5_BNYPC,
      st_data(i).B1_BNYRLN,
      st_data(i).B2_BNYRLN,
      st_data(i).B3_BNYRLN,
      st_data(i).B4_BNYRLN,
      st_data(i).B5_BNYRLN,
	  st_data(i).ZSOLCTFLG,
	  st_data(i).ZPLANCDE,
	  st_data(i).ZCMPCODE,
	  st_data(i).ZCPNSCDE,
	  st_data(i).ZSALECHNL,
	  st_data(i).TRANCDE
	  ;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
      --        EXECUTE IMMEDIATE 'Update '
      --                          || temp_tablename
      ---                          || ' set CHDRNUM = concat(CHDRNUM,''00'')';
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGPOLTRNH_IG', SUBSTR(st_data(SQL%bulk_exceptions(beindx).error_index).chdrnum || st_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := st_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_POLTRNH%notfound;
  END LOOP;
  CLOSE cur_POLTRNH;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg , 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg , 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_Policytran_transform_to_ig;
-- Procedure for dm_Policytran_transform_to_ig IG movement <ENDS> Here
-- Procedure for dm_polhis_cov_ig <STARTS> Here
PROCEDURE dm_polhis_cov_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF TITDMGMBRINDP2%rowtype;
  st_data ig_array;
  v_app TITDMGMBRINDP2%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE clnt_rc
IS
  REF
  CURSOR;
    cur_POLTRNH clnt_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
    --CURSOR CUR_CLNTBANK IS
    --SELECT * FROM TITDMGMBRINDP2;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGMBRINDP2';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP2 DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGMBRINDP2 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.REFNUM=TITDMGMBRINDP2.REFNUM ) ORDER BY TITDMGMBRINDP2.REFNUM' ;
    OPEN cur_POLTRNH FOR sqlstmt;
    LOOP
      FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + st_data.count;
      FORALL i                      IN 1..st_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (                                                                                                                                                               
			  REFNUM                                                                                                                                       
,             PRODTYP                                                                                                                                       
,             EFFDATE                                                                                                                                       
,             APREM                                                                                                                                       
,             HSUMINSU                                                                                                                                       
,             ZTAXFLG                                                                                                                                       
,             MBRNO                                                                                                                                       
,             DPNTNO                                                                                                                                       
,             NDRPREM                                                                                                                                       
,             PRODTYP02                                                                                                                                       
,             ZINSTYPE 
,			  ZSEQNO
                                                                                                                                      

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
      USING st_data(i).REFNUM,
      st_data(i).PRODTYP,
      st_data(i).EFFDATE,
      st_data(i).APREM,
      st_data(i).HSUMINSU,
      st_data(i).ZTAXFLG,
      st_data(i).MBRNO,
      st_data(i).DPNTNO,
      st_data(i).NDRPREM,
      st_data(i).PRODTYP02,
      st_data(i).ZINSTYPE,
      st_data(i).ZSEQNO	  ;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGMBRINDP2_IG', SUBSTR(st_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := st_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_POLTRNH%notfound;
  END LOOP;
  CLOSE cur_POLTRNH;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum , v_errormsg , 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum, v_errormsg , 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_polhis_cov_ig;
-- Procedure for dm_polhis_cov_ig <ENDS> Here
-- Procedure for dm_polhis_apirno_ig <STARTS> Here
PROCEDURE dm_polhis_apirno_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF TITDMGAPIRNO%rowtype;
  st_data ig_array;
  v_app TITDMGAPIRNO%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE clnt_rc
IS
  REF
  CURSOR;
    cur_POLTRNH clnt_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
    --CURSOR CUR_CLNTBANK IS
    --SELECT * FROM TITDMGAPIRNO;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGAPIRNO';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGAPIRNO DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGAPIRNO for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGAPIRNO where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGAPIRNO.CHDRNUM ) ORDER BY TITDMGAPIRNO.CHDRNUM' ;
    OPEN cur_POLTRNH FOR sqlstmt;
    LOOP
      FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + st_data.count;
      FORALL i                      IN 1..st_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename || ' (            
CHDRNUM           
, MBRNO           
, ZINSTYPE           
, ZAPIRNO           
, FULLKANJINAME           
)                                 
VALUES                                           
(:1,           
:2,           
:3,           
:4,           
:5           
)' USING st_data(i).CHDRNUM,
      st_data(i).MBRNO,
      st_data(i).ZINSTYPE,
      st_data(i).ZAPIRNO,
      st_data(i).FULLKANJINAME ;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGAPIRNO_IG', SUBSTR(st_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := st_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_POLTRNH%notfound;
  END LOOP;
  CLOSE cur_POLTRNH;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg , 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg , 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_polhis_apirno_ig;

END DM_bulkcopy_polhis;

/