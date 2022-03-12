create or replace PROCEDURE recon_g1zdpolhst (i_schedulenumber IN VARCHAR2) 
IS
  v_module_name         CONSTANT VARCHAR2(40) := 'DMPH - Policy History';
  obj_recon_master      recon_master%rowtype;
  v_igpolnum1           NUMBER(18);
  v_stgpolnum1          NUMBER(18);
  v_stgpolnum2          NUMBER(18);
  v_stgpolnum3          NUMBER(18);
  v_dmpjpolnum          NUMBER(18);
  v_gmh                 NUMBER(18);
  v_gxh                 NUMBER(18);
  v_stg1                NUMBER(18);
  v_stg2                NUMBER(18);
  v_dminsured1          NUMBER(18);
  v_dminsured2          NUMBER(18);
  v_ig_unnmed1          NUMBER(18);
  v_ig_unnmed2          NUMBER(18);
  v_dmunnamed           NUMBER(18);
  v_dmprodtyp           NUMBER(18);
  v_ig_prodtyp1         NUMBER(18);
  v_ig_prodtyp2         NUMBER(18);
  v_dmapirno            NUMBER(18);
  v_ig_apirno1          NUMBER(18);
  v_ig_apirno2          NUMBER(18);
  v_dmgtran             NUMBER(18);
  v_ig_newbus1          NUMBER(18);
  v_ig_newbus2          NUMBER(18);
  v_ig_newbus3          NUMBER(18);
  v_dmgnewbus           NUMBER(18);
  v_ig_cancl            NUMBER(18);
  v_dmcancl             NUMBER(18);
  v_ig_benf             NUMBER(18);
  v_dmbenf              NUMBER(18);
  v_cnterr              NUMBER(6);
  p_exitcode            NUMBER;
  p_exittext            VARCHAR2(2000); 
  v_odmcnt              NUMBER(18);
  v_ig_odmcnt              NUMBER(18);

  CURSOR c_pol_count IS 
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'ZTRAPF' v_tab FROM Jd1dta.ZTRAPF WHERE JOBNM = 'G1ZDPOLHST'
    UNION ALL
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'ZALTPF' v_tab FROM Jd1dta.ZALTPF WHERE JOBNM = 'G1ZDPOLHST'
    UNION ALL
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'GXHIPF' v_tab FROM Jd1dta.GXHIPF WHERE JOBNM = 'G1ZDPOLCOV'
    UNION ALL
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'ZTEMPCOVPF' v_tab FROM Jd1dta.ZTEMPCOVPF WHERE JOBNM = 'G1ZDPOLCOV'
    UNION ALL
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'ZAPIRNOPF' v_tab FROM Jd1dta.ZAPIRNOPF WHERE JOBNM = 'G1ZDAPIRNO'
    UNION ALL
    SELECT COUNT(distinct CHDRNUM) tab_cnt, 'ZMCIPF' v_tab FROM Jd1dta.ZMCIPF WHERE JOBNM = 'G1ZDPOLHST';
  obj_polcount c_pol_count%rowtype; 

  CURSOR c_insrd_count IS
    SELECT COUNT(*) tab_cnt, 'GXHIPF' v_tabnm FROM (select CHDRNUM, Count (distinct MBRNO) from GXHIPF where JOBNM = 'G1ZDPOLCOV' group by CHDRNUM)
    UNION ALL
    SELECT COUNT(*) tab_cnt, 'ZINSDTLSPF' v_tabnm FROM (select CHDRNUM, Count (distinct MBRNO) from ZINSDTLSPF where JOBNM = 'G1ZDPOLHST' group by CHDRNUM)
    UNION ALL
    SELECT COUNT(*) tab_cnt, 'ZTEMPCOVPF' v_tabnm FROM (select CHDRNUM, Count (distinct MBRNO) from ZTEMPCOVPF where JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);
  obj_insrd c_insrd_count%rowtype;

  CURSOR c_tran_count IS
    SELECT COUNT(*) tab_cnt, 'ZTRAPF' v_tabnm FROM (SELECT CHDRNUM, COUNT(*)  FROM ZTRAPF where JOBNM = 'G1ZDPOLHST' Group By CHDRNUM)
    UNION ALL
    SELECT COUNT(*) tab_cnt, 'ZALTPF' v_tabnm FROM (SELECT CHDRNUM, COUNT(*)  FROM ZALTPF where JOBNM = 'G1ZDPOLHST' Group By CHDRNUM)
    UNION ALL
    SELECT COUNT(*) tab_cnt, 'ZINSDTLSPF' v_tabnm FROM (SELECT CHDRNUM, COUNT(distinct TRANNO) FROM ZINSDTLSPF where MBRNO = '00001' and ZINSROLE = 1 and JOBNM = 'G1ZDPOLHST' Group By CHDRNUM);
  obj_tran  c_tran_count%rowtype;  

BEGIN
    --Object Preparation:
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_RECON_MASTER.module_name := v_module_name;
    obj_recon_master.rundate := SYSDATE;

    --------PHPOL1: POLICY COUNT START-------------------------------
    --IG Policy Count:
    SELECT COUNT(*) INTO v_igpolnum1 FROM Jd1dta.GCHD WHERE CHDRNUM NOT IN( SELECT CHDRNUM FROM Jd1dta.GCHD WHERE CHDRNUm = MPLNUM);

    ---Stage Policy Coutnt:
    SELECT COUNT(DISTINCT CHDRNUM) INTO v_stgpolnum1 FROM stagedbusr.TITDMGPOLTRNH@DMSTAGEDBLINK;
    SELECT COUNT(DISTINCT REFNUM) INTO v_stgpolnum2 FROM stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK;
    SELECT COUNT(DISTINCT CHDRNUM) INTO v_stgpolnum3 FROM stagedbusr.TITDMGAPIRNO@DMSTAGEDBLINK;

    --PJ/DM Policy Count:
    SELECT COUNT(DISTINCT SUBSTR(P.APCUCD,1,8)) INTO v_dmpjpolnum 
        FROM stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK P LEFT OUTER JOIN stagedbusr2.zmris00@DMSTGUSR2DBLINK RIS on RIS.ISCUCD = p.apcucd 
            INNER JOIN persnl_clnt_flg@DMSTGUSR2DBLINK   flg ON flg.apcucd = p.apcucd  AND flg.isa4st IS NOT NULL
                    INNER JOIN zmris00@DMSTGUSR2DBLINK   ris ON ris.iscicd = flg.iscicd
                    LEFT JOIN zmrrpt00@DMSTGUSR2DBLINK     t ON p.apc7cd = t.rptbtcd;

    v_cnterr := 0;
    obj_recon_master.recon_query_id := 'PHPOL1';
    obj_recon_master.group_clause   := 'CHDRNUM';
    obj_recon_master.where_clause   := '';

    OPEN c_pol_count;
    LOOP
    FETCH c_pol_count INTO obj_polcount;
    EXIT WHEN c_pol_count%notfound;

    obj_recon_master.source_value       := v_dmpjpolnum;
    obj_recon_master.staging_value      := v_stgpolnum1;
    obj_recon_master.ig_value           := obj_polcount.tab_cnt;
    obj_recon_master.validation_type    := 'COUNT ' || obj_polcount.v_tab;
    obj_recon_master.query_desc         := 'Policy Count in ZMRAP00, Policy Count in TITDMGPOLTRNH/TITDMGMBRINDP2/TITDMGAPIRNO, Policy count in ' ||  obj_polcount.v_tab;

    IF (v_dmpjpolnum = v_stgpolnum1) AND (v_stgpolnum1 = obj_polcount.tab_cnt) AND (v_stgpolnum2 = obj_polcount.tab_cnt)
        AND (v_stgpolnum3 = obj_polcount.tab_cnt) THEN
        obj_recon_master.status         := 'PASS';
    ELSE 
        obj_recon_master.status         := 'FAIL';
        v_cnterr                        := v_cnterr + 1;
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    END LOOP;

    obj_recon_master.source_value       := 0;
    obj_recon_master.staging_value      := 0;
    obj_recon_master.ig_value           := v_igpolnum1;
    obj_recon_master.validation_type    := 'IG COUNT';
    obj_recon_master.query_desc         := 'Policy count in (ZINSDTLSPF, ZTRAPF, ZALTPF, GXHIPF, ZTEMPCOVPF, ZAPIRNO, ZMCIPF) vs. Policy count in GCHD';

    IF (v_cnterr = 0) AND (v_igpolnum1 = v_stgpolnum1) THEN
        obj_recon_master.status         := 'PASS';
    ELSE
        obj_recon_master.status         := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL1: POLICY COUNT END---------------------------------


    --------PHPOL2: POLICY COUNT FOR ZSUBCOVDTLS START----------------
    --IG Policy Count:
    SELECT COUNT(*) INTO v_igpolnum1 FROM Jd1dta.ZSUBCOVDTLS  WHERE JOBNM = 'G1ZDPOLHST';

    --STAGE Policy Count:
    SELECT COUNT(DISTINCT REFNUM) INTO v_stgpolnum2 FROM stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK WHERE NDRPREM <> 0;

    --DM/PJ Policy Count:
    SELECT COUNT(DISTINCT SUBSTR(P.APCUCD,1,8)) INTO v_dmpjpolnum
        FROM stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK P LEFT OUTER JOIN stagedbusr2.ZMRIC00@DMSTGUSR2DBLINK RIC ON RIC.ICCUCD = P.APCUCD
        RIGHT OUTER JOIN stagedbusr2.dpntno_table@DMSTGUSR2DBLINK n on n.chdrnum =  substr(P.APCUCD,1,8)
        WHERE SUBSTR(RIC.ICCUCD,1,8) = N.CHDRNUM AND RIC.ICB7VA <> 0;

    obj_recon_master.recon_query_id     := 'PHPOL2';
    obj_recon_master.group_clause       := 'CHDRNUM';
    obj_recon_master.where_clause       := 'NDRPREM <> 0';
    obj_recon_master.source_value       := v_dmpjpolnum;
    obj_recon_master.staging_value      := v_stgpolnum2;
    obj_recon_master.ig_value           := v_igpolnum1;
    obj_recon_master.validation_type    := 'COUNT';
    obj_recon_master.query_desc         := 'Policy count from ZMRAP00, Policy Count in TITDMGMBRINDP2, Policy count in ZSUBCOVDTLS WHERE NDRPREM <> 0';

    IF (v_dmpjpolnum =  v_igpolnum1) AND (v_stgpolnum2 = v_igpolnum1) THEN
        obj_recon_master.status         := 'PASS';
    ELSE
        obj_recon_master.status         := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL2: POLICY COUNT FOR ZSUBCOVDTLS END------------------       

    --------PHPOL3: COUNT INSURED START-------------------------------
    --IG
    SELECT COUNT(*) INTO v_gmh FROM (select /*+ INDEX (GMHDPF IDX1_PA_ITR2_GMHDPF)*/  CHDRNUM, Count (distinct MBRNO) from GMHDPF group by CHDRNUM);

    --STAGING
    SELECT COUNT(*) INTO v_stg1 FROM (select CHDRNUM, Count (distinct MBRNO) from stagedbusr.TITDMGPOLTRNH@DMSTAGEDBLINK  group by CHDRNUM); 
    SELECT COUNT(*) INTO v_stg2 FROM (select REFNUM, Count (distinct MBRNO) from stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK  group by REFNUM);

    --PJ/DM
    SELECT COUNT(*) INTO v_dminsured1  FROM 
        (SELECT SUBSTR(P.APCUCD,1,8), COUNT(DISTINCT SUBSTR(RIS.ISCICD,-2))
            FROM stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK P 
            INNER JOIN persnl_clnt_flg@DMSTGUSR2DBLINK   flg ON flg.apcucd = p.apcucd  AND flg.isa4st IS NOT NULL
                    INNER JOIN zmris00@DMSTGUSR2DBLINK   ris ON ris.iscicd = flg.iscicd
                    LEFT JOIN zmrrpt00@DMSTGUSR2DBLINK     t ON p.apc7cd = t.rptbtcd
            GROUP BY SUBSTR(P.APCUCD,1,8));

    SELECT COUNT(*) INTO v_dminsured2 FROM (SELECT REFNUM, COUNT(DISTINCT MBRNO) from stagedbusr2.TITDMGMBRINDP2@DMSTGUSR2DBLINK group by REFNUM);

    v_cnterr := 0;
    obj_recon_master.recon_query_id     := 'PHPOL3';
    obj_recon_master.group_clause       := 'CHDRNUM, MBRNO';
    obj_recon_master.where_clause       := '';

    OPEN c_insrd_count; 
    LOOP
    FETCH c_insrd_count INTO obj_insrd; 
    EXIT WHEN c_insrd_count%notfound;
        obj_recon_master.ig_value           := obj_insrd.tab_cnt;
        obj_recon_master.validation_type    := 'COUNT ' || obj_insrd.v_tabnm;
        obj_recon_master.query_desc         := 'SOURCE: [ZMRAP00,TITDMGMBRINDP2] , STAGE: [TITDMGPOLTRNH,TITDMGMBRINDP2] , IG: ['|| obj_insrd.v_tabnm || ']' ;

        IF obj_insrd.v_tabnm = 'ZINSDTLSPF' THEN
            obj_recon_master.source_value   := v_dminsured1;
            obj_recon_master.staging_value  := v_stg1;
            IF (v_dminsured1 = obj_insrd.tab_cnt) AND (v_stg1 = obj_insrd.tab_cnt) THEN
                obj_recon_master.status     := 'PASS';
            ELSE
                obj_recon_master.status     := 'FAIL';
                v_cnterr                    := v_cnterr + 1;
            END IF;
        ELSE
            obj_recon_master.source_value   := v_dminsured2;
            obj_recon_master.staging_value  := v_stg2;
            IF (v_dminsured2 = obj_insrd.tab_cnt) AND (v_stg2 = obj_insrd.tab_cnt) THEN
                obj_recon_master.status     := 'PASS';
            ELSE
                obj_recon_master.status     := 'FAIL';
                v_cnterr                    := v_cnterr + 1;
            END IF;
        END IF;

        INSERT INTO RECON_MASTER VALUES obj_recon_master;
    END LOOP;

    obj_recon_master.source_value       := 0;
    obj_recon_master.staging_value      := 0;
    obj_recon_master.ig_value           := v_gmh;
    obj_recon_master.validation_type    := 'IG COUNT';
    obj_recon_master.query_desc         := 'Insured count in (ZINSDTLSPF, GXHIPF, ZTEMPCOVPF) vs. Insured count in GMHDPF';          

    IF (v_cnterr = 0) AND  (v_gmh = v_stg1) THEN
        obj_recon_master.status         := 'PASS';
    ELSE 
        obj_recon_master.status         := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL3: COUNT INSURED END---------------------------------


    --------PHPOL4: COUNT UNNAMED INSURED START-----------------------
    --IG
    SELECT COUNT(*) INTO v_ig_unnmed1 FROM (select CHDRNUM, Count (distinct MBRNO||DPNTNO) from GXHIPF where DPNTNO <> '00' and JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);
    SELECT COUNT(*) INTO v_ig_unnmed2 FROM (select CHDRNUM, Count (distinct MBRNO||DPNTNO) from ZTEMPCOVPF where DPNTNO <> '00' and JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);

    --STAGING
    SELECT COUNT(*) INTO v_stg2 FROM (select REFNUM, Count (distinct MBRNO||DPNTNO) from stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK where DPNTNO <> '00' group by REFNUM);

     --PJ/DM
     SELECT COUNT(*) INTO v_dmunnamed FROM (select REFNUM, Count (distinct MBRNO||DPNTNO) from stagedbusr2.TITDMGMBRINDP2@DMSTGUSR2DBLINK where DPNTNO <> '00' group by REFNUM);

     obj_recon_master.recon_query_id        := 'PHPOL4';        
     obj_recon_master.group_clause          := 'CHDRNUM, MBRNO';
     obj_recon_master.where_clause          := 'DPNTNO <> 00';
     obj_recon_master.source_value          := v_dmunnamed;
     obj_recon_master.staging_value         := v_stg2;
     obj_recon_master.ig_value              := v_ig_unnmed1;
     obj_recon_master.validation_type       := 'COUNT UNNAMED in GXHIPF';
     obj_recon_master.query_desc            := 'OURCE: [TITDMGMBRINDP2] , STAGE: [TITDMGMBRINDP2] , IG: [GXHIPF]';

     IF (v_dmunnamed = v_ig_unnmed1) AND (v_stg2 = v_ig_unnmed1) THEN
        obj_recon_master.status             := 'PASS';
     ELSE
        obj_recon_master.status             := 'FAIL';
     END IF;

     INSERT INTO RECON_MASTER VALUES obj_recon_master;

     obj_recon_master.ig_value              := v_ig_unnmed2;
     obj_recon_master.validation_type       := 'DPNTNO <> 00';
     obj_recon_master.validation_type       := 'COUNT UNNAMED in ZTEMPCOVPF';
     obj_recon_master.query_desc            := 'OURCE: [TITDMGMBRINDP2] , STAGE: [TITDMGMBRINDP2] , IG: [ZTEMPCOVPF]';

     IF (v_dmunnamed = v_ig_unnmed2) AND (v_stg2 = v_ig_unnmed2) THEN
        obj_recon_master.status             := 'PASS';
     ELSE
        obj_recon_master.status             := 'FAIL';
     END IF;

     INSERT INTO RECON_MASTER VALUES obj_recon_master;
     --------PHPOL4: COUNT UNNAMED INSURED END-------------------------

     --------PHPOL5: COUNT PRODTYP START-------------------------------
     --IG
     SELECT COUNT(*) INTO v_ig_prodtyp1 FROM (select CHDRNUM, Count (PRODTYP) from GXHIPF where JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);
     SELECT COUNT(*) INTO v_ig_prodtyp2 FROM (select CHDRNUM, Count (PRODTYP) from ZTEMPCOVPF where JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);

     --STAGING
     SELECT COUNT(*) INTO v_stg2 FROM (select REFNUM, Count (distinct PRODTYP) from stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK group by REFNUM);

     --PJ/DM
     SELECT  COUNT(*) INTO v_dmprodtyp FROM (select substr(P.APCUCD,1,8), count(distinct RIC.ICDMCD) from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK P 
        LEFT OUTER JOIN stagedbusr2.ZMRIC00@DMSTGUSR2DBLINK RIC on SUBSTR(P.APCUCD,1,8) = SUBSTR(RIC.ICCUCD,1,8)
        RIGHT OUTER JOIN stagedbusr2.dpntno_table@DMSTGUSR2DBLINK n on n.chdrnum =  substr(P.APCUCD,1,8) group by substr(P.APCUCD,1,8));

     obj_recon_master.recon_query_id        := 'PHPOL5';
     obj_recon_master.group_clause          := 'CHDRNUM, PRODTYP';
     obj_recon_master.where_clause          := ' ';
     obj_recon_master.source_value          := v_dmprodtyp;
     obj_recon_master.staging_value         := v_stg2;
     obj_recon_master.ig_value              := v_ig_prodtyp1;
     obj_recon_master.validation_type       := 'COUNT PRODTYP in GXHIPF';
     obj_recon_master.query_desc            := 'SOURCE: [ZMRAP00,ZMRIC00] , STAGE: [TITDMGMBRINDP2] , IG: [GXHIPF]';

     IF (v_dmprodtyp = v_ig_prodtyp1) AND (v_stg2 = v_ig_prodtyp1) THEN
        obj_recon_master.status             := 'PASS';
     ELSE
        obj_recon_master.status             := 'FAIL';
     END IF;

     INSERT INTO RECON_MASTER VALUES obj_recon_master;

     obj_recon_master.ig_value              := v_ig_prodtyp2;
     obj_recon_master.validation_type       := 'COUNT PRODTYP in ZTEMPCOVPF';
     obj_recon_master.query_desc            := 'SOURCE: [ZMRAP00,ZMRIC00] , STAGE: [TITDMGMBRINDP2] , IG: [ZTEMPCOVPF]';

     IF (v_dmprodtyp = v_ig_prodtyp2) AND (v_stg2 = v_ig_prodtyp2) THEN
        obj_recon_master.status             := 'PASS';
     ELSE 
        obj_recon_master.status             := 'FAIL';
     END IF;

     INSERT INTO RECON_MASTER VALUES obj_recon_master; 
     --------PHPOL5: COUNT PRODTYP END---------------------------------


    --------PHPOL6: COUNT APIRNO START--------------------------------
    --IG
    SELECT COUNT(*) INTO v_ig_apirno1 FROM (select CHDRNUM, count(*) from ZAPIRNOPF where JOBNM = 'G1ZDAPIRNO' group by CHDRNUM);
    SELECT COUNT(*) INTO v_ig_apirno2 FROM (select CHDRNUM, COUNT(distinct TRIM(MBRNO)|| TRIM(ZINSTYPE)) from GXHIPF where JOBNM = 'G1ZDPOLCOV' group by CHDRNUM);

    --STAGING
    SELECT COUNT(*) INTO v_stg2 FROM (select CHDRNUM, count(*) from stagedbusr.TITDMGAPIRNO@DMSTAGEDBLINK group by CHDRNUM);

    --PJ/DM
    SELECT COUNT(*) INTO v_dmapirno FROM (select CHDRNUM, count(*) from stagedbusr2.TITDMGAPIRNO@DMSTGUSR2DBLINK group by CHDRNUM);

    obj_recon_master.recon_query_id     := 'PHPOL6';
    obj_recon_master.group_clause       := 'CHDRNUM';
    obj_recon_master.where_clause       := ' ';
    obj_recon_master.source_value       := v_dmapirno;
    obj_recon_master.staging_value      := v_stg2;
    obj_recon_master.ig_value           := v_ig_apirno1;
    obj_recon_master.validation_type    := 'COUNT APIRNO ZAPIRNOPF';
    obj_recon_master.query_desc         := 'SOURCE: [TITDMGAPIRNO] , STAGE: [TITDMGAPIRNO] , IG: [ZAPIRNOPF]';

    IF (v_dmapirno = v_ig_apirno1) AND (v_stg2 = v_ig_apirno1) THEN
        obj_recon_master.status         := 'PASS';
    ELSE 
        obj_recon_master.status         := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;

    obj_recon_master.ig_value           := v_ig_apirno2;
    obj_recon_master.validation_type    := 'COUNT APIRNO GXHIPF';
    obj_recon_master.query_desc         := 'SOURCE: [TITDMGAPIRNO] , STAGE: [TITDMGAPIRNO] , IG: [ZTEMPCOVPF]';

    IF (v_dmapirno = v_ig_apirno2) AND (v_stg2 = v_ig_apirno2) THEN
        obj_recon_master.status         := 'PASS';
    ELSE
        obj_recon_master.status         := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL6: COUNT APIRNO END---------------------------------

    --------PHPOL7: COUNT TRANSCTION START---------------------------
    --IG
        --Cursor c_tran_count

    --STAGING
    SELECT COUNT(*) INTO v_stg2 FROM (select CHDRNUM, count(DISTINCT TRANNO) from stagedbusr.TITDMGPOLTRNH@DMSTAGEDBLINK where MBRNO = '00001' and ZINSROLE = 1 group by CHDRNUM);

    --PJ/DM
    SELECT COUNT(*) INTO v_dmgtran FROM (select CHDRNUM, count(DISTINCT ZSEQNO) from stagedbusr2.TITDMGPOLTRNH@DMSTGUSR2DBLINK where MBRNO = '00001' and ZINSROLE = 1 group by CHDRNUM);

    obj_recon_master.recon_query_id     := 'PHPOL7';
    obj_recon_master.group_clause       := 'CHDRNUM, TRANNO';
    obj_recon_master.where_clause       := 'MBRNO = 00001 and ZINSROLE = 1';
    obj_recon_master.source_value       := v_dmgtran;
    obj_recon_master.staging_value      := v_stg2;

    OPEN c_tran_count;
    LOOP
    FETCH c_tran_count INTO obj_tran;
    EXIT WHEN c_tran_count%notfound;
        obj_recon_master.ig_value           := obj_tran.tab_cnt;
        obj_recon_master.validation_type    := 'COUNT TRANNO from ' || obj_tran.v_tabnm;
        obj_recon_master.query_desc         := 'SOURCE: [TITDMGPOLTRNH] , STAGE: [TITDMGPOLTRNH] , IG: ['|| obj_tran.v_tabnm || ']' ;

        IF (v_dmgtran = obj_tran.tab_cnt) AND (v_stg2 = obj_tran.tab_cnt) THEN
            obj_recon_master.status         := 'PASS';
        ELSE
            obj_recon_master.status         := 'FAIL';
        END IF;

        INSERT INTO RECON_MASTER VALUES obj_recon_master;
    END LOOP;
    --------PHPOL7: COUNT TRANSCACTION END----------------------------


    --------PHPOL8: COUNT PolCov Transaction START--------------------
    --IG
    SELECT COUNT(*) INTO v_ig_newbus1 FROM  gxhipf where JOBNM = 'G1ZDPOLCOV';
    SELECT COUNT(*) INTO v_ig_newbus2 FROM  ztempcovpf where dtetrm = 99999999 and JOBNM = 'G1ZDPOLCOV';

    --STAGING
    SELECT COUNT(*) INTO v_stg2 FROM stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK;

    --PJ/DM
    SELECT COUNT(*) INTO v_dmgnewbus FROM stagedbusr2.TITDMGMBRINDP2@DMSTGUSR2DBLINK;

    obj_recon_master.recon_query_id         := 'PHPOL8';
    obj_recon_master.group_clause           := 'CHDRNUM, TRANNO';
    obj_recon_master.where_clause           := ' ';
    obj_recon_master.source_value           := v_dmgnewbus;
    obj_recon_master.staging_value          := v_stg2;
    obj_recon_master.ig_value               := v_ig_newbus1;
    obj_recon_master.validation_type        := 'COUNT Transaction GXHIPF';
    obj_recon_master.query_desc             := 'SOURCE: [ZMRAP00,ZMRIC00,DPNTNO_TABLE] , STAGE: [TITDMGMBRINDP2] , IG: [ZTRAPF]';

    IF (v_dmgnewbus = v_ig_apirno1) AND (v_stg2 = v_ig_apirno1) THEN
    obj_recon_master.status                 := 'PASS';
    ELSE
    obj_recon_master.status                 := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;

    obj_recon_master.ig_value               := v_ig_newbus2;
    obj_recon_master.validation_type        := 'COUNT Transaction ZTEMPCOVPF';
    obj_recon_master.query_desc             := 'SOURCE: [ZMRAP00,ZMRIC00,DPNTNO_TABLE] , STAGE: [TITDMGMBRINDP2] , IG: [ZALTPF]';

    IF (v_dmgnewbus = v_ig_newbus2) AND (v_stg2 = v_ig_newbus2) THEN
        obj_recon_master.status             := 'PASS';
    ELSE
        obj_recon_master.status             := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL8: COUNT PolCov transasction END--------------------


    --------PHPOL9: COUNT CANCELLATION START-------------------------
    --IG
    SELECT COUNT(*) INTO v_ig_cancl FROM  ZTEMPCOVPF where TRANNO <> 1 AND JOBNM = 'G1ZDPOLCOV';
    SELECT COUNT(distinct CHDRNUM) INTO v_ig_cancl FROM  ZTEMPCOVPF where TRANNO <> 1 AND DTETRM <> 99999999 AND JOBNM = 'G1ZDPOLCOV';  

    --STAGING
    SELECT COUNT(distinct CHDRNUM) INTO v_stg2 FROM stagedbusr.TITDMGPOLTRNH@DMSTAGEDBLINK A LEFT OUTER JOIN Jd1dta.ITEMPF B
        ON TRIM(B.ITEMITEM) = TRIM(A.ZALTRCDE01)
        AND TRIM(B.ITEMTABL) = 'TQ9MP'
        AND TRIM(B.ITEMCOY) IN (1, 9) AND TRIM(B.ITEMPFX) = 'IT' AND TRIM(B.VALIDFLAG)= '1'
    WHERE A.ZTRXSTAT = 'AP' AND 
        SUBSTR(UTL_RAW.CAST_TO_VARCHAR2(B.GENAREA),6,4) = 'TERM';

    --PJ/DM
    SELECT COUNT(distinct CHDRNUM) INTO v_dmcancl FROM stagedbusr2.TITDMGPOLTRNH@DMSTGUSR2DBLINK A LEFT OUTER JOIN ITEMPF B
        ON TRIM(B.ITEMITEM) = TRIM(A.ZALTRCDE01)
        AND TRIM(B.ITEMTABL) = 'TQ9MP'
        AND TRIM(B.ITEMCOY) IN (1, 9) AND TRIM(B.ITEMPFX) = 'IT' AND TRIM(B.VALIDFLAG)= '1'
    WHERE A.ZTRXSTAT = 'AP' AND 
        SUBSTR(UTL_RAW.CAST_TO_VARCHAR2(B.GENAREA),6,4) = 'TERM';

    obj_recon_master.recon_query_id         := 'PHPOL9';
    obj_recon_master.group_clause           := 'TRANNO';
    obj_recon_master.where_clause           := 'ZRCALTTY = TERM';
    obj_recon_master.source_value           := v_dmcancl;
    obj_recon_master.staging_value          := v_stg2;
    obj_recon_master.ig_value               := v_ig_cancl;
    obj_recon_master.validation_type        := 'COUNT Cancellation';
    obj_recon_master.query_desc             := 'SOURCE: [TITDMGPOLTRNH] , STAGE: [TITDMGPOLTRNH] , IG: [ZTEMPCOVPF]';

    IF (v_dmcancl = v_ig_cancl) AND (v_stg2 = v_ig_cancl) THEN
        obj_recon_master.status             := 'PASS';
    ELSE
        obj_recon_master.status             := 'FAIL';
    END IF;

    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL9: COUNT CANCELLATION END--------------------------


    --------PHPOL10: COUNT BENEFICIARY START-------------------------
    --IG
    SELECT COUNT(*) INTO v_ig_benf FROM  ZBENFDTLSPF where JOBNM = 'G1ZDPOLHST';

    --STAGING
    SELECT COUNT(trim(B1_ZKNJFULNM)) + COUNT(trim(B2_ZKNJFULNM)) + COUNT(trim(B3_ZKNJFULNM)) + COUNT(trim(B4_ZKNJFULNM)) + COUNT(trim(B5_ZKNJFULNM)) INTO v_stg2 FROM stagedbusr.TITDMGPOLTRNH@DMSTAGEDBLINK
    WHERE TRANNO = 1 OR ZALTRCDE01 = 'N10';

    --PJ/DM
    SELECT COUNT(trim(ris.B1_ZKNJFULNM)) + COUNT(trim(ris.B2_ZKNJFULNM)) + COUNT(trim(ris.B3_ZKNJFULNM)) + COUNT(trim(ris.B4_ZKNJFULNM)) + COUNT(trim(ris.B5_ZKNJFULNM)) INTO v_dmbenf
    FROM stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK P 
        INNER JOIN persnl_clnt_flg@DMSTGUSR2DBLINK   flg ON flg.apcucd = p.apcucd  AND flg.isa4st IS NOT NULL
                INNER JOIN zmris00@DMSTGUSR2DBLINK   ris ON ris.iscicd = flg.iscicd
    WHERE substr(p.APCUCD,9,3) = '000' or p.apdlcd = 'N5';

    obj_recon_master.recon_query_id         := 'PHPOL10';
    obj_recon_master.group_clause           := 'ZKNJFULNM';
    obj_recon_master.where_clause           := ' ';
    obj_recon_master.source_value           := v_dmbenf;
    obj_recon_master.staging_value          := v_stg2;
    obj_recon_master.ig_value               := v_ig_benf;
    obj_recon_master.validation_type        := 'COUNT Beneficiary';
    obj_recon_master.query_desc             := 'SOURCE: [ZMRAP00, ZMRIS00] , STAGE: [TITDMGPOLTRNH] , IG: [ZBENFDTLSPF ]';

    IF (v_dmbenf = v_ig_benf) AND (v_stg2 = v_ig_benf) THEN
        obj_recon_master.status             := 'PASS';
    ELSE
        obj_recon_master.status             := 'FAIL';
    END IF;
    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL10: COUNT BENEFICIARY END--------------------------

   --------PHPOL11: ODM PREMIUM VERSION-------------------------
    --IG
	SELECT count(*) INTO v_ig_odmcnt FROM Jd1dta.zodmprmverpf WHERE JOBNM = 'G1ZDPOLCOV'; 

    --STAGING
	SELECT COUNT(*) INTO v_stg1 FROM (
		SELECT DISTINCT p2.refnum, p2.zinstype from stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK p2 LEFT OUTER JOIN stagedbusr2.maxpolnum@DMSTGUSR2DBLINK mx ON refnum = mx.APCUCD WHERE mx.minapcucd = p2.refnum || p2.zseqno);
    --PJ/DM
	SELECT COUNT(*) INTO v_odmcnt FROM (
		SELECT DISTINCT ric.iccucd, ric.icdmcd from stagedbusr2.zmric00@DMSTGUSR2DBLINK ric LEFT OUTER JOIN stagedbusr2.maxpolnum@DMSTGUSR2DBLINK mx ON substr(ric.iccucd,1,8) = mx.APCUCD WHERE mx.minapcucd = ric.iccucd);

    obj_recon_master.recon_query_id         := 'PHPOL11';
    obj_recon_master.group_clause           := 'ZINSTYPE';
    obj_recon_master.where_clause           := ' ';
    obj_recon_master.source_value           := v_odmcnt;
    obj_recon_master.staging_value          := v_stg1;
    obj_recon_master.ig_value               := v_ig_odmcnt;
    obj_recon_master.validation_type        := 'COUNT ODM VERSION';
    obj_recon_master.query_desc             := 'SOURCE: [ZMRIS00] , STAGE: [TITDMGMBRINDP2] , IG: [ZODMPREMVERPF ]';

    IF (v_odmcnt = v_ig_odmcnt) AND (v_stg1 = v_ig_odmcnt) THEN
        obj_recon_master.status             := 'PASS';
    ELSE
        obj_recon_master.status             := 'FAIL';
    END IF;
    INSERT INTO RECON_MASTER VALUES obj_recon_master;
    --------PHPOL11: ODM PREMIUM VERSION--------------------------

    COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        p_exitcode := SQLCODE;
        p_exittext := ' DMPH- Member and Individual Policy History ' || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
        raise_application_error(-20001, p_exitcode || p_exittext);
END recon_g1zdpolhst;