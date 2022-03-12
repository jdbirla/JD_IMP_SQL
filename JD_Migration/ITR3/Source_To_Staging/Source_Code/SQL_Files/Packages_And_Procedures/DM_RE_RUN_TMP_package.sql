create or replace PACKAGE DM_RE_RUN_TMP AS
  FUNCTION IG_CONTROL_LOG(v_src_tabname IN VARCHAR2, v_target_tb IN VARCHAR2, v_endtime IN TIMESTAMP,v_applno IN VARCHAR2,l_errmsg IN VARCHAR2, l_st IN VARCHAR2,v_in_cnt IN NUMBER DEFAULT 0,v_out_cnt IN NUMBER DEFAULT 0) return number;
  PROCEDURE DM_RERUN_ZMRAP00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_RERUN_AGENCY( p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TRAN_STATUS_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRAT00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRLH00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_SPLN(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRIC00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRIS00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRRPT00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRISA00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRFCT00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMRRS00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ZMREI00(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_GRP_POLICY_FREE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_LETTER_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_COL_FEE_LST(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_DMPR(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_DECLINE_REASON_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_CARD_ENDORSER_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_ALTER_REASON_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_BTDATE_PTDATE_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_DSH_CODE_REF(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGCLNTCORP(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGCAMPCDE(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGSALEPLN1(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGSALEPLN2(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGBILL1(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGBILL2(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGREF1(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGREF2(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGMBRINDP3(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_PJ_TITDMGCOLRES(p_array_size IN PLS_INTEGER DEFAULT 1000);
  PROCEDURE DM_TITDMGAGENTPJ(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_MSTPOLDB(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_MSTPOLGRP(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_TITDMGMASPOL(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_TITDMGENDCTPF(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_TITDMGINSSTPL(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_ZMRULA00(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_SOLICITATION_FLG_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_KANA_ADDRESS_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_SPPLANCONVERTION(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_DMPR1(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE DM_MIPHSTDB(p_array_size IN PLS_INTEGER DEFAULT 1000);
 PROCEDURE ERROR_LOGS(v_jobnm IN VARCHAR2,v_apnum IN VARCHAR2, v_msg IN VARCHAR2);
END DM_RE_RUN_TMP;
/

create or replace PACKAGE BODY DM_RE_RUN_TMP
IS

      V_CNT number:=0;
      V_INPUT_COUNT NUMBER:=0;
      V_OUTPUT_COUNT NUMBER:=0;
      IG_STARTTIME   TIMESTAMP;
      L_ERR_FLG NUMBER :=0;
      G_ERR_FLG NUMBER :=0;


PROCEDURE ERROR_LOGS(v_jobnm IN VARCHAR2,v_apnum IN VARCHAR2, v_msg IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   INSERT INTO ERROR_LOG(JOBNAME,LAST_APPNO,ERROR_MESSAGE,RUNTIME)
                         VALUES(v_jobnm,v_apnum,v_msg,SYSTIMESTAMP);
   L_ERR_FLG:=1;
   G_ERR_FLG:=1;
   COMMIT;
END;

      FUNCTION IG_CONTROL_LOG(v_src_tabname IN VARCHAR2, v_target_tb IN VARCHAR2, v_endtime IN TIMESTAMP,v_applno IN VARCHAR2,l_errmsg IN VARCHAR2, l_st IN VARCHAR2,v_in_cnt IN NUMBER DEFAULT 0,v_out_cnt IN NUMBER DEFAULT 0)
       RETURN number
       IS
       BEGIN
          V_CNT := 0;
          SELECT COUNT(1) INTO V_CNT  FROM IG_COPY_CNTL_TABLE WHERE TARGET_TABLE =v_target_tb;

          IF V_CNT > 0 THEN
            UPDATE IG_COPY_CNTL_TABLE
               SET JOB_DETAIL ='RE-RUN FOR SQL LOADER',
                   SOURCE_TABLE = v_src_tabname,
                   TARGET_TABLE=v_target_tb,
                   START_TIMESTAMP = TO_CHAR(IG_STARTTIME,'YYYY-MM-DD HH24:MI:SS'),
                   END_TIMESTAMP = TO_CHAR(v_endtime,'YYYY-MM-DD HH24:MI:SS'),
                   INPUT_CNT = v_in_cnt,
                   OUTPUT_CNT = v_out_cnt,
                   LAST_PROCESSED_APPNO = v_applno,
                   ERROR_MSG = l_errmsg,
                   STATUS= l_st
             WHERE TARGET_TABLE =v_target_tb;

          ELSE
             INSERT INTO IG_COPY_CNTL_TABLE
                               (JOB_DETAIL,
                                SOURCE_TABLE,
                                TARGET_TABLE,
                                START_TIMESTAMP,
                                END_TIMESTAMP,
                                INPUT_CNT,
                                OUTPUT_CNT,
                                LAST_PROCESSED_APPNO,
                                ERROR_MSG,
                                STATUS)
                         VALUES('RE-RUN FOR SQL LOADER',
                                 v_src_tabname,
                                 v_target_tb,
                                 TO_CHAR(IG_STARTTIME,'YYYY-MM-DD HH24:MI:SS'),
                                 TO_CHAR(v_endtime,'YYYY-MM-DD HH24:MI:SS'),
                                 v_in_cnt,
                                 v_out_cnt,
                                 v_applno,
                                 l_errmsg,
                                 l_st);
          END IF;
          COMMIT;
          return 0;
       EXCEPTION
          WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE('IG_CONTROL_LOG:'||SQLERRM);
              return 1;
       END IG_CONTROL_LOG;


-- Procedure for RE-RUN SQL LOADER - ZMRAP00 <STARTS> Here

 PROCEDURE DM_RERUN_ZMRAP00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRAP00%ROWTYPE;
          ST_DATA IG_ARRAY;
          V_APP TMP_ZMRAP00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TMP IS
               SELECT * FROM TMP_ZMRAP00;
               tb_str varchar2(1000):= null;

               l_OUTPUT_COUNT NUMBER:=0;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;

         IG_STARTTIME := SYSTIMESTAMP;


             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRAP00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRAP00 DT WHERE DT.APCUCD =ZMRAP00.APCUCD);
         -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load

           OPEN CUR_TMP;
           LOOP
            FETCH CUR_TMP BULK COLLECT INTO ST_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ST_DATA.COUNT;
           FORALL i IN 1..ST_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRAP00 ( APCUCD,
                                           APEPST,
                                           APCVCD,
                                           APCWCD,
                                           APCXCD,
                                           APCYCD,
                                           APL6CD,
                                           APA2DT,
                                           APBEDT,
                                           APEVST,
                                           APF9CD,
                                           APA8ST,
                                           APBLST,
                                           APCZCD,
                                           APC0CD,
                                           APC1CD,
                                           APC2CD,
                                           APC3CD,
                                           APC4CD,
                                           APC5CD,
                                           APA9ST,
                                           APC6CD,
                                           APC7CD,
                                           APC8CD,
                                           APC9CD,
                                           APCACD,
                                           APB0TX,
                                           APB1TX,
                                           APB2TX,
                                           APB3TX,
                                           APB7IG,
                                           APB8IG,
                                           APB9IG,
                                           APCAIG,
                                           APB4TX,
                                           APB5TX,
                                           APB6TX,
                                           APCBIG,
                                           APCCIG,
                                           APA3DT,
                                           APB1NB,
                                           APBAST,
                                           APB2NB,
                                           APB7TX,
                                           APB8TX,
                                           APCDIG,
                                           APCEIG,
                                           APB9TX,
                                           APCATX,
                                           APDLCD,
                                           APD9CD,
                                           APCBTX,
                                           APCCTX,
                                           APCDTX,
                                           APCETX,
                                           APCFIG,
                                           APCGIG,
                                           APCHIG,
                                           APCIIG,
                                           APBBST,
                                           APCJIG,
                                           APDACD,
                                           APAFQT,
                                           APDBCD,
                                           APDCCD,
                                           APDDCD,
                                           APDECD,
                                           APDFCD,
                                           APDGCD,
                                           APDHCD,
                                           APBCST,
                                           APBDST,
                                           APBEST,
                                           APBFST,
                                           APB3NB,
                                           APDCNB,
                                           APDDNB,
                                           APDENB,
                                           APCKIG,
                                           APBGST,
                                           APAGQT,
                                           APAHQT,
                                           APBHST,
                                           APAIQT,
                                           APCFTX,
                                           APCLIG,
                                           APC6IG,
                                           APCGTX,
                                           APAJQT,
                                           APDICD,
                                           APBIST,
                                           APBJST,
                                           APA4DT,
                                           APA5DT,
                                           APB9ST,
                                           APDJCD,
                                           APDKCD,
                                           APBKST,
                                           APEICD,
                                           APCHTX,
                                           APCITX,
                                           APCMIG,
                                           APCNIG,
                                           APCJTX,
                                           APFLST,
                                           APFMST,
                                           APLACD,
                                           APPRIG,
                                           APF8NB,
                                           APYOB1,
                                           APYOB2,
                                           APYOB3,
                                           APYOB4,
                                           APYOB5,
                                           APYOB6,
                                           APYOB7,
                                           APYOB8,
                                           APYOB9,
                                           APYOBA,
                                           APBOCD,
                                           APBPCD,
                                           APAMDT,
                                           APAATM,
                                           APBQCD,
                                           APANDT,
                                           APABTM,
                                           APBRCD,
                                           APB6IG,
                                           ZPOSBDSM_R,
                                           ZPOSBDSY_R,
                                           ZACMCLDT,
                                           ZPOSBDSM,
                                           ZPOSBDSY,
                                           APCVCDNEW,
										   OCCDATE)
                                 VALUES
                                           (ST_DATA(i).APCUCD,
                                           ST_DATA(i).APEPST,
                                           ST_DATA(i).APCVCD,
                                           ST_DATA(i).APCWCD,
                                           ST_DATA(i).APCXCD,
                                           ST_DATA(i).APCYCD,
                                           ST_DATA(i).APL6CD,
                                           ST_DATA(i).APA2DT,
                                           ST_DATA(i).APBEDT,
                                           ST_DATA(i).APEVST,
                                           ST_DATA(i).APF9CD,
                                           ST_DATA(i).APA8ST,
                                           ST_DATA(i).APBLST,
                                           ST_DATA(i).APCZCD,
                                           ST_DATA(i).APC0CD,
                                           ST_DATA(i).APC1CD,
                                           ST_DATA(i).APC2CD,
                                           ST_DATA(i).APC3CD,
                                           ST_DATA(i).APC4CD,
                                           ST_DATA(i).APC5CD,
                                           ST_DATA(i).APA9ST,
                                           ST_DATA(i).APC6CD,
                                           ST_DATA(i).APC7CD,
                                           ST_DATA(i).APC8CD,
                                           ST_DATA(i).APC9CD,
                                           ST_DATA(i).APCACD,
                                           ST_DATA(i).APB0TX,
                                           ST_DATA(i).APB1TX,
                                           ST_DATA(i).APB2TX,
                                           ST_DATA(i).APB3TX,
                                           ST_DATA(i).APB7IG,
                                           ST_DATA(i).APB8IG,
                                           ST_DATA(i).APB9IG,
                                           ST_DATA(i).APCAIG,
                                           ST_DATA(i).APB4TX,
                                           ST_DATA(i).APB5TX,
                                           ST_DATA(i).APB6TX,
                                           ST_DATA(i).APCBIG,
                                           ST_DATA(i).APCCIG,
                                           ST_DATA(i).APA3DT,
                                           ST_DATA(i).APB1NB,
                                           ST_DATA(i).APBAST,
                                           ST_DATA(i).APB2NB,
                                           ST_DATA(i).APB7TX,
                                           ST_DATA(i).APB8TX,
                                           ST_DATA(i).APCDIG,
                                           ST_DATA(i).APCEIG,
                                           ST_DATA(i).APB9TX,
                                           ST_DATA(i).APCATX,
                                           ST_DATA(i).APDLCD,
                                           ST_DATA(i).APD9CD,
                                           ST_DATA(i).APCBTX,
                                           ST_DATA(i).APCCTX,
                                           ST_DATA(i).APCDTX,
                                           ST_DATA(i).APCETX,
                                           ST_DATA(i).APCFIG,
                                           ST_DATA(i).APCGIG,
                                           ST_DATA(i).APCHIG,
                                           ST_DATA(i).APCIIG,
                                           ST_DATA(i).APBBST,
                                           ST_DATA(i).APCJIG,
                                           ST_DATA(i).APDACD,
                                           ST_DATA(i).APAFQT,
                                           ST_DATA(i).APDBCD,
                                           ST_DATA(i).APDCCD,
                                           ST_DATA(i).APDDCD,
                                           ST_DATA(i).APDECD,
                                           ST_DATA(i).APDFCD,
                                           ST_DATA(i).APDGCD,
                                           ST_DATA(i).APDHCD,
                                           ST_DATA(i).APBCST,
                                           ST_DATA(i).APBDST,
                                           ST_DATA(i).APBEST,
                                           ST_DATA(i).APBFST,
                                           ST_DATA(i).APB3NB,
                                           ST_DATA(i).APDCNB,
                                           ST_DATA(i).APDDNB,
                                           ST_DATA(i).APDENB,
                                           ST_DATA(i).APCKIG,
                                           ST_DATA(i).APBGST,
                                           ST_DATA(i).APAGQT,
                                           ST_DATA(i).APAHQT,
                                           ST_DATA(i).APBHST,
                                           ST_DATA(i).APAIQT,
                                           ST_DATA(i).APCFTX,
                                           ST_DATA(i).APCLIG,
                                           ST_DATA(i).APC6IG,
                                           ST_DATA(i).APCGTX,
                                           ST_DATA(i).APAJQT,
                                           ST_DATA(i).APDICD,
                                           ST_DATA(i).APBIST,
                                           ST_DATA(i).APBJST,
                                           ST_DATA(i).APA4DT,
                                           ST_DATA(i).APA5DT,
                                           ST_DATA(i).APB9ST,
                                           ST_DATA(i).APDJCD,
                                           ST_DATA(i).APDKCD,
                                           ST_DATA(i).APBKST,
                                           ST_DATA(i).APEICD,
                                           ST_DATA(i).APCHTX,
                                           ST_DATA(i).APCITX,
                                           ST_DATA(i).APCMIG,
                                           ST_DATA(i).APCNIG,
                                           ST_DATA(i).APCJTX,
                                           ST_DATA(i).APFLST,
                                           ST_DATA(i).APFMST,
                                           ST_DATA(i).APLACD,
                                           ST_DATA(i).APPRIG,
                                           ST_DATA(i).APF8NB,
                                           ST_DATA(i).APYOB1,
                                           ST_DATA(i).APYOB2,
                                           ST_DATA(i).APYOB3,
                                           ST_DATA(i).APYOB4,
                                           ST_DATA(i).APYOB5,
                                           ST_DATA(i).APYOB6,
                                           ST_DATA(i).APYOB7,
                                           ST_DATA(i).APYOB8,
                                           ST_DATA(i).APYOB9,
                                           ST_DATA(i).APYOBA,
                                           ST_DATA(i).APBOCD,
                                           ST_DATA(i).APBPCD,
                                           ST_DATA(i).APAMDT,
                                           ST_DATA(i).APAATM,
                                           ST_DATA(i).APBQCD,
                                           ST_DATA(i).APANDT,
                                           ST_DATA(i).APABTM,
                                           ST_DATA(i).APBRCD,
                                           ST_DATA(i).APB6IG,
                                           ST_DATA(i).ZPOSBDSM_R,
                                           ST_DATA(i).ZPOSBDSY_R,
                                           ST_DATA(i).ZACMCLDT,
                                           ST_DATA(i).ZPOSBDSM,
                                           ST_DATA(i).ZPOSBDSY,
                                           ST_DATA(i).APCVCDNEW,
										   ST_DATA(i).OCCDATE
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRAP00',ST_DATA(sql%bulk_exceptions(beindx).error_index).apcucd,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ST_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := DM_RE_RUN_TMP.IG_CONTROL_LOG('TMP_ZMRAP00', 'ZMRAP00', SYSTIMESTAMP,V_APP.APCUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := DM_RE_RUN_TMP.IG_CONTROL_LOG('TMP_ZMRAP00', 'ZMRAP00', SYSTIMESTAMP,V_APP.APCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := DM_RE_RUN_TMP.IG_CONTROL_LOG('TMP_ZMRAP00', 'ZMRAP00', SYSTIMESTAMP,V_APP.APCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_RERUN_ZMRAP00;
-- Procedure for RE-RUN SQL LOADER - ZMRAP00 <ENDS> Here

-- Procedure for DM_Agency_to_ig IG movement <STARTS> Here

    PROCEDURE DM_RERUN_AGENCY( p_array_size IN PLS_INTEGER DEFAULT 1000)
       IS
          TYPE AJ_ARRAY IS TABLE OF TMP_TITDMGAGENTPJ%ROWTYPE;
          AJ_DATA AJ_ARRAY;
          V_APP TMP_TITDMGAGENTPJ%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;

          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_AGENCY IS
               SELECT * FROM TMP_TITDMGAGENTPJ;


      l_OUTPUT_COUNT NUMBER:=0;
       BEGIN
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
                  l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             EXECUTE IMMEDIATE 'DELETE FROM TITDMGAGENTPJ WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGAGENTPJ DT WHERE DT.ZAREFNUM=ZAREFNUM)';
             COMMIT;



      OPEN CUR_AGENCY;
           LOOP
            FETCH CUR_AGENCY BULK COLLECT INTO AJ_DATA ;--LIMIT p_array_size;
            V_INPUT_COUNT := V_INPUT_COUNT + AJ_DATA.COUNT;

             V_ERRORMSG:=temp_tablename||'-Before Bulk Insert:';

         BEGIN
           FORALL i IN 1..AJ_DATA.COUNT SAVE EXCEPTIONS

        INSERT INTO TITDMGAGENTPJ ( ZAREFNUM,
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
                                    "COUNT",
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
                                 VALUES(
                                    AJ_DATA(i).ZAREFNUM,
                                    AJ_DATA(i).AGTYPE,
                                    AJ_DATA(i).AGNTBR,
                                    AJ_DATA(i).SRDATE,
                                    AJ_DATA(i).DATEEND,
                                    AJ_DATA(i).STCA,
                                    AJ_DATA(i).RIDESC,
                                    AJ_DATA(i).AGCLSD,
                                    AJ_DATA(i).ZREPSTNM,
                                    AJ_DATA(i).ZAGREGNO,
                                    AJ_DATA(i).CPYNAME,
                                    AJ_DATA(i).ZTRGTFLG,
                                    AJ_DATA(i)."COUNT",
                                    AJ_DATA(i).DCONSIGNEN,
                                    AJ_DATA(i).ZCONSIDT,
                                    AJ_DATA(i).ZINSTYP01,
                                    AJ_DATA(i).CMRATE01,
                                    AJ_DATA(i).ZINSTYP02,
                                    AJ_DATA(i).CMRATE02,
                                    AJ_DATA(i).ZINSTYP03,
                                    AJ_DATA(i).CMRATE03,
                                    AJ_DATA(i).ZINSTYP04,
                                    AJ_DATA(i).CMRATE04,
                                    AJ_DATA(i).ZINSTYP05,
                                    AJ_DATA(i).CMRATE05,
                                    AJ_DATA(i).ZINSTYP06,
                                    AJ_DATA(i).CMRATE06,
                                    AJ_DATA(i).ZINSTYP07,
                                    AJ_DATA(i).CMRATE07,
                                    AJ_DATA(i).ZINSTYP08,
                                    AJ_DATA(i).CMRATE08,
                                    AJ_DATA(i).ZINSTYP09,
                                    AJ_DATA(i).CMRATE09,
                                    AJ_DATA(i).ZINSTYP10,
                                    AJ_DATA(i).CMRATE10,
                                    AJ_DATA(i).CLNTNUM,
                                    AJ_DATA(i).ZDRAGNT
                                         );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + AJ_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGAGENTPJ',substr(AJ_DATA(sql%bulk_exceptions(beindx).error_index).ZAREFNUM,1,15),SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=AJ_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_AGENCY%NOTFOUND;
           END LOOP;
        CLOSE CUR_AGENCY;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_RERUN_AGENCY;

-- Procedure for DM_Agency_to_ig IG movement <ENDS> Here

-- Procedure for RE-RUN SQL LOADER - TRAN_STATUS_CODE <STARTS> Here

PROCEDURE DM_TRAN_STATUS_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TRAN_STATUS_CODE%ROWTYPE;
          ST_DATA IG_ARRAY;
          V_APP TRAN_STATUS_CODE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;

          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TRAN_STATUS_CODE_TMP IS
               SELECT * FROM TMP_TRAN_STATUS_CODE;


       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TRAN_STATUS_CODE WHERE EXISTS (SELECT 'X' FROM TMP_TRAN_STATUS_CODE DT WHERE DT.TXN_STATUS = TRAN_STATUS_CODE.TXN_STATUS);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_TRAN_STATUS_CODE_TMP;
           LOOP
            FETCH CUR_TRAN_STATUS_CODE_TMP BULK COLLECT INTO ST_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ST_DATA.COUNT;
           FORALL i IN 1..ST_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TRAN_STATUS_CODE (
                                           TXN_STATUS,
                                           DESCP)
                                 VALUES
                                           (ST_DATA(i).TXN_STATUS,
                                           ST_DATA(i).DESCP
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TRAN_STATUS_CODE',ST_DATA(sql%bulk_exceptions(beindx).error_index).TXN_STATUS,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ST_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TRAN_STATUS_CODE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TRAN_STATUS_CODE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TRAN_STATUS_CODE', 'TRAN_STATUS_CODE', SYSTIMESTAMP,V_APP.TXN_STATUS,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TRAN_STATUS_CODE', 'TRAN_STATUS_CODE', SYSTIMESTAMP,V_APP.TXN_STATUS,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TRAN_STATUS_CODE', 'TRAN_STATUS_CODE', SYSTIMESTAMP,V_APP.TXN_STATUS,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TRAN_STATUS_CODE;
-- Procedure for RE-RUN SQL LOADER - TRAN_STATUS_CODE <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - ZMRAT00 <STARTS> Here

PROCEDURE DM_ZMRAT00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRAT00%ROWTYPE;
          ZMT_DATA IG_ARRAY;
          V_APP TMP_ZMRAT00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRAT00_TMP IS
               SELECT * FROM TMP_ZMRAT00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRAT00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRAT00 DT WHERE DT.CUB8CD = ZMRAT00.CUB8CD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRAT00_TMP;
           LOOP
            FETCH CUR_ZMRAT00_TMP BULK COLLECT INTO ZMT_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMT_DATA.COUNT;
           FORALL i IN 1..ZMT_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRAT00(
                                           CUB8CD,
                                           CUUFCD,
                                           CUABCE,
                                           CUAGNTCD,
                                           CUQONB,
                                           CUUGCD,
                                           CUACPC,
                                           CUAIPC,
                                           CUULCD,
                                           CUAEPC,
                                           CUAJPC,
                                           CUUMCD,
                                           CUAFPC,
                                           CUAKPC,
                                           CUUNCD,
                                           CUAGPC,
                                           CUALPC,
                                           CUUOCD,
                                           CUAHPC,
                                           CUAMPC,
                                           CUUICD,
                                           CUUJCD,
                                           CUUKCD,
                                           CUUVIG,
                                           CUCNPC,
                                           CUCOPC,
                                           CUCPPC,
                                           CUCQPC,
                                           CUCRPC,
                                           CUCSPC,
                                           CUCTPC,
                                           CUCUPC,
                                           CUCVPC,
                                           CUCWPC,
                                           CUBOCD,
                                           CUBPCD,
                                           CUAMDT,
                                           CUAATM,
                                           CUBQCD,
                                           CUANDT,
                                           CUABTM,
                                           CUBRCD,
                                           CUB6IG)
                                 VALUES
                                           (ZMT_DATA(i).CUB8CD,
                                           ZMT_DATA(i).CUUFCD,
                                           ZMT_DATA(i).CUABCE,
                                           ZMT_DATA(i).CUAGNTCD,
                                           ZMT_DATA(i).CUQONB,
                                           ZMT_DATA(i).CUUGCD,
                                           ZMT_DATA(i).CUACPC,
                                           ZMT_DATA(i).CUAIPC,
                                           ZMT_DATA(i).CUULCD,
                                           ZMT_DATA(i).CUAEPC,
                                           ZMT_DATA(i).CUAJPC,
                                           ZMT_DATA(i).CUUMCD,
                                           ZMT_DATA(i).CUAFPC,
                                           ZMT_DATA(i).CUAKPC,
                                           ZMT_DATA(i).CUUNCD,
                                           ZMT_DATA(i).CUAGPC,
                                           ZMT_DATA(i).CUALPC,
                                           ZMT_DATA(i).CUUOCD,
                                           ZMT_DATA(i).CUAHPC,
                                           ZMT_DATA(i).CUAMPC,
                                           ZMT_DATA(i).CUUICD,
                                           ZMT_DATA(i).CUUJCD,
                                           ZMT_DATA(i).CUUKCD,
                                           ZMT_DATA(i).CUUVIG,
                                           ZMT_DATA(i).CUCNPC,
                                           ZMT_DATA(i).CUCOPC,
                                           ZMT_DATA(i).CUCPPC,
                                           ZMT_DATA(i).CUCQPC,
                                           ZMT_DATA(i).CUCRPC,
                                           ZMT_DATA(i).CUCSPC,
                                           ZMT_DATA(i).CUCTPC,
                                           ZMT_DATA(i).CUCUPC,
                                           ZMT_DATA(i).CUCVPC,
                                           ZMT_DATA(i).CUCWPC,
                                           ZMT_DATA(i).CUBOCD,
                                           ZMT_DATA(i).CUBPCD,
                                           ZMT_DATA(i).CUAMDT,
                                           ZMT_DATA(i).CUAATM,
                                           ZMT_DATA(i).CUBQCD,
                                           ZMT_DATA(i).CUANDT,
                                           ZMT_DATA(i).CUABTM,
                                           ZMT_DATA(i).CUBRCD,
                                           ZMT_DATA(i).CUB6IG
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMT_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRAT00',ZMT_DATA(sql%bulk_exceptions(beindx).error_index).CUB8CD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMT_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRAT00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRAT00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRAT00', 'TMP_ZMRAT00', SYSTIMESTAMP,V_APP.CUB8CD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRAT00', 'TMP_ZMRAT00', SYSTIMESTAMP,V_APP.CUB8CD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRAT00', 'TMP_ZMRAT00', SYSTIMESTAMP,V_APP.CUB8CD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRAT00;
-- Procedure for RE-RUN SQL LOADER - ZMRAT00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - ZMRLH00 <STARTS> Here

PROCEDURE DM_ZMRLH00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRLH00%ROWTYPE;
          ZMLH_DATA IG_ARRAY;
          V_APP TMP_ZMRLH00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRLH00_TMP IS
               SELECT * FROM TMP_ZMRLH00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRLH00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRLH00 DT WHERE DT.LHCUCD = ZMRLH00.LHCUCD or ZMRLH00.LHCUCD is null);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRLH00_TMP;
           LOOP
            FETCH CUR_ZMRLH00_TMP BULK COLLECT INTO ZMLH_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMLH_DATA.COUNT;
           FORALL i IN 1..ZMLH_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRLH00(
                                           LHCUCD,
                                           LHCQCD,
                                           LHCRCD,
                                           LHAUDT,
                                           LHAVDT,
                                           LHA6ST,
                                           LHAWDT,
                                           LHBOCD,
                                           LHBPCD,
                                           LHAMDT,
                                           LHAATM,
                                           LHBQCD,
                                           LHANDT,
                                           LHABTM,
                                           LHBRCD,
                                           LHB6IG
                                          )
                                 VALUES
                                          (ZMLH_DATA(i).LHCUCD,
                                           ZMLH_DATA(i).LHCQCD,
                                           ZMLH_DATA(i).LHCRCD,
                                           ZMLH_DATA(i).LHAUDT,
                                           ZMLH_DATA(i).LHAVDT,
                                           ZMLH_DATA(i).LHA6ST,
                                           ZMLH_DATA(i).LHAWDT,
                                           ZMLH_DATA(i).LHBOCD,
                                           ZMLH_DATA(i).LHBPCD,
                                           ZMLH_DATA(i).LHAMDT,
                                           ZMLH_DATA(i).LHAATM,
                                           ZMLH_DATA(i).LHBQCD,
                                           ZMLH_DATA(i).LHANDT,
                                           ZMLH_DATA(i).LHABTM,
                                           ZMLH_DATA(i).LHBRCD,
                                           ZMLH_DATA(i).LHB6IG
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMLH_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRLH00',ZMLH_DATA(sql%bulk_exceptions(beindx).error_index).LHCUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMLH_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRLH00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRLH00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRLH00', 'TMP_ZMRLH00', SYSTIMESTAMP,V_APP.LHCUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRLH00', 'TMP_ZMRLH00', SYSTIMESTAMP,V_APP.LHCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRLH00', 'TMP_ZMRLH00', SYSTIMESTAMP,V_APP.LHCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRLH00;
-- Procedure for RE-RUN SQL LOADER - ZMRLH00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - SPLN <STARTS> Here

PROCEDURE DM_SPLN(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_SPLN%ROWTYPE;
          SPLN_DATA IG_ARRAY;
          V_APP TMP_SPLN%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_SPLN_TMP IS
               SELECT * FROM TMP_SPLN;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
                  l_OUTPUT_COUNT:=0;

         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM SPLN WHERE EXISTS (SELECT 'X' FROM TMP_SPLN DT WHERE DT.SRCD = SPLN.SRCD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_SPLN_TMP;
           LOOP
            FETCH CUR_SPLN_TMP BULK COLLECT INTO SPLN_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + SPLN_DATA.COUNT;
           FORALL i IN 1..SPLN_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO SPLN(
                                           CURRFROM,
                                           CURRTO,
                                           SALPLN,
                                           SRCD,
                                           ZSUMINS,
                                           DURPOL,
                                           AGE,
                                           SEX,
                                           MNPREM,
                                           ANPREM,
                                           LMPPREM,
                                           RSKPREM01,
                                           RSKPREM02,
                                           RSKPREM03,
                                           RSKPREM04,
                                           RSKPREM05,
                                           RSKPREM06,
                                           RSKPREM07,
                                           RSKPREM08,
                                           RSKPREM09,
                                           RSKPREM10,
                                           POLRESV01,
                                           POLRESV02,
                                           POLRESV03,
                                           POLRESV04,
                                           POLRESV05,
                                           POLRESV06,
                                           POLRESV07,
                                           POLRESV08,
                                           POLRESV09,
                                           POLRESV10
                                          )
                                 VALUES
                                          (SPLN_DATA(i).CURRFROM,
                                           SPLN_DATA(i).CURRTO,
                                           SPLN_DATA(i).SALPLN,
                                           SPLN_DATA(i).SRCD,
                                           SPLN_DATA(i).ZSUMINS,
                                           SPLN_DATA(i).DURPOL,
                                           SPLN_DATA(i).AGE,
                                           SPLN_DATA(i).SEX,
                                           SPLN_DATA(i).MNPREM,
                                           SPLN_DATA(i).ANPREM,
                                           SPLN_DATA(i).LMPPREM,
                                           SPLN_DATA(i).RSKPREM01,
                                           SPLN_DATA(i).RSKPREM02,
                                           SPLN_DATA(i).RSKPREM03,
                                           SPLN_DATA(i).RSKPREM04,
                                           SPLN_DATA(i).RSKPREM05,
                                           SPLN_DATA(i).RSKPREM06,
                                           SPLN_DATA(i).RSKPREM07,
                                           SPLN_DATA(i).RSKPREM08,
                                           SPLN_DATA(i).RSKPREM09,
                                           SPLN_DATA(i).RSKPREM10,
                                           SPLN_DATA(i).POLRESV01,
                                           SPLN_DATA(i).POLRESV02,
                                           SPLN_DATA(i).POLRESV03,
                                           SPLN_DATA(i).POLRESV04,
                                           SPLN_DATA(i).POLRESV05,
                                           SPLN_DATA(i).POLRESV06,
                                           SPLN_DATA(i).POLRESV07,
                                           SPLN_DATA(i).POLRESV08,
                                           SPLN_DATA(i).POLRESV09,
                                           SPLN_DATA(i).POLRESV10
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + SPLN_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_SPLN',SPLN_DATA(sql%bulk_exceptions(beindx).error_index).SRCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=SPLN_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_SPLN_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_SPLN_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_SPLN', 'TMP_SPLN', SYSTIMESTAMP,V_APP.SRCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_SPLN', 'TMP_SPLN', SYSTIMESTAMP,V_APP.SRCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_SPLN', 'TMP_SPLN', SYSTIMESTAMP,V_APP.SRCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_SPLN;
-- Procedure for RE-RUN SQL LOADER - SPLN <ENDS> Here

-- Procedure for RE-RUN SQL LOADER - ZMRIC00 <STARTS> Here

PROCEDURE DM_ZMRIC00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRIC00%ROWTYPE;
          ZMRIC_DATA IG_ARRAY;
          V_APP TMP_ZMRIC00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRIC00_TMP IS
               SELECT * FROM TMP_ZMRIC00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRIC00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRIC00 DT WHERE DT.ICCUCD = ZMRIC00.ICCUCD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRIC00_TMP;
           LOOP
            FETCH CUR_ZMRIC00_TMP BULK COLLECT INTO ZMRIC_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRIC_DATA.COUNT;
           FORALL i IN 1..ZMRIC_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRIC00(
                                           ICCUCD,
                                           ICCICD,
                                           ICJGCD,
                                           ICBMST,
                                           ICDMCD,
                                           ICC4IG,
                                           ICB0VA,
                                           ICB3VA,
                                           ICB4VA,
                                           ICB5VA,
                                           ICB6VA,
                                           ICB7VA,
                                           ICAKQT,
                                           ICCGST,
                                           ICDNCD,
                                           ICBOCD,
                                           ICBPCD,
                                           ICAMDT,
                                           ICAATM,
                                           ICBQCD,
                                           ICANDT,
                                           ICABTM,
                                           ICBRCD,
                                           ICB6IG
                                          )
                                 VALUES
                                          (
                                           ZMRIC_DATA(i).ICCUCD,
                                           ZMRIC_DATA(i).ICCICD,
                                           ZMRIC_DATA(i).ICJGCD,
                                           ZMRIC_DATA(i).ICBMST,
                                           ZMRIC_DATA(i).ICDMCD,
                                           ZMRIC_DATA(i).ICC4IG,
                                           ZMRIC_DATA(i).ICB0VA,
                                           ZMRIC_DATA(i).ICB3VA,
                                           ZMRIC_DATA(i).ICB4VA,
                                           ZMRIC_DATA(i).ICB5VA,
                                           ZMRIC_DATA(i).ICB6VA,
                                           ZMRIC_DATA(i).ICB7VA,
                                           ZMRIC_DATA(i).ICAKQT,
                                           ZMRIC_DATA(i).ICCGST,
                                           ZMRIC_DATA(i).ICDNCD,
                                           ZMRIC_DATA(i).ICBOCD,
                                           ZMRIC_DATA(i).ICBPCD,
                                           ZMRIC_DATA(i).ICAMDT,
                                           ZMRIC_DATA(i).ICAATM,
                                           ZMRIC_DATA(i).ICBQCD,
                                           ZMRIC_DATA(i).ICANDT,
                                           ZMRIC_DATA(i).ICABTM,
                                           ZMRIC_DATA(i).ICBRCD,
                                           ZMRIC_DATA(i).ICB6IG
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRIC_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRIC00',ZMRIC_DATA(sql%bulk_exceptions(beindx).error_index).ICCUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRIC_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRIC00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRIC00_TMP;


V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRIC00', 'TMP_ZMRIC00', SYSTIMESTAMP,V_APP.ICCUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRIC00', 'TMP_ZMRIC00', SYSTIMESTAMP,V_APP.ICCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRIC00', 'TMP_ZMRIC00', SYSTIMESTAMP,V_APP.ICCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRIC00;
-- Procedure for RE-RUN SQL LOADER - ZMRIC00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - ZMRIS00 <STARTS> Here

PROCEDURE DM_ZMRIS00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRIS00%ROWTYPE;
          ZMRIS_DATA IG_ARRAY;
          V_APP TMP_ZMRIS00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRIS00_TMP IS
               SELECT * FROM TMP_ZMRIS00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRIS00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRIS00 DT WHERE DT.ISCUCD = ZMRIS00.ISCUCD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRIS00_TMP;
           LOOP
            FETCH CUR_ZMRIS00_TMP BULK COLLECT INTO ZMRIS_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRIS_DATA.COUNT;
           FORALL i IN 1..ZMRIS_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRIS00(
                                           ISCUCD,
                                           ISCICD,
                                           ISCJCD,
                                           ISCMCD,
                                           ISCNCD,
                                           ISCOCD,
                                           ISBTIG,
                                           ISBUIG,
                                           ISBVIG,
                                           ISBWIG,
                                           ISATDT,
                                           ISB0NB,
                                           ISA3ST,
                                           ISA4ST,
                                           ISBXIG,
                                           ISBYIG,
                                           ISBZIG,
                                           ISB0IG,
                                           ISBYTX,
                                           ISBZTX,
                                           ISA5ST,
                                           ISB1IG,
                                           ISCPCD,
                                           ISCVVA,
                                           ISCFST,
                                           ISGJCD,
                                           ISBOCD,
                                           ISBPCD,
                                           ISAMDT,
                                           ISAATM,
                                           ISBQCD,
                                           ISANDT,
                                           ISABTM,
                                           ISBRCD,
                                           ISB6IG,
                                           B1_ZKNJFULNM,
                                           B1_CLTADDR01,
                                           B1_BNYPC,
                                           B1_BNYRLN,
                                           B2_ZKNJFULNM,
                                           B2_CLTADDR01,
                                           B2_BNYPC,
                                           B2_BNYRLN,
                                           B3_ZKNJFULNM,
                                           B3_CLTADDR01,
                                           B3_BNYPC,
                                           B3_BNYRLN,
                                           B4_ZKNJFULNM,
                                           B4_CLTADDR01,
                                           B4_BNYPC,
                                           B4_BNYRLN,
                                           B5_ZKNJFULNM,
                                           B5_CLTADDR01,
                                           B5_BNYPC,
                                           B5_BNYRLN
                                          )
                                 VALUES
                                          (
                                           ZMRIS_DATA(i).ISCUCD,
                                           ZMRIS_DATA(i).ISCICD,
                                           ZMRIS_DATA(i).ISCJCD,
                                           ZMRIS_DATA(i).ISCMCD,
                                           ZMRIS_DATA(i).ISCNCD,
                                           ZMRIS_DATA(i).ISCOCD,
                                           ZMRIS_DATA(i).ISBTIG,
                                           ZMRIS_DATA(i).ISBUIG,
                                           ZMRIS_DATA(i).ISBVIG,
                                           ZMRIS_DATA(i).ISBWIG,
                                           ZMRIS_DATA(i).ISATDT,
                                           ZMRIS_DATA(i).ISB0NB,
                                           ZMRIS_DATA(i).ISA3ST,
                                           ZMRIS_DATA(i).ISA4ST,
                                           ZMRIS_DATA(i).ISBXIG,
                                           ZMRIS_DATA(i).ISBYIG,
                                           ZMRIS_DATA(i).ISBZIG,
                                           ZMRIS_DATA(i).ISB0IG,
                                           ZMRIS_DATA(i).ISBYTX,
                                           ZMRIS_DATA(i).ISBZTX,
                                           ZMRIS_DATA(i).ISA5ST,
                                           ZMRIS_DATA(i).ISB1IG,
                                           ZMRIS_DATA(i).ISCPCD,
                                           ZMRIS_DATA(i).ISCVVA,
                                           ZMRIS_DATA(i).ISCFST,
                                           ZMRIS_DATA(i).ISGJCD,
                                           ZMRIS_DATA(i).ISBOCD,
                                           ZMRIS_DATA(i).ISBPCD,
                                           ZMRIS_DATA(i).ISAMDT,
                                           ZMRIS_DATA(i).ISAATM,
                                           ZMRIS_DATA(i).ISBQCD,
                                           ZMRIS_DATA(i).ISANDT,
                                           ZMRIS_DATA(i).ISABTM,
                                           ZMRIS_DATA(i).ISBRCD,
                                           ZMRIS_DATA(i).ISB6IG,
                                           ZMRIS_DATA(i).B1_ZKNJFULNM,
                                           ZMRIS_DATA(i).B1_CLTADDR01,
                                           ZMRIS_DATA(i).B1_BNYPC,
                                           ZMRIS_DATA(i).B1_BNYRLN,
                                           ZMRIS_DATA(i).B2_ZKNJFULNM,
                                           ZMRIS_DATA(i).B2_CLTADDR01,
                                           ZMRIS_DATA(i).B2_BNYPC,
                                           ZMRIS_DATA(i).B2_BNYRLN,
                                           ZMRIS_DATA(i).B3_ZKNJFULNM,
                                           ZMRIS_DATA(i).B3_CLTADDR01,
                                           ZMRIS_DATA(i).B3_BNYPC,
                                           ZMRIS_DATA(i).B3_BNYRLN,
                                           ZMRIS_DATA(i).B4_ZKNJFULNM,
                                           ZMRIS_DATA(i).B4_CLTADDR01,
                                           ZMRIS_DATA(i).B4_BNYPC,
                                           ZMRIS_DATA(i).B4_BNYRLN,
                                           ZMRIS_DATA(i).B5_ZKNJFULNM,
                                           ZMRIS_DATA(i).B5_CLTADDR01,
                                           ZMRIS_DATA(i).B5_BNYPC,
                                           ZMRIS_DATA(i).B5_BNYRLN
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRIS_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRIS00',ZMRIS_DATA(sql%bulk_exceptions(beindx).error_index).ISCUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRIS_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRIS00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRIS00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRIS00', 'TMP_ZMRIS00', SYSTIMESTAMP,V_APP.ISCUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRIS00', 'TMP_ZMRIS00', SYSTIMESTAMP,V_APP.ISCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRIS00', 'TMP_ZMRIS00', SYSTIMESTAMP,V_APP.ISCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRIS00;
-- Procedure for RE-RUN SQL LOADER - ZMRIS00 <ENDS> Here

-- Procedure for RE-RUN SQL LOADER - ZMRFCT00 <STARTS> Here

PROCEDURE DM_ZMRFCT00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRFCT00%ROWTYPE;
          ZMRFCT_DATA IG_ARRAY;
          V_APP TMP_ZMRFCT00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRFCT00_TMP IS
               SELECT * FROM TMP_ZMRFCT00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRFCT00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRFCT00 DT WHERE DT.FCTCUCD = ZMRFCT00.FCTCUCD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRFCT00_TMP;
           LOOP
            FETCH CUR_ZMRFCT00_TMP BULK COLLECT INTO ZMRFCT_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRFCT_DATA.COUNT;
           FORALL i IN 1..ZMRFCT_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRFCT00(
                                           FCTCUCD,
                                           FCTKBCD,
                                           FCTNDTE,
                                           FCTNTE1,
                                           FCTNTE2,
                                           FCTNTE3,
                                           FCTNTE4,
                                           FCTNTE5,
                                           FCTSTDT,
                                           FCTYOB1,
                                           FCTYOB2,
                                           FCTYOB3,
                                           FCTYOB4,
                                           FCTYOB5,
                                           FCTYOB6,
                                           FCTYOB7,
                                           FCTYOB8,
                                           FCTBOCD,
                                           FCTBPCD,
                                           FCTAMDT,
                                           FCTAATM,
                                           FCTBQCD,
                                           FCTANDT,
                                           FCTABTM,
                                           FCTBRCD,
                                           FCTB6IG
                                          )
                                 VALUES
                                          (
                                           ZMRFCT_DATA(i).FCTCUCD,
                                           ZMRFCT_DATA(i).FCTKBCD,
                                           ZMRFCT_DATA(i).FCTNDTE,
                                           ZMRFCT_DATA(i).FCTNTE1,
                                           ZMRFCT_DATA(i).FCTNTE2,
                                           ZMRFCT_DATA(i).FCTNTE3,
                                           ZMRFCT_DATA(i).FCTNTE4,
                                           ZMRFCT_DATA(i).FCTNTE5,
                                           ZMRFCT_DATA(i).FCTSTDT,
                                           ZMRFCT_DATA(i).FCTYOB1,
                                           ZMRFCT_DATA(i).FCTYOB2,
                                           ZMRFCT_DATA(i).FCTYOB3,
                                           ZMRFCT_DATA(i).FCTYOB4,
                                           ZMRFCT_DATA(i).FCTYOB5,
                                           ZMRFCT_DATA(i).FCTYOB6,
                                           ZMRFCT_DATA(i).FCTYOB7,
                                           ZMRFCT_DATA(i).FCTYOB8,
                                           ZMRFCT_DATA(i).FCTBOCD,
                                           ZMRFCT_DATA(i).FCTBPCD,
                                           ZMRFCT_DATA(i).FCTAMDT,
                                           ZMRFCT_DATA(i).FCTAATM,
                                           ZMRFCT_DATA(i).FCTBQCD,
                                           ZMRFCT_DATA(i).FCTANDT,
                                           ZMRFCT_DATA(i).FCTABTM,
                                           ZMRFCT_DATA(i).FCTBRCD,
                                           ZMRFCT_DATA(i).FCTB6IG
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRFCT_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRFCT00',ZMRFCT_DATA(sql%bulk_exceptions(beindx).error_index).FCTCUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRFCT_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRFCT00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRFCT00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRFCT00', 'TMP_ZMRFCT00', SYSTIMESTAMP,V_APP.FCTCUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRFCT00', 'TMP_ZMRFCT00', SYSTIMESTAMP,V_APP.FCTCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRFCT00', 'TMP_ZMRFCT00', SYSTIMESTAMP,V_APP.FCTCUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRFCT00;
-- Procedure for RE-RUN SQL LOADER - ZMRFCT00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - ZMRRS00 <STARTS> Here

PROCEDURE DM_ZMRRS00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRRS00%ROWTYPE;
          ZMRRS_DATA IG_ARRAY;
          V_APP TMP_ZMRRS00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRRS00_TMP IS
               SELECT * FROM TMP_ZMRRS00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRRS00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRRS00 DT WHERE DT.RSBTCD = ZMRRS00.RSBTCD);
         -- Delete the records for all the records exists in ZMRRS00 for Delta Load

           OPEN CUR_ZMRRS00_TMP;
           LOOP
            FETCH CUR_ZMRRS00_TMP BULK COLLECT INTO ZMRRS_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRRS_DATA.COUNT;
           FORALL i IN 1..ZMRRS_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRRS00(
                                           RSBTCD,
                                           RSBUCD,
                                           RSFOCD,
                                           RSBVCD,
                                           RSANST,
                                           RSGACD,
                                           RSADQT,
                                           RSAEQT,
                                           RSAOST,
                                           RSAPST,
                                           RSAQST,
                                           RSARST,
                                           RSASST,
                                           RSATST,
                                           RSAUST,
                                           RSAVST,
                                           RSAWST,
                                           RSAXST,
                                           RSAYST,
                                           RSAZST,
                                           RSB0CD,
                                           RSB1CD,
                                           RSB2CD,
                                           RSB3CD,
                                           RSB4CD,
                                           RSB5CD,
                                           RSNVST,
                                           RSNWST,
                                           RSNXST,
                                           RSNYST,
                                           RSJNCE,
                                           RSJOCE,
                                           RSJPCE,
                                           RSJQCE,
                                           RSJRCE,
                                           RSJSCE,
                                           RSNZST,
                                           RSN0ST,
                                           RSJTCE,
                                           RSJUCE,
                                           RSBOCD,
                                           RSBPCD,
                                           RSAMDT,
                                           RSAATM,
                                           RSBQCD,
                                           RSANDT,
                                           RSABTM,
                                           RSBRCD,
                                           RSB6IG
                                          )
                                 VALUES
                                          (
                                           ZMRRS_DATA(i).RSBTCD,
                                           ZMRRS_DATA(i).RSBUCD,
                                           ZMRRS_DATA(i).RSFOCD,
                                           ZMRRS_DATA(i).RSBVCD,
                                           ZMRRS_DATA(i).RSANST,
                                           ZMRRS_DATA(i).RSGACD,
                                           ZMRRS_DATA(i).RSADQT,
                                           ZMRRS_DATA(i).RSAEQT,
                                           ZMRRS_DATA(i).RSAOST,
                                           ZMRRS_DATA(i).RSAPST,
                                           ZMRRS_DATA(i).RSAQST,
                                           ZMRRS_DATA(i).RSARST,
                                           ZMRRS_DATA(i).RSASST,
                                           ZMRRS_DATA(i).RSATST,
                                           ZMRRS_DATA(i).RSAUST,
                                           ZMRRS_DATA(i).RSAVST,
                                           ZMRRS_DATA(i).RSAWST,
                                           ZMRRS_DATA(i).RSAXST,
                                           ZMRRS_DATA(i).RSAYST,
                                           ZMRRS_DATA(i).RSAZST,
                                           ZMRRS_DATA(i).RSB0CD,
                                           ZMRRS_DATA(i).RSB1CD,
                                           ZMRRS_DATA(i).RSB2CD,
                                           ZMRRS_DATA(i).RSB3CD,
                                           ZMRRS_DATA(i).RSB4CD,
                                           ZMRRS_DATA(i).RSB5CD,
                                           ZMRRS_DATA(i).RSNVST,
                                           ZMRRS_DATA(i).RSNWST,
                                           ZMRRS_DATA(i).RSNXST,
                                           ZMRRS_DATA(i).RSNYST,
                                           ZMRRS_DATA(i).RSJNCE,
                                           ZMRRS_DATA(i).RSJOCE,
                                           ZMRRS_DATA(i).RSJPCE,
                                           ZMRRS_DATA(i).RSJQCE,
                                           ZMRRS_DATA(i).RSJRCE,
                                           ZMRRS_DATA(i).RSJSCE,
                                           ZMRRS_DATA(i).RSNZST,
                                           ZMRRS_DATA(i).RSN0ST,
                                           ZMRRS_DATA(i).RSJTCE,
                                           ZMRRS_DATA(i).RSJUCE,
                                           ZMRRS_DATA(i).RSBOCD,
                                           ZMRRS_DATA(i).RSBPCD,
                                           ZMRRS_DATA(i).RSAMDT,
                                           ZMRRS_DATA(i).RSAATM,
                                           ZMRRS_DATA(i).RSBQCD,
                                           ZMRRS_DATA(i).RSANDT,
                                           ZMRRS_DATA(i).RSABTM,
                                           ZMRRS_DATA(i).RSBRCD,
                                           ZMRRS_DATA(i).RSB6IG
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRRS_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRRS00',ZMRRS_DATA(sql%bulk_exceptions(beindx).error_index).RSBTCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRRS_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRRS00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRRS00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRRS00', 'TMP_ZMRRS00', SYSTIMESTAMP,V_APP.RSBTCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRRS00', 'TMP_ZMRRS00', SYSTIMESTAMP,V_APP.RSBTCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRRS00', 'TMP_ZMRRS00', SYSTIMESTAMP,V_APP.RSBTCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRRS00;
-- Procedure for RE-RUN SQL LOADER - ZMRRS00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - ZMREI00 <STARTS> Here

PROCEDURE DM_ZMREI00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMREI00%ROWTYPE;
          ZMREI_DATA IG_ARRAY;
          V_APP TMP_ZMREI00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMREI00_TMP IS
               SELECT * FROM TMP_ZMREI00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMREI00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMREI00 DT WHERE DT.EICUCD = ZMREI00.EICUCD);
         -- Delete the records for all the records exists in ZMREI00 for Delta Load

           OPEN CUR_ZMREI00_TMP;
           LOOP
            FETCH CUR_ZMREI00_TMP BULK COLLECT INTO ZMREI_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMREI_DATA.COUNT;
           FORALL i IN 1..ZMREI_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMREI00(
                                           EICUCD,
                                           EIPLNO,
                                           EIA2DT,
                                           EIBEDT,
                                           EICTID,
                                           EIYOB1,
                                           EIYOB2,
                                           EIYOB3,
                                           EIYOB4,
                                           EIYOB5,
                                           EIYOB6,
                                           EIYOB7,
                                           EIYOB8,
                                           EIYOB9,
                                           EIYOBA,
                                           EIBOCD,
                                           EIBPCD,
                                           EIAMDT,
                                           EIAATM,
                                           EIBQCD,
                                           EIANDT,
                                           EIABTM,
                                           EIBRCD,
                                           EIB6IG
                                          )
                                 VALUES
                                          (
                                           ZMREI_DATA(i).EICUCD,
                                           ZMREI_DATA(i).EIPLNO,
                                           ZMREI_DATA(i).EIA2DT,
                                           ZMREI_DATA(i).EIBEDT,
                                           ZMREI_DATA(i).EICTID,
                                           ZMREI_DATA(i).EIYOB1,
                                           ZMREI_DATA(i).EIYOB2,
                                           ZMREI_DATA(i).EIYOB3,
                                           ZMREI_DATA(i).EIYOB4,
                                           ZMREI_DATA(i).EIYOB5,
                                           ZMREI_DATA(i).EIYOB6,
                                           ZMREI_DATA(i).EIYOB7,
                                           ZMREI_DATA(i).EIYOB8,
                                           ZMREI_DATA(i).EIYOB9,
                                           ZMREI_DATA(i).EIYOBA,
                                           ZMREI_DATA(i).EIBOCD,
                                           ZMREI_DATA(i).EIBPCD,
                                           ZMREI_DATA(i).EIAMDT,
                                           ZMREI_DATA(i).EIAATM,
                                           ZMREI_DATA(i).EIBQCD,
                                           ZMREI_DATA(i).EIANDT,
                                           ZMREI_DATA(i).EIABTM,
                                           ZMREI_DATA(i).EIBRCD,
                                           ZMREI_DATA(i).EIB6IG
                                            );

        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMREI_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMREI00',ZMREI_DATA(sql%bulk_exceptions(beindx).error_index).EICUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMREI_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMREI00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMREI00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMREI00', 'TMP_ZMREI00', SYSTIMESTAMP,V_APP.EICUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMREI00', 'TMP_ZMREI00', SYSTIMESTAMP,V_APP.EICUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMREI00', 'TMP_ZMREI00', SYSTIMESTAMP,V_APP.EICUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMREI00;
-- Procedure for RE-RUN SQL LOADER - ZMREI00 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - TITDMGAGENTPJ <STARTS> Here

PROCEDURE DM_TITDMGAGENTPJ(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGAGENTPJ%ROWTYPE;
          AG_DATA IG_ARRAY;
          V_APP TMP_TITDMGAGENTPJ%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGAGENTPJ_TMP IS
               SELECT * FROM TMP_TITDMGAGENTPJ;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGAGENTPJ WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGAGENTPJ DT WHERE DT.ZAREFNUM = TITDMGAGENTPJ.ZAREFNUM);
         -- Delete the records for all the records exists in ZMREI00 for Delta Load

           OPEN CUR_TITDMGAGENTPJ_TMP;
           LOOP
            FETCH CUR_TITDMGAGENTPJ_TMP BULK COLLECT INTO AG_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + AG_DATA.COUNT;
           FORALL i IN 1..AG_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGAGENTPJ(
                                           ZAREFNUM,
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
                                           ZDRAGNT
                                          )
                                 VALUES
                                          (
                                           AG_DATA(i).ZAREFNUM,
                                           AG_DATA(i).AGTYPE,
                                           AG_DATA(i).AGNTBR,
                                           AG_DATA(i).SRDATE,
                                           AG_DATA(i).DATEEND,
                                           AG_DATA(i).STCA,
                                           AG_DATA(i).RIDESC,
                                           AG_DATA(i).AGCLSD,
                                           AG_DATA(i).ZREPSTNM,
                                           AG_DATA(i).ZAGREGNO,
                                           AG_DATA(i).CPYNAME,
                                           AG_DATA(i).ZTRGTFLG,
                                           AG_DATA(i).COUNT,
                                           AG_DATA(i).DCONSIGNEN,
                                           AG_DATA(i).ZCONSIDT,
                                           AG_DATA(i).ZINSTYP01,
                                           AG_DATA(i).CMRATE01,
                                           AG_DATA(i).ZINSTYP02,
                                           AG_DATA(i).CMRATE02,
                                           AG_DATA(i).ZINSTYP03,
                                           AG_DATA(i).CMRATE03,
                                           AG_DATA(i).ZINSTYP04,
                                           AG_DATA(i).CMRATE04,
                                           AG_DATA(i).ZINSTYP05,
                                           AG_DATA(i).CMRATE05,
                                           AG_DATA(i).ZINSTYP06,
                                           AG_DATA(i).CMRATE06,
                                           AG_DATA(i).ZINSTYP07,
                                           AG_DATA(i).CMRATE07,
                                           AG_DATA(i).ZINSTYP08,
                                           AG_DATA(i).CMRATE08,
                                           AG_DATA(i).ZINSTYP09,
                                           AG_DATA(i).CMRATE09,
                                           AG_DATA(i).ZINSTYP10,
                                           AG_DATA(i).CMRATE10,
                                           AG_DATA(i).CLNTNUM,
                                           AG_DATA(i).ZDRAGNT
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + AG_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGAGENTPJ',AG_DATA(sql%bulk_exceptions(beindx).error_index).ZAREFNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=AG_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGAGENTPJ_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGAGENTPJ_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TMP_TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TMP_TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGAGENTPJ', 'TMP_TITDMGAGENTPJ', SYSTIMESTAMP,V_APP.ZAREFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGAGENTPJ;
-- Procedure for RE-RUN SQL LOADER - TITDMGAGENTPJ <ENDS> Here

-- Procedure for RE-RUN SQL LOADER - COL_FEE_LST <STARTS> Here

PROCEDURE DM_COL_FEE_LST(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_COL_FEE_LST%ROWTYPE;
          CF_DATA IG_ARRAY;
          V_APP COL_FEE_LST%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_COL_FEE_LST_TMP IS
               SELECT * FROM TMP_COL_FEE_LST;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM COL_FEE_LST WHERE EXISTS (SELECT 'X' FROM TMP_COL_FEE_LST DT WHERE DT.PRODUCTCODE = COL_FEE_LST.PRODUCTCODE and DT.ENDORSERCODE=COL_FEE_LST.ENDORSERCODE);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_COL_FEE_LST_TMP;
           LOOP
            FETCH CUR_COL_FEE_LST_TMP BULK COLLECT INTO CF_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + CF_DATA.COUNT;
           FORALL i IN 1..CF_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO COL_FEE_LST(
                                           PRODUCTCODE,
                                           ENDORSERCODE,
                                           FEERATE)
                                 VALUES
                                           (
                                           CF_DATA(i).PRODUCTCODE,
                                           CF_DATA(i).ENDORSERCODE,
                                           CF_DATA(i).FEERATE
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + CF_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('COL_FEE_LST',CF_DATA(sql%bulk_exceptions(beindx).error_index).PRODUCTCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=CF_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_COL_FEE_LST_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_COL_FEE_LST_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_COL_FEE_LST', 'COL_FEE_LST', SYSTIMESTAMP,V_APP.PRODUCTCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_COL_FEE_LST', 'COL_FEE_LST', SYSTIMESTAMP,V_APP.PRODUCTCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_COL_FEE_LST', 'COL_FEE_LST', SYSTIMESTAMP,V_APP.PRODUCTCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_COL_FEE_LST;
-- Procedure for RE-RUN SQL LOADER - COL_FEE_LST <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - LETTER_CODE <STARTS> Here

PROCEDURE DM_LETTER_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_LETTER_CODE%ROWTYPE;
          LC_DATA IG_ARRAY;
          V_APP LETTER_CODE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_LETTER_CODE_TMP IS
               SELECT * FROM TMP_LETTER_CODE;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM LETTER_CODE WHERE EXISTS (SELECT 'X' FROM TMP_LETTER_CODE DT WHERE DT.DMCODE = LETTER_CODE.DMCODE );
         -- Delete the records for all the records exists in LETTER_CODE for Delta Load

           OPEN CUR_LETTER_CODE_TMP;
           LOOP
            FETCH CUR_LETTER_CODE_TMP BULK COLLECT INTO LC_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + LC_DATA.COUNT;
           FORALL i IN 1..LC_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO LETTER_CODE(
                                           DMCODE,
                                           IGCODE)
                                 VALUES
                                           (
                                          LC_DATA(i).DMCODE,
                                           LC_DATA(i).IGCODE
                                            );

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + LC_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('LETTER_CODE',LC_DATA(sql%bulk_exceptions(beindx).error_index).DMCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=LC_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_LETTER_CODE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_LETTER_CODE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_LETTER_CODE', 'LETTER_CODE', SYSTIMESTAMP,V_APP.DMCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_LETTER_CODE', 'LETTER_CODE', SYSTIMESTAMP,V_APP.DMCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_LETTER_CODE', 'LETTER_CODE', SYSTIMESTAMP,V_APP.DMCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_LETTER_CODE;
-- Procedure for RE-RUN SQL LOADER - LETTER_CODE <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - GRP_POLICY_FREE <STARTS> Here

PROCEDURE DM_GRP_POLICY_FREE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_GRP_POLICY_FREE%ROWTYPE;
          GPF_DATA IG_ARRAY;
          V_APP GRP_POLICY_FREE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_GRP_POLICY_FREE_TMP IS
               SELECT * FROM TMP_GRP_POLICY_FREE;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM GRP_POLICY_FREE WHERE EXISTS (SELECT 'X' FROM TMP_GRP_POLICY_FREE DT WHERE DT.ENDORSERCODE = GRP_POLICY_FREE.ENDORSERCODE and DT.CAMPAIGN = GRP_POLICY_FREE.CAMPAIGN);
         -- Delete the records for all the records exists in GRP_POLICY_FREE for Delta Load

           OPEN CUR_GRP_POLICY_FREE_TMP;
           LOOP
            FETCH CUR_GRP_POLICY_FREE_TMP BULK COLLECT INTO GPF_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + GPF_DATA.COUNT;
           FORALL i IN 1..GPF_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO GRP_POLICY_FREE(
                                           ENDORSERCODE,
                                           PRODUCTCODE,
                                           GRP_POLICY_NO_DM,
                                           GRP_POLICY_NO_PJ,
                                           COMMENCEMENTDATE,
                                           TERMINATEDATE,
                                           PERIODS,
                                           CAMPAIGN,
                                           INSUREDTYPE)
                                 VALUES
                                           (
                                           GPF_DATA(i).ENDORSERCODE,
                                           GPF_DATA(i).PRODUCTCODE,
                                           GPF_DATA(i).GRP_POLICY_NO_DM,
                                           GPF_DATA(i).GRP_POLICY_NO_PJ,
                                           GPF_DATA(i).COMMENCEMENTDATE,
                                           GPF_DATA(i).TERMINATEDATE,
                                           GPF_DATA(i).PERIODS,
                                           GPF_DATA(i).CAMPAIGN,
                                           GPF_DATA(i).INSUREDTYPE
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + GPF_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('GRP_POLICY_FREE',GPF_DATA(sql%bulk_exceptions(beindx).error_index).ENDORSERCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=GPF_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_GRP_POLICY_FREE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_GRP_POLICY_FREE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_GRP_POLICY_FREE', 'GRP_POLICY_FREE', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_GRP_POLICY_FREE', 'GRP_POLICY_FREE', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_GRP_POLICY_FREE', 'GRP_POLICY_FREE', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_GRP_POLICY_FREE;
-- Procedure for RE-RUN SQL LOADER - GRP_POLICY_FREE  <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - DMPR <STARTS> Here

PROCEDURE DM_DMPR(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_DMPR%ROWTYPE;
          DMPR_DATA IG_ARRAY;
          V_APP DMPR%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_DMPR_TMP IS
               SELECT * FROM TMP_DMPR;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM DMPR WHERE EXISTS (SELECT 'X' FROM TMP_DMPR DT WHERE DT.CHDRNUM = DMPR.CHDRNUM );
         -- Delete the records for all the records exists in DMPR for Delta Load

           OPEN CUR_DMPR_TMP;
           LOOP
            FETCH CUR_DMPR_TMP BULK COLLECT INTO DMPR_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + DMPR_DATA.COUNT;
           FORALL i IN 1..DMPR_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO DMPR(
                                                                                      ACCTYEAR,
                                           ACCTMONTH,
                                           PROCCODE,
                                           PAYDATE,
                                           CNTBRANCH,
                                           FACTHOUS,
                                           ENDSERCD,
                                           CNTTYPE,
                                           CHDRPFX,
                                           CHDRCOY,
                                           CHDRNUM,
                                           CURRFROM,
                                           TRANNO,
                                           CLNTPFX,
                                           CLNTCOY,
                                           CLNTNUM,
                                           PAYAMT,
                                           TRANDATE,
                                           BANKKEY,
                                           BANKACCKEY,
                                           BANKACCDSC,
                                           BBKACTYP,
                                           CCDATE,
                                           CRDATE,
                                           CHEQPFX,
                                           CHEQCOY,
                                           CHEQBCDE,
                                           CHEQNO,
                                           CHEQDUPN,
                                           USERP,
                                           ERRORCODE,
                                           ENDRSN,
                                           USRPRF,
                                           JOBNM,
                                           DATIME)
                                 VALUES
                                           (
                                           DMPR_DATA(i).ACCTYEAR,
                                           DMPR_DATA(i).ACCTMONTH,
                                           DMPR_DATA(i).PROCCODE,
                                           DMPR_DATA(i).PAYDATE,
                                           DMPR_DATA(i).CNTBRANCH,
                                           DMPR_DATA(i).FACTHOUS,
                                           DMPR_DATA(i).ENDSERCD,
                                           DMPR_DATA(i).CNTTYPE,
                                           DMPR_DATA(i).CHDRPFX,
                                           DMPR_DATA(i).CHDRCOY,
                                           DMPR_DATA(i).CHDRNUM,
                                           DMPR_DATA(i).CURRFROM,
                                           DMPR_DATA(i).TRANNO,
                                           DMPR_DATA(i).CLNTPFX,
                                           DMPR_DATA(i).CLNTCOY,
                                           DMPR_DATA(i).CLNTNUM,
                                           DMPR_DATA(i).PAYAMT,
                                           DMPR_DATA(i).TRANDATE,
                                           DMPR_DATA(i).BANKKEY,
                                           DMPR_DATA(i).BANKACCKEY,
                                           DMPR_DATA(i).BANKACCDSC,
                                           DMPR_DATA(i).BBKACTYP,
                                           DMPR_DATA(i).CCDATE,
                                           DMPR_DATA(i).CRDATE,
                                           DMPR_DATA(i).CHEQPFX,
                                           DMPR_DATA(i).CHEQCOY,
                                           DMPR_DATA(i).CHEQBCDE,
                                           DMPR_DATA(i).CHEQNO,
                                           DMPR_DATA(i).CHEQDUPN,
                                           DMPR_DATA(i).USERP,
                                           DMPR_DATA(i).ERRORCODE,
                                           DMPR_DATA(i).ENDRSN,
                                           DMPR_DATA(i).USRPRF,
                                           DMPR_DATA(i).JOBNM,
                                           DMPR_DATA(i).DATIME
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + DMPR_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_DMPR',DMPR_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=DMPR_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_DMPR_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_DMPR_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_DMPR', 'DMPR', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_DMPR', 'DMPR', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_DMPR', 'DMPR', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_DMPR;
-- Procedure for RE-RUN SQL LOADER - DMPR <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - DECLINE_REASON_CODE <STARTS> Here

PROCEDURE DM_DECLINE_REASON_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_DECLINE_REASON_CODE%ROWTYPE;
          DRC_DATA IG_ARRAY;
          V_APP DECLINE_REASON_CODE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_DECLINE_REASON_CODE_TMP IS
               SELECT * FROM TMP_DECLINE_REASON_CODE;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM DECLINE_REASON_CODE WHERE EXISTS (SELECT 'X' FROM TMP_DECLINE_REASON_CODE DT WHERE DT.DM_R_CODE = DECLINE_REASON_CODE.DM_R_CODE );
         -- Delete the records for all the records exists in DECLINE_REASON_CODE for Delta Load

           OPEN CUR_DECLINE_REASON_CODE_TMP;
           LOOP
            FETCH CUR_DECLINE_REASON_CODE_TMP BULK COLLECT INTO DRC_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + DRC_DATA.COUNT;
           FORALL i IN 1..DRC_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO DECLINE_REASON_CODE(
                                           DM_R_CODE,
                                           IG_R_CODE,
                                           "DESC")
                                 VALUES
                                           (
                                           DRC_DATA(i).DM_R_CODE,
                                           DRC_DATA(i).IG_R_CODE,
                                           DRC_DATA(i)."DESC"
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + DRC_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_DECLINE_REASON_CODE',DRC_DATA(sql%bulk_exceptions(beindx).error_index).DM_R_CODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=DRC_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_DECLINE_REASON_CODE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_DECLINE_REASON_CODE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_DECLINE_REASON_CODE', 'DECLINE_REASON_CODE', SYSTIMESTAMP,V_APP.DM_R_CODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_DECLINE_REASON_CODE', 'DECLINE_REASON_CODE', SYSTIMESTAMP,V_APP.DM_R_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_DECLINE_REASON_CODE', 'DECLINE_REASON_CODE', SYSTIMESTAMP,V_APP.DM_R_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_DECLINE_REASON_CODE;
-- Procedure for RE-RUN SQL LOADER - DECLINE_REASON_CODE <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - CARD_ENDORSER_LIST <STARTS> Here

PROCEDURE DM_CARD_ENDORSER_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_CARD_ENDORSER_LIST%ROWTYPE;
          CEL_DATA IG_ARRAY;
          V_APP CARD_ENDORSER_LIST%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_CARD_ENDORSER_LIST_TMP IS
               SELECT * FROM TMP_CARD_ENDORSER_LIST;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM CARD_ENDORSER_LIST WHERE EXISTS (SELECT 'X' FROM TMP_CARD_ENDORSER_LIST DT WHERE DT.ENDORSERCODE = CARD_ENDORSER_LIST.ENDORSERCODE );
         -- Delete the records for all the records exists in CARD_ENDORSER_LIST for Delta Load

           OPEN CUR_CARD_ENDORSER_LIST_TMP;
           LOOP
            FETCH CUR_CARD_ENDORSER_LIST_TMP BULK COLLECT INTO CEL_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + CEL_DATA.COUNT;
           FORALL i IN 1..CEL_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO CARD_ENDORSER_LIST(
                                           ENDORSERCODE,
                                           FILETYPE,
                                           TABLENAME,
                                           FIELDNAME,
                                           ST_POS,
                                           DATALENGTH
                                           )
                                 VALUES
                                           (
                                          CEL_DATA(i).ENDORSERCODE,
                                          CEL_DATA(i).FILETYPE,
                                          CEL_DATA(i).TABLENAME,
                                          CEL_DATA(i).FIELDNAME,
                                          CEL_DATA(i).ST_POS,
                                          CEL_DATA(i).DATALENGTH
                                            );

        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + CEL_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_CARD_ENDORSER_LIST',CEL_DATA(sql%bulk_exceptions(beindx).error_index).ENDORSERCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=CEL_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_CARD_ENDORSER_LIST_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_CARD_ENDORSER_LIST_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_CARD_ENDORSER_LIST', 'CARD_ENDORSER_LIST', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_CARD_ENDORSER_LIST', 'CARD_ENDORSER_LIST', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_CARD_ENDORSER_LIST', 'CARD_ENDORSER_LIST', SYSTIMESTAMP,V_APP.ENDORSERCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_CARD_ENDORSER_LIST;
-- Procedure for RE-RUN SQL LOADER - CARD_ENDORSER_LIST <ENDS> Here

-- Procedure for RE-RUN SQL LOADER - ALTER_REASON_CODE <STARTS> Here

PROCEDURE DM_ALTER_REASON_CODE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ALTER_REASON_CODE%ROWTYPE;
          ARC_DATA IG_ARRAY;
          V_APP ALTER_REASON_CODE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ALTER_REASON_CODE_TMP IS
               SELECT * FROM TMP_ALTER_REASON_CODE;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ALTER_REASON_CODE WHERE EXISTS (SELECT 'X' FROM TMP_ALTER_REASON_CODE DT WHERE DT.DM_AL_CODE = ALTER_REASON_CODE.DM_AL_CODE );
         -- Delete the records for all the records exists in ALTER_REASON_CODE for Delta Load

           OPEN CUR_ALTER_REASON_CODE_TMP;
           LOOP
            FETCH CUR_ALTER_REASON_CODE_TMP BULK COLLECT INTO ARC_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ARC_DATA.COUNT;
           FORALL i IN 1..ARC_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ALTER_REASON_CODE(
                                           DM_AL_CODE,
                                           IG_AL_CODE,
                                           DESCRIPTION)
                                 VALUES
                                           (
                                          ARC_DATA(i).DM_AL_CODE,
                                          ARC_DATA(i).IG_AL_CODE,
                                          ARC_DATA(i).DESCRIPTION
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ARC_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ALTER_REASON_CODE',ARC_DATA(sql%bulk_exceptions(beindx).error_index).DM_AL_CODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ARC_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ALTER_REASON_CODE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ALTER_REASON_CODE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ALTER_REASON_CODE', 'ALTER_REASON_CODE', SYSTIMESTAMP,V_APP.DM_AL_CODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ALTER_REASON_CODE', 'ALTER_REASON_CODE', SYSTIMESTAMP,V_APP.DM_AL_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ALTER_REASON_CODE', 'ALTER_REASON_CODE', SYSTIMESTAMP,V_APP.DM_AL_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ALTER_REASON_CODE;
-- Procedure for RE-RUN SQL LOADER - ALTER_REASON_CODE <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - BTDATE_PTDATE_LIST <STARTS> Here

PROCEDURE DM_BTDATE_PTDATE_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_BTDATE_PTDATE_LIST%ROWTYPE;
          BPL_DATA IG_ARRAY;
          V_APP BTDATE_PTDATE_LIST%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_BTDATE_PTDATE_LIST_TMP IS
               SELECT * FROM TMP_BTDATE_PTDATE_LIST;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM BTDATE_PTDATE_LIST WHERE EXISTS (SELECT 'X' FROM TMP_BTDATE_PTDATE_LIST DT WHERE DT.CHDRNUM = BTDATE_PTDATE_LIST.CHDRNUM );
         -- Delete the records for all the records exists in BTDATE_PTDATE_LIST for Delta Load

           OPEN CUR_BTDATE_PTDATE_LIST_TMP;
           LOOP
            FETCH CUR_BTDATE_PTDATE_LIST_TMP BULK COLLECT INTO BPL_DATA;-- LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + BPL_DATA.COUNT;
           FORALL i IN 1..BPL_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO BTDATE_PTDATE_LIST(
                                           CHDRNUM,
                                           PTDATE,
                                           BTDATE,
                                           STATCODE,
                                           ZPGPFRDT,
                                           ZPGPTODT,
                                           ENDSERCD
                                           )
                                 VALUES
                                           (
                                          BPL_DATA(i).CHDRNUM,
                                          BPL_DATA(i).PTDATE,
                                          BPL_DATA(i).BTDATE,
                                          BPL_DATA(i).STATCODE,
                                          BPL_DATA(i).ZPGPFRDT,
                                          BPL_DATA(i).ZPGPTODT,
                                          BPL_DATA(i).ENDSERCD
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BPL_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_BTDATE_PTDATE_LIST',BPL_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=BPL_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_BTDATE_PTDATE_LIST_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_BTDATE_PTDATE_LIST_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_BTDATE_PTDATE_LIST', 'BTDATE_PTDATE_LIST', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_BTDATE_PTDATE_LIST', 'BTDATE_PTDATE_LIST', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_BTDATE_PTDATE_LIST', 'BTDATE_PTDATE_LIST', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_BTDATE_PTDATE_LIST;
-- Procedure for RE-RUN SQL LOADER - BTDATE_PTDATE_LIST <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - DSH_CODE_REF <STARTS> Here

PROCEDURE DM_DSH_CODE_REF(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_DSH_CODE_REF%ROWTYPE;
          DCR_DATA IG_ARRAY;
          V_APP DSH_CODE_REF%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_DSH_CODE_REF_TMP IS
               SELECT * FROM TMP_DSH_CODE_REF;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM DSH_CODE_REF WHERE EXISTS (SELECT 'X' FROM TMP_DSH_CODE_REF DT WHERE DT.RECSEQNODSHCDE = DSH_CODE_REF.RECSEQNODSHCDE );
         -- Delete the records for all the records exists in DSH_CODE_REF for Delta Load

           OPEN CUR_DSH_CODE_REF_TMP;
           LOOP
            FETCH CUR_DSH_CODE_REF_TMP BULK COLLECT INTO DCR_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + DCR_DATA.COUNT;
           FORALL i IN 1..DCR_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO DSH_CODE_REF(
                                           RECSEQNODSHCDE,
                                           PJ_DSHCDE,
                                           PJ_FACTHOUS,
                                           IG_DSHCDE,
                                           IGITEMLONGDESC
                                           )
                                 VALUES
                                           (
                                          DCR_DATA(i).RECSEQNODSHCDE,
                                          DCR_DATA(i).PJ_DSHCDE,
                                          DCR_DATA(i).PJ_FACTHOUS,
                                          DCR_DATA(i).IG_DSHCDE,
                                          DCR_DATA(i).IGITEMLONGDESC
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + DCR_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_DSH_CODE_REF',DCR_DATA(sql%bulk_exceptions(beindx).error_index).RECSEQNODSHCDE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=DCR_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_DSH_CODE_REF_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_DSH_CODE_REF_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_DSH_CODE_REF', 'DSH_CODE_REF', SYSTIMESTAMP,V_APP.RECSEQNODSHCDE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_DSH_CODE_REF', 'DSH_CODE_REF', SYSTIMESTAMP,V_APP.RECSEQNODSHCDE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_DSH_CODE_REF', 'DSH_CODE_REF', SYSTIMESTAMP,V_APP.RECSEQNODSHCDE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_DSH_CODE_REF;
-- Procedure for RE-RUN SQL LOADER - DSH_CODE_REF <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - TITDMGCLNTCORP <STARTS> Here

PROCEDURE DM_TITDMGCLNTCORP(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGCLNTCORP%ROWTYPE;
          CCORP_DATA IG_ARRAY;
          V_APP TITDMGCLNTCORP%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGCLNTCORP_TMP IS
               SELECT * FROM TMP_TITDMGCLNTCORP;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGCLNTCORP WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGCLNTCORP DT WHERE DT.CLNTKEY = TITDMGCLNTCORP.CLNTKEY AND DT.AGNTNUM = TITDMGCLNTCORP.AGNTNUM AND DT.MPLNUM = TITDMGCLNTCORP.MPLNUM);
         -- Delete the records for all the records exists in TITDMGCLNTCORP for Delta Load

           OPEN CUR_TITDMGCLNTCORP_TMP;
           LOOP
            FETCH CUR_TITDMGCLNTCORP_TMP BULK COLLECT INTO CCORP_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + CCORP_DATA.COUNT;
           FORALL i IN 1..CCORP_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGCLNTCORP(
                                           CLTTYPE,
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
                                           MPLNUM
                                           )
                                 VALUES
                                           (
                                          CCORP_DATA(i).CLTTYPE,
                                          CCORP_DATA(i).CLTADDR01,
                                          CCORP_DATA(i).CLTADDR02,
                                          CCORP_DATA(i).CLTADDR03,
                                          CCORP_DATA(i).CLTADDR04,
                                          CCORP_DATA(i).ZKANADDR01,
                                          CCORP_DATA(i).ZKANADDR02,
                                          CCORP_DATA(i).ZKANADDR03,
                                          CCORP_DATA(i).ZKANADDR04,
                                          CCORP_DATA(i).CLTPCODE,
                                          CCORP_DATA(i).CLTPHONE01,
                                          CCORP_DATA(i).CLTPHONE02,
                                          CCORP_DATA(i).CLTDOBX,
                                          CCORP_DATA(i).CLTSTAT,
                                          CCORP_DATA(i).FAXNO,
                                          CCORP_DATA(i).LSURNAME,
                                          CCORP_DATA(i).ZKANASNM,
                                          CCORP_DATA(i).CLNTKEY,
                                          CCORP_DATA(i).AGNTNUM,
                                          CCORP_DATA(i).MPLNUM
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + CCORP_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGCLNTCORP',CCORP_DATA(sql%bulk_exceptions(beindx).error_index).CLNTKEY,SUBSTR('(' || CCORP_DATA(sql%bulk_exceptions(beindx).error_index).CLNTKEY || CCORP_DATA(sql%bulk_exceptions(beindx).error_index).AGNTNUM || CCORP_DATA(sql%bulk_exceptions(beindx).error_index).MPLNUM || ')' || V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=CCORP_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGCLNTCORP_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGCLNTCORP_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGCLNTCORP', 'TITDMGCLNTCORP', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGCLNTCORP', 'TITDMGCLNTCORP', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGCLNTCORP', 'TITDMGCLNTCORP', SYSTIMESTAMP,V_APP.CLNTKEY,'(' || V_APP.CLNTKEY || V_APP.AGNTNUM || V_APP.MPLNUM || ')' || V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGCLNTCORP;
-- Procedure for RE-RUN SQL LOADER - TITDMGCLNTCORP <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - TITDMGCAMPCDE <STARTS> Here

PROCEDURE DM_TITDMGCAMPCDE(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGCAMPCDE%ROWTYPE;
          CCDE_DATA IG_ARRAY;
          V_APP TMP_TITDMGCAMPCDE%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGCAMPCDE_TMP IS
               SELECT * FROM TMP_TITDMGCAMPCDE;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGCAMPCDE WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGCAMPCDE DT WHERE DT.ZCMPCODE = TITDMGCAMPCDE.ZCMPCODE );
         -- Delete the records for all the records exists in TITDMGCAMPCDE for Delta Load

           OPEN CUR_TITDMGCAMPCDE_TMP;
           LOOP
            FETCH CUR_TITDMGCAMPCDE_TMP BULK COLLECT INTO CCDE_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + CCDE_DATA.COUNT;
           FORALL i IN 1..CCDE_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGCAMPCDE(
                                           ZCMPCODE,
                                           ZPETNAME,
                                           ZPOLCLS,
                                           ZENDCODE,
                                           CHDRNUM,
                                           GPOLTYP,
                                           ZAGPTID,
                                           RCDATE,
                                           ZCMPFRM,
                                           ZCMPTO,
                                           ZMAILDAT,
                                           ZACLSDAT,
                                           ZDLVCDDT,
                                           ZVEHICLE,
                                           ZSTAGE,
                                           ZSCHEME01,
                                           ZSCHEME02,
                                           ZCRTUSR,
                                           ZAPPDATE,
                                           ZCCODIND,
                                           EFFDATE,
                                           STATUS
                                           )
                                 VALUES
                                           (
                                          CCDE_DATA(i).ZCMPCODE,
                                          CCDE_DATA(i).ZPETNAME,
                                          CCDE_DATA(i).ZPOLCLS,
                                          CCDE_DATA(i).ZENDCODE,
                                          CCDE_DATA(i).CHDRNUM,
                                          CCDE_DATA(i).GPOLTYP,
                                          CCDE_DATA(i).ZAGPTID,
                                          CCDE_DATA(i).RCDATE,
                                          CCDE_DATA(i).ZCMPFRM,
                                          CCDE_DATA(i).ZCMPTO,
                                          CCDE_DATA(i).ZMAILDAT,
                                          CCDE_DATA(i).ZACLSDAT,
                                          CCDE_DATA(i).ZDLVCDDT,
                                          CCDE_DATA(i).ZVEHICLE,
                                          CCDE_DATA(i).ZSTAGE,
                                          CCDE_DATA(i).ZSCHEME01,
                                          CCDE_DATA(i).ZSCHEME02,
                                          CCDE_DATA(i).ZCRTUSR,
                                          CCDE_DATA(i).ZAPPDATE,
                                          CCDE_DATA(i).ZCCODIND,
                                          CCDE_DATA(i).EFFDATE,
                                          CCDE_DATA(i).STATUS
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + CCDE_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGCAMPCDE',CCDE_DATA(sql%bulk_exceptions(beindx).error_index).ZCMPCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
             V_APP:= CCDE_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGCAMPCDE_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGCAMPCDE_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGCAMPCDE', 'TITDMGCAMPCDE', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGCAMPCDE', 'TITDMGCAMPCDE', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGCAMPCDE', 'TITDMGCAMPCDE', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGCAMPCDE;
-- Procedure for RE-RUN SQL LOADER - TITDMGCAMPCDE <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - TITDMGSALEPLN1 <STARTS> Here

PROCEDURE DM_TITDMGSALEPLN1(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGSALEPLN1%ROWTYPE;
          SP1_DATA IG_ARRAY;
          V_APP TITDMGSALEPLN1%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGSALEPLN1_TMP IS
               SELECT * FROM TMP_TITDMGSALEPLN1;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGSALEPLN1 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGSALEPLN1 DT WHERE DT.ZSALPLAN = TITDMGSALEPLN1.ZSALPLAN );
         -- Delete the records for all the records exists in TITDMGSALEPLN1 for Delta Load

           OPEN CUR_TITDMGSALEPLN1_TMP;
           LOOP
            FETCH CUR_TITDMGSALEPLN1_TMP BULK COLLECT INTO SP1_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + SP1_DATA.COUNT;
           FORALL i IN 1..SP1_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGSALEPLN1(
                                           ZSALPLAN,
                                           ZINSTYPE,
                                           PRODTYP,
                                           SUMINS ,
                                           ZCOVRID,
                                           ZIMBRPLO
                                           )
                                 VALUES
                                           (
                                          SP1_DATA(i).ZSALPLAN,
                                          SP1_DATA(i).ZINSTYPE,
                                          SP1_DATA(i).PRODTYP,
                                          SP1_DATA(i).SUMINS ,
                                          SP1_DATA(i).ZCOVRID,
                                          SP1_DATA(i).ZIMBRPLO
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + SP1_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGSALEPLN1',SP1_DATA(sql%bulk_exceptions(beindx).error_index).ZSALPLAN,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=SP1_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGSALEPLN1_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGSALEPLN1_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN1', 'TITDMGSALEPLN1', SYSTIMESTAMP,V_APP.ZSALPLAN,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN1', 'TITDMGSALEPLN1', SYSTIMESTAMP,V_APP.ZSALPLAN,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN1', 'TITDMGSALEPLN1', SYSTIMESTAMP,V_APP.ZSALPLAN,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGSALEPLN1;
-- Procedure for RE-RUN SQL LOADER - TITDMGSALEPLN1 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - TITDMGSALEPLN2 <STARTS> Here

PROCEDURE DM_TITDMGSALEPLN2(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGSALEPLN2%ROWTYPE;
          SP2_DATA IG_ARRAY;
          V_APP TITDMGSALEPLN2%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGSALEPLN2_TMP IS
               SELECT * FROM TMP_TITDMGSALEPLN2;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGSALEPLN2 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGSALEPLN2 DT WHERE DT.ZCMPCODE = TITDMGSALEPLN2.ZCMPCODE );
         -- Delete the records for all the records exists in TITDMGSALEPLN2 for Delta Load

           OPEN CUR_TITDMGSALEPLN2_TMP;
           LOOP
            FETCH CUR_TITDMGSALEPLN2_TMP BULK COLLECT INTO SP2_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + SP2_DATA.COUNT;
           FORALL i IN 1..SP2_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGSALEPLN2(
                                           ZCMPCODE,
                                           ZSALPLAN
                                         )
                                 VALUES
                                           (
                                          SP2_DATA(i).ZCMPCODE,
                                          SP2_DATA(i).ZSALPLAN
                                            );

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + SP2_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGSALEPLN2',SP2_DATA(sql%bulk_exceptions(beindx).error_index).ZCMPCODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=SP2_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGSALEPLN2_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGSALEPLN2_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN2', 'TITDMGSALEPLN2', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN2', 'TITDMGSALEPLN2', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGSALEPLN2', 'TITDMGSALEPLN2', SYSTIMESTAMP,V_APP.ZCMPCODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGSALEPLN2;
-- Procedure for RE-RUN SQL LOADER - TITDMGSALEPLN2 <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - TITDMGBILL1 <STARTS> Here

PROCEDURE DM_TITDMGBILL1(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGBILL1%ROWTYPE;
          BILL1_DATA IG_ARRAY;
          V_APP TITDMGBILL1%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGBILL1_TMP IS
               SELECT * FROM TMP_TITDMGBILL1;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGBILL1 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGBILL1 DT WHERE DT.CHDRNUM = TITDMGBILL1.CHDRNUM );
         -- Delete the records for all the records exists in TITDMGBILL1 for Delta Load

           OPEN CUR_TITDMGBILL1_TMP;
           LOOP
            FETCH CUR_TITDMGBILL1_TMP BULK COLLECT INTO BILL1_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + BILL1_DATA.COUNT;
           FORALL i IN 1..BILL1_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGBILL1(
                                           TRREFNUM,
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
                                           TRANNO
                                         )
                                 VALUES
                                           (
                                          BILL1_DATA(i).TRREFNUM,
                                          BILL1_DATA(i).CHDRNUM,
                                          BILL1_DATA(i).PRBILFDT,
                                          BILL1_DATA(i).PRBILTDT,
                                          BILL1_DATA(i).PREMOUT,
                                          BILL1_DATA(i).ZCOLFLAG,
                                          BILL1_DATA(i).ZACMCLDT,
                                          BILL1_DATA(i).ZPOSBDSM,
                                          BILL1_DATA(i).ZPOSBDSY,
                                          BILL1_DATA(i).ENDSERCD,
                                          BILL1_DATA(i).TFRDATE,
                                          BILL1_DATA(i).POSTING,
                                          BILL1_DATA(i).NRFLAG,
                                          BILL1_DATA(i).ZPDATATXFLG,
                                          BILL1_DATA(i).TRANNO
                                            );

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + BILL1_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGBILL1',BILL1_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
        --   IF V_INPUT_COUNT <> 0 THEN
           --   V_APP:=BILL1_DATA(V_INPUT_COUNT);
       --    END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGBILL1_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGBILL1_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL1', 'TITDMGBILL1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL1', 'TITDMGBILL1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL1', 'TITDMGBILL1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGBILL1;
-- Procedure for RE-RUN SQL LOADER - TITDMGBILL1 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - TITDMGBILL2 <STARTS> Here

PROCEDURE DM_TITDMGBILL2(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGBILL2%ROWTYPE;
          BILL2_DATA IG_ARRAY;
          V_APP TITDMGBILL2%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGBILL2_TMP IS
               SELECT * FROM TMP_TITDMGBILL2;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGBILL2 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGBILL2 DT WHERE DT.CHDRNUM = TITDMGBILL2.CHDRNUM );
         -- Delete the records for all the records exists in TITDMGBILL2 for Delta Load

           OPEN CUR_TITDMGBILL2_TMP;
           LOOP
            FETCH CUR_TITDMGBILL2_TMP BULK COLLECT INTO BILL2_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + BILL2_DATA.COUNT;
           FORALL i IN 1..BILL2_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGBILL2(
                                           TRREFNUM,
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
                                           REFNUMCHUNK
                                         )
                                 VALUES
                                           (
                                          BILL2_DATA(i).TRREFNUM,
                                          BILL2_DATA(i).CHDRNUM,
                                          BILL2_DATA(i).TRANNO,
                                          BILL2_DATA(i).PRODTYP,
                                          BILL2_DATA(i).BPREM,
                                          BILL2_DATA(i).GAGNTSEL01,
                                          BILL2_DATA(i).GAGNTSEL02,
                                          BILL2_DATA(i).GAGNTSEL03,
                                          BILL2_DATA(i).GAGNTSEL04,
                                          BILL2_DATA(i).GAGNTSEL05,
                                          BILL2_DATA(i).CMRATE01,
                                          BILL2_DATA(i).CMRATE02,
                                          BILL2_DATA(i).CMRATE03,
                                          BILL2_DATA(i).CMRATE04,
                                          BILL2_DATA(i).CMRATE05,
                                          BILL2_DATA(i).COMMN01,
                                          BILL2_DATA(i).COMMN02,
                                          BILL2_DATA(i).COMMN03,
                                          BILL2_DATA(i).COMMN04,
                                          BILL2_DATA(i).COMMN05,
                                          BILL2_DATA(i).ZAGTGPRM01,
                                          BILL2_DATA(i).ZAGTGPRM02,
                                          BILL2_DATA(i).ZAGTGPRM03,
                                          BILL2_DATA(i).ZAGTGPRM04,
                                          BILL2_DATA(i).ZAGTGPRM05,
                                          BILL2_DATA(i).ZCOLLFEE01,
                                          BILL2_DATA(i).MBRNO,
                                          BILL2_DATA(i).DPNTNO,
                                          BILL2_DATA(i).PRBILFDT,
                                          BILL2_DATA(i).REFNUMCHUNK
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BILL2_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGBILL2',BILL2_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
             V_APP:=BILL2_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGBILL2_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGBILL2_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL2', 'TITDMGBILL2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL2', 'TITDMGBILL2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGBILL2', 'TITDMGBILL2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGBILL2;
-- Procedure for RE-RUN SQL LOADER - TITDMGBILL2 <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - TITDMGREF1 <STARTS> Here

PROCEDURE DM_TITDMGREF1(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGREF1%ROWTYPE;
          REF1_DATA IG_ARRAY;
          V_APP TITDMGREF1%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);

l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGREF1_TMP IS
               SELECT * FROM TMP_TITDMGREF1;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGREF1 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGREF1 DT WHERE DT.CHDRNUM = TITDMGREF1.CHDRNUM );
         -- Delete the records for all the records exists in TITDMGREF1 for Delta Load

           OPEN CUR_TITDMGREF1_TMP;
           LOOP
            FETCH CUR_TITDMGREF1_TMP BULK COLLECT INTO REF1_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + REF1_DATA.COUNT;
           FORALL i IN 1..REF1_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGREF1(
                                           REFNUM,
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
										   NRFLAG,
                                           TRANNO
                                           )
                                 VALUES
                                           (
                                          REF1_DATA(i).REFNUM,
                                          REF1_DATA(i).CHDRNUM,
                                          REF1_DATA(i).ZREFMTCD,
                                          REF1_DATA(i).EFFDATE,
                                          REF1_DATA(i).PRBILFDT,
                                          REF1_DATA(i).PRBILTDT,
                                          REF1_DATA(i).ZPOSBDSM,
                                          REF1_DATA(i).ZPOSBDSY,
                                          REF1_DATA(i).ZALTRCDE01,
                                          REF1_DATA(i).ZREFUNDBE,
                                          REF1_DATA(i).ZREFUNDBZ,
                                          REF1_DATA(i).ZENRFDST,
                                          REF1_DATA(i).ZZHRFDST,
                                          REF1_DATA(i).BANKKEY,
                                          REF1_DATA(i).BANKACOUNT,
                                          REF1_DATA(i).BANKACCDSC,
                                          REF1_DATA(i).BNKACTYP,
                                          REF1_DATA(i).ZRQBKRDF,
                                          REF1_DATA(i).REQDATE,
                                          REF1_DATA(i).ZCOLFLAG,
                                          REF1_DATA(i).PAYDATE,
                                          REF1_DATA(i).RDOCPFX,
                                          REF1_DATA(i).RDOCCOY,
                                          REF1_DATA(i).RDOCNUM,
                                          REF1_DATA(i).ZPDATATXFLG,
										  REF1_DATA(i).NRFLAG,
                                          REF1_DATA(i).TRANNO
                                          );

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + REF1_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGREF1',REF1_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
       --    IF V_INPUT_COUNT <> 0 THEN
      --        V_APP:=REF1_DATA(V_INPUT_COUNT);
      --     END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGREF1_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGREF1_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGREF1', 'TITDMGREF1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGREF1', 'TITDMGREF1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGREF1', 'TITDMGREF1', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGREF1;
-- Procedure for RE-RUN SQL LOADER - TITDMGREF1 <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - TITDMGREF2 <STARTS> Here

PROCEDURE DM_TITDMGREF2(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGREF2%ROWTYPE;
          REF2_DATA IG_ARRAY;
          V_APP TITDMGREF2%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGREF2_TMP IS
               SELECT * FROM TMP_TITDMGREF2;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGREF2 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGREF2 DT WHERE DT.CHDRNUM = TITDMGREF2.CHDRNUM );
         -- Delete the records for all the records exists in TITDMGREF2 for Delta Load

           OPEN CUR_TITDMGREF2_TMP;
           LOOP
            FETCH CUR_TITDMGREF2_TMP BULK COLLECT INTO REF2_DATA;-- LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + REF2_DATA.COUNT;
           FORALL i IN 1..REF2_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGREF2(
                                           TRREFNUM,
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
                                           DPNTNO,
                                           TRANNO,
                                           REFNUMCHUNK
                                            )
                                 VALUES
                                           (
                                          REF2_DATA(i).TRREFNUM,
                                          REF2_DATA(i).CHDRNUM,
                                          REF2_DATA(i).ZREFMTCD,
                                          REF2_DATA(i).PRODTYP,
                                          REF2_DATA(i).BPREM,
                                          REF2_DATA(i).GAGNTSEL01,
                                          REF2_DATA(i).GAGNTSEL02,
                                          REF2_DATA(i).GAGNTSEL03,
                                          REF2_DATA(i).GAGNTSEL04,
                                          REF2_DATA(i).GAGNTSEL05,
                                          REF2_DATA(i).CMRATE01,
                                          REF2_DATA(i).CMRATE02,
                                          REF2_DATA(i).CMRATE03,
                                          REF2_DATA(i).CMRATE04,
                                          REF2_DATA(i).CMRATE05,
                                          REF2_DATA(i).COMMN01,
                                          REF2_DATA(i).COMMN02,
                                          REF2_DATA(i).COMMN03,
                                          REF2_DATA(i).COMMN04,
                                          REF2_DATA(i).COMMN05,
                                          REF2_DATA(i).ZAGTGPRM01,
                                          REF2_DATA(i).ZAGTGPRM02,
                                          REF2_DATA(i).ZAGTGPRM03,
                                          REF2_DATA(i).ZAGTGPRM04,
                                          REF2_DATA(i).ZAGTGPRM05,
                                          REF2_DATA(i).ZCOLLFEE01,
                                          REF2_DATA(i).MBRNO,
                                          REF2_DATA(i).DPNTNO,
                                          REF2_DATA(i).TRANNO,
                                          REF2_DATA(i).REFNUMCHUNK
                                          );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + REF2_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGREF2',REF2_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=REF2_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGREF2_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGREF2_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGREF2', 'TITDMGREF2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGREF2', 'TITDMGREF2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGREF2', 'TITDMGREF2', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGREF2;
-- Procedure for RE-RUN SQL LOADER - TITDMGREF2 <ENDS> Here



-- Procedure for RE-RUN SQL LOADER - TITDMGMBRINDP3 <STARTS> Here

PROCEDURE DM_TITDMGMBRINDP3(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGMBRINDP3%ROWTYPE;
          DP3_DATA IG_ARRAY;
          V_APP TITDMGMBRINDP3%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_TITDMGMBRINDP3_TMP IS
               SELECT * FROM TMP_TITDMGMBRINDP3;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGMBRINDP3 WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGMBRINDP3 DT WHERE DT.OLDPOLNUM = TITDMGMBRINDP3.OLDPOLNUM );
         -- Delete the records for all the records exists in TITDMGMBRINDP3 for Delta Load

           OPEN CUR_TITDMGMBRINDP3_TMP;
           LOOP
            FETCH CUR_TITDMGMBRINDP3_TMP BULK COLLECT INTO DP3_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + DP3_DATA.COUNT;
           FORALL i IN 1..DP3_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGMBRINDP3(
                                           OLDPOLNUM
										    )
                                 VALUES
                                           (
                                         DP3_DATA(i).OLDPOLNUM
                                            );

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + DP3_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGMBRINDP3',DP3_DATA(sql%bulk_exceptions(beindx).error_index).OLDPOLNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=DP3_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_TITDMGMBRINDP3_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGMBRINDP3_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_TITDMGMBRINDP3', 'TITDMGMBRINDP3', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGMBRINDP3', 'TITDMGMBRINDP3', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGMBRINDP3', 'TITDMGMBRINDP3', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_TITDMGMBRINDP3;
-- Procedure for RE-RUN SQL LOADER - TITDMGMBRINDP3 <ENDS> Here


-- Procedure for RE-RUN SQL LOADER - PJ_TITDMGCOLRES <STARTS> Here

PROCEDURE DM_PJ_TITDMGCOLRES(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_PJ_TITDMGCOLRES%ROWTYPE;
          COLR_DATA IG_ARRAY;
          V_APP PJ_TITDMGCOLRES%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_PJ_TITDMGCOLRES_TMP IS
               SELECT * FROM TMP_PJ_TITDMGCOLRES;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM PJ_TITDMGCOLRES WHERE EXISTS (SELECT 'X' FROM TMP_PJ_TITDMGCOLRES DT WHERE DT.CHDRNUM = PJ_TITDMGCOLRES.CHDRNUM );
         -- Delete the records for all the records exists in PJ_TITDMGCOLRES for Delta Load

           OPEN CUR_PJ_TITDMGCOLRES_TMP;
           LOOP
            FETCH CUR_PJ_TITDMGCOLRES_TMP BULK COLLECT INTO COLR_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + COLR_DATA.COUNT;
           FORALL i IN 1..COLR_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO PJ_TITDMGCOLRES(
                                           CHDRNUM,
                                           TRREFNUM,
                                           TFRDATE,
                                           PSHCDE,
                                           FACTHOUS,
										   PRBILFDT
                                         )
                                 VALUES
                                           (
                                         COLR_DATA(i).CHDRNUM,
                                         COLR_DATA(i).TRREFNUM,
                                         COLR_DATA(i).TFRDATE,
                                         COLR_DATA(i).PSHCDE,
                                         COLR_DATA(i).FACTHOUS,
                                         COLR_DATA(i).PRBILFDT
                                            );

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + COLR_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_PJ_TITDMGCOLRES',COLR_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=COLR_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_PJ_TITDMGCOLRES_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_PJ_TITDMGCOLRES_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_PJ_TITDMGCOLRES', 'PJ_TITDMGCOLRES', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_PJ_TITDMGCOLRES', 'PJ_TITDMGCOLRES', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_PJ_TITDMGCOLRES', 'PJ_TITDMGCOLRES', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_PJ_TITDMGCOLRES;
-- Procedure for RE-RUN SQL LOADER - PJ_TITDMGCOLRES <ENDS> Here
-- Procedure for RE-RUN SQL LOADER - ZMRISA00 <STARTS> Here
PROCEDURE DM_ZMRISA00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRISA00%ROWTYPE;
          ZMRISA_DATA IG_ARRAY;
          V_APP TMP_ZMRISA00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRISA00_TMP IS
               SELECT * FROM TMP_ZMRISA00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRISA00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRISA00 DT WHERE DT.ISACUCD = ZMRISA00.ISACUCD);
         -- Delete the records for all the records exists in TRAN_STATUS_CODE for Delta Load

           OPEN CUR_ZMRISA00_TMP;
           LOOP
            FETCH CUR_ZMRISA00_TMP BULK COLLECT INTO ZMRISA_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRISA_DATA.COUNT;
           FORALL i IN 1..ZMRISA_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRISA00(
                                          ISACUCD,
										  ISACICD,
										  ISAA4ST,
										  ISAFLAG,
										  ISAC9CD,
										  ISADICD,
										  ISAB0TX,
										  ISAB1TX,
										  ISAB2TX,
										  ISAB3TX,
										  ISAB7IG,
										  ISAB8IG,
										  ISAB9IG,
										  ISACAIG,
										  ISAB4TX,
										  ISAYOB1,
										  ISAYOB2,
										  ISAYOB3,
										  ISAYOB4,
										  ISAYOB5,
										  ISAYOB6,
										  ISAYOB7,
										  ISAYOB8,
										  ISABOCD,
										  ISABPCD,
										  ISAAMDT,
										  ISAAATM,
										  ISABQCD,
										  ISAANDT,
										  ISAABTM,
										  ISABRCD,
										  ISAB6IG

                                          )
                                 VALUES
                                          (
                                           ZMRISA_DATA(i).ISACUCD,
										  ZMRISA_DATA(i).ISACICD,
										  ZMRISA_DATA(i).ISAA4ST,
										  ZMRISA_DATA(i).ISAFLAG,
										  ZMRISA_DATA(i).ISAC9CD,
										  ZMRISA_DATA(i).ISADICD,
										  ZMRISA_DATA(i).ISAB0TX,
										  ZMRISA_DATA(i).ISAB1TX,
										  ZMRISA_DATA(i).ISAB2TX,
										  ZMRISA_DATA(i).ISAB3TX,
										  ZMRISA_DATA(i).ISAB7IG,
										  ZMRISA_DATA(i).ISAB8IG,
										  ZMRISA_DATA(i).ISAB9IG,
										  ZMRISA_DATA(i).ISACAIG,
										  ZMRISA_DATA(i).ISAB4TX,
										  ZMRISA_DATA(i).ISAYOB1,
										  ZMRISA_DATA(i).ISAYOB2,
										  ZMRISA_DATA(i).ISAYOB3,
										  ZMRISA_DATA(i).ISAYOB4,
										  ZMRISA_DATA(i).ISAYOB5,
										  ZMRISA_DATA(i).ISAYOB6,
										  ZMRISA_DATA(i).ISAYOB7,
										  ZMRISA_DATA(i).ISAYOB8,
										  ZMRISA_DATA(i).ISABOCD,
										  ZMRISA_DATA(i).ISABPCD,
										  ZMRISA_DATA(i).ISAAMDT,
										  ZMRISA_DATA(i).ISAAATM,
										  ZMRISA_DATA(i).ISABQCD,
										  ZMRISA_DATA(i).ISAANDT,
										  ZMRISA_DATA(i).ISAABTM,
										  ZMRISA_DATA(i).ISABRCD,
										  ZMRISA_DATA(i).ISAB6IG
                                            );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRISA_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRISA00',ZMRISA_DATA(sql%bulk_exceptions(beindx).error_index).ISACUCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRISA_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRISA00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRISA00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRISA00', 'TMP_ZMRISA00', SYSTIMESTAMP,V_APP.ISACUCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRISA00', 'TMP_ZMRISA00', SYSTIMESTAMP,V_APP.ISACUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRISA00', 'TMP_ZMRISA00', SYSTIMESTAMP,V_APP.ISACUCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRISA00;
-- Procedure for RE-RUN SQL LOADER - ZMRISA00 <ENDS> Here
--- Procedure for RE-RUN SQL LOADER -  ZMRRRPT00 < START > Here
PROCEDURE DM_ZMRRPT00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRRPT00%ROWTYPE;
          ZMRRPT_DATA IG_ARRAY;
          V_APP TMP_ZMRRPT00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
		  l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          CURSOR CUR_ZMRRPT00_TMP IS
               SELECT * FROM TMP_ZMRRPT00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;

             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRRPT00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRRPT00 DT WHERE DT.RPTBTCD = ZMRRPT00.RPTBTCD);
         -- Delete the records for all the records exists in ZMRRPT00 for Delta Load

           OPEN CUR_ZMRRPT00_TMP;
           LOOP
            FETCH CUR_ZMRRPT00_TMP BULK COLLECT INTO ZMRRPT_DATA ;--LIMIT p_array_size;

            V_ERRORMSG:='Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRRPT_DATA.COUNT;
           FORALL i IN 1..ZMRRPT_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRRPT00(
                                         RPTBTCD,
										 RPTFPST,
										 RPTYOB1,
										 RPTYOB2,
										 RPTYOB3,
										 RPTYOB4,
										 RPTYOB5,
										 RPTYOB6,
										 RPTYOB7,
										 RPTYOB8,
										 RPTBOCD,
										 RPTBPCD,
										 RPTAMDT,
										 RPTAATM,
										 RPTBQCD,
										 RPTANDT,
										 RPTABTM,
										 RPTBRCD,
										 RPTB6IG
                                          )
                                 VALUES
                                          (
                                          ZMRRPT_DATA(i).RPTBTCD,
										  ZMRRPT_DATA(i).RPTFPST,
										  ZMRRPT_DATA(i).RPTYOB1,
										  ZMRRPT_DATA(i).RPTYOB2,
										  ZMRRPT_DATA(i).RPTYOB3,
										  ZMRRPT_DATA(i).RPTYOB4,
										  ZMRRPT_DATA(i).RPTYOB5,
										  ZMRRPT_DATA(i).RPTYOB6,
										  ZMRRPT_DATA(i).RPTYOB7,
										  ZMRRPT_DATA(i).RPTYOB8,
										  ZMRRPT_DATA(i).RPTBOCD,
										  ZMRRPT_DATA(i).RPTBPCD,
										  ZMRRPT_DATA(i).RPTAMDT,
										  ZMRRPT_DATA(i).RPTAATM,
										  ZMRRPT_DATA(i).RPTBQCD,
										  ZMRRPT_DATA(i).RPTANDT,
										  ZMRRPT_DATA(i).RPTABTM,
										  ZMRRPT_DATA(i).RPTBRCD,
                                          ZMRRPT_DATA(i).RPTB6IG);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRRPT_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRRPT00',ZMRRPT_DATA(sql%bulk_exceptions(beindx).error_index).RPTBTCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRRPT_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_ZMRRPT00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRRPT00_TMP;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TMP_ZMRRPT00', 'TMP_ZMRRPT00', SYSTIMESTAMP,V_APP.RPTBTCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRRPT00', 'TMP_ZMRRPT00', SYSTIMESTAMP,V_APP.RPTBTCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRRPT00', 'TMP_ZMRRPT00', SYSTIMESTAMP,V_APP.RPTBTCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_ZMRRPT00;

-- Procedure for RE-RUN SQL LOADER - ZMRRPT00 <ENDS> Here

--- Procedure for RE-RUN SQL LOADER - MSTPOLDB < STARTS > Here
PROCEDURE DM_MSTPOLDB(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_MSTPOLDB%ROWTYPE;
          MSTPOLDB_DATA IG_ARRAY;
          V_APP TMP_MSTPOLDB%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_MSTPOLDB_TMP IS
               SELECT * FROM TMP_MSTPOLDB;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM MSTPOLDB WHERE EXISTS (SELECT 'X' FROM TMP_MSTPOLDB DT WHERE DT.PJENDCD = MSTPOLDB.PJENDCD AND DT.PRODCD = MSTPOLDB.PRODCD);
         -- Delete the records for all the records exists in MSTPOLDB for Delta Load
           OPEN CUR_MSTPOLDB_TMP;
           LOOP
            FETCH CUR_MSTPOLDB_TMP BULK COLLECT INTO MSTPOLDB_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + MSTPOLDB_DATA.COUNT;
           FORALL i IN 1..MSTPOLDB_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO MSTPOLDB(
                                        PJENDCD,
										ENDCD,
										PRODCD,
										ZCCDE,
										ZCONSGNM,
										ZBLADCD,
										PJMPLNUM
                                        )
                                 VALUES
                                          (
                                        MSTPOLDB_DATA(i).PJENDCD,
										MSTPOLDB_DATA(i).ENDCD,
										MSTPOLDB_DATA(i).PRODCD,
										MSTPOLDB_DATA(i).ZCCDE,
										MSTPOLDB_DATA(i).ZCONSGNM,
										MSTPOLDB_DATA(i).ZBLADCD,
										MSTPOLDB_DATA(i).PJMPLNUM
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + MSTPOLDB_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_MSTPOLDB',MSTPOLDB_DATA(sql%bulk_exceptions(beindx).error_index).PJENDCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=MSTPOLDB_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_MSTPOLDB_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_MSTPOLDB_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_MSTPOLDB', 'TMP_MSTPOLDB', SYSTIMESTAMP,V_APP.PJENDCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_MSTPOLDB', 'TMP_MSTPOLDB', SYSTIMESTAMP,V_APP.PJENDCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_MSTPOLDB', 'TMP_MSTPOLDB', SYSTIMESTAMP,V_APP.PJENDCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_MSTPOLDB;

--- Procedure for RE_RUN SQL LOADER - MSTPOLDB <ENDS > Here

--- Procedure for RE_RUN SQL LOADER - MSTPOLGRP < STARTS > Here
PROCEDURE DM_MSTPOLGRP(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_MSTPOLGRP%ROWTYPE;
          MSTPOLGRP_DATA IG_ARRAY;
          V_APP TMP_MSTPOLGRP%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_MSTPOLGRP_TMP IS
               SELECT * FROM TMP_MSTPOLGRP;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM MSTPOLGRP WHERE EXISTS (SELECT 'X' FROM TMP_MSTPOLGRP DT WHERE DT.GRUPNUM = MSTPOLGRP.GRUPNUM);
         -- Delete the records for all the records exists in MSTPOLGRP for Delta Load
           OPEN CUR_MSTPOLGRP_TMP;
           LOOP
            FETCH CUR_MSTPOLGRP_TMP BULK COLLECT INTO MSTPOLGRP_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + MSTPOLGRP_DATA.COUNT;
           FORALL i IN 1..MSTPOLGRP_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO MSTPOLGRP(
                                       CLNTNUM,
									   GRUPNUM
                                        )
                                 VALUES
                                          (
                                        MSTPOLGRP_DATA(i).CLNTNUM,
									    MSTPOLGRP_DATA(i).GRUPNUM
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + MSTPOLGRP_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_MSTPOLGRP',MSTPOLGRP_DATA(sql%bulk_exceptions(beindx).error_index).GRUPNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=MSTPOLGRP_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_MSTPOLGRP_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_MSTPOLGRP_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_MSTPOLGRP', 'TMP_MSTPOLGRP', SYSTIMESTAMP,V_APP.GRUPNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_MSTPOLGRP', 'TMP_MSTPOLGRP', SYSTIMESTAMP,V_APP.GRUPNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_MSTPOLGRP', 'TMP_MSTPOLGRP', SYSTIMESTAMP,V_APP.GRUPNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_MSTPOLGRP;
--- Procedure for RE_RUN SQL LOADER - MSTPOLGRP <ENDS > Here

--- Procedure for RE_RUN SQL LOADER - TITDMGMASPOL < START > Here

PROCEDURE DM_TITDMGMASPOL(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGMASPOL%ROWTYPE;
          TITDMGMASPOL_DATA IG_ARRAY;
          V_APP TMP_TITDMGMASPOL%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_TITDMGMASPOL_TMP IS
               SELECT * FROM TMP_TITDMGMASPOL;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGMASPOL WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGMASPOL DT WHERE DT.CHDRNUM = TITDMGMASPOL.CHDRNUM);
         -- Delete the records for all the records exists in TITDMGMASPOL for Delta Load
           OPEN CUR_TITDMGMASPOL_TMP;
           LOOP
            FETCH CUR_TITDMGMASPOL_TMP BULK COLLECT INTO TITDMGMASPOL_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + TITDMGMASPOL_DATA.COUNT;
           FORALL i IN 1..TITDMGMASPOL_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGMASPOL(
                                       CHDRNUM,
									   CNTTYPE,
									   STATCODE,
									   ZAGPTNUM,
									   CCDATE,
									   CRDATE,
									   RPTFPST,
									   ZENDCDE,
									   RRA2IG,
									   B8TJIG,
									   ZBLNKPOL,
									   B8O9NB,
									   B8GPST,
									   B8GOST,
									   ZNBALTPR,
									   CANCELDT,
									   EFFDATE,
									   PNDATE,
									   OCCDATE,
									   INSENDTE,
									   ZPENDDT,
									   ZCCDE,
									   ZCONSGNM,
									   ZBLADCD,
									   CLNTNUM
                                        )
                                 VALUES
                                          (
                                       TITDMGMASPOL_DATA(i).CHDRNUM,
									   TITDMGMASPOL_DATA(i).CNTTYPE,
									   TITDMGMASPOL_DATA(i).STATCODE,
									   TITDMGMASPOL_DATA(i).ZAGPTNUM,
									   TITDMGMASPOL_DATA(i).CCDATE,
									   TITDMGMASPOL_DATA(i).CRDATE,
									   TITDMGMASPOL_DATA(i).RPTFPST,
									   TITDMGMASPOL_DATA(i).ZENDCDE,
									   TITDMGMASPOL_DATA(i).RRA2IG,
									   TITDMGMASPOL_DATA(i).B8TJIG,
									   TITDMGMASPOL_DATA(i).ZBLNKPOL,
									   TITDMGMASPOL_DATA(i).B8O9NB,
									   TITDMGMASPOL_DATA(i).B8GPST,
									   TITDMGMASPOL_DATA(i).B8GOST,
									   TITDMGMASPOL_DATA(i).ZNBALTPR,
									   TITDMGMASPOL_DATA(i).CANCELDT,
									   TITDMGMASPOL_DATA(i).EFFDATE,
									   TITDMGMASPOL_DATA(i).PNDATE,
									   TITDMGMASPOL_DATA(i).OCCDATE,
									   TITDMGMASPOL_DATA(i).INSENDTE,
									   TITDMGMASPOL_DATA(i).ZPENDDT,
									   TITDMGMASPOL_DATA(i).ZCCDE,
									   TITDMGMASPOL_DATA(i).ZCONSGNM,
									   TITDMGMASPOL_DATA(i).ZBLADCD,
									   TITDMGMASPOL_DATA(i).CLNTNUM
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + TITDMGMASPOL_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGMASPOL',TITDMGMASPOL_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=TITDMGMASPOL_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_TITDMGMASPOL_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGMASPOL_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGMASPOL', 'TMP_TITDMGMASPOL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGMASPOL', 'TMP_TITDMGMASPOL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGMASPOL', 'TMP_TITDMGMASPOL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_TITDMGMASPOL;

-- Procedure for RE_RUN SQL LOADER - TITDMGMASPOL < ENDS > Here  

-- Procedure for RE_RUN SQL LOADER - TITDMGENDCTPF < STARTS > Here

PROCEDURE DM_TITDMGENDCTPF(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGENDCTPF%ROWTYPE;
          TITDMGENDCTPF_DATA IG_ARRAY;
          V_APP TMP_TITDMGENDCTPF%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_TITDMGENDCTPF_TMP IS
               SELECT * FROM TMP_TITDMGENDCTPF;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGENDCTPF WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGENDCTPF DT WHERE DT.CHDRNUM = TITDMGENDCTPF.CHDRNUM);
         -- Delete the records for all the records exists in TITDMGENDCTPF for Delta Load
           OPEN CUR_TITDMGENDCTPF_TMP;
           LOOP
            FETCH CUR_TITDMGENDCTPF_TMP BULK COLLECT INTO TITDMGENDCTPF_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + TITDMGENDCTPF_DATA.COUNT;
           FORALL i IN 1..TITDMGENDCTPF_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGENDCTPF(
                                                CHDRNUM,
											    ZCRDTYPE,
											    ZCARDDC,
											    ZCNBRFRM,
											    ZCNBRTO,
												ZMSTID,
												ZMSTSNME,
												ZMSTIDV,
												ZMSTSNMEV
                                        )
                                 VALUES
                                          (
                                       TITDMGENDCTPF_DATA(i).CHDRNUM,
									   TITDMGENDCTPF_DATA(i).ZCRDTYPE,
									   TITDMGENDCTPF_DATA(i).ZCARDDC,
									   TITDMGENDCTPF_DATA(i).ZCNBRFRM,
									   TITDMGENDCTPF_DATA(i).ZCNBRTO,
									   TITDMGENDCTPF_DATA(i).ZMSTID,
									   TITDMGENDCTPF_DATA(i).ZMSTSNME,
									   TITDMGENDCTPF_DATA(i).ZMSTIDV,
									   TITDMGENDCTPF_DATA(i).ZMSTSNMEV
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + TITDMGENDCTPF_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGENDCTPF',TITDMGENDCTPF_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=TITDMGENDCTPF_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_TITDMGENDCTPF_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGENDCTPF_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGENDCTPF', 'TMP_TITDMGENDCTPF', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGENDCTPF', 'TMP_TITDMGENDCTPF', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGENDCTPF', 'TMP_TITDMGENDCTPF', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_TITDMGENDCTPF;

-- Procedure for RE_RUN SQL LOADER - TITDMGENDCTPF < ENDS > Here      

--- Procedure for RE_RUN SQL LOADER - TITDMGINSSTPL <STARTS> Here
PROCEDURE DM_TITDMGINSSTPL(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_TITDMGINSSTPL%ROWTYPE;
          TITDMGINSSTPL_DATA IG_ARRAY;
          V_APP TMP_TITDMGINSSTPL%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_TITDMGINSSTPL_TMP IS
               SELECT * FROM TMP_TITDMGINSSTPL;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGINSSTPL WHERE EXISTS (SELECT 'X' FROM TMP_TITDMGINSSTPL DT WHERE DT.CHDRNUM = TITDMGINSSTPL.CHDRNUM);
         -- Delete the records for all the records exists in TITDMGINSSTPL for Delta Load
           OPEN CUR_TITDMGINSSTPL_TMP;
           LOOP
            FETCH CUR_TITDMGINSSTPL_TMP BULK COLLECT INTO TITDMGINSSTPL_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + TITDMGINSSTPL_DATA.COUNT;
           FORALL i IN 1..TITDMGINSSTPL_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO TITDMGINSSTPL(
                                              CHDRNUM,
											  PLNSETNUM,
											  ZINSTYPE1,
											  ZINSTYPE2,
											  ZINSTYPE3,
											  ZINSTYPE4
                                        )
                                 VALUES
                                          (
                                       TITDMGINSSTPL_DATA(i).CHDRNUM,
									   TITDMGINSSTPL_DATA(i).PLNSETNUM,
									   TITDMGINSSTPL_DATA(i).ZINSTYPE1,
									   TITDMGINSSTPL_DATA(i).ZINSTYPE2,
									   TITDMGINSSTPL_DATA(i).ZINSTYPE3,
									   TITDMGINSSTPL_DATA(i).ZINSTYPE4
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + TITDMGINSSTPL_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_TITDMGINSSTPL',TITDMGINSSTPL_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=TITDMGINSSTPL_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_TITDMGINSSTPL_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_TITDMGINSSTPL_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGINSSTPL', 'TMP_TITDMGINSSTPL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_TITDMGINSSTPL', 'TMP_TITDMGINSSTPL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_TITDMGINSSTPL', 'TMP_TITDMGINSSTPL', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_TITDMGINSSTPL;
----- Procedure for RE_RUN SQL LOADER - TITDMGINSSTPL <ENDS> Here

-- Procedure for RE_RUN SQL LOADER - ZMRULA00 < START> Here
PROCEDURE DM_ZMRULA00(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_ZMRULA00%ROWTYPE;
          ZMRULA00_DATA IG_ARRAY;
          V_APP TMP_ZMRULA00%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_ZMRULA00_TMP IS
               SELECT * FROM TMP_ZMRULA00;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM ZMRULA00 WHERE EXISTS (SELECT 'X' FROM TMP_ZMRULA00 DT WHERE DT.ulac6cd = ZMRULA00.ulac6cd and DT.ulac7cd = ZMRULA00.ulac7cd );


         -- Delete the records for all the records exists in ZMRULA00 for Delta Load
           OPEN CUR_ZMRULA00_TMP;
           LOOP
            FETCH CUR_ZMRULA00_TMP BULK COLLECT INTO ZMRULA00_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + ZMRULA00_DATA.COUNT;
           FORALL i IN 1..ZMRULA00_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO ZMRULA00(
                                      ULAC6CD,
									  ULAC7CD,
									  ULANWLT,   
									  ULAB0NB,        
									  ULABLST, 
									  ULAYOB1,
									  ULAYOB2,
									  ULAYOB3,
									  ULAYOB4,
									  ULAYOB5,
								      ULABOCD,
									  ULABPCD,
									  ULAAMDT, 
									  ULAAATM,     
									  ULBQCD,
									  ULABOCDU,
									  ULABPCDU,
									  ULAANDT,       
									  ULAABTM,        
									  ULBRCD,
									  ULAB6IG
                                        )
                                 VALUES
                                          (
                                       ZMRULA00_DATA(i).ULAC6CD,
									   ZMRULA00_DATA(i).ULAC7CD,
									   ZMRULA00_DATA(i).ULANWLT,   
									   ZMRULA00_DATA(i).ULAB0NB,        
									   ZMRULA00_DATA(i).ULABLST, 
									   ZMRULA00_DATA(i).ULAYOB1,
									   ZMRULA00_DATA(i).ULAYOB2,
									   ZMRULA00_DATA(i).ULAYOB3,
									   ZMRULA00_DATA(i).ULAYOB4,
									   ZMRULA00_DATA(i).ULAYOB5,
								       ZMRULA00_DATA(i).ULABOCD,
									   ZMRULA00_DATA(i).ULABPCD,
									   ZMRULA00_DATA(i).ULAAMDT, 
									   ZMRULA00_DATA(i).ULAAATM,     
									   ZMRULA00_DATA(i).ULBQCD,
									   ZMRULA00_DATA(i).ULABOCDU,
									   ZMRULA00_DATA(i).ULABPCDU,
									   ZMRULA00_DATA(i).ULAANDT,       
									   ZMRULA00_DATA(i).ULAABTM,        
									   ZMRULA00_DATA(i).ULBRCD,
									   ZMRULA00_DATA(i).ULAB6IG
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + ZMRULA00_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_ZMRULA00',ZMRULA00_DATA(sql%bulk_exceptions(beindx).error_index).ulac6cd,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=ZMRULA00_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_ZMRULA00_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_ZMRULA00_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_ZMRULA00', 'TMP_ZMRULA00', SYSTIMESTAMP,V_APP.ulac6cd,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_ZMRULA00', 'TMP_ZMRULA00', SYSTIMESTAMP,V_APP.ulac6cd,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_ZMRULA00', 'TMP_ZMRULA00', SYSTIMESTAMP,V_APP.ulac6cd,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_ZMRULA00;
--- Procedure for RE_RUN SQL LOADER - ZMRULA00 <ENDS> Here

--- Procedure for RE_RUN SQL LOADER - SOLICITATION_FLG_LIST < STARTS > Here
PROCEDURE DM_SOLICITATION_FLG_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_SOLICITATION_FLG_LIST%ROWTYPE;
          SOLICITATION_FLG_LIST_DATA IG_ARRAY;
          V_APP SOLICITATION_FLG_LIST%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_SOLICITATION_FLG_LIST_TMP IS
               SELECT * FROM TMP_SOLICITATION_FLG_LIST;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM SOLICITATION_FLG_LIST WHERE EXISTS (SELECT 'X' FROM TMP_SOLICITATION_FLG_LIST DT WHERE DT.PRODUCT_CODE = SOLICITATION_FLG_LIST.PRODUCT_CODE);
         -- Delete the records for all the records exists in SOLICITATION_FLG_LIST for Delta Load
           OPEN CUR_SOLICITATION_FLG_LIST_TMP;
           LOOP
            FETCH CUR_SOLICITATION_FLG_LIST_TMP BULK COLLECT INTO SOLICITATION_FLG_LIST_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + SOLICITATION_FLG_LIST_DATA.COUNT;
           FORALL i IN 1..SOLICITATION_FLG_LIST_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO SOLICITATION_FLG_LIST(
                                                PRODUCT_CODE
                                        )
                                 VALUES
                                          (
                                       SOLICITATION_FLG_LIST_DATA(i).PRODUCT_CODE
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + SOLICITATION_FLG_LIST_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_SOLICITATION_FLG_LIST',SOLICITATION_FLG_LIST_DATA(sql%bulk_exceptions(beindx).error_index).PRODUCT_CODE,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=SOLICITATION_FLG_LIST_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_SOLICITATION_FLG_LIST_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_SOLICITATION_FLG_LIST_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_SOLICITATION_FLG_LIST', 'TMP_SOLICITATION_FLG_LIST', SYSTIMESTAMP,V_APP.PRODUCT_CODE,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_SOLICITATION_FLG_LIST', 'TMP_SOLICITATION_FLG_LIST', SYSTIMESTAMP,V_APP.PRODUCT_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_SOLICITATION_FLG_LIST', 'TMP_SOLICITATION_FLG_LIST', SYSTIMESTAMP,V_APP.PRODUCT_CODE,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_SOLICITATION_FLG_LIST;
-----Procedure for RE_RUN SQL LOADER - SOLICITATION_FLG_LIST < ENDS > Here
--- Procedure for RE_RUN SQL LOADER - KANA_ADDRESS_LIST < STARTS > Here
PROCEDURE DM_KANA_ADDRESS_LIST(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_KANA_ADDRESS_LIST%ROWTYPE;
          KANA_ADDRESS_LIST_DATA IG_ARRAY;
          V_APP KANA_ADDRESS_LIST%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_KANA_ADDRESS_LIST_TMP IS
               SELECT * FROM TMP_KANA_ADDRESS_LIST;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
        DELETE FROM KANA_ADDRESS_LIST WHERE EXISTS (SELECT 'X' FROM TMP_KANA_ADDRESS_LIST DT WHERE DT.POSTALCD = KANA_ADDRESS_LIST.POSTALCD);
         -- Delete the records for all the records exists in KANA_ADDRESS_LIST for Delta Load
           OPEN CUR_KANA_ADDRESS_LIST_TMP;
           LOOP
            FETCH CUR_KANA_ADDRESS_LIST_TMP BULK COLLECT INTO KANA_ADDRESS_LIST_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + KANA_ADDRESS_LIST_DATA.COUNT;
           FORALL i IN 1..KANA_ADDRESS_LIST_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO KANA_ADDRESS_LIST(
                                                POSTALCD,
                                                KANA1,
                                                KANA2
                                        )
                                 VALUES
                                          (
                                       KANA_ADDRESS_LIST_DATA(i).POSTALCD,
                                       KANA_ADDRESS_LIST_DATA(i).KANA1,
                                       KANA_ADDRESS_LIST_DATA(i).KANA2
										);

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + KANA_ADDRESS_LIST_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_KANA_ADDRESS_LIST',KANA_ADDRESS_LIST_DATA(sql%bulk_exceptions(beindx).error_index).POSTALCD,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=KANA_ADDRESS_LIST_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_KANA_ADDRESS_LIST_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_KANA_ADDRESS_LIST_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_KANA_ADDRESS_LIST', 'TMP_KANA_ADDRESS_LIST', SYSTIMESTAMP,V_APP.POSTALCD,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_KANA_ADDRESS_LIST', 'TMP_KANA_ADDRESS_LIST', SYSTIMESTAMP,V_APP.POSTALCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_KANA_ADDRESS_LIST', 'TMP_KANA_ADDRESS_LIST', SYSTIMESTAMP,V_APP.POSTALCD,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_KANA_ADDRESS_LIST;
-----Procedure for RE_RUN SQL LOADER - KANA_ADDRESS_LISTT < ENDS > Here
--- Procedure for RE_RUN SQL LOADER - SPPLANCONVERTION < STARTS > Here
PROCEDURE DM_SPPLANCONVERTION(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_SPPLANCONVERTION%ROWTYPE;
          SPPLANCONVERTION_DATA IG_ARRAY;
          V_APP SPPLANCONVERTION%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_SPPLANCONVERTION_TMP IS
               SELECT * FROM TMP_SPPLANCONVERTION;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
        DELETE FROM SPPLANCONVERTION WHERE EXISTS (SELECT 'X' FROM TMP_SPPLANCONVERTION DT WHERE DT.OLDZSALPLAN = SPPLANCONVERTION.OLDZSALPLAN);
         -- Delete the records for all the records exists in SPPLANCONVERTION for Delta Load
           OPEN CUR_SPPLANCONVERTION_TMP;
           LOOP
            FETCH CUR_SPPLANCONVERTION_TMP BULK COLLECT INTO SPPLANCONVERTION_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + SPPLANCONVERTION_DATA.COUNT;
           FORALL i IN 1..SPPLANCONVERTION_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO SPPLANCONVERTION(
                                               OLDZSALPLAN,
                                               NEWZSALPLAN
                                                                         )
                                 VALUES
                                          (
                                       SPPLANCONVERTION_DATA(i).OLDZSALPLAN,
                                       SPPLANCONVERTION_DATA(i).NEWZSALPLAN
                                     );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + SPPLANCONVERTION_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_SPPLANCONVERTION',SPPLANCONVERTION_DATA(sql%bulk_exceptions(beindx).error_index).OLDZSALPLAN,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=SPPLANCONVERTION_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_SPPLANCONVERTION_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_SPPLANCONVERTION_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_SPPLANCONVERTION', 'TMP_SPPLANCONVERTION', SYSTIMESTAMP,V_APP.OLDZSALPLAN,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_SPPLANCONVERTION', 'TMP_SPPLANCONVERTION', SYSTIMESTAMP,V_APP.OLDZSALPLAN,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_SPPLANCONVERTION', 'TMP_SPPLANCONVERTION', SYSTIMESTAMP,V_APP.OLDZSALPLAN,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_SPPLANCONVERTION;
-----Procedure for RE_RUN SQL LOADER - SPPLANCONVERTION < ENDS > Here
--- Procedure for RE_RUN SQL LOADER - DMPR1 < STARTS > Here
PROCEDURE DM_DMPR1(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_DMPR1%ROWTYPE;
          DMPR1_DATA IG_ARRAY;
          V_APP DMPR1%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_DMPR1_TMP IS
               SELECT * FROM TMP_DMPR1;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
        DELETE FROM DMPR1 WHERE EXISTS (SELECT 'X' FROM TMP_DMPR1 DT WHERE DT.REFNUM = DMPR1.REFNUM);
         -- Delete the records for all the records exists in DMPR1 for Delta Load
           OPEN CUR_DMPR1_TMP;
           LOOP
            FETCH CUR_DMPR1_TMP BULK COLLECT INTO DMPR1_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + DMPR1_DATA.COUNT;
           FORALL i IN 1..DMPR1_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO DMPR1(
                                        REFNUM,
										SEQNO,  
										CURRTO,   
										BANKCD, 
										BRANCHCD,
										FACTHOUS,
										BANKACCKEY,
										CRDTCARD,
									    BANKACCDSC, 
										BNKACTYP,
										TRANSHIST
                                        )
                                 VALUES
                                          (
                                       DMPR1_DATA(i).REFNUM,
									   DMPR1_DATA(i).SEQNO,  
									   DMPR1_DATA(i).CURRTO,   
									   DMPR1_DATA(i).BANKCD, 
									   DMPR1_DATA(i).BRANCHCD,
									   DMPR1_DATA(i).FACTHOUS,
									   DMPR1_DATA(i).BANKACCKEY,
									   DMPR1_DATA(i).CRDTCARD,
									   DMPR1_DATA(i).BANKACCDSC, 
									   DMPR1_DATA(i).BNKACTYP,
									  DMPR1_DATA(i).TRANSHIST
                                     );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + DMPR1_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_DMPR1',DMPR1_DATA(sql%bulk_exceptions(beindx).error_index).REFNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=DMPR1_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_DMPR1_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_DMPR1_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_DMPR1', 'TMP_DMPR1', SYSTIMESTAMP,V_APP.REFNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_DMPR1', 'TMP_DMPR1', SYSTIMESTAMP,V_APP.REFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_DMPR1', 'TMP_DMPR1', SYSTIMESTAMP,V_APP.REFNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_DMPR1;
-----Procedure for RE_RUN SQL LOADER - DMPR1 < ENDS > Here

PROCEDURE DM_MIPHSTDB(p_array_size IN PLS_INTEGER DEFAULT 1000)
IS
          TYPE IG_ARRAY IS TABLE OF TMP_MIPHSTDB%ROWTYPE;
          MIPHSTDB_DATA IG_ARRAY;
          V_APP MIPHSTDB%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          V_INPUT_COUNT NUMBER(10);
          V_OUTPUT_COUNT NUMBER(10);
          l_OUTPUT_COUNT NUMBER:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          CURSOR CUR_MIPHSTDB_TMP IS
               SELECT * FROM TMP_MIPHSTDB;
       BEGIN
         V_INPUT_COUNT:=0;
         V_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;
         l_OUTPUT_COUNT:=0;
         IG_STARTTIME := SYSTIMESTAMP;
             V_ERRORMSG:= 'For Delta Load:';
        DELETE FROM MIPHSTDB WHERE EXISTS (SELECT 'X' FROM TMP_MIPHSTDB DT WHERE DT.CHDRNUM = MIPHSTDB.CHDRNUM);
         -- Delete the records for all the records exists in MIPHSTDB for Delta Load
           OPEN CUR_MIPHSTDB_TMP;
           LOOP
            FETCH CUR_MIPHSTDB_TMP BULK COLLECT INTO MIPHSTDB_DATA ;--LIMIT p_array_size;
            V_ERRORMSG:='Before Bulk Insert:';
         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + MIPHSTDB_DATA.COUNT;
           FORALL i IN 1..MIPHSTDB_DATA.COUNT SAVE EXCEPTIONS
                     INSERT INTO MIPHSTDB(
                                       CHDRNUM,
                                       MBRNO,
                                       ZINSTYPE,
                                       ZAPIRNO,
                                       FULLKANJINAME
                                        )
                                 VALUES
                                          (
                                       MIPHSTDB_DATA(i).CHDRNUM,
                                       MIPHSTDB_DATA(i).MBRNO,
                                       MIPHSTDB_DATA(i).ZINSTYPE,
                                       MIPHSTDB_DATA(i).ZAPIRNO,
                                       MIPHSTDB_DATA(i). FULLKANJINAME
                                     );

         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + MIPHSTDB_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TMP_MIPHSTDB',MIPHSTDB_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=MIPHSTDB_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_MIPHSTDB_TMP%NOTFOUND;
           END LOOP;
        CLOSE CUR_MIPHSTDB_TMP;
V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';
            temp_no := IG_CONTROL_LOG('TMP_MIPHSTDB', 'TMP_MIPHSTDB', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);
        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TMP_MIPHSTDB', 'TMP_MIPHSTDB', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;
       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TMP_MIPHSTDB', 'TMP_MIPHSTDB', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;
       END DM_MIPHSTDB;
-----Procedure for RE_RUN SQL LOADER - MIPHSTDB < ENDS > Here
END DM_RE_RUN_TMP;
