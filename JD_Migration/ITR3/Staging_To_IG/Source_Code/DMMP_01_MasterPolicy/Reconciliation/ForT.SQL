--- #1 (T_1) ----
--- src ---
SELECT
      src.chdrnum src_chdrnum
     ,src.COWNNUM src_COWNNUM
     ,gchd.COWNNUM gchd_COWNNUM
FROM
    (
     SELECT
           srcpol.chdrnum
          ,srcgrp.ZIGVALUE COWNNUM
     FROM
         (
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                      WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                      ELSE TRIM(chdrnum)
                 END chdrnum
           FROM
                 TITDMGMASPOL@dmstgusr2dblink
           GROUP BY
                 CASE LENGTH(TRIM(chdrnum)) 
                      WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                      ELSE TRIM(chdrnum)
                 END
         ) srcpol
     LEFT JOIN
         (
          SELECT
                srcgrp1.CLNTNUM
               ,srcgrp1.GRUPNUM
               ,pazdclpf.ZIGVALUE
          FROM
              (
               SELECT
                     GRUPNUM
                    ,CLNTNUM
               FROM
                     MSTPOLGRP@dmstgusr2dblink
              ) srcgrp1
             INNER JOIN
             (
              SELECT
                   ZIGVALUE
                  ,ZENTITY
              FROM
                   PAZDCLPF
              WHERE
                   PREFIX = 'CC'
              ) pazdclpf
          ON 
              TRIM(pazdclpf.ZENTITY) = TRIM(srcgrp1.CLNTNUM)
         ) srcgrp
     ON TRIM(srcpol.chdrnum) = TRIM(srcgrp.GRUPNUM)
    ) src
LEFT JOIN
    --- ig ---
    (
     SELECT
           TRIM(CHDRNUM) CHDRNUM
          ,TRIM(COWNNUM) COWNNUM
     FROM
           GCHD
     WHERE
           CHDRNUM = MPLNUM
      AND  JOBNM = 'G1ZDMSTPOL'
     ) gchd
ON TRIM(src.chdrnum) = TRIM(gchd.CHDRNUM)
WHERE
   TRIM(src.COWNNUM) <> TRIM(gchd.COWNNUM)


--- #2 - 3  (T_2)----
SELECT
      src.chdrnum src_chdrnum
     ,src.agtype src_agtype
     ,src.ZPLANCLS src_ZPLANCLS
     ,gchd.SRCEBUS gchd_SRCEBUS
     ,gchppf.ZPLANCLS gchppf_ZPLANCLS
FROM
    (
     --- src ---
    SELECT
          srcpol.chdrnum
         ,srcpol.zagptnum
         ,agnt.agtype
         ,srcpol.ZPLANCLS
    FROM
        (
         SELECT
               TRIM(src1.chdrnum) chdrnum
              ,TRIM(src1.ZAGPTNUM) ZAGPTNUM
              ,DECODE(TRIM(src1.RPTFPST),'F','FP','PP') ZPLANCLS
         FROM
             (
              SELECT
                    CASE LENGTH(TRIM(chdrnum)) 
                         WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                         ELSE TRIM(chdrnum)
                    END chdrnum
                    ,ZAGPTNUM
                    ,RPTFPST
                    ,CCDATE
              FROM
                   TITDMGMASPOL@dmstgusr2dblink
             )  src1
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
       LEFT JOIN
           (
            SELECT
                  t2.agtype agtype
                 ,t2.agntnum agntnum
                 ,t1.zagptnum zagptnum
            FROM
                  zagppf t1 
            INNER JOIN
                  agntpf t2
            ON
                 TRIM(t1.gagntsel01) = TRIM(t2.agntnum)
            WHERE
                 TRIM(t1.zagptpfx) = 'AP'
             AND TRIM(t1.zagptcoy) = '1'
             AND TRIM(t1.provstat) = 'AP'
             AND TRIM(t1.validflag) = '1'
             ---AND TRIM(t1.zagptnum) = '00000406'
             ---AND TRIM(t1.effdate) <= TRIM(obj_maspol.effdate)
             AND TRIM(t2.agntpfx) = 'AG'
             AND TRIM(t2.validflag) = '1'
             AND TRIM(t2.agntcoy) = '1'
            ) agnt
       ON TRIM(srcpol.ZAGPTNUM) = TRIM(agnt.zagptnum)
    ) src
    LEFT JOIN
        --- ig gchd---
        (
         SELECT
               TRIM(CHDRNUM) CHDRNUM
              ,TRIM(SRCEBUS) SRCEBUS
         FROM
               GCHD
         WHERE
               CHDRNUM = MPLNUM
          AND  JOBNM = 'G1ZDMSTPOL'
         ) gchd
    ON TRIM(src.chdrnum) = TRIM(gchd.CHDRNUM)
    LEFT JOIN
        --- ig gchppf---
        (
         SELECT
               TRIM(CHDRNUM) CHDRNUM
              ,TRIM(ZPLANCLS) ZPLANCLS
         FROM
               GCHPPF
         WHERE
               JOBNM = 'G1ZDMSTPOL'
         ) gchppf
    ON TRIM(src.chdrnum) = TRIM(gchppf.CHDRNUM)
    WHERE
       TRIM(src.agtype) <> TRIM(gchd.SRCEBUS) 
    OR TRIM(src.ZPLANCLS) <> TRIM(gchppf.ZPLANCLS)

--- #4 - 7 (T_3)----
SELECT
      src.chdrnum src_chdrnum
     ,src.CRDATE src_CRDATE
     ,src.agntnum src_agntnum
     ,src.INSENDTE src_INSENDTE
     ,src.ZPENDDT src_ZPENDDT
     ,gchipf.CRDATE gchipf_CRDATE
     ,gchipf.AGNTNUM gchipf_AGNTNUM
     ,gchipf.INSENDTE gchipf_INSENDTE
     ,gchipf.ZPENDDT gchipf_ZPENDDT
FROM
    (
     SELECT
           srcpol.chdrnum
          ,srcpol.CRDATE
          ,agnt.agntnum
          ,srcpol.INSENDTE
          ,srcpol.ZPENDDT
     FROM
         (
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                      WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                      ELSE TRIM(chdrnum)
                 END chdrnum
                 ,TO_CHAR(TO_DATE(TRIM(CRDATE),'YYYYMMDD') - 1,'YYYYMMDD') CRDATE
                 ,TRIM(ZAGPTNUM) ZAGPTNUM
                 ,TRIM(INSENDTE) || '  ' INSENDTE
                 ,TO_CHAR(TO_DATE(TRIM(ZPENDDT),'YYYYMMDD') - 1,'YYYYMMDD') ZPENDDT
           FROM
                TITDMGMASPOL@dmstgusr2dblink
         ) srcpol
        LEFT JOIN
            (
             SELECT
                   t2.agtype agtype
                  ,t2.agntnum agntnum
                  ,t1.zagptnum zagptnum
             FROM
                   zagppf t1 
             INNER JOIN
                   agntpf t2
             ON
                  TRIM(t1.gagntsel01) = TRIM(t2.agntnum)
             WHERE
                  TRIM(t1.zagptpfx) = 'AP'
              AND TRIM(t1.zagptcoy) = '1'
              AND TRIM(t1.provstat) = 'AP'
              AND TRIM(t1.validflag) = '1'
              ---AND TRIM(t1.zagptnum) = '00000406'
              ---AND TRIM(t1.effdate) <= TRIM(obj_maspol.effdate)
              AND TRIM(t2.agntpfx) = 'AG'
              AND TRIM(t2.validflag) = '1'
              AND TRIM(t2.agntcoy) = '1'
             ) agnt
        ON TRIM(srcpol.ZAGPTNUM) = TRIM(agnt.zagptnum)
    ) src
LEFT JOIN
    (
     --- ig gchipf ---
     SELECT
          chdrnum
         ,CRDATE
         ,AGNTNUM
         ,INSENDTE
         ,ZPENDDT
     FROM
         GCHIPF
     WHERE
        JOBNM = 'G1ZDMSTPOL'
    ) gchipf
ON
    TRIM(src.chdrnum) = TRIM(gchipf.CHDRNUM)
AND TRIM(src.CRDATE) = TRIM(gchipf.CRDATE)
WHERE
    TRIM(src.CRDATE) <> TRIM(gchipf.CRDATE)
OR  TRIM(src.AGNTNUM) <> TRIM(gchipf.AGNTNUM)
OR  TRIM(src.INSENDTE) <> TRIM(gchipf.INSENDTE)
OR  TRIM(src.ZPENDDT) <> TRIM(gchipf.ZPENDDT)

---#8 -10 (T_4)
SELECT
      src.chdrnum     src_chdrnum
     ,src.EFFDATE     src_EFFDATE
     ,src.ZRNWABL     src_ZRNWABL
     ,src.ZWAVGFLG    src_ZWAVGFLG
     ,src.ZRREFFDT    src_ZRREFFDT
     ,ztgmpf.ZRNWABL  ztgmpf_ZRNWABL
     ,ztgmpf.ZWAVGFLG ztgmpf_ZWAVGFLG
     ,ztgmpf.ZRREFFDT ztgmpf_ZRREFFDT
FROM
    (
     ---- src ----
     SELECT
           srcpol.chdrnum
          ,srcpol.EFFDATE
          ,CASE srcpol.renewalable
                WHEN 'N' THEN 'N'
                ELSE
                    CASE TRIM(srcpol.ZRREFFDT)
                         WHEN NULL THEN 'N'
                         ELSE
                             CASE
                                 WHEN busdp.BUSDATE >= srcpol.ZRREFFDT THEN 'N'
                                 ELSE 'Y'
                             END
                    END
           END ZRNWABL 
          ,srcpol.ZWAVGFLG
          ,srcpol.ZRREFFDT
     FROM
         (
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
              ,TRIM(EFFDATE) EFFDATE
              ,CASE TRIM(RPTFPST)
                    WHEN 'F' THEN 'N'
                    ELSE
                        CASE TRIM(ZBLNKPOL)
                             WHEN 'Y' THEN 'N'
                             ELSE 'Y'
                        END
               END renewalable
              ,DECODE(TRIM(B8GOST),'Y','1','0') ZWAVGFLG
              ,DECODE(TRIM(B8O9NB),NULL,99999999, 20 || TRIM(B8O9NB)) ZRREFFDT
          FROM
             TITDMGMASPOL@dmstgusr2dblink
          UNION ALL
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
              ,TRIM(CANCELDT) EFFDATE
              ,CASE TRIM(RPTFPST)
                    WHEN 'F' THEN 'N'
                    ELSE
                        CASE TRIM(ZBLNKPOL)
                             WHEN 'Y' THEN 'N'
                             ELSE 'Y'
                        END
               END renewalable
              ,DECODE(TRIM(B8GOST),'Y','1','0') ZWAVGFLG
              ,DECODE(TRIM(B8O9NB),NULL,99999999, 20 || TRIM(B8O9NB)) ZRREFFDT
          FROM
             TITDMGMASPOL@dmstgusr2dblink
          WHERE
             statcode = 'CA'
         ) srcpol
        ,(SELECT TRIM(BUSDATE) BUSDATE FROM BUSDPF WHERE TRIM(COMPANY) = '1') busdp
    ) src
LEFT JOIN
    (
     ---- ig ZTGMP ---
     SELECT
          TRIM(CHDRNUM) CHDRNUM
         ,TRIM(EFFDATE) EFFDATE
         ,TRIM(ZRNWABL) ZRNWABL
         ,TRIM(ZWAVGFLG) ZWAVGFLG
         ,TRIM(ZRREFFDT) ZRREFFDT
     FROM
         ZTGMPF
     WHERE
         TRIM(JOBNM) = 'G1ZDMSTPOL'
    ) ztgmpf
ON
     TRIM(src.CHDRNUM) = TRIM(ztgmpf.CHDRNUM)
AND  TRIM(src.EFFDATE) = TRIM(ztgmpf.EFFDATE)
WHERE
     src.ZRNWABL <> ztgmpf.ZRNWABL
OR   src.ZWAVGFLG <> ztgmpf.ZWAVGFLG
OR   src.ZRREFFDT <> ztgmpf.ZRREFFDT



--- #11 - 12 (T_5)
SELECT
      src.chdrnum       src_chdrnum
     ,src.CCDATE        src_CCDATE
     ,src.TRANCDE       src_TRANCDE
     ,src.ZALTRCDE01    src_ZALTRCDE01
     ,src.ZVLDTRXIND    src_ZVLDTRXIND
     ,ztrapf.TRANCDE    ztrapf_TRANCDE
     ,ztrapf.ZALTRCDE01 ztrapf_ZALTRCDE01
     ,ztrapf.ZVLDTRXIND    ztrapf_ZVLDTRXIND
FROM
    (
     --- src --
     SELECT
           src1.chdrnum
          ,src1.CCDATE
          ,CASE src1.TRANCDE
                WHEN 'T902' THEN
                     CASE
                         WHEN src1.CCDATE = src2.CCDATE THEN src1.TRANCDE
                         ELSE 'T918'
                     END
                ELSE src1.TRANCDE
           END TRANCDE
          ,src1.ZALTRCDE01
          ,CASE src1.statcode
                WHEN 'CA' THEN 'Y'
                WHEN 'LA' THEN 'Y'
                ELSE  NULL
           END ZVLDTRXIND
     FROM
         (
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
              ,TRIM(CCDATE) CCDATE
              ,'T902' TRANCDE
              ,'   ' ZALTRCDE01
              ,null CANCELDT
              ,'IF 'statcode
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          UNION ALL
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
              ,TO_CHAR(ADD_MONTHS(TO_DATE(TRIM(CCDATE),'YYYYMMDD'), 1),'YYYYMMDD') CCDATE
              ,'T912' TRANCDE
              ,DECODE(TRIM(RPTFPST),'P','GC1','OT4') ZALTRCDE01
              ,TRIM(CANCELDT) CANCELDT
              ,statcode
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          WHERE
              statcode = 'CA'
          OR  TRIM(CANCELDT) IS NOT NULL
          UNION ALL
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
              ,TRIM(CCDATE) CCDATE
              ,'T912' TRANCDE
              ,'GC3' ZALTRCDE01
              ,TRIM(CANCELDT) CANCELDT
              ,statcode
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          WHERE
              statcode = 'LA'
         ) src1
     INNER JOIN
          (
           SELECT
                CASE LENGTH(TRIM(chdrnum)) 
                     WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                     ELSE TRIM(chdrnum)
                END chdrnum
               ,MIN(TRIM(CCDATE)) CCDATE
           FROM
               TITDMGMASPOL@dmstgusr2dblink
           GROUP BY
                CASE LENGTH(TRIM(chdrnum)) 
                     WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                     ELSE TRIM(chdrnum)
                END
          ) src2
     ON
        src1.chdrnum = src2.chdrnum
      ,(SELECT TRIM(BUSDATE) BUSDATE FROM BUSDPF WHERE TRIM(COMPANY) = '1') busdp
    ) src
LEFT JOIN
    (
     --- ig ---
     SELECT
          TRIM(CHDRNUM) CHDRNUM
         ,TRIM(EFDATE) EFDATE
         ,TRIM(TRANCDE) TRANCDE
         ,TRIM(ZALTRCDE01) ZALTRCDE01
         ,TRIM(ZVLDTRXIND) ZVLDTRXIND
     FROM
          ZTRAPF
     WHERE
          TRIM(JOBNM) = 'G1ZDMSTPOL'
    ) ztrapf
ON 
    src.chdrnum = ztrapf.chdrnum
AND src.CCDATE = ztrapf.EFDATE
AND src.TRANCDE = ztrapf.TRANCDE
WHERE
    src.TRANCDE <> ztrapf.TRANCDE
OR  src.ZALTRCDE01 <> ztrapf.ZALTRCDE01

----#13 -17 (T_6)
SELECT
      src.chdrnum src_chdrnum
     ,src.PLNSETNUM src_PLNSETNUM
     ,src.ZINSTYPST src_ZINSTYPST
     ,ztgmpf.chdrnum ztgmpf_chdrnum
     ,ztgmpf.PLNSETNUM ztgmpf_PLNSETNUM
     ,ztgmpf.ZINSTYPST ztgmpf_ZINSTYPST
FROM
     (
      ---- src
      SELECT
            chdrnum
           ,PLNSETNUM
           ,ZINSTYPST
      FROM
          (
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                 END chdrnum
                ,PLNSETNUM
                ,DECODE(TRIM(ZINSTYPE1) || TRIM(ZINSTYPE1) || TRIM(ZINSTYPE2) || TRIM(ZINSTYPE3) || TRIM(ZINSTYPE4),null,null,
                        DECODE(TRIM(ZINSTYPE1),null,'   ,',TRIM(ZINSTYPE1) || ',') ||
                        DECODE(TRIM(ZINSTYPE2),null,'   ,',TRIM(ZINSTYPE2) || ',') ||
                        DECODE(TRIM(ZINSTYPE3),null,'   ,',TRIM(ZINSTYPE3) || ',') ||
                        DECODE(TRIM(ZINSTYPE4),null,'   ',TRIM(ZINSTYPE4))
                 ) ZINSTYPST
           FROM
                 TITDMGINSSTPL@dmstgusr2dblink
           WHERE
                 PLNSETNUM = 1
           UNION ALL 
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                 END chdrnum
                ,PLNSETNUM
                ,DECODE(TRIM(ZINSTYPE1) || TRIM(ZINSTYPE1) || TRIM(ZINSTYPE2) || TRIM(ZINSTYPE3) || TRIM(ZINSTYPE4),null,null,
                        DECODE(TRIM(ZINSTYPE1),null,'   ,',TRIM(ZINSTYPE1) || ',') ||
                        DECODE(TRIM(ZINSTYPE2),null,'   ,',TRIM(ZINSTYPE2) || ',') ||
                        DECODE(TRIM(ZINSTYPE3),null,'   ,',TRIM(ZINSTYPE3) || ',') ||
                        DECODE(TRIM(ZINSTYPE4),null,'   ',TRIM(ZINSTYPE4))
                 ) ZINSTYPST
           FROM
                 TITDMGINSSTPL@dmstgusr2dblink
           WHERE
                 PLNSETNUM = 2
           UNION ALL 
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                 END chdrnum
                ,PLNSETNUM
                ,DECODE(TRIM(ZINSTYPE1) || TRIM(ZINSTYPE1) || TRIM(ZINSTYPE2) || TRIM(ZINSTYPE3) || TRIM(ZINSTYPE4),null,null,
                        DECODE(TRIM(ZINSTYPE1),null,'   ,',TRIM(ZINSTYPE1) || ',') ||
                        DECODE(TRIM(ZINSTYPE2),null,'   ,',TRIM(ZINSTYPE2) || ',') ||
                        DECODE(TRIM(ZINSTYPE3),null,'   ,',TRIM(ZINSTYPE3) || ',') ||
                        DECODE(TRIM(ZINSTYPE4),null,'   ',TRIM(ZINSTYPE4))
                 ) ZINSTYPST
           FROM
                 TITDMGINSSTPL@dmstgusr2dblink
           WHERE
                 PLNSETNUM = 3
           UNION ALL 
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                 END chdrnum
                ,PLNSETNUM
                ,DECODE(TRIM(ZINSTYPE1) || TRIM(ZINSTYPE1) || TRIM(ZINSTYPE2) || TRIM(ZINSTYPE3) || TRIM(ZINSTYPE4),null,null,
                        DECODE(TRIM(ZINSTYPE1),null,'   ,',TRIM(ZINSTYPE1) || ',') ||
                        DECODE(TRIM(ZINSTYPE2),null,'   ,',TRIM(ZINSTYPE2) || ',') ||
                        DECODE(TRIM(ZINSTYPE3),null,'   ,',TRIM(ZINSTYPE3) || ',') ||
                        DECODE(TRIM(ZINSTYPE4),null,'   ',TRIM(ZINSTYPE4))
                 ) ZINSTYPST
           FROM
                 TITDMGINSSTPL@dmstgusr2dblink
           WHERE
                 PLNSETNUM = 4
           UNION ALL 
           SELECT
                 CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                 END chdrnum
                ,PLNSETNUM
                ,DECODE(TRIM(ZINSTYPE1) || TRIM(ZINSTYPE1) || TRIM(ZINSTYPE2) || TRIM(ZINSTYPE3) || TRIM(ZINSTYPE4),null,null,
                        DECODE(TRIM(ZINSTYPE1),null,'   ,',TRIM(ZINSTYPE1) || ',') ||
                        DECODE(TRIM(ZINSTYPE2),null,'   ,',TRIM(ZINSTYPE2) || ',') ||
                        DECODE(TRIM(ZINSTYPE3),null,'   ,',TRIM(ZINSTYPE3) || ',') ||
                        DECODE(TRIM(ZINSTYPE4),null,'   ',TRIM(ZINSTYPE4))
                 ) ZINSTYPST
           FROM
                 TITDMGINSSTPL@dmstgusr2dblink
           WHERE
                 PLNSETNUM = 5
          )
      WHERE ZINSTYPST IS NOT NULL
     ) src
LEFT JOIN
    (
     ---ig
     SELECT
           CHDRNUM
          ,PLNSETNUM
          ,ZINSTYPST
     FROM
         (
          SELECT
                DISTINCT
                CHDRNUM
               ,1 PLNSETNUM
               ,ZINSTYPST1 ZINSTYPST
          FROM
               ZTGMPF
          WHERE
               TRIM(JOBNM) = 'G1ZDMSTPOL'
          UNION ALL
          SELECT
                DISTINCT
                CHDRNUM
               ,2 PLNSETNUM
               ,ZINSTYPST2 ZINSTYPST
          FROM
               ZTGMPF
          WHERE
               TRIM(JOBNM) = 'G1ZDMSTPOL'
          UNION ALL
          SELECT
                DISTINCT
                CHDRNUM
               ,3 PLNSETNUM
               ,ZINSTYPST3 ZINSTYPST
          FROM
               ZTGMPF
          WHERE
               TRIM(JOBNM) = 'G1ZDMSTPOL'
          UNION ALL
          SELECT
                DISTINCT
                CHDRNUM
               ,4 PLNSETNUM
               ,ZINSTYPST4 ZINSTYPST
          FROM
               ZTGMPF
          WHERE
               TRIM(JOBNM) = 'G1ZDMSTPOL'
          UNION ALL
          SELECT
                DISTINCT
                CHDRNUM
               ,5 PLNSETNUM
               ,ZINSTYPST5 ZINSTYPST
          FROM
               ZTGMPF
          WHERE
               TRIM(JOBNM) = 'G1ZDMSTPOL'
         ) 
     WHERE
         ZINSTYPST IS NOT NULL
    ) ztgmpf
ON
     src.CHDRNUM = ztgmpf.CHDRNUM
AND  src.PLNSETNUM = ztgmpf.PLNSETNUM
WHERE
     src.ZINSTYPST <> ztgmpf.ZINSTYPST
     
----- #18 - 18 (T_7)
SELECT
     src.chdrnum
    ,src.TRANLUSED
    ,gchd.TRANLUSED
FROM
    (
     SELECT
           chdrnum
          ,COUNT(1) TRANLUSED
     FROM
         (
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          UNION ALL
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          WHERE
              statcode = 'CA'
          OR  TRIM(CANCELDT) IS NOT NULL
          UNION ALL
          SELECT
               CASE LENGTH(TRIM(chdrnum)) 
                    WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                    ELSE TRIM(chdrnum)
               END chdrnum
          FROM
              TITDMGMASPOL@dmstgusr2dblink
          WHERE
              statcode = 'LA'
         ) 
     GROUP BY chdrnum
    ) src
LEFT JOIN
     (
      SELECT
            chdrnum
           ,TRANLUSED
      FROM
           GCHD
      WHERE
           CHDRNUM = MPLNUM
      AND  JOBNM = 'G1ZDMSTPOL'
     ) gchd
ON TRIM(src.chdrnum) = gchd.chdrnum
WHERE
     TRIM(src.chdrnum) <> gchd.chdrnum
OR   TRIM(src.TRANLUSED) <> gchd.TRANLUSED
