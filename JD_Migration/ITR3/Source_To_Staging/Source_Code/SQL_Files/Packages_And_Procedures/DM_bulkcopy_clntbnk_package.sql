create or replace PACKAGE                          DM_bulkcopy_clntbnk AS

 PROCEDURE DM_Clntbnk_TO_IG(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000, 
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_clntbnk;

/


create or replace PACKAGE BODY   DM_bulkcopy_clntbnk IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Client Bank IG movement <STARTS> Here
  PROCEDURE dm_clntbnk_to_ig
    (
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N'
    )
  IS
  TYPE ig_array
IS
  TABLE OF titdmgclntbank%rowtype;
  st_data ig_array;
  v_app titdmgclntbank%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE clnt_rc
IS
  REF
  CURSOR;
    cur_clntbank clnt_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
    --CURSOR CUR_CLNTBANK IS
    --SELECT * FROM TITDMGCLNTBANK;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGCLNTBANK';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTBANK DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load
    END IF;
    --  EXECUTE IMMEDIATE 'select count(1) from TITDMGCLNTBANK WHERE NOT EXISTS (SELECT ''X'' FROM '||temp_tablename||' TQ WHERE TQ.REFNUM=REFNUM and TQ.SEQNO = SEQNO)' INTO V_INPUT_COUNT;
    sqlstmt := 'SELECT * FROM TITDMGCLNTBANK where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.REFNUM=TITDMGCLNTBANK.REFNUM and DT.SEQNO = TITDMGCLNTBANK.SEQNO) ORDER BY TITDMGCLNTBANK.REFNUM,TITDMGCLNTBANK.SEQNO' ;
    OPEN cur_clntbank FOR sqlstmt;
    LOOP
      FETCH cur_clntbank BULK COLLECT INTO st_data;--LIMIT p_array_size;
    v_errormsg := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      v_input_count := v_input_count + st_data.count;
      FORALL i                      IN 1..st_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' ( 
	  REFNUM,                                           
SEQNO,                                           
CURRTO,                                           
BANKCD ,                                           
BRANCHCD,                                           
FACTHOUS ,                                           
BANKACCKEY,                                           
CRDTCARD,                                           
BANKACCDSC,                                           
BNKACTYP,                                           
TRANSHIST)                                 
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
:11)'
      USING 
	  st_data(i).refnum, 
      st_data(i).seqno,
      st_data(i).currto,
      st_data(i).bankcd,
      st_data(i).branchcd,
      st_data (i).facthous,
      st_data(i).bankacckey,
      st_data(i).crdtcard,
      st_data(i).bankaccdsc,
      st_data(i).bnkactyp,
      st_data (i).transhist;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
      /*EXECUTE IMMEDIATE 'Update '
      || temp_tablename
      || ' set REFNUM = concat(REFNUM,''00'')';*/
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGCLNTBANK_IG', SUBSTR(st_data(SQL%bulk_exceptions(beindx).error_index).refnum || st_data(SQL%bulk_exceptions(beindx).error_index).seqno, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := st_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_clntbank%notfound;
  END LOOP;
CLOSE cur_clntbank;
v_output_count := v_input_count - l_output_count;
IF g_err_flg    = 0 THEN
  v_errormsg   := 'SUCCESS';
  temp_no      := DM_data_trans_gen.ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg , 'S', v_input_count, v_output_count);
ELSE
  v_errormsg := 'COMPLETED WITH ERROR';
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg , 'F', v_input_count, v_output_count);
END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg , 'F', v_input_count, v_output_count);
  RETURN;
END dm_clntbnk_to_ig;
-- Procedure for DM Client Bank IG movement <ENDS> Here


END DM_bulkcopy_clntbnk;

/