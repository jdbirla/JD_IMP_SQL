create or replace PACKAGE     DM_bulkcopy_corpclnt AS

  PROCEDURE DM_Clntcorp_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      

END DM_bulkcopy_corpclnt;
/

create or replace PACKAGE BODY   DM_bulkcopy_corpclnt IS

  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Client CORP IG movement <STARTS> Here

-- Procedure for DM Client CORP IG movement <STARTS> Here given by Hodumi-san

PROCEDURE DM_clntcorp_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS
          TYPE IG_ARRAY IS TABLE OF TITDMGCLNTCORP%ROWTYPE;
          CC_DATA IG_ARRAY;
          V_APP TITDMGCLNTCORP%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;

          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          TYPE clntcrp_rc is REF CURSOR;
          CUR_CLNTCRP clntcrp_rc;

          sqlstmt VARCHAR2(2000):=null;


l_OUTPUT_COUNT NUMBER:=0;

       BEGIN

        V_INPUT_COUNT:=0;
        V_OUTPUT_COUNT:=0;
        l_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;

         dm_data_trans_gen.ig_starttime   := systimestamp;
            temp_tablename:=v_ig_schema||'.TITDMGCLNTCORP';
         IF p_delta = 'Y' THEN
             V_ERRORMSG:= 'For Delta Load:';
             ----EXECUTE IMMEDIATE 'DELETE FROM '||temp_tablename||' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTCORP DT WHERE DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) = T.CLNTKEY || TRIM(T.AGNTNUM) || TRIM(T.MPLNUM) and DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) in (select distinct CLNTKEY || TRIM(AGNTNUM) || TRIM(MPLNUM) from TMP_TITDMGCLNTCORP))';
             EXECUTE IMMEDIATE 'DELETE FROM '||temp_tablename||' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTCORP DT WHERE DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) = T.CLNTKEY || TRIM(T.AGNTNUM) || TRIM(T.MPLNUM) and DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) in (select distinct CLNTKEY || TRIM(AGNTNUM) || TRIM(MPLNUM) from TITDMGCLNTCORP))';
             COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTCORP for Delta Load
         END IF;
          sqlstmt:='SELECT * FROM TITDMGCLNTCORP where not exists ( select ''x'' from '||temp_tablename||' DT WHERE DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) = TITDMGCLNTCORP.CLNTKEY || TRIM(TITDMGCLNTCORP.AGNTNUM) || TRIM(TITDMGCLNTCORP.MPLNUM)) ORDER BY TITDMGCLNTCORP.CLNTKEY,TITDMGCLNTCORP.AGNTNUM,TITDMGCLNTCORP.MPLNUM';

           OPEN CUR_CLNTCRP FOR sqlstmt;
           LOOP
            FETCH CUR_CLNTCRP BULK COLLECT INTO CC_DATA  ;--LIMIT p_array_size;


             V_ERRORMSG:=temp_tablename||'-Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + CC_DATA.COUNT;
           FORALL i IN 1..CC_DATA.COUNT SAVE EXCEPTIONS

EXECUTE IMMEDIATE 'INSERT INTO '||temp_tablename||' (  CLTTYPE,
                                             CLTADDR01,
                                             CLTADDR02,
                                             CLTADDR03,
                                             CLTADDR04,
                                             ZKANADDR01,
                                             ZKANADDR02,
                                             ZKANADDR03,
                                             ZKANADDR04,
                                             CLTPCODE,
                                             CLTPHONE01,
                                             CLTPHONE02,
                                             CLTDOBX,
                                             CLTSTAT,
                                             FAXNO,
                                             LSURNAME,
                                             ZKANASNM,
                                             CLNTKEY,
                                             AGNTNUM,
                                             MPLNUM)
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
                                            :20)'
                                            USING
                                           CC_DATA(i).CLTTYPE,
                                             CC_DATA(i).CLTADDR01,
                                             CC_DATA(i).CLTADDR02,
                                             CC_DATA(i).CLTADDR03,
                                             CC_DATA(i).CLTADDR04,
                                             CC_DATA(i).ZKANADDR01,
                                             CC_DATA(i).ZKANADDR02,
                                             CC_DATA(i).ZKANADDR03,
                                             CC_DATA(i).ZKANADDR04,
                                             CC_DATA(i).CLTPCODE,
                                             CC_DATA(i).CLTPHONE01,
                                             CC_DATA(i).CLTPHONE02,
                                             CC_DATA(i).CLTDOBX,
                                             CC_DATA(i).CLTSTAT,
                                             CC_DATA(i).FAXNO,
                                             CC_DATA(i).LSURNAME,
                                             CC_DATA(i).ZKANASNM,
                                             CC_DATA(i).CLNTKEY,
                                             CC_DATA(i).AGNTNUM,
                                             CC_DATA(i).MPLNUM;
           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + CC_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
               DM_data_trans_gen.ERROR_LOGS('TITDMGCLNTCORP_IG',substr(CC_DATA(sql%bulk_exceptions(beindx).error_index).CLNTKEY,1,15),SUBSTR('(' || CC_DATA(sql%bulk_exceptions(beindx).error_index).CLNTKEY || CC_DATA(sql%bulk_exceptions(beindx).error_index).AGNTNUM || CC_DATA(sql%bulk_exceptions(beindx).error_index).MPLNUM || ')' || V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=CC_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_CLNTCRP%NOTFOUND;
           END LOOP;
        CLOSE CUR_CLNTCRP;


V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := DM_data_trans_gen.IG_CONTROL_LOG('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.IG_CONTROL_LOG('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := DM_data_trans_gen.IG_CONTROL_LOG('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_Clntcorp_to_ig;

-- Procedure for DM Client CORP IG movement <ENDS> Here



END DM_bulkcopy_corpclnt;
/
