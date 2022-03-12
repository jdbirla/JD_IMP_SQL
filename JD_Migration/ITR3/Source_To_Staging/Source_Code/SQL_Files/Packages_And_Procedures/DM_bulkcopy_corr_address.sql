create or replace PACKAGE                          DM_bulkcopy_corr_address AS

  PROCEDURE dm_corraddr_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');

END DM_bulkcopy_corr_address;
/

create or replace PACKAGE BODY DM_bulkcopy_corr_address IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;

-- Procedure for DM_Letterhist_to_ig IG movement <STARTS> Here
	PROCEDURE dm_corraddr_to_ig(
		v_ig_schema  IN VARCHAR2,
		p_array_size IN PLS_INTEGER DEFAULT 1000,
		p_delta      IN CHAR DEFAULT 'N' )
	IS
	TYPE ig_array
	IS
	  TABLE OF titdmgcoraddr%rowtype;
	  ca_data ig_array;
	  v_app titdmgcoraddr%rowtype;
	  ig_endtime TIMESTAMP;
	  v_errormsg VARCHAR2(2000);
	  dml_errors EXCEPTION;
	  PRAGMA exception_init ( dml_errors, -24381 );
	TYPE stcorraddr_rc
	IS
	  REF
	  CURSOR;
		cur_stcorraddr stcorraddr_rc;
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
		temp_tablename := v_ig_schema || '.TITDMGCORADDR';
		IF p_delta      = 'Y' THEN
		  v_errormsg   := 'For Delta Load:';
		  EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCORADDR DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_ZMRDA00 WHERE DAPLNO = DT.CHDRNUM))' ;
		  COMMIT;
		END IF;
		sqlstmt := 'SELECT * FROM TITDMGCORADDR where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.CHDRNUM=TITDMGCORADDR.CHDRNUM ) ORDER BY TITDMGCORADDR.CHDRNUM' ;
		OPEN cur_stcorraddr FOR sqlstmt;
		LOOP
		  FETCH cur_stcorraddr BULK COLLECT INTO ca_data;--LIMIT p_array_size;
		v_errormsg := temp_tablename || '-Before Bulk Insert:';
		BEGIN
		  v_input_count := v_input_count + ca_data.count;
		  FORALL i                      IN 1..ca_data.count SAVE EXCEPTIONS
		  EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
		  ' ( CHDRNUM,
	ZKANASNM,
	ZKANAGNM,
	LSURNAME,
	LGIVNAME,
	CLTPCODE,
	CLTADDR01,
	CLTADDR02,
	CLTADDR03,
	CLTADDR04,
	ZKANADDR01,
	ZKANADDR02,
	ZKANADDR03,
	ZKANADDR04,
	CLTPHONE01                                       
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
	:15                                            
	)'
		  USING ca_data(i).CHDRNUM,
				ca_data(i).ZKANASNM,
				ca_data(i).ZKANAGNM,
				ca_data(i).LSURNAME,
				ca_data(i).LGIVNAME,
				ca_data(i).CLTPCODE,
				ca_data(i).CLTADDR01,
				ca_data(i).CLTADDR02,
				ca_data(i).CLTADDR03,
				ca_data(i).CLTADDR04,
				ca_data(i).ZKANADDR01,
				ca_data(i).ZKANADDR02,
				ca_data(i).ZKANADDR03,
				ca_data(i).ZKANADDR04,
				ca_data(i).CLTPHONE01;

		  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ca_data.COUNT;
		EXCEPTION
		WHEN OTHERS THEN
		  FOR beindx IN 1..SQL%bulk_exceptions.count
		  LOOP
			v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
			DM_data_trans_gen.error_logs('TITDMGCORADDR_IG', ca_data(SQL%bulk_exceptions(beindx).error_index).chdrnum , v_errormsg);
			l_output_count := l_output_count + 1;
		  END LOOP;
		END;
		v_app            := NULL;
		IF v_input_count <> 0 THEN
		  v_app := ca_data(v_input_count);
		END IF;
		COMMIT;
		EXIT
	  WHEN cur_stcorraddr%notfound;
	  END LOOP;
	  CLOSE cur_stcorraddr;
	  v_output_count := v_input_count - l_output_count;
	  IF g_err_flg    = 0 THEN
		v_errormsg   := 'SUCCESS';
		temp_no      := DM_data_trans_gen.ig_control_log('TITDMGCORADDR', 'TITDMGCORADDR_IG', systimestamp, v_app.chdrnum, v_errormsg , 'S', v_input_count, v_output_count);
	  ELSE
		v_errormsg := 'COMPLETED WITH ERROR';
		temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCORADDR', 'TITDMGCORADDR_IG', systimestamp, v_app.chdrnum, v_errormsg , 'F', v_input_count, v_output_count);
	  END IF;
	EXCEPTION
	WHEN OTHERS THEN
	  v_errormsg := v_errormsg || '-' || sqlerrm;
	  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGCORADDR', 'TITDMGCORADDR_IG', systimestamp, v_app.chdrnum, v_errormsg , 'F', v_input_count, v_output_count);
	  RETURN;
	END dm_corraddr_to_ig;
	-- Procedure for dm_corraddr_to_ig IG movement <EndS> Here

END DM_bulkcopy_corr_address;
/