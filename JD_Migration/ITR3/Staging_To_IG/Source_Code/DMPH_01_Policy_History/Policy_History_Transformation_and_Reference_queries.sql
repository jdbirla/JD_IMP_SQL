----------------------------------
-------TRANSFORMATION Queries-----
----------------------------------
--- T2_1---
SELECT
      inf.RECIDXMBINDP2
     ,inf.REFNUM
     ,inf.MBRNO
     ,inf.EFFDATE
     ,inf.TRANNO
     ,inf.APREM
     ,inf.RIPROCDT
FROM
    ( 
     SELECT
           inf01.RECIDXMBINDP2
          ,inf01.REFNUM
          ,inf01.MBRNO
          ,inf01.EFFDATE
          ,inf01.TRANNO
          ,inf01.APREM
          ,CASE gchd.STATCODE
                WHEN 'CA' THEN 99999999
                ELSE 0
           END RIPROCDT
     FROM
           Jd1dta.DMIGTITDMGMBRINDP2 inf01
     LEFT JOIN
           Jd1dta.GCHD gchd
     ON
         TRIM(inf01.REFNUM) = TRIM(gchd.CHDRNUM)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.GXHIPF gxhipf
      WHERE
          TRIM(inf.REFNUM) = TRIM(gxhipf.CHDRNUM)
      AND TRIM(inf.MBRNO) =  TRIM(gxhipf.MBRNO)
      AND TRIM(inf.EFFDATE) =  TRIM(gxhipf.DTEATT)
      AND TRIM(inf.EFFDATE) =  TRIM(gxhipf.APRVDATE)
      AND TRIM(inf.TRANNO) =  TRIM(gxhipf.TRANNO)
      AND TRIM(inf.APREM) =  TRIM(gxhipf.DPREM)
      AND TRIM(inf.RIPROCDT) =  TRIM(gxhipf.RIPROCDT)
      ) 
;

--- T2_2---
SELECT
      inf.RECIDXMBINDP2   inf_RECIDXMBINDP2
     ,inf.REFNUM          inf_REFNUM
     ,inf.ZINSTYPE        inf_ZINSTYPE
     ,verf.verno          verf_verno
FROM
      (
        SELECT
              i01.* 
        FROM
              Jd1dta.DMIGTITDMGMBRINDP2 i01
        INNER JOIN
             (
              SELECT
                   REFNUM
                  ,MAX(EFFDATE) MAX_EFFDATE
              FROM
                   Jd1dta.DMIGTITDMGMBRINDP2
              GROUP BY
                   REFNUM
             ) i02
        ON 
             TRIM(i01.REFNUM)  = TRIM(i02.REFNUM)
        AND  TRIM(i01.EFFDATE) = TRIM(i02.MAX_EFFDATE)
      ) inf
LEFT JOIN Jd1dta.DMIGODMVERSIONHIS verf
ON 
    TRIM(inf.ZINSTYPE) = TRIM(verf.ZINSTYPE)
AND TRIM(inf.EFFDATE) BETWEEN TRIM(verf.frmdte) AND TRIM(verf.todte)
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZODMPRMVERPF zodmprmverpf
      WHERE
          TRIM(inf.REFNUM) = TRIM(zodmprmverpf.CHDRNUM)
      AND TRIM(inf.ZINSTYPE) =  TRIM(zodmprmverpf.ZINSTYPE)
      AND TRIM(verf.verno) =  TRIM(zodmprmverpf.ZODMPRMVER)
      ) 
;

--- T2_3---
SELECT
      inf.RECIDXMBINDP2   inf_RECIDXMBINDP2
     ,inf.REFNUM          inf_REFNUM
     ,inf.MBRNO           inf_MBRNO
FROM
      Jd1dta.DMIGTITDMGMBRINDP2 inf 
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZSUBCOVDTLS zsubcovdtls
      WHERE
          TRIM(inf.REFNUM) = TRIM(zsubcovdtls.CHDRNUM)
      AND TRIM(inf.MBRNO) =  TRIM(zsubcovdtls.MBRNO)
      AND inf.tranno =  TRIM(zsubcovdtls.TRANNO)
      ) 
AND TRIM(inf.NDRPREM) > 0
;

--- T2_4---
SELECT
      inf.RECIDXMBINDP2
     ,inf.REFNUM
     ,inf.TRANNO
     ,inf.MBRNO
     ,inf.DPNTNO
     ,inf.APREM
     ,inf.ZINSROLE
FROM
    (
     SELECT
           inf01.RECIDXMBINDP2
          ,inf01.REFNUM 
          ,inf01.TRANNO
          ,inf01.MBRNO
          ,inf01.DPNTNO
          ,inf01.APREM
          ,CASE 
                WHEN zins.ZINSROLE IS NULL THEN
                              CASE TRIM(inf01.DPNTNO)
                                   WHEN '00' THEN '1'
                                   WHEN '01' THEN '2'
                                   WHEN '02' THEN '3'
                              END
                ELSE zins.ZINSROLE
           END ZINSROLE
     FROM
           Jd1dta.DMIGTITDMGMBRINDP2 inf01
     LEFT JOIN
         (
          SELECT DISTINCT
                CHDRNUM
               ,MBRNO
               ,DPNTNO
               ,ZINSROLE
          FROM
                Jd1dta.ZINSDTLSPF
          ) zins
     ON
         TRIM(inf01.REFNUM) = TRIM(zins.CHDRNUM)
     AND TRIM(inf01.MBRNO) = TRIM(zins.MBRNO)
     AND TRIM(inf01.DPNTNO) = TRIM(zins.DPNTNO)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZTEMPCOVPF ztempcovpf
      WHERE
          TRIM(inf.REFNUM) = TRIM(ztempcovpf.CHDRNUM)
      AND TRIM(inf.TRANNO) =  TRIM(ztempcovpf.TRANNO)
      AND TRIM(inf.MBRNO) =  TRIM(ztempcovpf.MBRNO)
      AND TRIM(inf.DPNTNO) =  TRIM(ztempcovpf.DPNTNO)
      AND TRIM(inf.APREM) =  TRIM(ztempcovpf.DPREM)
      AND TRIM(inf.ZINSROLE) =  TRIM(ztempcovpf.ZINSROLE)
      ) 
;
--- T3_1---
SELECT
      inf.RECIDXPHIST     inf_RECIDXPHIST
     ,inf.CHDRNUM         inf_CHDRNUM
     ,inf.TRANNO        inf_TRANNO
     ,inf.ZSALECHNL        inf_ZSALECHNL
     ,inf.ZSOLCTFLG     inf_ZSOLCTFLG
     ,inf.ZENSPCD01         inf_ZENSPCD01
     ,inf.CURRTO        inf_CURRTO
     ,inf.BANKACCDSC01    inf_BANKACCDSC01
FROM
      Jd1dta.DMIGTITDMGPOLTRNH inf 
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZALTPF zaltpf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)     ,null,' ',TRIM(inf.CHDRNUM))           =  DECODE(TRIM(zaltpf.CHDRNUM),null,' ',TRIM(zaltpf.CHDRNUM))
      AND DECODE(TRIM(inf.TRANNO)    ,null,' ',TRIM(inf.TRANNO))         =  DECODE(TRIM(zaltpf.TRANNO),null,' ',TRIM(zaltpf.TRANNO))
      AND DECODE(TRIM(inf.ZSALECHNL)    ,null,' ',TRIM(inf.ZSALECHNL))         =  DECODE(TRIM(zaltpf.ZSALECHNL),null,' ',TRIM(zaltpf.ZSALECHNL))
      AND DECODE(TRIM(inf.ZSOLCTFLG) ,null,' ',TRIM(inf.ZSOLCTFLG))   =  DECODE(TRIM(zaltpf.ZSOLCTFLG),null,' ',TRIM(zaltpf.ZSOLCTFLG))
      AND DECODE(TRIM(inf.ZENSPCD01)     ,null,' ',TRIM(inf.ZENSPCD01))           =  DECODE(TRIM(zaltpf.ZENSPCD01),null,' ',TRIM(zaltpf.ZENSPCD01))
      AND DECODE(TRIM(inf.CURRTO), 99999999, 0, SUBSTR(TRIM(inf.CURRTO),5,2))       =  DECODE(TRIM(zaltpf.MTHTO),null,' ',TRIM(zaltpf.MTHTO))
      AND DECODE(TRIM(inf.CURRTO), 99999999, 0, SUBSTR(TRIM(inf.CURRTO),3,2)) =  DECODE(TRIM(zaltpf.YEARTO),null,' ',TRIM(zaltpf.YEARTO))
      ) 
AND  (inf.MBRNO = '00001') AND (inf.ZINSROLE = 1)
;
select * from Jd1dta.zaltpf where chdrnum = '00027359';
--- T3_2---
SELECT
      inf.RECIDXPHIST     inf_RECIDXPHIST
     ,inf.MBRNO         inf_MBRNO
     ,inf.chdrnum       inf_chdrnum
     ,inf.TRANNO        inf_TRANNO
FROM
      Jd1dta.DMIGTITDMGPOLTRNH inf 
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZBENFDTLSPF zbenfdtlspf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)     ,null,' ',TRIM(inf.CHDRNUM))           =  DECODE(TRIM(zbenfdtlspf.CHDRNUM),null,' ',TRIM(zbenfdtlspf.CHDRNUM))
      AND DECODE(TRIM(inf.MBRNO)    ,null,' ',TRIM(inf.MBRNO))         =  DECODE(TRIM(zbenfdtlspf.MBRNO),null,' ',TRIM(zbenfdtlspf.MBRNO))
      AND DECODE(TRIM(inf.TRANNO)    ,null,' ',TRIM(inf.TRANNO))         =  DECODE(TRIM(zbenfdtlspf.TRANNO),null,' ',TRIM(zbenfdtlspf.TRANNO))
      ) 
AND  (TRANNO = 1 OR ZALTRCDE01 = 'N10')
;

--- T3_3---
SELECT
      inf.RECIDXPHIST
     ,inf.CHDRNUM
     ,inf.MBRNO
     ,inf.ZORIGSALP
     ,inf.TRANNO
     ,inf.UNIQUE_NUMBER_02
     ,inf.ZINSDTHD
FROM
    (
     SELECT
           inf01.RECIDXPHIST
          ,inf01.CHDRNUM
          ,inf01.MBRNO
          ,inf01.TRANNO
          ,inf01.ZSEQNO
          ,inf01.PRE_ZSEQNO
          ,inf01.EFFDATE
          ,inf01.ZPLANCDE
          ,inf02.ZORIGSALP
          ,gchd.UNIQUE_NUMBER UNIQUE_NUMBER_02
          ,CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) --ZRCALTTY
                WHEN 'TERM' THEN
                            CASE
                                WHEN (TRIM(inf01.zaltrcde01) IN ('ZD1', 'ZD3')) AND (inf01.ZINSROLE = 1)  THEN inf01.EFFDATE
                                WHEN (TRIM(inf01.zaltrcde01) IN ('ZD2'))                                THEN inf01.EFFDATE
                                WHEN (TRIM(inf01.zaltrcde01) IN ('ZD4', 'DM3')) AND (inf01.ZINSROLE <> 1) THEN inf01.EFFDATE
                                ELSE 99999999
                            END
                ELSE 99999999
           END ZINSDTHD
     FROM
          (
           SELECT
                 RECIDXPHIST
                ,CHDRNUM
                ,EFFDATE
                ,ZALTREGDAT
                ,MBRNO
                ,TRANNO
                ,ZSEQNO
                ,CASE SUBSTR(ZSEQNO,1,2)
                      WHEN '00' THEN SUBSTR(ZSEQNO,1,2) || '0'
                      ELSE LPAD(TO_NUMBER(SUBSTR(ZSEQNO,1,2)) - 1,2,'0') || '0'
                 END PRE_ZSEQNO
                ,ZPLANCDE
                ,zaltrcde01
                ,ZINSROLE
           FROM
                Jd1dta.DMIGTITDMGPOLTRNH inf01
          ) inf01
     INNER JOIN
          (
           SELECT
                 RECIDXPHIST
                ,CHDRNUM
                ,MBRNO
                ,TRANNO
                ,ZSEQNO
                ,SUBSTR(ZSEQNO,1,2) || '0' ZSEQNO2
                ,EFFDATE
                ,ZPLANCDE  ZORIGSALP
           FROM
                Jd1dta.DMIGTITDMGPOLTRNH
           WHERE
                SUBSTR(ZSEQNO,-1) = '0'
                
          ) inf02
     ON 
         TRIM(inf01.CHDRNUM) = TRIM(inf02.CHDRNUM)
     AND TRIM(inf01.MBRNO) = TRIM(inf02.MBRNO)
     AND TRIM(inf01.PRE_ZSEQNO) = TRIM(inf02.ZSEQNO2)
     LEFT JOIN
         (
          SELECT
                gchd.CHDRNUM
               ,gchd.COWNNUM
               ,zclnpf.EFFDATE
               ,zclnpf.UNIQUE_NUMBER
          FROM
                Jd1dta.GCHD gchd
          INNER JOIN
                Jd1dta.ZCLNPF zclnpf
          ON
                TRIM(gchd.COWNNUM) = TRIM(zclnpf.CLNTNUM)
          WHERE
                gchd.CHDRNUM <> gchd.MPLNUM
         ) gchd
     ON
         TRIM(inf01.CHDRNUM) = TRIM(gchd.CHDRNUM)
     AND TRIM(gchd.EFFDATE) <=
         CASE
             WHEN inf01.effdate < inf01.zaltregdat THEN inf01.zaltregdat
             ELSE inf01.effdate
         END
     AND ROWNUM = 1
     LEFT OUTER JOIN 
          Jd1dta.ITEMPF C 
     ON
          TRIM(C.ITEMITEM)=TRIM(inf01.ZALTRCDE01)
     AND  TRIM(C.ITEMTABL) = 'TQ9MP' 
     AND TRIM(C.ITEMCOY) IN (1, 9)
     AND TRIM(C.ITEMPFX) = 'IT'
     AND TRIM(C.VALIDFLAG)= '1'
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZINSDTLSPF zinsdtlspf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)   ,null,' ',TRIM(inf.CHDRNUM))    =  DECODE(TRIM(zinsdtlspf.CHDRNUM)   ,null,' ',TRIM(zinsdtlspf.CHDRNUM))
      AND DECODE(TRIM(inf.MBRNO)   ,null,' ',TRIM(inf.MBRNO))    =  DECODE(TRIM(zinsdtlspf.MBRNO)   ,null,' ',TRIM(zinsdtlspf.MBRNO))
      AND DECODE(TRIM(inf.EFFDATE)   ,null,' ',TRIM(inf.EFFDATE))    =  DECODE(TRIM(zinsdtlspf.EFFDATE)   ,null,' ',TRIM(zinsdtlspf.EFFDATE))
      AND DECODE(TRIM(inf.ZORIGSALP),null,' ',TRIM(inf.ZORIGSALP)) =  DECODE(TRIM(zinsdtlspf.ZORIGSALP),null,' ',TRIM(zinsdtlspf.ZORIGSALP))
      AND DECODE(TRIM(inf.TRANNO),null,' ',TRIM(inf.TRANNO)) =  DECODE(TRIM(zinsdtlspf.TRANNO),null,' ',TRIM(zinsdtlspf.TRANNO))
      AND DECODE(TRIM(inf.UNIQUE_NUMBER_02),null,' ',TRIM(inf.UNIQUE_NUMBER_02)) =  DECODE(TRIM(zinsdtlspf.UNIQUE_NUMBER_02),null,' ',TRIM(zinsdtlspf.UNIQUE_NUMBER_02))
      AND DECODE(TRIM(inf.ZINSDTHD),null,' ',TRIM(inf.ZINSDTHD)) =  DECODE(TRIM(zinsdtlspf.ZINSDTHD),null,' ',TRIM(zinsdtlspf.ZINSDTHD))
      ) 
;

---T3_4----
SELECT
      inf.RECIDXPHIST     inf_RECIDXPHIST
     ,inf.CHDRNUM         inf_CHDRNUM
     ,inf.TRANNO         inf_TRANNO
     ,inf.ZENSPCD01         inf_ZENSPCD01
     ,inf.ZENSPCD02      inf_ZENSPCD02
     ,inf.CRDTCARD        inf_CRDTCARD
     ,inf.BNKACCKEY01         inf_BNKACCKEY01
     ,inf.BANKACCDSC01        inf_BANKACCDSC01
     ,inf.CURRTO           inf_CURRTO
FROM
      Jd1dta.DMIGTITDMGPOLTRNH inf 
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZMCIPF zmcipf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)   ,null,' ',TRIM(inf.CHDRNUM))    =  DECODE(TRIM(zmcipf.CHDRNUM)   ,null,' ',TRIM(zmcipf.CHDRNUM))
     AND DECODE(TRIM(inf.TRANNO)   ,null,' ',TRIM(inf.TRANNO))    =  DECODE(TRIM(zmcipf.TRANNO)   ,null,' ',TRIM(zmcipf.TRANNO))
     AND DECODE(TRIM(inf.ZENSPCD01)   ,null,' ',TRIM(inf.ZENSPCD01))    =  DECODE(TRIM(zmcipf.ZENSPCD01)   ,null,' ',TRIM(zmcipf.ZENSPCD01))
     AND DECODE(TRIM(inf.ZENSPCD02),null,' ',TRIM(inf.ZENSPCD02)) =  DECODE(TRIM(zmcipf.ZENSPCD02),null,' ',TRIM(zmcipf.ZENSPCD02))
     AND DECODE(TRIM(inf.CRDTCARD)  ,null,' ',TRIM(inf.CRDTCARD))   =  DECODE(TRIM(zmcipf.CRDTCARD)  ,null,' ',TRIM(zmcipf.CRDTCARD))
     AND DECODE(TRIM(inf.BNKACCKEY01)   ,null,' ',TRIM(inf.BNKACCKEY01))    =  DECODE(TRIM(zmcipf.BANKACCKEY01)   ,null,' ',TRIM(zmcipf.BANKACCKEY01))
     AND DECODE(TRIM(inf.BANKACCDSC01)  ,null,' ',TRIM(inf.BANKACCDSC01))   =  DECODE(TRIM(zmcipf.BANKACCDSC01)  ,null,' ',TRIM(zmcipf.BANKACCDSC01))
     AND DECODE(inf.CURRTO  ,99999999,0,SUBSTR(TRIM(inf.CURRTO),5,2))   =  DECODE(TRIM(zmcipf.MTHTO)  ,null,' ',TRIM(zmcipf.MTHTO))
     AND DECODE(inf.CURRTO  ,99999999,0,SUBSTR(TRIM(inf.CURRTO),3,2))   =  DECODE(TRIM(zmcipf.YEARTO)  ,null,' ',TRIM(zmcipf.YEARTO))
      )AND
  (TRIM(inf.mbrno) = '00001') and (inf.zinsrole = 1) AND (TRIM(inf.trancde) in ('T902', 'T928')
    AND
   (
     (TRIM(inf.zenspcd01) IS NOT NULL) OR
     (TRIM(inf.zenspcd02) IS NOT NULL) OR
     (TRIM(inf.crdtcard)  IS NOT NULL) OR
     (TRIM(inf.bnkacckey01) IS NOT NULL) OR 
     (TRIM(inf.zddreqno)  IS NOT NULL) OR
     (TRIM(inf.zcifcode)  IS NOT NULL)
    )
  ) 
OR
  (TRIM(inf.zaltrcde01) = 'M04')
OR 
  (TRIM(inf.zaltrcde01) = 'M01')
OR 
  (TRIM(inf.zaltrcde01) = 'M02')
;
---T3_5--------@@@×TRANCDE:MSD(Direct)とコード(TRANNO、解約を判断して'T902','T912'をセットしている)が異なっているので、不一致となる。このSQLはMSDに準じている
--------------------ZPDATATXDAT:上記のTRANCDEが不一致になるので、TRANCDEを判断して編集しているこの項目も不一致になる。
SELECT
      inf.RECIDXPHIST
     ,inf.CHDRNUM
     ,inf.EFFDATE
     ,inf.TRANNO
     ,inf.TRANCDE
     ,inf.ZALTRCDE01
     ,inf.ZPDATATXDAT
     ,inf.EFDATE
     ,inf.ZLOGALTDT
     ,inf.ZFINANCFLG
     ,inf.STATCODE
FROM
    (
     SELECT
           inf01.RECIDXPHIST
          ,inf01.CHDRNUM
          ,inf01.EFFDATE
          ,inf01.TRANNO
          ,inf01.TRANCDE
          ,inf01.ZALTRCDE01
          ,inf01.ZINSROLE
          ,inf01.MBRNO
          ,gchppf.ZPDATATXDAT
          ,CASE inf01.TRANNO
                WHEN 1 THEN inf01.EFFDATE
                ELSE
                     CASE
                          WHEN substr(gchipf.CCDATE, 7, 8) = substr(inf01.EFFDATE, 7, 8) THEN inf01.EFFDATE
                          ELSE TO_NUMBER(SUBSTR(inf01.EFFDATE,1,6) || substr(gchipf.CCDATE, 7, 8))
                     END
           END EFDATE
          ,CASE inf01.TRANNO
                WHEN 1 THEN 99999999
                ELSE
                     CASE
                          WHEN inf01.EFFDATE >= NVL(inf01.BTDATE,0) THEN
                                                                     CASE
                                                                          WHEN substr(gchipf.CCDATE, 7, 8) = substr(inf01.EFFDATE, 7, 8) THEN inf01.EFFDATE
                                                                          ELSE TO_NUMBER(SUBSTR(inf01.EFFDATE,1,6) || substr(gchipf.CCDATE, 7, 8))
                                                                     END
                          ELSE TO_NUMBER(TO_CHAR(TO_DATE(inf01.BTDATE, 'yyyymmdd') + 1, 'yyyymmdd'))
                     END
           END ZLOGALTDT
          ,CASE inf01.TRANNO
                WHEN 1 THEN 'Y'
                ELSE
                     CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) --ZRCALTTY
                          WHEN 'TERM' THEN 'Y'
                         ELSE 'N'
                     END
           END ZFINANCFLG
          ,CASE inf01.TRANNO
                WHEN 1 THEN DECODE(gchd.STATCODE,'CA','IF',gchd.STATCODE)
                ELSE
                     CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) --ZRCALTTY
                          WHEN 'TERM' THEN 'CA'
                          ELSE gchd.STATCODE
                     END
           END STATCODE
          ,B.TRANNO            CC_tranno
          ,B.EFFDATE           B_EFFDATE
          ,gchipf.CCDATE       gchipf_CCDATE
     FROM
           Jd1dta.DMIGTITDMGPOLTRNH inf01
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,CASE zplancls
                     WHEN 'FP'  THEN 99999999
                END ZPDATATXDAT
          FROM
                Jd1dta.GCHPPF
          WHERE
                TRIM(CHDRCOY) IN (1, 9)
          ) gchppf
     ON  TRIM(inf01.CHDRNUM) = TRIM(gchppf.CHDRNUM)
     LEFT JOIN 
         (
          SELECT
                CHDRNUM
               ,EFFDATE
               ,ZSEQNO
               ,MBRNO
               ,TRANNO
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH
          WHERE
               substr(ZSEQNO,-1) = '0' 
         ) B
     ON   TRIM(inf01.CHDRNUM) = TRIM(B.CHDRNUM)
     AND  TRIM(inf01.MBRNO) = TRIM(B.MBRNO)
     AND  SUBSTR(TRIM(inf01.ZSEQNO),1,2) = SUBSTR(TRIM(B.ZSEQNO),1,2)
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,CCDATE
               ,TRANNO
               ,ZPOLPERD
          FROM
               Jd1dta.GCHIPF
         ) gchipf
     ON
         TRIM(inf01.CHDRNUM) = TRIM(gchipf.CHDRNUM)
     AND TRIM(B.EFFDATE) = TRIM(gchipf.CCDATE)
     AND TRIM(B.TRANNO) = TRIM(gchipf.TRANNO)
     LEFT OUTER JOIN 
          Jd1dta.ITEMPF C 
     ON
          TRIM(C.ITEMITEM)=TRIM(inf01.ZALTRCDE01)
     AND  TRIM(C.ITEMTABL) = 'TQ9MP' 
     AND TRIM(C.ITEMCOY) IN (1, 9)
     AND TRIM(C.ITEMPFX) = 'IT'
     AND TRIM(C.VALIDFLAG)= '1'
     LEFT JOIN
         Jd1dta.GCHD gchd
     ON TRIM(inf01.CHDRNUM) = TRIM(gchd.CHDRNUM)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZTRAPF ztrapf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)     ,null,' ',TRIM(inf.CHDRNUM))     =  DECODE(TRIM(ztrapf.CHDRNUM)     ,null,' ',TRIM(ztrapf.CHDRNUM))
      AND DECODE(TRIM(inf.EFFDATE)     ,null,' ',TRIM(inf.EFFDATE))     =  DECODE(TRIM(ztrapf.EFFDATE)     ,null,' ',TRIM(ztrapf.EFFDATE))
      AND DECODE(TRIM(inf.TRANNO)  ,null,' ',TRIM(inf.TRANNO))  =  DECODE(TRIM(ztrapf.TRANNO)  ,null,' ',TRIM(ztrapf.TRANNO))
      AND DECODE(TRIM(inf.TRANCDE)    ,null,' ',TRIM(inf.TRANCDE))    =  DECODE(TRIM(ztrapf.TRANCDE)    ,null,' ',TRIM(ztrapf.TRANCDE))
      AND DECODE(TRIM(inf.ZALTRCDE01)    ,null,' ',TRIM(inf.ZALTRCDE01))    =  DECODE(TRIM(ztrapf.ZALTRCDE01)    ,null,' ',TRIM(ztrapf.ZALTRCDE01))
      --AND DECODE(TRIM(inf.ZPDATATXDAT)    ,null,' ',TRIM(inf.ZPDATATXDAT))    =  DECODE(TRIM(ztrapf.ZPDATATXDAT)    ,null,' ',TRIM(ztrapf.ZPDATATXDAT))
      --AND DECODE(TRIM(inf.EFDATE)    ,null,' ',TRIM(inf.EFDATE))    =  DECODE(TRIM(ztrapf.EFDATE)    ,null,' ',TRIM(ztrapf.EFDATE))
      --AND DECODE(TRIM(inf.ZLOGALTDT)    ,null,' ',TRIM(inf.ZLOGALTDT))    =  DECODE(TRIM(ztrapf.ZLOGALTDT)    ,null,' ',TRIM(ztrapf.ZLOGALTDT))
      --AND DECODE(TRIM(inf.ZFINANCFLG)    ,null,' ',TRIM(inf.ZFINANCFLG))    =  DECODE(TRIM(ztrapf.ZFINANCFLG)    ,null,' ',TRIM(ztrapf.ZFINANCFLG))
      AND DECODE(TRIM(inf.STATCODE)    ,null,' ',TRIM(inf.STATCODE))    =  DECODE(TRIM(ztrapf.STATCODE)    ,null,' ',TRIM(ztrapf.STATCODE))
      ) 
AND  (inf.MBRNO = '00001') AND (inf.ZINSROLE = 1)
;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------
-------REFERENCE Queries----------
----------------------------------
--- R1_1---
SELECT
      inf.RECIDXAPIRNO     inf_RECIDXAPIRNO
     ,inf.CHDRNUM          inf_CHDRNUM
     ,inf.MBRNO            inf_MBRNO
     ,gmhdpf.dteatt        gmhdpf_dteatt
FROM
      Jd1dta.DMIGTITDMGAPIRNO inf
LEFT JOIN Jd1dta.GMHDPF gmhdpf
ON
    inf.chdrnum = gmhdpf.chdrnum
AND inf.mbrno = gmhdpf.mbrno
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZAPIRNOPF zapirnopf
      WHERE
          TRIM(inf.CHDRNUM)   = TRIM(zapirnopf.CHDRNUM)
      AND TRIM(inf.MBRNO)    =  TRIM(zapirnopf.MBRNO)
      AND TRIM(gmhdpf.dteatt) =  TRIM(zapirnopf.EFFDATE)
      ) 
;      

--- R2_1---
SELECT
      inf.RECIDXMBINDP2,
      inf.refnum
     ,inf.DTETRM
FROM
    (
     SELECT
           inf02.inf01_RECIDXMBINDP2   RECIDXMBINDP2
          ,inf02.inf01_REFNUM          REFNUM
          ,inf02.inf01_MBRNO           MBRNO
          ,inf02.inf01_PRODTYP         PRODTYP
          ,inf02.inf01_EFFDATE         EFFDATE
          ,CASE inf02.gchd_STATCODE
                WHEN 'CA' THEN
                          CASE
                              WHEN inf02.gchd_effdcldt <= inf02.gchipf_crdate THEN inf02.gchd_effdcldt
                              WHEN inf02.gchipf_period = 1 THEN inf02.gchipf_crdate1
                              ELSE inf02.gchipf_ccdate
                          END
                ELSE
                    CASE
                         WHEN inf02.gchipf_max_period > 1 AND inf02.gchipf_period = 1 THEN inf02.gchipf_crdate1
                         ELSE 99999999
                    END
           END DTETRM
     FROM
          (
           SELECT
                 inf01.RECIDXMBINDP2   inf01_RECIDXMBINDP2
                ,inf01.REFNUM          inf01_REFNUM
                ,inf01.MBRNO           inf01_MBRNO
                ,inf01.PRODTYP           inf01_PRODTYP
                ,inf01.EFFDATE         inf01_EFFDATE
                ,gchd.STATCODE       gchd_STATCODE 
                ,gchd.effdcldt       gchd_effdcldt
                ,gchipf.ccdate       gchipf_ccdate
                ,gchipf.crdate       gchipf_crdate
                ,TO_NUMBER(TO_CHAR(TO_DATE(TRIM(gchipf.crdate),'YYYYMMDD') + 1,'YYYYMMDD')) gchipf_crdate1
                ,gchipf.period       gchipf_period
                ,gchipf.max_period   gchipf_max_period
           FROM
                 Jd1dta.DMIGTITDMGMBRINDP2 inf01
           LEFT JOIN
                 Jd1dta.GCHD gchd
           ON
                TRIM(gchd.chdrnum) = TRIM(inf01.REFNUM)
           AND  gchd.chdrnum <> gchd.mplnum
           LEFT JOIN
               (
                 SELECT DISTINCT
                        gchipf01.CHDRNUM
                       ,gchipf01.CCDATE
                       ,gchipf01.CRDATE
                       ,ROW_NUMBER() OVER(PARTITION BY gchipf01.chdrnum ORDER BY gchipf01.chdrnum,gchipf01.ccdate) AS period
                       ,gchipf02.max_period
                 FROM
                        Jd1dta.GCHIPF gchipf01
                 INNER JOIN
                      (
                       SELECT
                             CHDRNUM
                            ,COUNT(*) max_period
                       FROM
                           (
                            SELECT DISTINCT
                                   CHDRNUM
                                  ,CCDATE
                            FROM
                                   Jd1dta.GCHIPF
                           ) 
                       GROUP BY
                            CHDRNUM
                       ) gchipf02
                 ON 
                     TRIM(gchipf01.CHDRNUM) = TRIM(gchipf02.CHDRNUM)
               ) gchipf
           ON
               TRIM(inf01.REFNUM) = TRIM(gchipf.CHDRNUM)
           AND TRIM(inf01.EFFDATE) BETWEEN TRIM(gchipf.CCDATE) AND TRIM(gchipf.CRDATE)
          ) inf02
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.GXHIPF gxhipf
      WHERE
          TRIM(inf.REFNUM) = TRIM(gxhipf.CHDRNUM)
      AND TRIM(inf.MBRNO) =  TRIM(gxhipf.MBRNO)
      AND TRIM(inf.PRODTYP) =  TRIM(gxhipf.PRODTYP)
      AND TRIM(inf.EFFDATE) =  TRIM(gxhipf.EFFDATE)
      AND TRIM(inf.DTETRM) =  TRIM(gxhipf.DTETRM)
      AND TRIM(inf.DTETRM) =  TRIM(gxhipf.ACCPTDTE)
      ) 
;

--- R2_2---
SELECT
      inf.inf01_RECIDXMBINDP2  inf_RECIDXMBINDP2
     ,inf.inf01_REFNUM         inf_REFNUM
     ,inf.inf01_EFFDATE        inf_EFFDATE
     ,inf.gchipf_CCDATE        inf_CCDATE
     ,inf.gchipf_CRDATE        inf_CRDATE
FROM
    (
     SELECT
           inf01.RECIDXMBINDP2   inf01_RECIDXMBINDP2
          ,inf01.REFNUM          inf01_REFNUM
          ,inf01.EFFDATE         inf01_EFFDATE
          ,gchipf.CCDATE         gchipf_CCDATE
          ,gchipf.CRDATE         gchipf_CRDATE
     FROM
           (
             SELECT
                   i01.* 
             FROM
                   Jd1dta.DMIGTITDMGMBRINDP2 i01
             INNER JOIN
                  (
                   SELECT
                        REFNUM
                       ,MAX(EFFDATE) MAX_EFFDATE
                   FROM
                        Jd1dta.DMIGTITDMGMBRINDP2
                   GROUP BY
                        REFNUM
                  ) i02
             ON 
                  TRIM(i01.REFNUM)  = TRIM(i02.REFNUM)
             AND  TRIM(i01.EFFDATE) = TRIM(i02.MAX_EFFDATE)
           ) inf01 
     LEFT JOIN
         (
          SELECT DISTINCT
                 CHDRNUM
                ,CCDATE
                ,CRDATE
          FROM
                GCHIPF
         ) gchipf
     ON
         TRIM(inf01.REFNUM) = TRIM(gchipf.CHDRNUM)
     AND TRIM(inf01.EFFDATE) BETWEEN TRIM(gchipf.CCDATE) AND TRIM(gchipf.CRDATE) 
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZODMPRMVERPF zodmprmverpf
      WHERE
          TRIM(inf.inf01_REFNUM) = TRIM(zodmprmverpf.CHDRNUM)
      AND TRIM(inf.gchipf_CCDATE) =  TRIM(zodmprmverpf.CCDATE)
      AND TRIM(inf.gchipf_CRDATE) =  TRIM(zodmprmverpf.CRDATE)
      ) 
;

--- R2_3--- @@@×ZTRXSTSIND:MSDとコードが異なっているので、不一致となる。このSQLはMSDに準じている
SELECT
      inf.inf01_RECIDXMBINDP2  inf_RECIDXMBINDP2
     ,inf.inf01_REFNUM         inf_REFNUM
     ,inf.inf01_MBRNO          inf_MBRNO
     ,inf.inf01_EFFDATE        inf_EFFDATE
     ,inf.inf01_TRANNO         inf_TRANNO
     ,inf.inf01_ZTRXSTSIND     inf_ZTRXSTSIND
FROM
    (
     SELECT
           inf01.RECIDXMBINDP2   inf01_RECIDXMBINDP2
          ,inf01.EFFDATE         inf01_EFFDATE
          ,inf01.REFNUM          inf01_REFNUM
          ,inf01.MBRNO           inf01_MBRNO
          ,inf01.TRANNO          inf01_TRANNO
          ,inf01.NDRPREM         inf01_NDRPREM
          ,CASE  ztrapf.ZTRXSTAT
                 WHEN 'AP' THEN '1'
                 WHEN 'RJ' THEN '4'
           END inf01_ZTRXSTSIND
     FROM
           Jd1dta.DMIGTITDMGMBRINDP2 inf01
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,TRANNO
               ,ZTRXSTAT
          FROM
                Jd1dta.ZTRAPF
         ) ztrapf
     ON
         TRIM(inf01.REFNUM) = TRIM(ztrapf.CHDRNUM)
     AND TRIM(inf01.TRANNO) = TRIM(ztrapf.TRANNO)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZSUBCOVDTLS zsubcovdtls
      WHERE
          TRIM(inf.inf01_REFNUM) = TRIM(zsubcovdtls.CHDRNUM)
      AND TRIM(inf.inf01_EFFDATE) =  TRIM(zsubcovdtls.EFFDATE)
      AND TRIM(inf.inf01_MBRNO) =  TRIM(zsubcovdtls.MBRNO)
      AND TRIM(inf.inf01_TRANNO) =  TRIM(zsubcovdtls.TRANNO)
      AND TRIM(inf.inf01_ZTRXSTSIND) =  TRIM(zsubcovdtls.ZTRXSTSIND)
      ) 
AND TRIM(inf.inf01_NDRPREM) > 0
;

--- R2_4---@@@×ZTRXSTSIND:MSDとコードが異なっているので、不一致となる。このSQLはMSDに準じている
SELECT
      inf.inf01_RECIDXMBINDP2
     ,inf.inf01_REFNUM
     ,inf.inf01_PRODTYP
     ,inf.inf01_EFFDATE
     ,inf.inf01_DTETRM
     ,inf.inf01_ZPLANCDE
     ,inf.inf01_ZTRXSTSIND
FROM
    (
     SELECT
           inf01.RECIDXMBINDP2   inf01_RECIDXMBINDP2
          ,inf01.REFNUM          inf01_REFNUM
          ,inf01.PRODTYP         inf01_PRODTYP
          ,inf01.EFFDATE         inf01_EFFDATE
          ,CASE gchd.STATCODE 
                WHEN 'CA' THEN gchd.effdcldt
                ELSE 99999999
           END inf01_DTETRM
          ,trnhf.ZPLANCDE        inf01_ZPLANCDE
          ,CASE  ztrapf.ZTRXSTAT
                 WHEN 'AP' THEN '1'
                 WHEN 'RJ' THEN '4'
           END inf01_ZTRXSTSIND
     FROM
           Jd1dta.DMIGTITDMGMBRINDP2 inf01
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,STATCODE
               ,effdcldt
          FROM
                Jd1dta.GCHD
          WHERE
                TRIM(CHDRNUM) <> TRIM(MPLNUM)
         ) gchd
     ON
         TRIM(gchd.CHDRNUM) = TRIM(inf01.REFNUM)
     LEFT JOIN
         Jd1dta.DMIGTITDMGPOLTRNH trnhf
     ON
         TRIM(inf01.REFNUM) = TRIM(trnhf.CHDRNUM)
     AND TRIM(inf01.ZSEQNO) = TRIM(trnhf.ZSEQNO)
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,TRANNO
               ,ZTRXSTAT
          FROM
                Jd1dta.ZTRAPF
         ) ztrapf
     ON
         TRIM(inf01.REFNUM) = TRIM(ztrapf.CHDRNUM)
     AND TRIM(inf01.TRANNO) = TRIM(ztrapf.TRANNO)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZTEMPCOVPF ztempcovpf
      WHERE
          TRIM(inf.inf01_REFNUM) = TRIM(ztempcovpf.CHDRNUM)
      AND TRIM(inf.inf01_PRODTYP) =  TRIM(ztempcovpf.PRODTYP)
      AND TRIM(inf.inf01_EFFDATE) =  TRIM(ztempcovpf.EFFDATE)
      AND TRIM(inf.inf01_DTETRM) =  TRIM(ztempcovpf.DTETRM)
      AND TRIM(inf.inf01_ZPLANCDE) =  TRIM(ztempcovpf.ZSALPLAN)
      AND TRIM(inf.inf01_EFFDATE) =  TRIM(ztempcovpf.ZCVGSTRTDT)
      AND TRIM(inf.inf01_DTETRM) =  TRIM(ztempcovpf.ZCVGENDDT)
      AND TRIM(inf.inf01_ZTRXSTSIND) =  TRIM(ztempcovpf.ZTRXSTSIND)
      AND TRIM(inf.inf01_DTETRM) =  TRIM(ztempcovpf.ZRFNDSDT)
      ) 
;


---R3_1----
SELECT
      inf01.RECIDXPHIST
     ,inf01.CHDRNUM
     ,inf01.EFFDATE
     ,inf01.TRANNO
     ,inf01.COWNNUM
     ,inf01.zworkplce
     ,inf01.ZPGPFRDT
     ,inf01.ZPGPTODT
     ,inf01.ZPOLPERD
     ,inf01.ZSLPTYP
     ,inf01.ZINSROLE
FROM
    (
     SELECT
           inf.RECIDXPHIST
          ,inf.CHDRNUM
          ,inf.EFFDATE
          ,inf.TRANNO
          ,gchd.COWNNUM
          ,gchd.zworkplce
          ,CASE
               WHEN inf.TRANNO = gchd.tranlused THEN gchppf.zpgpfrdt
               ELSE 99999999
           END ZPGPFRDT
          ,CASE
               WHEN inf.TRANNO = gchd.tranlused THEN gchppf.zpgptodt
               ELSE 99999999
           END ZPGPTODT
          ,gchipf.ZPOLPERD
          ,zslphpf.ZSLPTYP
          ,inf.ZINSROLE
          ,inf.MBRNO
     FROM
         (
           SELECT
                A.RECIDXPHIST     RECIDXPHIST
               ,A.CHDRNUM         CHDRNUM
               ,B.EFFDATE         EFFDATE
               ,A.zaltregdat      zaltregdat
               ,B.TRANNO          TRANNO
               ,A.ZPLANCDE        ZPLANCDE
               ,A.ZINSROLE        ZINSROLE
               ,A.MBRNO           MBRNO
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH A
          LEFT JOIN 
          (
           SELECT
                 CHDRNUM
                ,EFFDATE
                ,ZSEQNO
                ,MBRNO
                ,TRANNO
           FROM
                 Jd1dta.DMIGTITDMGPOLTRNH
           WHERE
                substr(ZSEQNO,-1) = '0' 
          ) B
          ON   TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM)
          AND  TRIM(A.MBRNO) = TRIM(B.MBRNO)
          AND  SUBSTR(TRIM(A.ZSEQNO),1,2) = SUBSTR(TRIM(B.ZSEQNO),1,2)
         ) inf
     LEFT JOIN
         (
          SELECT
                gchd.CHDRNUM
               ,gchd.COWNNUM
               ,gchd.tranlused
               ,zclnpf.EFFDATE
               ,zclnpf.zworkplce
          FROM
                Jd1dta.GCHD gchd
          INNER JOIN
                Jd1dta.ZCLNPF zclnpf
          ON
                TRIM(gchd.COWNNUM) = TRIM(zclnpf.CLNTNUM)
          WHERE
                gchd.CHDRNUM <> gchd.MPLNUM
         ) gchd
     ON
         TRIM(inf.CHDRNUM) = TRIM(gchd.CHDRNUM)
     AND TRIM(gchd.EFFDATE) <=
         CASE
             WHEN inf.effdate < inf.zaltregdat THEN inf.zaltregdat
             ELSE inf.effdate
         END
     AND ROWNUM = 1
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,zpgpfrdt
               ,zpgptodt
          FROM
                Jd1dta.GCHPPF
          ) gchppf
     ON
         TRIM(inf.CHDRNUM) = TRIM(gchppf.CHDRNUM)
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,CCDATE
               ,TRANNO
               ,ZPOLPERD
          FROM
               Jd1dta.GCHIPF
         ) gchipf
     ON
         TRIM(inf.CHDRNUM) = TRIM(gchipf.CHDRNUM)
     AND TRIM(inf.EFFDATE) = TRIM(gchipf.CCDATE)
     AND TRIM(inf.TRANNO) = TRIM(gchipf.TRANNO)
     LEFT JOIN
         (
          SELECT
                ZSLPTYP
               ,ZSALPLAN
          FROM
                Jd1dta.ZSLPHPF
         ) zslphpf
     ON
         TRIM(inf.ZPLANCDE) = TRIM(zslphpf.ZSALPLAN)
    ) inf01
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZALTPF zaltpf
      WHERE
          DECODE(TRIM(inf01.CHDRNUM)     ,null,' ',TRIM(inf01.CHDRNUM))           =  DECODE(TRIM(zaltpf.CHDRNUM),null,' ',TRIM(zaltpf.CHDRNUM))
      AND DECODE(TRIM(inf01.COWNNUM)    ,null,' ',TRIM(inf01.COWNNUM))         =  DECODE(TRIM(zaltpf.COWNNUM),null,' ',TRIM(zaltpf.COWNNUM))
      AND DECODE(TRIM(inf01.ZPGPFRDT)    ,null,' ',TRIM(inf01.ZPGPFRDT))         =  DECODE(TRIM(zaltpf.ZPGPFRDT),null,' ',TRIM(zaltpf.ZPGPFRDT))
      AND DECODE(TRIM(inf01.ZPGPTODT) ,null,' ',TRIM(inf01.ZPGPTODT))   =  DECODE(TRIM(zaltpf.ZPGPTODT),null,' ',TRIM(zaltpf.ZPGPTODT))
      AND DECODE(TRIM(inf01.zworkplce)     ,null,' ',TRIM(inf01.zworkplce))           =  DECODE(TRIM(zaltpf.ZWORKPLCE1),null,' ',TRIM(zaltpf.ZWORKPLCE1))
      AND DECODE(TRIM(inf01.ZPOLPERD)    ,null,' ',TRIM(inf01.ZPOLPERD))         =  DECODE(TRIM(zaltpf.ZPOLPERD),null,' ',TRIM(zaltpf.ZPOLPERD))
      AND DECODE(TRIM(inf01.ZSLPTYP),null,' ',TRIM(inf01.ZSLPTYP)) =  DECODE(TRIM(zaltpf.ZSLPTYP),null,' ',TRIM(zaltpf.ZSLPTYP))
      ) 
AND  (inf01.MBRNO = '00001') AND (inf01.ZINSROLE = 1)
;

---R3_2--------@@@×ZTRXSTSIND:MSDとコード(コードは Directなので結果が異なる)が異なっているので、不一致となる。このSQLはMSDに準じている
SELECT
      inf.RECIDXPHIST
     ,inf.CHDRNUM
     ,inf.MBRNO
     ,inf.TRANNO
     ,inf.DTETRM
     ,inf.ZTRXSTSIND
FROM
    (
     SELECT
           inf02.RECIDXPHIST
          ,inf02.CHDRNUM
          ,inf02.MBRNO
          ,inf02.TRANNO
          ,CASE inf02.TYPE
                WHEN 'INSERT' THEN 99999999
                ELSE inf02.EFFDATE
           END DTETRM
          ,CASE  ztrapf.ZTRXSTAT
                 WHEN 'AP' THEN '1'
                 WHEN 'RJ' THEN '4'
           END ZTRXSTSIND
     FROM
         (
          SELECT
                inf01.RECIDXPHIST
               ,inf01.CHDRNUM
               ,inf01.MBRNO
               ,inf01.TRANNO
               ,inf01.EFFDATE
               ,'INSERT' TYPE
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH inf01
          WHERE inf01.TRANNO = 1 AND inf01.ZALTRCDE01 <> 'N10'
          UNION ALL
          SELECT
                inf01.RECIDXPHIST
               ,inf01.CHDRNUM
               ,inf01.MBRNO
               ,inf01.TRANNO
               ,inf01.EFFDATE
               ,'INSERT' TYPE
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH inf01
          WHERE NOT EXISTS
                (
                 SELECT
                        *
                 FROM
                       Jd1dta.zbenfdtlspf
                 WHERE
                       TRIM(CHDRNUM) = TRIM(inf01.CHDRNUM)
                 AND   TRIM(MBRNO) = TRIM(inf01.MBRNO)
                 AND   TRIM(DTETRM) = 99999999
                 AND   TRANNO < inf01.TRANNO
                )
          AND  inf01.ZALTRCDE01 = 'N10'
          UNION ALL
          SELECT
                inf01.RECIDXPHIST
               ,inf01.CHDRNUM
               ,inf01.MBRNO
               ,inf01.TRANNO
               ,inf01.EFFDATE
               ,'UPDATE' TYPE
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH inf01
          WHERE EXISTS
                (
                 SELECT
                        *
                 FROM
                       Jd1dta.zbenfdtlspf
                 WHERE
                       TRIM(CHDRNUM) = TRIM(inf01.CHDRNUM)
                 AND   TRIM(MBRNO) = TRIM(inf01.MBRNO)
                 AND   TRIM(DTETRM) = 99999999
                 AND   TRANNO < inf01.TRANNO
                )
          AND inf01.ZALTRCDE01 = 'N10'
         ) inf02
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,TRANNO
               ,ZTRXSTAT
          FROM
                Jd1dta.ZTRAPF
         ) ztrapf
     ON
         TRIM(inf02.CHDRNUM) = TRIM(ztrapf.CHDRNUM)
     AND TRIM(inf02.TRANNO) = TRIM(ztrapf.TRANNO)
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZBENFDTLSPF zbenfdtlspf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)   ,null,' ',TRIM(inf.CHDRNUM))    =  DECODE(TRIM(zbenfdtlspf.CHDRNUM)  ,null,' ',TRIM(zbenfdtlspf.CHDRNUM))
      AND DECODE(TRIM(inf.MBRNO)   ,null,' ',TRIM(inf.MBRNO))    =  DECODE(TRIM(zbenfdtlspf.MBRNO)  ,null,' ',TRIM(zbenfdtlspf.MBRNO))
      AND DECODE(TRIM(inf.TRANNO) ,null,' ',TRIM(inf.TRANNO))  =  DECODE(TRIM(zbenfdtlspf.TRANNO),null,' ',TRIM(zbenfdtlspf.TRANNO))
      AND DECODE(TRIM(inf.DTETRM) ,null,' ',TRIM(inf.DTETRM))  =  DECODE(TRIM(zbenfdtlspf.DTETRM),null,' ',TRIM(zbenfdtlspf.DTETRM))
      AND DECODE(TRIM(inf.ZTRXSTSIND)     ,null,' ',TRIM(inf.ZTRXSTSIND))      =  DECODE(TRIM(zbenfdtlspf.ZTRXSTSIND)    ,null,' ',TRIM(zbenfdtlspf.ZTRXSTSIND))
      )
;

---R3_3----@@@×DTETRM:MSDはZTRAPF.EFDATE、コードではキャンセルの場合にinf.EFFDATEをセットしている
----------------TERMDTE:MSDはZTRAPF.EFDATE、コードではキャンセルの場合にinf.EFFDATEをセットしている
----------------ZTRXSTSIND:コードは Directなので結果が異なる
SELECT
       inf.RECIDXPHIST
      ,inf.CHDRNUM
      ,inf.tranno
      ,inf.CC_tranno
      ,inf.CLNTNUM
      ,inf.DTETRM
      ,inf.ZTRXSTSIND
      ,inf.TERMDTE
      ,inf.OCCPCODE
FROM
    (
     SELECT
           inf.RECIDXPHIST
          ,inf.CHDRNUM
          ,inf.tranno
          ,B.TRANNO            CC_tranno
          ----
          ,pazdclpf.zigvalue   CLNTNUM
          ,CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) --ZRCALTTY
                WHEN 'TERM' THEN ztrapf.EFFDATE
                ELSE 99999999
           END DTETRM
          ,gchipf.CCDATE DTEATT
          ,CASE  ztrapf.ZTRXSTAT
                 WHEN 'AP' THEN '1'
                 WHEN 'RJ' THEN '4'
           END ZTRXSTSIND
          ,CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) --ZRCALTTY
                WHEN 'TERM' THEN ztrapf.EFFDATE
                ELSE 99999999
           END TERMDTE
           ,zclnpf.OCCPCODE
     FROM
           Jd1dta.DMIGTITDMGPOLTRNH inf
      LEFT JOIN 
          (
           SELECT
                 CHDRNUM
                ,EFFDATE
                ,ZSEQNO
                ,MBRNO
                ,TRANNO
           FROM
                 Jd1dta.DMIGTITDMGPOLTRNH
           WHERE
                substr(ZSEQNO,-1) = '0' 
          ) B
          ON   TRIM(inf.CHDRNUM) = TRIM(B.CHDRNUM)
          AND  TRIM(inf.MBRNO) = TRIM(B.MBRNO)
          AND  SUBSTR(TRIM(inf.ZSEQNO),1,2) = SUBSTR(TRIM(B.ZSEQNO),1,2)
     LEFT JOIN
          Jd1dta.PAZDCLPF pazdclpf
     ON
         TRIM(inf.CLIENTNO) = TRIM(pazdclpf.zentity)
     AND TRIM(PREFIX) = TRIM('CP')
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,TRANNO
               ,EFFDATE
               ,ZTRXSTAT
          FROM
                Jd1dta.ZTRAPF
         ) ztrapf
     ON
         TRIM(inf.CHDRNUM) = TRIM(ztrapf.CHDRNUM)
     AND TRIM(inf.TRANNO) = TRIM(ztrapf.TRANNO)
     LEFT OUTER JOIN 
          Jd1dta.ITEMPF C 
     ON
          TRIM(C.ITEMITEM)=TRIM(inf.ZALTRCDE01)
     AND  TRIM(C.ITEMTABL) = 'TQ9MP' 
     AND TRIM(C.ITEMCOY) IN (1, 9)
     AND TRIM(C.ITEMPFX) = 'IT'
     AND TRIM(C.VALIDFLAG)= '1'
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,CCDATE
               ,TRANNO
               ,ZPOLPERD
          FROM
               Jd1dta.GCHIPF
         ) gchipf
     ON
         TRIM(inf.CHDRNUM) = TRIM(gchipf.CHDRNUM)
     AND TRIM(B.EFFDATE) = TRIM(gchipf.CCDATE)
     AND TRIM(B.TRANNO) = TRIM(gchipf.TRANNO)
     LEFT JOIN
         (
         SELECT
               gchd.CHDRNUM
              ,gchd.COWNNUM
              ,gchd.tranlused
              ,zclnpf.EFFDATE
              ,zclnpf.OCCPCODE
         FROM
               Jd1dta.GCHD gchd
         INNER JOIN
              (
                SELECT
                      CLNTNUM
                     ,EFFDATE
                     ,OCCPCODE
                FROM
                      Jd1dta.ZCLNPF zclnpf
              ) zclnpf
         ON
               TRIM(gchd.COWNNUM) = TRIM(zclnpf.CLNTNUM)
         WHERE
               gchd.CHDRNUM <> gchd.MPLNUM
         ) zclnpf
     ON
         TRIM(inf.CHDRNUM) = TRIM(zclnpf.CHDRNUM)
     AND TRIM(zclnpf.EFFDATE) <=
         CASE
             WHEN B.effdate < inf.zaltregdat THEN inf.zaltregdat
             ELSE B.effdate
         END
     AND ROWNUM = 1
    ) inf
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZINSDTLSPF zinsdtlspf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)   ,null,' ',TRIM(inf.CHDRNUM))    =  DECODE(TRIM(zinsdtlspf.CHDRNUM)   ,null,' ',TRIM(zinsdtlspf.CHDRNUM))
      AND DECODE(TRIM(inf.CLNTNUM)   ,null,' ',TRIM(inf.CLNTNUM))    =  DECODE(TRIM(zinsdtlspf.CLNTNUM)   ,null,' ',TRIM(zinsdtlspf.CLNTNUM))
      AND DECODE(TRIM(inf.DTETRM),null,' ',TRIM(inf.DTETRM)) =  DECODE(TRIM(zinsdtlspf.DTETRM),null,' ',TRIM(zinsdtlspf.DTETRM))
      AND DECODE(TRIM(inf.ZTRXSTSIND)   ,null,' ',TRIM(inf.ZTRXSTSIND))    =  DECODE(TRIM(zinsdtlspf.ZTRXSTSIND)   ,null,' ',TRIM(zinsdtlspf.ZTRXSTSIND))
      AND DECODE(TRIM(inf.TERMDTE)  ,null,' ',TRIM(inf.TERMDTE))   =  DECODE(TRIM(zinsdtlspf.TERMDTE)  ,null,' ',TRIM(zinsdtlspf.TERMDTE))
      AND DECODE(TRIM(inf.OCCPCODE)  ,null,' ',TRIM(inf.OCCPCODE))   =  DECODE(TRIM(zinsdtlspf.OCCPCODE)  ,null,' ',TRIM(zinsdtlspf.OCCPCODE))
      ) 
;

---R3_4----
SELECT
      inf.RECIDXPHIST
     ,inf.CHDRNUM
     ,inf.TRANNO
     ,gchppf.ZENDCDE
     ,gchd.ZCRDTYPE
FROM
      Jd1dta.DMIGTITDMGPOLTRNH inf 
LEFT JOIN
    (
     SELECT
           CHDRNUM
          ,ZENDCDE
     FROM
           Jd1dta.GCHPPF
     WHERE
           TRIM(CHDRCOY) IN (1, 9)
     ) gchppf
ON  TRIM(inf.CHDRNUM) = TRIM(gchppf.CHDRNUM)
LEFT JOIN
    (
     SELECT
           gchd.CHDRNUM
          ,gchd.MPLNUM
          ,zenctpf.ZCNBRFRM
          ,zenctpf.ZCRDTYPE
          ,zenctpf.ZCNBRTO
          ,zenctpf.ZCARDDC
     FROM
           Jd1dta.GCHD gchd
     LEFT JOIN
           Jd1dta.ZENCTPF zenctpf
     ON
        TRIM(gchd.MPLNUM) = TRIM(zenctpf.ZPOLNMBR)
     WHERE
           TRIM(gchd.CHDRNUM) <> TRIM(gchd.MPLNUM)
     ) gchd
ON
    TRIM(inf.CHDRNUM) = TRIM(gchd.CHDRNUM)
AND (
        (TRIM(gchd.ZCNBRFRM) < TRIM(inf.CRDTCARD) AND TRIM(gchd.ZCNBRTO) > TRIM(inf.CRDTCARD))
     OR  TRIM(gchd.ZCNBRFRM) = TRIM(inf.CRDTCARD)   AND TRIM(gchd.ZCNBRTO) = TRIM(inf.CRDTCARD)
    )
AND gchd.ZCARDDC = length(inf.CRDTCARD)
WHERE trim(inf.crdtcard) is not null and trim(inf.MPLNUM) is not null and
NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZMCIPF zmcipf
      WHERE
          DECODE(TRIM(inf.CHDRNUM)   ,null,' ',TRIM(inf.CHDRNUM))    =  DECODE(TRIM(zmcipf.CHDRNUM)   ,null,' ',TRIM(zmcipf.CHDRNUM))
      AND DECODE(TRIM(inf.TRANNO)   ,null,' ',TRIM(inf.TRANNO))    =  DECODE(TRIM(zmcipf.TRANNO)   ,null,' ',TRIM(zmcipf.TRANNO))
      AND DECODE(TRIM(gchppf.ZENDCDE),null,' ',TRIM(gchppf.ZENDCDE)) =  DECODE(TRIM(zmcipf.ZENDCDE),null,' ',TRIM(zmcipf.ZENDCDE))
      AND DECODE(TRIM(gchd.ZCRDTYPE)  ,null,' ',TRIM(gchd.ZCRDTYPE))   =  DECODE(TRIM(zmcipf.CARDTYP)  ,null,' ',TRIM(zmcipf.CARDTYP))
      )
AND
  (
    TRIM(inf.mbrno) = '00001') and (inf.zinsrole = 1) AND (TRIM(inf.zseqno) = '000'
    AND
   (
     (TRIM(inf.zenspcd01) IS NOT NULL) OR
     (TRIM(inf.zenspcd02) IS NOT NULL) OR
     (TRIM(inf.crdtcard)  IS NOT NULL) OR
     (TRIM(inf.bnkacckey01) IS NOT NULL) OR 
     (TRIM(inf.zddreqno)  IS NOT NULL) OR
     (TRIM(inf.zcifcode)  IS NOT NULL)
    )
  ) 
OR
  (TRIM(inf.zaltrcde01) = 'M04')
OR 
  (TRIM(inf.zaltrcde01) = 'M01')
OR 
  (TRIM(inf.zaltrcde01) = 'M02')
;

---R3_5----注意！同一契約番号内の全てのMBRNOについて、ZALTRCDE01の履歴は同一にする（MBRNO:1のTRANNO:1が'C06'で、MBRNO:２のTRANNO:1が'P09'にすると結果の不一致が起こる）
SELECT
      inf01.RECIDXPHIST
     ,inf01.CHDRNUM
     ,inf01.EFFDATE
     ,inf01.ZQUOTIND
     ,inf01.ZPOLDATE
     ,inf01.UNIQUE_NUMBER_01
     ,inf01.ZREFUNDAM
     ,inf01.ZVLDTRXIND
     ,inf01.ZRCALTTY
FROM
    (
     SELECT
           inf.RECIDXPHIST
          ,inf.CHDRNUM
          ,inf.EFFDATE
          ,inf.ZALTREGDAT
          /*
          ,inf.ZACLSDAT
          ,inf.ZTRXSTAT
          ,inf.ZACLSDAT
          ,inf.APPRDTE
          ,gchppf.zpoltdate
          ,inf.TRANNO
          ,can.CANTRANNO
          ,can.CANDATE
          ,inf.EFFDATE
          */
          ----
          ,CASE inf.TRANNO
                WHEN 1 THEN '  '
                ELSE 'A'
           END ZQUOTIND
          ,CASE inf.TRANNO
                WHEN 1 THEN 99999999
                ELSE
                     CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4)
                          WHEN 'TERM'  THEN gchppf.zpoltdate
                          ELSE 99999999
                     END
           END ZPOLDATE
          ,gchd.UNIQUE_NUMBER UNIQUE_NUMBER_01
          ,CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4)
                WHEN 'TERM' THEN inf.INTREFUND
                ELSE 0
           END ZREFUNDAM
          ,CASE SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4)
                WHEN 'TERM' THEN 
                                 CASE
                                     WHEN (inf.TRANNO <> can.CANTRANNO) AND (inf.EFFDATE >= can.CANDATE) THEN 'Y'
                                     ELSE NULL
                                 END
                ELSE NULL
           END ZVLDTRXIND
          ,SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4)  ZRCALTTY
     FROM
           Jd1dta.DMIGTITDMGPOLTRNH inf 
     LEFT JOIN
         (
          SELECT
                CHDRNUM
               ,zpoltdate
          FROM
                Jd1dta.GCHPPF
          WHERE
                TRIM(CHDRCOY) IN (1, 9)
          ) gchppf
     ON  TRIM(inf.CHDRNUM) = TRIM(gchppf.CHDRNUM)
     LEFT OUTER JOIN 
          Jd1dta.ITEMPF C 
     ON
          TRIM(C.ITEMITEM)=TRIM(inf.ZALTRCDE01)
     AND  TRIM(C.ITEMTABL) = 'TQ9MP' 
     AND TRIM(C.ITEMCOY) IN (1, 9)
     AND TRIM(C.ITEMPFX) = 'IT'
     AND TRIM(C.VALIDFLAG)= '1'
     LEFT JOIN
         (
          SELECT
                gchd.CHDRNUM
               ,gchd.COWNNUM
               ,zclnpf.EFFDATE
               ,zclnpf.UNIQUE_NUMBER
          FROM
                Jd1dta.GCHD gchd
          INNER JOIN
                Jd1dta.ZCLNPF zclnpf
          ON
                TRIM(gchd.COWNNUM) = TRIM(zclnpf.CLNTNUM)
          WHERE
                gchd.CHDRNUM <> gchd.MPLNUM
         ) gchd
     ON
         TRIM(inf.CHDRNUM) = TRIM(gchd.CHDRNUM)
     AND TRIM(gchd.EFFDATE) <=
         CASE
             WHEN inf.effdate < inf.zaltregdat THEN inf.zaltregdat
             ELSE inf.effdate
         END
     AND ROWNUM = 1
     LEFT JOIN
         (
          SELECT
                A.CHDRNUM
               ,MAX(A.TRANNO) CANTRANNO
               ,A.EFFDATE     CANDATE
          FROM
                Jd1dta.DMIGTITDMGPOLTRNH A
          LEFT JOIN 
                Jd1dta.ITEMPF B
          ON TRIM(B.ITEMITEM) = TRIM(A.ZALTRCDE01)
          AND TRIM(B.ITEMTABL) = 'TQ9MP'
          AND TRIM(B.ITEMCOY) IN (1, 9)
          AND TRIM(B.ITEMPFX) = 'IT'
          AND TRIM(B.VALIDFLAG)= '1'
          WHERE
                SUBSTR(UTL_RAW.CAST_TO_VARCHAR2(B.GENAREA),6,4) = 'TERM'
          GROUP BY
                 A.CHDRNUM
                ,A.EFFDATE
         ) can
     ON TRIM(can.CHDRNUM) = TRIM(inf.CHDRNUM)
     WHERE (inf.MBRNO = '00001') AND (inf.ZINSROLE = 1)
    ) inf01
WHERE NOT EXISTS
     (SELECT
            * 
      FROM
           Jd1dta.ZTRAPF ztrapf
      WHERE
          DECODE(TRIM(inf01.CHDRNUM)     ,null,' ',TRIM(inf01.CHDRNUM))     =  DECODE(TRIM(ztrapf.CHDRNUM)     ,null,' ',TRIM(ztrapf.CHDRNUM))
      AND DECODE(TRIM(inf01.EFFDATE)     ,null,' ',TRIM(inf01.EFFDATE))     =  DECODE(TRIM(ztrapf.EFFDATE)     ,null,' ',TRIM(ztrapf.EFFDATE))
      AND DECODE(TRIM(inf01.ZQUOTIND)  ,null,' ',TRIM(inf01.ZQUOTIND))  =  DECODE(TRIM(ztrapf.ZQUOTIND)  ,null,' ',TRIM(ztrapf.ZQUOTIND))
      AND DECODE(TRIM(inf01.ZPOLDATE)    ,null,' ',TRIM(inf01.ZPOLDATE))    =  DECODE(TRIM(ztrapf.ZPOLDATE)    ,null,' ',TRIM(ztrapf.ZPOLDATE))
      AND DECODE(TRIM(inf01.UNIQUE_NUMBER_01)    ,null,' ',TRIM(inf01.UNIQUE_NUMBER_01))    =  DECODE(TRIM(ztrapf.UNIQUE_NUMBER_01)    ,null,' ',TRIM(ztrapf.UNIQUE_NUMBER_01))
      AND DECODE(TRIM(inf01.ZREFUNDAM)    ,null,' ',TRIM(inf01.ZREFUNDAM))    =  DECODE(TRIM(ztrapf.ZREFUNDAM)    ,null,' ',TRIM(ztrapf.ZREFUNDAM))
      AND DECODE(TRIM(inf01.ZVLDTRXIND)    ,null,' ',TRIM(inf01.ZVLDTRXIND))    =  DECODE(TRIM(ztrapf.ZVLDTRXIND)    ,null,' ',TRIM(ztrapf.ZVLDTRXIND))
      AND DECODE(TRIM(inf01.ZRCALTTY)     ,null,' ',TRIM(inf01.ZRCALTTY))     =  DECODE(TRIM(ztrapf.ZRCALTTY)     ,null,' ',TRIM(ztrapf.ZRCALTTY))
      ) 
;