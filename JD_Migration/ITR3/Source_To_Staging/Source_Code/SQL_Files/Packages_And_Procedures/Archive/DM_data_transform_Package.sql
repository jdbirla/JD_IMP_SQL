create or replace PACKAGE                          DM_data_transform AS
  FUNCTION CONTROL_LOG(v_src_tabname IN VARCHAR2, v_target_tb IN VARCHAR2, v_endtime IN TIMESTAMP,v_applno IN VARCHAR2,l_errmsg IN VARCHAR2, l_st IN VARCHAR2,v_in_cnt IN NUMBER DEFAULT 0,v_out_cnt IN NUMBER DEFAULT 0) return number;
  PROCEDURE DM_clntbnk_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Annualprem_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Refundhdr_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_policytran_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_billing_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_prsnclnt_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_clienthistory_transform(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Billing_collectres(p_array_size IN PLS_INTEGER DEFAULT 1000,  p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_LETTERHIST_TRANSFORM(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Refunddets_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mempol_grp_pol(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mempol_oldpol(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_MEMPOL_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_MEMPOL_BTPTUPDATE(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE dm_saleplan_camp_transform(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE dm_history_new_ZMRAP00_v1(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_MSTPOL_TRANSFROM(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  PROCEDURE ERROR_LOGS(v_jobnm IN VARCHAR2,v_apnum IN VARCHAR2, v_msg IN VARCHAR2);
   PROCEDURE dm_DPNTNO_INSERT (p_array_size   IN   PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_cov (p_array_size   IN   PLS_INTEGER DEFAULT 1000,p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_apirno(p_array_size   IN   PLS_INTEGER DEFAULT 1000,p_delta        IN   CHAR DEFAULT 'N');
END DM_data_transform;
/


create or replace PACKAGE BODY                                                                                                                                                                                     dm_data_transform IS

    v_cnt            NUMBER := 0;
    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
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

    FUNCTION control_log (
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
            dm_transfm_cntl_table
        WHERE
            target_table = v_target_tb;

        IF v_cnt > 0 THEN
            UPDATE dm_transfm_cntl_table
            SET
                module_name = 'DM',
                source_table = v_src_tabname,
                target_table = v_target_tb,
                start_timestamp = to_char(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                end_timestamp = to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                input_cnt = v_in_cnt,
                output_cnt = v_out_cnt,
                last_processed_appno = v_applno,
                errormsg = l_errmsg,
                status = l_st
            WHERE
                target_table = v_target_tb;

        ELSE
            INSERT INTO dm_transfm_cntl_table (
                module_name,
                source_table,
                target_table,
                start_timestamp,
                end_timestamp,
                input_cnt,
                output_cnt,
                last_processed_appno,
                errormsg,
                status
            ) VALUES (
                'DM',
                v_src_tabname,
                v_target_tb,
                to_char(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                v_in_cnt,
                v_out_cnt,
                application_no,
                l_errmsg,
                l_st
            );

        END IF;

        COMMIT;
        RETURN 0;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('CONTROL_LOG:' || sqlerrm);
            RETURN 1;
    END control_log;

-- Procedure for Old ----- DM Client Bank transformations <STARTS> Here

  /*  PROCEDURE dm_clntbnk_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit           PLS_INTEGER := p_array_size;
        v_errormsg        VARCHAR2(2000) := ' ';
        l_credit          VARCHAR2(30) := NULL;
        l_credit_old      VARCHAR2(30) := NULL;
        l_app_old         VARCHAR2(30) := NULL;
        l_currdt          VARCHAR2(8);
        l_date            DATE := NULL;
        l_date_old        DATE := NULL;
        bank_cnt          NUMBER := 0;
        pj_cnt            NUMBER := 0;
        temp_no           NUMBER;
        CURSOR zmrap00_appl_cur IS
        SELECT
            apcucd
        FROM
            (
                SELECT
                    ROWNUM n,
                    apcucd
                FROM
                    zmrap00 a
                WHERE
                    NOT EXISTS (
                        SELECT
                            'X'
                        FROM
                            titdmgclntbank
                        WHERE
                            refnum = substr(apcucd, 1, 8)
                    )
            )
        ORDER BY
            apcucd;

        CURSOR zmrap00_cur (
            c1 IN VARCHAR2
        ) IS
        SELECT
            apcucd,
            substr(apcucd, 1, 8) refnum,
            substr(apcucd, - 3) seqno,
            apc0cd,
            nvl(apdjcd, '    ') AS apdjcd,
            nvl(apyob3, '000000') AS apyob3,
            apc6cd,
            apdkcd,
            endorsercode,
            crdt,
            bnk,
            nvl(apeicd, '          ') AS apeicd,
            apchtx,
            nvl(apbkst, ' ') AS apbkst,
            apb5tx,
            apc7cd
        FROM
            (
                SELECT
                    *
                FROM
                    zmrap00
                WHERE
                    ( ( substr(apcucd, - 3) = '000' )
                      OR apdlcd IN (
                        'ID',
                        'M2',
                        'S2',
                        'CNV'
                    ) )
            ) a,
            (
                SELECT
                    endorsercode,
                    MAX(decode(filetype, 'CreditCard', 'CreditCard')) crdt,
                    MAX(decode(filetype, 'BankAccount', 'BankAccount')) bnk
                FROM
                    card_endorser_list
                WHERE
                    filetype IN (
                        'CreditCard',
                        'BankAccount'
                    )
                GROUP BY
                    endorsercode
            ) b
        WHERE
            a.apc6cd = b.endorsercode
            AND a.apcucd = c1
        ORDER BY
            apcucd;

        TYPE zmrap00_appcur IS
            TABLE OF zmrap00_appl_cur%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF zmrap00_cur%rowtype;
        TYPE t_clnbnk_crd_t IS
            TABLE OF titdmgclntbank%rowtype;
        zmrap00_appls     zmrap00_appcur;
        zmrap00_l_appls   zmrap00_cur_t;
        l_outputcount     NUMBER := 0;
        tmp_bankaccdsc    titdmgclntbank.bankaccdsc%TYPE;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_outputcount := 0;
        v_errormsg := 'DM_clntbnk_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgclntbank
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgclntbank.refnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load
        END IF;

        OPEN zmrap00_appl_cur;
        LOOP
            FETCH zmrap00_appl_cur BULK COLLECT INTO zmrap00_appls LIMIT c_limit;
            v_input_count := v_input_count + zmrap00_appls.count;
            FOR appln_indx IN 1..zmrap00_appls.count LOOP
                OPEN zmrap00_cur(zmrap00_appls(appln_indx).apcucd);
                LOOP
                    FETCH zmrap00_cur BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
                    FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
                        l_currdt := NULL;
                        application_no := zmrap00_l_appls(l_apindx).apcucd;
                        BEGIN -- Start for logic
                            IF zmrap00_l_appls(l_apindx).apyob3 IN (
                                '000000',
                                '999999'
                            ) THEN
                                l_currdt := '99999999';
                                l_date := TO_DATE('00010101', 'YYYYMMDD');
                            ELSE
                                l_currdt := zmrap00_l_appls(l_apindx).apyob3;
                                l_date := last_day(to_date(l_currdt, 'YYYYMM'));
                            END IF;

                            IF zmrap00_l_appls(l_apindx).crdt = 'CreditCard' AND zmrap00_l_appls(l_apindx).apyob3 IS NOT NULL THEN
                                l_credit := zmrap00_l_appls(l_apindx).apc0cd;
                                IF substr(l_app_old, 1, 8) = zmrap00_l_appls(l_apindx).refnum AND l_credit_old = l_credit AND ( l_date
                                > l_date_old OR l_currdt = '99999999' ) THEN
                                    v_errormsg := 'UPDATE';
                                    UPDATE titdmgclntbank
                                    SET
                                        currto = to_number(decode(l_currdt, '99999999', '99999999', to_char(l_date, 'YYYYMMDD')))
                                        ,
                                        seqno = zmrap00_l_appls(l_apindx).seqno
                                    WHERE
                                        refnum = substr(l_app_old, 1, 8)
                                        AND crdtcard = l_credit_old;

                                    v_output_count := v_output_count + 1;
                                ELSIF substr(l_app_old, 1, 8) = substr(zmrap00_l_appls(l_apindx).apcucd, 1, 8) AND l_credit_old =
                                l_credit AND l_date <= l_date_old THEN
                                    NULL;
                                ELSE
                                    v_errormsg := 'CREDITCARD';
                                    INSERT INTO titdmgclntbank (
                                        refnum,
                                        seqno,
                                        currto,
                                        bankcd,
                                        branchcd,
                                        facthous,
                                        bankacckey,
                                        crdtcard,
                                        bankaccdsc,
                                        bnkactyp,
                                        transhist
                                    ) VALUES (
                                        zmrap00_l_appls(l_apindx).refnum,
                                        zmrap00_l_appls(l_apindx).seqno,
                                        to_number(decode(l_currdt, '99999999', '99999999', to_char(l_date, 'YYYYMMDD'))),
                                        '9999',--nvl(ZMRAP00_l_appls(l_apindx).APDJCD,'  '),
                                        '999',--nvl(ZMRAP00_l_appls(l_apindx).APDKCD,'  '),
                                        '99',
                                        nvl(zmrap00_l_appls(l_apindx).apeicd, '  '),
                                        l_credit,
                                        nvl(zmrap00_l_appls(l_apindx).apb5tx, '  '),--NVL(ZMRAP00_l_appls(l_apindx).APCHTX,'  '),
                                        'CC',--nvl(ZMRAP00_l_appls(l_apindx).APBKST,' '),
                                        'N'
                                    );

                                    v_output_count := v_output_count + 1;
                                END IF;

                            END IF;

                            bank_cnt := 0;
                            IF zmrap00_l_appls(l_apindx).bnk = 'BankAccount' AND zmrap00_l_appls(l_apindx).apc7cd <> 'FSH' AND zmrap00_l_appls
                            (l_apindx).apdjcd IS NOT NULL AND zmrap00_l_appls(l_apindx).apeicd IS NOT NULL AND zmrap00_l_appls(l_apindx
                            ).apbkst IS NOT NULL THEN
                                v_errormsg := 'BANKACCOUNT CHK:';
                                SELECT
                                    COUNT(1)
                                INTO bank_cnt
                                FROM
                                    titdmgclntbank
                                WHERE
                                    refnum = zmrap00_l_appls(l_apindx).refnum
                                    AND bankcd = zmrap00_l_appls(l_apindx).apdjcd
                                    AND branchcd = zmrap00_l_appls(l_apindx).apdkcd
                                    AND bankacckey = zmrap00_l_appls(l_apindx).apeicd
                                    AND bnkactyp = zmrap00_l_appls(l_apindx).apbkst;

                                IF bank_cnt = 0 THEN
                                    tmp_bankaccdsc := zmrap00_l_appls(l_apindx).apchtx;
                                    v_errormsg := 'BANKACCOUNT :';
                                    INSERT INTO titdmgclntbank (
                                        refnum,
                                        seqno,
                                        currto,
                                        bankcd,
                                        branchcd,
                                        facthous,
                                        bankacckey,
                                        crdtcard,
                                        bankaccdsc,
                                        bnkactyp,
                                        transhist
                                    ) VALUES (
                                        zmrap00_l_appls(l_apindx).refnum,
                                        zmrap00_l_appls(l_apindx).seqno,
                                        '99999999',
                                        nvl(zmrap00_l_appls(l_apindx).apdjcd, '  '),
                                        nvl(zmrap00_l_appls(l_apindx).apdkcd, '  '),
                                        '98',
                                        nvl(zmrap00_l_appls(l_apindx).apeicd, '  '),
                                        '                    ',
                                        nvl(zmrap00_l_appls(l_apindx).apchtx, '  '),
                                        nvl(zmrap00_l_appls(l_apindx).apbkst, ' '),
                                        'N'
                                    );

                                    v_output_count := v_output_count + 1;
                                ELSE
                                    IF substr(l_app_old, 1, 8) = zmrap00_l_appls(l_apindx).refnum AND tmp_bankaccdsc <> zmrap00_l_appls
                                    (l_apindx).apchtx THEN
                                        v_errormsg := 'ACCOUNT NAME UPDATE:';
                                        UPDATE titdmgclntbank
                                        SET
                                            bankaccdsc = zmrap00_l_appls(l_apindx).apchtx
                                        WHERE
                                            refnum = zmrap00_l_appls(l_apindx).refnum
                                            AND bankcd = zmrap00_l_appls(l_apindx).apdjcd
                                            AND branchcd = zmrap00_l_appls(l_apindx).apdkcd
                                            AND bankacckey = zmrap00_l_appls(l_apindx).apeicd
                                            AND bnkactyp = zmrap00_l_appls(l_apindx).apbkst;

                                    END IF;
                                END IF;

                            ELSIF zmrap00_l_appls(l_apindx).bnk = 'BankAccount' AND zmrap00_l_appls(l_apindx).apc7cd <> 'FSH' AND
                            ( zmrap00_l_appls(l_apindx).apdjcd IS NULL OR zmrap00_l_appls(l_apindx).apeicd IS NULL OR zmrap00_l_appls
                            (l_apindx).apbkst IS NULL OR zmrap00_l_appls(l_apindx).apdkcd IS NULL ) THEN
                                v_errormsg := 'BANK ACCOUNT DETAILS CANNOT BE NULL FOR NON FSH POLICY';
                                error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
                                l_err_flg := 1;
                            END IF;

                        EXCEPTION
                            WHEN OTHERS THEN
                                v_errormsg := v_errormsg
                                              || ' '
                                              || sqlerrm;
                                error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
                                l_err_flg := 1;
                        END;

                        IF ( zmrap00_l_appls(l_apindx).refnum <> substr(l_app_old, 1, 8) ) AND ( l_app_old IS NOT NULL ) THEN
                            IF l_err_flg = 1 THEN
                                ROLLBACK;
                                l_err_flg := 0;
                            END IF;
                            COMMIT;
                        END IF;

                        l_app_old := zmrap00_l_appls(l_apindx).apcucd;
                        l_credit_old := l_credit;
                        l_date_old := nvl(l_date, '01-01-01');
                    END LOOP;

                    EXIT WHEN zmrap00_cur%notfound;
                END LOOP;

                CLOSE zmrap00_cur;
            END LOOP;

            EXIT WHEN zmrap00_appl_cur%notfound;
        END LOOP;

        COMMIT;
        CLOSE zmrap00_appl_cur;
-- DMPR PJ BANK Logic transformations
        pj_cnt := 0;
        SELECT
            COUNT(1)
        INTO pj_cnt
        FROM
            dmpr1;

        v_input_count := v_input_count + pj_cnt;
        v_errormsg := 'DMPR-PJ';
        MERGE INTO titdmgclntbank tgt
        USING (
                  SELECT
                      *
                  FROM
                      dmpr1
              )
        src ON ( tgt.refnum = src.refnum
                 AND tgt.bankacckey = src.bankacckey
                 AND tgt.bnkactyp = src.bnkactyp
                 AND tgt.bankcd = src.bankcd
                 AND tgt.branchcd = src.branchcd )
        WHEN NOT MATCHED THEN
        INSERT (
            refnum,
            seqno,
            currto,
            bankcd,
            branchcd,
            facthous,
            bankacckey,
            crdtcard,
            bankaccdsc,
            bnkactyp,
            transhist )
        VALUES
            ( src.refnum,
              src.seqno,
              src.currto,
              src.bankcd,
              src.branchcd,
              src.facthous,
              src.bankacckey,
              src.crdtcard,
              src.bankaccdsc,
              src.bnkactyp,
              src.transhist );

        v_output_count := v_output_count + ( SQL%rowcount );
        v_errormsg := 'Before count chk:';
        SELECT
            COUNT(1)
        INTO l_outputcount
        FROM
            titdmgclntbank;

        IF v_output_count > l_outputcount THEN
            v_output_count := l_outputcount;
        END IF;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            ROLLBACK;
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'F', v_input_count, v_output_count);

    END dm_clntbnk_transform;

-- Procedure for old ----- DM client bank transform Bank transformations <ENDS> Here
*/

    PROCEDURE dm_clntbnk_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit           PLS_INTEGER := p_array_size;
        v_errormsg        VARCHAR2(2000) := ' ';
        l_credit          VARCHAR2(30) := NULL;
        l_credit_old      VARCHAR2(30) := NULL;
        l_app_old         VARCHAR2(30) := NULL;
        l_currdt          VARCHAR2(8);
        l_date            DATE := NULL;
        l_date_old        DATE := NULL;
        bank_cnt          NUMBER := 0;
        pj_cnt            NUMBER := 0;
        temp_no           NUMBER;
        CURSOR zmrap00_appl_cur IS
        SELECT
            apcucd
        FROM
            (
                SELECT
                    ROWNUM n,
                    apcucd
                FROM
                    zmrap00 a
                WHERE
                    NOT EXISTS (
                        SELECT
                            'X'
                        FROM
                            titdmgclntbank
                        WHERE
                            refnum = substr(apcucd, 1, 8)
                    )
            )
        ORDER BY
            apcucd;

        CURSOR zmrap00_cur (
            c1 IN VARCHAR2
        ) IS
        SELECT
            apcucd,
            substr(apcucd, 1, 8) refnum,
            substr(apcucd, - 3) seqno,
            apc0cd,
            apdjcd,
            --nvl(apdjcd, '    ') AS apdjcd,
            --apyob3,
            nvl(apyob3, '000000') AS apyob3,
            apc6cd,
            apdkcd,
            endorsercode,
            crdt,
            bnk,
            apeicd,
            --nvl(apeicd, '          ') AS apeicd,
            apchtx,
            apbkst,
            --nvl(apbkst, ' ') AS apbkst,
            apb5tx,
            c.rptfpst
        FROM
            (
                SELECT
                    *
                FROM
                    zmrap00
                WHERE
                    ( apblst IN (
                        1,
                        3, 5
                    )
                      OR apdlcd IN (
                        'ID',
                        'M2',
                        'S2',
                        'CNV'
                    ) )
            ) a,
            (
                SELECT
                    endorsercode,
                    MAX(decode(filetype, 'CreditCard', 'CreditCard')) crdt,
                    MAX(decode(filetype, 'BankAccount', 'BankAccount')) bnk
                FROM
                    card_endorser_list
                WHERE
                    filetype IN (
                        'CreditCard',
                        'BankAccount'
                    )
                GROUP BY
                    endorsercode
            ) b,
            stagedbusr2.zmrrpt00 c
        WHERE
            a.apc6cd = b.endorsercode
            AND a.apc7cd = c.rptbtcd
            AND a.apcucd = c1
        ORDER BY
            apcucd;

        TYPE zmrap00_appcur IS
            TABLE OF zmrap00_appl_cur%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF zmrap00_cur%rowtype;
        TYPE t_clnbnk_crd_t IS
            TABLE OF titdmgclntbank%rowtype;
        zmrap00_appls     zmrap00_appcur;
        zmrap00_l_appls   zmrap00_cur_t;
        l_outputcount     NUMBER := 0;
        tmp_bankaccdsc    titdmgclntbank.bankaccdsc%TYPE;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_outputcount := 0;
        v_errormsg := 'DM_clntbnk_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgclntbank
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgclntbank.refnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTBANK for Delta Load
        END IF;

        OPEN zmrap00_appl_cur;
        LOOP
            FETCH zmrap00_appl_cur BULK COLLECT INTO zmrap00_appls LIMIT c_limit;
            v_input_count := v_input_count + zmrap00_appls.count;
            FOR appln_indx IN 1..zmrap00_appls.count LOOP
                OPEN zmrap00_cur(zmrap00_appls(appln_indx).apcucd);
                LOOP
                    FETCH zmrap00_cur BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
                    FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
                        l_currdt := NULL;
                        application_no := zmrap00_l_appls(l_apindx).apcucd;
                        BEGIN -- Start for logic
                        dbms_output.put_line(application_no);
                            IF zmrap00_l_appls(l_apindx).apyob3 IN (
                                '000000',
                                '999999'
                            ) THEN
                                l_currdt := '99999999';
                                l_date := TO_DATE('00010101', 'YYYYMMDD');
                            ELSE
                                l_currdt := zmrap00_l_appls(l_apindx).apyob3;
                                l_date := last_day(to_date(l_currdt, 'YYYYMM'));
                            END IF;

                            IF zmrap00_l_appls(l_apindx).crdt = 'CreditCard' AND zmrap00_l_appls(l_apindx).apc0cd IS NOT NULL THEN
                                l_credit := zmrap00_l_appls(l_apindx).apc0cd;
                                IF substr(l_app_old, 1, 8) = zmrap00_l_appls(l_apindx).refnum AND l_credit_old = l_credit AND ( l_date
                                > l_date_old OR l_currdt = '99999999' ) THEN
                                    v_errormsg := 'UPDATE';
                                    UPDATE titdmgclntbank
                                    SET
                                        currto = to_number(decode(l_currdt, '99999999', '99999999', to_char(l_date, 'YYYYMMDD')))
                                        ,
                                        seqno = zmrap00_l_appls(l_apindx).seqno
                                    WHERE
                                        refnum = substr(l_app_old, 1, 8)
                                        AND crdtcard = l_credit_old;

                                    v_output_count := v_output_count + 1;
                                ELSIF substr(l_app_old, 1, 8) = substr(zmrap00_l_appls(l_apindx).apcucd, 1, 8) AND l_credit_old =
                                l_credit AND l_date <= l_date_old THEN
                                    NULL;
                                ELSE
                                    v_errormsg := 'CREDITCARD';
                                    INSERT INTO titdmgclntbank (
                                        refnum,
                                        seqno,
                                        currto,
                                        bankcd,
                                        branchcd,
                                        facthous,
                                        bankacckey,
                                        crdtcard,
                                        bankaccdsc,
                                        bnkactyp,
                                        transhist
                                    ) VALUES (
                                        zmrap00_l_appls(l_apindx).refnum,
                                        zmrap00_l_appls(l_apindx).seqno,
                                        to_number(decode(l_currdt, '99999999', '99999999', to_char(l_date, 'YYYYMMDD'))),
                                        '9999',--nvl(ZMRAP00_l_appls(l_apindx).APDJCD,'  '),
                                        '999',--nvl(ZMRAP00_l_appls(l_apindx).APDKCD,'  '),
                                        '99',
                                        nvl(zmrap00_l_appls(l_apindx).apeicd, '  '),
                                        l_credit,
                                        nvl(zmrap00_l_appls(l_apindx).apb5tx, '  '),--NVL(ZMRAP00_l_appls(l_apindx).APCHTX,'  '),
                                        'CC',--nvl(ZMRAP00_l_appls(l_apindx).APBKST,' '),
                                        'N'
                                    );

                                    v_output_count := v_output_count + 1;
                                END IF;

                            END IF;

                            bank_cnt := 0;
                            IF zmrap00_l_appls(l_apindx).bnk = 'BankAccount' AND zmrap00_l_appls(l_apindx).rptfpst <> 'F' AND zmrap00_l_appls
                            (l_apindx).apdjcd IS NOT NULL AND zmrap00_l_appls(l_apindx).apeicd IS NOT NULL AND zmrap00_l_appls(l_apindx
                            ).apbkst IS NOT NULL THEN
                                v_errormsg := 'BANKACCOUNT CHK:';
                                SELECT
                                    COUNT(1)
                                INTO bank_cnt
                                FROM
                                    titdmgclntbank
                                WHERE
                                    refnum = zmrap00_l_appls(l_apindx).refnum
                                    AND bankcd = zmrap00_l_appls(l_apindx).apdjcd
                                    AND branchcd = zmrap00_l_appls(l_apindx).apdkcd
                                    AND bankacckey = zmrap00_l_appls(l_apindx).apeicd
                                    AND bnkactyp = zmrap00_l_appls(l_apindx).apbkst;

                                IF bank_cnt = 0 THEN
                                    tmp_bankaccdsc := zmrap00_l_appls(l_apindx).apchtx;
                                    v_errormsg := 'BANKACCOUNT :';
                                    INSERT INTO titdmgclntbank (
                                        refnum,
                                        seqno,
                                        currto,
                                        bankcd,
                                        branchcd,
                                        facthous,
                                        bankacckey,
                                        crdtcard,
                                        bankaccdsc,
                                        bnkactyp,
                                        transhist
                                    ) VALUES (
                                        zmrap00_l_appls(l_apindx).refnum,
                                        zmrap00_l_appls(l_apindx).seqno,
                                        '99999999',
                                        nvl(zmrap00_l_appls(l_apindx).apdjcd, '  '),
                                        nvl(zmrap00_l_appls(l_apindx).apdkcd, '  '),
                                        '98',
                                        nvl(zmrap00_l_appls(l_apindx).apeicd, '  '),
                                        '                    ',
                                        nvl(zmrap00_l_appls(l_apindx).apchtx, '  '),
                                        nvl(zmrap00_l_appls(l_apindx).apbkst, ' '),
                                        'N'
                                    );

                                    v_output_count := v_output_count + 1;
                                ELSE
                                    IF substr(l_app_old, 1, 8) = zmrap00_l_appls(l_apindx).refnum AND tmp_bankaccdsc <> zmrap00_l_appls
                                    (l_apindx).apchtx THEN
                                        v_errormsg := 'ACCOUNT NAME UPDATE:';
                                        UPDATE titdmgclntbank
                                        SET
                                            bankaccdsc = zmrap00_l_appls(l_apindx).apchtx
                                        WHERE
                                            refnum = zmrap00_l_appls(l_apindx).refnum
                                            AND bankcd = zmrap00_l_appls(l_apindx).apdjcd
                                            AND branchcd = zmrap00_l_appls(l_apindx).apdkcd
                                            AND bankacckey = zmrap00_l_appls(l_apindx).apeicd
                                            AND bnkactyp = zmrap00_l_appls(l_apindx).apbkst;

                                    END IF;
                                END IF;

                            ELSIF zmrap00_l_appls(l_apindx).bnk = 'BankAccount' AND zmrap00_l_appls(l_apindx).rptfpst <> 'F' AND
                            ( zmrap00_l_appls(l_apindx).apdjcd IS NULL OR zmrap00_l_appls(l_apindx).apeicd IS NULL OR zmrap00_l_appls
                            (l_apindx).apbkst IS NULL OR zmrap00_l_appls(l_apindx).apdkcd IS NULL ) THEN
                                v_errormsg := 'BANK ACCOUNT DETAILS CANNOT BE NULL FOR PAID POLICY';
                                error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
                                l_err_flg := 1;
                            END IF;

                        EXCEPTION
                            WHEN OTHERS THEN
                                v_errormsg := v_errormsg
                                              || ' '
                                              || sqlerrm;
                                error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
                                l_err_flg := 1;
                        END;

                        IF ( zmrap00_l_appls(l_apindx).refnum <> substr(l_app_old, 1, 8) ) AND ( l_app_old IS NOT NULL ) THEN
                            IF l_err_flg = 1 THEN
                                ROLLBACK;
                                l_err_flg := 0;
                            END IF;
                            COMMIT;
                        END IF;

                        l_app_old := zmrap00_l_appls(l_apindx).apcucd;
                        l_credit_old := l_credit;
                        l_date_old := nvl(l_date, to_date('00010101','yyyymmdd'));
                    END LOOP;

                    EXIT WHEN zmrap00_cur%notfound;
                END LOOP;

                CLOSE zmrap00_cur;
            END LOOP;

            EXIT WHEN zmrap00_appl_cur%notfound;
        END LOOP;

        COMMIT;
        CLOSE zmrap00_appl_cur;
-- DMPR PJ BANK Logic transformations
        pj_cnt := 0;
        SELECT
            COUNT(1)
        INTO pj_cnt
        FROM
            dmpr1;

        v_input_count := v_input_count + pj_cnt;
        v_errormsg := 'DMPR-PJ';
        MERGE INTO titdmgclntbank tgt
        USING (
                  SELECT
                      *
                  FROM
                      dmpr1
              )
        src ON ( tgt.refnum = src.refnum
                 AND tgt.bankacckey = src.bankacckey
                 AND tgt.bnkactyp = src.bnkactyp
                 AND tgt.bankcd = src.bankcd
                 AND tgt.branchcd = src.branchcd )
        WHEN NOT MATCHED THEN
        INSERT (
            refnum,
            seqno,
            currto,
            bankcd,
            branchcd,
            facthous,
            bankacckey,
            crdtcard,
            bankaccdsc,
            bnkactyp,
            transhist )
        VALUES
            ( src.refnum,
              src.seqno,
              src.currto,
              src.bankcd,
              src.branchcd,
              src.facthous,
              src.bankacckey,
              src.crdtcard,
              src.bankaccdsc,
              src.bnkactyp,
              src.transhist );

        v_output_count := v_output_count + ( SQL%rowcount );
        v_errormsg := 'Before count chk:';
        SELECT
            COUNT(1)
        INTO l_outputcount
        FROM
            titdmgclntbank;

        IF v_output_count > l_outputcount THEN
            v_output_count := l_outputcount;
        END IF;
        Update stagedbusr2.titdmgclntbank set refnum = concat(refnum,'00');
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'F', v_input_count, v_output_count);

        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            ROLLBACK;
            temp_no := control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
            ,
            'F', v_input_count, v_output_count);

    END dm_clntbnk_transform;

-- Procedure for DM client bank transform Bank transformations <ENDS> Here

--ANNUAL PREMIUM PROCEDURE
-- Procedure for DM ANNUAL PREMIUM transformations <STARTS> Here

    PROCEDURE dm_annualprem_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        TYPE ig_array IS
            TABLE OF temp1%rowtype;
        st_data        ig_array;
        v_app          titdmgmbrindp2%rowtype;
        l_appno        VARCHAR2(20);
        ig_starttime   TIMESTAMP;
        ig_endtime     TIMESTAMP;
        v_errormsg     VARCHAR2(2000);
        temp_no        NUMBER;
        CURSOR cur_tempt IS
        SELECT
            zmric00.iccicd,
            zmric00.icjgcd,
            zmric00.icbmst,
            (
                CASE
                    WHEN zmric00.icbmst IN (
                        '979',
                        '980',
                        '981',
                        '982',
                        '984',
                        '985',
                        '986',
                        '988',
                        '991',
                        '992',
                        '993',
                        '994',
                        '995',
                        '996',
                        '997'
                    ) THEN
                        ( zmric00.icb0va * 1000 )
                    ELSE
                        zmric00.icb0va
                END
            ) AS icb0va,
            zmric00.icb3va,
            zmris00.isb0nb,
            zmris00.isa3st,
            zmrap00.aplacd
        FROM
            ( zmric00 left
            JOIN zmris00 ON zmric00.iccicd = zmris00.iscicd ) left
            JOIN zmrap00 ON zmris00.iscucd = zmrap00.apcucd
        WHERE
            ( ( zmrap00.apc7cd = 'FSH'
                AND substr(zmrap00.apcucd, - 3) = '000' ) );

        CURSOR a1 IS
        SELECT
            apcucd
        FROM
            zmrap00
        WHERE
            substr(apcucd, - 3) = '000'
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgmbrindp2
                WHERE
                    refnum = substr(apcucd, 1, 8)
            )
        ORDER BY
            apcucd;

        CURSOR a2 (
            c1 IN VARCHAR2
        ) IS
        SELECT
            maxapcucd,
            apcvcd,
            apc7cd,
            apa2dt,
            icbmst,
            icb3va,
            hsuminsu,
            ztaxflg
        FROM
            (
                SELECT
                    maxapcucd,
                    zmrap00.apcucd,
                    zmrap00.apcvcd,
                    zmrap00.apc7cd,
                    zmrap00.apa2dt,
                    nvl2(zmric00.icbmst, '1' || zmric00.icbmst, zmric00.icbmst) AS icbmst,
                       --ZMRIC00.ICB0VA,
                    zmric00.icb3va,
                    (
                        CASE
                            WHEN zmric00.icbmst IN (
                                '979',
                                '980',
                                '981',
                                '982',
                                '984',
                                '985',
                                '986',
                                '988',
                                '991',
                                '992',
                                '993',
                                '994',
                                '995',
                                '996',
                                '997'
                            ) THEN
                                ( zmric00.icb0va * 1000 )
                            WHEN icbmst IN (
                                '976',
                                '977',
                                '978',
                                '983',
                                '987',
                                '989',
                                '990'
                            ) THEN
                                ( zmric00.icb0va * 1 )
                        END
                    ) AS hsuminsu,
                    (
                        CASE
                            WHEN substr(zmric00.icbmst, 1, 1) = '9' THEN
                                'Y'
                            ELSE
                                'N'
                        END
                    ) AS ztaxflg -- added for ITR4 Lot2 change
                FROM
                    zmrap00,
                    zmric00,
                    maxpolnum
                WHERE
                    zmrap00.apcucd = zmric00.iccucd
                    AND zmrap00.apcucd = minapcucd
                    AND zmrap00.apcucd = c1
                UNION ALL
                SELECT
                    maxapcucd,
                    apcucd,
                    apcvcd,
                    apc7cd,
                    apa2dt,
                    rider         icbmst,
                    installment   icb0va,
                    premium       icb3va,
                    'N' AS ztaxflg -- added for ZTAXFLG ITR4 Lot2 change
                FROM
                    (
                        SELECT
                            maxapcucd,
                            apcucd,
                            apcvcd,
                            apc7cd,
                            apa2dt,
                            rsaqst,
                            rsarst,
                            rsasst,
                            nvl2(value, '1' || value, value) AS rider,
                            0 installment,
                            0 premium
                        FROM
                            (
                                WITH t AS (
                                    SELECT
                                        maxapcucd,
                                        zmrap00.apcucd,
                                        zmrap00.apcvcd,
                                        zmrap00.apc7cd,
                                        apa2dt,
                                        rsfocd,
                                        rsb0cd,
                                        rsb1cd,
                                        rsb2cd,
                                        rsb3cd,
                                        rsb4cd,
                                        rsb5cd,
                                        rsaqst,
                                        rsarst,
                                        rsasst,
                                        decode(rsaqst, 1, '415') rd1,
                                        decode(rsarst, 1, '395') rd2,
                                        decode(rsasst, 1, '414') rd3
                                    FROM
                                        zmrap00,
                                        zmrrs00,
                                        maxpolnum
                                    WHERE
                                        zmrap00.apc2cd = zmrrs00.rsbvcd
                                        AND zmrap00.apc6cd = zmrrs00.rsfocd
                                        AND zmrap00.apc7cd = zmrrs00.rsbtcd
                                        AND zmrap00.apc8cd = zmrrs00.rsbucd
                                        AND zmrap00.apcucd = minapcucd
                                        AND zmrap00.apcucd = c1
                                ) --and ZMRAP00.APCUCD= a1)
                                SELECT
                                    *
                                FROM
                                    t UNPIVOT EXCLUDE NULLS ( value
                                        FOR col
                                    IN ( rsb0cd,
                                         rsb1cd,
                                         rsb2cd,
                                         rsb3cd,
                                         rsb4cd,
                                         rsb5cd,
                                         rd1,
                                         rd2,
                                         rd3 ) )
                            ) a
                    )
                WHERE
                    apcucd = c1
            ) a;

        a1rec          a1%rowtype;
        a2rec          a2%rowtype;
    BEGIN
        stg_starttime := systimestamp;
        v_errormsg := 'TEMP Table:';
        v_output_count := 0;
        v_input_count := 0;
        g_err_flg := 0;

--DELETE FROM TEMP1;commit;
        l_err_flg := 0;
        v_errormsg := 'DM_Annualprem_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgmbrindp2
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00   dt,
                        tmp_zmric00   dt2
                    WHERE
                        dt.apcucd = dt2.iccucd
                        AND substr(dt.apcucd, 1, 8) = substr(titdmgmbrindp2.refnum, 1, 8)
                    UNION
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00   rdt,
                        tmp_zmrrs00   rdt1
                    WHERE
                        rdt.apc2cd = rdt1.rsbvcd
                        AND rdt.apc6cd = rdt1.rsfocd
                        AND rdt.apc7cd = rdt1.rsbtcd
                        AND rdt.apc8cd = rdt1.rsbucd
                        AND substr(rdt.apcucd, 1, 8) = substr(titdmgmbrindp2.refnum, 1, 8)
                );

            COMMIT;
         -- Delete the records for all the records exists in DM_Annualprem_transform for Delta Load
        END IF;

        v_errormsg := 'Before TEMP1 Cursor:';
        OPEN cur_tempt;
        LOOP
            FETCH cur_tempt BULK COLLECT INTO st_data LIMIT p_array_size;
            v_errormsg := 'TEMP Table insert:';
            FORALL i IN 1..st_data.count
                INSERT INTO temp1 (
                    iccicd,
                    icjgcd,
                    icbmst,
                    icb0va,
                    icb3va,
                    isb0nb,
                    isa3st,
                    aplacd
                ) VALUES (
                    st_data(i).iccicd,
                    st_data(i).icjgcd,
                    st_data(i).icbmst,
                    st_data(i).icb0va,
                    st_data(i).icb3va,
                    st_data(i).isb0nb,
                    st_data(i).isa3st,
                    st_data(i).aplacd
                );

            COMMIT;
            EXIT WHEN cur_tempt%notfound;
        END LOOP;

        CLOSE cur_tempt;
        COMMIT;
        v_errormsg := 'TEMP Table update:';
        UPDATE temp1
        SET
            temp1.icb3va = nvl((
                SELECT
                    spln.lmpprem
                FROM
                    spln
                WHERE
                    temp1.isa3st = spln.sex
                    AND temp1.isb0nb = spln.age
                    AND temp1.icb0va = spln.zsumins
                    AND temp1.icbmst = spln.srcd
                    AND(temp1.aplacd * 12) = spln.durpol
            ), 0);
 --- UPDATING ZMRIC00 TABLE OF COLUMN ICB3VA

        COMMIT;
        v_errormsg := 'ZMRIC00 Table update:';
        UPDATE zmric00
        SET
            zmric00.icb3va = (
                SELECT
                    temp1.icb3va
                FROM
                    temp1
                WHERE
                    temp1.iccicd = zmric00.iccicd
                    AND temp1.icbmst = zmric00.icbmst
                    AND temp1.icjgcd = zmric00.icjgcd
            )
        WHERE
            EXISTS (
                SELECT
                    'x'
                FROM
                    temp1
                WHERE
                    temp1.iccicd = zmric00.iccicd
                    AND temp1.icbmst = zmric00.icbmst
                    AND temp1.icjgcd = zmric00.icjgcd
            );

        COMMIT;
        v_errormsg := 'A1 cur:';
        l_err_flg := 0;
        v_input_count := 0;
        v_output_count := 0;
        OPEN a1;
        LOOP
            FETCH a1 INTO a1rec;
            EXIT WHEN a1%notfound;
            v_input_count := v_input_count + 1;
            v_errormsg := 'A2 cur:';
            OPEN a2(a1rec.apcucd);
            LOOP
                FETCH a2 INTO a2rec;
                EXIT WHEN a2%notfound;
                l_appno := a2rec.maxapcucd;
                v_errormsg := 'Stage Insert :';
                application_no := a2rec.maxapcucd;
                BEGIN
                    INSERT INTO titdmgmbrindp2 (
                        refnum,
                        prodtyp,
                        effdate,
                        aprem,
                        hsuminsu,
                        ztaxflg
                    ) VALUES (
                        a2rec.maxapcucd,
                        a2rec.icbmst,
                        a2rec.apa2dt,
                        (
                            CASE
                                WHEN a2rec.apc7cd = 'FSH' THEN
                                    a2rec.icb3va
                                ELSE
                                    a2rec.icb3va * 12
                            END
                        ),
                        a2rec.hsuminsu,
                        a2rec.ztaxflg
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        error_logs('TITDMGMBRINDP2', application_no, v_errormsg);
                        l_err_flg := 1;
                END;

                IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
                    COMMIT;
                END IF;
            END LOOP;

            CLOSE a2;
        END LOOP;

        CLOSE a1;
        COMMIT;
        IF l_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('SPLN,ZMRIC00', 'TITDMGMBRINDP2', systimestamp, application_no, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('SPLN,ZMRIC00', 'TITDMGMBRINDP2', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            temp_no := control_log('SPLN,ZMRIC00', 'TITDMGMBRINDP2', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

    END dm_annualprem_transform;


-- Procedure for DM ANNUAL PREMIUM transformations <ENDS> Here

-- Procedure for DM DM_Refundhdr_transform <STARTS> Here

    PROCEDURE dm_refundhdr_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit               PLS_INTEGER := p_array_size;
        v_errormsg            VARCHAR2(2000) := ' ';
        l_credit              VARCHAR2(30) := NULL;
        l_credit_old          VARCHAR2(30) := NULL;
        l_app_old             VARCHAR2(60) := NULL;
        l_currdt              VARCHAR2(8);
        l_date                DATE := NULL;
        l_date_old            DATE := NULL;
        bank_cnt              NUMBER := 0;
        temp_no               NUMBER;
        CURSOR zmrap00_refhdr_cur IS
        SELECT
            apcucd,
            substr(apcucd, 1, 8) chdrnum,
            '002' AS zrefmtcd,
            apf8nb,
            apcycd,
            apf8nb         AS installmentprem,
            -- (select -(apf8nb) from zmrap00 b where substr(a.apcucd,1,8)=substr(b.apcucd,1,8)and substr(b.apcucd,-3)='000') as installmentprem,
           --  (apf8nb/(select -(apf8nb) from zmrap00 b where substr(a.apcucd,1,8)=substr(b.apcucd,1,8)and substr(b.apcucd,-3)='000')) as noofinstallment,rehearsal cahnge
            to_number(substr(((
                SELECT
                    icb3va
                FROM
                    (
                        SELECT
                            icbmst, icb3va
                        FROM
                            zmric00
                        WHERE
                            substr(a.apcucd, 1, 8) = substr(iccucd, 1, 8)
                            AND icb3va < 0
                        ORDER BY
                            iccucd, icbmst DESC
                    )
                WHERE
                    ROWNUM = 1
            ) /(
                SELECT
                    - icb3va
                FROM
                    (
                        SELECT
                            icbmst, icb3va
                        FROM
                            zmric00
                        WHERE
                            substr(a.apcucd, 1, 8) = substr(iccucd, 1, 8)
                            AND icb3va > 0
                        ORDER BY
                            iccucd, icbmst DESC
                    )
                WHERE
                    ROWNUM = 1
            )), 1, 6)) AS noofinstallment,
            apa2dt         effdate,
            CASE
                WHEN substr(apa2dt, - 2) = '01' THEN
                    to_char(last_day(to_date((apa2dt))), 'yyyymmdd')
                WHEN substr(apa2dt, - 2) <> '01' THEN
                    to_char((add_months(to_date(apa2dt), 1) - 1), 'yyyymmdd')
            END enddate,
            zposbdsm_r     zposbdsm,
            zposbdsy_r     zposbdsy,
            (
                SELECT DISTINCT
                    ig_al_code
                FROM
                    alter_reason_code
                WHERE
                    a.apdlcd = dm_al_code
                    AND ROWNUM = 1
            ) AS alterationcode,
            0 AS endorserrefund,
            '  ' AS endorserrefundstatus,
            (
                CASE
                    WHEN proccode IN (
                        'RQ',
                        'UP'
                    ) THEN
                        'RC'
                    ELSE
                        'PE'
                END
            ) AS zurichrefundstats,
            bankkey        AS bnkkey,
            nvl(bankacckey, '          ') AS bnkacckey,
            bankaccdsc,
            dmpr.bbkactyp,
            (
                CASE
                    WHEN a.apdjcd = dmpr.bankacckey THEN
                        'N'
                    ELSE
                        'Y'
                END
            ) AS refundacc,
            nvl(trandate, 99999999) AS trandate,
            'N' AS zcolflag,
            (
                CASE
                    WHEN proccode IN (
                        'RQ',
                        'UP'
                    ) THEN
                        paydate
                    ELSE
                        '99999999'
                END
            ) AS prdate,
            dmpr.cheqpfx   AS docprefix, -- Modified for #7620
            dmpr.cheqcoy   AS rdoccoy, -- Modified for #7620
             /*Commented for change in MSD for #7620 direct mapping
             (CASE DMPR.PAYDATE WHEN '0' THEN ' ' ELSE NVL2(PAYDATE,'CQ','  ') END) AS  docprefix, -- Modified for #7620
             (CASE DMPR.PAYDATE WHEN '0' THEN ' ' ELSE NVL2(PAYDATE,'1',' ') END) AS rdoccoy, -- Modified for #7620
           -- Commented for #7620 NVL2(PAYDATE,'CQ','  ') AS  docprefix,
             NVL2(PAYDATE,'1',' ') AS rdoccoy, */
            cheqbcde || cheqno AS rdocno
        FROM
            zmrap00 a,
            dmpr
        WHERE
            substr(apcucd, 1, 8) = chdrnum (+)
            AND apcycd BETWEEN 50 AND 69
            AND apf8nb < 0
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgref1
                WHERE
                    chdrnum = substr(apcucd, 1, 8)
            )
        ORDER BY
            apcucd;

        zmrap00_rhdrl_appls   zmrap00_refhdr_cur%rowtype;
        l_cnt                 DECIMAL(5, 3) := NULL;
        l_cnt1                NUMBER;
        l_refnum              INTEGER := 0;
        l_stdate              NUMBER := NULL;
        l_enddate             NUMBER := NULL;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_app_old := NULL;
        v_errormsg := 'DM_Refundhdr_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgref1
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgref1.chdrnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGREF1 for Delta Load
        END IF;

        v_errormsg := 'Master cursor';
        OPEN zmrap00_refhdr_cur;
        LOOP
            FETCH zmrap00_refhdr_cur INTO zmrap00_rhdrl_appls;
            EXIT WHEN zmrap00_refhdr_cur%notfound;
            v_input_count := v_input_count + 1;
            application_no := zmrap00_rhdrl_appls.apcucd;
            l_cnt := zmrap00_rhdrl_appls.noofinstallment;
               -- dbms_output.put_line(application_no||l_cnt);
            l_stdate := zmrap00_rhdrl_appls.effdate;
            l_enddate := zmrap00_rhdrl_appls.enddate;
            l_refnum := 0;
            IF instr(l_cnt, '.') > 0 THEN
                l_cnt := 1;
            ELSE
                l_cnt := l_cnt;
            END IF;

            l_cnt1 := l_cnt;
            LOOP
                EXIT WHEN l_cnt = 0;
                l_refnum := l_refnum + 1;
                v_errormsg := 'Insert step:';
                BEGIN
 -- Insert into TITDMGREF11(
                    INSERT INTO titdmgref1 (
                        refnum,
                        chdrnum,
                        zrefmtcd,
                        effdate,
                        prbilfdt,
                        prbiltdt,
                        zposbdsm,
                        zposbdsy,
                        zaltrcde01,
                        zrefundbe,
                        zrefundbz,
                        zenrfdst,
                        zzhrfdst,
                        bankkey,
                        bankacount,
                        bankaccdsc,
                        bnkactyp,
                        zrqbkrdf,
                        reqdate,
                        zcolflag,
                        paydate,
                        rdocpfx,
                        rdoccoy,
                        rdocnum
                    ) VALUES (
                        l_refnum,
                        zmrap00_rhdrl_appls.chdrnum,
                        zmrap00_rhdrl_appls.zrefmtcd,
                        zmrap00_rhdrl_appls.effdate,
                        l_stdate,
                        l_enddate,
                        zmrap00_rhdrl_appls.zposbdsm,
                        zmrap00_rhdrl_appls.zposbdsy,
                        zmrap00_rhdrl_appls.alterationcode,
                        zmrap00_rhdrl_appls.endorserrefund,
                        ( zmrap00_rhdrl_appls.installmentprem / l_cnt1 ),
                        zmrap00_rhdrl_appls.endorserrefundstatus,
                        zmrap00_rhdrl_appls.zurichrefundstats,
                        zmrap00_rhdrl_appls.bnkkey,
                        zmrap00_rhdrl_appls.bnkacckey,
                        zmrap00_rhdrl_appls.bankaccdsc,
                        zmrap00_rhdrl_appls.bbkactyp,
                        zmrap00_rhdrl_appls.refundacc,
                        zmrap00_rhdrl_appls.trandate,
                        zmrap00_rhdrl_appls.zcolflag,
                        zmrap00_rhdrl_appls.prdate,
                        zmrap00_rhdrl_appls.docprefix,
                        zmrap00_rhdrl_appls.rdoccoy,
                        zmrap00_rhdrl_appls.rdocno
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_errormsg := v_errormsg
                                      || ' '
                                      || sqlerrm;
                        error_logs('TITDMGREF1', application_no, v_errormsg);
                        l_err_flg := 1;
                END;

                l_stdate := to_char((add_months(to_date(l_stdate), 1)), 'yyyymmdd');

                l_enddate := to_char((add_months(to_date(l_enddate), 1)), 'yyyymmdd');

                l_cnt := l_cnt - 1;
                IF l_app_old <> zmrap00_rhdrl_appls.chdrnum THEN
                    IF l_err_flg = 1 THEN
                                     --ROLLBACK;
                        l_err_flg := 0;
                    END IF;
                    COMMIT;
                END IF;

                l_app_old := zmrap00_rhdrl_appls.chdrnum;
            END LOOP;

        END LOOP;

        CLOSE zmrap00_refhdr_cur;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

            COMMIT;
    END dm_refundhdr_transform;

-- Procedure for DM DM_Refundhdr_transform <ENDS> Here

-- Procedure for DM_policytran_transform <STARTS> Here

PROCEDURE DM_policytran_transform (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) AS
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    stg_endtime      TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    v_errormsg       VARCHAR2(2000);
    rows_inserted    Number;
    temp_no          NUMBER;
    l_app_old        Varchar2(20);
    c_limit          PLS_INTEGER := p_array_size;  

    CURSOR cur_data IS
        SELECT
            chdrnum,
            zseqno,
            effdate,
            client_category,
            mbrno,
            cltreln,
            zinsrole,
            clientno,
            zaltregdat,
            zaltrcde01,
            zinhdsclm,
            zuwrejflg,
            zstopbpj,
            ztrxstat,
            zstatresn,
            zaclsdat,
            apprdte,
            zpdatatxdte,
            zpdatatxflg,
            zrefundam,
            zpayinreq,
            zpayinreq2,
            crdtcard,
            preautno,
            bnkacckey01,
            nvl(
                CASE
                    WHEN endorserspec_tab1 = 'APC0CD' THEN
                        endorserspec1
                    WHEN endorserspec_tab1 = 'APB8TX' THEN
                        endorserspec1
                    WHEN substr(apcucd, - 3) = '000'
                         AND endorserspec1 IS NOT NULL THEN
                        endorserspec1
                    WHEN apdlcd = 'ID'
                         AND endorserspec1 IS NOT NULL THEN
                        endorserspec1
                    WHEN apdlcd <> 'ID'               THEN
                        LAG(endorserspec1 IGNORE NULLS, 1) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                            ORDER BY
                                apcucd
                        )
                END, '                    ') AS zenspcd01,
            nvl(
                CASE
                    WHEN endorserspec_tab2 = 'APC0CD' THEN
                        endorserspec2
                    WHEN endorserspec_tab2 = 'APB8TX' THEN
                        endorserspec2
                    WHEN substr(apcucd, - 3) = '000'
                         AND endorserspec2 IS NOT NULL THEN
                        endorserspec2
                    WHEN apdlcd = 'ID'
                         AND endorserspec2 IS NOT NULL THEN
                        endorserspec2
                    WHEN apdlcd <> 'ID'               THEN
                        LAG(endorserspec2 IGNORE NULLS, 1) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                            ORDER BY
                                apcucd
                        )
                END, '                    ') AS zenspcd02,
            nvl(
                CASE
                    WHEN cif_tab = 'APC0CD' THEN
                        cif
                    WHEN cif_tab = 'APB8TX' THEN
                        cif
                    WHEN substr(apcucd, - 3) = '000'
                         AND cif IS NOT NULL THEN
                        cif
                    WHEN apdlcd = 'ID'
                         AND cif IS NOT NULL THEN
                        cif
                    WHEN apdlcd <> 'ID'     THEN
                        LAG(cif IGNORE NULLS, 1) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                            ORDER BY
                                apcucd
                        )
                END, '               ') AS zcifcode,
            zddreqno,
            zworkplce2,
            bankaccdsc01,
            bankkey,
            bnkactyp01,
            currto,
            b1_zknjfulnm,
            b2_zknjfulnm,
            b3_zknjfulnm,
            b4_zknjfulnm,
            b5_zknjfulnm,
            b1_cltaddr01,
            b2_cltaddr01,
            b3_cltaddr01,
            b4_cltaddr01,
            b5_cltaddr01,
            b1_bnypc,
            b2_bnypc,
            b3_bnypc,
            b4_bnypc,
            b5_bnypc,
            b1_bnyrln,
            b2_bnyrln,
            b3_bnyrln,
            b4_bnyrln,
            b5_bnyrln
        FROM
            (
                SELECT DISTINCT
                    p.apcucd           AS apcucd,
                    p.apdlcd           AS apdlcd,
                    substr(p.apcucd, 1, 8) AS chdrnum,
                    substr(p.apcucd, - 3) AS zseqno,
                    p.apa2dt           AS effdate,
                    '1' AS client_category,
                    '000'
                    || substr(ris.iscicd, - 2) AS mbrno,
                    ris.isa4st         AS cltreln,
                    substr(flg.insur_role, - 1) AS zinsrole,
                    flg.stg_clntnum    AS clientno,
                    p.apcvcd           AS zaltregdat,
                    (
                        SELECT DISTINCT
                            ig_al_code
                        FROM
                            alter_reason_code
                        WHERE
                            p.apdlcd = dm_al_code
                            AND dm_al_code not like '*%' 
                            AND ROWNUM = 1
                    ) AS zaltrcde01,
                    'N' AS zinhdsclm,
                    CASE
                        WHEN substr(p.apdlcd, 1, 1) = '*'
                             AND substr(p.apcucd, - 3) = '000' THEN
                            'Y'
                        ELSE
                            'N'
                    END AS zuwrejflg,
                    'N' AS zstopbpj,
                    CASE
                        WHEN t.rptfpst = 'F'
                             AND p.apblst = '1' THEN
                            'AP'
                        WHEN t.rptfpst = 'F'
                             AND p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) = '*' THEN
                            'RJ'
                        WHEN t.rptfpst = 'F'
                             AND p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) <> '*' THEN
                            'AP'
                        WHEN t.rptfpst = 'F'
                             AND p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            'AP'
                        WHEN t.rptfpst = 'F'
                             AND p.apblst = '5' THEN
                            'RJ'
                        WHEN t.rptfpst = 'P'
                             AND p.apblst = '1' THEN
                            'AP'
                        WHEN t.rptfpst = 'P'
                             AND p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) = '*' THEN
                            'RJ'
                        WHEN t.rptfpst = 'P'
                             AND p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) <> '*' THEN
                            'AP'
                        WHEN t.rptfpst = 'P'
                             AND p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            'AP'
                        WHEN t.rptfpst = 'P'
                             AND p.apblst = '5' THEN
                            'RJ'
                    END AS ztrxstat,
                    (
                        SELECT
                            ig_r_code
                        FROM
                            decline_reason_code dcl
                        WHERE
                            dcl.dm_r_code = p.apdlcd
                    ) AS zstatresn,
                    p.apcvcd           AS zaclsdat,
                    p.apa2dt           AS apprdte,
                    CASE
                        WHEN apflst = '1'
                             AND length(apandt) = 6 THEN
                            apandt + 20000000
                        WHEN apflst = '1'
                             AND length(apandt) = 7 THEN
                            apandt + 19000000    --#9145   --#9145 17-jun-18
                        WHEN apflst = '1'
                             AND length(apandt) NOT IN (
                            6,
                            7
                        ) THEN
                            apandt  --#9145   --#9145 17-jun-18
                        WHEN apflst <> '1' THEN
                            zacmcldt
                        WHEN apflst IS NULL THEN
                            zacmcldt
                    END AS zpdatatxdte,
                    ' ' AS zpdatatxflg -- THIS COLUMN IS STRIKED OUT IN MAPPING SHEET
                    ,
                    NULL AS zrefundam,
                    CASE
                        WHEN p.apdlcd IN (
                            'T4',
                            'T8',
                            'TB',
                            'TD',
                            'TF',
                            'TZ'
                        ) THEN
                            'Y' 
                                                                                                                                                                                         --IF SYSDATE < 'end of pgp case' 
                        ELSE
                            'N'
                    END AS zpayinreq,
                    CASE
                        WHEN substr(p.apdlcd, 1, 2) IN (
                            'T4',
                            'T8',
                            'TB',
                            'TD',
                            'TF',
                            'TZ'
                        )
                             AND p1.zpgptodt IS NOT NULL 
                                                                                                                               --and  DMDATE < P1.ZPGPTODT 
                              THEN
                            'Y' ---#9194 18jun18 -- DMDATE IS IN PARAMETER
                                                                                                                    /* WHEN SUBSTR(P.APDLCD,1,2) in ( 'T4', 'T8', 'TB', 'TD', 'TF' ,'TZ') and P1.ZPGPTODT is not null 
                                                                                                                               --and  DMDATE > P1.ZPGPTODT 
                                                                                                                             then 'N' ---#9194 18jun18*/-- TO CHECK WITH ABHISHEK
                        WHEN substr(p.apdlcd, 1, 2) IN (
                            'T4',
                            'T8',
                            'TB',
                            'TD',
                            'TF',
                            'TZ'
                        )
                             AND p1.zpgptodt IS NULL THEN
                            'N'---#9194 18jun18
                        WHEN substr(p.apdlcd, 1, 2) NOT IN (
                            'T4',
                            'T8',
                            'TB',
                            'TD',
                            'TF',
                            'TZ'
                        ) THEN
                            'N'--#9194 18jun1
                        WHEN substr(p.apdlcd, 1, 2) IS NULL THEN
                            'N'---#9194 18jun18
                    END zpayinreq2,
                    CASE
                        WHEN endrsr.crdt_tab1 = 'APC0CD' THEN
                            apc0cd
                    END AS crdtcard,
                    substr(p.apyob4, - 6) AS preautno,
                    CASE
                        WHEN p.apeicd IS NOT NULL THEN
                            p.apeicd
                        ELSE
                            ' '
                    END AS bnkacckey01,
                    endrsr.endorserspec_tab1,
                    endrsr.endorserspec_tab2,
                    CASE
                        WHEN endrsr.endorserspec_tab1 = 'EICTID'
                             AND endrsr.endorser1_pos IS NOT NULL THEN
                            substr(e.eictid, endrsr.endorser1_pos, endrsr.endorser1_len)
                        WHEN endrsr.endorserspec_tab1 = 'EICTID'
                             AND endrsr.endorser1_pos IS NULL THEN
                            e.eictid
                        WHEN endrsr.endorserspec_tab1 = 'APC0CD' THEN
                            p.apc0cd
                        WHEN endrsr.endorserspec_tab1 = 'APB8TX' THEN
                            p.apb8tx
                    END AS endorserspec1,
                    CASE
                        WHEN endrsr.endorserspec_tab2 = 'EICTID'
                             AND endrsr.endorser2_pos IS NOT NULL THEN
                            substr(e.eictid, endrsr.endorser2_pos, endrsr.endorser2_len)
                        WHEN endrsr.endorserspec_tab2 = 'EICTID'
                             AND endrsr.endorser2_pos IS NULL THEN
                            e.eictid
                        WHEN endrsr.endorserspec_tab2 = 'APC0CD' THEN
                            p.apc0cd
                        WHEN endrsr.endorserspec_tab2 = 'APB8TX' THEN
                            p.apb8tx
                    END AS endorserspec2,
                    CASE
                        WHEN endrsr.cif = 'CIF'
                             AND endrsr.cif_pos IS NOT NULL THEN
                            substr(e.eictid, endrsr.cif_pos, endrsr.cif_len)
                        WHEN endrsr.cif = 'CIF'
                             AND endrsr.cif_pos IS NULL THEN
                            e.eictid
                        WHEN endrsr.cif_tab = 'APC0CD' THEN
                            p.apc0cd
                        WHEN endrsr.cif_tab = 'APB8TX' THEN
                            p.apb8tx
                    END AS cif,
                    CASE
                        WHEN substr(p.apcetx, 1, 8) IS NOT NULL
                             OR substr(p.apcetx, 1, 8) NOT LIKE '        %' THEN
                            substr(p.apcetx, 1, 8)
                        ELSE
                            ' '
                    END AS zddreqno,
                    substr(ris.isbzig, 1, 25) AS zworkplce2,
                    CASE
                        WHEN endrsr.bnk = 'BankAccount' THEN
                            p.apchtx
                        WHEN endrsr.crdt = 'CreditCard' THEN
                            p.apb5tx
                    END AS bankaccdsc01,
                    CASE
                        WHEN endrsr.bnk = 'BankAccount' THEN
                            concat(p.apdjcd, p.apdkcd)
                        WHEN endrsr.crdt = 'CreditCard' THEN
                            '9999999'
                    END AS bankkey,
                    CASE
                        WHEN endrsr.bnk = 'BankAccount' THEN
                            p.apbkst
                        WHEN endrsr.crdt = 'CreditCard' THEN
                            'CC'
                    END AS bnkactyp01,
                    CASE
                        WHEN endrsr.crdt = 'CreditCard'
                             AND p.apyob3 IS NOT NULL
                             AND p.apyob3 <> '000000' THEN
                            to_char(last_day(to_date(p.apyob3, 'YYYYMM')), 'YYYYMMDD')
                        WHEN p.apyob3 IS NULL
                             OR p.apyob3 = '000000' THEN
                            '99999999'
                        WHEN endrsr.bnk = 'BankAccount' THEN
                            '99999999'
                    END AS currto -- CLARIFICATION REQUIRED
                    ,
                    ris.b1_zknjfulnm   AS b1_zknjfulnm,
                    ris.b2_zknjfulnm   AS b2_zknjfulnm,
                    ris.b3_zknjfulnm   AS b3_zknjfulnm,
                    ris.b4_zknjfulnm   AS b4_zknjfulnm,
                    ris.b5_zknjfulnm   AS b5_zknjfulnm,
                    ris.b1_cltaddr01   AS b1_cltaddr01,
                    ris.b2_cltaddr01   AS b2_cltaddr01,
                    ris.b3_cltaddr01   AS b3_cltaddr01,
                    ris.b4_cltaddr01   AS b4_cltaddr01,
                    ris.b5_cltaddr01   AS b5_cltaddr01,
                    ris.b1_bnypc       AS b1_bnypc,
                    ris.b2_bnypc       AS b2_bnypc,
                    ris.b3_bnypc       AS b3_bnypc,
                    ris.b4_bnypc       AS b4_bnypc,
                    ris.b5_bnypc       AS b5_bnypc,
                    ris.b1_bnyrln      AS b1_bnyrln,
                    ris.b2_bnyrln      AS b2_bnyrln,
                    ris.b3_bnyrln      AS b3_bnyrln,
                    ris.b4_bnyrln      AS b4_bnyrln,
                    ris.b5_bnyrln      AS b5_bnyrln,
                    cif_tab
                                                                                   /* , CASE WHEN p.APDLCD IN ('C6') AND SUBSTR(p.APYOB6,5,8) = SUBSTR(p.APCUCD,1,8) THEN SUBSTR(p.APCUCD,1,8)
                                                                                                   ELSE ' '
                                                                                       END AS ZCONVPOLNO */ -- Column Removed in MSD2.3
                FROM
                    zmrap00           p
                    INNER JOIN persnl_clnt_flg   flg ON flg.apcucd = p.apcucd
                                                      AND flg.isa4st IS NOT NULL
                    INNER JOIN zmris00           ris ON ris.iscicd = flg.iscicd
                    LEFT JOIN zmrrpt00          t ON p.apc7cd = t.rptbtcd
                    LEFT JOIN zmrei00           e ON p.apcucd = e.eicucd
                    LEFT OUTER JOIN titdmgmbrindp1    p1 ON p1.refnum = ris.iscicd
                    LEFT JOIN (
                        SELECT
                            endorsercode,
                            MAX(decode(filetype, 'CreditCard', 'CreditCard')) crdt,
                            MAX(decode(filetype, 'CreditCard', fieldname)) crdt_tab1,
                            MAX(decode(filetype, 'BankAccount', 'BankAccount')) bnk,
                            MAX(decode(filetype, 'BankAccount', fieldname)) bank_tab1,
                            MAX(decode(filetype, 'EndorserSpecCode1', 'EndorserSpecCode1')) endorserspec1,
                            MAX(decode(filetype, 'EndorserSpecCode1', fieldname)) endorserspec_tab1,
                            MAX(decode(filetype, 'EndorserSpecCode1', st_pos)) endorser1_pos,
                            MAX(decode(filetype, 'EndorserSpecCode1', datalength)) endorser1_len,
                            MAX(decode(filetype, 'EndorserSpecCode2', 'EndorserSpecCode2')) endorserspec2,
                            MAX(decode(filetype, 'EndorserSpecCode2', fieldname)) endorserspec_tab2,
                            MAX(decode(filetype, 'EndorserSpecCode2', st_pos)) endorser2_pos,
                            MAX(decode(filetype, 'EndorserSpecCode2', datalength)) endorser2_len,
                            MAX(decode(filetype, 'CIF', 'CIF')) cif,
                            MAX(decode(filetype, 'CIF', fieldname)) cif_tab,
                            MAX(decode(filetype, 'CIF', st_pos)) cif_pos,
                            MAX(decode(filetype, 'CIF', datalength)) cif_len
                        FROM
                            card_endorser_list
                        WHERE
                            filetype IN (
                                'CreditCard',
                                'BankAccount',
                                'EndorserSpecCode1',
                                'EndorserSpecCode2',
                                'CIF'
                            )
                        GROUP BY
                            endorsercode
                    ) endrsr ON endrsr.endorsercode = p.apc6cd

                /*WHERE
                    substr(flg.chdrnum, 1, 8) = substr(ris.iscucd, 1, 8)
                    AND substr(ris.iscucd, 1, 8) = substr(p.apcucd, 1, 8)
                    --AND substr(f.chdrnum, 1, 8) = substr(p.apcucd, 1, 8) */
            )
        ORDER BY
            chdrnum,
            effdate;
    
    TYPE ig_array IS    TABLE OF cur_data%rowtype;
    st_data             cur_data%rowtype;
    --del_curr                             cur_data%rowtype;
    TYPE zmrap00_cur_t IS TABLE OF cur_data%rowtype;
    zmrap00_l_appls   zmrap00_cur_t;
BEGIN
    l_err_flg := 0;
    g_err_flg := 0;
    stg_starttime := systimestamp;
    v_input_count := 0;
    v_output_count := 0;
    IF p_delta = 'Y' THEN
        v_errormsg := 'For TITDMGPOLTRNH TABLE Load:';
    
    OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            DELETE FROM TITDMGPOLTRNH TRN
            WHERE
                TRN.CHDRNUM = st_data.CHDRNUM;

        END LOOP;
    CLOSE cur_data; 
    COMMIT;
         -- Delete the records for all the records exists in TITDMGPOLTRNH for Delta Load
    END IF;            
    v_errormsg := 'Error while insert into TITDMGPOLTRNH :';
    OPEN cur_data;
    LOOP
        FETCH cur_data BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
        v_input_count := v_input_count + zmrap00_l_appls.count;
        FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
            --dbms_output.put_line ('CHDRNUM : '||st_data.CHDRNUM);
            --v_input_count := v_input_count+1;
            l_app_old:= zmrap00_l_appls(l_apindx).CHDRNUM||zmrap00_l_appls(l_apindx).ZSEQNO;
            V_ERRORMSG:='INSERT TARGET:';
              --dbms_output.put_line ('CHDRNUM : '||st_data.CHDRNUM); 
          BEGIN    
            INSERT INTO titdmgpoltrnh (
                chdrnum,
                zseqno,
                effdate,
                client_category,
                mbrno,
                cltreln,
                zinsrole,
                clientno,
                zaltregdat,
                zaltrcde01,
                zinhdsclm,
                zuwrejflg,
                zstopbpj,
                ztrxstat,
                zstatresn,
                zaclsdat,
                apprdte,
                zpdatatxdte,
                zpdatatxflg,
                zrefundam,
                zpayinreq,
                crdtcard,
                preautno,
                bnkacckey01,
                zenspcd01,
                zenspcd02,
                zcifcode,
                zddreqno,
                zworkplce2,
                bankaccdsc01,
                bankkey,
                bnkactyp01,
                currto,
                b1_zknjfulnm,
                b2_zknjfulnm,
                b3_zknjfulnm,
                b4_zknjfulnm,
                b5_zknjfulnm,
                b1_cltaddr01,
                b2_cltaddr01,
                b3_cltaddr01,
                b4_cltaddr01,
                b5_cltaddr01,
                b1_bnypc,
                b2_bnypc,
                b3_bnypc,
                b4_bnypc,
                b5_bnypc,
                b1_bnyrln,
                b2_bnyrln,
                b3_bnyrln,
                b4_bnyrln,
                b5_bnyrln
                                                                                                                                                                          -- ,             ZCONVPOLNO
            ) VALUES (
                zmrap00_l_appls(l_apindx).chdrnum,
                zmrap00_l_appls(l_apindx).zseqno,
                zmrap00_l_appls(l_apindx).effdate,
                zmrap00_l_appls(l_apindx).client_category,
                zmrap00_l_appls(l_apindx).mbrno,
                zmrap00_l_appls(l_apindx).cltreln,
                zmrap00_l_appls(l_apindx).zinsrole,
                zmrap00_l_appls(l_apindx).clientno,
                zmrap00_l_appls(l_apindx).zaltregdat,
                zmrap00_l_appls(l_apindx).zaltrcde01,
                zmrap00_l_appls(l_apindx).zinhdsclm,
                zmrap00_l_appls(l_apindx).zuwrejflg,
                zmrap00_l_appls(l_apindx).zstopbpj,
                zmrap00_l_appls(l_apindx).ztrxstat,
                zmrap00_l_appls(l_apindx).zstatresn,
                zmrap00_l_appls(l_apindx).zaclsdat,
                zmrap00_l_appls(l_apindx).apprdte,
                zmrap00_l_appls(l_apindx).zpdatatxdte,
                zmrap00_l_appls(l_apindx).zpdatatxflg,
                zmrap00_l_appls(l_apindx).zrefundam,
                zmrap00_l_appls(l_apindx).zpayinreq,
                zmrap00_l_appls(l_apindx).crdtcard,
                zmrap00_l_appls(l_apindx).preautno,
                zmrap00_l_appls(l_apindx).bnkacckey01,
                zmrap00_l_appls(l_apindx).zenspcd01,
                zmrap00_l_appls(l_apindx).zenspcd02,
                zmrap00_l_appls(l_apindx).zcifcode,
                zmrap00_l_appls(l_apindx).zddreqno,
                zmrap00_l_appls(l_apindx).zworkplce2,
                zmrap00_l_appls(l_apindx).bankaccdsc01,
                zmrap00_l_appls(l_apindx).bankkey,
                zmrap00_l_appls(l_apindx).bnkactyp01,
                zmrap00_l_appls(l_apindx).currto,
                zmrap00_l_appls(l_apindx).b1_zknjfulnm,
                zmrap00_l_appls(l_apindx).b2_zknjfulnm,
                zmrap00_l_appls(l_apindx).b3_zknjfulnm,
                zmrap00_l_appls(l_apindx).b4_zknjfulnm,
                zmrap00_l_appls(l_apindx).b5_zknjfulnm,
                zmrap00_l_appls(l_apindx).b1_cltaddr01,
                zmrap00_l_appls(l_apindx).b2_cltaddr01,
                zmrap00_l_appls(l_apindx).b3_cltaddr01,
                zmrap00_l_appls(l_apindx).b4_cltaddr01,
                zmrap00_l_appls(l_apindx).b5_cltaddr01,
                zmrap00_l_appls(l_apindx).b1_bnypc,
                zmrap00_l_appls(l_apindx).b2_bnypc,
                zmrap00_l_appls(l_apindx).b3_bnypc,
                zmrap00_l_appls(l_apindx).b4_bnypc,
                zmrap00_l_appls(l_apindx).b5_bnypc,
                zmrap00_l_appls(l_apindx).b1_bnyrln,
                zmrap00_l_appls(l_apindx).b2_bnyrln,
                zmrap00_l_appls(l_apindx).b3_bnyrln,
                zmrap00_l_appls(l_apindx).b4_bnyrln,
                zmrap00_l_appls(l_apindx).b5_bnyrln
                -- , st_data.ZCONVPOLNO
            );
            V_OUTPUT_COUNT := V_OUTPUT_COUNT +1;
            EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_transform.error_logs('TITDMGPOLTRNH', zmrap00_l_appls(l_apindx).chdrnum, v_errormsg);
                        g_err_flg := 1;
            END;
        END LOOP; 
        EXIT WHEN cur_data%notfound;
        
        --dbms_output.put_line('rows inserted '|| rows_inserted);
    END LOOP;
    COMMIT;
    rows_inserted := v_input_count;
    CLOSE cur_data;
    COMMIT;

        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no :=dm_data_transform.control_log('zmris00,persnl_clnt_flg,ZMRRPT00,TITDMGREF1,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_transform.control_log('zmris00,persnl_clnt_flg,ZMRRPT00,TITDMGREF1,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);

            dbms_output.put_line(v_errormsg);
        END IF;

                             --dbms_output.put_line('Error while insert into TITDMGPOLTRNH ');
    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            error_logs('TITDMGMBRINDP1_trans', application_no, v_errormsg);
            temp_no := dm_data_transform.control_log('zmris00,persnl_clnt_flg,ZMRRPT00,TITDMGREF1,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);

            dbms_output.put_line(v_errormsg);
            return;
END DM_policytran_transform;

-- Procedure for DM_policytran_transform <ENDS> Here
-- Procedure for dm_polhis_cov <STARTS> Here
PROCEDURE dm_polhis_cov (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) AS
    V_INPUT_COUNT    NUMBER;
    V_OUTPUT_COUNT   NUMBER;
    stg_starttime    TIMESTAMP;
    stg_endtime      TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    v_errormsg       VARCHAR2(2000);
    rows_inserted    Number;
    p_delta1         CHAR(1) :='Y';
    l_app_old        VARCHAR2(20);
    temp_no          NUMBER;
              CURSOR cur_data IS
                                                          (  select DISTINCT REFNUM,MBRNO,DPNTNO,PRODTYP,EFFDATE, APREM,HSUMINSU,ZTAXFLG,NDRPREM,PRODTYP02 ,ZINSTYPE
FROM (

      SELECT  distinct  substr(P.APCUCD,1,8) AS REFNUM,
     
       CASE WHEN HPF.zslptyp = 'N' then CONCAT('000',SUBSTR(RIC.ICCICD,-2)) -- NAMED POLICY
             WHEN HPF.zslptyp = 'U' then CONCAT('000','01') --UNNAMED POLICY
        END AS MBRNO
      ,CASE WHEN HPF.zslptyp = 'N' then '00' -- NAMED POLICY
            ELSE                   -- UNNAMED POLICY
            DPN.DPNTNO
          END AS DPNTNO
      ,       CASE  WHEN RIC.ICDMCD = 'PO'  THEN    CONCAT('2',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'PTA' THEN    CONCAT('5',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'SPA' THEN    CONCAT('4',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'PFA' THEN    CONCAT('3',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'PFT' THEN    CONCAT('6',RIC.ICBMST)                     
                                                   WHEN RIC.ICDMCD = 'CLP' THEN    CONCAT('7',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD  = 'EQ' THEN     CONCAT('8',RIC.ICBMST)
                                  END AS PRODTYP
      ,       P.APA2DT AS EFFDATE
      ,                              RIC.ICB3VA AS APREM
      ,       RIC.ICB0VA AS HSUMINSU
      ,        CASE WHEN SUBSTR(RIC.ICBMST,1,1) ='9' THEN 'Y' 
                                                               ELSE 'N'
                                  END AS ZTAXFLG
      ,                              RIC.ICB7VA AS NDRPREM
      ,       CASE  WHEN RIC.ICDMCD = 'PO' AND ICBMST = '103' THEN    CONCAT('2',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'PTA' AND ICBMST = '103' THEN    CONCAT('5',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'SPA' AND ICBMST = '103' THEN    CONCAT('4',RIC.ICBMST)
                                                   WHEN RIC.ICDMCD = 'PFA' AND ICBMST = '103' THEN    CONCAT('3',RIC.ICBMST)
                                  ELSE ' '
                                  END AS PRODTYP02
      ,CASE WHEN HPF.zslptyp = 'N' then RIC.ICDMCD -- NAMED POLICY
            WHEN HPF.zslptyp = 'U' then RRC.RCB6CD--UNNAMED POLICY
             
        END AS ZINSTYPE
     -- ,RIC.ICDMCD AS ZINSTYPE
                                  
      from ZMRAP00 P 
                    LEFT OUTER JOIN ZMRIC00 RIC on SUBSTR(P.APCUCD,1,8) = SUBSTR(RIC.ICCUCD,1,8)
                    LEFT OUTER JOIN ZMRRC00 RRC ON RRC.RCBVCD = P.APC2CD
                    RIGHT OUTER JOIN DPNTNO_TABLE DPN ON DPN.CHDRNUM= substr(P.APCUCD,1,8)
                    left OUTER JOIN SPPLANCONVERTION SPP ON SPP.OLDZSALPLAN = P.APC2CD
                    left outer join STAGEDBUSR.ZSLPHPF hpf on hpf.zsalplan = spp.newzsalplan
                    where substr(ric.iccucd,-1)='0'
                    and substr(p.apcucd,-1)='0'

UNION ALL


  SELECT  distinct  substr(P.APCUCD,1,8) AS REFNUM
  
      , CASE WHEN HPF.zslptyp = 'N' then   CONCAT('000',SUBSTR(RIC.ICCICD,-2))  -- NAMED POLICY
             WHEN HPF.zslptyp = 'U' then CONCAT('000','01') --UNNAMED POLICY
        END AS MBRNO
      ,CASE WHEN HPF.zslptyp = 'N' then '00' -- NAMED POLICY
            ELSE                   -- UNNAMED POLICY
            DPN.DPNTNO
            END AS DPNTNO
         , ppf.prodtyp   

        ,       P.APA2DT AS EFFDATE
         ,       0 AS APREM
          ,       0 AS HSUMINSU
          ,        'N' AS ZTAXFLG
          ,        0 AS NDRPREM
          ,       ' '   AS PRODTYP02
         
          ,PPF.ZINSTYPE
          
          from ZMRAP00 P 
            LEFT OUTER JOIN ZMRIC00 RIC on SUBSTR(P.APCUCD,1,8) = SUBSTR(RIC.ICCUCD,1,8)
            RIGHT OUTER JOIN DPNTNO_TABLE DPN ON DPN.CHDRNUM= substr(P.APCUCD,1,8)
            left OUTER JOIN SPPLANCONVERTION SPP ON SPP.OLDZSALPLAN = P.APC2CD
            left outer join STAGEDBUSR.ZSLPHPF hpf on hpf.zsalplan = spp.newzsalplan
            left outer join stagedbusr.zslppf ppf on ppf.zsalplan = spp.newzsalplan
            where  --substr(ric.iccucd,-1)<>'0'
             ppf.zcovrid in ('R')
             and  substr(ric.iccucd,-1)='0'
             and substr(p.apcucd,-1)='0'
) 
 
 
) 
order by refnum, effdate, DPNTNO;


                             TYPE ig_array IS
                     TABLE OF cur_data%rowtype;
                             st_data           cur_data%rowtype;
              --            del_curr                            cur_data%rowtype;
BEGIN
    l_err_flg := 0;
    g_err_flg := 0;
    stg_starttime := sysdate;
    v_input_count := 0;
    V_OUTPUT_COUNT := 0;
              IF p_delta1 = 'Y' THEN
        v_errormsg := 'For TITDMGMBRINDP2 TABLE Load:';

                                           OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            DELETE FROM TITDMGMBRINDP2 BRI
            WHERE
                BRI.refnum = st_data.refnum;

        END LOOP;
       CLOSE cur_data; 
                             COMMIT;
         -- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
    END IF;            
    v_errormsg := 'Errow while insert into TITDMGMBRINDP2 :';
    OPEN cur_data;
    LOOP
    --dbms_output.put_line ('Entering Cursor loop ');

        FETCH cur_data INTO st_data;
        EXIT WHEN cur_data%notfound;

        l_app_old := st_data.REFNUM||ST_DATA.MBRNO;

        V_ERRORMSG:='INSERT :';
              --dbms_output.put_line ('CHDRNUM : '||st_data.REFNUM);
        V_INPUT_COUNT := V_INPUT_COUNT+1;

                                                          INSERT INTO TITDMGMBRINDP2 (
        REFNUM     ,
                                                          MBRNO ,
                                                          DPNTNO             ,
                                                          PRODTYP            ,
                                                          EFFDATE             ,
                                                          APREM ,
                                                          HSUMINSU,
                                                          ZTAXFLG             ,
                                                          NDRPREM          ,
                                                          PRODTYP02,
        ZINSTYPE)
                                                          VALUES (
                                                          st_data.REFNUM            ,
                                                          st_data.MBRNO              ,
                                                          st_data.DPNTNO             ,
                                                          st_data.PRODTYP           ,
                                                          st_data.EFFDATE            ,
                                                          st_data.APREM ,
                                                          st_data.HSUMINSU        ,
                                                          st_data.ZTAXFLG             ,
                                                          st_data.NDRPREM          ,
                                                          st_data.PRODTYP02,
        st_data.ZINSTYPE);
                             V_OUTPUT_COUNT := V_OUTPUT_COUNT +1;


              END LOOP; 
              CLOSE cur_data;
    COMMIT;
--dbms_output.put_line (' V_OUTPUT_COUNT : '||V_OUTPUT_COUNT);
                             IF L_ERR_FLG = 1 THEN 
                                        --ROLLBACK;
                                        L_ERR_FLG := 0;
                                    END IF;

                             IF (MOD(V_OUTPUT_COUNT,p_array_size)=0) THEN
                                           COMMIT;
                                END IF;
              IF G_ERR_FLG = 0 THEN
                             V_ERRORMSG := 'SUCCESS';
                             temp_no := CONTROL_LOG('ZMRAP00,ZMRIC00,DPNTNO_TABLE', 'TITDMGMBRINDP2', SYSTIMESTAMP,l_app_old,V_ERRORMSG, 'S', V_INPUT_COUNT, V_OUTPUT_COUNT);
                             ELSE
                             V_ERRORMSG := 'COMPLETED WITH ERROR';
                             temp_no := CONTROL_LOG('ZMRAP00,ZMRIC00,DPNTNO_TABLE', 'TITDMGMBRINDP2', SYSTIMESTAMP,l_app_old,V_ERRORMSG, 'F', V_INPUT_COUNT, V_OUTPUT_COUNT);
              END IF;

   exception 
                             when others then

                             V_ERRORMSG := V_ERRORMSG ||'-'||sqlerrm;
              ERROR_LOGS('TITDMGMBRINDP2',st_data.REFNUM||st_data.MBRNO,V_ERRORMSG);
END dm_polhis_cov;
-- Procedure for dm_polhis_cov <ENDS> Here
-- Procedure for DM_DPNTNO_INSERT <STARTS> Here

 PROCEDURE dm_DPNTNO_INSERT (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) AS
    V_INPUT_COUNT    NUMBER;
    V_OUTPUT_COUNT   NUMBER;
    stg_starttime    TIMESTAMP;
    stg_endtime      TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    v_errormsg       VARCHAR2(2000);
    rows_inserted    Number;
    p_delta1         CHAR(1) :='Y';
    l_app_old        VARCHAR2(20);
    temp_no          NUMBER;
              CURSOR cur_data IS
                                                          (
                                                             SELECT SUBSTR(P.APCUCD,1,8) CHDRNUM,
            SUBSTR(P.APCUCD,9,2) RNCNT,
            SUBSTR(P.APCUCD,10,1) ALCNT,
            P.APC7CD CNTTYP,
            P.APC2CD SLPLAN,
            'Named' INSURED,
            CONCAT('000',SUBSTR(RIC.ICCICD,-2)) MBRNO,
            '00' DPNTNO,
            RIC.ICDMCD INSTYPE,
            DECODE(RIC.ICDMCD,'PO',2||RIC.ICBMST,'PFA',3||RIC.ICBMST,'SPA',4||RIC.ICBMST,'PTA',5||RIC.ICBMST,'PFT',6||RIC.ICBMST,'CLP',7||RIC.ICBMST,'EQ',8||RIC.ICBMST) PRODTYP,
            RIC.ICB3VA PREM_J1,
            RIC.ICB3VA PREM_J2,
            RIC.ICB0VA SUMINS,
            P.APC6CD ENDRCDE
from ZMRAP00 P 
        LEFT OUTER JOIN ZMRIC00 RIC on SUBSTR(P.APCUCD,1,8) = SUBSTR(RIC.ICCUCD,1,8)
        left OUTER JOIN SPPLANCONVERTION SPP ON SPP.OLDZSALPLAN = P.APC2CD
        left outer join STAGEDBUSR.ZSLPHPF hpf on hpf.zsalplan = spp.newzsalplan
        where substr(ric.iccucd,-1)='0'
        and substr(p.apcucd,-1)='0'
        AND HPF.ZSLPTYP='N'
UNION ALL
SELECT CHDRNUM,
            RNCNT,
            ALCNT,
            CNTTYP,
            SLPLAN,
            INSURED,
            '00001' MBRNO,
            DECODE(INSURED, 'Main', '00', 'Spouse', '01', 'Relative', '02') DPNTNO,
            INSTYPE,
            PRODTYP,
            PREM_J1,
            PREM_J2,
            SUMINS,
            ENDRCDE
    FROM (
        SELECT SUBSTR(P.APCUCD,0,8) CHDRNUM,
            SUBSTR(P.APCUCD,9,2) RNCNT,
            SUBSTR(P.APCUCD,11,1) ALCNT,
            C.RCBUCD SUBCODE,
            C.RCBTCD CNTTYP,
            C.RCBVCD SLPLAN,
            'Main' INSURED,
            C.RCB6CD INSTYPE,
            DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
            C.RCBPVA PREM_J1,
            C.RCBSVA PREM_J2,
            C.RCBDVA SUMINS,
            C.RCFOCD ENDRCDE
        FROM  stagedbusr2.ZMRAP00 P,stagedbusr2.ZMRRC00 C
            WHERE
            P.APC2CD=C.RCBVCD
            AND P.APC6CD=C.RCFOCD
            AND P.APC7CD=C.RCBTCD
            AND P.APC8CD=C.RCBUCD
            --AND (P.APBLST ='1' OR P.APBLST = '3') -- code commented '3' should be writtenfor itr3
            AND P.APBLST ='1' 
        UNION ALL
        SELECT SUBSTR(P.APCUCD,0,8) CHDRNUM,
            SUBSTR(P.APCUCD,9,2) RNCNT,
            SUBSTR(P.APCUCD,11,1) ALCNT,
            C.RCBUCD SUBCODE,
            C.RCBTCD CNTTYP,
            C.RCBVCD SLPLAN,
            'Spouse' INSURED,
            C.RCB6CD INSTYPE,
            DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
            C.RCBQVA PREM_J1,
            C.RCBTVA PREM_J2,
            C.RCBEVA SUMINS,
            C.RCFOCD ENDRCDE
        FROM  stagedbusr2.ZMRAP00 P,stagedbusr2.ZMRRC00 C
            WHERE
            P.APC2CD=C.RCBVCD
            AND P.APC6CD=C.RCFOCD
            AND P.APC7CD=C.RCBTCD
            AND P.APC8CD=C.RCBUCD
            --AND (P.APBLST ='1' OR P.APBLST = '3') -- commented as p.apblst='3' pertains to ITR3
            AND P.APBLST ='1'
        UNION ALL
        SELECT SUBSTR(P.APCUCD,0,8) CHDRNUM,
            SUBSTR(P.APCUCD,9,2) RNCNT,
            SUBSTR(P.APCUCD,11,1) ALCNT,
            C.RCBUCD SUBCODE,
            C.RCBTCD CNTTYP,
            C.RCBVCD SLPLAN,
            'Relative' INSURED,
            C.RCB6CD INSTYPE,
            DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
            C.RCBRVA PREM_J1,
            C.RCBUVA PREM_J2,
            C.RCBFVA SUMINS,
            C.RCFOCD ENDRCDE
        FROM  stagedbusr2.ZMRAP00 P,stagedbusr2.ZMRRC00 C
             WHERE
             P.APC2CD=C.RCBVCD
             AND P.APC6CD=C.RCFOCD
             AND P.APC7CD=C.RCBTCD
             AND P.APC8CD=C.RCBUCD
             --AND (P.APBLST ='1' OR P.APBLST = '3') -- commented as p.apblst='3' pertains to ITR3
             AND P.APBLST ='1'
    ) UNNAMED, SPPLANCONVERTION SP, STAGEDBUSR.ZSLPHPF HPF WHERE 
        UNNAMED.PREM_J1 > 0 AND UNNAMED.PREM_J2 > 0
        AND UNNAMED.SLPLAN = SP.OLDZSALPLAN
        AND SP.NEWZSALPLAN = HPF.ZSALPLAN
        AND HPF.ZSLPTYP='U'
    and ALCNT = '0' );


                             TYPE ig_array IS
                     TABLE OF cur_data%rowtype;
                             st_data           cur_data%rowtype;
              --            del_curr                            cur_data%rowtype;
BEGIN
    l_err_flg := 0;
    g_err_flg := 0;
    stg_starttime := sysdate;
    v_input_count := 0;
    V_OUTPUT_COUNT := 0;
              IF p_delta1 = 'Y' THEN
            v_errormsg := 'For DPNTNO TABLE Load:';

                                           OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            DELETE FROM dpntno_table BRI
            WHERE
                BRI.CHDRNUM = st_data.CHDRNUM;

        END LOOP;
       CLOSE cur_data; 
                             COMMIT;
         -- Delete the records for all the records exists in DPNTNO_TABLE for Delta Load
    END IF;            
    v_errormsg := 'Errow while insert into DPNTNO_TABLE :';
    OPEN cur_data;
    LOOP
    --dbms_output.put_line ('Entering Cursor loop ');

        FETCH cur_data INTO st_data;
        EXIT WHEN cur_data%notfound;

        l_app_old := st_data.CHDRNUM||ST_DATA.MBRNO;

        V_ERRORMSG:='INSERT :';
             -- dbms_output.put_line ('CHDRNUM : '||st_data.CHDRNUM);
        V_INPUT_COUNT := V_INPUT_COUNT+1;

                                                          INSERT INTO DPNTNO_TABLE (
                                                                    CHDRNUM,
                                                                    RNCNT,
                                                                    ALCNT,
                                                                    CNTTYP,
                                                                    SLPLAN,
                                                                    INSURED,
                                                                    MBRNO,
                                                                    DPNTNO,
                                                                    INSTYPE,
                                                                    PRODTYP,
                                                                    PREM_J1,
                                                                    PREM_J2,
                                                                    SUMINS,
                                                                    ENDRCDE )
                                                          VALUES (
                                                                    st_data.CHDRNUM,
                                                                    st_data.RNCNT,
                                                                    st_data.ALCNT,
                                                                    st_data.CNTTYP,
                                                                    st_data.SLPLAN,
                                                                    st_data.INSURED,
                                                                    st_data.MBRNO,
                                                                    st_data.DPNTNO,
                                                                    st_data.INSTYPE,
                                                                    st_data.PRODTYP,
                                                                    st_data.PREM_J1,
                                                                    st_data.PREM_J2,
                                                                    st_data.SUMINS,
                                                                    st_data.ENDRCDE

        );
                             V_OUTPUT_COUNT := V_OUTPUT_COUNT +1;


              END LOOP; 
              CLOSE cur_data;
    COMMIT;

                             IF L_ERR_FLG = 1 THEN 
        --ROLLBACK;
        L_ERR_FLG := 0;
    END IF;

                             IF (MOD(V_OUTPUT_COUNT,p_array_size)=0) THEN
               COMMIT;
    END IF;
              IF G_ERR_FLG = 0 THEN
                             V_ERRORMSG := 'SUCCESS';
                            -- temp_no := CONTROL_LOG('ZMRAP00,ZMRIC00,DPNTNO_TABLE', 'DPNTNO_TABLE', SYSTIMESTAMP,l_app_old,V_ERRORMSG, 'S', V_INPUT_COUNT, V_OUTPUT_COUNT);
                             ELSE
                             V_ERRORMSG := 'COMPLETED WITH ERROR';
                             --temp_no := CONTROL_LOG('ZMRAP00,ZMRIC00,DPNTNO_TABLE', 'DPNTNO_TABLE', SYSTIMESTAMP,l_app_old,V_ERRORMSG, 'F', V_INPUT_COUNT, V_OUTPUT_COUNT);
              END IF;

   exception 
                             when others then

                             V_ERRORMSG := V_ERRORMSG ||'-'||sqlerrm;
             -- ERROR_LOGS('DPNTNO_TABLE',st_data.CHDRNUM||st_data.MBRNO,V_ERRORMSG);
END dm_DPNTNO_INSERT;

-- Procedure for DM_DPNTNO_INSERT <ENDS> Here

-- Procedure for  dm_polhis_apirno <STARTS> Here
PROCEDURE dm_polhis_apirno  (
p_array_size   IN   PLS_INTEGER DEFAULT 1000,
p_delta        IN   CHAR DEFAULT 'N'
) AS
v_input_count    NUMBER;
v_input_count_insert  NUMBER;
V_OUTPUT_COUNT_insert NUMBER;
v_output_count   NUMBER;
v_process_flg      Number;
stg_starttime    TIMESTAMP;
stg_endtime      TIMESTAMP;
l_err_flg        NUMBER := 0;
g_err_flg        NUMBER := 0;
v_errormsg       VARCHAR2(2000);
rows_inserted    Number;
paid_plan_count  Number;
PJ_fullkanjiname_temp     Varchar2(200);

MBRNO_update_count Number ;
l_app_old        VARCHAR2(20);
temp_no          NUMBER;
FREE_PLAN_LOAD   VARCHAR2(20);
FREE_V_INPUT_COUNT NUMBER;
FREE_V_OUTPUT_COUNT NUMBER;

his_refnum  titdmgcltrnhis.refnum%type;
his_lgivname  titdmgcltrnhis.lgivname%type;
his_lsurname titdmgcltrnhis.lsurname%type;
var_err      Varchar2(200);
v_STG_CLNTNUM PERSNL_CLNT_FLG.STG_CLNTNUM%TYPE;
prsl_CHDRNUM  PERSNL_CLNT_FLG.CHDRNUM%TYPE;
INSUR_ROLE    PERSNL_CLNT_FLG.INSUR_ROLE%TYPE;
DP1_ZINSROLE  TITDMGMBRINDP1.ZINSROLE%TYPE;
NEW_MBRNO     TITDMGMBRINDP1.MBRNO%TYPE;
/* BELOW CURSOR TO INSERT ROWS FROM MIPHSTDB INTO TITDMGAPIRNO (Assumption : MIPHSTDB  will contain Paid plan data) */

                                                                        CURSOR CUR_INSERT_TITDMGAPIRNO IS (
                                                                        SELECT 
                                                                         CHDRNUM, 
                                                                         MBRNO, 
                                                                         ZINSTYPE, 
                                                                         ZAPIRNO, 
                                                                         Fullkanjiname
                                                                        FROM STAGEDBUSR2.MIPHSTDB
                                                                        ) ORDER BY CHDRNUM, MBRNO, ZINSTYPE ;



/* BELOW CURSOR TO PULL THE ROWS FROM TITDMGAPIRNO  (Assumption : TITDMGAPIRNO  will contain Paid plan data) */

                                                                        Cursor cur_data_Post_Plan IS (
                                                                        select CHDRNUM ,MBRNO ,ZINSTYPE ,ZAPIRNO ,FULLKANJINAME
                                                                        from (
                                                                        SELECT  CHDRNUM
                                                                                         ,MBRNO
                                                                                         ,ZINSTYPE
                                                                                         ,ZAPIRNO
                                                                                         , Fullkanjiname
                                                                                         , count(chdrnum) over (partition by chdrnum) as count_chdrnum
                                                                                         FROM 
                                                                                         titdmgapirno
                                                                                         order by chdrnum,mbrno
                                                                        ) where count_chdrnum < 2
                                                                        and mbrno not in ('00001'))  ORDER BY CHDRNUM,MBRNO, ZINSTYPE;


/*Below cursor is to INSERT rows with Free plan */                                                                                                                                                          

                            CURSOR cur_data_Free_plan IS
                                  (select  DISTINCT
                                        BRI.REFNUM AS CHDRNUM
                                        ,BRI.MBRNO AS MBRNO
                                        ,BRI.ZINSTYPE AS ZINSTYPE
                                        ,ROW_NUMBER() OVER (PARTITION BY BRI.REFNUM ORDER BY BRI.MBRNO) as  ZAPIRNO
                                        , TRIM(substr((TRIM(p.apcbig)), 1,(
                                                                     CASE
                                                                     WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                                                    instr(TRIM(p.apcbig), unistr('\3000'))
                                                                     ELSE
                                                                    instr(TRIM(p.apcbig), '?')
                                                                     END
                                                                     ) - 1))  lsurname
                                        , TRIM(substr((TRIM(p.apcbig)),(
                                                                     CASE
                                                                     WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                                                    instr(TRIM(p.apcbig),unistr('\3000'))
                                                                     ELSE
                                                                    instr(TRIM(p.apcbig), '?')
                                                                     END
                                                                     ) + 1)) lgivname
                                        ,TRIM(substr((TRIM(p.apcbig)), 1,(
                                                                     CASE
                                                                     WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                                                    instr(TRIM(p.apcbig), unistr('\3000'))
                                                                     ELSE
                                                                    instr(TRIM(p.apcbig), '?')
                                                                     END
                                                                     ) - 1)) ||
                                                                    TRIM(substr((TRIM(p.apcbig)),(
                                                                     CASE
                                                                     WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                                                    instr(TRIM(p.apcbig),unistr('\3000'))
                                                                     ELSE
                                                                    instr(TRIM(p.apcbig), '?')
                                                                     END
                                                                     ) + 1)) as FULLKANJINAME

                                        from TITDMGMBRINDP2 BRI 
                                        LEFT OUTER JOIN ZMRAP00 P ON SUBSTR(P.APCUCD,1,8) = SUBSTR(BRI.REFNUM,1,8)
                                        LEFT OUTER JOIN ZMRRPT00 RPT ON RPT.RPTBTCD = P.APC7CD
                                        WHERE RPT.RPTFPST='F'
                                        ) order by CHDRNUM, MBRNO, ZINSTYPE;


              TYPE Insert_array IS TABLE OF CUR_INSERT_TITDMGAPIRNO%rowtype;

              insert_plan_data           CUR_INSERT_TITDMGAPIRNO%rowtype;

              TYPE post_plan_array IS  TABLE OF cur_data_Post_Plan%rowtype;
              Post_plan_data           cur_data_Post_Plan%rowtype;

              TYPE INSERT_FREEPLAN_ARRAY IS TABLE OF cur_data_Free_plan%ROWTYPE;
              INSERT_FREEPLAN_ROW       cur_data_Free_plan%ROWTYPE;

BEGIN
l_err_flg := 0;
g_err_flg := 0;
stg_starttime := systimestamp;

V_INPUT_COUNT := 0;
v_input_count_insert :=0;
V_OUTPUT_COUNT := 0;

FREE_V_INPUT_COUNT := 0;
FREE_V_OUTPUT_COUNT := 0;
paid_plan_count := 0;
V_OUTPUT_COUNT_insert:=0;





 IF p_delta = 'Y' THEN
v_errormsg := 'For TITDMGAPIRNO TABLE Load:';

OPEN CUR_INSERT_TITDMGAPIRNO;
LOOP
FETCH CUR_INSERT_TITDMGAPIRNO INTO insert_plan_data;
EXIT WHEN CUR_INSERT_TITDMGAPIRNO%notfound;

DELETE FROM TITDMGAPIRNO BRI
WHERE
BRI.CHDRNUM = insert_plan_data.CHDRNUM;

END LOOP;
CLOSE CUR_INSERT_TITDMGAPIRNO; 
     COMMIT;
-- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
END IF;            

  /* below code to INSERT ROWS FROM MIPHSTDB INTO TITDMGAPIRNO TABLE */
BEGIN
                   v_errormsg := 'Errow while INSERTING rows FROM MIPHSTDB INTO  TITDMGAPIRNO :';

          OPEN CUR_INSERT_TITDMGAPIRNO;
          LOOP
         FETCH CUR_INSERT_TITDMGAPIRNO INTO insert_plan_data;
          EXIT WHEN CUR_INSERT_TITDMGAPIRNO%notfound;
          l_app_old := insert_plan_data.CHDRNUM||insert_plan_data.MBRNO;
           V_ERRORMSG:='INSERT from MIPHSTDB INTO TITDMGAPIRNO :';
           v_input_count_insert := v_input_count_insert+1;

         INSERT INTO titdmgapirno(
                                   CHDRNUM
                                   ,MBRNO
                                   ,ZINSTYPE
                                   ,ZAPIRNO
                                   ,FULLKANJINAME) 
                                   values
                                   (insert_plan_data.CHDRNUM
                                   ,insert_plan_data.MBRNO
                                   ,insert_plan_data.ZINSTYPE
                                   ,insert_plan_data.ZAPIRNO
                                   ,insert_plan_data.FULLKANJINAME
                                   ); 
                       V_OUTPUT_COUNT_insert:= V_OUTPUT_COUNT_insert+1;

         END LOOP;
        COMMIT;
     EXCEPTION
     when others then
     IF L_ERR_FLG = 1 THEN 
                                  --ROLLBACK;
                                  L_ERR_FLG := 0;
     END IF;

     IF (MOD(V_OUTPUT_COUNT,p_array_size)=0) THEN
                      COMMIT;
     END IF;
   IF G_ERR_FLG = 0 THEN
                   V_ERRORMSG := 'SUCCESS';
                  temp_no := CONTROL_LOG('MIPHSTDB', 'TITDMGAPIRNO', SYSTIMESTAMP,FREE_PLAN_LOAD,V_ERRORMSG, 'S', v_input_count_insert, V_OUTPUT_COUNT_insert);
                   ELSE
                   V_ERRORMSG := 'COMPLETED WITH ERROR';
                   temp_no := CONTROL_LOG('MIPHSTDB', 'TITDMGAPIRNO', SYSTIMESTAMP,FREE_PLAN_LOAD,V_ERRORMSG, 'F', v_input_count_insert, V_OUTPUT_COUNT_insert);

     END IF;
CLOSE CUR_INSERT_TITDMGAPIRNO;

END;

BEGIN
/* BELOW CURSOR WILL PULL ALL THE ROWS FROM TITDMGAPIRNO TABLE WHICH DOES NOT HAVE MBRNO <> '00001' */
            v_errormsg := 'Errow while pulling rows for paid plan from TITDMGAPIRNO :';
                   OPEN cur_data_Post_Plan;
                   LOOP
                  FETCH cur_data_Post_Plan INTO Post_plan_data;
                  EXIT WHEN cur_data_Post_Plan%notfound;
                  l_app_old := Post_plan_data.CHDRNUM||Post_plan_data.MBRNO;
                  
                  V_ERRORMSG:='INSERT :';
                 
                  v_input_count := v_input_count+1;
            

            /* ABOVE PAID PLAN ROWS WITH (MBRNO <> '00001' IS CHECKED BELOW FURTHER TO GET THE NEW_MBRNO                        */
                    V_ERRORMSG := 'Errow while passing paid plan rows to get new_mbrno :';

                    v_process_flg := 0;
                     var_err := 'SUCCESS: NEW MBRNO UPDATED';
                    --DBMS_OUTPUT.PUT_LINE('AFTER V_PROCESS_FLG');
                    PJ_fullkanjiname_temp:='';
                     PJ_fullkanjiname_temp :=  case when instr(trim(Post_plan_data.Fullkanjiname),'?' ) = 0 then 
                                  trim(substr((trim(Post_plan_data.Fullkanjiname)),1,(
                                case when instr(trim(Post_plan_data.Fullkanjiname),'?' ) = 0 then 
                                          instr(trim(Post_plan_data.Fullkanjiname),unistr('\3000'))
                                     else instr(TRIM(Post_plan_data.Fullkanjiname), '?')
                                end)-1 ))
                                ||trim(substr((trim(Post_plan_data.Fullkanjiname)),(
                                            case when instr(trim(Post_plan_data.Fullkanjiname),'?' ) = 0 then 
                                                  instr(trim(Post_plan_data.Fullkanjiname),unistr('\3000'))
                                             else instr(TRIM(Post_plan_data.Fullkanjiname), '?')
                                        end)+1 ))
                                end;
                    begin
                    
                    select distinct his.refnum,  trim(his.lsurname),trim(his.lgivname) INTO his_refnum, his_lsurname,his_lgivname
                           from TITDMGCLTRNHIS his where substr(his.refnum,1,8) = Post_plan_data.chdrnum
                           and clntroleflg = 'I'
                           and pj_fullkanjiname_temp =trim(his.lsurname)||trim(his.lgivname) ;
                     
                    exception when no_data_found then
                      var_err := 'ERROR : Chdrnum does not exist in titdmgcltrnhis table ';
                        v_process_flg := 1;
                        GOTO INSERTZONE;
                       WHEN TOO_MANY_ROWS THEN 
                      var_err := 'ERROR :  Too many rows exist in titdmgcltrnhis table ';
                        v_process_flg := 1;
                        GOTO INSERTZONE; 
                    end; 
                    

                    Begin                                                          
                      select DISTINCT STG_CLNTNUM, CHDRNUM, substr(INSUR_ROLE,-1) into v_STG_CLNTNUM, prsl_CHDRNUM, INSUR_ROLE 
                      from PERSNL_CLNT_FLG  where STG_CLNTNUM= his_refnum
                      and substr(INSUR_ROLE,-1) in ('1','2','3');

                      If trim(v_STG_CLNTNUM) is null  Then
                          var_err := 'ERROR : STG_CLNTNUM IS NULL';
                                    v_process_flg := 1;
                                    GOTO INSERTZONE;
                      END IF;
                      exception when no_data_found then
                      var_err := 'ERROR :  Chdrnum does not exist in PERSNL_CLNT_FLG table ';
                        v_process_flg := 1;
                        GOTO INSERTZONE;
                       WHEN TOO_MANY_ROWS THEN 
                      var_err := 'ERROR :  Too many rows exist in PERSNL_CLNT_FLG table ';
                        v_process_flg := 1;
                        GOTO INSERTZONE; 
                      
                      end;

                       BEGIN  
                          Select CONCAT('000',MBRNO), ZINSROLE INTO NEW_MBRNO, DP1_ZINSROLE from TITDMGMBRINDP1 
                          where SUBSTR(refnum,1,8) = prsl_CHDRNUM
                          and zinsrole in ('1','2','3');

                          IF NEW_MBRNO IS NULL THEN
                          var_err := 'NEW_MBRNO IS NULL';
                                           v_process_flg := 1;
                                           GOTO INSERTZONE;
                          end if;


                          If (DP1_ZINSROLE <> INSUR_ROLE) OR (DP1_ZINSROLE NOT in (1,2,3)) OR (INSUR_ROLE NOT in (1,2,3)) THEN
                                           var_err := 'ERROR : ZINSROLE issue';
                                           v_process_flg := 1;
                                           GOTO INSERTZONE;
                          end if;
                            exception when no_data_found then
                                      var_err := 'ERROR :  Chdrnum does not exist in TITDMGMBRINDP1 table ';
                                        v_process_flg := 1;
                                        GOTO INSERTZONE;
                                       WHEN TOO_MANY_ROWS THEN 
                                      var_err := 'ERROR : Too many rows exist in TITDMGMBRINDP1 table ';
                                        v_process_flg := 1;
                                        GOTO INSERTZONE; 

                    end;
                                            <<INSERTZONE>>
                                            INSERT INTO TITDMGAPIRNO_LOG (
                                                 CHDRNUM,
                                                 MBRNO,
                                                 LOG_DESCRIPTION
                                                 ,EVENT_TIME) 
                                                  VALUES (Post_plan_data.CHDRNUM
                                                 ,Post_plan_data.MBRNO
                                                 ,VAR_ERR
                                                 ,SYSDATE
                                                 );
                                     COMMIT;

                                    if v_process_flg = 0 Then    

                                                  UPDATE titdmgapirno_temp_Oct13th SET MBRNO = NEW_MBRNO WHERE CHDRNUM = Post_plan_data.chdrnum
                                                  AND SUBSTR(MBRNO,-1) ='2';

                                                  END IF;
                                    
                   END LOOP; 
                   COMMIT;
                   CLOSE cur_data_Post_Plan;
exception when others 
then
dbms_output.put_line('sql errm '||sqlerrm);

end;
/* OPENING BELOW CURSOR TO INSERT ROWS FOR FREE PLAN */

                   OPEN cur_data_Free_plan;
                   LOOP
                                FETCH cur_data_Free_plan INTO INSERT_FREEPLAN_ROW;
                                EXIT WHEN cur_data_Free_plan%notfound;
                                  FREE_PLAN_LOAD :=      INSERT_FREEPLAN_ROW.CHDRNUM||INSERT_FREEPLAN_ROW.MBRNO;
                                  v_errormsg := 'Errow while processing Free plan rows into table TITDMGAPIRNO';    

                                  FREE_V_INPUT_COUNT := FREE_V_INPUT_COUNT+1;

                                INSERT INTO titdmgapirno(
                                                      CHDRNUM
                                                     ,MBRNO
                                                      ,ZINSTYPE
                                                      ,ZAPIRNO
                                                      ,FULLKANJINAME) 
                                                      values
                                                      (INSERT_FREEPLAN_ROW.CHDRNUM
                                                      ,INSERT_FREEPLAN_ROW.MBRNO
                                                      ,INSERT_FREEPLAN_ROW.ZINSTYPE
                                                      ,INSERT_FREEPLAN_ROW.ZAPIRNO
                                                      ,INSERT_FREEPLAN_ROW.FULLKANJINAME
                                                      ); 

                                                FREE_V_OUTPUT_COUNT := FREE_V_OUTPUT_COUNT +1;

                   END LOOP;
                   COMMIT;
CLOSE cur_data_Free_plan;
EXCEPTION
     when others then
     IF L_ERR_FLG = 1 THEN 
                                  --ROLLBACK;
                                  L_ERR_FLG := 0;
     END IF;

    /*IF (MOD(V_OUTPUT_COUNT,p_array_size)=0) THEN
COMMIT;
     END IF; */
     IF G_ERR_FLG = 0 THEN
                   V_ERRORMSG := 'SUCCESS';
                   temp_no := CONTROL_LOG('TITDMGMBRINDP2,ZMRAP00,ZMRRPT00', 'TITDMGAPIRNO', SYSTIMESTAMP,FREE_PLAN_LOAD,V_ERRORMSG, 'S', FREE_V_INPUT_COUNT, FREE_V_OUTPUT_COUNT);
                   ELSE
                   V_ERRORMSG := 'COMPLETED WITH ERROR';
                   temp_no := CONTROL_LOG('TITDMGMBRINDP2,ZMRAP00,ZMRRPT00', 'TITDMGAPIRNO', SYSTIMESTAMP,FREE_PLAN_LOAD,V_ERRORMSG, 'F', FREE_V_INPUT_COUNT, FREE_V_OUTPUT_COUNT);

     END IF;


END dm_polhis_apirno;
-- Procedure for dm_polhis_apirno <ENDS> Here
-- Procedure for dm_polhis_apirno <ENDS> Here

-- Procedure for DM DM_billing_transform <STARTS> Here
    PROCEDURE dm_billing_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS
        BEGIN
            update stagedbusr2.titdmgbill1 a set zacmcldt = (
                select b.zacmcldt
                  from stagedbusr.zesdpf b, stagedbusr.zendrpf c, titdmgmbrindp1 d
                 where b.zendscid = c.zendscid
                   and c.zendcde = d.zendcde
                   and b.zposbdsy = a.zposbdsy
                   and b.zposbdsm = a.zposbdsm
                   and SUBSTR(TRIM(d.refnum),1,8) = trim(a.chdrnum));
                   
            commit;
            
        EXCEPTION
            WHEN OTHERS THEN
                rollback;
                dbms_output.put_line('Error: '||sqlerrm);
                
    END dm_billing_transform;
-- Procedure for DM DM_billing_transform <ENDS> Here

-- Procedure for DM DM_prsnclnt_transform <STARTS> Here

    PROCEDURE dm_prsnclnt_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        v_errormsg       VARCHAR2(2000);
        l_cnt_chk        NUMBER(2);
        v_zledest        NUMBER(1);
        v_output_count   NUMBER := 0;
        v_input_count    NUMBER := 0;
        v_inpcountf      NUMBER := 0;
        v_count          NUMBER := 0;
        v_igcode         CHAR(5);
        v_lhcqcd         VARCHAR(4);
        v_lhcucd         VARCHAR2(11);
        v_cnt            NUMBER(7) := 0;
        vard             VARCHAR2(13);
        stg_endtime      TIMESTAMP;
        CURSOR cur_data IS
        SELECT
            substr(zmrap00.apcucd, 1, 8) AS apcucd,

                  /*      trim(substr((trim(APCBIG)),1,instr((trim(APCBIG)), '@')-1)) LSURNAME,
                            trim(substr((trim(APCBIG)),instr((trim(APCBIG)), '@')+1)) LGIVNAME,
                            trim(substr((trim(APB5TX)),1,instr((trim(APB5TX)), ' ')-1)) ZKANAGIVNAME,
                            trim(substr((trim(APB5TX)),instr((trim(APB5TX)), ' ')+1)) ZKANASURNAME, */
                 /* incident #7405 changes - add trim for single byte as well
                            trim(substr((trim(APCBIG)),1,(CASE WHEN instr(APCBIG,'@') =0 THEN instr(APCBIG,' ') ELSE instr(APCBIG,'@') END)-1)) LSURNAME,
                            trim(substr((trim(APCBIG)),(CASE WHEN instr(APCBIG,'@') =0 THEN instr(APCBIG,' ') ELSE instr(APCBIG,'@') END)+1)) LGIVNAME,*/
            TRIM(substr((TRIM(apcbig)), 1,(
                CASE
                    WHEN instr(TRIM(apcbig), '@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '@')
                END
            ) - 1)) lsurname,
            TRIM(substr((TRIM(apcbig)),(
                CASE
                    WHEN instr(TRIM(apcbig), '@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '@')
                END
            ) + 1)) lgivname,
            TRIM(substr((TRIM(apb5tx)), 1, instr((TRIM(apb5tx)), ' ') - 1)) zkanagivname,
            TRIM(substr((TRIM(apb5tx)), instr((TRIM(apb5tx)), ' ') + 1)) zkanasurname,
            zmrap00.apc9cd,
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji1
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji1
                    ELSE
                        zmrap00.apb7ig
                END
            ) apb7ig,--newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji2
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji2
                    ELSE
                        zmrap00.apb8ig
                END
            ) apb8ig,--newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji3
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji3
                    ELSE
                        zmrap00.apb9ig
                END
            ) apb9ig,--newly added 11jun18
                            ---ZMRAP00.APB9IG,
            zmrap00.apcaig,
                           -- ZMRAP00.APB0TX,
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL
                         AND kana1 IS NOT NULL THEN
                        kana1
                    WHEN zmrap00.apb1tx = ' '
                         AND kana1 IS NOT NULL THEN
                        kana1
                    ELSE
                        zmrap00.apb0tx
                END
            ) apb0tx,--newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL
                         AND kana2 IS NOT NULL THEN
                        kana2
                    WHEN zmrap00.apb1tx = ' '
                         AND kana2 IS NOT NULL THEN
                        kana2
                    ELSE
                        zmrap00.apb1tx
                END
            ) apb1tx,--newly added 11jun18
                            --ZMRAP00.APB1TX,
            zmrap00.apb2tx,
            zmrap00.apb3tx,
            decode(nvl(zmrap00.apbast, ' '), '1', 'M', '2', 'F') apbast,
            zmrap00.apb4tx,
            zmrap00.apb9tx,
            zmris00.iscpcd,
            zmrap00.apa3dt,
            zmris00.isb1ig,
            substr(zmrap00.apcdig, 1, 25) apcdig,
            (
                CASE
                    WHEN zmrap00.apcatx IN (
                        '4',
                        '5'
                    ) THEN
                        'RA01'
                    ELSE
                        NULL
                END
            ) asrf
        FROM
            zmris00,
            zmrap00,
            kanji_address_list,
            stagedbusr2.kana_address_list --newly added 11jun18
        WHERE
            zmrap00.apcucd = zmris00.iscucd (+)
            AND zmrap00.apcucd = kanji_address_list.apcucd (+)
            AND --newly added 11jun18
             zmrap00.apc9cd = kana_address_list.postalcd (+)--newly added 11jun18
            AND zmrap00.apepst = '5'
            AND zmrap00.apcucd = (
                SELECT
                    MAX(a.apcucd)
                FROM
                    zmrap00 a
                WHERE
                    substr(a.apcucd, 1, 8) = substr(zmrap00.apcucd, 1, 8)
            )
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgclntprsn
                WHERE
                    refnum = substr(zmrap00.apcucd, 1, 8)
            )
        ORDER BY
            zmrap00.apcucd;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data          cur_data%rowtype;
        TYPE err_type IS
            TABLE OF error_log%rowtype;
        l_errvariable    err_type;
        temp_no          NUMBER := 0;
        l_app_old        VARCHAR2(15) := NULL;
    BEGIN
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgclntprsn
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmris00,
                        tmp_zmrap00
                    WHERE
                        tmp_zmrap00.apcucd = tmp_zmris00.iscucd (+)
                        AND tmp_zmrap00.apepst = '5'
                        AND substr(tmp_zmrap00.apcucd, 1, 8) = titdmgclntprsn.refnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLNTPRSN for Delta Load
        END IF;

        v_errormsg := 'MASTER :';
        OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            v_input_count := v_input_count + 1;
            l_app_old := st_data.apcucd;
            v_errormsg := 'INSERT :';
            BEGIN
                INSERT INTO titdmgclntprsn (
                    refnum,
                    lsurname,
                    lgivname,
                    zkanagivname,
                    zkanasurname,
                    cltpcode,
                    cltaddr01,
                    cltaddr02,
                    cltaddr03,
                    cltaddr04,
                    zkanaddr01,
                    zkanaddr02,
                    zkanaddr03,
                    zkanaddr04,
                    cltsex,
                    addrtype,
                    cltphone01,
                    cltphone02,
                    occpcode,
                    servbrh,
                    cltdob,
                    zoccdsc,
                    zworkplce,
                    occpclas,
                    transhist,
                    asrf
                ) VALUES (
                    st_data.apcucd,
                    st_data.lsurname,--remove space set -rehearsal1
                    st_data.lgivname,
                    st_data.zkanasurname,
                    st_data.zkanagivname,--remove space set -rehearsal1
                    st_data.apc9cd,
                    st_data.apb7ig,
                    st_data.apb8ig,--remove space set -rehearsal1
                    st_data.apb9ig,
                    ' ',
                   -- ST_DATA.APCAIG,Incident #7034 need to set space
                    st_data.apb0tx,
                    st_data.apb1tx,--remove space set -rehearsal1
                    ' ',
                    ' ',
                  --  ST_DATA.APB2TX, Incident #7034 need to set space
                   -- ST_DATA.APB3TX,Incident #7034 need to set space
                    st_data.apbast,
                    'R',
                    st_data.apb4tx,
                    st_data.apb9tx,
                    st_data.iscpcd,
                    '31',
                    st_data.apa3dt,
                    st_data.isb1ig,
                    st_data.apcdig,
                    NULL,
                    'N',
                    st_data.asrf
                );

                v_output_count := v_output_count + SQL%rowcount;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    error_logs('TITDMGCLNTPRSN', st_data.apcucd, v_errormsg);
            END;

            IF l_err_flg = 1 THEN
        --ROLLBACK;
                l_err_flg := 0;
            END IF;
            IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
                COMMIT;
            END IF;
        END LOOP;

        CLOSE cur_data;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00', 'TITDMGCLNTPRSN', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00', 'TITDMGCLNTPRSN', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00', 'TITDMGCLNTPRSN', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

    END;

-- Procedure for DM DM_prsnclnt_transform <ENDS> Here

-- Procedure for DM DM_clienthistory_transform <STARTS> Here

   /* PROCEDURE dm_clienthistory_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        v_errormsg      VARCHAR2(2000);
        l_cnt_chk       NUMBER(2);
        v_zledest       NUMBER(1);
        v_inpcount      NUMBER := 0;
        v_inpcountf     NUMBER := 0;
        v_count         NUMBER := 0;
        v_igcode        CHAR(5);
        v_lhcqcd        VARCHAR(4);
        v_lhcucd        VARCHAR2(11);
        v_cnt           NUMBER(7) := 0;
        vard            VARCHAR2(13);
        temp_no         NUMBER;
        stg_endtime     TIMESTAMP;
        CURSOR cur_data IS
        SELECT
            substr(zmrap00.apcucd, 1, 8) AS apcucd_appno,
            substr(zmrap00.apcucd, - 3) AS apcucd_seq,
            zmrap00.apa2dt,
                             incident #7405 changes - add trim for single byte as well
                  trim(substr((trim(APCBIG)),1,(CASE WHEN instr(APCBIG,'@') =0 THEN instr(APCBIG,' ') ELSE instr(APCBIG,'@') END)-1)) LNAME,
                            trim(substr((trim(APCBIG)),(CASE WHEN instr(APCBIG,'@') =0 THEN instr(APCBIG,' ') ELSE instr(APCBIG,'@') END)+1)) GNAME,
            TRIM(substr((TRIM(apcbig)), 1,(
                CASE
                    WHEN instr(TRIM(apcbig), '@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '@')
                END
            ) - 1)) lname,
            TRIM(substr((TRIM(apcbig)),(
                CASE
                    WHEN instr(TRIM(apcbig), '@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '@')
                END
            ) + 1)) gname,
            TRIM(substr((TRIM(apb5tx)), 1, instr((TRIM(apb5tx)), ' ') - 1)) klname,
            TRIM(substr((TRIM(apb5tx)), instr((TRIM(apb5tx)), ' ') + 1)) glname,
            zmrap00.apc9cd,
                            ZMRAP00.APB7IG,
                            ZMRAP00.APB8IG,
                            ZMRAP00.APB9IG,
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji1
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji1
                    ELSE
                        zmrap00.apb7ig
                END
            ) apb7ig, --newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji2
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji2
                    ELSE
                        zmrap00.apb8ig
                END
            ) apb8ig, --newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb8ig IS NULL THEN
                        addr_kanji3
                    WHEN zmrap00.apb8ig = ' ' THEN
                        addr_kanji3
                    ELSE
                        zmrap00.apb9ig
                END
            ) apb9ig, --newly added 11jun18
                     /*       ZMRAP00.APB0TX,
                            ZMRAP00.APB1TX,
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL
                         AND kana1 IS NOT NULL THEN
                        kana1
                    WHEN zmrap00.apb1tx = ' '
                         AND kana1 IS NOT NULL THEN
                        kana1
                    ELSE
                        zmrap00.apb0tx
                END
            ) apb0tx, --newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL
                         AND kana2 IS NOT NULL THEN
                        kana2
                    WHEN zmrap00.apb1tx = ' '
                         AND kana2 IS NOT NULL THEN
                        kana2
                    ELSE
                        zmrap00.apb1tx
                END
            ) apb1tx,    --newly added 11jun18
            decode(zmrap00.apbast, '1', 'M', '2', 'F') apbast,
            zmrap00.apb4tx,
            zmrap00.apb9tx,
            zmris00.iscpcd,
            zmrap00.apa3dt,
            zmris00.isb1ig,
            ZMRAP00.APC6CD,
            zmrap00.apcdig,
            (
                SELECT DISTINCT
                    ig_al_code ig_code
                FROM
                    alter_reason_code arc
                WHERE
                    arc.dm_al_code = zmrap00.apdlcd
                    AND ROWNUM = 1
            ) AS apdlcd
        FROM
            zmris00,
            zmrap00,
            kanji_address_list,
            kana_address_list --newly added 11jun18
        WHERE
            zmrap00.apcucd = zmris00.iscucd
            AND zmrap00.apcucd = kanji_address_list.apcucd (+)
            AND --newly added 11jun18
             zmrap00.apc9cd = kana_address_list.postalcd (+)         --newly added 11jun18

                            --WHERE ZMRAP00.APCUCD =ZMRIS00.ISCUCD
            AND ( substr(zmrap00.apcucd, - 3) = '000'
                  OR zmrap00.apdlcd IN (
                'N1',
                'N6',
                'N7'
            ) )
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgcltrnhis
                WHERE
                    refnum
                    || lpad(zseqno, 3, '0') = zmrap00.apcucd
            )
        ORDER BY
            zmrap00.apcucd;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data         cur_data%rowtype;
        TYPE err_type IS
            TABLE OF error_log%rowtype;
        l_errvariable   err_type;
        l_app_old       VARCHAR2(15) := NULL;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgcltrnhis
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgcltrnhis.refnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
        END IF;

        v_errormsg := 'MASTER :';
        OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            v_input_count := v_input_count + 1;
            l_app_old := st_data.apcucd_appno || st_data.apcucd_seq;
            v_errormsg := 'INSERT :';
            BEGIN
                INSERT INTO titdmgcltrnhis (
                    refnum,
                    zseqno,
                    effdate,
                    lsurname,
                    lgivname,
                    zkanagivname,
                    zkanasurname,
                    cltpcode,
                    cltaddr01,
                    cltaddr02,
                    cltaddr03,
                    zkanaddr01,
                    zkanaddr02,
                    addrtype,
                    cltsex,
                    cltphone01,
                    cltphone02,
                    occpcode,
                    cltdob,
                    zoccdsc,
                    zworkplce,
                    zaltrcde01,
                    TRANSHIST,
				    ZENDCDE,
				    CLNTROLEFLG
                ) VALUES (
                    st_data.apcucd_appno,
                    st_data.apcucd_seq,
                    st_data.apa2dt,
                    st_data.lname,
                    st_data.gname,
                    st_data.glname,
                    st_data.klname,
                    st_data.apc9cd,
                    st_data.apb7ig,
                    st_data.apb8ig,--remove space set -rehearsal
                    st_data.apb9ig,
                    st_data.apb0tx,
                    st_data.apb1tx,--remove space set -rehearsal
                    'R',
                    st_data.apbast,
                    st_data.apb4tx,
                    st_data.apb9tx,
                    st_data.iscpcd,
                    st_data.apa3dt,
                    st_data.isb1ig,
                    st_data.apcdig,
                    st_data.apdlcd,
                    'N',
                    st_data.APC6CD,
                    'OW'
                );

                v_output_count := v_output_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    error_logs('TITDMGCLTRNHIS', st_data.apcucd_appno || st_data.apcucd_seq, v_errormsg);
            END;

            IF l_err_flg = 1 THEN
        --ROLLBACK;
                l_err_flg := 0;
            END IF;
            IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
                COMMIT;
            END IF;
        END LOOP;

        CLOSE cur_data;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

    END; */

-- Procedure for DM DM_clienthistory_transform <ENDS> Here
-- New procedure --------------------------------------
-- Procedure for DM DM_clienthistory_transform <STARTS> Here

    PROCEDURE dm_clienthistory_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        v_input_count    NUMBER;
        v_output_count   NUMBER;
        stg_starttime    TIMESTAMP;
        stg_endtime      TIMESTAMP;
        l_err_flg        NUMBER := 0;
        g_err_flg        NUMBER := 0;
        v_errormsg       VARCHAR2(2000);
        temp_no          NUMBER;
        CURSOR cur_data IS
         SELECT
            *
        FROM
            (
                SELECT
                    a.apcucd        AS apcucd,
                    x.stg_clntnum   AS refnum,
                    substr(a.apcucd, - 3) AS zseqno,
                    a.apa2dt        AS effdate,
                    TRIM(substr((TRIM(a.apcbig)), 1,(
                        CASE
                            WHEN instr(TRIM(a.apcbig), '?') = 0 THEN
                                instr(TRIM(a.apcbig), unistr('\3000'))
                            ELSE
                                instr(TRIM(a.apcbig), '?')
                        END
                    ) - 1))  lsurname,
                 
                    TRIM(substr((TRIM(a.apcbig)),(
                        CASE
                            WHEN instr(TRIM(a.apcbig), '?') = 0 THEN
                                instr(TRIM(a.apcbig),unistr('\3000'))
                            ELSE
                                instr(TRIM(a.apcbig), '?')
                        END
                    ) + 1)) lgivname,
                    nvl(TRIM(substr((TRIM(a.apb5tx)), instr((TRIM(a.apb5tx)), ' ') + 1)), ' ') AS zkanagivname,
                    nvl(TRIM(substr((TRIM(a.apb5tx)), 1, instr((TRIM(a.apb5tx)), ' ') - 1)), ' ') AS zkanasurname,
                    a.apc9cd        AS cltpcode,
                    a.apb7ig        AS cltaddr01,
                    a.apb8ig        AS cltaddr02,
                    a.apb9ig        AS cltaddr03,
                    a.apb0tx        AS zkanaddr01,
                    a.apb1tx        AS zkanaddr02,
                    decode(a.apbast, '1', 'M', '2', 'F') AS cltsex,
                    NULL AS addrtype,
                    a.apb4tx        AS cltphone01,
                    a.apb9tx        AS cltphone02,
                    b.iscpcd        AS occpcode,
                    a.apa3dt        AS cltdob,
                    b.isb1ig        AS zoccdsc,
                    substr(a.apcdig, 1, 25) AS zworkplce,
                    a.apdlcd        AS zaltrcde01,
                   decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
                a.apc6cd        AS zendcde,
                x.insur_typ     AS clntroleflg,
                1 AS n7_ver,
                1 AS n4_ver
            FROM
                (
                    SELECT
                        a.*,
                        concat(substr(apcucd, 1, 8), MIN(substr(apcucd, - 3)) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                        )) min_apcucd,
                        concat(substr(apcucd, 1, 8), MAX(substr(apcucd, - 3)) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                        )) max_apcucd
                    FROM
                        zmrap00 a where   (a.apblst IN (
                        1,3,5
                    ) 
                    OR a.apdlcd IN (
                        'N1',
                        'NS',
                        'N7',
                        'N4'))
                ) a
    INNER JOIN persnl_clnt_flg   x ON a.apcucd = x.apcucd
                                                    AND x.isa4st IS NULL
                    LEFT OUTER JOIN zmris00           b ON a.apcucd = b.iscucd
                                                 AND b.isa4st = '1'
                    LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                WHERE
                    ( a.apcucd = a.min_apcucd
                      AND apblst IN (
                        1,
                        3, 5
                    ) )
                    OR apdlcd IN (
                        'N1',
                        'NS',
                        'N7',
                        'N4'
                    )
                UNION ALL
                SELECT
                    a.apcucd        AS apcucd,
                    x.stg_clntnum   AS refnum,
                    substr(a.apcucd, - 3) AS zseqno,
                    a.apa2dt        AS effdate,
                    TRIM(substr((TRIM(b.isbvig)), 1,(
                        CASE
                            WHEN instr(TRIM(b.isbvig), '?') = 0 THEN
                                instr(TRIM(b.isbvig), unistr('\3000'))
                            ELSE
                                instr(TRIM(b.isbvig), '?')
                        END
                    ) - 1))   AS lsurname,
                    TRIM(substr((TRIM(b.isbvig)),(
                        CASE
                            WHEN instr(TRIM(b.isbvig), '?') = 0 THEN
                                instr(TRIM(b.isbvig), unistr('\3000'))
                            ELSE
                                instr(TRIM(b.isbvig), '?')
                        END
                    ) + 1)) AS lgivname,
                    nvl(TRIM(substr((TRIM(b.isbtig)), instr((TRIM(b.isbtig)), ' ') + 1)), ' ') AS zkanagivname,
                    nvl(TRIM(substr((TRIM(b.isbtig)), 1, instr((TRIM(b.isbtig)), ' ') - 1)), ' ') AS zkanasurname,
                    c.isac9cd AS cltpcode,
                    c.isab7ig AS cltaddr01,
                    c.isab8ig AS cltaddr02,
                    c.isab9ig AS cltaddr03,
                    c.isab0tx AS zkanaddr01,
                    c.isab1tx AS zkanaddr02,
                  /*nvl2(i.iscucd, a.apc9cd, c.isac9cd) AS cltpcode,
                    nvl2(i.iscucd, a.apb7ig, c.isab7ig) AS cltaddr01,
                    nvl2(i.iscucd, a.apb8ig, c.isab8ig) AS cltaddr02,
                    nvl2(i.iscucd, a.apb9ig, c.isab9ig) AS cltaddr03,
                    nvl2(i.iscucd, a.apb0tx, c.isab0tx) AS zkanaddr01,
                    nvl2(i.iscucd, a.apb1tx, c.isab1tx) AS zkanaddr02, */
                    decode(b.isa3st, '1', 'M', '2', 'F') AS cltsex,
                    NULL AS addrtype,
                    c.isab4tx AS cltphone01,
                    --nvl2(i.iscucd, a.apb4tx, c.isab4tx) AS cltphone01,
                    b.isbytx        AS cltphone02,
                    b.iscpcd        AS occpcode,
                    b.isatdt        AS cltdob,
                    b.isb1ig        AS zoccdsc,
                    substr(b.isbzig, 1, 25) AS zworkplce,
                    a.apdlcd        AS zaltrcde01,
   decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
                a.apc6cd        AS zendcde,
                x.insur_typ     AS clntroleflg,
                1 AS n7_ver,
                1 AS n4_ver
            FROM
                (
                    SELECT
                        a.*,
                        concat(substr(apcucd, 1, 8), MIN(substr(apcucd, - 3)) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                        )) min_apcucd,
                        concat(substr(apcucd, 1, 8), MAX(substr(apcucd, - 3)) OVER(
                            PARTITION BY substr(apcucd, 1, 8)
                        )) max_apcucd
                    FROM
                        zmrap00 a where   (a.apblst IN (
                        1,3,5
                    ) 
                    OR a.apdlcd IN (
                        'N7',
                        'ND',
                        'N6',
                        'N4'))
                ) a
                                 INNER JOIN persnl_clnt_flg   x ON a.apcucd = x.apcucd
                                                    AND x.isa4st IS NOT NULL
                    INNER JOIN zmris00           b ON b.iscicd = x.iscicd
                                            AND b.isa4st <> '1'
                    LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                   -- LEFT OUTER JOIN zmris00           i ON a.apcucd = i.iscucd
                   --                              AND i.isa4st = '1'
                WHERE
                    b.isa4st <> 1
                    AND ( a.apcucd = min_apcucd
                          AND apblst IN (
                        1,
                        3, 5
                    ) )
                    OR a.apdlcd IN (
                        'N7',
                        'ND',
                        'N6',
                        'N4'
                    )
            )
        ORDER BY
            refnum,
            zseqno;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data          cur_data%rowtype;
        prev_data        cur_data%rowtype;
        TYPE err_type IS
            TABLE OF error_log%rowtype;
        l_errvariable    err_type;
        l_app_old        VARCHAR2(15) := NULL;
        n7_ver           NUMBER := 1;
        n4_ver           NUMBER := 1;
        ins_flg          INTEGER := 0;
        ins_seq          INTEGER := 0;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data INTO st_data;
                EXIT WHEN cur_data%notfound;
                DELETE FROM titdmgcltrnhis
                WHERE
                    refnum = st_data.refnum;

            END LOOP;

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
        END IF;

        v_errormsg := 'MASTER :';
        OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            l_app_old := st_data.apcucd;
            ins_flg := 0;
            IF prev_data.refnum = st_data.refnum THEN
                IF nvl(prev_data.occpcode, '-1') <> nvl(st_data.occpcode, '-1') THEN
                    n4_ver := n4_ver + 1;
                    ins_flg := 1;
                END IF;

                IF NOT ( ( nvl(prev_data.lsurname, '-XYZ') = nvl(st_data.lsurname, '-XYZ') ) AND ( nvl(prev_data.lgivname, '-XYZ'
                ) = nvl(st_data.lgivname, '-XYZ') ) AND ( nvl(prev_data.zkanagivname, '-XYZ') = nvl(st_data.zkanagivname, '-XYZ')
                ) AND ( nvl(prev_data.zkanasurname, '-XYZ') = nvl(st_data.zkanasurname, '-XYZ') ) AND ( nvl(prev_data.cltpcode, '-XYZ'
                ) = nvl(st_data.cltpcode, '-XYZ') ) AND ( nvl(prev_data.cltaddr01, '-XYZ') = nvl(st_data.cltaddr01, '-XYZ') ) AND
                ( nvl(prev_data.cltaddr02, '-XYZ') = nvl(st_data.cltaddr02, '-XYZ') ) AND ( nvl(prev_data.cltaddr03, '-XYZ') = nvl
                (st_data.cltaddr03, '-XYZ') ) AND ( nvl(prev_data.zkanaddr01, '-XYZ') = nvl(st_data.zkanaddr01, '-XYZ') ) AND ( nvl
                (prev_data.zkanaddr02, '-XYZ') = nvl(st_data.zkanaddr02, '-XYZ') ) AND ( nvl(prev_data.cltsex, '-XYZ') = nvl(st_data
                .cltsex, '-XYZ') ) AND ( nvl(prev_data.cltphone01, '-XYZ') = nvl(st_data.cltphone01, '-XYZ') ) AND ( nvl(prev_data
                .cltphone02, '-XYZ') = nvl(st_data.cltphone02, '-XYZ') ) AND ( nvl(prev_data.cltdob, -1) = nvl(st_data.cltdob, -1
                ) ) ) THEN
                    n7_ver := n7_ver + 1;
                    ins_flg := 1;
                END IF;

                IF st_data.zaltrcde01 IN (
                    'N1',
                    'NS',
                    'N6',
                    'ND'
                ) THEN
                    ins_flg := 1;
                END IF;
                
                IF ins_flg = 1 THEN
                    ins_seq := ins_seq + 1;
                END IF;

            ELSE
                ins_seq := 0;
                n7_ver := 1;
                n4_ver := 1;
                ins_flg := 1;
            END IF;

            prev_data := st_data;
            v_errormsg := 'INSERT :';
            BEGIN
                IF ins_flg = 1 THEN
                    INSERT INTO titdmgcltrnhis (
               -- recidxclhis,
                        refnum,
                        zseqno,
                        zseqdmno,
                        effdate,
                        lsurname,
                        lgivname,
                        zkanagivname,
                        zkanasurname,
                        cltpcode,
                        cltaddr01,
                        cltaddr02,
                        cltaddr03,
                        zkanaddr01,
                        zkanaddr02,
                        addrtype,
                        cltsex,
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
                         ZKANASNMNOR,
                    ZKANAGNMNOR          ,

                        n7_ver,
                        n4_ver
                    ) VALUES (
               -- st_data.apcucd,
                        st_data.refnum,
                        ins_seq,
                        st_data.zseqno,
                        st_data.effdate,
                        st_data.lsurname,
                        nvl(st_data.lgivname, ' '),
                        st_data.zkanagivname,
                        nvl(st_data.zkanasurname, ' '),
                        nvl(st_data.cltpcode, ' '),
                        nvl(st_data.cltaddr01, ' '),
                        nvl(st_data.cltaddr02, ' '),
                        st_data.cltaddr03,
                        nvl(st_data.zkanaddr01, ' '),
                        st_data.zkanaddr02,
                        st_data.addrtype,
                        nvl(st_data.cltsex, ' '),
                        st_data.cltphone01,
                        st_data.cltphone02,
                        st_data.occpcode,
                        st_data.cltdob,
                        st_data.zoccdsc,
                        st_data.zworkplce,
                        substr(st_data.zaltrcde01, 1, 4),
                        st_data.transhist,
                        st_data.zendcde,
                        st_data.clntroleflg,
                       HALFBYTEKATAKANANORMALIZED_FUN(st_data.ZKANASURNAME),
                    HALFBYTEKATAKANANORMALIZED_FUN(st_data.ZKANAGIVNAME),
                        n7_ver,
                        n4_ver
                    );

                END IF;

                v_output_count := v_output_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    error_logs('TITDMGCLTRNHIS', st_data.apcucd, v_errormsg);
            END;

            IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
                COMMIT;
            END IF;
        END LOOP;

        v_input_count := cur_data%rowcount;
        CLOSE cur_data;
        update titdmgcltrnhis a set TRANSHIST = 1 where (refnum || ZSEQNO) in (select refnum || max(ZSEQNO) ZSEQNO from stagedbusr2.titdmgcltrnhis group by refnum) 
        and TRANSHIST = 0;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
        dbms_output.put_line('Error message' || sqlerrm);
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

    END;

-- Procedure for DM DM_clienthistory_transform <ENDS> Here



-------new procedure ends here ----------------------------
-- Procedure for DM DM_Billing_collectres <STARTS> Here

    PROCEDURE dm_billing_collectres (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        l_cnt_chk          NUMBER(2);
        v_zledest          NUMBER(1);
        v_output_count     NUMBER := 0;
        v_inpcountf        NUMBER := 0;
        v_count            NUMBER := 0;
        v_igcode           CHAR(5);
        v_lhcqcd           VARCHAR(4);
        v_lhcucd           VARCHAR2(11);
        v_cnt              NUMBER(7) := 0;
        vard               VARCHAR2(13);
        stg_endtime        TIMESTAMP;
        TYPE ig_array IS
            TABLE OF titdmgcolres%rowtype;
        st_data            ig_array;
        v_app              titdmgcolres%rowtype;
        l_appno            VARCHAR2(20);
        ig_starttime       TIMESTAMP;
        ig_endtime         TIMESTAMP;
        v_errormsg         VARCHAR2(2000);
        v_input_count      NUMBER := 0;
        temp_no            NUMBER;
        custom_exp EXCEPTION;
        CURSOR cur_titdmgcolres IS
        SELECT
            pj_titdmgcolres.chdrnum,
            pj_titdmgcolres.trrefnum,
            pj_titdmgcolres.tfrdate,
            pj_titdmgcolres.pshcde,
            pj_titdmgcolres.facthous,
            (
                SELECT
                    dsh_code_ref.ig_dshcde
                FROM
                    dsh_code_ref
                WHERE
                    dsh_code_ref.pj_dshcde = pj_titdmgcolres.pshcde
                    AND dsh_code_ref.pj_facthous = pj_titdmgcolres.facthous
            ) ig_dshcde
        FROM
            pj_titdmgcolres
        WHERE
            NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgcolres
                WHERE
                    titdmgcolres.chdrnum = pj_titdmgcolres.chdrnum
                    AND titdmgcolres.trrefnum = pj_titdmgcolres.trrefnum
            )
        ORDER BY
            chdrnum;

        rec_titdmgcolres   cur_titdmgcolres%rowtype;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_errormsg := 'DM_Billing_collectres:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgcolres
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_pj_titdmgcolres dt
                    WHERE
                        dt.chdrnum = titdmgcolres.chdrnum
                );

            COMMIT;
         -- Delete the records for all the records exists in PJ_TITDMGCOLRES for Delta Load
        END IF;

        v_errormsg := 'Master cursor:';
        OPEN cur_titdmgcolres;
        LOOP
            FETCH cur_titdmgcolres INTO rec_titdmgcolres;
            EXIT WHEN cur_titdmgcolres%notfound;
            l_appno := rec_titdmgcolres.chdrnum;
            v_input_count := v_input_count + 1;
            BEGIN
                IF rec_titdmgcolres.ig_dshcde IS NOT NULL THEN
                    v_errormsg := 'Insert CALL:';
                    INSERT INTO titdmgcolres (
                        chdrnum,
                        trrefnum,
                        tfrdate,
                        dshcde
                    ) VALUES (
                        rec_titdmgcolres.chdrnum,
                        rec_titdmgcolres.trrefnum,
                        rec_titdmgcolres.tfrdate,
                        rec_titdmgcolres.ig_dshcde
                    );

                    v_output_count := v_output_count + 1;
                ELSE
                    v_errormsg := 'No IG code mapping for:' || rec_titdmgcolres.pshcde;
                    error_logs('TITDMGCOLRES', rec_titdmgcolres.chdrnum, v_errormsg);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := 'CODE NOT CONFIRMED / NOT AVAILABLE';
                    error_logs('TITDMGCOLRES', l_appno, v_errormsg);
            END;

            IF l_err_flg = 1 THEN
                        --ROLLBACK;
                l_err_flg := 0;
            END IF;
            COMMIT;
        END LOOP;

        CLOSE cur_titdmgcolres;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00', 'TITDMGCOLRES', systimestamp, l_appno, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00', 'TITDMGCOLRES', systimestamp, l_appno, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN custom_exp THEN
            dbms_output.put_line('ALL DATA / NO DATA RETRIEVED FROM THE TABLE');
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            temp_no := control_log('PJ_TITDMGCOLRES', 'TITDMGCOLRES', systimestamp, NULL, v_errormsg,
            'F', v_input_count, v_output_count);

    END dm_billing_collectres;

-- Procedure for DM DM_Billing_collectres <ENDS> Here

-- Procedure for DM DM_LETTERHIST_TRANSFORM <STARTS> Here
/* old version
    PROCEDURE dm_letterhist_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        v_errormsg       VARCHAR2(2000);
        l_cnt_chk        NUMBER(2);
        v_zledest        NUMBER(1);
        v_output_count   NUMBER := 0;
        v_inpcount       NUMBER := 0;
        v_inpcountf      NUMBER := 0;
        v_count          NUMBER := 0;
        v_igcode         CHAR(5);
        v_lhcqcd         VARCHAR(4);
        v_lhcucd         VARCHAR2(11);
        v_cnt            NUMBER(7) := 0;
        temp_no          NUMBER := 0;
        vard             VARCHAR2(13);
        stg_endtime      TIMESTAMP;
        CURSOR cur_zmrlh00 IS
        SELECT
            substr(lhcqcd, 1, 2) v_lhcqcd,
            lhawdt,
            lhcucd,
            substr(lhcucd, 1, 8) v_lhcucd,
            lhcqcd,
            (
                SELECT
                    igcode
                FROM
                    letter_code
                WHERE
                    dmcode = substr(za.lhcqcd, 1, 2)
            ) AS v_igcode,
            nvl((
                CASE
                    WHEN zmrap.apevst = '1' THEN
                        'Y'
                    ELSE
                        'N'
                END
            ), 'N') AS zapstmpd, -- ITR4 changes addition
            ' ' AS zdesper -- ITR4 changes
        FROM
            zmrlh00   za,
            zmrap00   zmrap   -- ITR4 changes addition
        WHERE
            za.lhcucd = zmrap.apcucd  -- ITR4 changes addition
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgletter lt,
                    letter_code
                WHERE
                    chdrnum = substr(lhcucd, 1, 8)
                    AND igcode = lt.lettype
                    AND dmcode = substr(nvl(za.lhcqcd, '        '), 1, 2)
                    AND lreqdate = za.lhawdt
            )
        ORDER BY
            3;

        rec_zmrlh00      cur_zmrlh00%rowtype;
        TYPE recd_zmrlh00 IS
            TABLE OF cur_zmrlh00%rowtype;
        l_data           recd_zmrlh00;
        chk_cnt          NUMBER := 0;
    BEGIN
        stg_starttime := systimestamp;
        l_err_flg := 0;
        g_err_flg := 0;
        v_errormsg := 'DM_LETTERHIST_TRANSFORM:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgletter
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrlh00 za
                    WHERE
                        substr(za.lhcucd, 1, 8) = titdmgletter.chdrnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGLETTER for Delta Load
        END IF;

        v_errormsg := 'CURSOR_F-';
        OPEN cur_zmrlh00;
        LOOP
            FETCH cur_zmrlh00 BULK COLLECT INTO l_data LIMIT p_array_size;
            v_inpcount := v_inpcount + l_data.count;
            FOR cnt IN 1..l_data.count LOOP
                vard := l_data(cnt).lhcucd;
                IF l_data(cnt).lhcqcd IN (
                    'SB0D',
                    'SB1E',
                    'SB2E',
                    'SB3E',
                    'SB4E',
                    'SB5E',
                    'SB7E',
                    'SB9E',
                    'PL1E',
                    'PL2E',
                    'PL3E',
                    'PL4E',
                    'PL5E',
                    'PL7E',
                    'PL9E'
                ) THEN
                    v_zledest := 1;
                ELSE
                    v_zledest := 2;
                END IF;

                BEGIN
                    v_errormsg := 'CURSOR_MT-';
                    IF l_data(cnt).lhcucd IS NOT NULL THEN
                        IF l_data(cnt).v_igcode IS NOT NULL THEN
                            INSERT INTO titdmgletter (
                                lettype,
                                lreqdate,
                                chdrnum,
                                zdspcatg,
                                zletvern,
                                zletdest,
                                zcomaddr,
                                zletcat,
                                zapstmpd,
                                zdesper,
                                zletefdt
                            ) VALUES (
                                l_data(cnt).v_igcode,
                                l_data(cnt).lhawdt,
                                l_data(cnt).v_lhcucd,
                                '2',
                                '000',
                                v_zledest,
                                'POLHLD',
                                'M',
                                l_data(cnt).zapstmpd,
                                l_data(cnt).zdesper,
                                l_data(cnt).lhawdt
                            );

                            v_output_count := v_output_count + SQL%rowcount;
                            DELETE FROM tab_not_found_list
                            WHERE
                                lhcucd = l_data(cnt).lhcucd;

                        ELSE
                            chk_cnt := 0;
                            SELECT
                                COUNT(1)
                            INTO chk_cnt
                            FROM
                                tab_not_found_list
                            WHERE
                                lhcucd = l_data(cnt).lhcucd;

                            IF chk_cnt = 0 THEN
                                INSERT INTO tab_not_found_list (
                                    lhcucd,
                                    lhcqcd
                                ) VALUES (
                                    l_data(cnt).lhcucd,
                                    l_data(cnt).v_lhcqcd
                                );

                            END IF;

                            v_output_count := v_output_count + SQL%rowcount;
                        END IF;

                    ELSE
                        v_errormsg := 'LHCUCD CANNOT BE NULL. LETTYPE:'
                                      || l_data(cnt).v_lhcqcd
                                      || '-LREQDATE:'
                                      || l_data(cnt).lhawdt;

                        error_logs('TITDMGLETTER', vard, v_errormsg);
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        error_logs('TITDMGLETTER', vard, v_errormsg);
                END;

                COMMIT;
            END LOOP;

            EXIT WHEN cur_zmrlh00%notfound;
        END LOOP;

        CLOSE cur_zmrlh00;
        IF l_err_flg = 1 THEN
        --ROLLBACK;
            l_err_flg := 0;
        END IF;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRLH00', 'TITDMGLETTER', systimestamp, vard, v_errormsg,
            'S', v_inpcount, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRLH00', 'TITDMGLETTER', systimestamp, vard, v_errormsg,
            'F', v_inpcount, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRLH00', 'TITDMGLETTER', systimestamp, vard, v_errormsg,
            'F', v_inpcount, v_output_count);

    END dm_letterhist_transform;

-- Procedure for DM DM_LETTERHIST_TRANSFORM <ENDS> Here
old */
-- Procedure for DM DM_LETTERHIST_TRANSFORM <STARTS> Here

PROCEDURE DM_LETTERHIST_TRANSFORM(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N')
	AS
	V_ERRORMSG VARCHAR2(2000);
    L_CNT_CHK NUMBER(2);
    V_ZLEDEST NUMBER(1);
    V_OUTPUT_COUNT NUMBER := 0;
    V_INPCOUNT NUMBER :=0;
    V_INPCOUNTF NUMBER :=0;
    V_COUNT NUMBER :=0;
	V_IGCODE CHAR(5);
	V_LHCQCD VARCHAR(4);
	V_LHCUCD VARCHAR2(11);
    V_CNT   NUMBER(7):= 0;
    temp_no NUMBER:=0;
    temp_IGCODE CHAR(5) :='     ';--bhupendra change
	temp_LHCUCD VARCHAR2(11) :='           '; --bhupendra change
	temp_V_LHCUCD VARCHAR2(11) :='           '; --bhupendra change
	temp_LHAWDT VARCHAR2(8):='        '; --bhupendra change
	v_zlettrno NUMBER :=1;--bhupendra change
    VARD varchar2(13);
    STG_ENDTIMe TIMESTAMP;
        CURSOR CUR_ZMRLH00
        IS
          SELECT SUBSTR(LHCQCD,1,2) V_LHCQCD,
                 LHAWDT,
                 LHCUCD,
                 SUBSTR(LHCUCD,1,8) V_LHCUCD,
                 LHCQCD,
                 (SELECT IGCODE FROM LETTER_CODE where DMCODE=SUBSTR(ZA.LHCQCD,1,2)) AS V_IGCODE,
                -- NVL((CASE WHEN ZMRAP.APEVST='1' THEN 'Y' ELSE 'N' END)  ,'N') AS ZAPSTMPD, -- ITR4 changes addition
                 ' ' AS ZDESPER -- ITR4 changes
            FROM ZMRLH00 ZA
              --   ZMRAP00 ZMRAP   -- ITR4 changes addition
           WHERE
		   --ZA.LHCUCD = ZMRAP.APCUCD AND -- ITR4 changes addition
              NOT EXISTS (SELECT 'X' FROM TITDMGLETTER LT ,LETTER_CODE
                              WHERE CHDRNUM =  SUBSTR(LHCUCD,1,8) and
                               IGCODE = LT.LETTYPE
                               AND dmcode = SUBSTR(NVL(ZA.LHCQCD,'        '),1,2)
                               AND LREQDATE = ZA.LHAWDT
                            )
           --  ORDER BY 3;
		 ORDER BY LHCUCD,LHAWDT,V_IGCODE; --bhupendra change

    REC_ZMRLH00 CUR_ZMRLH00%ROWTYPE;

     TYPE RECD_ZMRLH00 IS TABLE OF CUR_ZMRLH00%ROWTYPE;
     L_DATA RECD_ZMRLH00;

   CHK_CNT NUMBER:=0;

BEGIN
    STG_STARTTIME :=SYSTIMESTAMP;
    L_ERR_FLG :=0;
    G_ERR_FLG :=0;


     V_ERRORMSG:= 'DM_LETTERHIST_TRANSFORM:';
      IF p_delta = 'Y' THEN
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGLETTER WHERE EXISTS (SELECT 'X' FROM TMP_ZMRLH00 ZA
                                                     WHERE SUBSTR(ZA.LHCUCD,1,8) = TITDMGLETTER.CHDRNUM
                                                     );
             COMMIT;
         -- Delete the records for all the records exists in TITDMGLETTER for Delta Load
      END IF;

    V_ERRORMSG:='CURSOR_F-';
    OPEN CUR_ZMRLH00;
    LOOP
      FETCH CUR_ZMRLH00
        BULK COLLECT INTO L_DATA LIMIT p_array_size;

        V_INPCOUNT := V_INPCOUNT + L_DATA.COUNT;

        FOR cnt IN 1 .. L_DATA.COUNT
        LOOP
        vard := L_DATA(cnt).LHCUCD;

/* comments - Bhupendra
     --   IF L_DATA(cnt).LHCQCD IN ('SB0D','SB1E','SB2E','SB3E','SB4E','SB5E','SB7E','SB9E','PL1E','PL2E','PL3E','PL4E','PL5E','PL7E','PL9E') THEN
   --       V_ZLEDEST := 1;
    --    ELSE
    --      V_ZLEDEST := 2;
    --    END IF;
*/

       BEGIN
        V_ERRORMSG:='CURSOR_MT-';
        IF L_DATA(cnt).LHCUCD is not null THEN
        IF L_DATA(cnt).V_IGCODE IS NOT NULL THEN
         IF (temp_V_LHCUCD = L_DATA(cnt).V_LHCUCD) THEN --bhupendra change
                        v_zlettrno := v_zlettrno + 1;--bhupendra change
                ELSE
                       
						temp_V_LHCUCD := L_DATA(cnt).V_LHCUCD;--bhupendra change
						v_zlettrno := 1;--bhupendra change
                END IF;
             INSERT INTO TITDMGLETTER(LETTYPE,LREQDATE,CHDRNUM,ZDSPCATG,ZLETVERN,ZLETDEST,ZCOMADDR,ZLETCAT,ZAPSTMPD,ZDESPER,ZLETEFDT,ZLETTRNO)--bhupendra change add ZLETTRNO
                               VALUES(L_DATA(cnt).V_IGCODE, L_DATA(cnt).LHAWDT, L_DATA(cnt).V_LHCUCD,'2','000','2','POLHLD','M','N',L_DATA(cnt).ZDESPER, L_DATA(cnt).LHAWDT,v_zlettrno);--bhupendra change add ZLETTRNO
             V_OUTPUT_COUNT := V_OUTPUT_COUNT + SQL%ROWCOUNT;
             DELETE FROM TAB_NOT_FOUND_LIST WHERE LHCUCD=L_DATA(cnt).LHCUCD;
        ELSE
            CHK_CNT :=0;
            SELECT COUNT(1) INTO CHK_CNT FROM TAB_NOT_FOUND_LIST WHERE LHCUCD=L_DATA(cnt).LHCUCD;
            IF CHK_CNT = 0 THEN
               INSERT INTO TAB_NOT_FOUND_LIST(LHCUCD,LHCQCD) VALUES (L_DATA(cnt).LHCUCD, L_DATA(cnt).V_LHCQCD);
            END IF;
            V_OUTPUT_COUNT := V_OUTPUT_COUNT + SQL%ROWCOUNT;
        END IF;
        ELSE
            V_ERRORMSG:='LHCUCD CANNOT BE NULL. LETTYPE:'||L_DATA(cnt).V_LHCQCD||'-LREQDATE:'||L_DATA(cnt).LHAWDT;
            ERROR_LOGS('TITDMGLETTER',vard,V_ERRORMSG);
        END IF;
       EXCEPTION
       WHEN OTHERS  THEN
          V_ERRORMSG := V_ERRORMSG ||'-'||sqlerrm;
          ERROR_LOGS('TITDMGLETTER',vard,V_ERRORMSG);
        END;

        COMMIT;

        END LOOP;
      EXIT WHEN CUR_ZMRLH00%NOTFOUND;
    END LOOP;

    CLOSE CUR_ZMRLH00;

        IF L_ERR_FLG = 1 THEN
        --ROLLBACK;
          L_ERR_FLG := 0;
        END IF;

COMMIT;

    IF G_ERR_FLG = 0 THEN
       V_ERRORMSG := 'SUCCESS';
       temp_no := CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'S',V_INPCOUNT, V_OUTPUT_COUNT);
    ELSE
       V_ERRORMSG := 'COMPLETED WITH ERROR';
       temp_no := CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'F',V_INPCOUNT, V_OUTPUT_COUNT);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
       temp_no := CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'F',V_INPCOUNT, V_OUTPUT_COUNT);
END DM_LETTERHIST_TRANSFORM;

-- Procedure for DM DM_LETTERHIST_TRANSFORM <ENDS> Here


-- Procedure for DM DM_Refunddets_transform <STARTS> Here

    PROCEDURE dm_refunddets_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit          PLS_INTEGER := p_array_size;
        v_errormsg       VARCHAR2(2000) := ' ';
        l_credit         VARCHAR2(30) := NULL;
        l_credit_old     VARCHAR2(30) := NULL;
        l_app_old        VARCHAR2(60) := NULL;
        l_currdt         VARCHAR2(8);
        l_date           DATE := NULL;
        l_date_old       DATE := NULL;
        application_no   VARCHAR2(13);
        bank_cnt         NUMBER := 0;
        v_input_count    NUMBER;
        v_output_count   NUMBER;
        temp_no          NUMBER;
        CURSOR refdet_cur IS
        SELECT
            a.appno AS apcucd,
            cuugcd,
            cuulcd,
            cuumcd,
            cuuncd,
            cuuocd,
            cuaipc,
            cuajpc,
            cuakpc,
            cualpc,
            cuampc,
            cuacpc,
            cuaepc,
            cuafpc,
            cuagpc,
            cuahpc,
            collection_fee,
            (
                CASE
                    WHEN instr(noofinstallment, '.') > 0 THEN
                        1
                    ELSE
                        noofinstallment
                END
            ) cnt
        FROM
            (
                SELECT
                    apcucd appno,
                    cuugcd,
                    cuulcd,
                    cuumcd,
                    cuuncd,
                    cuuocd,
                    cuaipc,
                    cuajpc,
                    cuakpc,
                    cualpc,
                    cuampc,
                    cuacpc,
                    cuaepc,
                    cuafpc,
                    cuagpc,
                    cuahpc,
                    nvl(feerate, 0) collection_fee,
                 --  (apf8nb/(select -(apf8nb) from zmrap00 b where substr(a.apcucd,1,8)=substr(b.apcucd,1,8)and substr(b.apcucd,-3)='000')) as noofinstallment rehearsal
                    to_number(substr(((
                        SELECT
                            icb3va
                        FROM
                            (
                                SELECT
                                    icbmst, icb3va
                                FROM
                                    zmric00
                                WHERE
                                    substr(a.apcucd, 1, 8) = substr(iccucd, 1, 8)
                                    AND icb3va < 0
                                ORDER BY
                                    iccucd, icbmst DESC
                            )
                        WHERE
                            ROWNUM = 1
                    ) /(
                        SELECT
                            - icb3va
                        FROM
                            (
                                SELECT
                                    icbmst, icb3va
                                FROM
                                    zmric00
                                WHERE
                                    substr(a.apcucd, 1, 8) = substr(iccucd, 1, 8)
                                    AND icb3va > 0
                                ORDER BY
                                    iccucd, icbmst DESC
                            )
                        WHERE
                            ROWNUM = 1
                    )), 1, 6)) AS noofinstallment
                FROM
                    zmrap00 a,
                    zmrat00,
                    (
                        SELECT
                            TRIM(productcode) productcode,
                            TRIM(endorsercode) endorsercode,
                            feerate
                        FROM
                            col_fee_lst
                    ) a
                WHERE
                    apcycd BETWEEN 50 AND 69
                    AND apf8nb < 0
                    AND apc6cd = cub8cd
                    AND apc7cd = cuufcd
                    AND apf9cd = cuugcd
                    AND apc7cd = a.productcode (+)
                    AND apc6cd = a.endorsercode (+)
            ) a,
            (
                SELECT
                    iccucd appno,
                    COUNT(substr(iccucd, 1, 8)) AS cnt
                FROM
                    zmric00
                WHERE
                    icb3va < 0
                GROUP BY
                    iccucd
            ) b
        WHERE
            a.appno = b.appno
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgref2
                WHERE
                    chdrnum = substr(a.appno, 1, 8)
            )
        ORDER BY
            1;

        CURSOR zmric00_cur (
            c1 IN VARCHAR2
        ) IS
        SELECT
            *
        FROM
            (
                SELECT
                    icbmst,
                    icb3va,
                    '002'
                FROM
                    zmric00
                WHERE
                    icb3va < 0
                    AND zmric00.iccucd = c1
            );

        refdet_rec       refdet_cur%rowtype;
        refdet_rec1      zmric00_cur%rowtype;
        l_refcnt         DECIMAL(5, 3) := NULL;
        l_refcnt1        INTEGER := 0;
        l_refcnt2        INTEGER := 0;
        l_stdate         NUMBER := NULL;
        l_enddate        NUMBER := NULL;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_app_old := NULL;
        v_errormsg := 'DM_Refunddets_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgref2
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgref2.chdrnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGPOLTRNH for Delta Load
        END IF;

        v_errormsg := 'Master cursor';
        OPEN refdet_cur;
        LOOP
            FETCH refdet_cur INTO refdet_rec;
            EXIT WHEN refdet_cur%notfound;
            l_refcnt1 := refdet_rec.cnt;
            v_input_count := v_input_count + 1;
            OPEN zmric00_cur(refdet_rec.apcucd);
            LOOP
                FETCH zmric00_cur INTO refdet_rec1;
                EXIT WHEN zmric00_cur%notfound;
                l_refcnt1 := refdet_rec.cnt;
                LOOP
                    EXIT WHEN l_refcnt1 = 0;
                    l_refcnt2 := l_refcnt2 + 1;
                    BEGIN
                        v_errormsg := 'TITDMGREF2 Insert:';

              --      INSERT INTO TITDMGREF22
                        INSERT INTO titdmgref2 (
                            trrefnum,
                            chdrnum,
                            zrefmtcd,
                            prodtyp,
                            bprem,
                            gagntsel01,
                            gagntsel02,
                            gagntsel03,
                            gagntsel04,
                            gagntsel05,
                            cmrate01,
                            cmrate02,
                            cmrate03,
                            cmrate04,
                            cmrate05,
                            commn01,
                            commn02,
                            commn03,
                            commn04,
                            commn05,
                            zagtgprm01,
                            zagtgprm02,
                            zagtgprm03,
                            zagtgprm04,
                            zagtgprm05,
                            zcollfee01
                        ) VALUES (
                            l_refcnt2,
                            substr(refdet_rec.apcucd, 1, 8),
                            '002',
                            '1' || refdet_rec1.icbmst,
                            round(refdet_rec1.icb3va / refdet_rec.cnt, 2),
                            refdet_rec.cuugcd,
                            refdet_rec.cuulcd,
                            refdet_rec.cuumcd,
                            refdet_rec.cuuncd,
                            refdet_rec.cuuocd,
                            refdet_rec.cuaipc,
                            refdet_rec.cuajpc,
                            refdet_rec.cuakpc,
                            refdet_rec.cualpc,
                            refdet_rec.cuampc,
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) *(refdet_rec.cuacpc / 100)) * refdet_rec.cuaipc / 100))
                            + round(round((((refdet_rec1.icb3va / refdet_rec.cnt) *(refdet_rec.cuacpc / 100)) * refdet_rec.cuaipc
                            / 100)) * 0.08),
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuaepc / 100) * refdet_rec.cuajpc / 100)) +
                            round(round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuaepc / 100) * refdet_rec.cuajpc / 100
                            )) * 0.08),
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuafpc / 100) * refdet_rec.cuakpc / 100)) +
                            round(round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuafpc / 100) * refdet_rec.cuakpc / 100
                            )) * 0.08),
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuagpc / 100) * refdet_rec.cualpc / 100)) +
                            round(round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuagpc / 100) * refdet_rec.cualpc / 100
                            )) * 0.08),
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuahpc / 100) * refdet_rec.cuampc / 100)) +
                            round(round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuahpc / 100) * refdet_rec.cuampc / 100
                            )) * 0.08),
                            round(((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuacpc / 100), 0),
                            round(((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuaepc / 100), 0),
                            round(((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuafpc / 100), 0),
                            round(((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuagpc / 100), 0),
                            round(((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.cuahpc / 100), 0),
                            round((((refdet_rec1.icb3va / refdet_rec.cnt) * refdet_rec.collection_fee / 100))) + round(round((((refdet_rec1
                            .icb3va / refdet_rec.cnt) *(refdet_rec.collection_fee / 100)))) * 0.08)
                        );

                        v_output_count := v_output_count + 1;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_errormsg := v_errormsg
                                          || ' '
                                          || sqlerrm;
                            error_logs('TITDMGREF2', refdet_rec.apcucd, substr(v_errormsg, 1, 200));
                            l_err_flg := 1;
                    END;

                    l_refcnt1 := l_refcnt1 - 1;
                    IF l_refcnt2 = refdet_rec.cnt THEN
                        l_refcnt2 := 0;
                    END IF;
                    IF l_app_old <> refdet_rec.apcucd THEN
                        IF l_err_flg = 1 THEN
                                     --ROLLBACK;
                            l_err_flg := 0;
                        END IF;
                        COMMIT;
                    END IF;

                    l_app_old := refdet_rec.apcucd;
                END LOOP;

            END LOOP;

            CLOSE zmric00_cur;
        END LOOP;

        CLOSE refdet_cur;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

            COMMIT;
    END dm_refunddets_transform;

-- Procedure for DM DM_Refunddets_transform <ENDS> Here

-- Procedure for DM  Member policy transformation <STARTS> Here

    PROCEDURE dm_mempol_grp_pol (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit            PLS_INTEGER := p_array_size;
        v_errormsg         VARCHAR2(2000) := ' ';
        l_app_old          VARCHAR2(60) := NULL;
        v_input_count      NUMBER;
        v_output_count     NUMBER;
        temp_no            NUMBER;
        grp_pol_free_cnt   INT;
        v_source           VARCHAR(500);
        v_in1              NUMBER;
        CURSOR grp_pol_free IS
        SELECT
            *
        FROM
            grp_policy_free;

        grp_pol_free_rec   grp_pol_free%rowtype;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_app_old := NULL;
        SELECT
            COUNT(*)
        INTO v_input_count
        FROM
            grp_policy_free;

        v_source := 'GRP_POLICY_FREE:' || v_input_count;
        v_errormsg := 'DM_Mempol_transform_grp_policy:';
        BEGIN
            IF p_delta = 'Y' THEN
                DELETE FROM maxpolnum
                WHERE
                    EXISTS (
                        SELECT
                            'X'
                        FROM
                            tmp_zmrap00 dt
                        WHERE
                            substr(dt.apcucd, 1, 8) = apcucd
                    );

                COMMIT;
            END IF;

            INSERT INTO maxpolnum
                ( SELECT
                    apcucd,
                    minapcucd,
                    maxapcucd
                FROM
                    (
                        SELECT
                            substr(apcucd, 1, 8) apcucd,
                            MIN(apcucd) minapcucd,
                            MAX(apcucd) maxapcucd
                        FROM
                            zmrap00 a
                        WHERE
                            NOT EXISTS (
                                SELECT
                                    'X'
                                FROM
                                    maxpolnum dt
                                WHERE
                                    apcucd = substr(a.apcucd, 1, 8)
                            )
                        GROUP BY
                            substr(apcucd, 1, 8)
                    )
                );

            COMMIT;
        END;

        v_errormsg := 'Master cursor_grp_pol';
   ---PROCESS TO BEGIN UPDATING OF THE GROUP POLICY FROM PJ TO THE ZMRAP00
        OPEN grp_pol_free;
        LOOP
            FETCH grp_pol_free INTO grp_pol_free_rec;
            EXIT WHEN grp_pol_free%notfound;
            BEGIN
                UPDATE zmrap00
                SET
                    apcwcd = grp_pol_free_rec.grp_policy_no_pj
                WHERE
                    apc6cd = grp_pol_free_rec.endorsercode
                    AND apc1cd = grp_pol_free_rec.campaign;

                v_output_count := v_output_count + SQL%rowcount;
                l_app_old := grp_pol_free_rec.grp_policy_no_pj;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    error_logs('TITDMGMBRINDP1_GRPPOL', grp_pol_free_rec.grp_policy_no_pj, v_errormsg);
            END;

        END LOOP;

        COMMIT;
        CLOSE grp_pol_free;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := dm_data_transform.control_log(v_source, 'GRPPOL_ZMRAP00', systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_transform.control_log(v_source, 'GRPPOL_ZMRAP00', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            dm_data_transform.error_logs('TITDMGMBRINDP1_GRPPOL', grp_pol_free_rec.grp_policy_no_pj, substr(v_errormsg, 1, 200));

            l_err_flg := 1;
    END dm_mempol_grp_pol;

    PROCEDURE dm_mempol_oldpol (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit          PLS_INTEGER := p_array_size;
        v_errormsg       VARCHAR2(2000) := ' ';
        l_date_old       DATE := NULL;
        application_no   VARCHAR2(13);
        bank_cnt         NUMBER := 0;
        v_input_count    NUMBER;
        v_output_count   NUMBER;
        temp_no          NUMBER;
        l_cnt1           INT;
        sqlstmt          VARCHAR2(3000);
        v_source         VARCHAR(300);
        l_app_old        VARCHAR2(13);
        CURSOR pol_app IS
        SELECT
            a.apcucd    AS mp,
            b.n         AS ip,
            a.apevst    mp_apevt,
            b.apevst1   ip_apevt,
            (
                CASE
                    WHEN a.apevst <> apevst1 THEN
                        a1
                END
            ) oldpolnum,
            (
                CASE
                    WHEN a.apevst = apevst1 THEN
                        substr(a.apcucd, 1, 8)
                END
            ) AS refno,
            (
                CASE
                    WHEN a.apevst <> apevst1 THEN
                        substr(n, 1, 8)
                END
            ) zconvpol
        FROM
            zmrap00 a,
            (
                SELECT
                    MAX(apcucd) n,
                    substr(apyob6, 5, 8) a1,
                    apevst AS apevst1
                FROM
                    zmrap00
                GROUP BY
                    substr(apyob6, 5, 8),
                    apevst
            ) b
        WHERE
            substr(a.apcucd, 1, 8) = a1
            AND a.apcucd IN (
                SELECT
                    maxapcucd
                FROM
                    maxpolnum
            );   --select APCUCD from ZMRAP00 ;

        pol_app_rec      pol_app%rowtype;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_app_old := NULL;
        SELECT
            COUNT(*)
        INTO v_input_count
        FROM
            zmrap00;

        v_source := 'ZMRAP00 :' || v_input_count;
        v_errormsg := 'DM_Mempol_transform_OLD_policy:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load_grp_policy:';
            DELETE FROM mempol;

            COMMIT;
        END IF;

        v_errormsg := 'Master DM_Mempol_transform_OLD_policy';

   ---PROCESS TO BEGIN UPDATING OF THE GROUP POLICY FROM PJ TO THE ZMRAP00
        OPEN pol_app;
        LOOP
            FETCH pol_app INTO pol_app_rec;
            v_input_count := v_input_count + SQL%rowcount;
            EXIT WHEN pol_app%notfound;
            BEGIN
                INSERT INTO mempol VALUES (
                    pol_app_rec.mp,
                    pol_app_rec.ip,
                    pol_app_rec.mp_apevt,
                    pol_app_rec.ip_apevt,
                    pol_app_rec.oldpolnum,
                    pol_app_rec.refno,
                    pol_app_rec.zconvpol
                );

                v_output_count := v_output_count + SQL%rowcount;
                l_app_old := pol_app_rec.mp;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    dm_data_transform.error_logs('TITDMGMBRINDP1_OLDPOL', l_app_old, v_errormsg);
            END;

        END LOOP;

        dbms_output.put_line('complete');
        CLOSE pol_app;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := dm_data_transform.control_log(v_source, 'MEMPOL', systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_transform.control_log(v_source, 'MEMPOL', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            dm_data_transform.error_logs('oldpol', pol_app_rec.mp, substr(v_errormsg, 1, 200));

            l_err_flg := 1;
            COMMIT;
    END dm_mempol_oldpol;

 PROCEDURE dm_mempol_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
      
    ) AS

        v_input_count          NUMBER;
        v_output_count         NUMBER;
        c_limit                PLS_INTEGER := p_array_size;
        v_errormsg             VARCHAR2(2000) := ' ';
        application_no         VARCHAR2(13);
        v_source               VARCHAR(200);
       /* CURSOR zmrap00_appl_cur IS
        SELECT
            apcucd,
            minapcucd,
            substr(maxapcucd,1,8) as maxapcucd
        FROM
            maxpolnum a
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    titdmgmbrindp1 b
                WHERE
                    substr(b.refnum, 1, 8) = a.apcucd
            )
        ORDER BY
            apcucd;*/

    CURSOR zmrap00_cur  IS
    SELECT *
    FROM
        (
            SELECT
                refnum,
                gpoltype,
                zendcde,
                zcmpcode,
                mpolnum,
                effdate,
                months_between(to_date(crdate, 'yyyymmdd'), to_date(effdate, 'yyyymmdd')) AS zpolperd,
                NULL AS zmargnflg,
                NULL AS zdfcncy,
                docrcvdt,
                hpropdte,
                ztrxstat,
                NULL AS zstatresn,
                NULL AS zanncldt,
                NULL AS zcpnscde02,
                zsalechnl,
                zsolctflg,
                NULL AS cltreln,
                NULL AS zplancde,
                crdtcard,
                NULL AS preautno,
                apeicd AS bnkacckey01,
                nvl(
                    CASE
                        WHEN endorserspec_tab1 = 'APC0CD' THEN
                            endorserspec1
                        WHEN endorserspec_tab1 = 'APB8TX' THEN
                            endorserspec1
                        WHEN substr(refnum, - 3) = '000'
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN apdlcd = 'ID'
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN apdlcd <> 'ID'               THEN
                            LAG(endorserspec1 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY
                                    refnum
                            )
                    END, '                    ') AS zenspcd01,
                nvl(
                    CASE
                        WHEN endorserspec_tab2 = 'APC0CD' THEN
                            endorserspec2
                        WHEN endorserspec_tab2 = 'APB8TX' THEN
                            endorserspec2
                        WHEN substr(refnum, - 3) = '000'
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN apdlcd = 'ID'
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN apdlcd <> 'ID'               THEN
                            LAG(endorserspec2 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY
                                    refnum
                            )
                    END, '                    ') AS zenspcd02,
                nvl(
                    CASE
                        WHEN cif_tab = 'APC0CD' THEN
                            cif
                        WHEN cif_tab = 'APB8TX' THEN
                            cif
                        WHEN substr(refnum, - 3) = '000'
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN apdlcd = 'ID'
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN apdlcd <> 'ID'     THEN
                            LAG(cif IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY
                                    refnum
                            )
                    END, '               ') AS zcifcode,
                dtetrm,
                crdate,
                cnttypind,
                nvl(ptdate, 99999999) AS ptdate,
                nvl(btdate, 99999999) AS btdate,
                nvl(statcode, '  ') AS statcode,
                NULL AS zwaitpedt,
                zconvindpol,
                zpoltdate,
                NULL AS oldpolnum,
                zpgpfrdt,
                zpgptodt,
                sinstno,
                trefnum,
                endsercd,
                NULL AS issdate,
                zpdatatxflg,
                occdate,
                '0' client_category,
                NULL AS mbrno,
                zinsrole,
                '1' AS tranno,
                clientno,
                zrwnlage,
                znbmnage,
                termage,
                zblnkpol,
                plnclass
            FROM
                (
                    SELECT
                        a.apcucd        AS refnum,
                        nvl(a.apc7cd, '   ') AS gpoltype,
                        nvl(a.apc6cd, '            ') AS zendcde,
                        nvl(RPAD(a.apc1cd,6,0), '            ') AS zcmpcode, 
                        CASE
                            WHEN c.rptfpst = 'P'
                                 AND a.apevst = '1' THEN
                                ' '
                            WHEN c.rptfpst = 'P'
                                 AND a.apevst <> '1' THEN
                                substr(a.apcwcd, - 8)
                            WHEN c.rptfpst = 'F' THEN
                                a.apcwcd
                        END AS mpolnum,
                        g.orgcommdate   AS effdate,
                        a.apcvcd        AS docrcvdt,
                        a.apcvcd        AS hpropdte,
                        CASE
                            WHEN c.rptfpst = 'F' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        'AP'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'AP'
                                    WHEN a.apblst = '5' THEN
                                        'RJ'
                                END
                            WHEN c.rptfpst = 'P' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        'AP'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'AP'
                                    WHEN a.apblst = '5' THEN
                                        'RJ'
                                END
                        END AS ztrxstat,
                        CASE
                            WHEN a.apyob9 = 0 THEN
                                10
                            WHEN a.apyob9 = 1 THEN
                                20
                            WHEN a.apyob9 = 2 THEN
                                99
                            WHEN a.apyob9 = 3 THEN
                                30
                        END AS zsalechnl,
                        nvl2(p.product_code, 'Y', 'N') AS zsolctflg,
                        CASE
                            WHEN a.apblst = '2' THEN
                                CASE
                                    WHEN a.apcycd BETWEEN 50 AND 69
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        99999999
                                    WHEN a.apcycd BETWEEN 50 AND 69
                                         AND pj.btdate IS NULL
                                         AND c.rptfpst = 'F' THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', a.apa2dt, 99999999)
                                    WHEN a.apcycd BETWEEN 50 AND 69
                                         AND pj.btdate IS NULL
                                         AND c.rptfpst = 'P' THEN
                                        a.apa2dt
                                    WHEN a.apcycd BETWEEN 50 AND 69
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        a.apa2dt
                                    ELSE
                                        99999999
                                END
                            WHEN a.apblst = '5' THEN
                                a.apa2dt
                            ELSE
                                99999999
                        END AS dtetrm,
                        a.apbedt        AS crdate,
                        CASE
                            WHEN a.apevst = '1' THEN
                                'I'
                            WHEN a.apevst = '2' THEN
                                'M'
                        END AS cnttypind,
                        CASE
                            WHEN c.rptfpst = 'F' THEN
                                to_number(to_char(to_date(a.apbedt, 'yyyymmdd') - 1, 'yyyymmdd'))
                            WHEN c.rptfpst = 'P' THEN
                                to_number(to_char(pj.ptdate, 'YYYYMMDD'))
                        END AS ptdate,
                        CASE
                            WHEN c.rptfpst = 'F' THEN
                                to_number(to_char(to_date(a.apbedt, 'yyyymmdd') - 1, 'yyyymmdd'))
                            WHEN c.rptfpst = 'P' THEN
                                to_number(to_char(pj.btdate, 'YYYYMMDD'))
                        END AS btdate,
                        CASE
                            WHEN c.rptfpst = 'F' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        'IF'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'CA', 'IF')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'IF'
                                    WHEN a.apblst = '5' THEN
                                        'CA'
                                END
                            WHEN c.rptfpst = 'P' THEN
                                CASE
                                    WHEN a.apblst = '1' THEN
                                        nvl2(pj.btdate, pj.statcode, 'XN')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) = '*' THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NULL THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        'IF'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69
                                         AND substr(a.apdlcd, 1, 1) <> '*'
                                         AND pj.btdate IS NOT NULL
                                         AND a.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                        'CA'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        nvl2(pj.btdate, pj.statcode, 'XN')
                                    WHEN a.apblst = '5' THEN
                                        'CA'
                                END
                        END statcode,
                        decode(apdlcd, 'C6', mp.zconvpol, NULL) AS zconvindpol,
                        CASE
                            WHEN a.apblst = '2'
                                 AND a.apcycd BETWEEN 50 AND 69
                                 AND pj.btdate IS NOT NULL
                                 AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                apa2dt
                            ELSE
                                99999999
                        END zpoltdate,
                        nvl(pj.zpgpfrdt, 99999999) AS zpgpfrdt,
                        nvl(pj.zpgptodt, 99999999) AS zpgptodt,
                        substr(decode(c.rptfpst, 'F', 1, a.aplacd * 12), 1, 3) sinstno,
                        mp.refno        AS trefnum,
                        pj.endsercd,
                        decode(a.apflst, '1', 'Y', NULL) AS zpdatatxflg,
                        g.orgcommdate   AS occdate,
                        substr(x.insur_role, 2) AS zinsrole,
                        x.stg_clntnum   AS clientno,
                        r.ulab0nb       AS zrwnlage,
                        minnbage(a.apc6cd, a.apc7cd, c.rptfpst, i.icdmcd) AS znbmnage,
                        r.ulanwlt       AS termage,
                        decode(a.apc7cd, 'BDT', 'Y', 'BBT', 'Y', 'N') zblnkpol,
                        c.rptfpst       AS plnclass,
                        d.endorserspec_tab1,
                        d.endorserspec_tab2,
                        d.cif_tab,
                        a.apdlcd,
                        a.apeicd as apeicd,
                        CASE
                            WHEN d.crdt_tab1 = 'APC0CD' THEN
                                a.apc0cd
                        END AS crdtcard,                            
                        CASE
                            WHEN d.endorserspec_tab1 = 'EICTID'
                                 AND d.endorser1_pos IS NOT NULL THEN
                                substr(e.eictid, d.endorser1_pos, d.endorser1_len)
                            WHEN d.endorserspec_tab1 = 'EICTID'
                                 AND d.endorser1_pos IS NULL THEN
                                e.eictid
                            WHEN d.endorserspec_tab1 = 'APC0CD' THEN
                                a.apc0cd
                            WHEN d.endorserspec_tab1 = 'APB8TX' THEN
                                a.apb8tx
                        END AS endorserspec1,
                        CASE
                            WHEN d.endorserspec_tab2 = 'EICTID'
                                 AND d.endorser2_pos IS NOT NULL THEN
                                substr(e.eictid, d.endorser2_pos, d.endorser2_len)
                            WHEN d.endorserspec_tab2 = 'EICTID'
                                 AND d.endorser2_pos IS NULL THEN
                                e.eictid
                            WHEN d.endorserspec_tab2 = 'APC0CD' THEN
                                a.apc0cd
                            WHEN d.endorserspec_tab2 = 'APB8TX' THEN
                              a.apb8tx
                        END AS endorserspec2,
                        CASE
                            WHEN d.cif = 'CIF'
                                 AND d.cif_pos IS NOT NULL THEN
                                substr(e.eictid, d.cif_pos, d.cif_len)
                            WHEN d.cif = 'CIF'
                                 AND d.cif_pos IS NULL THEN
                                e.eictid
                            WHEN d.cif_tab = 'APC0CD' THEN
                                a.apc0cd
                            WHEN d.cif_tab = 'APB8TX' THEN
                                a.apb8tx
                        END AS cif
                    FROM
                        zmrap00                 a
                        INNER JOIN persnl_clnt_flg         x ON a.apcucd = x.apcucd
                                                        AND x.isa4st IS NULL
                        LEFT JOIN zmrrpt00                c ON a.apc7cd = c.rptbtcd
                        LEFT JOIN zmrei00                 e ON a.apcucd = e.eicucd
                        LEFT JOIN solicitation_flg_list   p ON a.apc7cd = p.product_code
                        LEFT JOIN (
                            SELECT
                                endorsercode,
                                MAX(decode(filetype, 'CreditCard', 'CreditCard')) crdt,
                                MAX(decode(filetype, 'CreditCard', fieldname)) crdt_tab1,
                                MAX(decode(filetype, 'BankAccount', 'BankAccount')) bnk,
                                MAX(decode(filetype, 'BankAccount', fieldname)) bank_tab1,
                                MAX(decode(filetype, 'EndorserSpecCode1', 'EndorserSpecCode1')) endorserspec1,
                                MAX(decode(filetype, 'EndorserSpecCode1', fieldname)) endorserspec_tab1,
                                MAX(decode(filetype, 'EndorserSpecCode1', st_pos)) endorser1_pos,
                                MAX(decode(filetype, 'EndorserSpecCode1', datalength)) endorser1_len,
                                MAX(decode(filetype, 'EndorserSpecCode2', 'EndorserSpecCode2')) endorserspec2,
                                MAX(decode(filetype, 'EndorserSpecCode2', fieldname)) endorserspec_tab2,
                                MAX(decode(filetype, 'EndorserSpecCode2', st_pos)) endorser2_pos,
                                MAX(decode(filetype, 'EndorserSpecCode2', datalength)) endorser2_len,
                                MAX(decode(filetype, 'CIF', 'CIF')) cif,
                                MAX(decode(filetype, 'CIF', fieldname)) cif_tab,
                                MAX(decode(filetype, 'CIF', st_pos)) cif_pos,
                                MAX(decode(filetype, 'CIF', datalength)) cif_len
                            FROM
                                card_endorser_list
                            WHERE
                                filetype IN (
                                    'CreditCard',
                                    'BankAccount',
                                    'EndorserSpecCode1',
                                    'EndorserSpecCode2',
                                    'CIF'
                                )
                            GROUP BY
                                endorsercode
                        ) d ON a.apc6cd = d.endorsercode
                        LEFT JOIN btdate_ptdate_list      pj ON substr(a.apcucd, 1, 8) = pj.chdrnum
                        LEFT JOIN zmrula00                r ON a.apc6cd = r.ulac6cd
                                                AND a.apc7cd = r.ulac7cd
                        LEFT JOIN (
                            SELECT
                                iccucd,
                                icdmcd
                            FROM
                                zmric00
                            WHERE
                                iccicd LIKE '%01'
                                AND icdmcd = 'SPA'
                                AND ROWNUM = 1
                        ) i ON a.apcucd = i.iccucd
                        LEFT JOIN (
                            SELECT
                                apcucd   AS pjapp,
                                apa2dt   AS orgcommdate
                            FROM
                                zmrap00
                            WHERE
                                substr(apcucd, - 3) = '000'
                        ) g ON substr(a.apcucd, 1, 8) = substr(g.pjapp, 1, 8)
                        LEFT JOIN mempol_view  mp ON a.apcucd = mp.mp
                        --join maxpolnum xa on xa.maxapcucd = a.apcucd
                 --   WHERE
                    --   a.apcucd in (SELECT maxapcucd from maxpolnum xa)
                )
            UNION ALL
            SELECT
                a.apcucd         AS refnum,
                NULL AS gpoltype,
                NULL AS zendcde,
                NULL AS zcmpcode,
                NULL AS mpolnum,
                g.orgcommdate    AS effdate,
                NULL AS zpolperd,
                'N' AS zmargnflg,
                'N' AS zdfcncy,
                a.apcvcd         AS docrcvdt,
                a.apcvcd         AS hpropdte,
                CASE
                    WHEN d.rptfpst = 'F' THEN
                        CASE
                            WHEN a.apblst = '1' THEN
                                'AP'
                            WHEN a.apblst = '2'
                                 AND a.apcycd BETWEEN 50 AND 69 THEN
                                decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                            WHEN a.apblst = '2'
                                 AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                'AP'
                            WHEN a.apblst = '5' THEN
                                'RJ'
                        END
                    WHEN d.rptfpst = 'P' THEN
                        CASE
                            WHEN a.apblst = '1' THEN
                                'AP'
                            WHEN a.apblst = '2'
                                 AND a.apcycd BETWEEN 50 AND 69 THEN
                                decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                            WHEN a.apblst = '2'
                                 AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                'AP'
                            WHEN a.apblst = '5' THEN
                                'RJ'
                        END
                END AS ztrxstat,
                (
                    SELECT DISTINCT
                        ig_r_code
                    FROM
                        decline_reason_code
                    WHERE
                        a.apdlcd = dm_r_code
                        AND ROWNUM = 1
                ) AS zstatresn,
                a.apcvcd         AS zanncldt,
                a.apl6cd         AS zcpnscde02,
                NULL AS zsalechnl,
                NULL AS zsolctflg,
                b.isa4st         AS cltreln,
                sp.newzsalplan   AS zplancde,
                NULL AS crdtcard,
                NULL AS preautno,
                NULL AS bnkacckey01,
                '                    ' AS zenspcd01,
                '                    ' AS zenspcd02,
                '               ' AS zcifcode,
                CASE
                    WHEN a.apblst = '2'
                         AND a.apcycd BETWEEN 50 AND 69
                         AND pj.btdate IS NOT NULL
                         AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                        99999999
                    WHEN a.apblst = '2'
                        AND a.apcycd BETWEEN 50 AND 69
                         AND pj.btdate IS NULL
                         AND d.rptfpst = 'F' THEN
                        decode(substr(a.apdlcd, 1, 1), '*', apa2dt, 99999999)
                    WHEN a.apblst = '2'
                         AND a.apcycd BETWEEN 50 AND 69
                         AND pj.btdate IS NULL
                         AND d.rptfpst = 'P' THEN
                        apa2dt
                    WHEN a.apblst = '2'
                         AND a.apcycd BETWEEN 50 AND 69
                         AND pj.btdate IS NOT NULL
                         AND a.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                        a.apa2dt
                    WHEN a.apblst = '5' THEN
                        a.apa2dt
                    ELSE
                        99999999
                END AS dtetrm,
                a.apbedt         AS crdate,
                CASE
                    WHEN a.apevst = '1' THEN
                        'I'
                    WHEN a.apevst = '2' THEN
                        'M'
                END AS cnttypind,
                NULL AS ptdate,
                NULL AS btdate,
                '  ' AS statcode,
                NULL AS zwaitpedt,
                NULL AS zconvindpol,
                NULL AS zpoltdate,
                NULL AS oldpolnum,
                NULL AS zpgpfrdt,
                NULL AS zpgptodt,
                NULL AS sinstno,
                NULL AS trefnum,
                NULL AS endsercd,
                a.apyoba         AS issdate,
                NULL AS zpdatatxflg,
                NULL AS occdate,
                '1' client_category,
                substr(b.iscicd, - 2) AS mbrno,
                substr(x.insur_role, 2) AS zinsrole,
                '1' AS tranno,
                x.stg_clntnum    AS clientno,
                NULL AS zrwnlage,
                NULL AS znbmnage,
                NULL AS termage,
                NULL AS zblnkpol,
                NULL AS plnclass
            FROM
                zmrap00              a
                INNER JOIN persnl_clnt_flg      x ON a.apcucd = x.apcucd
                                                AND x.isa4st IS NOT NULL
                INNER JOIN zmris00              b ON b.iscicd = x.iscicd
                LEFT JOIN zmrrpt00             d ON a.apc7cd = d.rptbtcd
                LEFT JOIN btdate_ptdate_list   pj ON substr(a.apcucd, 1, 8) = pj.chdrnum
                LEFT JOIN spplanconvertion     sp ON b.iscjcd = sp.oldzsalplan
                LEFT JOIN (
                    SELECT
                        apcucd   AS pjapp,
                        apa2dt   AS orgcommdate
                    FROM
                        zmrap00
                    WHERE
                        substr(apcucd, - 3) = '000'
                ) g ON substr(a.apcucd, 1, 8) = substr(g.pjapp, 1, 8)
            --WHERE
          --      a.apcucd in (SELECT maxapcucd from (SELECT a.maxapcucd as maxapcucd FROM maxpolnum a )
          --a.apcucd in (SELECT maxapcucd from maxpolnum xa)
        ) 
    WHERE
        refnum IN (
            SELECT
                maxapcucd
            FROM
                maxpolnum
        );
      
        --TYPE zmrap00_appcur IS
        --    TABLE OF zmrap00_appl_cur%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF zmrap00_cur%rowtype;
        --TYPE t_clnbnk_crd_t IS
        --    TABLE OF titdmgclntbank%rowtype;
        --zmrap00_appls     zmrap00_appcur;
        zmrap00_l_appls   zmrap00_cur_t;

        temp_no varchar2(2500);
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        v_errormsg := 'DM_MEMPOL_transform:';
        v_source :='zmrap00,  persnl_clnt_flg, zmris00 , zmrrpt00 ';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgmbrindp1 t
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = substr(t.refnum, 1, 8)
                );

            COMMIT;
        END IF;

        OPEN zmrap00_cur;
        LOOP
            FETCH zmrap00_cur BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
            v_input_count := v_input_count + zmrap00_l_appls.count;
            FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
                                                            v_errormsg := 'Inser Target';
            
            BEGIN
                    INSERT INTO titdmgmbrindp1 (
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
                        plnclass
                    ) VALUES (
                        zmrap00_l_appls(l_apindx).refnum,
                        zmrap00_l_appls(l_apindx).gpoltype,
                        zmrap00_l_appls(l_apindx).zendcde,
                        zmrap00_l_appls(l_apindx).zcmpcode,
                        zmrap00_l_appls(l_apindx).mpolnum,
                        zmrap00_l_appls(l_apindx).effdate,
                        zmrap00_l_appls(l_apindx).zpolperd,
                        zmrap00_l_appls(l_apindx).zmargnflg,
                        zmrap00_l_appls(l_apindx).zdfcncy,
                        zmrap00_l_appls(l_apindx).docrcvdt,
                        zmrap00_l_appls(l_apindx).hpropdte,
                        zmrap00_l_appls(l_apindx).ztrxstat,
                        zmrap00_l_appls(l_apindx).zstatresn,
                        zmrap00_l_appls(l_apindx).zanncldt,
                        zmrap00_l_appls(l_apindx).zcpnscde02,
                        zmrap00_l_appls(l_apindx).zsalechnl,
                       zmrap00_l_appls(l_apindx).zsolctflg,
                        zmrap00_l_appls(l_apindx).cltreln,
                        zmrap00_l_appls(l_apindx).zplancde,
                        zmrap00_l_appls(l_apindx).crdtcard,
                        zmrap00_l_appls(l_apindx).preautno,
                        zmrap00_l_appls(l_apindx).bnkacckey01,
                        zmrap00_l_appls(l_apindx).zenspcd01,
                        zmrap00_l_appls(l_apindx).zenspcd02,
                        zmrap00_l_appls(l_apindx).zcifcode,
                        zmrap00_l_appls(l_apindx).dtetrm,
                        zmrap00_l_appls(l_apindx).crdate,
                        zmrap00_l_appls(l_apindx).cnttypind,
                        zmrap00_l_appls(l_apindx).ptdate,
                        zmrap00_l_appls(l_apindx).btdate,
                        zmrap00_l_appls(l_apindx).statcode,
                        zmrap00_l_appls(l_apindx).zwaitpedt,
                        zmrap00_l_appls(l_apindx).zconvindpol,
                        zmrap00_l_appls(l_apindx).zpoltdate,
                        zmrap00_l_appls(l_apindx).oldpolnum,
                        zmrap00_l_appls(l_apindx).zpgpfrdt,
                        zmrap00_l_appls(l_apindx).zpgptodt,
                        zmrap00_l_appls(l_apindx).sinstno,
                        zmrap00_l_appls(l_apindx).trefnum,
                        zmrap00_l_appls(l_apindx).endsercd,
                        zmrap00_l_appls(l_apindx).issdate,
                        zmrap00_l_appls(l_apindx).zpdatatxflg,
                        zmrap00_l_appls(l_apindx).occdate,
                        zmrap00_l_appls(l_apindx).client_category,
                        zmrap00_l_appls(l_apindx).mbrno,
                        zmrap00_l_appls(l_apindx).zinsrole,
                        0,
                        0,
                        zmrap00_l_appls(l_apindx).clientno,
                        zmrap00_l_appls(l_apindx).zrwnlage,
                        zmrap00_l_appls(l_apindx).znbmnage,
                        zmrap00_l_appls(l_apindx).termage,
                        zmrap00_l_appls(l_apindx).zblnkpol,
                        zmrap00_l_appls(l_apindx).plnclass
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_transform.error_logs('TITDMGMBRINDP1', zmrap00_l_appls(l_apindx).refnum, v_errormsg);
                END;
      
            END LOOP;
            EXIT WHEN zmrap00_cur%notfound;
                                             COMMIT;
        END LOOP;
        COMMIT;
        CLOSE zmrap00_cur;
       /* UPDATE titdmgmbrindp1 a
        SET
            statcode = (
                SELECT
                    statcode
                FROM
                    titdmgmbrindp1 b
                WHERE
                    client_category = 0
                    AND a.refnum = b.refnum
            )
        WHERE
            client_category = 1;

        COMMIT; */
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no :=dm_data_transform.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_transform.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);

            dbms_output.put_line(v_errormsg);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            error_logs('TITDMGMBRINDP1_trans', application_no, v_errormsg);
           temp_no := dm_data_transform.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);

            dbms_output.put_line(v_errormsg);
            return;
    END dm_mempol_transform;




    PROCEDURE dm_mempol_btptupdate (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        c_limit           PLS_INTEGER := p_array_size;
        v_errormsg        VARCHAR2(2000) := ' ';
        l_credit          VARCHAR2(30) := NULL;
        l_credit_old      VARCHAR2(30) := NULL;
        l_app_old         VARCHAR2(60) := NULL;
        l_currdt          VARCHAR2(8);
        l_date            DATE := NULL;
        l_date_old        DATE := NULL;
        application_no    VARCHAR2(13);
        bank_cnt          NUMBER := 0;
        v_input_count     NUMBER;
        v_output_count    NUMBER;
        v_output_count1   NUMBER;
        temp_no           NUMBER;
        mempol_cnt        NUMBER;
        bt_pt_date_cnt    INT;
        v_source          VARCHAR(200);
        CURSOR bt_pt_date IS
        SELECT
            *
        FROM
            btdate_ptdate_list;

        bt_pt_date_rec    bt_pt_date%rowtype;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        l_app_old := NULL;
        v_output_count1 := 0;
        SELECT
            COUNT(*)
        INTO v_input_count
        FROM
            btdate_ptdate_list;

        SELECT
            COUNT(*)
        INTO mempol_cnt
        FROM
            titdmgmbrindp1;

        v_source := 'BTDATE_PTDATE_LIST :'
                    || v_input_count
                    || ', TITDMGMBRINDP1 :'
                    || mempol_cnt;
        v_errormsg := 'DM_Mempol_transform_BTDATEUPDATE:';
        v_errormsg := 'Master DM_Mempol_transform_BTDATEUPDATE';
   ---PROCESS TO BEGIN UPDATING OF THE GROUP POLICY FROM PJ TO THE ZMRAP00
        OPEN bt_pt_date;
        LOOP
            FETCH bt_pt_date INTO bt_pt_date_rec;
            l_app_old := bt_pt_date_rec.chdrnum;
            EXIT WHEN bt_pt_date%notfound;
            dbms_output.put_line('before update:' || bt_pt_date_rec.chdrnum);
            BEGIN
                UPDATE titdmgmbrindp1
                SET
                    btdate = to_char(bt_pt_date_rec.btdate, 'YYYYMMDD'),
                    ptdate = to_char(bt_pt_date_rec.ptdate, 'YYYYMMDD'),
                    zpgpfrdt = bt_pt_date_rec.zpgpfrdt,
                    zpgptodt = bt_pt_date_rec.zpgptodt,
                    endsercd = bt_pt_date_rec.endsercd
                WHERE
                    substr(refnum, 1, 8) = bt_pt_date_rec.chdrnum;

                COMMIT;
                v_output_count := v_output_count + SQL%rowcount;
                UPDATE titdmgmbrindp1
                SET
                    statcode = bt_pt_date_rec.statcode
                WHERE
                    substr(refnum, 1, 8) = bt_pt_date_rec.chdrnum
                    AND statcode = 'PJ';

                v_output_count1 := v_output_count1 + SQL%rowcount;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    dm_data_transform.error_logs('BTDT_MBRINDP1', bt_pt_date_rec.chdrnum, v_errormsg);
            END;

        END LOOP;

        CLOSE bt_pt_date;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := dm_data_transform.control_log(v_source, 'BTDT_MBRINDP1', systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_transform.control_log(v_source, 'BTDT_MGMBRINDP1', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            dm_data_transform.error_logs('BTDT_MBRINDP1', bt_pt_date_rec.chdrnum, substr(v_errormsg, 1, 200));

            l_err_flg := 1;
    END dm_mempol_btptupdate;


-- Procedure for DM  Member policy transformation <ENDS> Here

--- Start DM Campaign and Sale plan code ------

    PROCEDURE dm_saleplan_camp_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

   /* TYPE IG_ARRAY IS RECORD
    (
    ST_ZCMPCODE ZMRCP00.CPBCCD%TYPE,
    ST_ZSALPLAN ZMRRP00.RPBVCD%TYPE,
    ST_ENDORSER_CODE ZMRRP00.RPFOCD%TYPE
    );
    TYPE ST_DATA IS TABLE OF IG_ARRAY;*/

        v_app            stagedbusr2.titdmgzcslpf%rowtype;
        l_appno          VARCHAR2(20);
        ig_starttime     TIMESTAMP;
        ig_endtime       TIMESTAMP;
        v_errormsg       VARCHAR2(2000);
        temp_no          NUMBER;
        sql_stmt         VARCHAR2(100);
        row_count        NUMBER(10) DEFAULT 0;
        tmp_sql_stmt     VARCHAR2(100);
        tmp_row_count    NUMBER(10) DEFAULT 0;
        stg_starttime    TIMESTAMP;
        v_input_count    NUMBER(10) DEFAULT 0;
        v_ip_stmt        VARCHAR2(100);
        v_output_count   NUMBER(10) DEFAULT 0;
        v_op_stmt        VARCHAR2(100);
        g_err_flg        VARCHAR2(20);
        l_err_flg        NUMBER(10) DEFAULT 0;
        application_no   VARCHAR2(20);


 /*   CURSOR cur_tempt IS
  SELECT
        zmrcp00.cpbccd,
        zmrrp00.rpbvcd,
        ZMRRP00.RPFOCD
        FROM
        zmrcp00
        INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd )
                              AND ( zmrcp00.cpbdcd = zmrrp00.rpfocd );
                               SELECT zmrcp00.cpbccd,
        zmrrp00.rpbvcd
        FROM
        zmrcp00 INNER JOIN zmrrp00
            ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                 AND
                zmrcp00.cpbdcd = zmrrp00.rpfocd )
        group by
        zmrcp00.cpbccd,
        zmrrp00.rpbvcd;

   TYPE IG_ARRAY IS TABLE OF cur_tempt%ROWTYPE;
   ST_DATA IG_ARRAY; */
    BEGIN
        stg_starttime := systimestamp;
        v_errormsg := 'TEMP Table:';
  --  v_output_count := 0;
  --  v_input_count := 0;
        g_err_flg := 0;
        sql_stmt := 'select count(*) as row_count from STAGEDBUSR2.TITDMGZCSLPF';
        IF row_count > 0 THEN
            DELETE FROM stagedbusr2.titdmgzcslpf;

            COMMIT;
        END IF;
        tmp_sql_stmt := 'select count(*) as tmp_row_count from STAGEDBUSR2.TMP_TITDMGZCSLPF';
        IF tmp_row_count > 0 THEN
            DELETE FROM stagedbusr2.tmp_titdmgzcslpf;

            COMMIT;
        END IF;
--DELETE FROM TEMP1;commit;
        l_err_flg := 0;
        v_errormsg := 'DM_Saleplan_Camp_transform:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM stagedbusr2.titdmgzcslpf
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        zmrcp00   dt,
                        zmrrp00   dt2,
                        SPPlanconvertion sp
                    WHERE
                        dt.cpbecd = dt2.rpbtcd
                        AND dt.cpbdcd = dt2.rpfocd
                        and sp.oldzsalplan = dt2.rpbvcd
                );

            COMMIT;
         -- Delete the records for all the records exists in DM_Annualprem_transform for Delta Load
        END IF;

        v_errormsg := 'Before CUR_TEMPT Cursor:';

  /*  OPEN cur_tempt;

   LOOP
        FETCH cur_tempt BULK COLLECT INTO ST_DATA limit p_array_size;
        v_errormsg := 'Validate No.of Rows in cur_tempt Cursor:';
     /*   FORALL i IN 1..ST_DATA.count


            INSERT INTO tmp_titdmgsalepln2 (
                 zcmpcode,
                zsalplan
            ) VALUES (
                st_data(i).CPBCCD,
                st_data(i).RPBVCD
            );

        EXIT WHEN cur_tempt%notfound;
      --  v_ip_stmt := 'SELECT COUNT(1) FROM ' || ST_DATA;

       -- dbms_output.get_line(v_input_count);
     -- EXECUTE IMMEDIATE v_ip_stmt INTO v_input_count;
    END LOOP;
     v_input_count := cur_tempt%rowcount;
  --  COMMIT;
    CLOSE cur_tempt; */
        EXECUTE IMMEDIATE 'select count(*) from (SELECT count(*)
        FROM
        zmrcp00 INNER JOIN zmrrp00
            ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                 AND
                zmrcp00.cpbdcd = zmrrp00.rpfocd )
        group by
        zmrcp00.cpbccd,
        zmrrp00.rpbvcd) tmp'
        INTO v_input_count;
/*CURSOR A1 IS SELECT RECIDXSLPL2,ZCMPCODE,ZSALPLAN FROM TMP_TITDMGSALEPLN2;

		A1REC A1%ROWTYPE;*/
        v_errormsg := 'A1 cur:';
        l_err_flg := 0;
   -- v_input_count := 0;
   -- v_output_count := 0;

--OPEN A1;
         --LOOP
        --FETCH A1 BULK COLLECT INTO A1REC LIMIT p_array_size;
       -- EXIT WHEN A1%NOTFOUND;
  /*  FOR j IN (
        SELECT
            recidxslpl2,
            zcmpcode,
            zsalplan
        FROM
            tmp_titdmgsalepln2
        GROUP BY
            tmp_titdmgsalepln2.zcmpcode,
            tmp_titdmgsalepln2.zsalplan
    ) LOOP
        v_input_count := v_input_count + 1; */
        l_appno := 'test';
        v_errormsg := 'Stage Insert :';
        application_no := 'SALEPLAN';
    /*    INSERT INTO titdmgsalepln2 (
             zcmpcode,
            zsalplan
        ) VALUES (
            j.zcmpcode,
            j.zsalplan
        ); */
        BEGIN
            INSERT /*+ PARALLEL */ INTO stagedbusr2.titdmgzcslpf (
                zcmpcode,
                old_zsalplan,
                zsalplan
            )
             /* OLD SALEPLAN CODE  SELECT
                    zmrcp00.cpbccd,
                    zmrrp00.rpbvcd
                FROM
                    zmrcp00
                    INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                            AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                GROUP BY
                    zmrcp00.cpbccd,
                    zmrrp00.rpbvcd;
                    */
                    -- New Saleplan Code
                SELECT
                    zmrcp00.cpbccd,
                    zmrrp00.rpbvcd,
                    spplanconvertion.newzsalplan
                FROM
                    zmrcp00
                    INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                            AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                    JOIN spplanconvertion ON oldzsalplan = zmrrp00.rpbvcd
                GROUP BY
                    zmrcp00.cpbccd,
                    zmrrp00.rpbvcd,
                    spplanconvertion.newzsalplan;

            EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM STAGEDBUSR2.TITDMGZCSLPF'
            INTO v_output_count;
        -- v_output_count := titdmgsalepln2%rowcount;
    -- EXECUTE IMMEDIATE v_op_stmt INTO v_output_count;
       -- END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                v_errormsg := v_errormsg
                              || '-'
                              || sqlerrm;
                error_logs('TITDMGZCSLPF', application_no, v_errormsg);
                l_err_flg := 1;
                IF ( MOD(v_output_count, v_input_count) = 0 ) THEN
                    COMMIT;
                END IF;
        END;

        IF l_err_flg <= 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRCP00,ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRCP00,ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

    END dm_saleplan_camp_transform;

    PROCEDURE dm_history_new_zmrap00_v1 (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        v_errormsg      VARCHAR2(2000);
        l_cnt_chk       NUMBER(2);
        v_zledest       NUMBER(1);
        v_inpcount      NUMBER := 0;
        v_inpcountf     NUMBER := 0;
        v_count         NUMBER := 0;
        v_igcode        CHAR(5);
        v_lhcqcd        VARCHAR(4);
        v_lhcucd        VARCHAR2(11);
        v_cnt           NUMBER(7) := 0;
        vard            VARCHAR2(13);
        temp_no         NUMBER;
        stg_endtime     TIMESTAMP;
        CURSOR cur_data IS
        SELECT
            zmrap00.apcucd,
            substr(zmrap00.apcucd, 1, 8) AS apcucd_appno,
            substr(zmrap00.apcucd, - 3) AS apcucd_seq,
            zmrap00.apa2dt,
            TRIM(substr((TRIM(apcbig)), 1,(
                CASE
                    WHEN instr(TRIM(apcbig), '?@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '?@')
                END
            ) - 1)) lname,
            TRIM(substr((TRIM(apcbig)),(
                CASE
                    WHEN instr(TRIM(apcbig), '?@') = 0 THEN
                        instr(TRIM(apcbig), ' ')
                    ELSE
                        instr(TRIM(apcbig), '?@')
                END
            ) + 1)) gname,
            TRIM(substr((TRIM(apb5tx)), 1, instr((TRIM(apb5tx)), ' ') - 1)) klname,
            TRIM(substr((TRIM(apb5tx)), instr((TRIM(apb5tx)), ' ') + 1)) glname,
            zmrap00.apc9cd,
            zmrap00.apb7ig,
            zmrap00.apb8ig,
            zmrap00.apb9ig,
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL --and KANA1 is not null  THEN KANA1
                     THEN
                        ' '
                    WHEN zmrap00.apb1tx = ' '--and KANA1 is not null  THEN KANA1
                     THEN
                        ' '
                    ELSE
                        zmrap00.apb0tx
                END
            ) apb0tx, --newly added 11jun18
            (
                CASE
                    WHEN zmrap00.apb1tx IS NULL --and KANA2 is not null THEN KANA2
                     THEN
                        ' '
                    WHEN zmrap00.apb1tx = ' ' --and KANA2 is not null  THEN KANA2
                     THEN
                        ' '
                    ELSE
                        zmrap00.apb1tx
                END
            ) apb1tx,    --newly added 11jun18
            decode(zmrap00.apbast, '1', 'M', '2', 'F') apbast,
            zmrap00.apb4tx,
            zmrap00.apb9tx,
            zmris00.iscpcd,
            zmrap00.apa3dt,
            zmris00.isb1ig,
            zmrap00.apcdig,
            zmris00.isa3st,
            RANK() OVER(
                PARTITION BY substr(zmrap00.apcucd, 1, 8)
                ORDER BY
                    zmrap00.apcucd ASC
            ) AS ranking,
            zmrap00.apdlcd,
            zmrap00.apc6cd
        FROM
            stagedbusr2.zmrap00
            LEFT OUTER JOIN stagedbusr2.zmris00 ON zmrap00.apcucd = zmris00.iscucd
                                                   AND isa4st = 1 --and (substr(zmrap00.APCUCD ,1,8)='1845KL03')
        WHERE
--(substr(rap.APCUCD ,-1)='0') and
            zmrap00.apdlcd IN (
                'N1',
                'NS',
                'N7',
                'N4'
            )
            OR zmrap00.apblst IN (
                1,
                3
            );

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data         cur_data%rowtype;
        TYPE err_type IS
            TABLE OF error_log%rowtype;
        l_errvariable   err_type;
        l_app_old       VARCHAR2(15) := NULL;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM stagedbusr2.titdmgcltrnhis
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        stagedbusr2.tmp_zmrap00 dt
                    WHERE
                        substr(dt.apcucd, 1, 8) = titdmgcltrnhis.refnum
                );

            COMMIT;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS for Delta Load
        END IF;

        v_errormsg := 'MASTER :';
        OPEN cur_data;
        LOOP
            FETCH cur_data INTO st_data;
            EXIT WHEN cur_data%notfound;
            v_input_count := v_input_count + 1;
            l_app_old := st_data.apcucd_appno || st_data.apcucd_seq;
            v_errormsg := 'INSERT :';
            BEGIN
                INSERT INTO stagedbusr2.titdmgcltrnhis (
                    refnum,
                    zseqno,
                    effdate,
                    lsurname,
                    lgivname,
                    zkanagivname,
                    zkanasurname,
                    cltpcode,
                    cltaddr01,
                    cltaddr02,
                    cltaddr03,
                    zkanaddr01,
                    zkanaddr02,
                    addrtype,
                    cltsex,
                    cltphone01,
                    cltphone02,
                    occpcode,
                    cltdob,
                    zoccdsc,
                    zworkplce,
                    zaltrcde01,
                    transhist,
                    zendcde,
                    clntroleflg
                ) VALUES (
                    st_data.apcucd_appno,
                    st_data.apcucd_seq,
                    st_data.apa2dt,
                    st_data.lname,
                    st_data.gname,
                    st_data.glname,
                    st_data.klname,
                    st_data.apc9cd,
                    st_data.apb7ig,
                    st_data.apb8ig,--remove space set -rehearsal
                    st_data.apb9ig,
                    st_data.apb0tx,
                    st_data.apb1tx,--remove space set -rehearsal
                    'R',
                    st_data.apbast,
                    st_data.apb4tx,
                    st_data.apb9tx,
                    st_data.iscpcd,
                    st_data.apa3dt,
                    st_data.isb1ig,
                    st_data.apcdig,
                    st_data.apdlcd,
                    'N',
                    st_data.apc6cd,
                    'OW'
                );

                IF st_data.ranking = 1 THEN
                    INSERT INTO stagedbusr2.persnl_clnt_flg VALUES (
                        st_data.apcucd_appno,
                        '',
                        '',
                        '0',
                        '00',
                        st_data.apcucd_appno || '00',
                        'R',
                        '1',
                        '',
                        ''
                    );

                END IF;

                v_output_count := v_output_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    error_logs('TITDMGCLTRNHIS', st_data.apcucd_appno || st_data.apcucd_seq, v_errormsg);
            END;

            IF l_err_flg = 1 THEN
        --ROLLBACK;
                l_err_flg := 0;
            END IF;
            IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
                COMMIT;
            END IF;
        END LOOP;

        CLOSE cur_data;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := control_log('ZMRAP00,ZMRIS00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := control_log('ZMRAP00', 'TITDMGCLTRNHIS', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

 --   END;
END dm_history_new_zmrap00_v1;

PROCEDURE DM_MSTPOL_TRANSFROM(p_array_size IN PLS_INTEGER DEFAULT 1000,  p_delta IN CHAR DEFAULT 'N')
IS
   STG_STARTTIME TIMESTAMP;
   V_OUTPUT_COUNT NUMBER(10);
   V_INPUT_COUNT NUMBER(10);
   G_ERR_FLG NUMBER(10);
   V_APP TITDMGMASPOL%ROWTYPE;
   L_APPNO VARCHAR2(20);
   IG_STARTTIME TIMESTAMP;
   IG_ENDTIME TIMESTAMP;
   V_ERRORMSG VARCHAR2(2000);
   temp_no NUMBER;
   sql_stmt VARCHAR2(100);
   row_count number(10) default 0;
   tmp_sql_stmt VARCHAR2(100);
   tmp_row_count number(10) default 0;


CURSOR CUR_TEMPT IS SELECT
  MSTPOLDB.ZCCDE
 ,MSTPOLDB.ZCONSGNM
 ,MSTPOLDB.ZBLADCD
 ,TITDMGMASPOL.ZENDCDE
 ,TITDMGMASPOL.CNTTYPE
FROM
  MSTPOLDB,
  TITDMGMASPOL
WHERE
    TRIM(MSTPOLDB.ENDCD) = TRIM(TITDMGMASPOL.ZENDCDE)
AND TRIM(MSTPOLDB.PRODCD) = TRIM(TITDMGMASPOL.CNTTYPE);

TYPE IG_ARRAY IS TABLE OF CUR_TEMPT%ROWTYPE;
ST_DATA IG_ARRAY;
RECORDS_AFFECTED NUMBER;

CURSOR CUR_TEMPT2 IS
SELECT
   A.CLNTNUM
  ,B.CHDRNUM
FROM
  MSTPOLGRP A,
  TITDMGMASPOL B
WHERE
    TRIM(A.GRUPNUM) =
    CASE WHEN LENGTH(TRIM(B.CHDRNUM)) = 11 THEN SUBSTR(TRIM(B.CHDRNUM),4,8)
         ELSE TRIM(B.CHDRNUM )
    END;

TYPE IG_ARRAY2 IS TABLE OF CUR_TEMPT2%ROWTYPE;
ST_DATA2 IG_ARRAY2;


BEGIN
STG_STARTTIME := SYSTIMESTAMP;
V_ERRORMSG:='UPDATE Table from MSTPOLDB:';
V_OUTPUT_COUNT := 0;
V_INPUT_COUNT  := 0;
G_ERR_FLG :=0;
RECORDS_AFFECTED :=0 ;

OPEN CUR_TEMPT;
LOOP
  FETCH CUR_TEMPT BULK COLLECT INTO ST_DATA LIMIT p_array_size;
  EXIT WHEN ST_DATA.COUNT = 0;
  V_INPUT_COUNT := V_INPUT_COUNT + 1 ;
  V_ERRORMSG:='Update Table TITDMGMASPOL using MSTPOLDB:';

   FOR i IN 1..ST_DATA.COUNT LOOP
    UPDATE STAGEDBUSR2.TITDMGMASPOL
    SET
        ZCCDE= TRIM(ST_DATA(i).ZCCDE)
       ,ZCONSGNM = TRIM(ST_DATA(i).ZCONSGNM)
       ,ZBLADCD= TRIM(ST_DATA(i).ZBLADCD)
    WHERE
        TRIM(ZENDCDE)= TRIM(ST_DATA(i).ZENDCDE)
    AND TRIM(CNTTYPE) = TRIM(ST_DATA(i).CNTTYPE);
    RECORDS_AFFECTED := SQL%ROWCOUNT;
   END LOOP;
END LOOP;
 CLOSE CUR_TEMPT;
 commit;

V_OUTPUT_COUNT := RECORDS_AFFECTED;

STG_STARTTIME := SYSTIMESTAMP;
V_ERRORMSG:='UPDATE Table From MSTPOLGRP:';
V_OUTPUT_COUNT := 0;
V_INPUT_COUNT  := 0;
G_ERR_FLG :=0;

OPEN CUR_TEMPT2;
   LOOP
       V_INPUT_COUNT := V_INPUT_COUNT + 1 ;
       RECORDS_AFFECTED :=0 ;
       FETCH CUR_TEMPT2 BULK COLLECT INTO ST_DATA2 LIMIT p_array_size;
       EXIT WHEN ST_DATA2.COUNT = 0;
       V_ERRORMSG:='Update Table from MSTPOLGRP:';
       FOR i IN 1..ST_DATA2.COUNT LOOP
           UPDATE STAGEDBUSR2.TITDMGMASPOL SET
                  CLNTNUM=TRIM(ST_DATA2(i).CLNTNUM)
           WHERE
                  TRIM(ST_DATA2(i).CHDRNUM)=TRIM(CHDRNUM);
        END LOOP;
        RECORDS_AFFECTED := sql%rowcount;
    END LOOP;
    CLOSE CUR_TEMPT2;
    COMMIT;

V_OUTPUT_COUNT := RECORDS_AFFECTED;

V_ERRORMSG:='Update Table TITDMGMASPOL using TITDMGMASPOL:';
UPDATE STAGEDBUSR2.TITDMGMASPOL
SET
     EFFDATE=CCDATE
    ,PNDATE=CCDATE
    ,OCCDATE=CCDATE
    ,INSENDTE=CRDATE
    ,ZPENDDT=CRDATE;
COMMIT;
V_OUTPUT_COUNT := RECORDS_AFFECTED;

    EXCEPTION
            WHEN OTHERS THEN
                v_errormsg := v_errormsg
                              || '-'
                              || sqlerrm;
                error_logs('TITDMGMASPOL', application_no, v_errormsg);
                l_err_flg := 1;

IF L_ERR_FLG = 0 THEN
V_ERRORMSG := 'SUCCESS';
    temp_no := CONTROL_LOG('MSTPOLDB,MSTPOLGRP', 'TITDMGMASPOL', SYSTIMESTAMP,application_no,V_ERRORMSG, 'S', V_INPUT_COUNT, V_OUTPUT_COUNT);
    COMMIT;
ELSE
V_ERRORMSG := 'COMPLETED WITH ERROR';
    temp_no := CONTROL_LOG('MSTPOLDB,MSTPOLGRP', 'TITDMGMASPOL', SYSTIMESTAMP,application_no,V_ERRORMSG, 'F', V_INPUT_COUNT, V_OUTPUT_COUNT);
    ROLLBACK;
END IF;

END DM_MSTPOL_TRANSFROM;

END dm_data_transform;

/
