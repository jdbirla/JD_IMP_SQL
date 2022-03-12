CREATE OR REPLACE PROCEDURE dm_policy_status_code (
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N'
)
    AUTHID current_user
AS 
                /*************************************************************************************************** 
                * Amednment History: DM_POLICY_STATUS_CODE
                * Date    Initials   Tag   Decription 
                * -----   --------   ---   --------------------------------------------------------------------------- 
                * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
                * JAN07    MKS       PC1   PA_ITR3 Policy Status Code Initial Code 
                * OCT01    JDB       PC2   POlicy STATUS will be CA if policy cancel from inception
                *****************************************************************************************************/

    CURSOR cur_data IS
    SELECT
        p.apcucd,
        substr(p.apcucd, 1, 8)           chdrnum,
        p.apa2dt                         effdate,
        g.ccdate,
        p.apbedt                         crdate,
        p.apc6cd                         zendcde,
        c.rptfpst                        AS plnclass,
        CASE
            WHEN p.apblst = '2'
                 AND p.apcycd BETWEEN 50 AND 69
                 AND pj.btdate IS NOT NULL
                 AND p.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                p.apa2dt
            ELSE
                99999999
        END                              AS zpoltdate,
        CASE
            WHEN p.apblst = '2' THEN
                    CASE
                        WHEN p.apcycd BETWEEN 50 AND 69
                             AND pj.btdate IS NOT NULL
                             AND p.apa2dt > to_char(btdate + 1, 'YYYYMMDD') THEN
                            99999999
                        WHEN p.apcycd BETWEEN 50 AND 69
                             AND pj.btdate IS NULL
                             AND c.rptfpst = 'F'
                             AND substr(p.apdlcd, 1, 1) = '*' THEN
                            p.apa2dt
                        WHEN p.apcycd BETWEEN 50 AND 69
                             AND pj.btdate IS NULL
                             AND c.rptfpst = 'F'
                             AND substr(p.apdlcd, 1, 1) <> '*' THEN
                            99999999
                        WHEN p.apcycd BETWEEN 50 AND 69
                             AND pj.btdate IS NULL
                             AND c.rptfpst = 'P' THEN
                            p.apa2dt
                        WHEN p.apcycd BETWEEN 50 AND 69
                             AND pj.btdate IS NOT NULL
                             AND p.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                            p.apa2dt
                        ELSE
                            99999999
                    END
            WHEN p.apblst = '5' THEN
                p.apa2dt
            ELSE
                99999999
        END                              AS dtetrm,
        CASE
            WHEN c.rptfpst = 'F' THEN
                    CASE
                        WHEN p.apblst IN ( '1', '3' ) THEN
                            'AP'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69 THEN
                            decode(substr(p.apdlcd, 1, 1), '*', 'RJ', 'AP')
                        WHEN p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            'AP'
                        WHEN p.apblst = '5' THEN
                            'RJ'
                    END
            WHEN c.rptfpst = 'P' THEN
                    CASE
                        WHEN p.apblst IN ( '1', '3' ) THEN
                            'AP'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69 THEN
                            decode(substr(p.apdlcd, 1, 1), '*', 'RJ', 'AP')
                        WHEN p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            'AP'
                        WHEN p.apblst = '5' THEN
                            'RJ'
                    END
        END                              AS ztrxstat,
        CASE
            WHEN c.rptfpst = 'F' THEN
                    CASE
                        WHEN p.apblst = '1' THEN
                            'IF'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69 THEN
                            decode(substr(p.apdlcd, 1, 1), '*', 'CA', 'IF')
                        WHEN p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            'IF'
                        WHEN p.apblst = '5' THEN
                            'CA'
                    END
            WHEN c.rptfpst = 'P' THEN
                    CASE
                        WHEN p.apblst = '1'
                             AND pj.btdate IS NULL THEN
                            'XN'
                        WHEN p.apblst IN ( '1', '3' )
                             AND pj.btdate IS NOT NULL THEN
                            pj.statcode
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) = '*' THEN
                            'CA'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) <> '*'
                             AND pj.btdate IS NULL THEN
                            'CA'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) <> '*'
                             AND pj.btdate IS NOT NULL
                             AND p.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                            'IF'
                        WHEN p.apblst = '2'
                             AND p.apcycd BETWEEN 50 AND 69
                             AND substr(p.apdlcd, 1, 1) <> '*'
                             AND pj.btdate IS NOT NULL
                             AND p.apa2dt <= to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                            'CA'
                        WHEN p.apblst = '2'
                             AND p.apcycd NOT BETWEEN 50 AND 69 THEN
                            nvl2(pj.btdate, pj.statcode, 'XN')
                        WHEN p.apblst = '5' THEN
                            'CA'
                    END
        END                              statcode,
        CASE
            WHEN c.rptfpst = 'F' THEN
                to_number(to_char(to_date(p.apbedt, 'yyyymmdd') - 1, 'yyyymmdd'))
            WHEN c.rptfpst = 'P' THEN
                to_number(to_char(pj.ptdate, 'YYYYMMDD'))
            ELSE
                99999999
        END                              AS ptdate,
        CASE
            WHEN c.rptfpst = 'F' THEN
                to_number(to_char(to_date(p.apbedt, 'yyyymmdd') - 1, 'yyyymmdd'))
            WHEN c.rptfpst = 'P' THEN
                to_number(to_char(pj.btdate, 'YYYYMMDD'))
            ELSE
                99999999
        END                              AS btdate,
        nvl(pj.zpgpfrdt, 99999999)       AS zpgpfrdt,
        nvl(pj.zpgptodt, 99999999)       AS zpgptodt,
        pj.endsercd,
        decode(p.apflst, '1', 'Y', NULL) AS zpdatatxflg,
        p.occdate --PC2
    FROM
        (
            SELECT
                a.*,
                concat(substr(a.apcucd, 1, 8), MAX(substr(a.apcucd, - 3))
                                               OVER(PARTITION BY substr(a.apcucd, 1, 8)))  max_apcucd,
                concat(substr(a.apcucd, 1, 10), MIN(substr(a.apcucd, - 1))
                                                OVER(PARTITION BY substr(a.apcucd, 1, 10))) minperiod
            FROM
                zmrap00 a
        )                  p
        LEFT JOIN zmrrpt00           c ON p.apc7cd = c.rptbtcd
        LEFT JOIN btdate_ptdate_list pj ON substr(p.apcucd, 1, 8) = pj.chdrnum
        LEFT JOIN (
            SELECT
                a.apcucd AS pjapp,
                a.apa2dt AS ccdate
            FROM
                zmrap00 a
        )                  g ON g.pjapp = p.minperiod
    WHERE
        p.apcucd = max_apcucd
    ORDER BY
        p.apcucd;

    TYPE cur_data_type IS
        TABLE OF cur_data%rowtype;
    cur_polstat    cur_data_type;
    v_input_count  NUMBER;
    v_output_count NUMBER;
    stg_starttime  TIMESTAMP;
    stg_endtime    TIMESTAMP;
    l_err_flg      NUMBER;
    g_err_flg      NUMBER;
    v_errormsg     VARCHAR2(1000);
    application_no VARCHAR2(11);
    temp_no        NUMBER;
    v_trmdate      NUMBER(8, 0);
    c_maxdate      NUMBER(8, 0) := 99999999;
    v_statcode     VARCHAR2(2);
    v_busdate      NUMBER(8);
    v_zpoltdate    NUMBER(8);
    v_dtetrm       NUMBER(8);
    v_planclass    VARCHAR(2);
    v_casename     VARCHAR(100);
BEGIN
    l_err_flg := 0;
    g_err_flg := 0;
    dm_data_trans_gen.stg_starttime := systimestamp;
    v_input_count := 0;
    v_output_count := 0;
    v_errormsg := ' ';
    application_no := '0';
    SELECT
        busdate
    INTO v_busdate
    FROM
        stagedbusr.busdpf
    WHERE
        TRIM(company) = '1';

    IF p_delta = 'Y' THEN
        OPEN cur_data;
        LOOP
            FETCH cur_data
            BULK COLLECT INTO cur_polstat LIMIT p_array_size;
            FORALL d_indx IN 1..cur_polstat.count
                DELETE FROM policy_statcode
                WHERE
                    EXISTS (
                        SELECT
                            'X'
                        FROM
                            policy_statcode dt
                        WHERE
                            dt.apcucd = cur_polstat(d_indx).apcucd
                    );

            EXIT WHEN cur_data%notfound;
        END LOOP;

        CLOSE cur_data;
        COMMIT;
    END IF;

    OPEN cur_data;
    LOOP
        FETCH cur_data
        BULK COLLECT INTO cur_polstat LIMIT p_array_size;
        v_input_count := v_input_count + cur_polstat.count;
        FOR cur_indx IN 1..cur_polstat.count LOOP
            v_errormsg := 'POLICY_STATUS_CODE Insert: ';
            application_no := cur_polstat(cur_indx).apcucd;
            v_statcode := cur_polstat(cur_indx).statcode;
            v_zpoltdate := cur_polstat(cur_indx).zpoltdate;
            v_dtetrm := cur_polstat(cur_indx).dtetrm;
            
                        v_casename := 'AS IT IS FROM CURSOR';

            IF trim(cur_polstat(cur_indx).ztrxstat) <> 'RJ' THEN
                v_trmdate := c_maxdate;
                IF
                    ( trim(cur_polstat(cur_indx).zpoltdate) <> c_maxdate )
                    AND ( TRIM(cur_polstat(cur_indx).zpoltdate) IS NOT NULL )
                THEN
                    v_trmdate := cur_polstat(cur_indx).zpoltdate;
                END IF;

                IF
                    ( trim(cur_polstat(cur_indx).dtetrm) <> c_maxdate )
                    AND ( TRIM(cur_polstat(cur_indx).dtetrm) IS NOT NULL )
                THEN
                    v_trmdate := cur_polstat(cur_indx).dtetrm;
                END IF;

                IF
                    ( v_trmdate <> c_maxdate )
                    AND ( trim(cur_polstat(cur_indx).zpdatatxflg) = 'Y' )
                THEN
                    IF ( v_trmdate >= v_busdate ) THEN
                        v_statcode := 'IF';
                        v_zpoltdate := v_trmdate;
                        v_dtetrm := c_maxdate;
                        v_casename := 'IF : ZPDATATXFLG=Y and v_trmdate >= v_BUSDATE';
                    ELSE
                        v_statcode := 'CA';
                        v_zpoltdate := c_maxdate;
                        v_dtetrm := v_trmdate;
                        v_casename := 'CA: ZPDATATXFLG=Y and v_trmdate < v_BUSDATE';
                    END IF;
                END IF;

                IF
                    ( v_trmdate <> c_maxdate )
                    AND ( ( trim(cur_polstat(cur_indx).zpdatatxflg) <> 'Y' ) OR ( TRIM(cur_polstat(cur_indx).zpdatatxflg) IS NULL ) )
                THEN
                    v_statcode := 'IF';
                    v_zpoltdate := v_trmdate;
                    v_dtetrm := c_maxdate;
                    v_casename := 'IF: ZPDATATXFLG<>Y OR ZPDATATXFLG IS NULL ';
                END IF;

                IF
                    ( v_trmdate <> c_maxdate )
                    AND ( TRIM(cur_polstat(cur_indx).zpdatatxflg) IS NULL )
                THEN
                    IF
                        ( v_trmdate = trim(cur_polstat(cur_indx).ccdate) )
                        AND ( v_trmdate < v_busdate )
                    THEN
                        v_statcode := 'CA';
                        v_zpoltdate := c_maxdate;
                        v_dtetrm := v_trmdate;
                        v_casename := 'CA: ZPDATATXFLG IS NULL AND v_trmdate = CCDATE and  v_trmdate <= v_BUSDATE';

                --dbms_output.put_line('Policy: ' || cur_polstat(cur_indx).APCUCD);
                    END IF;
                END IF;
----------------PC2:START------
                IF ( v_trmdate <> c_maxdate ) THEN
                    IF ( v_trmdate = trim(cur_polstat(cur_indx).occdate) ) THEN
                        v_statcode := 'CA';
                        v_zpoltdate := c_maxdate;
                        v_dtetrm := v_trmdate;
                        v_casename := 'CA: ZPDATATXFLG IS NULL AND v_trmdate = OCCDATE';

                --dbms_output.put_line('Policy: ' || cur_polstat(cur_indx).APCUCD);
                    END IF;
                END IF;
----------------PC2:END------

                IF trim(cur_polstat(cur_indx).plnclass) = 'F' THEN
                    IF cur_polstat(cur_indx).crdate < v_busdate THEN
                        v_statcode := 'LA';
                        v_casename := 'LA: PLNCLASS=F IS NULL AND CRDATE < v_BUSDATE';
                    END IF;
                END IF;

            END IF;

            IF trim(cur_polstat(cur_indx).ztrxstat) = 'RJ' THEN
                v_casename := 'RJ CASE';
            END IF;


      /*
      IF TRIM(cur_polstat(cur_indx).PLNCLASS) is null THEN
        v_planclass := null;
      ELSE
        v_planclass := TRIM(cur_polstat(cur_indx).PLNCLASS) || 'P';
      END IF; 
      */
            BEGIN
                INSERT INTO policy_statcode (
                    apcucd,
                    chdrnum,
                    effdate,
                    crdate,
                    zendcde,
                    plnclass,
                    zpoltdate,
                    dtetrm,
                    ztrxstat,
                    zpdatatxflg,
                    statcode,
                    btdate,
                    ptdate,
                    zpgpfrdt,
                    zpgptodt,
                    endsercd,
                    casename
                ) VALUES (
                    cur_polstat(cur_indx).apcucd,
                    cur_polstat(cur_indx).chdrnum,
                    cur_polstat(cur_indx).effdate,
                    cur_polstat(cur_indx).crdate,
                    cur_polstat(cur_indx).zendcde,
                    TRIM(cur_polstat(cur_indx).plnclass),
                    v_zpoltdate,
                    v_dtetrm,
                    cur_polstat(cur_indx).ztrxstat,
                    cur_polstat(cur_indx).zpdatatxflg,
                    v_statcode,
                    nvl(cur_polstat(cur_indx).btdate, 99999999),
                    nvl(cur_polstat(cur_indx).ptdate, 99999999),
                    cur_polstat(cur_indx).zpgpfrdt,
                    cur_polstat(cur_indx).zpgptodt,
                    cur_polstat(cur_indx).endsercd,
                    v_casename
                );

                v_output_count := v_output_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := v_errormsg
                                  || '-'
                                  || sqlerrm;
                    dm_data_trans_gen.error_logs('POLICY_STATUS_CODE', application_no, v_errormsg);
                    g_err_flg := g_err_flg + 1;
            END;

        END LOOP;

        COMMIT;
        EXIT WHEN cur_data%notfound;
    END LOOP;

    CLOSE cur_data;
    COMMIT;
    IF g_err_flg = 0 THEN
        v_errormsg := 'SUCCESS';
        temp_no := dm_data_trans_gen.control_log('ZMRAP00, ZMRRPT00, BTDATE_PTDATE_LIST', 'POLICY_STATCODE', systimestamp, application_no,
        v_errormsg,
                                                'S', v_input_count, v_output_count);

    ELSE
        v_errormsg := 'COMPLETED WITH ERROR';
        temp_no := dm_data_trans_gen.control_log('ZMRAP00, ZMRRPT00, BTDATE_PTDATE_LIST', 'POLICY_STATCODE', systimestamp, application_no,
        v_errormsg,
                                                'F', v_input_count, v_output_count);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_errormsg := v_errormsg
                      || '-'
                      || sqlerrm;
        dm_data_trans_gen.error_logs('POLICY_STATUS_CODE', application_no, v_errormsg);
        temp_no := dm_data_trans_gen.control_log('ZMRAP00, ZMRRPT00, BTDATE_PTDATE_LIST', 'POLICY_STATCODE', systimestamp, application_no,
        v_errormsg,
                                                'F', v_input_count, v_output_count);

END dm_policy_status_code;