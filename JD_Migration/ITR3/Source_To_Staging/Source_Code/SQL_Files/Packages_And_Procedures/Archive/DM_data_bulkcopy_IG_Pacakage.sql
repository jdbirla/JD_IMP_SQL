create or replace PACKAGE  DM_data_bulkcopy_IG AS
  FUNCTION IG_CONTROL_LOG(v_src_tabname IN VARCHAR2, v_target_tb IN VARCHAR2, v_endtime IN TIMESTAMP,v_applno IN VARCHAR2,l_errmsg IN VARCHAR2, l_st IN VARCHAR2,v_in_cnt IN NUMBER DEFAULT 0,v_out_cnt IN NUMBER DEFAULT 0) return number;
  PROCEDURE DM_Clntbnk_TO_IG(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Agency_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  --PROCEDURE DM_New_Agency_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Letterhist_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Annualprem_to_ig(v_ig_schema IN VARCHAR2 , p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN VARCHAR2 DEFAULT 'N');
  PROCEDURE DM_Policydishonor_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Clntcorp_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Campaign_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Salesplan1_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Salesplan2_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Billheader1_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Billheader2_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Poltranhist_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Billcolres_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Refundhdr_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Clienthist_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_clntprsn_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Refunddets_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Memberpol_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mastpol1_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mastpol2_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mastpol3_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE ERROR_LOGS(v_jobnm IN VARCHAR2,v_apnum IN VARCHAR2, v_msg IN VARCHAR2);
  PROCEDURE dm_Policytran_transform_to_ig (v_ig_schema    IN   VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_cov_ig (v_ig_schema    IN   VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_apirno_ig(v_ig_schema    IN   VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');
 -- PROCEDURE dm_generate_tranno_ig(v_ig_schema    IN   VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');

END DM_data_bulkcopy_IG;
/

create or replace PACKAGE BODY             dm_data_bulkcopy_ig IS

    v_cnt            NUMBER := 0;
    v_input_count    NUMBER := 0;
    v_output_count   NUMBER := 0;
    ig_starttime     TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;

    PROCEDURE error_logs (
        v_jobnm   IN   VARCHAR2,
        v_apnum   IN   VARCHAR2,
        v_msg     IN   VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO error_log (
            jobname,
            last_appno,
            error_message,
            runtime
        ) VALUES (
            v_jobnm,
            v_apnum,
            v_msg,
            systimestamp
        );

        l_err_flg := 1;
        g_err_flg := 1;
        COMMIT;
    END;

    FUNCTION ig_control_log (
        v_src_tabname   IN   VARCHAR2,
        v_target_tb     IN   VARCHAR2,
        v_endtime       IN   TIMESTAMP,
        v_applno        IN   VARCHAR2,
        l_errmsg        IN   VARCHAR2,
        l_st            IN   VARCHAR2,
        v_in_cnt        IN   NUMBER DEFAULT 0,
        v_out_cnt       IN   NUMBER DEFAULT 0
    ) RETURN NUMBER IS
    BEGIN
        v_cnt := 0;
        SELECT
            COUNT(1)
        INTO v_cnt
        FROM
            ig_copy_cntl_table
        WHERE
            target_table = v_target_tb;

        IF v_cnt > 0 THEN
            UPDATE ig_copy_cntl_table
            SET
                job_detail = 'STAGE4 - COPYING DATA TO IG TABLE',
                source_table = v_src_tabname,
                target_table = v_target_tb,
                start_timestamp = to_char(ig_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                end_timestamp = to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                input_cnt = v_in_cnt,
                output_cnt = v_out_cnt,
                last_processed_appno = v_applno,
                error_msg = l_errmsg,
                status = l_st
            WHERE
                target_table = v_target_tb;

        ELSE
            INSERT INTO ig_copy_cntl_table (
                job_detail,
                source_table,
                target_table,
                start_timestamp,
                end_timestamp,
                input_cnt,
                output_cnt,
                last_processed_appno,
                error_msg,
                status
            ) VALUES (
                'STAGE4 - COPYING DATA TO IG TABLE',
                v_src_tabname,
                v_target_tb,
                to_char(ig_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                v_in_cnt,
                v_out_cnt,
                v_applno,
                l_errmsg,
                l_st
            );

        END IF;

        COMMIT;
        RETURN 0;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('IG_CONTROL_LOG:' || sqlerrm);
            RETURN 1;
    END ig_control_log;


-- Procedure for DM Client Bank IG movement <STARTS> Here

    PROCEDURE dm_clntbnk_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgclntbank%rowtype;
        st_data          ig_array;
        v_app            titdmgclntbank%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnt_rc IS REF CURSOR;
        cur_clntbank     clnt_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
          --CURSOR CUR_CLNTBANK IS
               --SELECT * FROM TITDMGCLNTBANK;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCLNTBANK';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTBANK DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load
        END IF;

       --  EXECUTE IMMEDIATE 'select count(1) from TITDMGCLNTBANK WHERE NOT EXISTS (SELECT ''X'' FROM '||temp_tablename||' TQ WHERE TQ.REFNUM=REFNUM and TQ.SEQNO = SEQNO)' INTO V_INPUT_COUNT;

        sqlstmt := 'SELECT * FROM TITDMGCLNTBANK where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGCLNTBANK.REFNUM and DT.SEQNO = TITDMGCLNTBANK.SEQNO) ORDER BY TITDMGCLNTBANK.REFNUM,TITDMGCLNTBANK.SEQNO'
                   ;
        OPEN cur_clntbank FOR sqlstmt;

        LOOP
            FETCH cur_clntbank BULK COLLECT INTO st_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + st_data.count;
                FORALL i IN 1..st_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
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
                        USING st_data(i).refnum, st_data(i).seqno, st_data(i).currto, st_data(i).bankcd, st_data(i).branchcd, st_data
                        (i).facthous, st_data(i).bankacckey, st_data(i).crdtcard, st_data(i).bankaccdsc, st_data(i).bnkactyp, st_data
                        (i).transhist;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;

                /*EXECUTE IMMEDIATE 'Update '
                                  || temp_tablename
                                  || ' set REFNUM = concat(REFNUM,''00'')';*/
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCLNTBANK_IG', substr(st_data(SQL%bulk_exceptions(beindx).error_index).refnum
                                                               || st_data(SQL%bulk_exceptions(beindx).error_index).seqno, 1, 15),
                                                               substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := st_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_clntbank%notfound;
        END LOOP;

        CLOSE cur_clntbank;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg
            , 'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg
            , 'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCLNTBANK', 'TITDMGCLNTBANK_IG', systimestamp, v_app.refnum || v_app.seqno, v_errormsg
            , 'F', v_input_count, v_output_count);

            return;
    END dm_clntbnk_to_ig;

-- Procedure for DM Client Bank IG movement <ENDS> Here

-- Procedure for DM_Agency_to_ig IG movement <STARTS> Here

    PROCEDURE dm_agency_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE aj_array IS
            TABLE OF titdmgagentpj%rowtype;
        aj_data          aj_array;
        v_app            titdmgagentpj%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE agency_rc IS REF CURSOR;
        cur_agency       agency_rc;
        aj_sqlstmt       VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGAGENTPJ';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGAGENTPJ DT WHERE DT.ZAREFNUM=T.ZAREFNUM)';
            COMMIT;
         -- Delete the records for the records exists in TITDMGAGENTPJ for Delta Load
        END IF;

        aj_sqlstmt := 'SELECT * FROM TITDMGAGENTPJ where not exists ( select ''x'' from '
                      || temp_tablename
                      || ' DT WHERE DT.ZAREFNUM=TITDMGAGENTPJ.ZAREFNUM) ORDER BY TITDMGAGENTPJ.ZAREFNUM';
        OPEN cur_agency FOR aj_sqlstmt;

        LOOP
            FETCH cur_agency BULK COLLECT INTO aj_data;--LIMIT p_array_size;
            v_input_count := v_input_count + aj_data.count;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                FORALL i IN 1..aj_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (ZAREFNUM,
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
                        USING aj_data(i).zarefnum, aj_data(i).agtype, aj_data(i).agntbr, aj_data(i).srdate, aj_data(i).dateend, aj_data
                        (i).stca, aj_data(i).ridesc, aj_data(i).agclsd, aj_data(i).zrepstnm, aj_data(i).zagregno, aj_data(i).cpyname
                        , aj_data(i).ztrgtflg, aj_data(i)."COUNT", aj_data(i).dconsignen, aj_data(i).zconsidt, aj_data(i).zinstyp01
                        , aj_data(i).cmrate01, aj_data(i).zinstyp02, aj_data(i).cmrate02, aj_data(i).zinstyp03, aj_data(i).cmrate03
                        , aj_data(i).zinstyp04, aj_data(i).cmrate04, aj_data(i).zinstyp05, aj_data(i).cmrate05, aj_data(i).zinstyp06
                        , aj_data(i).cmrate06, aj_data(i).zinstyp07, aj_data(i).cmrate07, aj_data(i).zinstyp08, aj_data(i).cmrate08
                        , aj_data(i).zinstyp09, aj_data(i).cmrate09, aj_data(i).zinstyp10, aj_data(i).cmrate10, aj_data(i).clntnum
                        , aj_data(i).zdragnt;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + AJ_DATA.COUNT;
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGAGENTPJ_IG', substr(aj_data(SQL%bulk_exceptions(beindx).error_index).zarefnum, 1, 15),
                        substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := aj_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_agency%notfound;
        END LOOP;

        CLOSE cur_agency;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_agency_to_ig;

-- Procedure for DM_Agency_to_ig IG movement <ENDS> Here

-- Procedure for DM_Letterhist_to_ig IG movement <STARTS> Here

    PROCEDURE dm_letterhist_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgletter%rowtype;
        lh_data          ig_array;
        v_app            titdmgletter%rowtype;
        ig_endtime       TIMESTAMP;
        v_errormsg       VARCHAR2(2000);
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE stletter_rc IS REF CURSOR;
        cur_stletter     stletter_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGLETTER';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGLETTER DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_ZMRLH00 WHERE SUBSTR(LHCUCD,1,8) = DT.CHDRNUM))'
                              ;
            COMMIT;
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGLETTER where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGLETTER.CHDRNUM and DT.LETTYPE = TITDMGLETTER.LETTYPE) ORDER BY TITDMGLETTER.CHDRNUM'
                   ;
        OPEN cur_stletter FOR sqlstmt;

        LOOP
            FETCH cur_stletter BULK COLLECT INTO lh_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + lh_data.count;
                FORALL i IN 1..lh_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( CHDRNUM,
                                            LETTYPE,
                                            LREQDATE,
                                            ZDSPCATG,
                                            ZLETVERN,
                                            ZLETDEST,
                                            ZCOMADDR,
                                            ZLETCAT,
                                            ZAPSTMPD,
                                            ZLETEFDT,
                                            ZLETTRNO 
                                            --ZDESPER
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
                                            :11
                                            )'
                        USING lh_data(i).chdrnum, lh_data(i).lettype, lh_data(i).lreqdate, lh_data(i).zdspcatg, lh_data(i).zletvern
                        , lh_data(i).zletdest, lh_data(i).zcomaddr, lh_data(i).zletcat, lh_data(i).zapstmpd, lh_data(i).zletefdt,lh_data(i).ZLETTRNO;--, Added for ITR4 Lot2 change
                                         --  LH_DATA(i).ZDESPER;

          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + LH_DATA.COUNT;

            EXCEPTION
                WHEN OTHERS THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGLETTER_IG', substr(lh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum
                                                             || lh_data(SQL%bulk_exceptions(beindx).error_index).lettype, 1, 15),
                                                             v_errormsg);

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := lh_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_stletter%notfound;
        END LOOP;

        CLOSE cur_stletter;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGLETTER', 'TITDMGLETTER_IG', systimestamp, v_app.chdrnum || v_app.lettype, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_letterhist_to_ig;

-- Procedure for DM_Letterhist_to_ig IG movement <EndS> Here

-- Procedure for DM_Annualprem_to_ig IG movement <STARTS> Here

    PROCEDURE dm_annualprem_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   VARCHAR2 DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgmbrindp2%rowtype;
        ap_data          ig_array;
        v_app            titdmgmbrindp2%rowtype;
        ig_endtime       TIMESTAMP;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(60) := NULL;
        temp_no          NUMBER := 0;
        sql_stmt         VARCHAR2(4000) := NULL;
        dml_errors EXCEPTION;
        sqlstmt          VARCHAR2(2000) := NULL;
        TYPE annpre_rc IS REF CURSOR;
        cur_annual       annpre_rc;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGMBRINDP2';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP2 DT WHERE DT.REFNUM=T.REFNUM and DT.PRODTYP = T.PRODTYP)'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGMBRINDP2 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGMBRINDP2.REFNUM and DT.PRODTYP = TITDMGMBRINDP2.PRODTYP) ORDER BY TITDMGMBRINDP2.REFNUM'
                   ;
        OPEN cur_annual FOR sqlstmt;

        LOOP
            FETCH cur_annual BULK COLLECT INTO ap_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + ap_data.count;
                FORALL i IN 1..ap_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
                                           	      PRODTYP,
                                           	      EFFDATE,
	                                              APREM ,
                                           	      HSUMINSU,
                                                  ZTAXFLG -- added for ITR4 lot2 change
                                                    )
                                        VALUES
                                                    (:1,
                                                     :2,
                                                     :3,
                                                     :4,
                                                     :5,
                                                     :6)'
                        USING ap_data(i).refnum, ap_data(i).prodtyp, ap_data(i).effdate, ap_data(i).aprem, ap_data(i).hsuminsu, ap_data
                        (i).ztaxflg; -- added for ITR4 Lot 2 change
	     -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + AP_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(SQL%bulk_exceptions(beindx).error_code);
                        error_logs('TITDMGMBRINDP2_IG', substr(ap_data(SQL%bulk_exceptions(beindx).error_index).refnum
                                                               || ap_data(SQL%bulk_exceptions(beindx).error_index).prodtyp, 1, 15
                                                               ), substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ap_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_annual%notfound;
        END LOOP;

        CLOSE cur_annual;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum || v_app.prodtyp, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, 'V_APP.REFNUM||V_APP.PRODTYP', v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum || v_app.prodtyp, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_annualprem_to_ig;

-- Procedure for DM_Annualprem_to_ig IG movement <EndS> Here

-------------- old
-- Procedure for DM  DM_Policydishonor_to_ig IG movement <Starts> Here
/*
    PROCEDURE dm_policydishonor_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgmbrindp3%rowtype;
        pd_data          ig_array;
        v_app            titdmgmbrindp3%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE poldis_rc IS REF CURSOR;
        cur_poldis       poldis_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGMBRINDP3';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP3 DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in (select REFNUM from TMP_TITDMGMBRINDP3))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGMBRINDP3 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGMBRINDP3 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGMBRINDP3.REFNUM ) ORDER BY TITDMGMBRINDP3.REFNUM';
        OPEN cur_poldis FOR sqlstmt;

        LOOP
            FETCH cur_poldis BULK COLLECT INTO pd_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + pd_data.count;
                FORALL i IN 1..pd_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
                                                      OLDPOLNUM,
                                                      ZDSHCNT,
                                                      CURRFROM)
                                 VALUES
                                           (:1,
                                            :2,
                                            :3,
                                            :4
                                            )'
                        USING pd_data(i).refnum, pd_data(i).oldpolnum, pd_data(i).zdshcnt,
                                           --PD_DATA(i).ZENDPGP,
                                           --PD_DATA(i).ZCOMBILL,
                         pd_data(i).currfrom;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + PD_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGMBRINDP3_IG', substr(pd_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), substr
                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := pd_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_poldis%notfound;
        END LOOP;

        CLOSE cur_poldis;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.refnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_policydishonor_to_ig;

-- Procedure for DM  DM_Policydishonor_to_ig IG movement <ENDS> Here
old ----
*/

-- Procedure for DM  DM_Policydishonor_to_ig IG movement <Starts> Here

    PROCEDURE dm_policydishonor_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgmbrindp3%rowtype;
        pd_data          ig_array;
        v_app            titdmgmbrindp3%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE poldis_rc IS REF CURSOR;
        cur_poldis       poldis_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGMBRINDP3';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP3 DT WHERE DT.OLDPOLNUM=T.OLDPOLNUM and DT.OLDPOLNUM in (select OLDPOLNUM from TMP_TITDMGMBRINDP3))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGMBRINDP3 for Delta Load
        END IF;


          sqlstmt:='SELECT * FROM TITDMGMBRINDP3 where not exists ( select ''x'' from '||temp_tablename||' DT WHERE DT.OLDPOLNUM=TITDMGMBRINDP3.OLDPOLNUM ) ORDER BY TITDMGMBRINDP3.OLDPOLNUM';

           OPEN CUR_POLDIS FOR sqlstmt;
           LOOP
            FETCH CUR_POLDIS BULK COLLECT INTO PD_DATA  ;--LIMIT p_array_size;


             V_ERRORMSG:=temp_tablename||'-Before Bulk Insert:';

         BEGIN
           V_INPUT_COUNT := V_INPUT_COUNT + PD_DATA.COUNT;
           FORALL i IN 1..PD_DATA.COUNT SAVE EXCEPTIONS

EXECUTE IMMEDIATE 'INSERT INTO '||temp_tablename||' (OLDPOLNUM)
                                 VALUES
                                           (:1
                                            )'
                                            USING
                                           PD_DATA(i).OLDPOLNUM;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + PD_DATA.COUNT;

       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TITDMGMBRINDP3_IG',substr(PD_DATA(sql%bulk_exceptions(beindx).error_index).OLDPOLNUM,1,15),SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=PD_DATA(V_INPUT_COUNT);
           END IF;

           COMMIT;

            EXIT WHEN CUR_POLDIS%NOTFOUND;
           END LOOP;
        CLOSE CUR_POLDIS;

V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;

        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TITDMGMBRINDP3', 'TITDMGMBRINDP3_IG', SYSTIMESTAMP,V_APP.OLDPOLNUM,V_ERRORMSG, 'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_Policydishonor_to_ig;

-- Procedure for DM  DM_Policydishonor_to_ig IG movement <ENDS> Here


-- Procedure for DM Client CORP IG movement <STARTS> Here

PROCEDURE dm_clntcorp_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS
    
    l_output_count   NUMBER := 0;
begin
l_output_count    := 1;
end dm_clntcorp_to_ig;

  /*  PROCEDURE dm_clntcorp_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgclntcorp%rowtype;
        cc_data          ig_array;
        v_app            titdmgclntcorp%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clntcrp_rc IS REF CURSOR;
        cur_clntcrp      clntcrp_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCLNTCORP';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTCORP DT WHERE DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) = T.CLNTKEY || TRIM(T.AGNTNUM) || TRIM(T.MPLNUM) and DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) in (select distinct CLNTKEY || TRIM(AGNTNUM) || TRIM(MPLNUM) from TMP_TITDMGCLNTCORP))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTCORP for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGCLNTCORP where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CLNTKEY || TRIM(DT.AGNTNUM) || TRIM(DT.MPLNUM) = TITDMGCLNTCORP.CLNTKEY || TRIM(TITDMGCLNTCORP.AGNTNUM) || TRIM(TITDMGCLNTCORP.MPLNUM)) ORDER BY TITDMGCLNTCORP.CLNTKEY,TITDMGCLNTCORP.AGNTNUM,TITDMGCLNTCORP.MPLNUM'
                   ;
        OPEN cur_clntcrp FOR sqlstmt;

        LOOP
            FETCH cur_clntcrp BULK COLLECT INTO cc_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + cc_data.count;
                FORALL i IN 1..cc_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (  CLTTYPE,
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
                        USING cc_data(i).clttype, cc_data(i).cltaddr01, cc_data(i).cltaddr02, cc_data(i).cltaddr03, cc_data(i).cltaddr04
                        , cc_data(i).zkanaddr01, cc_data(i).zkanaddr02, cc_data(i).zkanaddr03, cc_data(i).zkanaddr04, cc_data(i).
                        cltpcode, cc_data(i).cltphone01, cc_data(i).cltphone02, cc_data(i).cltdobx, cc_data(i).cltstat, cc_data(i
                        ).faxno, cc_data(i).lsurname, cc_data(i).zkanasnm, cc_data(i).clntkey, cc_data(i).agntnum, cc_data(i).mplnum
                        ;
           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + CC_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCLNTCORP_IG', substr(cc_data(SQL%bulk_exceptions(beindx).error_index).clntkey, 1, 15),
                        substr('('
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        cc_data
                                                                                                                                        (
                                                                                                                                        SQL
                                                                                                                                        %
                                                                                                                                        bulk_exceptions
                                                                                                                                        (
                                                                                                                                        beindx
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        error_index
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        clntkey
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        cc_data
                                                                                                                                        (
                                                                                                                                        SQL
                                                                                                                                        %
                                                                                                                                        bulk_exceptions
                                                                                                                                        (
                                                                                                                                        beindx
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        error_index
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        agntnum
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        cc_data
                                                                                                                                        (
                                                                                                                                        SQL
                                                                                                                                        %
                                                                                                                                        bulk_exceptions
                                                                                                                                        (
                                                                                                                                        beindx
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        error_index
                                                                                                                                        )
                                                                                                                                        .
                                                                                                                                        mplnum
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        ')'
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        v_errormsg
                                                                                                                                        ,
                                                                                                                                        1
                                                                                                                                        ,
                                                                                                                                        1000
                                                                                                                                        )
                                                                                                                                        )
                                                                                                                                        ;

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := cc_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_clntcrp%notfound;
        END LOOP;

        CLOSE cur_clntcrp;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', systimestamp, v_app.clntkey, '('
                                                                                                          || v_app.clntkey
                                                                                                          || v_app.agntnum
                                                                                                          || v_app.mplnum
                                                                                                          || ')'
                                                                                                          || v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', systimestamp, v_app.clntkey, '('
                                                                                                          || v_app.clntkey
                                                                                                          || v_app.agntnum
                                                                                                          || v_app.mplnum
                                                                                                          || ')'
                                                                                                          || v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCLNTCORP', 'TITDMGCLNTCORP_IG', systimestamp, v_app.clntkey, '('
                                                                                                          || v_app.clntkey
                                                                                                          || v_app.agntnum
                                                                                                          || v_app.mplnum
                                                                                                          || ')'
                                                                                                          || v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_clntcorp_to_ig;
*/
-- Procedure for DM Client CORP IG movement <ENDS> Here




-- Procedure for DM Campaign code IG movement <STARTS> Here

    PROCEDURE dm_campaign_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgcampcde%rowtype;
        cd_data          ig_array;
        v_app            titdmgcampcde%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE ccode_rc IS REF CURSOR;
        cur_cmpcde       ccode_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCAMPCDE';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCAMPCDE DT WHERE DT.ZCMPCODE=T.ZCMPCODE and DT.ZCMPCODE in(select ZCMPCODE from TMP_TITDMGCAMPCDE))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCAMPCDE for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGCAMPCDE where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.ZCMPCODE=TITDMGCAMPCDE.ZCMPCODE) ORDER BY TITDMGCAMPCDE.CHDRNUM';
        OPEN cur_cmpcde FOR sqlstmt;

        LOOP
            FETCH cur_cmpcde BULK COLLECT INTO cd_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + cd_data.count;
                FORALL i IN 1..cd_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( ZCMPCODE,
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
                                            :22)'
                        USING cd_data(i).zcmpcode, cd_data(i).zpetname, cd_data(i).zpolcls, cd_data(i).zendcode, cd_data(i).chdrnum
                        , cd_data(i).gpoltyp, cd_data(i).zagptid, cd_data(i).rcdate, cd_data(i).zcmpfrm, cd_data(i).zcmpto, cd_data
                        (i).zmaildat, cd_data(i).zaclsdat, cd_data(i).zdlvcddt, cd_data(i).zvehicle, cd_data(i).zstage, cd_data(i
                        ).zscheme01, cd_data(i).zscheme02, cd_data(i).zcrtusr, cd_data(i).zappdate, cd_data(i).zccodind, cd_data(
                        i).effdate, cd_data(i).status;
           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + CD_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCAMPCDE_IG', substr(cd_data(SQL%bulk_exceptions(beindx).error_index).zcmpcode, 1, 15),
                        substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := cd_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_cmpcde%notfound;
        END LOOP;

        CLOSE cur_cmpcde;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCAMPCDE', 'TITDMGCAMPCDE_IG', systimestamp, v_app.zcmpcode, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_campaign_to_ig;

-- Procedure for DM Campaign code IG movement <ENDS> Here

-- Procedure for DM Sales plan 1 IG movement <STARTS> Here

    PROCEDURE dm_salesplan1_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgsalepln1%rowtype;
        sp1_data         ig_array;
        v_app            titdmgsalepln1%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE spln1_rc IS REF CURSOR;
        cur_slpln1       spln1_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGSALEPLN1';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGSALEPLN1 DT WHERE DT.ZSALPLAN=T.ZSALPLAN AND DT.ZINSTYPE=T.ZINSTYPE AND  DT.PRODTYP=T.PRODTYP and DT.ZSALPLAN in(select ZSALPLAN from TMP_TITDMGSALEPLN1))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGSALEPLN1 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGSALEPLN1 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.ZSALPLAN=TITDMGSALEPLN1.ZSALPLAN AND DT.ZINSTYPE=TITDMGSALEPLN1.ZINSTYPE AND  DT.PRODTYP=TITDMGSALEPLN1.PRODTYP) ORDER BY TITDMGSALEPLN1.ZSALPLAN'
                   ;
        OPEN cur_slpln1 FOR sqlstmt;

        LOOP
            FETCH cur_slpln1 BULK COLLECT INTO sp1_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + sp1_data.count;
                FORALL i IN 1..sp1_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( ZSALPLAN,
                                                      PRODTYP,
                                                      ZINSTYPE,
                                                      SUMINS,
                                                      ZCOVRID,
                                                      ZIMBRPLO)
                                 VALUES
                                           (:1,
                                            :2,
                                            :3,
                                            :4,
                                            :5,
                                            :6)'
                        USING sp1_data(i).zsalplan, sp1_data(i).prodtyp, sp1_data(i).zinstype, sp1_data(i).sumins, sp1_data(i).zcovrid
                        , sp1_data(i).zimbrplo;
         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + SP1_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGSALEPLN1_IG', substr(sp1_data(SQL%bulk_exceptions(beindx).error_index).zsalplan, 1, 15
                        ), substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := sp1_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_slpln1%notfound;
        END LOOP;

        CLOSE cur_slpln1;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGSALEPLN1', 'TITDMGSALEPLN1_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGSALEPLN1', 'TITDMGSALEPLN1_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
        --       ROLLBACK;
            temp_no := ig_control_log('TITDMGSALEPLN1', 'TITDMGSALEPLN1_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_salesplan1_to_ig;

-- Procedure for DM Sales plan 1 IG movement <ENDS> Here

-- Procedure for DM Sales plan 2 IG movement <STARTS> Here

    PROCEDURE dm_salesplan2_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgzcslpf%rowtype;
        sp2_data         ig_array;
        v_app            titdmgzcslpf%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE spln2_rc IS REF CURSOR;
        cur_slpln2       spln2_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGZCSLPF';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGZCSLPF DT WHERE DT.ZSALPLAN=T.ZSALPLAN and DT.ZSALPLAN in(select distinct ZSALPLAN from TMP_TITDMGZCSLPF))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGSALEPLN2 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGZCSLPF where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.ZSALPLAN=TITDMGZCSLPF.ZSALPLAN ) ORDER BY TITDMGZCSLPF.ZSALPLAN';
        OPEN cur_slpln2 FOR sqlstmt;

        LOOP
            FETCH cur_slpln2 BULK COLLECT INTO sp2_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + sp2_data.count;
                FORALL i IN 1..sp2_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( ZCMPCODE,
                                                     OLD_ZSALPLAN,
                                                      ZSALPLAN)
                                 VALUES
                                           (:1,
                                            :2,
                                            :3)'
                        USING sp2_data(i).zcmpcode, sp2_data(i).old_zsalplan, sp2_data(i).zsalplan;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGZCSLPF_IG', substr(sp2_data(SQL%bulk_exceptions(beindx).error_index).zsalplan, 1, 15),
                        substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := sp2_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_slpln2%notfound;
        END LOOP;

        CLOSE cur_slpln2;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGZCSLPF', 'TITDMGZCSLPF_IG', systimestamp, v_app.zsalplan, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_salesplan2_to_ig;

-- Procedure for DM Sales plan 2 IG movement <ENDS> Here


-- Procedure for DM Bill Header1 IG movement <STARTS> Here

    PROCEDURE dm_billheader1_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgbill1%rowtype;
        bh_data          ig_array;
        v_app            titdmgbill1%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE bill1_rc IS REF CURSOR;
        cur_billhdr      bill1_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGBILL1';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGBILL1 DT WHERE DT.TRREFNUM=T.TRREFNUM and DT.CHDRNUM = T.CHDRNUM and (DT.TRREFNUM,DT.CHDRNUM) in(select DT.TRREFNUM,DT.CHDRNUM from TMP_TITDMGBILL1))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGBILL1 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGBILL1 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.TRREFNUM=TRREFNUM and DT.CHDRNUM = CHDRNUM ) order by trrefnum,chdrnum';
        OPEN cur_billhdr FOR sqlstmt;

        LOOP
            FETCH cur_billhdr BULK COLLECT INTO bh_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + bh_data.count;
                FORALL i IN 1..bh_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( TRREFNUM,
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
                                                      ZPDATATXFLG,
                                                      TRANNO
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
                                            :14
                                            )'
                        USING bh_data(i).trrefnum, bh_data(i).chdrnum, bh_data(i).prbilfdt, bh_data(i).prbiltdt, bh_data(i).premout
                        , bh_data(i).zcolflag, bh_data(i).zacmcldt, bh_data(i).zposbdsm, bh_data(i).zposbdsy, bh_data(i).endsercd
                        , bh_data(i).tfrdate, bh_data(i).posting, bh_data(i).zpdatatxflg, bh_data(i).tranno
                        ;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BH_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGBILL1_IG', substr(bh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr

                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := bh_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_billhdr%notfound;
        END LOOP;

        CLOSE cur_billhdr;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGBILL1', 'TITDMGBILL1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_billheader1_to_ig;

-- Procedure for DM Bill Header1 IG movement <ENDS> Here

-- Procedure for DM Bill Header2 IG movement <STARTS> Here

    PROCEDURE dm_billheader2_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgbill2%rowtype;
        bd_data          ig_array;
        v_app            titdmgbill2%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE bill2_rc IS REF CURSOR;
        cur_billhdr2     bill2_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGBILL2';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGBILL2 DT WHERE DT.TRREFNUM=T.TRREFNUM and DT.CHDRNUM = T.CHDRNUM and DT.CHDRNUM in(select distinct CHDRNUM from TMP_TITDMGBILL2))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGBILL2 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGBILL2 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.TRREFNUM=TITDMGBILL2.TRREFNUM and DT.CHDRNUM = TITDMGBILL2.CHDRNUM and DT.PRODTYP = TITDMGBILL2.PRODTYP
                       and DT.MBRNO = TITDMGBILL2.MBRNO and DT.DPNTNO = TITDMGBILL2.DPNTNO) order by trrefnum, chdrnum, prodtyp, mbrno, dpntno'
                   ;
        OPEN cur_billhdr2 FOR sqlstmt;

        LOOP
            FETCH cur_billhdr2 BULK COLLECT INTO bd_data LIMIT p_array_size;
            v_input_count := v_input_count + bd_data.count;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                FORALL i IN 1..bd_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (TRREFNUM,
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
                                            :29)'
                        USING bd_data(i).trrefnum, bd_data(i).chdrnum, bd_data(i).tranno, bd_data(i).prodtyp, bd_data(i).bprem, bd_data
                        (i).gagntsel01, bd_data(i).gagntsel02, bd_data(i).gagntsel03, bd_data(i).gagntsel04, bd_data(i).gagntsel05
                        , bd_data(i).cmrate01, bd_data(i).cmrate02, bd_data(i).cmrate03, bd_data(i).cmrate04, bd_data(i).cmrate05
                        , bd_data(i).commn01, bd_data(i).commn02, bd_data(i).commn03, bd_data(i).commn04, bd_data(i).commn05, bd_data
                        (i).zagtgprm01, bd_data(i).zagtgprm02, bd_data(i).zagtgprm03, bd_data(i).zagtgprm04, bd_data(i).zagtgprm05
                        , bd_data(i).zcollfee01, bd_data(i).mbrno, bd_data(i).dpntno, bd_data(i).refnumchunk;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BD_DATA.COUNT;
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGBILL2_IG', substr(bd_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr
                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_errormsg := temp_tablename || '-Before getting appno:';
                v_app := bd_data(bd_data.count);
            END IF;

            COMMIT;
            EXIT WHEN cur_billhdr2%notfound;
        END LOOP;

        CLOSE cur_billhdr2;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGBILL2', 'TITDMGBILL2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_billheader2_to_ig;

-- Procedure for DM Bill Header2 IG movement <ENDS> Here

-- Procedure for DM Policy Trans Hist IG movement <STARTS> Here
/*
    PROCEDURE dm_poltranhist_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgpoltrnh%rowtype;
        ph_data          ig_array;
        v_app            titdmgpoltrnh%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE potrh_rc IS REF CURSOR;
        cur_polthis      potrh_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGPOLTRNH';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
--             EXECUTE IMMEDIATE 'DELETE FROM '||temp_tablename||' WHERE EXISTS (SELECT ''X'' FROM TITDMGPOLTRNH DT WHERE DT.CHDRNUM=CHDRNUM and DT.ZSEQNO = ZSEQNO and DT.EFFDATE = EFFDATE and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGPOLTRNH DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_ZMRAP00 where substr(APCUCD,1,8)=DT.CHDRNUM))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGPOLTRNH for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGPOLTRNH where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGPOLTRNH.CHDRNUM ) ORDER BY TITDMGPOLTRNH.CHDRNUM';
        OPEN cur_polthis FOR sqlstmt;

        LOOP
            FETCH cur_polthis BULK COLLECT INTO ph_data LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + ph_data.count;
                FORALL i IN 1..ph_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (CHDRNUM,
                                                      ZSEQNO,
                                                      EFFDATE,
                                                      ZALTREGDAT,
                                                      ZALTRCDE01,
                                                      ZINHDSCLM,
                                                      ZUWREJFLG,
                                                      ZSTOPBPJ,
                                                      ZTRXSTAT,
                                                      ZSTATRESN,
                                                      ZACLSDAT,
                                                      APPRDTE,
                                                      ZPDATATXDTE,
                                                      ZPDATATXFLG,
                                                      ZREFUNDAM,
                                                      ZPAYINREQ,
                                                      CRDTCARD,
                                                      PREAUTNO,
                                                      BNKACCKEY01,
                                                      ZENSPCD01,
                                                      ZENSPCD02,
                                                      ZCIFCODE,
                                                      ZPGPFRDT, -- added for ITR4 changes
                                                      ZPGPTODT,ZDDREQNO)-- added for ITR4 changes
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
											abs(:15),-- Changed for converting positive value #7864	
                                            -- (-1*:15),-- Changed for converting positive value #7864
                                            :16,
                                            :17,
                                            :18,
                                            :19,
                                            :20,
                                            :21,
                                            :22,
                                            :23,
                                            :24,
                                            :25)'
                        USING ph_data(i).chdrnum, ph_data(i).zseqno, ph_data(i).effdate, ph_data(i).zaltregdat, ph_data(i).zaltrcde01
                        , ph_data(i).zinhdsclm, ph_data(i).zuwrejflg, ph_data(i).zstopbpj, ph_data(i).ztrxstat, ph_data(i).zstatresn
                        , ph_data(i).zaclsdat, ph_data(i).apprdte, ph_data(i).zpdatatxdte, ph_data(i).zpdatatxflg, ph_data(i).zrefundam
                        , ph_data(i).zpayinreq, ph_data(i).crdtcard, ph_data(i).preautno, ph_data(i).bnkacckey01, ph_data(i).zenspcd01
                        , ph_data(i).zenspcd02, ph_data(i).zcifcode, ph_data(i).zpgpfrdt,-- added ZPGPFRDT and ZPGPTODT for ITR4 changes
                         ph_data(i).zpgptodt, ph_data(i).zddreqno;
         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + PH_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGPOLTRNH_IG', substr(ph_data(SQL%bulk_exceptions(beindx).error_index).chdrnum
                                                              || ph_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15),
                                                              substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ph_data(ph_data.count);
            END IF;

            COMMIT;
            EXIT WHEN cur_polthis%notfound;
        END LOOP;

        CLOSE cur_polthis;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_poltranhist_to_ig;

-- Procedure for DM Policy Trans Hist IG movement <ENDS> Here
*/
-- Procedure for DM BILL Collection res IG movement <STARTS> Here

    PROCEDURE dm_billcolres_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgcolres%rowtype;
        bc_data          ig_array;
        v_app            titdmgcolres%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE bc_rc IS REF CURSOR;
        cur_colres       bc_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCOLRES';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCOLRES DT WHERE DT.CHDRNUM=T.CHDRNUM and EXISTS (select ''X'' from TMP_PJ_TITDMGCOLRES A WHERE A.CHDRNUM=DT.CHDRNUM))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCOLRES for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGCOLRES where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGCOLRES.CHDRNUM and DT.TRREFNUM = TITDMGCOLRES.TRREFNUM) ORDER BY TITDMGCOLRES.CHDRNUM'
                   ;
        OPEN cur_colres FOR sqlstmt;

        LOOP
            FETCH cur_colres BULK COLLECT INTO bc_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + bc_data.count;
                FORALL i IN 1..bc_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
                                              CHDRNUM,
                                              TRREFNUM,
                                              TFRDATE,
                                              DSHCDE)
                                 VALUES
                                           (:1,
                                            :2,
                                            :3,
                                            :4
                                            )'
                        USING bc_data(i).chdrnum, bc_data(i).trrefnum, bc_data(i).tfrdate, bc_data(i).dshcde;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + BC_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCOLRES_IG', substr(bc_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr
                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := bc_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_colres%notfound;
        END LOOP;

        CLOSE cur_colres;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCOLRES', 'TITDMGCOLRES_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_billcolres_to_ig;

-- Procedure for DM BILL Collection res IG movement <ENDS> Here


-- Procedure for DM Refund HDR IG movement <STARTS> Here

    PROCEDURE dm_refundhdr_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgref1%rowtype;
        rh_data          ig_array;
        v_app            titdmgref1%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE rehd_rc IS REF CURSOR;
        cur_refhdr       rehd_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGREF1';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGREF1 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGREF1 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGREF1 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGREF1.CHDRNUM) ORDER BY TITDMGREF1.CHDRNUM';
        OPEN cur_refhdr FOR sqlstmt;

        LOOP
            FETCH cur_refhdr BULK COLLECT INTO rh_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + rh_data.count;
                FORALL i IN 1..rh_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
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
                                             ZPDATATXFLG
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
                                            :25)'
                        USING rh_data(i).refnum, rh_data(i).chdrnum, rh_data(i).zrefmtcd, rh_data(i).effdate, rh_data(i).prbilfdt
                        , rh_data(i).prbiltdt, rh_data(i).zposbdsm, rh_data(i).zposbdsy, rh_data(i).zaltrcde01, rh_data(i).zrefundbe
                        , rh_data(i).zrefundbz, rh_data(i).zenrfdst, rh_data(i).zzhrfdst, rh_data(i).bankkey, rh_data(i).bankacount
                        , rh_data(i).bankaccdsc, rh_data(i).bnkactyp, rh_data(i).zrqbkrdf, rh_data(i).reqdate, rh_data(i).zcolflag
                        , rh_data(i).paydate, rh_data(i).rdocpfx, rh_data(i).rdoccoy, rh_data(i).rdocnum, rh_data(i).zpdatatxflg;
          --    V_OUTPUT_COUNT := V_OUTPUT_COUNT + RH_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGREF1_IG', substr(rh_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr
                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := rh_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_refhdr%notfound;
        END LOOP;

        CLOSE cur_refhdr;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
        --       ROLLBACK;
            temp_no := ig_control_log('TITDMGREF1', 'TITDMGREF1_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_refundhdr_to_ig;

-- Procedure for DM Refund HDR IG movement <ENDS> Here

-- Procedure for DM Client Hist IG movement <STARTS> Here
/*
    PROCEDURE dm_clienthist_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF stagedbusr.titdmgcltrnhis%rowtype;
        ch_data          ig_array;

        v_app            stagedbusr.titdmgcltrnhis%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnth_rc IS REF CURSOR;
        cur_clenthis     clnth_rc;

        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCLTRNHIS';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLTRNHIS DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
        END IF;

        sqlstmt := 'SELECT REFNUM,
                            ZSEQNO,
                            EFFDATE,
                            LSURNAME,
                            LGIVNAME,
                            ZKANAGIVNAME,
                            ZKANASURNAME,
                            ZKANASNMNOR,
                            ZKANAGNMNOR,
                            CLTPCODE,
                            CLTADDR01,
                            CLTADDR02,
                            CLTADDR03,
                            ZKANADDR01,
                            ZKANADDR02,
                            CLTSEX,
                            ADDRTYPE,
                            CLTPHONE01,
                            CLTPHONE02,
                            OCCPCODE,
                            CLTDOB,
                            ZOCCDSC,
                            ZWORKPLCE,
                            ZALTRCDE01,
                            TRANSHIST,
                            ZENDCDE,
                            CLNTROLEFLG
                    FROM TITDMGCLTRNHIS where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGCLTRNHIS.REFNUM and DT.ZSEQNO = TITDMGCLTRNHIS.ZSEQNO) ORDER BY TITDMGCLTRNHIS.REFNUM,TITDMGCLTRNHIS.ZSEQNO'
                   ;
        OPEN cur_clenthis FOR sqlstmt;

        LOOP
            FETCH cur_clenthis BULK COLLECT INTO ch_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + ch_data.count;
                FORALL i IN 1..ch_data.count SAVE EXCEPTIONS

                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
                                                ZSEQNO,
                                                EFFDATE,
                                                LSURNAME,
                                                LGIVNAME,
                                                ZKANAGIVNAME,
                                                ZKANASURNAME,
                                                ZKANASNMNOR,
                                                ZKANAGNMNOR,
                                                CLTPCODE,
                                                CLTADDR01,
                                                CLTADDR02,
                                                CLTADDR03,
                                                ZKANADDR01,
                                                ZKANADDR02,
                                                CLTSEX,
                                                ADDRTYPE,
                                                CLTPHONE01,
                                                CLTPHONE02,
                                                OCCPCODE,
                                                CLTDOB,
                                                ZOCCDSC,
                                                ZWORKPLCE,
                                                ZALTRCDE01,
                                                TRANSHIST,
                                                ZENDCDE,
                                                CLNTROLEFLG
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
                                                :27
                                                )'
                        USING  ch_data(i).REFNUM,
                                 ch_data(i).ZSEQNO,
                                 ch_data(i).EFFDATE,
                                 ch_data(i).LSURNAME,
                                 ch_data(i).LGIVNAME,
                                 ch_data(i).ZKANAGIVNAME,
                                 ch_data(i).ZKANASURNAME,
                                 ch_data(i).ZKANASNMNOR,
                                 ch_data(i).ZKANAGNMNOR,
                                 ch_data(i).CLTPCODE,
                                 ch_data(i).CLTADDR01,
                                 ch_data(i).CLTADDR02,
                                 ch_data(i).CLTADDR03,
                                 ch_data(i).ZKANADDR01,
                                 ch_data(i).ZKANADDR02,
                                 ch_data(i).CLTSEX,
                                 ch_data(i).ADDRTYPE,
                                 ch_data(i).CLTPHONE01,
                                 ch_data(i).CLTPHONE02,
                                 ch_data(i).OCCPCODE,
                                 ch_data(i).CLTDOB,
                                 ch_data(i).ZOCCDSC,
                                 ch_data(i).ZWORKPLCE,
                                 ch_data(i).ZALTRCDE01,
                                 ch_data(i).TRANSHIST,
                                 ch_data(i).ZENDCDE,
                                 ch_data(i).CLNTROLEFLG
                                ;
         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + CH_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCLTRNHIS_IG', substr(ch_data(SQL%bulk_exceptions(beindx).error_index).refnum
                                                               || ch_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15)
                                                               , substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ch_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_clenthis%notfound;
        END LOOP;

        CLOSE cur_clenthis;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            , 'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            , 'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRORMESSAGE '|| SQLERRM);
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            , 'F', v_input_count, v_output_count);

            return;
    END dm_clienthist_to_ig; */

PROCEDURE dm_clienthist_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgcltrnhis%rowtype;
        ch_data          ig_array;
        v_app            titdmgcltrnhis%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnth_rc IS REF CURSOR;
        cur_clenthis     clnth_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCLTRNHIS';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLTRNHIS DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGCLTRNHIS where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGCLTRNHIS.REFNUM and DT.ZSEQNO = TITDMGCLTRNHIS.ZSEQNO) ORDER BY TITDMGCLTRNHIS.REFNUM,TITDMGCLTRNHIS.ZSEQNO'
                   ;
        OPEN cur_clenthis FOR sqlstmt;

        LOOP
            FETCH cur_clenthis BULK COLLECT INTO ch_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + ch_data.count;
                FORALL i IN 1..ch_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( REFNUM,
                                                      ZSEQNO,
                                                      EFFDATE,
                                                      LSURNAME,
                                                      LGIVNAME,
                                                      ZKANAGIVNAME,
                                                      ZKANASURNAME,
                                                      ZKANASNMNOR,
                                                      ZKANAGNMNOR,
                                                      CLTPCODE,
                                                      CLTADDR01,
                                                      CLTADDR02,
                                                      CLTADDR03,
                                                      ZKANADDR01,
                                                      ZKANADDR02,
                                                      CLTSEX,
                                                      ADDRTYPE,
                                                      CLTPHONE01,
                                                      CLTPHONE02,
                                                      OCCPCODE,
                                                      CLTDOB,
                                                      ZOCCDSC,
                                                      ZWORKPLCE,
                                                      ZALTRCDE01,
                                                      transhist,
                    zendcde,
                    clntroleflg)
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
                                            :27)'
                        USING ch_data(i).refnum, ch_data(i).zseqno, ch_data(i).effdate, ch_data(i).lsurname, ch_data(i).lgivname,
                        ch_data(i).zkanagivname, ch_data(i).zkanasurname, ch_data(i).ZKANASNMNOR, ch_data(i).ZKANAGNMNOR, ch_data(i).cltpcode, ch_data(i).cltaddr01, ch_data(i).cltaddr02
                        , ch_data(i).cltaddr03, ch_data(i).zkanaddr01, ch_data(i).zkanaddr02, ch_data(i).cltsex, ch_data(i).addrtype
                        , ch_data(i).cltphone01, ch_data(i).cltphone02, ch_data(i).occpcode, ch_data(i).cltdob, ch_data(i).zoccdsc
                        , ch_data(i).zworkplce, ch_data(i).zaltrcde01,ch_data(i).transhist,ch_data(i).zendcde,ch_data(i).clntroleflg;
         --  V_OUTPUT_COUNT := V_OUTPUT_COUNT + CH_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCLTRNHIS_IG', substr(ch_data(SQL%bulk_exceptions(beindx).error_index).refnum
                                                               || ch_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15)
                                                               , substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ch_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_clenthis%notfound;
        END LOOP;

        CLOSE cur_clenthis;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGCLTRNHIS', 'TITDMGCLTRNHIS_IG', systimestamp, v_app.refnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_clienthist_to_ig;
-- Procedure for DM Client Hist IG movement <ENDS> Here

-- Procedure for DM Client person IG movement <STARTS> Here

    PROCEDURE dm_clntprsn_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgclntprsn%rowtype;
        cp_data          ig_array;
        v_app            titdmgclntprsn%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clntpr_rc IS REF CURSOR;
        cur_clntprsn     clntpr_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGCLNTPRSN';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGCLNTPRSN DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTPRSN for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGCLNTPRSN where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGCLNTPRSN.REFNUM ) ORDER BY TITDMGCLNTPRSN.REFNUM';
        OPEN cur_clntprsn FOR sqlstmt;

        LOOP
            FETCH cur_clntprsn BULK COLLECT INTO cp_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + cp_data.count;
                FORALL i IN 1..cp_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
                                           REFNUM,
                                           LSURNAME,
                                           LGIVNAME,
                                           ZKANAGIVNAME,
                                           ZKANASURNAME,
                                           CLTPCODE,
                                           CLTADDR01,
                                           CLTADDR02,
                                           CLTADDR03,
                                           CLTADDR04,
                                           ZKANADDR01,
                                           ZKANADDR02,
                                           ZKANADDR03,
                                           ZKANADDR04,
                                           CLTSEX,
                                           ADDRTYPE,
                                           CLTPHONE01,
                                           CLTPHONE02,
                                           OCCPCODE,
                                           SERVBRH,
                                           CLTDOB,
                                           ZOCCDSC,
                                           ZWORKPLCE,
                                    --       OCCPCLAS,
                                           TRANSHIST,
                                           ASRF)
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
                                         --   :24,
                                            :25,
                                            :26)'
                        USING cp_data(i).refnum, cp_data(i).lsurname, cp_data(i).lgivname, cp_data(i).zkanagivname, cp_data(i).zkanasurname
                        , cp_data(i).cltpcode, cp_data(i).cltaddr01, cp_data(i).cltaddr02, cp_data(i).cltaddr03, cp_data(i).cltaddr04
                        , cp_data(i).zkanaddr01, cp_data(i).zkanaddr02, cp_data(i).zkanaddr03, cp_data(i).zkanaddr04, cp_data(i).
                        cltsex, cp_data(i).addrtype, cp_data(i).cltphone01, cp_data(i).cltphone02, cp_data(i).occpcode, cp_data(i
                        ).servbrh, cp_data(i).cltdob, cp_data(i).zoccdsc, cp_data(i).zworkplce,
                                        --   CP_DATA(i).OCCPCLAS,
                         cp_data(i).transhist, cp_data(i).asrf;

           --V_OUTPUT_COUNT := V_OUTPUT_COUNT + CP_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGCLNTPRSN_IG', substr(cp_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), substr

                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := cp_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_clntprsn%notfound;
        END LOOP;

        CLOSE cur_clntprsn;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGCLNTPRSN', 'TITDMGCLNTPRSN_IG', systimestamp, v_app.refnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGCLNTPRSN', 'TITDMGCLNTPRSN_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
        --       ROLLBACK;
            temp_no := ig_control_log('TITDMGCLNTPRSN', 'TITDMGCLNTPRSN_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_clntprsn_to_ig;

-- Procedure for DM Client person IG movement <ENDS> Here


-- Procedure for DM Refund Details IG movement <STARTS> Here

    PROCEDURE dm_refunddets_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgref2%rowtype;
        rd_data          ig_array;
        v_app            titdmgref2%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE ref2_rc IS REF CURSOR;
        cur_refdet       ref2_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGREF2';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGREF2 DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGREF2 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGREF2 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGREF2.CHDRNUM ) ORDER BY TITDMGREF2.CHDRNUM ';
        OPEN cur_refdet FOR sqlstmt;

        LOOP
            FETCH cur_refdet BULK COLLECT INTO rd_data;-- LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + rd_data.count;
                FORALL i IN 1..rd_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (TRREFNUM,
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
                        USING rd_data(i).trrefnum, rd_data(i).chdrnum, rd_data(i).zrefmtcd, rd_data(i).prodtyp, rd_data(i).bprem,
                        rd_data(i).gagntsel01, rd_data(i).gagntsel02, rd_data(i).gagntsel03, rd_data(i).gagntsel04, rd_data(i).gagntsel05
                        , rd_data(i).cmrate01, rd_data(i).cmrate02, rd_data(i).cmrate03, rd_data(i).cmrate04, rd_data(i).cmrate05
                        , rd_data(i).commn01, rd_data(i).commn02, rd_data(i).commn03, rd_data(i).commn04, rd_data(i).commn05, rd_data
                        (i).zagtgprm01, rd_data(i).zagtgprm02, rd_data(i).zagtgprm03, rd_data(i).zagtgprm04, rd_data(i).zagtgprm05
                        , rd_data(i).zcollfee01, rd_data(i).mbrno, rd_data(i).dpntno;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + RD_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGREF2_IG', substr(rd_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr

                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := rd_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_refdet%notfound;
        END LOOP;

        CLOSE cur_refdet;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGREF2', 'TITDMGREF2_IG', systimestamp, v_app.chdrnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_refunddets_to_ig;

-- Procedure for DM Refund Details IG movement <ENDS> Here


-- Procedure for DM Member Policy IG movement <STARTS> Here

    PROCEDURE dm_memberpol_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF titdmgmbrindp1%rowtype;
        mp_data          ig_array;
        v_app            titdmgmbrindp1%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE mpol_rc IS REF CURSOR;
        cur_membrpol     mpol_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGMBRINDP1';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP1 DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGMBRINDP1 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGMBRINDP1 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGMBRINDP1.REFNUM) ORDER BY TITDMGMBRINDP1.REFNUM';
        OPEN cur_membrpol FOR sqlstmt;

        LOOP
            FETCH cur_membrpol BULK COLLECT INTO mp_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + mp_data.count;
                FORALL i IN 1..mp_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                  || temp_tablename
                                  || ' (
                                           refnum,
                        gpoltype,
                        zendcde,
                        zcmpcode,
                        mpolnum,
                        effdate,
                        zpolperd,
                        zmargnflg,
                        zdfcncy,
                        docrcvdt,
                        hpropdte,
                        ztrxstat,
                        zstatresn,
                        zanncldt,
                        zcpnscde02,
                        zsalechnl,
                        zsolctflg,
                        cltreln,
                        zplancde,
                        crdtcard,
                        preautno,
                        bnkacckey01,
                        zenspcd01,
                        zenspcd02,
                        zcifcode,
                        dtetrm,
                        crdate,
                        cnttypind,
                        ptdate,
                        btdate,
                        statcode,
                        zwaitpedt,
                        zconvindpol,
                        zpoltdate,
                        oldpolnum,
                        zpgpfrdt,
                        zpgptodt,
                        sinstno,
                        trefnum,
                        endsercd,
                        issdate,
                        zpdatatxflg,
                        occdate,
                        client_category,
                        mbrno,
                        zinsrole,
                        trannomin,
                        trannomax,
                        clientno,
                        zrwnlage,
                        znbmnage,
                        termage,
                        zblnkpol,
                        plnclass)
                                 VALUES
                                           (:1, :2, :3, :4,:5, :6, :7, :8, :9, :10,
                                            :11, :12,:13,:14,:15,:16,:17,:18,:19,:20,
                                            :21,:22,:23,:24,:25,:26,:27,:28,:29,:30,
                                            :31,:32,:33,:34,:35,:36,:37,:38,:39,:40,
                                            :41,:42,:43,:44,:45,:46,:47,:48,:49,:50,
                                            :51,:52,:53,:54)'
                        USING mp_data(i).refnum, mp_data(i).gpoltype, mp_data(i).zendcde, mp_data(i).zcmpcode, mp_data(i).mpolnum
                        , mp_data(i).effdate, mp_data(i).zpolperd, mp_data(i).zmargnflg, mp_data(i).zdfcncy, mp_data(i).docrcvdt, mp_data(
                        i).hpropdte, mp_data(i).ztrxstat, mp_data(i).zstatresn, mp_data(i).zanncldt, mp_data(i).zcpnscde02, mp_data
                        (i).zsalechnl, mp_data(i).zsolctflg, mp_data(i).cltreln, mp_data(i).zplancde, mp_data(i).crdtcard, mp_data(
                        i).preautno, mp_data(i).bnkacckey01, mp_data(i).zenspcd01, mp_data(i).zenspcd02, mp_data(i).zcifcode, mp_data
                        (i).dtetrm, mp_data(i).crdate, mp_data(i).cnttypind, mp_data(i).ptdate, mp_data(i).btdate, mp_data(i).statcode
                        , mp_data(i).zwaitpedt, mp_data(i).zconvindpol, mp_data(i).zpoltdate, mp_data(i).oldpolnum, mp_data(i).zpgpfrdt
                        , mp_data(i).zpgptodt, mp_data(i).sinstno, mp_data(i).trefnum, mp_data(i).endsercd, mp_data(i).issdate, mp_data(i
                        ).zpdatatxflg, mp_data(i).occdate, mp_data(i).client_category, mp_data(i).mbrno, mp_data(i).zinsrole, mp_data
                        (i).trannomin, mp_data(i).trannomax, mp_data(i).clientno, mp_data(i).zrwnlage, mp_data(i).znbmnage, mp_data
                        (i).termage, mp_data(i).zblnkpol, mp_data(i).plnclass;
          -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + MP_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGMBRINDP1_IG', substr(mp_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), substr

                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := mp_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_membrpol%notfound;
        END LOOP;

        CLOSE cur_membrpol;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_memberpol_to_ig;

-- Procedure for DM Member Policy IG movement <ENDS> Here
-- created on 22nd April 2020 for AGENT MODULE 

    PROCEDURE dm_new_agency_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE aj_array IS
            TABLE OF titdmgagentpj%rowtype;
        aj_data          aj_array;
        v_app            titdmgagentpj%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE agency_rc IS REF CURSOR;
        cur_agency       agency_rc;
        aj_sqlstmt       VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGAGENTPJ';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGAGENTPJ DT 
WHERE DT.ZAREFNUM=T.ZAREFNUM)';
            COMMIT;
         -- Delete the records for the records exists in TITDMGAGENTPJ for Delta Load
        END IF;

        aj_sqlstmt := 'SELECT * FROM TITDMGAGENTPJ where not exists ( select ''x'' from '
                      || temp_tablename
                      || ' DT WHERE 
DT.ZAREFNUM=TITDMGAGENTPJ.ZAREFNUM) ORDER BY TITDMGAGENTPJ.ZAREFNUM';
        OPEN cur_agency FOR aj_sqlstmt;

        LOOP
            FETCH cur_agency BULK COLLECT INTO aj_data;--LIMIT p_array_size;
            v_input_count := v_input_count + aj_data.count;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                FORALL i IN 1..aj_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' ( ZAREFNUM,
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
                        USING aj_data(i).zarefnum, aj_data(i).agtype, aj_data(i).agntbr, aj_data(i).srdate, aj_data(i).dateend, aj_data
                        (i).stca, aj_data(i).ridesc, aj_data(i).agclsd, aj_data(i).zrepstnm, aj_data(i).zagregno, aj_data(i).cpyname
                        , aj_data(i).ztrgtflg, aj_data(i)."COUNT", aj_data(i).dconsignen, aj_data(i).zconsidt, aj_data(i).zinstyp01
                        , aj_data(i).cmrate01, aj_data(i).zinstyp02, aj_data(i).cmrate02, aj_data(i).zinstyp03, aj_data(i).cmrate03
                        , aj_data(i).zinstyp04, aj_data(i).cmrate04, aj_data(i).zinstyp05, aj_data(i).cmrate05, aj_data(i).zinstyp06
                        , aj_data(i).cmrate06, aj_data(i).zinstyp07, aj_data(i).cmrate07, aj_data(i).zinstyp08, aj_data(i).cmrate08
                        , aj_data(i).zinstyp09, aj_data(i).cmrate09, aj_data(i).zinstyp10, aj_data(i).cmrate10, aj_data(i).clntnum
                        , aj_data(i).zdragnt;
                                --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + AJ_DATA.COUNT;
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGAGENTPJ_IG', substr(aj_data(SQL%bulk_exceptions(beindx).error_index).zarefnum, 1, 15),

                        substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := aj_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_agency%notfound;
        END LOOP;

        CLOSE cur_agency;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGAGENTPJ', 'TITDMGAGENTPJ_IG', systimestamp, v_app.zarefnum, v_errormsg,
               'F', v_input_count, v_output_count);

            return;
    END dm_new_agency_to_ig;

-- Procedure for DM_New_Agency_to_ig IG movement <ENDS> Here
--- Procedure for DM_Mastpol1_to_ig < STARTS > Here
PROCEDURE DM_Mastpol1_to_ig(
			v_ig_schema IN VARCHAR2, 
			p_array_size IN PLS_INTEGER DEFAULT 1000, 
			p_delta IN CHAR DEFAULT 'N')
       IS

          TYPE AJ_ARRAY IS 
          TABLE OF TITDMGMASPOL%ROWTYPE;
          MS1_DATA AJ_ARRAY;
          V_APP TITDMGMASPOL%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;
          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);
          TYPE master_policy_rc is REF CURSOR;
          CUR_MASTER1 master_policy_rc;
          ms1_sqlstmt VARCHAR2(2000):=null;
          l_OUTPUT_COUNT NUMBER:=0;
       BEGIN
        V_INPUT_COUNT:=0;
        V_OUTPUT_COUNT:=0;
        l_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;

         IG_STARTTIME := SYSTIMESTAMP;
            temp_tablename:=v_ig_schema||'.TITDMGMASPOL';

         IF p_delta = 'Y' THEN
             V_ERRORMSG:= 'For Delta Load:';
             EXECUTE IMMEDIATE 'DELETE FROM '||temp_tablename||' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGMASPOL DT WHERE DT.CHDRNUM=T.CHDRNUM)';
             COMMIT;
         -- Delete the records for the records exists in TITDMGMASPOL for Delta Load
         END IF;

ms1_sqlstmt:='SELECT * FROM TITDMGMASPOL where not exists ( select ''x'' from '
				||temp_tablename
				||' DT WHERE DT.CHDRNUM=TITDMGMASPOL.CHDRNUM) ORDER BY TITDMGMASPOL.CHDRNUM';
           OPEN CUR_MASTER1 FOR ms1_sqlstmt;
           
           LOOP
            FETCH CUR_MASTER1 BULK COLLECT INTO MS1_DATA  ;--LIMIT p_array_size;
            V_INPUT_COUNT := V_INPUT_COUNT + MS1_DATA.COUNT;
             V_ERRORMSG:=temp_tablename||'-Before Bulk Insert:';
         BEGIN
           FORALL i IN 1..MS1_DATA.COUNT SAVE EXCEPTIONS
       EXECUTE IMMEDIATE 'INSERT INTO '||temp_tablename
       								   ||' (
	                                              -- RECIDXMPMSPOL ,
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
														    CLNTNUM)
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
                                            :25
                                            )'
                        USING ms1_data(i).chdrnum, ms1_data(i).cnttype, ms1_data(i).statcode, ms1_data(i).zagptnum, ms1_data(i).ccdate
                        , ms1_data(i).crdate, ms1_data(i).rptfpst, ms1_data(i).zendcde, ms1_data(i).rra2ig, ms1_data(i).b8tjig, ms1_data
                        (i).zblnkpol, ms1_data(i).b8o9nb, ms1_data(i).b8gpst, ms1_data(i).b8gost, ms1_data(i).znbaltpr, ms1_data(
                        i).canceldt, ms1_data(i).effdate, ms1_data(i).pndate, ms1_data(i).occdate, ms1_data(i).insendte, ms1_data
                        (i).zpenddt, ms1_data(i).zccde, ms1_data(i).zconsgnm, ms1_data(i).zbladcd, ms1_data(i).clntnum;
                                --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS1_DATA.COUNT;
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGMASPOL_IG', substr(ms1_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15), substr

                        (v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ms1_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_master1%notfound;
        END LOOP;

        CLOSE cur_master1;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count
            , v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count
            , v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGMASPOL', 'TITDMGMASPOL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count
            , v_output_count);

            return;
    END dm_mastpol1_to_ig;
--- Procedure for DM_Mastpol1_to_ig < ENDS > Here
--- Procedure for DM_Mastpol2_to_ig < STARTS > Here
    PROCEDURE dm_mastpol2_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE aj_array IS
            TABLE OF titdmginsstpl%rowtype;
        ms2_data         aj_array;
        v_app            titdmginsstpl%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE master_policy_rc IS REF CURSOR;
        cur_master2      master_policy_rc;
        ms2_sqlstmt      VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGINSSTPL';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGINSSTPL DT WHERE DT.CHDRNUM=T.CHDRNUM)';
            COMMIT;
         -- Delete the records for the records exists in TITDMGINSSTPL for Delta Load
        END IF;

        ms2_sqlstmt := 'SELECT * FROM TITDMGINSSTPL where not exists ( select ''x'' from '
                       || temp_tablename
                       || ' DT WHERE DT.CHDRNUM=TITDMGINSSTPL.CHDRNUM) ORDER BY TITDMGINSSTPL.CHDRNUM';
        OPEN cur_master2 FOR ms2_sqlstmt;

        LOOP
            FETCH cur_master2 BULK COLLECT INTO ms2_data;--LIMIT p_array_size;
            v_input_count := v_input_count + ms2_data.count;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                FORALL i IN 1..ms2_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
	                                            CHDRNUM,
											    PLNSETNUM,
											    ZINSTYPE1,
											    ZINSTYPE2,
											    ZINSTYPE3,
												ZINSTYPE4)
                                 VALUES
                                           (:1,
                                            :2,
                                            :3,
                                            :4,
                                            :5,
                                            :6
                                            )'
                        USING ms2_data(i).chdrnum, ms2_data(i).plnsetnum, ms2_data(i).zinstype1, ms2_data(i).zinstype2, ms2_data(
                        i).zinstype3, ms2_data(i).zinstype4;
                                --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS2_DATA.COUNT;
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGINSSTPL_IG', substr(ms2_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15),

                        substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := ms2_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_master2%notfound;
        END LOOP;

        CLOSE cur_master2;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'S', v_input_count
            , v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count
            , v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGINSSTPL', 'TITDMGINSSTPL_IG', systimestamp, v_app.chdrnum, v_errormsg, 'F', v_input_count
            , v_output_count);

            return;
    END dm_mastpol2_to_ig;
--- Procedure for DM_Mastpol2_to_ig < ENDS > Here
--- Procedure for DM_Mastpol3_to_ig < STARTS > Here
PROCEDURE DM_Mastpol3_to_ig(v_ig_schema IN VARCHAR2, p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N')
       IS
          TYPE AJ_ARRAY IS TABLE OF TITDMGENDCTPF%ROWTYPE;
          MS3_DATA AJ_ARRAY;
          V_APP TITDMGENDCTPF%ROWTYPE;
          V_ERRORMSG VARCHAR2(2000);
          temp_tablename VARCHAR2(30):=null;
          temp_no number:=0;

          dml_errors EXCEPTION;
          PRAGMA exception_init(dml_errors, -24381);

          TYPE master_policy_rc is REF CURSOR;
          CUR_MASTER3 master_policy_rc;

          ms3_sqlstmt VARCHAR2(2000):=null;
          l_OUTPUT_COUNT NUMBER:=0;

       BEGIN
        V_INPUT_COUNT:=0;
        V_OUTPUT_COUNT:=0;
        l_OUTPUT_COUNT:=0;
         L_ERR_FLG :=0;
         G_ERR_FLG :=0;

         IG_STARTTIME := SYSTIMESTAMP;
            temp_tablename:=v_ig_schema||'.TITDMGENDCTPF';

         IF p_delta = 'Y' THEN
             V_ERRORMSG:= 'For Delta Load:';
             EXECUTE IMMEDIATE 'DELETE FROM '||temp_tablename||' T WHERE EXISTS (SELECT ''X'' FROM TMP_TITDMGENDCTPF DT WHERE DT.CHDRNUM=T.CHDRNUM)';
             COMMIT;
         -- Delete the records for the records exists in TITDMGENDCTPF for Delta Load
         END IF;


ms3_sqlstmt:='SELECT * FROM TITDMGENDCTPF where not exists ( select ''x'' from '||temp_tablename||' DT WHERE DT.CHDRNUM=TITDMGENDCTPF.CHDRNUM) ORDER BY TITDMGENDCTPF.CHDRNUM';


           OPEN CUR_MASTER3 FOR ms3_sqlstmt;
           LOOP
            FETCH cur_master3 BULK COLLECT INTO ms3_data;--LIMIT p_array_size;
            v_input_count := v_input_count + ms3_data.count;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                FORALL i IN 1..ms3_data.count SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (CHDRNUM,
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
                                           (:1,
                                            :2,
                                            :3,
                                            :4,
                                            :5,
                                            :6,
                                            :7,
                                            :8,
                                            :9
                                            )'
                        USING ms3_data(i).chdrnum, ms3_data(i).zcrdtype, ms3_data(i).zcarddc, ms3_data(i).zcnbrfrm, ms3_data(i).zcnbrto
                                                MS3_DATA(i).CHDRNUM,
												MS3_DATA(i).ZCRDTYPE,
												MS3_DATA(i).ZCARDDC,
												MS3_DATA(i).ZCNBRFRM,
												MS3_DATA(i).ZCNBRTO,
												MS3_DATA(i).ZMSTID,
												MS3_DATA(i).ZMSTSNME,
												MS3_DATA(i).ZMSTIDV,
												MS3_DATA(i).ZMSTSNMEV;
                                --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + MS3_DATA.COUNT;
       EXCEPTION
           WHEN dml_errors THEN
             FOR beindx in 1 .. sql%bulk_exceptions.count
             LOOP
                V_ERRORMSG := 'In Insert -'||sqlerrm(-sql%bulk_exceptions(beindx).error_code);
                ERROR_LOGS('TITDMGENDCTPF_IG',substr(MS3_DATA(sql%bulk_exceptions(beindx).error_index).CHDRNUM,1,15),SUBSTR(V_ERRORMSG,1,1000));
                l_OUTPUT_COUNT:=l_OUTPUT_COUNT+1;
             END LOOP;
       END;
           V_APP:=NULL;
           IF V_INPUT_COUNT <> 0 THEN
              V_APP:=MS3_DATA(V_INPUT_COUNT);
           END IF;
           COMMIT;
            EXIT WHEN CUR_MASTER3%NOTFOUND;
           END LOOP;
        CLOSE CUR_MASTER3;
			V_OUTPUT_COUNT:= V_INPUT_COUNT - l_OUTPUT_COUNT;
        IF G_ERR_FLG = 0 THEN
            V_ERRORMSG := 'SUCCESS';

            temp_no := IG_CONTROL_LOG('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG,'S',V_INPUT_COUNT,V_OUTPUT_COUNT);

        ELSE
            V_ERRORMSG := 'COMPLETED WITH ERROR';
            temp_no := IG_CONTROL_LOG('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG,'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
               V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
               temp_no := IG_CONTROL_LOG('TITDMGENDCTPF', 'TITDMGENDCTPF_IG', SYSTIMESTAMP,V_APP.CHDRNUM,V_ERRORMSG,'F',V_INPUT_COUNT,V_OUTPUT_COUNT);
               return;

       END DM_Mastpol3_to_ig;
--- Procedure for DM_Mastpol3_to_ig < ENDS > Here
-- Procedure for dm_Policytran_transform_to_ig IG movement <STARTS> Here
PROCEDURE dm_Policytran_transform_to_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF TITDMGPOLTRNH%rowtype;
        st_data          ig_array;
        v_app            TITDMGPOLTRNH%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnt_rc IS REF CURSOR;
        cur_POLTRNH     clnt_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
          --CURSOR CUR_CLNTBANK IS
               --SELECT * FROM TITDMGPOLTRNH;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGPOLTRNH';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGPOLTRNH DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGPOLTRNH for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGPOLTRNH where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGPOLTRNH.CHDRNUM and DT.ZSEQNO = TITDMGPOLTRNH.ZSEQNO) ORDER BY TITDMGPOLTRNH.CHDRNUM,TITDMGPOLTRNH.ZSEQNO'
                   ;              
        OPEN cur_POLTRNH FOR sqlstmt;

        LOOP
            FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + st_data.count;
                FORALL i IN 1..st_data.count SAVE EXCEPTIONS
						EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
												CHDRNUM
                                            ,	ZSEQNO
                                            ,	EFFDATE
                                            ,	CLIENT_CATEGORY
                                            ,	MBRNO
                                            ,	CLTRELN
                                            ,	ZINSROLE
                                            ,	CLIENTNO
                                            ,	ZALTREGDAT
                                            ,	ZALTRCDE01
                                            ,	ZINHDSCLM
                                            ,	ZUWREJFLG
                                            ,	ZSTOPBPJ
                                            ,	ZTRXSTAT
                                            ,	ZSTATRESN
                                            ,	ZACLSDAT
                                            ,	APPRDTE
                                            ,	ZPDATATXDTE
                                            ,	ZPDATATXFLG
                                            ,	ZREFUNDAM
                                            ,	ZPAYINREQ
                                            ,	CRDTCARD
                                            ,	PREAUTNO
                                            ,	BNKACCKEY01
                                            ,	ZENSPCD01
                                            ,	ZENSPCD02
                                            ,	ZCIFCODE
                                            ,	ZDDREQNO
                                            ,	ZWORKPLCE2
                                            ,	BANKACCDSC01
                                            ,	BANKKEY
                                            ,	BNKACTYP01
                                            ,	CURRTO
                                            ,	B1_ZKNJFULNM
                                            ,	B2_ZKNJFULNM
                                            ,	B3_ZKNJFULNM
                                            ,	B4_ZKNJFULNM
                                            ,	B5_ZKNJFULNM
                                            ,	B1_CLTADDR01
                                            ,	B2_CLTADDR01
                                            ,	B3_CLTADDR01
                                            ,	B4_CLTADDR01
                                            ,	B5_CLTADDR01
                                            ,	B1_BNYPC
                                            ,	B2_BNYPC
                                            ,	B3_BNYPC
                                            ,	B4_BNYPC
                                            ,	B5_BNYPC
                                            ,	B1_BNYRLN
                                            ,	B2_BNYRLN
                                            ,	B3_BNYRLN
                                            ,	B4_BNYRLN
                                            ,	B5_BNYRLN
                                            ,	ZCONVPOLNO
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
                                            :54
												)'
									USING   st_data(i).CHDRNUM,
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
                                            st_data(i).ZCONVPOLNO
                                             ;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
        --        EXECUTE IMMEDIATE 'Update '
        --                          || temp_tablename
        ---                          || ' set CHDRNUM = concat(CHDRNUM,''00'')';
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGPOLTRNH_IG', substr(st_data(SQL%bulk_exceptions(beindx).error_index).chdrnum
                                                               || st_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15),
                                                               substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := st_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_POLTRNH%notfound;
        END LOOP;

        CLOSE cur_POLTRNH;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;                         
            temp_no := ig_control_log('TITDMGPOLTRNH', 'TITDMGPOLTRNH_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_Policytran_transform_to_ig;

-- Procedure for dm_Policytran_transform_to_ig IG movement <ENDS> Here

-- Procedure for dm_polhis_cov_ig <STARTS> Here
PROCEDURE dm_polhis_cov_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF TITDMGMBRINDP2%rowtype;
        st_data          ig_array;
        v_app            TITDMGMBRINDP2%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnt_rc IS REF CURSOR;
        cur_POLTRNH     clnt_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
          --CURSOR CUR_CLNTBANK IS
               --SELECT * FROM TITDMGMBRINDP2;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGMBRINDP2';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP2 DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGMBRINDP2 where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.REFNUM=TITDMGMBRINDP2.REFNUM ) ORDER BY TITDMGMBRINDP2.REFNUM'
                   ;
        OPEN cur_POLTRNH FOR sqlstmt;

        LOOP
            FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + st_data.count;
                FORALL i IN 1..st_data.count SAVE EXCEPTIONS
                                                                                      EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (           
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
                                                                                                                                       :11
                                                                                                                                                     )' 
                                                                                                                                 USING   st_data(i).REFNUM,
                                                                                                                                                               st_data(i).PRODTYP,
                                                                                                                                                               st_data(i).EFFDATE,
                                                                                                                                                               st_data(i).APREM,
                                                                                                                                                               st_data(i).HSUMINSU,
                                                                                                                                                               st_data(i).ZTAXFLG,
                                                                                                                                                               st_data(i).MBRNO,
                                                                                                                                                               st_data(i).DPNTNO,
                                                                                                                                                               st_data(i).NDRPREM,
                                                                                                                                                               st_data(i).PRODTYP02,
                                                                                                                                                               st_data(i).ZINSTYPE
                                                                                                                                                               ;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
               
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGMBRINDP2_IG', substr(st_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := st_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_POLTRNH%notfound;
        END LOOP;

        CLOSE cur_POLTRNH;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum , v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGMBRINDP2', 'TITDMGMBRINDP2_IG', systimestamp, v_app.refnum, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_polhis_cov_ig;

-- Procedure for dm_polhis_cov_ig <ENDS> Here


-- Procedure for dm_polhis_apirno_ig <STARTS> Here
PROCEDURE dm_polhis_apirno_ig(
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF TITDMGAPIRNO%rowtype;
        st_data          ig_array;
        v_app            TITDMGAPIRNO%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnt_rc IS REF CURSOR;
        cur_POLTRNH     clnt_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
          --CURSOR CUR_CLNTBANK IS
               --SELECT * FROM TITDMGAPIRNO;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TITDMGAPIRNO';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGAPIRNO DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TITDMGAPIRNO for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TITDMGAPIRNO where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TITDMGAPIRNO.CHDRNUM ) ORDER BY TITDMGAPIRNO.CHDRNUM'
                   ;
        OPEN cur_POLTRNH FOR sqlstmt;

        LOOP
            FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + st_data.count;
                FORALL i IN 1..st_data.count SAVE EXCEPTIONS
						EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
												CHDRNUM
											,	MBRNO
											,	ZINSTYPE
											,	ZAPIRNO
											,	FULLKANJINAME
											)
                                 VALUES
                                           (:1,
											:2,
											:3,
											:4,
											:5
											)'
									USING   st_data(i).CHDRNUM,
											st_data(i).MBRNO,
											st_data(i).ZINSTYPE,
											st_data(i).ZAPIRNO,
											st_data(i).FULLKANJINAME
											;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;

            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TITDMGAPIRNO_IG', substr(st_data(SQL%bulk_exceptions(beindx).error_index).chdrnum, 1, 15),
                                                               substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := st_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_POLTRNH%notfound;
        END LOOP;

        CLOSE cur_POLTRNH;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TITDMGAPIRNO', 'TITDMGAPIRNO_IG', systimestamp, v_app.chdrnum, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_polhis_apirno_ig;
-- Procedure for dm_polhis_apirno_ig <ENDS> Here


-- Procedure for dm_generate_tranno_ig <STARTS> Here
/*PROCEDURE dm_generate_tranno_ig (
        v_ig_schema    IN   VARCHAR2,
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF TRANNOTBL%rowtype;
        st_data          ig_array;
        v_app            TRANNOTBL%rowtype;
        v_errormsg       VARCHAR2(2000);
        temp_tablename   VARCHAR2(30) := NULL;
        temp_no          NUMBER := 0;
        dml_errors EXCEPTION;
        PRAGMA exception_init ( dml_errors, -24381 );
        TYPE clnt_rc IS REF CURSOR;
        cur_POLTRNH     clnt_rc;
        sqlstmt          VARCHAR2(2000) := NULL;
        l_output_count   NUMBER := 0;
          --CURSOR CUR_CLNTBANK IS
               --SELECT * FROM TRANNOTBL;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        ig_starttime := systimestamp;
        temp_tablename := v_ig_schema || '.TRANNOTBL';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            EXECUTE IMMEDIATE 'DELETE FROM '
                              || temp_tablename
                              || ' T WHERE EXISTS (SELECT ''X'' FROM TRANNOTBL DT WHERE DT.CHDRNUM=T.CHDRNUM and DT.CHDRNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))'
                              ;
            COMMIT;
         -- Delete the records for all the records exists in TRANNOTBL for Delta Load
        END IF;

        sqlstmt := 'SELECT * FROM TRANNOTBL where not exists ( select ''x'' from '
                   || temp_tablename
                   || ' DT WHERE DT.CHDRNUM=TRANNOTBL.CHDRNUM ) ORDER BY TRANNOTBL.CHDRNUM'
                   ;
        OPEN cur_POLTRNH FOR sqlstmt;

        LOOP
            FETCH cur_POLTRNH BULK COLLECT INTO st_data;--LIMIT p_array_size;
            v_errormsg := temp_tablename || '-Before Bulk Insert:';
            BEGIN
                v_input_count := v_input_count + st_data.count;
                FORALL i IN 1..st_data.count SAVE EXCEPTIONS
						EXECUTE IMMEDIATE 'INSERT INTO '
                                      || temp_tablename
                                      || ' (
											,	CHDRNUM
											,	ZSEQNO
											,	T_TYPE
											,	ZALTRCDE01
											,	T_DATE
											,	TRANNO
											,	OLDPOLNUM

											)
                                 VALUES
                                           (:1,
											:2,
											:3,
											:4,
											:5,
											:6,
											:7
											)'
									USING   st_data(i).CHDRNUM,
											st_data(i).ZSEQNO,
											st_data(i).T_TYPE,
											st_data(i).ZALTRCDE01,
											st_data(i).T_DATE,
											st_data(i).TRANNO,
											st_data(i).OLDPOLNUM
											;
        --   V_OUTPUT_COUNT := V_OUTPUT_COUNT + ST_DATA.COUNT;
                EXECUTE IMMEDIATE 'Update '
                                  || temp_tablename
                                  || ' set CHDRNUM = concat(CHDRNUM,''00'')';
            EXCEPTION
                WHEN dml_errors THEN
                    FOR beindx IN 1..SQL%bulk_exceptions.count LOOP
                        v_errormsg := 'In Insert -'
                                      || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);

                        error_logs('TRANNOTBL_IG', substr(st_data(SQL%bulk_exceptions(beindx).error_index).chdrnum
                                                               || st_data(SQL%bulk_exceptions(beindx).error_index).zseqno, 1, 15),
                                                               substr(v_errormsg, 1, 1000));

                        l_output_count := l_output_count + 1;
                    END LOOP;
            END;

            v_app := NULL;
            IF v_input_count <> 0 THEN
                v_app := st_data(v_input_count);
            END IF;
            COMMIT;
            EXIT WHEN cur_POLTRNH%notfound;
        END LOOP;

        CLOSE cur_POLTRNH;
        v_output_count := v_input_count - l_output_count;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := ig_control_log('TRANNOTBL', 'TRANNOTBL_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := ig_control_log('TRANNOTBL', 'TRANNOTBL_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := ig_control_log('TRANNOTBL', 'TRANNOTBL_IG', systimestamp, v_app.chdrnum || v_app.zseqno, v_errormsg
            ,
               'F', v_input_count, v_output_count);

            return;
    END dm_generate_tranno_ig ; */
-- Procedure for dm_generate_tranno_ig <ENDS> Here
END dm_data_bulkcopy_ig;
/