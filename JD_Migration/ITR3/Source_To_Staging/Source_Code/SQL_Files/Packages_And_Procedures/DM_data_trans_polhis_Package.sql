create or replace PACKAGE   DM_data_trans_polhis AS
  
/* **************************************************************************************************
    Amendment History: DM_data_trans_polhis
    Date    Initials   Tag   			Description
    -----   --------   ---   		-----------------------------------------------------------------
   1/4/2021  Prabu	   PH1   ITR3: ZJNPG_9214 Code fix to handle the Cif, EndorserSpecCode1 , EndorserSpecCode2 upon renewals & back-dated alteration
  *****************************************************************************************************/

  
  PROCEDURE DM_policytran_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');
  PROCEDURE dm_DPNTNO_INSERT (p_array_size   IN   PLS_INTEGER DEFAULT 1000, p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_cov (p_array_size   IN   PLS_INTEGER DEFAULT 1000,p_delta        IN   CHAR DEFAULT 'N');
  PROCEDURE dm_polhis_apirno(p_array_size   IN   PLS_INTEGER DEFAULT 1000,p_delta        IN   CHAR DEFAULT 'N');
  

END DM_data_trans_polhis;
/
create or replace PACKAGE BODY dm_data_trans_polhis IS

    application_no VARCHAR2(13);
  -- Procedure for DM_policytran_transform <STARTS> Here

    PROCEDURE dm_policytran_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        v_input_count     NUMBER;
        v_output_count    NUMBER;
        stg_starttime     TIMESTAMP;
        stg_endtime       TIMESTAMP;
        l_err_flg         NUMBER := 0;
        g_err_flg         NUMBER := 0;
        v_errormsg        VARCHAR2(2000);
        rows_inserted     NUMBER;
        temp_no           NUMBER;
        l_app_old         VARCHAR2(20);
        c_limit           PLS_INTEGER := p_array_size;
        CURSOR cur_data IS
        WITH data_1 AS (
            SELECT
                apcucd,
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
        --zpayinreq2,
                crdtcard,
                preautno,
                bnkacckey01,
                nvl(
                    CASE
                        WHEN endorserspec_tab1 = 'APC0CD' THEN
                            endorserspec1
                        WHEN endorserspec_tab1 = 'APB8TX' THEN
                            endorserspec1
                        WHEN substr(apcucd, -1) = '0' --- Changed for PH1
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN apdlcd = 'ID'
                             AND endorserspec1 IS NOT NULL THEN
                            endorserspec1
                        WHEN nvl(apdlcd,'x') <> 'ID'               THEN --- Changed for PH1
                            LAG(endorserspec1 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(apcucd, 1, 8)
                                ORDER BY effdate,
                                    apcucd
                            )
                    END, '                    ') AS zenspcd01,
                nvl(
                    CASE
                        WHEN endorserspec_tab2 = 'APC0CD' THEN
                            endorserspec2
                        WHEN endorserspec_tab2 = 'APB8TX' THEN
                            endorserspec2
                        WHEN substr(apcucd, -1) = '0' --- Changed for PH1
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN apdlcd = 'ID'
                             AND endorserspec2 IS NOT NULL THEN
                            endorserspec2
                        WHEN nvl(apdlcd,'x') <> 'ID'               THEN --- Changed for PH1
                            LAG(endorserspec2 IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(apcucd, 1, 8)
                                ORDER BY effdate,
                                    apcucd
                            )
                    END, '                    ') AS zenspcd02,
                nvl(
                    CASE
                        WHEN cif_tab = 'APC0CD' THEN
                            cif
                        WHEN cif_tab = 'APB8TX' THEN
                            cif
                        WHEN substr(apcucd, -1) = '0' --- Changed for PH1
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN apdlcd = 'ID'
                             AND cif IS NOT NULL THEN
                            cif
                        WHEN nvl(apdlcd,'x') <> 'ID'     THEN --- Changed for PH1
                            LAG(cif IGNORE NULLS, 1) OVER(
                                PARTITION BY substr(apcucd, 1, 8)
                                ORDER BY effdate,
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
                b5_bnyrln,
                zsolctflg,
                zplancde,
                zcmpcode,
                zcpnscde,
                zsalechnl,
                trancde
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
                        clnt.stageclntno   AS clientno,
                        p.apcvcd           AS zaltregdat,
                        (
                            SELECT DISTINCT
                                ig_al_code
                            FROM
                                alter_reason_code
                            WHERE
                                p.apdlcd = dm_al_code
                                AND dm_al_code NOT LIKE '*%'
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
                                 AND p.apblst IN (
                                '1',
                                '3'
                            ) THEN
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
                                 AND p.apblst IN (
                                '1',
                                '3'
                            ) THEN
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
                        p.apcvcd           AS apprdte, --ZJNPG-9443: PJ Transfer Date Issue - Use apcvcd instead of apcvcd for Transfer Date Calculation as aggreed with Jdrich.
                        CASE
                            WHEN apflst = '1'
                                 AND length(apandt) = 6 THEN
                                apandt + 20000000
                            WHEN apflst = '1'
                                 AND length(apandt) = 7 THEN
                                apandt + 19000000 --#9145   --#9145 17-jun-18
                            WHEN apflst = '1'
                                 AND length(apandt) = 8 THEN      		--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                                apandt --#9145   --#9145 17-jun-18
							ELSE										--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
								NULL									--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                            /* WHEN apflst <> '1' THEN					--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                                zacmcldt								--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                            WHEN apflst IS NULL THEN					--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                                zacmcldt */								--ZJNPG-9443: PJ Transfer Date to be dirrect mapping if already transfered in DM side.
                        END AS zpdatatxdte,
                        NULL AS zpdatatxflg,
                        NULL AS zrefundam, -- This field will be updated in tranno logic

       -- (select avg(gref.zrefundbz) from titdmgref1 gref where gref.chdrnum = substr(p.apcucd,1,8) group by gref.chdrnum) as zrefundam,
       -- to clarify below field in msd with kevin       
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
/*		-- to clarify below field in msd with kevin  there is no zpayinreq2 column in msd
        CASE
          WHEN SUBSTR(p.apdlcd, 1, 2) IN ( 'T4', 'T8', 'TB', 'TD', 'TF', 'TZ' )
          AND p1.zpgptodt             IS NOT NULL --and  DMDATE < P1.ZPGPTODT THEN
          THEN 'Y'                               ---#9194 18jun18 -- DMDATE IS IN PARAMETER
            /* WHEN SUBSTR(P.APDLCD,1,2) in ( 'T4', 'T8', 'TB', 'TD', 'TF' ,'TZ') and P1.ZPGPTODT is not null
            --and  DMDATE > P1.ZPGPTODT then 'N' ---#9194 18jun18
            -- TO CHECK WITH ABHISHEK
          WHEN SUBSTR(p.apdlcd, 1, 2) IN ( 'T4', 'T8', 'TB', 'TD', 'TF', 'TZ' )
          AND p1.zpgptodt             IS NULL
          THEN 'N'---#9194 18jun18
          WHEN SUBSTR(p.apdlcd, 1, 2) NOT IN ( 'T4', 'T8', 'TB', 'TD', 'TF', 'TZ' )
          THEN 'N'--#9194 18jun1
          WHEN SUBSTR(p.apdlcd, 1, 2) IS NULL
          THEN 'N'---#9194 18jun18
        END zpayinreq2, */
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
                                NULL -- changed it from ' ' to null
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
            --concat(p.apdjcd, p.apdkcd)
                                p.apdjcd
                                || '   '
                                || p.apdkcd -- Modified to fix ZJNPG-8213 (added 3 spaces inbetween
                            WHEN endrsr.crdt = 'CreditCard' THEN
                                '9999   999' -- Modified to fix ZJNPG-8213 (added 3 spaces inbetween
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
                                 AND p.apyob3 <> '000000' 
                                 AND p.apyob3 <> '999999' THEN
                                to_char(last_day(to_date(p.apyob3, 'YYYYMM')), 'YYYYMMDD')
                            WHEN p.apyob3 IS NULL
                                 OR p.apyob3 = '000000'  OR p.apyob3 = '999999' THEN
                                '99999999'
                            WHEN endrsr.bnk = 'BankAccount' THEN
                                '99999999'
                            ELSE
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
                        decode(trim(ris.b1_bnyrln), '1', 'MI', '2', 'SP', '3', 'RE', '4', 'OT',  ris.b1_bnyrln) AS b1_bnyrln,
                        decode(trim(ris.b2_bnyrln), '1', 'MI', '2', 'SP', '3', 'RE', '4', 'OT',  ris.b2_bnyrln) AS b2_bnyrln,
                        decode(trim(ris.b3_bnyrln), '1', 'MI', '2', 'SP', '3', 'RE', '4', 'OT',  ris.b3_bnyrln) AS b3_bnyrln,
                        decode(trim(ris.b4_bnyrln), '1', 'MI', '2', 'SP', '3', 'RE', '4', 'OT',  ris.b4_bnyrln) AS b4_bnyrln,
                        decode(trim(ris.b5_bnyrln), '1', 'MI', '2', 'SP', '3', 'RE', '4', 'OT',  ris.b5_bnyrln) AS b5_bnyrln,
                        cif_tab,
        /* , CASE WHEN p.APDLCD IN ('C6') AND SUBSTR(p.APYOB6,5,8) = SUBSTR(p.APCUCD,1,8) THEN SUBSTR(p.APCUCD,1,8)
        ELSE ' '
        END AS ZCONVPOLNO */
        -- Column Removed in MSD2.3
                        CASE
                            WHEN sfl.product_code = p.apc7cd THEN
                                'Y'
                            ELSE
                                'N'
                        END AS zsolctflg,
                        ssp.newzsalplan    AS zplancde,
                        nvl(rpad(p.apc1cd, 6, 0), '            ') AS zcmpcode,
                        p.apl6cd           AS zcpnscde,
                        CASE
                            WHEN p.apyob9 = 0 THEN
                                10
                            WHEN p.apyob9 = 1 THEN
                                20
                            WHEN p.apyob9 = 2 THEN
                                99
                            WHEN p.apyob9 = 3 THEN
                                30
                        END AS zsalechnl,
                        CASE
                            WHEN substr(p.apcucd, - 3) = '000' THEN
                                'T902'
          --WHEN SUBSTR(p.apcucd,-1) = '0'   THEN 'T992'
                            WHEN substr(p.apcucd, - 1) = '0'   THEN
                                'T928'
                            ELSE
                                'T912'
                        END AS trancde
                    FROM
                        zmrap00                          p
                        INNER JOIN persnl_clnt_flg                  flg ON flg.apcucd = p.apcucd
                                                          AND flg.isa4st IS NOT NULL
                        INNER JOIN zmris00                          ris ON ris.iscicd = flg.iscicd
                        LEFT JOIN zmrrpt00                         t ON p.apc7cd = t.rptbtcd
                        LEFT JOIN zmrei00                          e ON p.apcucd = e.eicucd
      /*LEFT OUTER JOIN titdmgmbrindp1 p1 -- As we are not using this in phase 2, we have commented this out.
      ON p1.refnum = ris.iscicd */
                        LEFT OUTER JOIN solicitation_flg_list            sfl ON p.apc7cd = sfl.product_code
                        LEFT OUTER JOIN titdmgclntmap                    clnt ON flg.stg_clntnum = clnt.refnum
                        LEFT OUTER JOIN mem_ind_polhist_ssplan_intrmdt   ssp ON substr(ssp.apcucd, 1, 10) = substr(p.apcucd, 1, 10)
                                                                              AND ssp.mbrno = '000'
                                                                                              || substr(ris.iscicd, - 2)
                        LEFT OUTER JOIN (
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
                effdate
        )
        SELECT
            apcucd,
            chdrnum,
            zseqno,
            effdate,
            client_category,
            mbrno,
            cltreln,
            zinsrole,
            clientno, -- Need to check this column mapping after Nayose table titdmgclntmap is created
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
            b5_bnyrln,
            zsolctflg,
            zplancde,
            zcmpcode,
            zcpnscde,
            zsalechnl,
            trancde
        FROM
            data_1;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data           cur_data%rowtype;
  --del_curr                             cur_data%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF cur_data%rowtype;
        zmrap00_l_appls   zmrap00_cur_t;
        old_apcucd        VARCHAR2(11) := '0';
        var_trancde       VARCHAR2(5) := '0';
        var_old_pol       VARCHAR2(8) := '0';
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For TITDMGPOLTRNH TABLE Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data INTO st_data;
                EXIT WHEN cur_data%notfound;
                DELETE FROM titdmgpoltrnh trn
                WHERE
                    trn.chdrnum = st_data.chdrnum;

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
                l_app_old := zmrap00_l_appls(l_apindx).chdrnum
                             || zmrap00_l_appls(l_apindx).zseqno;
                v_errormsg := 'INSERT TARGET:';
   /* IF SUBSTR(zmrap00_l_appls(l_apindx).apcucd,-1) = 0 THEN
      IF old_apcucd = zmrap00_l_appls(l_apindx).apcucd 
      THEN 
        var_trancde := var_trancde;
      ELSE
        IF SUBSTR(zmrap00_l_appls(l_apindx).apcucd,9,2) = '00' THEN
          var_trancde                                  := 'T902';
          old_apcucd                                   := zmrap00_l_appls(l_apindx).apcucd;
          var_old_pol                                  := SUBSTR(zmrap00_l_appls(l_apindx).apcucd,1,8);
        ELSE
          IF var_old_pol = SUBSTR(zmrap00_l_appls(l_apindx).apcucd,1,8) THEN
            var_trancde := 'T928';
          ELSE
            var_trancde := 'T992';
            old_apcucd  := zmrap00_l_appls(l_apindx).apcucd;
            var_old_pol := SUBSTR(zmrap00_l_appls(l_apindx).apcucd,1,8);
          END IF;
        END IF;
      END IF;
    ELSE
      var_trancde := 'T912';
    END IF;*/
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
                        b5_bnyrln,
                        zsolctflg,
                        zplancde,
                        zcmpcode,
                        zcpnscde,
                        zsalechnl,
                        trancde
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
                        zmrap00_l_appls(l_apindx).b5_bnyrln,
          -- , st_data.ZCONVPOLNO
                        zmrap00_l_appls(l_apindx).zsolctflg,
                        zmrap00_l_appls(l_apindx).zplancde,
                        zmrap00_l_appls(l_apindx).zcmpcode,
                        zmrap00_l_appls(l_apindx).zcpnscde,
                        zmrap00_l_appls(l_apindx).zsalechnl,
                        zmrap00_l_appls(l_apindx).trancde
          --var_trancde
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
    --  DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_trans_gen.error_logs('TITDMGPOLTRNH', zmrap00_l_appls(l_apindx).chdrnum, v_errormsg);
                        g_err_flg := 1;
                END;

            END LOOP;

            EXIT WHEN cur_data%notfound;
  --dbms_output.put_line('rows inserted '|| rows_inserted);
        END LOOP;

        COMMIT;
--rows_inserted := v_input_count;
        CLOSE cur_data;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := dm_data_trans_gen.control_log('zmris00,persnl_clnt_flg,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH'
            , systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_trans_gen.control_log('zmris00,persnl_clnt_flg,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH'
            , systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);

        END IF;
--dbms_output.put_line('Error while insert into TITDMGPOLTRNH ');

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            dm_data_trans_gen.error_logs('TITDMGPOLTRNH', application_no, v_errormsg);
            temp_no := dm_data_trans_gen.control_log('zmris00,persnl_clnt_flg,ZMRIC00,TITDMGMBRINDP1,CARD_ENDORSER_LIST', 'TITDMGPOLTRNH'
            , systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);

            return;
    END dm_policytran_transform;
-- Procedure for DM_DPNTNO_INSERT <STARTS> Here

    PROCEDURE dm_dpntno_insert (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        v_input_count     NUMBER;
        v_output_count    NUMBER;
        stg_starttime     TIMESTAMP;
        stg_endtime       TIMESTAMP;
        l_err_flg         NUMBER := 0;
        g_err_flg         NUMBER := 0;
        v_errormsg        VARCHAR2(2000);
        rows_inserted     NUMBER;
        l_app_old         VARCHAR2(20);
        temp_no           NUMBER;
        c_limit           PLS_INTEGER := p_array_size;
  -- Below cursor query is different from itr2 ; This was modified based on the
  -- discussion with Niranjan/ Kevin on 15/1/2021
        CURSOR cur_data IS
        SELECT
            substr(p.apcucd, 1, 8) chdrnum,
            substr(p.apcucd, 9, 2) rncnt,
            substr(p.apcucd, 11, 1) alcnt,
            p.apc7cd          cnttyp,
            spp.newzsalplan   slplan,
            'Named' insured,
            concat('000', substr(ric.iccicd, - 2)) mbrno,
            '00' dpntno,
            ric.icdmcd        instype,
            decode(ric.icdmcd, 'PO', 2 || ric.icbmst, 'PFA', 3 || ric.icbmst,
                   'SPA', 4 || ric.icbmst, 'PTA', 5 || ric.icbmst, 'PFT',
                   6 || ric.icbmst, 'CLP', 7 || ric.icbmst, 'EQ', 8 || ric.icbmst) prodtyp,
            ric.icb3va        prem_j1,
            ric.icb3va        prem_j2,
            ric.icb0va        sumins,
            p.apc6cd          endrcde
        FROM
            zmrap00                          p
            LEFT OUTER JOIN zmric00                          ric ON p.apcucd = ric.iccucd --#ZJNPG-10273 - G1 rehearsal substr(p.apcucd,1,8) = substr(ric.iccucd,1,8)
            LEFT OUTER JOIN mem_ind_polhist_ssplan_intrmdt   spp ON spp.apcucd = p.apcucd AND spp.mbrno = '000'||substr(ric.iccicd, - 2) 
            LEFT OUTER JOIN stagedbusr.zslphpf               hpf ON hpf.zsalplan = spp.newzsalplan
        WHERE
            substr(ric.iccucd, - 1) = '0'
            AND substr(p.apcucd, - 1) = '0'
            AND hpf.zslptyp = 'N'
        UNION ALL
        SELECT
            unnamed.chdrnum,
            unnamed.rncnt,
            unnamed.alcnt,
            unnamed.cnttyp,
            spp.newzsalplan slplan,
            unnamed.insured,
            '00001' mbrno,
            decode(insured, 'Main', '00', 'Spouse', '01',
                   'Relative', '02') dpntno,
            instype,
            prodtyp,
            prem_j1,
            prem_j2,
            sumins,
            endrcde
        FROM
            (
--***************************************************************************************************************		
-- Below query (query for "MAIN" Insured )changed to reflect the fixes made in ITR2
                SELECT
                    p.apcucd,
                    substr(p.apcucd, 1, 8) chdrnum,
                    substr(p.apcucd, 9, 2) rncnt,
                    substr(p.apcucd, 11, 1) alcnt,
                    NULL AS subcode,
                    p.apc7cd     cnttyp,
                    p.apc2cd     slplan,
                    'Main' insured,
						--concat('000', substr(ric.iccicd, - 2)) mbrno,
                    ric.icdmcd   instype,
                    decode(ric.icdmcd, 'PO', 2 || ric.icbmst, 'PFA', 3 || ric.icbmst,
                           'SPA', 4 || ric.icbmst, 'PTA', 5 || ric.icbmst, 'PFT',
                           6 || ric.icbmst, 'CLP', 7 || ric.icbmst, 'EQ', 8 || ric.icbmst) prodtyp,
                    ric.icb3va   prem_j1,
                    ric.icb3va   prem_j2,
                    ric.icb0va   sumins,
                    p.apc6cd     endrcde
                FROM
                    zmrap00   p
                    LEFT OUTER JOIN zmric00   ric ON p.apcucd = ric.iccucd --#ZJNPG-10273 - G1 rehearsal substr(p.apcucd,1,8) = substr(ric.iccucd,1,8)
						--LEFT OUTER JOIN spplanconvertion     spp ON spp.oldzsalplan = p.apc2cd                  
                WHERE
                    substr(ric.iccucd, - 1) = '0'
                    AND substr(p.apcucd, - 1) = '0'	

--***************************************************************************************************************	
                UNION ALL
                SELECT
                    p.apcucd,
                    substr(p.apcucd, 0, 8) chdrnum,
                    substr(p.apcucd, 9, 2) rncnt,
                    substr(p.apcucd, 11, 1) alcnt,
                    c.rcbucd   subcode,
                    c.rcbtcd   cnttyp,
                    c.rcbvcd   slplan,
                    'Spouse' insured,
                    c.rcb6cd   instype,
                    decode(c.rcb6cd, 'PO', 2 || c.rca0st, 'PFA', 3 || c.rca0st,
                           'SPA', 4 || c.rca0st, 'PTA', 5 || c.rca0st, 'PFT',
                           6 || c.rca0st, 'CLP', 7 || c.rca0st, 'EQ', 8 || c.rca0st) prodtyp,
                    c.rcbqva   prem_j1,
                    c.rcbtva   prem_j2,
                    c.rcbeva   sumins,
                    c.rcfocd   endrcde
                FROM
                    stagedbusr2.zmrap00   p,
                    stagedbusr2.zmrrc00   c
                WHERE
                    p.apc2cd = c.rcbvcd
                    AND p.apc6cd = c.rcfocd
                    AND p.apc7cd = c.rcbtcd
                    AND p.apc8cd = c.rcbucd
                    AND ( p.apblst = '1'
                          OR p.apblst = '3' ) -- commented as p.apblst='3' pertains to ITR3
    --AND P.APBLST ='1'
                UNION ALL
                SELECT
                    p.apcucd,
                    substr(p.apcucd, 0, 8) chdrnum,
                    substr(p.apcucd, 9, 2) rncnt,
                    substr(p.apcucd, 11, 1) alcnt,
                    c.rcbucd   subcode,
                    c.rcbtcd   cnttyp,
                    c.rcbvcd   slplan,
                    'Relative' insured,
                    c.rcb6cd   instype,
                    decode(c.rcb6cd, 'PO', 2 || c.rca0st, 'PFA', 3 || c.rca0st,
                           'SPA', 4 || c.rca0st, 'PTA', 5 || c.rca0st, 'PFT',
                           6 || c.rca0st, 'CLP', 7 || c.rca0st, 'EQ', 8 || c.rca0st) prodtyp,
                    c.rcbrva   prem_j1,
                    c.rcbuva   prem_j2,
                    c.rcbfva   sumins,
                    c.rcfocd   endrcde
                FROM
                    stagedbusr2.zmrap00   p,
                    stagedbusr2.zmrrc00   c
                WHERE
                    p.apc2cd = c.rcbvcd
                    AND p.apc6cd = c.rcfocd
                    AND p.apc7cd = c.rcbtcd
                    AND p.apc8cd = c.rcbucd
                    AND ( p.apblst = '1'
                          OR p.apblst = '3' ) -- commented as p.apblst='3' pertains to ITR3
      --AND P.APBLST ='1'
            ) unnamed
            LEFT OUTER JOIN mem_ind_polhist_ssplan_intrmdt   spp ON spp.apcucd = unnamed.apcucd AND spp.mbrno = '00001'
            LEFT OUTER JOIN stagedbusr.zslphpf               hpf ON hpf.zsalplan = spp.newzsalplan
        WHERE
    --substr(ric.iccucd,-1)='0'
            substr(unnamed.apcucd, - 1) = '0'
            AND hpf.zslptyp = 'U'
            AND unnamed.alcnt = '0'
            AND ( unnamed.prem_j1 > 0 --ZJNPG-9186
            OR unnamed.prem_j2 > 0);  --ZJNPG-9186

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data           cur_data%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF cur_data%rowtype;
        zmrap00_l_appls   zmrap00_cur_t;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For DPNTNO TABLE Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data INTO st_data;
                EXIT WHEN cur_data%notfound;
                DELETE FROM dpntno_table bri
                WHERE
                    bri.chdrnum = st_data.chdrnum;

            END LOOP;

            CLOSE cur_data;
            COMMIT;
    -- Delete the records for all the records exists in DPNTNO_TABLE for Delta Load
        END IF;

        v_errormsg := 'Errow while insert into DPNTNO_TABLE :';
        OPEN cur_data;
        LOOP
    --dbms_output.put_line ('Entering Cursor loop ');
            FETCH cur_data BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
            v_input_count := v_input_count + zmrap00_l_appls.count;
            FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
                l_app_old := zmrap00_l_appls(l_apindx).chdrnum;
                v_errormsg := 'INSERT :';
    -- dbms_output.put_line ('CHDRNUM : '||st_data.CHDRNUM);
                v_input_count := v_input_count + 1;
                BEGIN
                    INSERT INTO dpntno_table (
                        chdrnum,
                        rncnt,
                        alcnt,
                        cnttyp,
                        slplan,
                        insured,
                        mbrno,
                        dpntno,
                        instype,
                        prodtyp,
                        prem_j1,
                        prem_j2,
                        sumins,
                        endrcde
                    ) VALUES (
                        zmrap00_l_appls(l_apindx).chdrnum,
                        zmrap00_l_appls(l_apindx).rncnt,
                        zmrap00_l_appls(l_apindx).alcnt,
                        zmrap00_l_appls(l_apindx).cnttyp,
                        zmrap00_l_appls(l_apindx).slplan,
                        zmrap00_l_appls(l_apindx).insured,
                        zmrap00_l_appls(l_apindx).mbrno,
                        zmrap00_l_appls(l_apindx).dpntno,
                        zmrap00_l_appls(l_apindx).instype,
                        zmrap00_l_appls(l_apindx).prodtyp,
                        zmrap00_l_appls(l_apindx).prem_j1,
                        zmrap00_l_appls(l_apindx).prem_j2,
                        zmrap00_l_appls(l_apindx).sumins,
                        zmrap00_l_appls(l_apindx).endrcde
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
     -- DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_trans_gen.error_logs('DPNTNO_TABLE', zmrap00_l_appls(l_apindx).chdrnum, v_errormsg);
                        g_err_flg := 1;
                END;

            END LOOP;

            EXIT WHEN cur_data%notfound;
        END LOOP;

        COMMIT;
        CLOSE cur_data;
        IF l_err_flg = 1 THEN
    --ROLLBACK;
            l_err_flg := 0;
        END IF;
        IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
            COMMIT;
        END IF;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := dm_data_trans_gen.control_log('zmrap00,zmrrc00', 'DPNTNO_TABLE', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_trans_gen.control_log('zmrap00,zmrrc00', 'DPNTNO_TABLE', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            application_no := NULL;
            dm_data_trans_gen.error_logs('DPNTNO_TABLE', application_no, v_errormsg);
            temp_no := dm_data_trans_gen.control_log('zmrap00,zmrrc00', 'DPNTNO_TABLE', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);

            return;
    END dm_dpntno_insert;
-- Procedure for dm_polhis_cov <STARTS> Here

    PROCEDURE dm_polhis_cov (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        v_input_count     NUMBER;
        v_output_count    NUMBER;
        stg_starttime     TIMESTAMP;
        stg_endtime       TIMESTAMP;
        l_err_flg         NUMBER := 0;
        g_err_flg         NUMBER := 0;
        v_errormsg        VARCHAR2(2000);
        rows_inserted     NUMBER;
        l_app_old         VARCHAR2(20);
        temp_no           NUMBER;
        c_limit           PLS_INTEGER := p_array_size;
        CURSOR cur_data IS --#ZJNPG-9739: RUAT - performance improvement 
         SELECT DISTINCT
            refnum,
            zseqno,
            mbrno,
            dpntno,
            prodtyp,
            effdate,
            aprem,
            hsuminsu,
            ztaxflg,
            ndrprem,
            prodtyp02,
            zinstype
        FROM
            (
                SELECT DISTINCT
                    substr(p.apcucd, 1, 8) AS refnum,
                    dpn.mbrno     mbrno,
                    dpn.dpntno,
                    dpn.prodtyp,
                    p.apa2dt      AS effdate,
                    CASE
                        WHEN dpn.insured = 'Named' THEN
                            dpn.prem_j1
                        ELSE
                            CASE
                                WHEN ris.iscfst = '1' THEN
                                    dpn.prem_j1
                                ELSE
                                    dpn.prem_j2
                            END
                    END AS aprem,
                    ( dpn.sumins * nvl(dnm.dnmtor, 1) ) AS hsuminsu,
                    CASE
                        WHEN substr(dpn.prodtyp, 2, 1) = '9' THEN
                            'Y'
                        ELSE
                            'N'
                    END AS ztaxflg,
                    ric.icb7va    AS ndrprem,
                    CASE
                        WHEN ric.icb7va <> 0 THEN
                            ndr.ndr_rider_code
                    END AS prodtyp02,
                    dpn.instype   AS zinstype,
                    substr(p.apcucd, - 3) AS zseqno
                FROM
                    zmrap00                            p
                    INNER JOIN dpntno_table                       dpn ON dpn.chdrnum = substr(p.apcucd, 1, 8) and dpn.RNCNT = substr(p.apcucd, 9,2) --#ZJNPG-10273 - G1 rehearsal
                    LEFT OUTER JOIN zmric00                            ric ON substr(p.apcucd, 1, 8) = substr(ric.iccucd, 1, 8)
                                                   AND substr(ric.iccicd, - 2) = substr(dpn.mbrno, - 2)
                                                   AND ric.icbmst = substr(dpn.prodtyp, - 3)
                    LEFT OUTER JOIN zmris00                            ris ON p.apcucd = ris.iscucd
                                                   AND substr(ris.iscicd, - 2) = substr(dpn.mbrno, - 2)
                    --LEFT OUTER JOIN mem_ind_polhist_ssplan_intrmdt     spp ON spp.apcucd = p.apcucd and spp.mbrno = dpn.mbrno
                    LEFT OUTER JOIN stagedbusr2.ig_coverage_ndrrider   ndr ON dpn.instype = ndr.insurance_type
                                                                            AND ndr.prod_code = dpn.prodtyp
                    LEFT OUTER JOIN titdmgsuminsfactor                 dnm ON dnm.zinstype = dpn.instype            --ZJNPG-8564: Apply Denominotr Factor for Sum Insured
                                                              AND dnm.dm_prodtyp = substr(dpn.prodtyp, - 3) --ZJNPG-8564: Apply Denominotr Factor for Sum Insured
                WHERE
                    substr(ric.iccucd, - 1) = '0'
                    AND substr(p.apcucd, - 1) = '0'
    --  ************************
                UNION ALL
	--  ************************
	-- Below query changed to reflect the fixes made in ITR2
                SELECT DISTINCT
                    substr(p.apcucd, 1, 8) AS refnum,
                    dpn.mbrno,
                    dpn.dpntno,
                    ppf.prodtyp,
                    p.apa2dt AS effdate,
                    0 AS aprem,
                    0 AS hsuminsu,
                    'N' AS ztaxflg,
                    0 AS ndrprem,
                    ' ' AS prodtyp02,
                    ppf.zinstype,
                    substr(p.apcucd, - 3) AS zseqno
                FROM
                    zmrap00                          p
                    INNER JOIN dpntno_table                          dpn ON dpn.chdrnum = substr(p.apcucd, 1, 8) and dpn.RNCNT = substr(p.apcucd, 9,2) --#ZJNPG-10273 - G1 rehearsal
                    LEFT OUTER JOIN mem_ind_polhist_ssplan_intrmdt   spp ON spp.apcucd = p.apcucd and spp.mbrno = dpn.mbrno
                    LEFT OUTER JOIN stagedbusr.zslppf                ppf ON ppf.zsalplan = spp.newzsalplan
                WHERE
                    ppf.zcovrid = 'R'
                    AND substr(p.apcucd, - 1) = '0'
                    AND 
                      (dpn.mbrno = '00001' OR 
                        (dpn.mbrno = '00002' AND NOT EXISTS 
                                                  (SELECT 1 FROM stagedbusr.itempf it WHERE ppf.prodtyp= RTRIM(it.itemitem) AND it.itemtabl='TQ9GY'
                                                      AND it.itempfx='IT' AND it.validflag='1' AND TRIM(substr(UTL_RAW.CAST_TO_VARCHAR2(it.genarea),1,5))='R'
                                                      AND substr(UTL_RAW.CAST_TO_VARCHAR2(genarea),9,1)='Y')
                                                  )
                     )
            )
        ORDER BY
            refnum,
            effdate,
            dpntno;
    
  --TYPE ig_array IS   TABLE OF cur_data%rowtype;

        st_data           cur_data%rowtype;

--**********************************************************************************************  

    --TYPE ig_array IS TABLE OF cur_data%rowtype;
    --st_data cur_data%rowtype;
        TYPE zmrap00_cur_t IS
            TABLE OF cur_data%rowtype;
        zmrap00_l_appls   zmrap00_cur_t;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For TITDMGMBRINDP2 TABLE Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data INTO st_data;
                EXIT WHEN cur_data%notfound;
                DELETE FROM titdmgmbrindp2 bri
                WHERE
                    bri.refnum = st_data.refnum;

            END LOOP;

            CLOSE cur_data;
            COMMIT;
    -- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
        END IF;

        v_errormsg := 'Errow while insert into TITDMGMBRINDP2 :';
        OPEN cur_data;
        LOOP
            FETCH cur_data BULK COLLECT INTO zmrap00_l_appls LIMIT c_limit;
            v_input_count := v_input_count + zmrap00_l_appls.count;
            FOR l_apindx IN 1..zmrap00_l_appls.count LOOP
                l_app_old := zmrap00_l_appls(l_apindx).refnum
                             || zmrap00_l_appls(l_apindx).mbrno;
                v_errormsg := 'INSERT :';
                BEGIN
                    INSERT INTO titdmgmbrindp2 (
                        refnum,
                        zseqno,
                        mbrno,
                        dpntno,
                        prodtyp,
                        effdate,
                        aprem,
                        hsuminsu,
                        ztaxflg,
                        ndrprem,
                        prodtyp02,
                        zinstype
                    ) VALUES (
                        zmrap00_l_appls(l_apindx).refnum,
                        zmrap00_l_appls(l_apindx).zseqno,
                        zmrap00_l_appls(l_apindx).mbrno,
                        zmrap00_l_appls(l_apindx).dpntno,
                        zmrap00_l_appls(l_apindx).prodtyp,
                        zmrap00_l_appls(l_apindx).effdate,
                        zmrap00_l_appls(l_apindx).aprem,
                        zmrap00_l_appls(l_apindx).hsuminsu,
                        zmrap00_l_appls(l_apindx).ztaxflg,
                        zmrap00_l_appls(l_apindx).ndrprem,
                        zmrap00_l_appls(l_apindx).prodtyp02,
                        zmrap00_l_appls(l_apindx).zinstype
                    );

                    v_output_count := v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
     -- DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_trans_gen.error_logs('TITDMGMBRINDP2', zmrap00_l_appls(l_apindx).refnum, v_errormsg);
                        g_err_flg := 1;
                END;

            END LOOP;
            COMMIT;   
            EXIT WHEN cur_data%notfound;
        END LOOP;


        CLOSE cur_data;
        COMMIT;
  --dbms_output.put_line (' V_OUTPUT_COUNT : '||V_OUTPUT_COUNT);
        IF l_err_flg = 1 THEN
    --ROLLBACK;
            l_err_flg := 0;
        END IF;
        IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
            COMMIT;
        END IF;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := dm_data_trans_gen.control_log('ZMRAP00,zslphpf,zslppf,DPNTNO_TABLE, MEM_IND_POLHIST_SSPLAN_INTRMDT', 'TITDMGMBRINDP2'
            , systimestamp, l_app_old, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_trans_gen.control_log('ZMRAP00,zslphpf,zslppf,DPNTNO_TABLE, MEM_IND_POLHIST_SSPLAN_INTRMDT', 'TITDMGMBRINDP2'
            , systimestamp, l_app_old, v_errormsg,
                              'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            dm_data_trans_gen.error_logs('TITDMGMBRINDP2', l_app_old, v_errormsg);
            application_no := NULL;
            temp_no := dm_data_trans_gen.control_log('ZMRAP00,zslphpf,zslppf,DPNTNO_TABLE, MEM_IND_POLHIST_SSPLAN_INTRMDT', 'TITDMGMBRINDP2'
            , systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
 -- dbms_output.put_line(v_errormsg);

            return;
    END dm_polhis_cov;
-- Procedure for  dm_polhis_apirno <STARTS> Here

    PROCEDURE dm_polhis_apirno (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        mbr_name_not_matching EXCEPTION;
        PRAGMA exception_init ( mbr_name_not_matching, -20111 );
        v_input_count           NUMBER;
        v_input_count_insert    NUMBER;
        v_output_count_insert   NUMBER;
        v_output_count          NUMBER;
        v_process_flg           NUMBER;
        stg_starttime           TIMESTAMP;
        stg_endtime             TIMESTAMP;
        l_err_flg               NUMBER := 0;
        g_err_flg               NUMBER := 0;
        v_errormsg              VARCHAR2(2000);
        rows_inserted           NUMBER;
        paid_plan_count         NUMBER;
        pj_fullkanjiname_temp   VARCHAR2(200);
        mbrno_update_count      NUMBER;
        l_app_old               VARCHAR2(20);
        temp_no                 NUMBER;
        free_plan_load          VARCHAR2(20);
        free_v_input_count      NUMBER;
        free_v_output_count     NUMBER;
        his_refnum              titdmgcltrnhis.refnum%TYPE;
        his_lgivname            titdmgcltrnhis.lgivname%TYPE;
        his_lsurname            titdmgcltrnhis.lsurname%TYPE;
        var_err                 VARCHAR2(200);
        v_stg_clntnum           persnl_clnt_flg.stg_clntnum%TYPE;
        prsl_chdrnum            persnl_clnt_flg.chdrnum%TYPE;
        insur_role              persnl_clnt_flg.insur_role%TYPE;
        dp1_zinsrole            titdmgmbrindp1.zinsrole%TYPE;
        new_mbrno               titdmgmbrindp1.mbrno%TYPE;
        c_limit                 PLS_INTEGER := p_array_size;

  /* BELOW CURSOR TO INSERT ROWS FROM MIPHSTDB INTO TITDMGAPIRNO (Assumption : MIPHSTDB  will contain Paid plan data) */
        CURSOR cur_insert_titdmgapirno IS
        SELECT
            chdrnum,
            mbrno,
            zinstype,
            zapirno,
            fullkanjiname
        FROM
            stagedbusr2.miphstdb
        ORDER BY
            chdrnum,
            mbrno,
            zinstype;
  /*Below cursor is to INSERT rows with Free plan */
  --Below cursor was modified to reflect correct zapirno on 11/20 to fix JIRA ticket ZJNPG-8455

        CURSOR cur_data_free_plan IS
        SELECT DISTINCT -- ZJNPG-9103: Issue #9
            chdrnum,
            mbrno,
            zinstype,
            DENSE_RANK() OVER(
                PARTITION BY chdrnum
                ORDER BY
                    mbrno, zinstype
            ) AS zapirno,
            lsurname,
            lgivname,
            fullkanjiname
        FROM
            (
                SELECT DISTINCT
                    bri.refnum     AS chdrnum,
                    bri.mbrno      AS mbrno,
                    bri.zinstype   AS zinstype,
                    ROW_NUMBER() OVER(
                        PARTITION BY bri.refnum
                        ORDER BY
                            bri.mbrno
                    ) AS zapirno,
                    TRIM(substr((TRIM(p.apcbig)), 1,(
                        CASE
                            WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                instr(TRIM(p.apcbig), unistr('\3000'))
                            ELSE
                                instr(TRIM(p.apcbig), '?')
                        END
                    ) - 1)) lsurname,
                    TRIM(substr((TRIM(p.apcbig)),(
                        CASE
                            WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                instr(TRIM(p.apcbig), unistr('\3000'))
                            ELSE
                                instr(TRIM(p.apcbig), '?')
                        END
                    ) + 1)) lgivname,
                    TRIM(substr((TRIM(p.apcbig)), 1,(
                        CASE
                            WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                instr(TRIM(p.apcbig), unistr('\3000'))
                            ELSE
                                instr(TRIM(p.apcbig), '?')
                        END
                    ) - 1))
                    || TRIM(substr((TRIM(p.apcbig)),(
                        CASE
                            WHEN instr(TRIM(p.apcbig), '?') = 0 THEN
                                instr(TRIM(p.apcbig), unistr('\3000'))
                            ELSE
                                instr(TRIM(p.apcbig), '?')
                        END
                    ) + 1)) AS fullkanjiname
                FROM
                    titdmgmbrindp2   bri
                    LEFT OUTER JOIN zmrap00            p ON substr(p.apcucd, 1, 8) = bri.refnum --Ticket #ZJNPG-9739: remove substr
                    LEFT OUTER JOIN zmrrpt00         rpt ON rpt.rptbtcd = p.apc7cd
                    LEFT OUTER JOIN maxpolnum         mx ON p.apcucd = mx.app_no --Ticket #ZJNPG-9739: added this line to reomve duplicates 
                WHERE
                    rpt.rptfpst = 'F'
                    and p.apcucd = mx.maxapcucd
            )
        ORDER BY
            chdrnum,
            mbrno,
            zinstype;

        TYPE insert_array IS
            TABLE OF cur_insert_titdmgapirno%rowtype;
        insert_plan_data        cur_insert_titdmgapirno%rowtype;
        TYPE insert_freeplan_array IS
            TABLE OF cur_data_free_plan%rowtype;
        insert_freeplan_row     cur_data_free_plan%rowtype;
        TYPE zmrap00_cur_t1 IS
            TABLE OF cur_insert_titdmgapirno%rowtype;
        zmrap00_l_appls1        zmrap00_cur_t1;
        TYPE zmrap00_cur_t2 IS
            TABLE OF cur_data_free_plan%rowtype;
        zmrap00_l_appls2        zmrap00_cur_t2;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_input_count_insert := 0;
        v_output_count := 0;
        free_v_input_count := 0;
        free_v_output_count := 0;
        paid_plan_count := 0;
        v_output_count_insert := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For TITDMGAPIRNO TABLE Load:';
            OPEN cur_insert_titdmgapirno;
            LOOP
                FETCH cur_insert_titdmgapirno INTO insert_plan_data;
                EXIT WHEN cur_insert_titdmgapirno%notfound;
                DELETE FROM titdmgapirno bri
                WHERE
                    bri.chdrnum = insert_plan_data.chdrnum;

            END LOOP;

            CLOSE cur_insert_titdmgapirno;
            COMMIT;
    -- Delete the records for all the records exists in TITDMGMBRINDP2 for Delta Load
        END IF;
  /* below code to INSERT ROWS FROM MIPHSTDB INTO TITDMGAPIRNO TABLE */

        BEGIN
            v_errormsg := 'Errow while INSERTING rows FROM MIPHSTDB INTO  TITDMGAPIRNO :';
            OPEN cur_insert_titdmgapirno;
            LOOP
                FETCH cur_insert_titdmgapirno BULK COLLECT INTO zmrap00_l_appls1 LIMIT c_limit;
                v_input_count := v_input_count + zmrap00_l_appls1.count;
                FOR l_apindx IN 1..zmrap00_l_appls1.count LOOP
                    l_app_old := zmrap00_l_appls1(l_apindx).chdrnum
                                 || zmrap00_l_appls1(l_apindx).mbrno;
                    v_errormsg := 'INSERT from MIPHSTDB INTO TITDMGAPIRNO :';
                    v_input_count_insert := v_input_count_insert + 1;
                    BEGIN
                        INSERT INTO titdmgapirno (
                            chdrnum,
                            mbrno,
                            zinstype,
                            zapirno,
                            fullkanjiname
                        ) VALUES (
                            zmrap00_l_appls1(l_apindx).chdrnum,
                            zmrap00_l_appls1(l_apindx).mbrno,
                            zmrap00_l_appls1(l_apindx).zinstype,
                            zmrap00_l_appls1(l_apindx).zapirno,
                            zmrap00_l_appls1(l_apindx).fullkanjiname
                        );

                        v_output_count_insert := v_output_count_insert + 1;
                    EXCEPTION
                        WHEN OTHERS THEN
			--  DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                            v_errormsg := v_errormsg
                                          || '-'
                                          || sqlerrm;
                            dm_data_trans_gen.error_logs('TITDMGAPIRNO', l_app_old, v_errormsg);
                            g_err_flg := 1;
                    END;

                END LOOP;

                EXIT WHEN cur_insert_titdmgapirno%notfound;
            END LOOP;

            COMMIT;
		--rows_inserted := v_input_count;
            CLOSE cur_insert_titdmgapirno;
            COMMIT;
            IF g_err_flg = 0 THEN
                v_errormsg := 'SUCCESS';
                application_no := NULL;
                temp_no := dm_data_trans_gen.control_log('MIPHSTDB', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

            ELSE
                v_errormsg := 'COMPLETED WITH ERROR';
                temp_no := dm_data_trans_gen.control_log('MIPHSTDB', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
		 -- dbms_output.put_line(v_errormsg);

            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                v_errormsg := v_errormsg
                              || '-'
                              || sqlerrm;
                dm_data_trans_gen.error_logs('TITDMGAPIRNO', application_no, v_errormsg);
                temp_no := dm_data_trans_gen.control_log('MIPHSTDB', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);
  --RETURN;

        END;
  --1st update statement of mbrno for single records

        BEGIN
            UPDATE titdmgapirno
            SET
                mbrno = '00001'
            WHERE
                chdrnum IN (
                    SELECT
                        chdrnum
                    FROM
                        titdmgapirno
                    WHERE
                        chdrnum NOT IN (
                            SELECT
                                chdrnum
                            FROM
                                titdmgapirno
                            WHERE
                                mbrno = '00001'
                        )
                    GROUP BY
                        chdrnum
                    HAVING
                        COUNT(*) = 1
                );

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                v_errormsg := v_errormsg
                              || '-'
                              || sqlerrm;
                dm_data_trans_gen.error_logs('TITDMGAPIRNO', application_no, v_errormsg);
                temp_no := dm_data_trans_gen.control_log('TITDMGAPIRNO', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg
                ,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);

        END;

  --2nd update statement for matching name (for multiple records matching name)

        BEGIN
            MERGE INTO titdmgapirno api1
            USING (
                      SELECT
                          chdrnum,
                          recidxapirno,
                          clnt_mbrno
                      FROM
                          (
                                SELECT
                                    api.chdrnum        chdrnum,
                                    api.recidxapirno   recidxapirno,
                                    cl.cln_mbrno       clnt_mbrno
                                FROM
                                   (
                                    SELECT 
									TRIM(regexp_replace(a.fullkanjiname, '[[:space:]]+', '')) AS name_2,
									--TRIM(replace(replace(a.fullkanjiname, unistr('\3000'), ''), ' ', '')) AS name_2,
									a.*
                                    FROM
                                    titdmgapirno a
                                ) api
                                LEFT OUTER JOIN (
                                    select * from (
                                        select concat(SUBSTR(a.iscucd,1,8), MAX(SUBSTR(a.iscucd, - 3)) OVER( PARTITION BY SUBSTR(a.iscucd,1,8) )) maxapcucd, 
                                        a.ISCUCD, substr(a.ISCUCD,1,8) chdrnum, '000'||substr(a.ISCICD,-2) cln_mbrno, 
										TRIM(regexp_replace(a.ISBVIG, '[[:space:]]+', '')) cln_fullname  
										--TRIM(replace(replace(a.isbvig, unistr('\3000'), ''), ' ', '')) cln_fullname  
										from zmris00 a
                                        ) ris 
                                    where ris.maxapcucd = ris.iscucd 
                                ) cl ON cl.chdrnum = api.chdrnum
                                          AND cl.cln_fullname = api.name_2
                              WHERE
                                  api.chdrnum NOT IN (
                                      SELECT DISTINCT
                                          chdrnum
                                      FROM
                                          titdmgapirno
                                      WHERE
                                          mbrno = '00001'
                                  )
                                  AND cl.cln_mbrno IS NOT NULL
                          )
                  )
            api2 ON ( api1.chdrnum = api2.chdrnum
                      AND api1.recidxapirno = api2.recidxapirno )
            WHEN MATCHED THEN UPDATE
            SET api1.mbrno = api2.clnt_mbrno;

            COMMIT;
            INSERT INTO titdmgapirno_log (
                chdrnum,
                mbrno,
                log_description,
                event_time
            )
                SELECT
                    api.chdrnum,
                    mbrno,
                    cl.cln_fullname
                    || ' , '
                    || api.name_2
                    || ' NAME NOT MATCHING FOR MBRNO UPDATE' log_description,
                    sysdate
                FROM
                    (SELECT
                            TRIM(regexp_replace(a.fullkanjiname, '[[:space:]]+', '')) AS name_2,
							--TRIM(replace(replace(a.fullkanjiname, unistr('\3000'), ''), ' ', '')) AS name_2,
							a.*
                        FROM
                            titdmgapirno a
                ) api
                LEFT OUTER JOIN (
                        select * from (
                            select concat(SUBSTR(a.iscucd,1,8), MAX(SUBSTR(a.iscucd, - 3)) OVER( PARTITION BY SUBSTR(a.iscucd,1,8) )) maxapcucd, 
                            a.ISCUCD, substr(a.ISCUCD,1,8) chdrnum, '000'||substr(a.ISCICD,-2) cln_mbrno, 
							TRIM(regexp_replace(a.ISBVIG, '[[:space:]]+', '')) cln_fullname  
                            --TRIM(replace(replace(a.isbvig, unistr('\3000'), ''), ' ', '')) cln_fullname
							from zmris00 a
                            ) ris 
                        where ris.maxapcucd = ris.iscucd                    
                ) cl ON cl.chdrnum = api.chdrnum
                            AND cl.cln_fullname = api.name_2
                WHERE
                    rtrim(cl.cln_mbrno) IS NULL
                    AND api.chdrnum NOT IN (
                        SELECT DISTINCT
                            chdrnum
                        FROM
                            titdmgapirno
                        WHERE
                            mbrno = '00001'
                    )
                ORDER BY
                    api.name_2 DESC;

            IF SQL%found THEN
    --commit;
                raise_application_error(-20111, ' mbr_name_not_matching');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                v_errormsg := v_errormsg
                              || '-'
                              || sqlerrm;
                dm_data_trans_gen.error_logs('TITDMGAPIRNO', application_no, v_errormsg);
                temp_no := dm_data_trans_gen.control_log('TITDMGAPIRNO', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg
                ,
                              'F', v_input_count, v_output_count);
  --dbms_output.put_line(v_errormsg);

        END;

  /* OPENING BELOW CURSOR TO INSERT ROWS FOR FREE PLAN */

        OPEN cur_data_free_plan;
        LOOP
            FETCH cur_data_free_plan BULK COLLECT INTO zmrap00_l_appls2 LIMIT c_limit;
            free_v_input_count := free_v_input_count + 1;
            FOR l_apindx IN 1..zmrap00_l_appls2.count LOOP
                free_plan_load := zmrap00_l_appls2(l_apindx).chdrnum
                                  || zmrap00_l_appls2(l_apindx).mbrno;
                v_errormsg := 'Errow while processing Free plan rows into table TITDMGAPIRNO';
                BEGIN
                    INSERT INTO titdmgapirno (
                        chdrnum,
                        mbrno,
                        zinstype,
                        zapirno,
                        fullkanjiname
                    ) VALUES (
                        zmrap00_l_appls2(l_apindx).chdrnum,
                        zmrap00_l_appls2(l_apindx).mbrno,
                        zmrap00_l_appls2(l_apindx).zinstype,
                        zmrap00_l_appls2(l_apindx).zapirno,
                        zmrap00_l_appls2(l_apindx).fullkanjiname
                    );

                    free_v_output_count := free_v_output_count + 1;
                EXCEPTION
                    WHEN OTHERS THEN
     -- DBMS_OUTPUT.PUT_LINE(' WHEN OTHERS '||SQLERRM);
                        v_errormsg := v_errormsg
                                      || '-'
                                      || sqlerrm;
                        dm_data_trans_gen.error_logs('TITDMGAPIRNO', zmrap00_l_appls2(l_apindx).chdrnum, v_errormsg);
                        g_err_flg := 1;
                END;

            END LOOP;

            EXIT WHEN cur_data_free_plan%notfound;
        END LOOP;

        COMMIT;
        CLOSE cur_data_free_plan;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            application_no := NULL;
            temp_no := dm_data_trans_gen.control_log('TITDMGAPIRNO', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_trans_gen.control_log('TITDMGAPIRNO', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
		 -- dbms_output.put_line(v_errormsg);

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            dm_data_trans_gen.error_logs('TITDMGAPIRNO', application_no, v_errormsg);
            temp_no := dm_data_trans_gen.control_log('TITDMGAPIRNO', 'TITDMGAPIRNO', systimestamp, application_no, v_errormsg,
                              'F', v_input_count, v_output_count);
 -- dbms_output.put_line(v_errormsg);

            return;
    END dm_polhis_apirno;

END dm_data_trans_polhis;