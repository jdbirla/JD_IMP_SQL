create or replace PACKAGE   DM_data_trans_billref AS

  PROCEDURE DM_Refundhdr_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Refunddets_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');

END DM_data_trans_billref;

/


create or replace PACKAGE BODY   DM_data_trans_billref IS
-- Procedure for DM DM_Refundhdr_transform <STARTS> Here
    v_cnt            NUMBER := 0;
    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    
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
        dm_data_trans_gen.stg_starttime := systimestamp;
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
                        DM_data_trans_gen.error_logs('TITDMGREF1', application_no, v_errormsg);
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
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,DMPR', 'TITDMGREF1', systimestamp, application_no, v_errormsg,
            'F', v_input_count, v_output_count);

            COMMIT;
    END dm_refundhdr_transform;
    
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
        dm_data_trans_gen.stg_starttime := systimestamp;
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
                            DM_data_trans_gen.error_logs('TITDMGREF2', refdet_rec.apcucd, substr(v_errormsg, 1, 200));
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
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := DM_data_trans_gen.control_log('ZMRAP00,ZMRIC00,ZMRAT00', 'TITDMGREF2', systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

            COMMIT;
    END dm_refunddets_transform;

END DM_data_trans_billref;
/
