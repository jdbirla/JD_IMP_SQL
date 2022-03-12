create or replace PACKAGE                          DM_bulkcopy_agncy AS

  PROCEDURE DM_Agency_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_agncy;

/

create or replace PACKAGE BODY   DM_bulkcopy_agncy IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM_Agency_to_ig IG movement <STARTS> Here
PROCEDURE dm_agency_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE aj_array
IS
  TABLE OF titdmgagentpj%rowtype;
  aj_data aj_array;
  v_app titdmgagentpj%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE agency_rc
IS
  REF
  CURSOR;
    cur_agency agency_rc;
    aj_sqlstmt     VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGAGENTPJ';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGAGENTPJ DT WHERE DT.ZAREFNUM=T.ZAREFNUM)';
      COMMIT;
      -- Delete the records for the records exists in TITDMGAGENTPJ for Delta Load
    END IF;
    aj_sqlstmt := 'SELECT * FROM TITDMGAGENTPJ where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.ZAREFNUM=TITDMGAGENTPJ.ZAREFNUM) ORDER BY TITDMGAGENTPJ.ZAREFNUM';
    OPEN cur_agency FOR aj_sqlstmt;
    LOOP
      FETCH cur_agency BULK COLLECT INTO aj_data;--LIMIT p_array_size;
    v_input_count := v_input_count + aj_data.count;
    v_errormsg    := temp_tablename || '-Before Bulk Insert:';
    BEGIN
      FORALL i IN 1..aj_data.count SAVE EXCEPTIONS
      EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
      ' (ZAREFNUM,                                                        
AGTYPE,                                                        
AGNTBR,                                                        
SRDATE,                                                        
DATEEND,                                                        
STCA,                                                        
RIDESC,                                                        
AGCLSD,                                                        
ZREPSTNM,                                                        
ZAGREGNO,                                                        
CPYNAME,                                                        
ZTRGTFLG,                                                        
COUNT,                                                        
DCONSIGNEN,                                                        
ZCONSIDT,                                                        
ZINSTYP01,                                                        
CMRATE01,                                                        
ZINSTYP02,                                                        
CMRATE02,                                                        
ZINSTYP03,                                                        
CMRATE03,                                                        
ZINSTYP04,                                                        
CMRATE04,                                                        
ZINSTYP05,                                                        
CMRATE05,                                                        
ZINSTYP06,                                                        
CMRATE06,                                                        
ZINSTYP07,                                                        
CMRATE07,                                                        
ZINSTYP08,                                                        
CMRATE08,                                                        
ZINSTYP09,                                                        
CMRATE09,                                                        
ZINSTYP10,                                                        
CMRATE10,                                                        
CLNTNUM,                                                        
ZDRAGNT)                                 
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
:37)'
      USING aj_data(i).zarefnum,
      aj_data(i).agtype,
      aj_data(i).agntbr,
      aj_data(i).srdate,
      aj_data(i).dateend,
      aj_data (i).stca,
      aj_data(i).ridesc,
      aj_data(i).agclsd,
      aj_data(i).zrepstnm,
      aj_data(i).zagregno,
      aj_data(i).cpyname ,
      aj_data(i).ztrgtflg,
      aj_data(i)."COUNT",
      aj_data(i).dconsignen,
      aj_data(i).zconsidt,
      aj_data(i).zinstyp01 ,
      aj_data(i).cmrate01,
      aj_data(i).zinstyp02,
      aj_data(i).cmrate02,
      aj_data(i).zinstyp03,
      aj_data(i).cmrate03 ,
      aj_data(i).zinstyp04,
      aj_data(i).cmrate04,
      aj_data(i).zinstyp05,
      aj_data(i).cmrate05,
      aj_data(i).zinstyp06 ,
      aj_data(i).cmrate06,
      aj_data(i).zinstyp07,
      aj_data(i).cmrate07,
      aj_data(i).zinstyp08,
      aj_data(i).cmrate08 ,
      aj_data(i).zinstyp09,
      aj_data(i).cmrate09,
      aj_data(i).zinstyp10,
      aj_data(i).cmrate10,
      aj_data(i).clntnum ,
      aj_data(i).zdragnt;
      --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + AJ_DATA.COUNT;
    EXCEPTION
    WHEN dml_errors THEN
      FOR beindx IN 1..SQL%bulk_exceptions.count
      LOOP
        v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
        DM_data_trans_gen.error_logs('TITDMGAGENTPJ_IG', SUBSTR(aj_data(SQL%bulk_exceptions(beindx).error_index).zarefnum, 1, 15), SUBSTR(v_errormsg, 1, 1000));
        l_output_count := l_output_count + 1;
      END LOOP;
    END;
    v_app            := NULL;
    IF v_input_count <> 0 THEN
      v_app          := aj_data(v_input_count);
    END IF;
    COMMIT;
    EXIT
  WHEN cur_agency%notfound;
  END LOOP;
  CLOSE cur_agency;
  v_output_count := v_input_count - l_output_count;
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errormsg := v_errormsg || '-' || sqlerrm;
  temp_no    := DM_data_trans_gen.ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg, 'F', v_input_count , v_output_count);
  RETURN;
END dm_agency_to_ig;
-- Procedure for DM_Agency_to_ig IG movement <ENDS> Here

END DM_bulkcopy_agncy;

/