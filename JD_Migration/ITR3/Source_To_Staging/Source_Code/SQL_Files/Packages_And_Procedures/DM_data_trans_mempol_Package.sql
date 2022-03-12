create or replace PACKAGE   DM_data_trans_mempol AS

/* **************************************************************************************************
    Amendment History: DM_data_trans_polhis
    Date    Initials   Tag   			Description
    -----   --------   ---   		-----------------------------------------------------------------
   1/4/2021  Prabu	   MIP1   ITR3: ZJNPG_9214 Code fix to handle the Cif, EndorserSpecCode1 , EndorserSpecCode2 upon renewals & back-dated alteration
  *****************************************************************************************************/


  PROCEDURE DM_Mempol_grp_pol(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_Mempol_oldpol(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE DM_MEMPOL_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  
END DM_data_trans_mempol;
/
create or replace PACKAGE BODY  DM_data_trans_mempol IS

    v_cnt            NUMBER := 0;
    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;

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

        TYPE grp_free_type IS TABLE OF grp_pol_free%rowtype;
        grp_pol_free_rec   grp_free_type;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
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
                ( SELECT p.*,
                         MAX(p.period_no) OVER( PARTITION BY p.apcucd) as TOTAL_PERIOD_COUNT  FROM (                    
                    SELECT
                      a.apcucd app_no,
                      substr(a.apcucd,1,10) period_apcucd,
                      substr(a.apcucd,1,8) apcucd,
                      concat(SUBSTR(a.apcucd,1,10), MIN(SUBSTR(a.apcucd, - 1)) OVER( PARTITION BY SUBSTR(a.apcucd,1,10) )) minperiod,
                      concat(SUBSTR(a.apcucd,1,10), MAX(SUBSTR(a.apcucd, - 1)) OVER( PARTITION BY SUBSTR(a.apcucd,1,10) )) maxperiod,
                      concat(SUBSTR(a.apcucd,1,8), MIN(SUBSTR(a.apcucd, - 3)) OVER( PARTITION BY SUBSTR(a.apcucd,1,8) )) minapcucd,
                      concat(SUBSTR(a.apcucd,1,8), MAX(SUBSTR(a.apcucd, - 3)) OVER( PARTITION BY SUBSTR(a.apcucd,1,8) )) maxapcucd,
                      DENSE_RANK() OVER( partition by substr(a.apcucd,1,8) order by substr(a.apcucd,1,10)) period_no
                    FROM zmrap00 a ) p
                  );

            COMMIT;
        END;

        v_errormsg := 'Master cursor_grp_pol';
   ---PROCESS TO BEGIN UPDATING OF THE GROUP POLICY FROM PJ TO THE ZMRAP00
        OPEN grp_pol_free;
        LOOP
            FETCH grp_pol_free BULK COLLECT INTO grp_pol_free_rec LIMIT p_array_size;
            FOR f_indx IN 1..grp_pol_free_rec.COUNT LOOP              
              BEGIN
                  UPDATE zmrap00
                  SET
                      apcwcd = grp_pol_free_rec(f_indx).grp_policy_no_pj
                  WHERE
                      apc6cd = grp_pol_free_rec(f_indx).endorsercode
                      AND apc1cd = grp_pol_free_rec(f_indx).campaign;

                  v_output_count := v_output_count + 1;
                  l_app_old := grp_pol_free_rec(f_indx).grp_policy_no_pj;
              EXCEPTION
                  WHEN OTHERS THEN
                      g_err_flg := g_err_flg + 1;
                      v_errormsg := v_errormsg
                                    || '-'
                                    || sqlerrm;
                      DM_data_trans_gen.error_logs('TITDMGMBRINDP1_GRPPOL', l_app_old, v_errormsg);
              END;
            END LOOP;
            COMMIT;
            EXIT WHEN grp_pol_free%notfound;
        END LOOP;
        COMMIT;
        CLOSE grp_pol_free;

        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := DM_data_trans_gen.control_log(v_source, 'GRPPOL_ZMRAP00', systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);
        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log(v_source, 'GRPPOL_ZMRAP00', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            DM_data_trans_gen.error_logs('TITDMGMBRINDP1_GRPPOL', l_app_old, substr(v_errormsg, 1, 200));
            l_err_flg := 1;
            temp_no := DM_data_trans_gen.control_log(v_source, 'GRPPOL_ZMRAP00', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);
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

        TYPE pol_app_type IS TABLE OF pol_app%rowtype;
        pol_app_rec      pol_app_type;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
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
            FETCH pol_app BULK COLLECT INTO pol_app_rec LIMIT p_array_size;           
            v_input_count := v_input_count + pol_app_rec.COUNT;
            FOR a_indx IN 1..pol_app_rec.COUNT LOOP      
                BEGIN
                    INSERT INTO mempol VALUES (
                        pol_app_rec(a_indx).mp,
                        pol_app_rec(a_indx).ip,
                        pol_app_rec(a_indx).mp_apevt,
                        pol_app_rec(a_indx).ip_apevt,
                        pol_app_rec(a_indx).oldpolnum,
                        pol_app_rec(a_indx).refno,
                        pol_app_rec(a_indx).zconvpol
                    );

                    v_output_count := v_output_count + 1;
                    l_app_old := pol_app_rec(a_indx).mp;
                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        g_err_flg := 1;
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        DM_data_trans_gen.error_logs('TITDMGMBRINDP1_OLDPOL', l_app_old, v_errormsg);
                END;
            END LOOP
            COMMIT;
            EXIT WHEN pol_app%notfound;
        END LOOP;
        CLOSE pol_app;
        COMMIT;

        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := DM_data_trans_gen.control_log(v_source, 'MEMPOL', systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log(v_source, 'MEMPOL', systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            DM_data_trans_gen.error_logs('oldpol', l_app_old, substr(v_errormsg, 1, 200));

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
    SELECT p1.*,
          g.effdate,
          months_between(to_date(crdate, 'yyyymmdd'), to_date(g.effdate, 'yyyymmdd')) AS zpolperd,
          mx.period_no,
          mx.total_period_count,
          decode(p1.refnum, mx.maxapcucd, 'Y', 'N') AS last_trxs
    FROM
        (
          SELECT
                refnum,
                gpoltype,
                zendcde,
                zcmpcode,
                mpolnum,
                --effdate,
                --months_between(to_date(crdate, 'yyyymmdd'), to_date(effdate, 'yyyymmdd')) AS zpolperd,
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
                        WHEN substr(refnum, -1) = '0' --- Changed for MIP1
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN apdlcd = 'ID'
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN nvl(apdlcd,'x') <> 'ID'               THEN --- Changed for MIP1
                            LAG(endorserspec1 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY zeffdt, 
                                    refnum
                            )
                    END, '                    ') AS zenspcd01,
                nvl(
                    CASE
                        WHEN endorserspec_tab2 = 'APC0CD' THEN
                            endorserspec2
                        WHEN endorserspec_tab2 = 'APB8TX' THEN
                            endorserspec2
                        WHEN substr(refnum, -1) = '0' --- Changed for MIP1
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN apdlcd = 'ID'
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN nvl(apdlcd,'x') <> 'ID'               THEN --- Changed for MIP1
                            LAG(endorserspec2 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY  zeffdt, 
                                    refnum
                            )
                    END, '                    ') AS zenspcd02,
                nvl(
                    CASE
                        WHEN cif_tab = 'APC0CD' THEN
                            cif
                        WHEN cif_tab = 'APB8TX' THEN
                            cif
                        WHEN substr(refnum, -1) = '0' --- Changed for MIP1
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN apdlcd = 'ID'
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN nvl(apdlcd,'x') <> 'ID'     THEN --- Changed for MIP1
                            LAG(cif IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(refnum, 1, 8)
                                ORDER BY zeffdt, 
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
                null AS tranno,
                clientno,
                zrwnlage,
                znbmnage,
                termage,
                zblnkpol,
                plnclass,
                zlaptrx,
                zrnwcnt
            FROM
                (
                    SELECT
                        a.apcucd        AS refnum,
                        nvl(a.apc7cd, '   ') AS gpoltype,
                        nvl(a.apc6cd, '            ') AS zendcde,
                        nvl(RPAD(a.apc1cd,6,0), '            ') AS zcmpcode, 
                        CASE
                            WHEN pst.plnclass = 'P'
                                 AND a.apevst = '1' THEN
                                ' '
                            WHEN pst.plnclass = 'P'
                                 AND a.apevst <> '1' THEN
                                substr(a.apcwcd, - 8)
                            WHEN pst.plnclass = 'F' THEN
                                a.apcwcd
                        END AS mpolnum,
                        --g.orgcommdate   AS effdate,
                        a.apcvcdnew        AS docrcvdt,
                        a.apcvcdnew        AS hpropdte,
                        CASE
                            WHEN pst.plnclass = 'F' THEN
                                CASE
                                    WHEN a.apblst in ('1','3') THEN
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
                            WHEN pst.plnclass = 'P' THEN
                                CASE
                                    WHEN a.apblst in ('1','3') THEN
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
                        /*CASE
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
                        END AS dtetrm,*/ -- get from policy_statcode
                        pst.dtetrm,
                        a.apbedt        AS crdate,
                        CASE
                            WHEN a.apevst = '1' THEN
                                'I'
                            WHEN a.apevst = '2' THEN
                                'M'
                        END AS cnttypind,
                        /*CASE
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
                        END AS btdate,*/
                        pst.btdate, -- get form policy_statcode table
                        pst.ptdate, -- get form policy_statcode table
                        /*CASE
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
                        END statcode,*/ --get form policy_statcode table
                        pst.statcode, 
                        decode(apdlcd, 'C6', mp.zconvpol, NULL) AS zconvindpol,
                        /*CASE
                            WHEN a.apblst = '2'
                                 AND a.apcycd BETWEEN 50 AND 69
                                 AND pj.btdate IS NOT NULL
                                 AND a.apa2dt > to_char(pj.btdate + 1, 'YYYYMMDD') THEN
                                apa2dt
                            ELSE
                                99999999
                        END zpoltdate, */ --get form policy_statcode table
                        pst.zpoltdate,
                        --nvl(pj.zpgpfrdt, 99999999) AS zpgpfrdt, get from policy_statcode table
                        --nvl(pj.zpgptodt, 99999999) AS zpgptodt, get from policy_statcode table
                        nvl(pst.zpgpfrdt, 99999999) AS zpgpfrdt, 
                        nvl(pst.zpgptodt, 99999999) AS zpgptodt,
                        --substr(decode(c.rptfpst, 'F', 1, a.aplacd * 12), 1, 3) sinstno, get plnclass from policy_statcode
                        substr(decode(pst.plnclass, 'F', 1, a.aplacd * 12), 1, 3) sinstno,
                        mp.refno        AS trefnum,
                        --pj.endsercd, get from policy_statcode table
                        pst.endsercd, 
                        decode(a.apflst, '1', 'Y', NULL) AS zpdatatxflg,
                        --g.orgcommdate   AS occdate, ITR3 Direct from Source
                        a.occdate,
                        substr(x.insur_role, 2) AS zinsrole,
                        cm.stageclntno   AS clientno,
                        decode(pst.plnclass, 'F', 100, r.ulab0nb)      AS zrwnlage,
                        --minnbage(a.apc6cd, a.apc7cd, c.rptfpst, i.icdmcd) AS znbmnage, get plnclass from policy_statcode
                        --minnbage(a.apc6cd, a.apc7cd, pst.plnclass, i.icdmcd) AS znbmnage,
                --Defect ZJNPG-8946: Start    
                        CASE 
                          WHEN pst.plnclass = 'F' THEN
                            0
                          WHEN  pst.plnclass = 'P' THEN
                            CASE
                              WHEN a.apc6cd in ('BSCYCLE', 'BSCYCLE_PC') THEN
                                0
                              WHEN a.apc6cd = 'AMEX_CR' THEN
                                22
                              WHEN TRIM(i.icdmcd) = 'SPA' THEN
                                65
                              WHEN mna.zendcde IS NOT NULL THEN
                                22
                              ELSE
                                20
                            END
                        END AS znbmnage,                       
                --Defect ZJNPG-8946: End
                        decode(pst.plnclass, 'F', 100, r.ulanwlt)       AS termage,
                        decode(a.apc7cd, 'BDT', 'Y', 'BBT', 'Y', 'N') zblnkpol,
                        --c.rptfpst       AS plnclass, get from policy_statcode
                        pst.plnclass, 
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
                        END AS cif,
                      decode(pst.plnclass, 'F', 'Y', 'N')  AS zlaptrx,
                      CASE
                        WHEN pst.plnclass = 'P' THEN
                          substr(a.apcucd,9,2) 
                        WHEN pst.plnclass = 'F' THEN
                          '0'
                      END AS zrnwcnt,
					  apa2dt zeffdt    --- Changed for MIP1
                    FROM
                        zmrap00 a
                        INNER JOIN persnl_clnt_flg         x ON a.apcucd = x.apcucd
                                                        AND x.isa4st IS NULL
                        --LEFT JOIN zmrrpt00                c ON a.apc7cd = c.rptbtcd
                        LEFT OUTER JOIN titdmgclntmap    cm ON cm.refnum = x.stg_clntnum 
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
                        --LEFT JOIN btdate_ptdate_list      pj ON substr(a.apcucd, 1, 8) = pj.chdrnum
                        LEFT JOIN policy_statcode  pst ON substr(a.apcucd, 1, 8) = pst.chdrnum
                        LEFT JOIN zmrula00           r ON a.apc6cd = r.ulac6cd
                                                            AND a.apc7cd = r.ulac7cd
                        LEFT JOIN (
                          SELECT DISTINCT
                                    iccucd,
                                    icdmcd
                          FROM
                            zmric00
                          WHERE
                            substr(iccicd,-2) = '01'
                            AND icdmcd = 'SPA'
                                --AND ROWNUM = 1
                        ) i ON a.apcucd = i.iccucd
                        LEFT OUTER JOIN minage_table mna ON mna.zendcde = TRIM(a.apc6cd)
                                                              AND mna.prod_code = TRIM(a.apc7cd)
                        LEFT JOIN mempol_view         mp ON a.apcucd = mp.mp
                )                
            UNION ALL
            SELECT
                a.apcucd         AS refnum,
                NULL AS gpoltype,
                nvl(a.apc6cd, '            ') AS zendcde, --ZJNPG-8240
                NULL AS zcmpcode,
                NULL AS mpolnum,
                --g.orgcommdate    AS effdate,
                --NULL AS zpolperd,
                'N' AS zmargnflg,
                'N' AS zdfcncy,
                a.apcvcdnew         AS docrcvdt,
                a.apcvcdnew         AS hpropdte,
                CASE
                    WHEN pst.plnclass = 'F' THEN
                        CASE
                            WHEN a.apblst in ('1','3') THEN
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
                    WHEN pst.plnclass = 'P' THEN
                        CASE
                            WHEN a.apblst in ('1','3') THEN
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
                /*CASE
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
                END AS dtetrm,*/ -- get from policy_statcode
                pst.dtetrm,
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
                a.occdate AS occdate,
                '1' client_category,
                substr(b.iscicd, - 2) AS mbrno,
                substr(x.insur_role, 2) AS zinsrole,
                '1' AS tranno,
                cm.stageclntno    AS clientno,
                NULL AS zrwnlage,
                NULL AS znbmnage,
                NULL AS termage,
                NULL AS zblnkpol,
                NULL AS plnclass,
                decode(pst.plnclass, 'F', 'Y', 'N')  AS zlaptrx,
                CASE
                  WHEN pst.plnclass = 'P' THEN
                    substr(a.apcucd,9,2) 
                  WHEN pst.plnclass = 'F' THEN
                    '0'
                END AS zrnwcnt
            FROM
                zmrap00 a
                INNER JOIN persnl_clnt_flg        x ON a.apcucd = x.apcucd
                                                      AND x.isa4st IS NOT NULL
                INNER JOIN zmris00                b ON b.iscicd = x.iscicd
                --LEFT JOIN zmrrpt00              d ON a.apc7cd = d.rptbtcd
                --LEFT JOIN btdate_ptdate_list   pj ON substr(a.apcucd, 1, 8) = pj.chdrnum
                LEFT OUTER JOIN policy_statcode pst ON substr(a.apcucd, 1, 8) = pst.chdrnum
                LEFT OUTER JOIN titdmgclntmap    cm ON cm.refnum = x.stg_clntnum 
                LEFT JOIN mem_ind_polhist_ssplan_intrmdt sp ON substr(a.apcucd,1,10) = substr(sp.apcucd,1,10)
                                                              AND substr(b.iscicd,-2) = substr(sp.mbrno,-2)
        ) p1
          LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        zmrap00 a left outer join maxpolnum min on a.apcucd = min.app_no
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(p1.refnum, 1, 10) = g.period_apcucd
          LEFT OUTER JOIN maxpolnum mx ON mx.app_no = p1.refnum
        WHERE p1.refnum = mx.maxperiod;

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
        dm_data_trans_gen.stg_starttime := systimestamp;
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
              v_errormsg := 'Insert Target';

              BEGIN
                    INSERT INTO titdmgmbrindp1 (
                        client_category,
                        refnum,
                        mbrno,
                        zinsrole,
                        clientno,
                        occdate,
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
                        zrwnlage,
                        znbmnage,
                        termage,
                        zblnkpol,
                        plnclass,
                        zrnwcnt,
                        zlaptrx,
                        period_no,
                        total_period_count,
                        trannomin,
                        trannonbrn,
                        trannomax,
                        last_trxs
                    ) VALUES (
                        zmrap00_l_appls(l_apindx).client_category,
                        zmrap00_l_appls(l_apindx).refnum,
                        zmrap00_l_appls(l_apindx).mbrno,
                        zmrap00_l_appls(l_apindx).zinsrole,
                        zmrap00_l_appls(l_apindx).clientno,
                        zmrap00_l_appls(l_apindx).occdate,
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
                        zmrap00_l_appls(l_apindx).zrwnlage,
                        zmrap00_l_appls(l_apindx).znbmnage,
                        zmrap00_l_appls(l_apindx).termage,
                        zmrap00_l_appls(l_apindx).zblnkpol,
                        zmrap00_l_appls(l_apindx).plnclass,
                        zmrap00_l_appls(l_apindx).zrnwcnt,
                        zmrap00_l_appls(l_apindx).zlaptrx,
                        zmrap00_l_appls(l_apindx).period_no,
                        zmrap00_l_appls(l_apindx).total_period_count,
                        0,
                        0,
                        0,
                        zmrap00_l_appls(l_apindx).last_trxs
                    );

                    v_output_count := v_output_count + 1;
              EXCEPTION
                WHEN OTHERS THEN
                  g_err_flg := g_err_flg + 1;
                  v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                  DM_data_trans_gen.error_logs('TITDMGMBRINDP1', zmrap00_l_appls(l_apindx).refnum, v_errormsg);
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
            temp_no :=DM_data_trans_gen.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
           DM_data_trans_gen.error_logs('TITDMGMBRINDP1_trans', application_no, v_errormsg);
           temp_no := DM_data_trans_gen.control_log(v_source, 'TITDMGMBRINDP1', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
    END dm_mempol_transform;    

END DM_data_trans_mempol;
/

