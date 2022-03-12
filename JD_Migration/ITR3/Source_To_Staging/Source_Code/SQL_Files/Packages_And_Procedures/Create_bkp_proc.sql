create or replace PROCEDURE                           "CREATE_BKUP" (v_tblname in varchar2)
authid current_user
IS
tb_str varchar2(1000):= null;
BEGIN
    IF v_tblname = 'ZMRAP00' THEN
       tb_str:='CREATE TABLE ZMRAP00_'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRAP00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_RERUN_ZMRAP00(1000);
    ELSIF v_tblname = 'TRAN_STATUS_CODE' THEN
       tb_str:='CREATE TABLE TRAN_STATUS_CODE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TRAN_STATUS_CODE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TRAN_STATUS_CODE(1000);
    ELSIF v_tblname = 'ZMRAT00' THEN
       tb_str:='CREATE TABLE ZMRAT00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRAT00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRAT00(1000);
    ELSIF v_tblname = 'ZMRLH00' THEN
       tb_str:='CREATE TABLE ZMRLH00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRLH00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRLH00(1000);
   ELSIF v_tblname = 'ZMRRPT00' THEN
       tb_str:='CREATE TABLE ZMRRPT00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRRPT00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRRPT00(1000);
    ELSIF v_tblname = 'ZMRIS00' THEN
       tb_str:='CREATE TABLE ZMRIS00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRIS00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRIS00(1000);
    ELSIF v_tblname = 'ZMRISA00' THEN
       tb_str:='CREATE TABLE ZMRISA00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRISA00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRISA00(1000);
    ELSIF v_tblname = 'ZMRFCT00' THEN
       tb_str:='CREATE TABLE ZMRFCT00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRFCT00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRFCT00(1000);
    ELSIF v_tblname = 'ZMRIC00' THEN
       tb_str:='CREATE TABLE ZMRIC00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRIC00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRIC00(1000);
    ELSIF v_tblname = 'ZMRRS00' THEN
       tb_str:='CREATE TABLE ZMRRS00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRRS00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRRS00(1000);
    ELSIF v_tblname = 'ZMREI00' THEN
       tb_str:='CREATE TABLE ZMREI00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRRS00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMREI00(1000);
    ELSIF v_tblname = 'SPLN' THEN
       tb_str:='CREATE TABLE SPLN'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM SPLN';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_SPLN(1000);
    ELSIF v_tblname = 'TITDMGAGENTPJ' THEN
       tb_str:='CREATE TABLE TITDMGAGENTPJ'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGAGENTPJ';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGAGENTPJ(1000);
    ELSIF v_tblname = 'GRP_POLICY_FREE' THEN
       tb_str:='CREATE TABLE GRP_POLICY_FREE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM GRP_POLICY_FREE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_GRP_POLICY_FREE(1000);

    ELSIF v_tblname = 'LETTER_CODE' THEN
       tb_str:='CREATE TABLE LETTER_CODE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM LETTER_CODE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_LETTER_CODE(1000);

    ELSIF v_tblname = 'COL_FEE_LST' THEN
       tb_str:='CREATE TABLE COL_FEE_LST'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM COL_FEE_LST';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_COL_FEE_LST(1000);

    ELSIF v_tblname = 'DMPR' THEN
       tb_str:='CREATE TABLE DMPR'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM DMPR';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_DMPR(1000);
       
           ELSIF v_tblname = 'DMPR1' THEN
       tb_str:='CREATE TABLE DMPR1'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM DMPR1';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_DMPR1(1000);

    ELSIF v_tblname = 'DECLINE_REASON_CODE' THEN
       tb_str:='CREATE TABLE DECLINE_REASON_CODE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM DECLINE_REASON_CODE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_DECLINE_REASON_CODE(1000);

    ELSIF v_tblname = 'CARD_ENDORSER_LIST' THEN
       tb_str:='CREATE TABLE CARD_ENDORSER_LIST'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM CARD_ENDORSER_LIST';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_CARD_ENDORSER_LIST(1000);

    ELSIF v_tblname = 'ALTER_REASON_CODE' THEN
       tb_str:='CREATE TABLE ALTER_REASON_CODE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ALTER_REASON_CODE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ALTER_REASON_CODE(1000);

    ELSIF v_tblname = 'BTDATE_PTDATE_LIST' THEN
       tb_str:='CREATE TABLE BTDATE_PTDATE_LIST'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM BTDATE_PTDATE_LIST';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_BTDATE_PTDATE_LIST(1000);

    ELSIF v_tblname = 'DSH_CODE_REF' THEN
       tb_str:='CREATE TABLE DSH_CODE_REF'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM DSH_CODE_REF';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_DSH_CODE_REF(1000);

    ELSIF v_tblname = 'TITDMGCLNTCORP' THEN
       tb_str:='CREATE TABLE TITDMGCLNTCORP'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGCLNTCORP';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGCLNTCORP(1000);

    ELSIF v_tblname = 'TITDMGCAMPCDE' THEN
       tb_str:='CREATE TABLE TITDMGCAMPCDE'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGCAMPCDE';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGCAMPCDE(1000);


    ELSIF v_tblname = 'TITDMGSALEPLN1' THEN
       tb_str:='CREATE TABLE TITDMGSALEPLN1'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGSALEPLN1';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGSALEPLN1(1000);


    ELSIF v_tblname = 'TITDMGSALEPLN2' THEN
       tb_str:='CREATE TABLE TITDMGSALEPLN2'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGSALEPLN2';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGSALEPLN2(1000);


    ELSIF v_tblname = 'TITDMGBILL1' THEN
       tb_str:='CREATE TABLE TITDMGBILL1'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGBILL1';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGBILL1(1000);

    ELSIF v_tblname = 'TITDMGBILL2' THEN
       tb_str:='CREATE TABLE TITDMGBILL2'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGBILL2';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGBILL2(1000);


    ELSIF v_tblname = 'TITDMGREF1' THEN
       tb_str:='CREATE TABLE TITDMGREF1'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGREF1';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGREF1(1000);

    ELSIF v_tblname = 'TITDMGREF2' THEN
       tb_str:='CREATE TABLE TITDMGREF2'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGREF2';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGREF2(1000);

    ELSIF v_tblname = 'TITDMGMBRINDP3' THEN
       tb_str:='CREATE TABLE TITDMGMBRINDP3'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGMBRINDP3';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGMBRINDP3(1000);

    ELSIF v_tblname = 'TITDMGCOLRES' THEN
       tb_str:='CREATE TABLE PJ_TITDMGCOLRES'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM PJ_TITDMGCOLRES';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_PJ_TITDMGCOLRES(1000);
       
           ELSIF v_tblname = 'MSTPOLDB' THEN
       tb_str:='CREATE TABLE MSTPOLDB'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM MSTPOLDB';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_MSTPOLDB(1000);
       
                  ELSIF v_tblname = 'MSTPOLGRP' THEN
       tb_str:='CREATE TABLE MSTPOLGRP'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM MSTPOLGRP';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_MSTPOLGRP(1000);
       
                  ELSIF v_tblname = 'TITDMGMASPOL' THEN
       tb_str:='CREATE TABLE TITDMGMASPOL'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGMASPOL';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGMASPOL(1000);
       
                  ELSIF v_tblname = 'TITDMGENDCTPF' THEN
       tb_str:='CREATE TABLE TITDMGENDCTPF'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGENDCTPF';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGENDCTPF(1000);
       
                  ELSIF v_tblname = 'TITDMGINSSTPL' THEN
       tb_str:='CREATE TABLE TITDMGINSSTPL'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM TITDMGINSSTPL';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_TITDMGINSSTPL(1000);
       
                 ELSIF v_tblname = 'ZMRULA00' THEN
        tb_str:='CREATE TABLE ZMRULA00'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM ZMRULA00';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_ZMRULA00(1000);
       
        ELSIF v_tblname = 'KANA_ADDRESS_LIST' THEN
        tb_str:='CREATE TABLE KANA_ADDRESS_LIST'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM KANA_ADDRESS_LIST';
       EXECUTE IMMEDIATE tb_str;
       
       DM_RE_RUN_TMP.DM_KANA_ADDRESS_LIST(1000);
       
          ELSIF v_tblname = 'SPPLANCONVERTION' THEN
        tb_str:='CREATE TABLE SPPLANCONVERTION'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM SPPLANCONVERTION';
       EXECUTE IMMEDIATE tb_str;
        DM_RE_RUN_TMP.DM_SPPLANCONVERTION(1000);

        ELSIF v_tblname = 'SOLICITATION_FLG_LIST' THEN
        tb_str:='CREATE TABLE SOLICITATION_FLG_LIST'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM SOLICITATION_FLG_LIST';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_SOLICITATION_FLG_LIST(1000);
      
       
        ELSIF v_tblname = 'MIPHSTDB' THEN
        tb_str:='CREATE TABLE MIPHSTDB'  || TO_CHAR(SYSDATE, 'MMDDHH24MI')||' AS SELECT * FROM MIPHSTDB';
       EXECUTE IMMEDIATE tb_str;
       DM_RE_RUN_TMP.DM_MIPHSTDB(1000);


    END IF;


EXCEPTION
   WHEN OTHERS THEN
       DM_RE_RUN_TMP.ERROR_LOGS('RE-RUN ERR',SQLCODE,SQLERRM);
END;

/