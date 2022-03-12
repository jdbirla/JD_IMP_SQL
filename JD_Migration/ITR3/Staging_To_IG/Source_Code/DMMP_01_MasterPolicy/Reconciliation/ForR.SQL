----#1 - 3 ----------------------------------------------------------------------------
SELECT
      src.chdrnum src_chdrnum
     ,src.TERMAGE src_TERMAGE
     ---,src.TAXFLAG src_TAXFLAG
     ,gchd.mplnum gchd_mplnum
     ,gchd.TERMAGE gchd_TERMAGE
     ---,gchd.TAXFLAG gchd_TAXFLAG
FROM
    (
     SELECT
           srcpol.chdrnum
          ,DFPO.TERMAGE   --- Change this to a target field
          ,DFPO.TAXFLAG   --- Change this to a target field
     FROM
          (
           SELECT
                 src1.chdrnum
                ,src1.cnttype
                ,src1.ZPLANCLS
           FROM
               (
                SELECT
                      CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                      END chdrnum
                      ,CCDATE
                      ,cnttype
                      ,DECODE(TRIM(RPTFPST),'F','FP','PP') ZPLANCLS
                FROM
                     TITDMGMASPOL@dmstgusr2dblink
               ) src1
           INNER JOIN
                (
                 SELECT
                      CHDRNUM 
                     ,MAX(CCDATE) MAX_CCDATE
                 FROM
                     (
                      SELECT
                           CASE LENGTH(TRIM(chdrnum)) 
                                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                ELSE TRIM(chdrnum)        
                           END chdrnum       
                          ,CCDATE
                      FROM
                          TITDMGMASPOL@dmstgusr2dblink
                     ) 
                 GROUP BY
                      CHDRNUM
                ) src2
            ON     
                TRIM(src1.CHDRNUM) = TRIM(src2.CHDRNUM)
            AND TRIM(src1.CCDATE) = TRIM(src2.MAX_CCDATE) 
          ) srcpol
     INNER JOIN
         (
          SELECT
                tq9fk.cnttype
               ,tq9fk.zplancls
               ,dfpopf.TERMAGE TERMAGE
               ,dfpopf.TAXFLAG TAXFLAG
          FROM
              (
               SELECT
                     TRIM(itemcoy) itemcoy
                    ,TRIM(itemtabl) itemtabl
                    ,SUBSTR(itemitem,1,3) cnttype
                    ,SUBSTR(itemitem,4,2) zplancls
                    ,SUBSTR( utl_raw.cast_to_varchar2(genarea) ,9,7) template
               FROM itempf
               WHERE
                    TRIM(itemtabl) = 'TQ9FK'
                    AND TRIM(itemcoy) IN (1, 9)
                    AND TRIM(itempfx) = 'IT'
                    AND TRIM(validflag)= '1'
               ORDER BY TRIM(itemtabl)
              ) tq9fk
          INNER JOIN
              (
               SELECT
                     *
               FROM
                    dfpopf
              ) dfpopf
          ON 
              TRIM(tq9fk.template) = TRIM( dfpopf.template)
          AND TRIM(tq9fk.itemcoy) = TRIM(dfpopf.CHDRCOY)
         ) DFPO
     ON
         TRIM(srcpol.cnttype) = TRIM(DFPO.cnttype)
     AND TRIM(srcpol.zplancls) = TRIM(DFPO.zplancls)
    ) src
LEFT JOIN
    (
     SELECT
           chdrnum
          ,mplnum
          ,TRIM(TERMAGE) TERMAGE
          ,TRIM(TAXFLAG) TAXFLAG
     FROM
          GCHD
     WHERE
           CHDRNUM = MPLNUM
     AND   JOBNM = 'G1ZDMSTPOL'
    ) gchd
ON
   src.chdrnum = gchd.chdrnum
WHERE
    src.TERMAGE <> gchd.TERMAGE
---OR  src.TAXFLAG <> gchd.TAXFLAG
OR  gchd.mplnum <> gchd.chdrnum
    

----#4 - 9 (R_2) -----------------------------------------------------------------------------------
SELECT
      src.chdrnum src_chdrnum
     ,src.ccdate src_ccdate
     ,src.BILLFREQ src_BILLFREQ
     ,src.GADJFREQ src_GADJFREQ
     ,src.ZPSTDDT src_ZPSTDDT
     ,gchipf.tq9gx_TIMECH01 tq9gx_TIMECH01
     ,gchipf.tq9gx_TIMECH02 tq9gx_TIMECH02
     ,gchipf.calc_ZPOLPERD calc_ZPOLPERD
     ,gchipf.BILLFREQ gchipf_BILLFREQ
     ,gchipf.GADJFREQ gchipf_GADJFREQ
     ,gchipf.ZPSTDDT gchipf_ZPSTDDT
     ,gchipf.TIMECH01 gchipf_TIMECH01
     ,gchipf.TIMECH02 gchipf_TIMECH02
     ,gchipf.ZPOLPERD gchipf_ZPOLPERD
FROM
    (
     SELECT
           srcpol.chdrnum
          ,srcpol.ccdate
          ,srcpol.crdate
          ,srcpol.ZPSTDDT
          ,DFPO.BILLFREQ
          ,DFPO.GADJFREQ
     FROM
          (
           SELECT
                 src1.chdrnum
                ,src1.ccdate
                ,src1.crdate
                ,src1.cnttype
                ,src1.pndate ZPSTDDT
                ,src1.ZPLANCLS
           FROM
               (
                SELECT
                      CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                      END chdrnum
                      ,CCDATE
                      ,TO_CHAR(TO_DATE(TRIM(CRDATE),'YYYYMMDD') - 1,'YYYYMMDD') CRDATE
                      ,cnttype
                      ,pndate
                      ,DECODE(TRIM(RPTFPST),'F','FP','PP') ZPLANCLS
                FROM
                     TITDMGMASPOL@dmstgusr2dblink
               ) src1
          ) srcpol
     INNER JOIN
         (
          SELECT
                tq9fk.cnttype
               ,tq9fk.zplancls
               ,dfpopf.BILLFREQ BILLFREQ
               ,dfpopf.GADJFREQ GADJFREQ
          FROM
              (
               SELECT
                     TRIM(itemcoy) itemcoy
                    ,TRIM(itemtabl) itemtabl
                    ,SUBSTR(itemitem,1,3) cnttype
                    ,SUBSTR(itemitem,4,2) zplancls
                    ,SUBSTR( utl_raw.cast_to_varchar2(genarea) ,9,7) template
               FROM itempf
               WHERE
                    TRIM(itemtabl) = 'TQ9FK'
                    AND TRIM(itemcoy) IN (1, 9)
                    AND TRIM(itempfx) = 'IT'
                    AND TRIM(validflag)= '1'
               ORDER BY TRIM(itemtabl)
              ) tq9fk
          INNER JOIN
              (
               SELECT
                     *
               FROM
                    dfpopf
              ) dfpopf
          ON 
              TRIM(tq9fk.template) = TRIM( dfpopf.template)
          AND TRIM(tq9fk.itemcoy) = TRIM(dfpopf.CHDRCOY)
         ) DFPO
     ON
         TRIM(srcpol.cnttype) = TRIM(DFPO.cnttype)
     AND TRIM(srcpol.zplancls) = TRIM(DFPO.zplancls)
    ) src
LEFT JOIN
    (
     SELECT
           gchipf01.chdrnum
          ,gchipf01.ccdate
          ,gchipf01.crdate
          ,gchipf01.ZPSTDDT
          ,gchipf01.ZPOLPERD
          ,CEIL(MONTHS_BETWEEN(TO_DATE(gchipf01.crdate,'YYYYMMDD'),TO_DATE(gchipf01.ccdate,'YYYYMMDD'))) calc_ZPOLPERD
          ,TRIM(gchipf01.BILLFREQ) BILLFREQ
          ,TRIM(gchipf01.GADJFREQ) GADJFREQ
          ,TRIM(gchipf01.TIMECH01) TIMECH01
          ,TRIM(gchipf01.TIMECH02) TIMECH02
          ,gchd.TIMECH01 tq9gx_TIMECH01
          ,gchd.TIMECH02 tq9gx_TIMECH02
     FROM
          GCHIPF gchipf01
     INNER JOIN
          (
           SELECT
                 gchd01.chdrnum
                ,gchd01.CNTTYPE
                ,tq9gx.TIMECH01
                ,tq9gx.TIMECH02
           FROM
                 GCHD gchd01
           LEFT JOIN
               (
                SELECT
                    TRIM(itemitem) CNTTYPE
                   ,SUBSTR(utl_raw.cast_to_varchar2(genarea),1,5) TIMECH01
                   ,SUBSTR(utl_raw.cast_to_varchar2(genarea),6,5) TIMECH02
                FROM
                    itempf
                WHERE
                    TRIM(itemtabl)= 'TQ9GX'
                AND TRIM(itemcoy) IN (1, 9)
                AND TRIM(itempfx) = 'IT'
                AND TRIM(validflag)= '1'
               ) tq9gx
           ON gchd01.CNTTYPE || 'T902' = tq9gx.CNTTYPE
           WHERE
                 gchd01.chdrnum = gchd01.mplnum
           AND   gchd01.JOBNM = 'G1ZDMSTPOL'
           ) gchd
     ON gchipf01.chdrnum = gchd.chdrnum
     WHERE
          gchipf01.JOBNM = 'G1ZDMSTPOL'
    ) gchipf
ON
    src.chdrnum = gchipf.chdrnum
AND src.ccdate = gchipf.ccdate
WHERE
     src.BILLFREQ <> gchipf.BILLFREQ
AND  src.GADJFREQ <> gchipf.GADJFREQ
AND  src.ZPSTDDT <> gchipf.ZPSTDDT
AND  gchipf.tq9gx_TIMECH01 <> gchipf.TIMECH01
AND  gchipf.tq9gx_TIMECH02 <> gchipf.TIMECH02
AND  gchipf.CALC_ZPOLPERD <> gchipf.ZPOLPERD


----#10 - 17 (R_3)----------------------------------------------------------------------------
SELECT
     --- source ---
      src.chdrnum src_chdrnum
     ,src.ADMNRULE src_ADMNRULE
     ,src.DEFCLMPYE src_DEFCLMPYE
     ,src.MBRIDFLD src_MBRIDFLD
     ,src.CALCMTHD src_CALCMTHD
     ,gchipf.ZAPLFOD gchipf_ZAPLFOD
     ,src.zcolmcls src_zcolmcls
     --- results ----
     ,gchppf.ADMNRULE gchppf_ADMNRULE
     ,gchppf.DEFCLMPYE gchppf_DEFCLMPYE
     ,gchppf.MBRIDFLD gchppf_MBRIDFLD
     ,gchppf.CALCMTHD gchppf_CALCMTHD
     ,gchppf.ZAPLFOD gchppf_ZAPLFOD
     ,gchppf.zcolmcls gchppf_zcolmcls
FROM
    (
     SELECT
           srcpol.chdrnum
          ,DFPO.ADMNRULE   
          ,DFPO.DEFCLMPYE  
          ,DFPO.MBRIDFLD   
          ,DFPO.CALCMTHD   
          ,srcpol.zcolmcls
     FROM
          (
           SELECT
                 src1.chdrnum
                ,src1.cnttype
                ,src1.ZPLANCLS
                ,src3.zcolmcls
           FROM
               (
                SELECT
                      CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                      END chdrnum
                      ,CCDATE
                      ,cnttype
                      ,DECODE(TRIM(RPTFPST),'F','FP','PP') ZPLANCLS
                      ,TRIM(ZENDCDE) ZENDCDE
                FROM
                     TITDMGMASPOL@dmstgusr2dblink
               ) src1
           INNER JOIN
                (
                 SELECT
                      CHDRNUM 
                     ,MAX(CCDATE) MAX_CCDATE
                 FROM
                     (
                      SELECT
                           CASE LENGTH(TRIM(chdrnum)) 
                                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                ELSE TRIM(chdrnum)        
                           END chdrnum       
                          ,CCDATE
                      FROM
                          TITDMGMASPOL@dmstgusr2dblink
                     ) 
                 GROUP BY
                      CHDRNUM
                ) src2
            ON     
                TRIM(src1.CHDRNUM) = TRIM(src2.CHDRNUM)
            AND TRIM(src1.CCDATE) = TRIM(src2.MAX_CCDATE) 
           INNER JOIN
                (
                  SELECT
                        TRIM(zendrpf.ZENDCDE) ZENDCDE
                       ,TRIM(zendrpf.ZFACTHUS) ZFACTHUS
                       ,itempf.zcolmcls zcolmcls
                  FROM
                         Jd1dta.ZENDRPF zendrpf
                  INNER JOIN
                       (
                        SELECT
                              TRIM(itemitem) itemitem
                             ,SUBSTR(utl_raw.cast_to_varchar2(itempf.genarea),196,1) zcolmcls
                        FROM
                              Jd1dta.ITEMPF
                        WHERE
                              TRIM(itemtabl) = 'T3684'
                        AND   TRIM(itemcoy) IN (1, 9)
                        AND   TRIM(itempfx) = 'IT'
                        AND   TRIM(validflag)= '1'
                       ) itempf
                   ON TRIM(zendrpf.ZFACTHUS) = TRIM(itempf.itemitem)
                ) src3
            ON     
                TRIM(src1.ZENDCDE) = TRIM(src3.ZENDCDE)
          ) srcpol
     INNER JOIN
         (
          SELECT
                tq9fk.cnttype
               ,tq9fk.zplancls
               ,TRIM(dfpopf.ADMNRULE) ADMNRULE
               ,TRIM(dfpopf.DEFCLMPYE) DEFCLMPYE
               ,TRIM(dfpopf.MBRIDFLD) MBRIDFLD
               ,TRIM(dfpopf.CALCMTHD) CALCMTHD
          FROM
              (
               SELECT
                     TRIM(itemcoy) itemcoy
                    ,TRIM(itemtabl) itemtabl
                    ,SUBSTR(itemitem,1,3) cnttype
                    ,SUBSTR(itemitem,4,2) zplancls
                    ,SUBSTR( utl_raw.cast_to_varchar2(genarea) ,9,7) template
               FROM itempf
               WHERE
                    TRIM(itemtabl) = 'TQ9FK'
                    AND TRIM(itemcoy) IN (1, 9)
                    AND TRIM(itempfx) = 'IT'
                    AND TRIM(validflag)= '1'
               ORDER BY TRIM(itemtabl)
              ) tq9fk
          INNER JOIN
              (
               SELECT
                     *
               FROM
                    dfpopf
              ) dfpopf
          ON 
              TRIM(tq9fk.template) = TRIM( dfpopf.template)
          AND TRIM(tq9fk.itemcoy) = TRIM(dfpopf.CHDRCOY)
         ) DFPO
     ON
         TRIM(srcpol.cnttype) = TRIM(DFPO.cnttype)
     AND TRIM(srcpol.zplancls) = TRIM(DFPO.zplancls)
    ) src
LEFT JOIN
    (
     SELECT
           chdrnum
          ,TRIM(ADMNRULE) ADMNRULE
          ,TRIM(DEFCLMPYE) DEFCLMPYE
          ,TRIM(MBRIDFLD) MBRIDFLD
          ,TRIM(CALCMTHD) CALCMTHD
          ,DECODE(TRIM(ZAPLFOD),null,' ', TRIM(ZAPLFOD)) ZAPLFOD
          ,TRIM(ZCOLMCLS) ZCOLMCLS
     FROM
          GCHPPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) gchppf
ON
   src.chdrnum = gchppf.chdrnum
LEFT JOIN
    (
     SELECT
           gchipf01.chdrnum
          ,gchipf01.ccdate
          ,gchipf01.crdate
          ,gchppf01.ZPLANCLS
          ,DECODE(gchppf01.ZPLANCLS,'FP',SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(gchipf01.ccdate,'YYYYMMDD'), -1),'YYYYMMDD'),1,6) || '01',' ') ZAPLFOD
     FROM
          GCHIPF gchipf01
     INNER JOIN
          (
           SELECT
                 chdrnum
                ,MAX(ccdate) ccdate
           FROM
                GCHIPF
           WHERE
                JOBNM = 'G1ZDMSTPOL'
           GROUP BY
                chdrnum
          ) gchipf02
     ON  gchipf01.chdrnum = gchipf02.chdrnum
     AND gchipf01.ccdate = gchipf02.ccdate
     INNER JOIN
          (
           SELECT
                 chdrnum
                ,ZPLANCLS
           FROM
                 GCHPPF
           WHERE
                 JOBNM = 'G1ZDMSTPOL'
           ) gchppf01
     ON gchipf01.chdrnum = gchppf01.chdrnum
    ) gchipf
ON src.chdrnum = gchipf.chdrnum
WHERE
    src.ADMNRULE <> gchppf.ADMNRULE
OR  src.DEFCLMPYE <> gchppf.DEFCLMPYE
OR  src.MBRIDFLD <> gchppf.MBRIDFLD
OR  src.CALCMTHD <> gchppf.CALCMTHD
OR  gchipf.ZAPLFOD <> gchppf.ZAPLFOD
OR  src.ZCOLMCLS <> gchppf.ZCOLMCLS
    
------ #18 - 19 (R_4)--------------------------------------------------------------
SELECT
     src.chdrnum src_chdrnum
    ,src.ZENDCDE src_ENDCDE
    ,zenctpf.ZENDCDE zenctpf_ZENDCDE
FROM
    (
     SELECT
           gchd.chdrnum
          ,gchppf.ZENDCDE
     FROM
           GCHD gchd
     INNER JOIN
          (
           SELECT
                 TRIM(chdrnum) chdrnum
                ,TRIM(ZENDCDE) ZENDCDE
           FROM
                 GCHPPF
           WHERE
                 TRIM(JOBNM) = 'G1ZDMSTPOL'
          ) gchppf
     ON gchd.chdrnum = gchppf.chdrnum
     WHERE
          gchd.chdrnum = gchd.mplnum
     AND  TRIM(gchd.JOBNM) = 'G1ZDMSTPOL'
    ) src
INNER JOIN
     (
      SELECT
            DISTINCT
            TRIM(ZPOLNMBR) ZPOLNMBR
           ,TRIM(ZENDCDE) ZENDCDE
      FROM
            ZENCTPF
      WHERE
            JOBNM = 'G1ZDMSTPOL'
     ) zenctpf
ON src.chdrnum = zenctpf.ZPOLNMBR
WHERE
      src.ZENDCDE <> zenctpf.ZENDCDE
      
      
------ #20 - ITR3-2 (R_5)----------------------------------------------------------------------------
SELECT
      src.chdrnum src_chdrnum
     ,src.tranno src_tranno
     ,src.CHDRCOY src_CHDRCOY
     ,src.COWNNUM src_COWNNUM
     ,src.EFFDATE src_EFFDATE
     ,src.PETNAME src_PETNAME
     ,src.ZGRPCLS src_ZGRPCLS
     ,src.ZAGPTNUM src_ZAGPTNUM
     ,src.ZGPMPPP src_ZGPMPPP
     ,src.CCDATE src_CCDATE
     ,src.CCDATE src_CCDATE
     ,ztgmpf.chdrnum ztgmpf_chdrnum
     ,ztgmpf.tranno ztgmpf_tranno
     ,ztgmpf.CHDRCOY ztgmpf_CHDRCOY
     ,ztgmpf.COWNNUM ztgmpf_COWNNUM
     ,ztgmpf.EFFDATE ztgmpf_EFFDATE
     ,ztgmpf.PETNAME ztgmpf_PETNAME
     ,ztgmpf.ZGRPCLS ztgmpf_ZGRPCLS
     ,ztgmpf.ZAGPTNUM ztgmpf_ZAGPTNUM
     ,ztgmpf.ZGPMPPP ztgmpf_ZGPMPPP
     ,ztgmpf.CCDATE ztgmpf_CCDATE
     ,ztgmpf.CCDATE ztgmpf_CCDATE
FROM
    (
----- source -------------
     SELECT
           gchd01.chdrnum
          ,gchipf.CCDATE
          ,gchipf.CRDATE
          ,gchipf.tranno
          ,gchd01.CHDRCOY
          ,gchd01.COWNNUM
          ,CASE gchd01.EFFDCLDT
                WHEN 99999999 THEN TO_CHAR(gchipf.CCDATE)
                ELSE
                    CASE gchipf.STATCODE 
                         WHEN 'CA' THEN TO_CHAR(gchd01.EFFDCLDT)
                         WHEN 'LA' THEN TO_CHAR(gchipf.CCDATE)
                         ELSE           TO_CHAR(gchipf.CCDATE)
                    END
                END EFFDATE
          ,gchppf.PETNAME
          ,gchppf.ZGRPCLS
          ,gchipf.ZAGPTNUM
          ,gchipf.ZPOLPERD ZGPMPPP
          ,gchipf.STATCODE ----@@@
          ,gchd01.EFFDCLDT ----@@
    FROM
          GCHD gchd01
     INNER JOIN
          (
           SELECT
                 TRIM(chdrnum) chdrnum
                ,TRIM(PETNAME) PETNAME
                ,TRIM(ZGRPCLS) ZGRPCLS
           FROM
                GCHPPF
           WHERE
                TRIM(JOBNM) = 'G1ZDMSTPOL'
          ) gchppf
     ON TRIM(gchd01.chdrnum) = TRIM(gchppf.chdrnum)
     INNER JOIN
          (
           SELECT
                 chdrnum
                ,ccdate
                ,crdate
                ,ZAGPTNUM
                ,ZPOLPERD
                ,STATCODE
                ,CANCELDT
                ,ROW_NUMBER() OVER(PARTITION BY chdrnum ORDER BY chdrnum,ccdate,seq) AS tranno
           FROM
               (
               ----- add cancel or lapse to gchipf
               SELECT
                     DISTINCT
                     TRIM(gchipf.chdrnum) chdrnum
                    ,TRIM(gchipf.ccdate) ccdate
                    ,TRIM(gchipf.crdate) crdate
                    ,TRIM(gchipf.ZAGPTNUM) ZAGPTNUM
                    ,TRIM(gchipf.ZPOLPERD) ZPOLPERD
                    ,srcpol.STATCODE
                    ,srcpol.CANCELDT
                    ,srcpol.seq
               FROM
                    GCHIPF gchipf
               INNER JOIN
                    (
                     ------ select cancel to be added
                     SELECT
                           CASE LENGTH(TRIM(chdrnum)) 
                                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                ELSE TRIM(chdrnum)
                           END chdrnum
                          ,TRIM(ccdate) ccdate
                          ,CASE STATCODE
                                 WHEN 'CA' THEN 'IF'
                                 WHEN 'LA' THEN 'IF'
                                 ELSE STATCODE
                           END STATCODE
                          ,NULL CANCELDT
                          ,'1' seq
                     FROM
                           TITDMGMASPOL@dmstagedblink
                     UNION ALL
                     ------ select cancel to be added
                     SELECT
                           CASE LENGTH(TRIM(chdrnum)) 
                                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                ELSE TRIM(chdrnum)
                           END chdrnum
                          ,TRIM(ccdate) ccdate
                          ,'CA' STATCODE
                          ,TRIM(CANCELDT) CANCELDT
                          ,'2' seq
                     FROM
                           TITDMGMASPOL@dmstagedblink
                     WHERE
                          TRIM(STATCODE) = 'CA'
                     OR   TRIM(CANCELDT) IS NOT NULL
                     UNION ALL
                     ------ select lapse to be added
                     SELECT
                           CASE LENGTH(TRIM(chdrnum)) 
                                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                ELSE TRIM(chdrnum)
                           END chdrnum
                          ,TRIM(ccdate) ccdate
                          ,TRIM(STATCODE) STATCODE
                          ,TRIM(CANCELDT) CANCELDT
                          ,'2' seq
                     FROM
                           TITDMGMASPOL@dmstagedblink
                     WHERE
                          TRIM(STATCODE) = 'LA'
                    ) srcpol
               ON 
                   TRIM(gchipf.chdrnum) = TRIM(srcpol.chdrnum)
               AND TRIM(gchipf.ccdate) = TRIM(srcpol.ccdate)
               WHERE
                    TRIM(gchipf.JOBNM) = 'G1ZDMSTPOL'
               )
           ORDER BY
                chdrnum
               ,ccdate
               ,seq
          ) gchipf
     ON TRIM(gchd01.chdrnum) = TRIM(gchipf.chdrnum)
     WHERE
          TRIM(gchd01.chdrnum) = TRIM(gchd01.mplnum)
     AND  TRIM(gchd01.JOBNM) = 'G1ZDMSTPOL'
     ORDER BY
            gchd01.chdrnum
           ,gchipf.tranno
    ) src
LEFT JOIN
     (
      ---- results
      SELECT
            TRIM(CHDRNUM) CHDRNUM
           ,TRIM(TRANNO) TRANNO
           ,TRIM(CHDRCOY) CHDRCOY
           ,TO_CHAR(TRIM(EFFDATE)) EFFDATE
           ,TRIM(COWNNUM) COWNNUM
           ,TRIM(PETNAME) PETNAME
           ,TRIM(ZGRPCLS) ZGRPCLS
           ,TRIM(ZAGPTNUM) ZAGPTNUM
           ,TO_CHAR(TRIM(ZGPMPPP)) ZGPMPPP
           ,TRIM(CCDATE) CCDATE ---- Iteration 3
           ,TRIM(CRDATE) CRDATE ---- Iteration 3
      FROM
           ZTGMPF
      WHERE
           TRIM(JOBNM) = 'G1ZDMSTPOL'
     ) ztgmpf
ON
     src.CHDRNUM = ztgmpf.CHDRNUM
AND  src.TRANNO = ztgmpf.TRANNO
WHERE
     src.CHDRCOY <> ztgmpf.CHDRCOY
OR   src.COWNNUM <> ztgmpf.COWNNUM
OR   src.EFFDATE <> ztgmpf.EFFDATE
OR   src.PETNAME <> ztgmpf.PETNAME
OR   src.ZGRPCLS <> ztgmpf.ZGRPCLS
OR   src.ZAGPTNUM <> ztgmpf.ZAGPTNUM
OR   src.ZGPMPPP <> ztgmpf.ZGPMPPP
OR   src.CCDATE <> ztgmpf.CCDATE ---- Iteration 3
OR   src.CRDATE <> ztgmpf.CRDATE ---- Iteration 3


------ #29 - 35 (R_6)----------------------------------------------------------------------------
SELECT
      src.chdrnum src_chdrnum
     ,src.tranno src_tranno
     ,src.CHDRCOY src_CHDRCOY
     ,src.EFDATE src_EFDATE
     ,src.EFFDATE src_EFFDATE
     ,src.ZALTREGDAT src_ZALTREGDAT
     ,src.APPRDTE src_APPRDTE
     ,src.STATCODE src_STATCODE
     ,ztrapf.chdrnum ztrapf_chdrnum
     ,ztrapf.tranno ztrapf_tranno
     ,ztrapf.CHDRCOY ztrapf_CHDRCOY
     ,ztrapf.EFDATE ztrapf_EFDATE
     ,ztrapf.EFFDATE ztrapf_EFFDATE
     ,ztrapf.ZALTREGDAT ztrapf_ZALTREGDAT
     ,ztrapf.APPRDTE ztrapf_APPRDTE
     ,ztrapf.STATCODE ztrapf_STATCODE
FROM
    (
----- source -------------
     SELECT
           gchd01.chdrnum
          ,gchipf.tranno
          ,gchd01.CHDRCOY
          ,gchipf.EFDATE
          ,gchipf.EFFDATE
          ,gchipf.ZALTREGDAT
          ,gchipf.APPRDTE
          ,gchipf.STATCODE
    FROM
          GCHD gchd01
    INNER JOIN
          (
           SELECT
                 chdrnum
                ,ccdate
                ,crdate
                ,DECODE(TRIM(canceldt),null,ccdate,TO_CHAR(ADD_MONTHS(TO_DATE(ccdate,'YYYYMMDD'), 1),'YYYYMMDD')) EFDATE
                ,DECODE(TRIM(canceldt),null,ccdate,canceldt) EFFDATE
                ,DECODE(TRIM(canceldt),null,ccdate,canceldt) ZALTREGDAT
                ,APPRDTE
                ,STATCODE
                ,ROW_NUMBER() OVER(PARTITION BY chdrnum ORDER BY chdrnum,ccdate,seq) AS tranno
           FROM
               (
                ----- select all data from gchipf
                SELECT
                      TRIM(gchipf01.chdrnum) chdrnum
                     ,TRIM(gchipf01.ccdate) ccdate
                     ,TRIM(gchipf01.crdate) crdate
                     ,TRIM(gchipf01.ccdate) EFDATE
                     ,TRIM(gchipf01.ccdate) EFFDATE
                     ,TRIM(gchipf01.ccdate) ZALTREGDAT
                     ,TRIM(gchipf01.ccdate) APPRDTE
                     ,TRIM(srcpol.canceldt) canceldt
                     ,srcpol.STATCODE
                     ,srcpol.seq
                FROM
                     GCHIPF gchipf01
                INNER JOIN
                     (
                     --- select all records
                      SELECT
                            CASE LENGTH(TRIM(chdrnum)) 
                                 WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                 ELSE TRIM(chdrnum)
                            END chdrnum
                           ,TRIM(ccdate) ccdate
                           ,CASE STATCODE
                                 WHEN 'CA' THEN 'IF'
                                 WHEN 'LA' THEN 'IF'
                                 ELSE STATCODE
                            END STATCODE
                           ,null canceldt
                           ,'1' seq
                      FROM
                            TITDMGMASPOL@dmstagedblink
                      UNION ALL
                      ---- select cancel to be added
                      SELECT
                            CASE LENGTH(TRIM(chdrnum)) 
                                 WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                 ELSE TRIM(chdrnum)
                            END chdrnum
                           ,TRIM(ccdate) ccdate
                           ,TRIM(STATCODE) STATCODE
                           ,TRIM(canceldt) canceldt
                           ,'2' seq
                      FROM
                            TITDMGMASPOL@dmstagedblink
                      WHERE
                           TRIM(CANCELDT) IS NOT NULL
                      UNION ALL
                      ---- select lapse to be added
                      SELECT
                            CASE LENGTH(TRIM(chdrnum)) 
                                 WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                                 ELSE TRIM(chdrnum)
                            END chdrnum
                           ,TRIM(ccdate) ccdate
                           ,TRIM(STATCODE) STATCODE
                           ,null canceldt
                           ,'2' seq
                      FROM
                            TITDMGMASPOL@dmstagedblink
                      WHERE
                            TRIM(STATCODE) = 'LA'
                     ) srcpol
                ON 
                    TRIM(gchipf01.chdrnum) = TRIM(srcpol.chdrnum)
                AND TRIM(gchipf01.ccdate) = TRIM(srcpol.ccdate)
                WHERE
                     TRIM(gchipf01.JOBNM) = 'G1ZDMSTPOL'
               )
           ORDER BY
                chdrnum
               ,ccdate
               ,seq
          ) gchipf
     ON TRIM(gchd01.chdrnum) = TRIM(gchipf.chdrnum)
     WHERE
          TRIM(gchd01.chdrnum) = TRIM(gchd01.mplnum)
     AND  TRIM(gchd01.JOBNM) = 'G1ZDMSTPOL'
     ORDER BY
            gchd01.chdrnum
           ,gchipf.tranno
    ) src
LEFT JOIN
     (
      ---- results
      SELECT
            TRIM(CHDRNUM) CHDRNUM
           ,TRIM(TRANNO) TRANNO
           ,TRIM(CHDRCOY) CHDRCOY
           ,TRIM(EFDATE) EFDATE
           ,TRIM(EFFDATE) EFFDATE
           ,TRIM(ZALTREGDAT) ZALTREGDAT
           ,TRIM(APPRDTE) APPRDTE
           ,TRIM(STATCODE) STATCODE
      FROM
           ZTRAPF
      WHERE
           TRIM(JOBNM) = 'G1ZDMSTPOL'
     ) ztrapf
ON
     src.CHDRNUM = ztrapf.CHDRNUM
AND  src.TRANNO = ztrapf.TRANNO
WHERE
     src.CHDRCOY <> ztrapf.CHDRCOY
OR   src.EFDATE <> ztrapf.EFDATE
OR   src.EFFDATE <> ztrapf.EFFDATE
OR   src.ZALTREGDAT <> ztrapf.ZALTREGDAT
OR   src.APPRDTE <> ztrapf.APPRDTE
OR   src.STATCODE <> ztrapf.STATCODE

------ #36 - 39 (R_7)---------
SELECT
      TRIM(gchd.CHDRNUM) gchd_CHDRNUM
     ----,TRIM(gchd.Cownpfx) gchd_Cownpfx
     ----,TRIM(gchd.Cowncoy) gchd_Cowncoy
     ,TRIM(gchd.COWNNUM) gchd_COWNNUM
     ,TRIM(clrrpf.FORENUM) clrrpf_FORENUM
     ----,TRIM(clrrpf.CLNTPFX) clrrpf_CLNTPFX
     ----,TRIM(clrrpf.CLNTCOY) clrrpf_CLNTCOY
     ,TRIM(clrrpf.CLNTNUM) clrrpf_CLNTNUM
FROM
     GCHD gchd
LEFT JOIN
    (
     SELECT
           TRIM(FORENUM) FORENUM
          ,TRIM(CLNTPFX) CLNTPFX
          ,TRIM(CLNTCOY) CLNTCOY
          ,TRIM(CLNTNUM) CLNTNUM
     FROM
          CLRRPF
     WHERE
          TRIM(JOBNM) = 'G1ZDMSTPOL'
    ) clrrpf    
ON
    TRIM(gchd.CHDRNUM) = TRIM(clrrpf.FORENUM)
AND TRIM(gchd.COWNNUM) = TRIM(clrrpf.CLNTNUM)
WHERE
     TRIM(gchd.CHDRNUM) = TRIM(gchd.MPLNUM)
AND  TRIM(gchd.JOBNM) = 'G1ZDMSTPOL'
AND (
    TRIM(gchd.CHDRNUM) <> TRIM(clrrpf.FORENUM)
----OR  TRIM(gchd.Cownpfx) <> TRIM(clrrpf.CLNTPFX)
----OR  TRIM(gchd.Cowncoy) <> TRIM(clrrpf.CLNTCOY)
OR  TRIM(gchd.COWNNUM) <> TRIM(clrrpf.CLNTNUM)
    )
------ #40 - 55 (R_8)---------
SELECT
      TRIM(clrrpf.CLNTNUM) clrrpf_CLNTNUM
     ,TRIM(clrrpf.CLNTPFX) clrrpf_CLNTPFX
     ,TRIM(clrrpf.CLNTCOY) clrrpf_CLNTCOY
     ,TRIM(clrrpf.CLRRROLE) clrrpf_CLRRROLE
     ,TRIM(clrrpf.FOREPFX) clrrpf_FOREPFX
     ,TRIM(clrrpf.FORECOY) clrrpf_FORECOY
     ,TRIM(clrrpf.FORENUM) clrrpf_FORENUM
     ,TRIM(audit_clrrpf.OLDCLNTNUM) audit_clrrpf_OLDCLNTNUM
     ,TRIM(audit_clrrpf.NEWCLNTPFX) audit_clrrpff_CLNTPFX
     ,TRIM(audit_clrrpf.NEWCLNTCOY) audit_clrrpf_NEWCLNTCOY
     ,TRIM(audit_clrrpf.NEWCLNTNUM) audit_clrrpff_NEWCLNTNUM
     ,TRIM(audit_clrrpf.NEWCLRRROLE) audit_clrrpf_NEWCLRRROLE
     ,TRIM(audit_clrrpf.NEWFOREPFX) audit_clrrpf_NEWFOREPFX
     ,TRIM(audit_clrrpf.NEWFORECOY) audit_clrrpf_NEWFORECOY
     ,TRIM(audit_clrrpf.NEWFORENUM) audit_clrrpf_NEWFORENUM
FROM
     CLRRPF clrrpf
LEFT JOIN
    (
     SELECT
            OLDCLNTNUM
           ,NEWCLNTPFX
           ,NEWCLNTCOY
           ,NEWCLNTNUM
           ,NEWCLRRROLE
           ,NEWFOREPFX
           ,NEWFORECOY
           ,NEWFORENUM
    FROM
         AUDIT_CLRRPF
    WHERE
         TRIM(NEWJOBNM) = 'G1ZDMSTPOL'
    ) audit_clrrpf
ON
    TRIM(clrrpf.CLNTNUM) = TRIM(audit_clrrpf.OLDCLNTNUM)
AND TRIM(clrrpf.FORENUM) = TRIM(audit_clrrpf.NEWFORENUM)
WHERE
    TRIM(clrrpf.JOBNM) = 'G1ZDMSTPOL'
AND (
     TRIM(clrrpf.CLNTNUM) <> TRIM(audit_clrrpf.OLDCLNTNUM)
OR   TRIM(clrrpf.CLNTPFX) <> TRIM(audit_clrrpf.NEWCLNTPFX)
OR   TRIM(clrrpf.CLNTCOY) <> TRIM(audit_clrrpf.NEWCLNTCOY)
OR   TRIM(clrrpf.CLNTNUM) <> TRIM(audit_clrrpf.NEWCLNTNUM)
OR   TRIM(clrrpf.CLRRROLE) <> TRIM(audit_clrrpf.NEWCLRRROLE)
OR   TRIM(clrrpf.FOREPFX) <> TRIM(audit_clrrpf.NEWFOREPFX)
OR   TRIM(clrrpf.FORECOY) <> TRIM(audit_clrrpf.NEWFORECOY)
OR   TRIM(clrrpf.FORENUM) <> TRIM(audit_clrrpf.NEWFORENUM)
    )

---- #ITR3-3 - ITR3-4 (R_9) ---------------------
SELECT
      src.CHDRNUM src_CHDRNUM
     ,src.ZLAPTRX src_ZLAPTRX
     ,src.ZPOLTDATE src_ZPOLTDATE
     ,gchppf.ZLAPTRX gchppf_ZLAPTRX
     ,gchppf.ZPOLTDATE gchppf_ZPOLTDATE
FROM
    (
     SELECT
           ztgmpf.CHDRNUM
          ,CASE ztgmpf.ZRNWABL
                WHEN 'Y' THEN 'N'
                ELSE
                    CASE gchppf.ZPLANCLS
                         WHEN 'PP' THEN 'Y'
                         ELSE           'Y'
                    END
           END ZLAPTRX
          ,CASE ztgmpf.ZRNWABL
                WHEN 'Y' THEN '99999999'
                ELSE  TO_CHAR(TO_DATE(TRIM(ztgmpf.CRDATE),'YYYYMMDD') + 1,'YYYYMMDD')
           END ZPOLTDATE 
          ,ztgmpf.ZRNWABL
          ,ztgmpf.CRDATE
          ,gchppf.ZPLANCLS
     FROM
           ZTGMPF ztgmpf
     INNER JOIN
          (
           SELECT
                 TRIM(CHDRNUM) CHDRNUM
                ,MAX(TRIM(TRANNO)) TRANNO
           FROM
                 ZTGMPF
           WHERE
                 TRIM(JOBNM) = 'G1ZDMSTPOL'
           GROUP BY
                CHDRNUM
          ) ztgmpf01
     ON
         TRIM(ztgmpf.CHDRNUM) = TRIM(ztgmpf01.CHDRNUM)
     AND TRIM(ztgmpf.TRANNO) = TRIM(ztgmpf01.TRANNO)
     INNER JOIN
          (
           SELECT
                 TRIM(CHDRNUM) CHDRNUM
                ,TRIM(ZPLANCLS) ZPLANCLS
           FROM
                 GCHPPF gchppf
           WHERE
                 TRIM(JOBNM) = 'G1ZDMSTPOL'
          ) gchppf
     ON
         TRIM(ztgmpf.CHDRNUM) = TRIM(gchppf.CHDRNUM)
     WHERE
         TRIM(ztgmpf.JOBNM) = 'G1ZDMSTPOL'
    ) src
LEFT JOIN
    (
     SELECT
           TRIM(CHDRNUM) CHDRNUM
          ,TRIM(ZLAPTRX) ZLAPTRX
          ,TRIM(ZPOLTDATE) ZPOLTDATE
     FROM
          GCHPPF
     WHERE
         TRIM(JOBNM) = 'G1ZDMSTPOL'
    ) gchppf
ON src.CHDRNUM = gchppf.CHDRNUM
WHERE
     src.CHDRNUM <> gchppf.CHDRNUM
OR   src.ZLAPTRX <> gchppf.ZLAPTRX
OR   src.ZPOLTDATE <> gchppf.ZPOLTDATE

---- #ITR3-5 - ITR3-5 (R_10)---------------------
SELECT
      src.chdrnum
     ,src.EFFDCLDT
     ,gchd.EFFDCLDT
FROM
    (
      SELECT
            TRIM(src1.chdrnum)  chdrnum
           ,TRIM(src1.CCDATE)  CCDATE
           ,TO_CHAR(TO_DATE(TRIM(src1.CRDATE),'YYYYMMDD') -1,'YYYYMMDD') CRDATE
           ,TRIM(src1.CANCELDT)  CANCELDT
           ,TRIM(gchd01.STATCODE) STATCODE
           ,CASE TRIM(gchd01.STATCODE)
                 WHEN 'LA' THEN TO_CHAR(TO_DATE(TRIM(src1.CRDATE),'YYYYMMDD') -1,'YYYYMMDD')
                 ELSE DECODE(TRIM(src1.CANCELDT),null,'99999999',TRIM(src1.CANCELDT))
            END EFFDCLDT
      FROM
           (
            SELECT
                  CASE LENGTH(TRIM(chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                       ELSE TRIM(chdrnum)
                  END chdrnum
                 ,TRIM(CCDATE) CCDATE
                 ,TRIM(CRDATE) CRDATE
                 ,TRIM(CANCELDT) CANCELDT
            FROM
                 TITDMGMASPOL@dmstgusr2dblink
           )  src1
           INNER JOIN
          (
           SELECT
                CHDRNUM 
               ,MAX(CCDATE) CCDATE
           FROM
               (
                SELECT
                     CASE LENGTH(TRIM(chdrnum)) 
                          WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                          ELSE TRIM(chdrnum)          
                     END chdrnum       
                    ,CCDATE
                FROM
                    TITDMGMASPOL@dmstgusr2dblink
               ) 
           GROUP BY
                CHDRNUM 
          ) src2
         ON
             TRIM(src1.CHDRNUM) = TRIM(src2.CHDRNUM)
         AND TRIM(src1.CCDATE) = TRIM(src2.CCDATE)
         INNER JOIN
              (
               SELECT
                     TRIM(chdrnum) chdrnum
                    ,TRIM(STATCODE) STATCODE
               FROM
                     GCHD
               WHERE
                    TRIM(chdrnum) = TRIM(mplnum)
               AND  TRIM(JOBNM) = 'G1ZDMSTPOL'
              ) gchd01
         ON TRIM(src1.CHDRNUM) = TRIM(gchd01.CHDRNUM)
    ) src
LEFT JOIN
     (
      SELECT
            TRIM(CHDRNUM) CHDRNUM
           ,TRIM(EFFDCLDT) EFFDCLDT
      FROM
            GCHD
      WHERE
           TRIM(JOBNM) = 'G1ZDMSTPOL'
      AND  TRIM(CHDRNUM) = TRIM(MPLNUM)
     ) gchd
ON src.CHDRNUM = gchd.CHDRNUM
WHERE
     src.CHDRNUM <> gchd.CHDRNUM
AND  src.EFFDCLDT <> gchd.EFFDCLDT
      