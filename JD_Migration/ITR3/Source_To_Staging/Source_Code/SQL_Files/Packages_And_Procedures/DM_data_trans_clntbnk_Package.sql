create or replace PACKAGE  DM_data_trans_clntbnk AS

  PROCEDURE DM_clntbnk_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');


END DM_data_trans_clntbnk;

/

create or replace PACKAGE BODY DM_data_trans_clntbnk as

    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    
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
                RAP.*
            FROM
                zmrap00 RAP
                
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
    dm_data_trans_gen.stg_starttime := systimestamp;
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
--                    dbms_output.put_line(application_no);
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
                            DM_data_trans_gen.error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
                            l_err_flg := 1;
                        END IF;

                    EXCEPTION
                        WHEN OTHERS THEN
                            v_errormsg := v_errormsg
                                          || ' '
                                          || sqlerrm;
                            DM_data_trans_gen.error_logs('TITDMGCLNTBANK', application_no, v_errormsg);
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
              --SELECT * FROM dmpr1
				SELECT PR1.* FROM dmpr1 PR1
				
          )
    src ON ( tgt.refnum = src.refnum
             AND tgt.bankacckey = src.bankacckey
             AND tgt.bnkactyp = src.bnkactyp
             AND tgt.bankcd = src.bankcd
             AND tgt.branchcd = src.branchcd)
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
commit;
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
    
    
    
    Update stagedbusr2.titdmgclntbank clnt set clnt.refnum = clnt.refnum||'00';

    COMMIT;
    
    
    Update titdmgclntbank a set a.refnum = (
    SELECT CLMAP.STAGECLNTNO FROM TITDMGCLNTMAP CLMAP WHERE A.REFNUM=CLMAP.REFNUM
    ) WHERE EXISTS(
    SELECT 1 FROM TITDMGCLNTMAP CLMAP WHERE A.REFNUM=CLMAP.REFNUM );
    COMMIT;

    --Remove duplicate refnum, bankacckey, crdtcard
    DELETE FROM titdmgclntbank WHERE recidxclbk NOT IN ( SELECT MAX(recidxclbk) FROM titdmgclntbank GROUP BY refnum, bankacckey, crdtcard, bankcd, branchcd);
    COMMIT;
    
    IF g_err_flg = 0 THEN
        v_errormsg := 'SUCCESS';
        application_no := NULL;
        temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
        ,
        'S', v_input_count, v_output_count);

    ELSE
        v_errormsg := 'COMPLETED WITH ERROR';
        temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
        ,
        'F', v_input_count, v_output_count);

    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        v_errormsg := v_errormsg
                      || '-'
                      || sqlerrm;
        ROLLBACK;
        temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR1,CARD_ENDORSER_LIST', 'TITDMGCLNTBANK', systimestamp, application_no, v_errormsg
        ,
        'F', v_input_count, v_output_count);

END dm_clntbnk_transform;

end DM_data_trans_clntbnk;

/