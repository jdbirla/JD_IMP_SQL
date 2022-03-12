create or replace PACKAGE    DM_bulkcopy_perclnthis AS

  PROCEDURE DM_Clienthist_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');

END DM_bulkcopy_perclnthis;

/

create or replace PACKAGE BODY   DM_bulkcopy_perclnthis IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
PROCEDURE dm_clienthist_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgcltrnhis%rowtype;
  ch_data ig_array;
  v_app titdmgcltrnhis%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE clnth_rc
IS
  REF
  CURSOR;
    cur_clenthis clnth_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGCLTRNHIS';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLTRNHIS DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGCLTRNHIS where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.REFNUM=TITDMGCLTRNHIS.REFNUM and DT.ZSEQNO = TITDMGCLTRNHIS.ZSEQNO) ORDER BY TITDMGCLTRNHIS.REFNUM,TITDMGCLTRNHIS.ZSEQNO' ;
    OPEN cur_clenthis FOR sqlstmt;
    LOOP
      FETCH cur_clenthis BULK COLLECT INTO ch_data;-- LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + ch_data.count;
      FORALL i                      IN 1..ch_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' ( refnum,
			zseqno,
			effdate,
			lsurname,
			lgivname,
			zkanagivname,
			zkanasurname,
			zkanasnmnor,
			zkanagnmnor,
			cltpcode,
			cltaddr01,
			cltaddr02,
			cltaddr03,
			zkanaddr01,
			zkanaddr02,
			cltsex,
			addrtype,
			cltphone01,
			cltphone02,
			occpcode,
			cltdob,
			zoccdsc,
			zworkplce,
			zaltrcde01,
			transhist,
			zendcde,
			clntroleflg,
			policystatus,
			policytype,
			priorty
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
:30)'
      USING ch_data(i).refnum,
			ch_data(i).zseqno,
			ch_data(i).effdate,
			ch_data(i).lsurname,
			ch_data(i).lgivname,
			ch_data(i).zkanagivname,
			ch_data(i).zkanasurname,
			ch_data(i).zkanasnmnor,
			ch_data(i).zkanagnmnor,
			ch_data(i).cltpcode,
			ch_data(i).cltaddr01,
			ch_data(i).cltaddr02,
			ch_data(i).cltaddr03,
			ch_data(i).zkanaddr01,
			ch_data(i).zkanaddr02,
			ch_data(i).cltsex,
			ch_data(i).addrtype,
			ch_data(i).cltphone01,
			ch_data(i).cltphone02,
			ch_data(i).occpcode,
			ch_data(i).cltdob,
			ch_data(i).zoccdsc,
			ch_data(i).zworkplce,
			ch_data(i).zaltrcde01,
			ch_data(i).transhist,
			ch_data(i).zendcde,
			ch_data(i).clntroleflg,
			ch_data(i).policystatus,
			ch_data(i).policytype,
			ch_data(i).priorty;
      --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + CH_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGCLTRNHIS_IG', SUBSTR(ch_data(SQL%bulk_exceptions(beindx).error_index).refnum || ch_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15) , SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := ch_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_clenthis%notfound;
  END LOOP;
  CLOSE cur_clenthis;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg , 'S', v_input_count, v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg , 'F', v_input_count, v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_clienthist_to_ig;


END DM_bulkcopy_perclnthis;


/