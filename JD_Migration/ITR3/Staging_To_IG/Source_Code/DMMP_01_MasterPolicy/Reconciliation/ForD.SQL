--- #1 - 8 (D_1)---
SELECT
      src_chdrnum ---#1
     ,src_CNTTYPE ---#2
     ,src_STATCODE ---#3
     ,src_OCCDATE ---#4
     ,src_PNDATE ---#5
     ,src_ZENDCDE ---#6
     ,src_RRA2IG ---#7
     ,src_B8TJIG ---#8
     ,src_zpenddt 
     ,NULL src_EFFDATE
     ,NULL src_CCDATE
     ,NULL src_ZAGPTNUM
     ,NULL src_ZBLNKPOL
     ,NULL src_ZNBALTPR
     ,NULL src_ZBLADCD
     ,NULL src_ZCRDTYPE
     ,NULL src_ZCNBRFRM
     ,NULL src_ZCNBRTO
     ,NULL src_ZMSTID
     ,NULL src_ZMSTSNME
     ,NULL src_ZCCDE
     ,NULL src_ZCONSGNM
     ,NULL src_ZMSTIDV
     ,NULL src_ZMSTSNMEV
     ,NULL src_ZCARDDC
     ,gchd_CNTTYPE ---#2
     ,gchd_STATCODE ---#3
     ,gchd_OCCDATE ---#4
     ,gchd_PNDATE ---#5
     ,gchppf_ZENDCDE ---#6
     ,gchppf_PETNAME ---#7
     ,gchppf_ZGRPCLS ---#8
     ,gchppf_zpenddt
     ,NULL gchipf_EFFDATE
     ,NULL gchipf_CCDATE
     ,NULL gchipf_ZAGPTNUM
     ,NULL ztgmpf_ZBLNKPOL
     ,NULL ztgmpf_ZNBALTPR
     ,NULL zenctpf_ZBLADCD
     ,NULL zenctpf_ZCRDTYPE
     ,NULL zenctpf_ZCNBRFRM
     ,NULL zenctpf_ZCNBRTO
     ,NULL zenctpf_ZMSTID
     ,NULL zenctpf_ZMSTSNME
     ,NULL zenctpf_ZCCDE
     ,NULL zenctpf_ZCONSGNM
     ,NULL zenctpf_ZMSTIDV
     ,NULL zenctpf_ZMSTSNMEV
     ,NULL zenctpf_ZCARDDC
FROM
     (
      SELECT
            TRIM(src1.chdrnum)  src_chdrnum ---#1
           ,TRIM(src1.CNTTYPE)  src_CNTTYPE     ---#2
           ,TRIM(src1.STATCODE) src_STATCODE     ---#3
           ,TRIM(src2.MIN_OCCDATE)  src_OCCDATE     ---#4
           ---,TRIM(src2.MAX_OCCDATE)  src_MAX_OCCDATE     ---#4
           ,TRIM(src1.PNDATE)   src_PNDATE     ---#5
           ,TRIM(src1.ZENDCDE)  src_ZENDCDE     ---#6
           ,TRIM(src1.RRA2IG)   src_RRA2IG     ---#7
           ,TRIM(src1.B8TJIG)   src_B8TJIG     ---#8
           ,TRIM(src1.zpenddt)   src_zpenddt     ---#8
      FROM
           (
            SELECT
                  CASE LENGTH(TRIM(chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                       ELSE TRIM(chdrnum)
                  END chdrnum  ---#1
                 ,CNTTYPE      ---#2
                 ,STATCODE     ---#3
                 ,OCCDATE  ---#4
                 ,PNDATE       ---#5
                 ,ZENDCDE      ---#6
                 ,RRA2IG       ---#7
                 ,B8TJIG       ---#8
                 ,zpenddt
            FROM
                 TITDMGMASPOL@dmstgusr2dblink
           )  src1
           INNER JOIN
          (
           SELECT
                CHDRNUM 
               ,CNTTYPE
               ,MAX(OCCDATE) MAX_OCCDATE
               ,MIN(OCCDATE) MIN_OCCDATE
           FROM
               (
                SELECT
                     CASE LENGTH(TRIM(chdrnum)) 
                          WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                          ELSE TRIM(chdrnum)          
                     END chdrnum       
                    ,CNTTYPE
                    ,OCCDATE
                FROM
                    TITDMGMASPOL@dmstgusr2dblink
               ) 
           GROUP BY
                CHDRNUM 
               ,CNTTYPE
          ) src2
      ON
          TRIM(src1.CHDRNUM) = TRIM(src2.CHDRNUM)
      AND TRIM(src1.CNTTYPE) = TRIM(src2.CNTTYPE)
      AND TRIM(src1.OCCDATE) = TRIM(src2.MAX_OCCDATE)
     ) src
LEFT JOIN 
    (
     SELECT
           TRIM(CHDRNUM)  gchd_CHDRNUM
          ,TRIM(CNTTYPE)  gchd_CNTTYPE
          ,TRIM(STATCODE) gchd_STATCODE
          ,TRIM(OCCDATE)  gchd_OCCDATE
          ,TRIM(PNDATE)  gchd_PNDATE
     FROM
          GCHD
     WHERE
          CHDRNUM = MPLNUM
     AND  JOBNM = 'G1ZDMSTPOL'
     ) gchd
ON gchd.gchd_CHDRNUM = src.src_chdrnum
LEFT JOIN
    (
     SELECT
           TRIM(CHDRNUM)  gchppf_CHDRNUM
          ,TRIM(ZENDCDE)  gchppf_ZENDCDE
          ,TRIM(PETNAME)  gchppf_PETNAME
          ,TRIM(ZGRPCLS) gchppf_ZGRPCLS
          ,TRIM(zpenddt) gchppf_zpenddt
     FROM
         GCHPPF
     WHERE
         JOBNM = 'G1ZDMSTPOL'
    ) gchppf
ON gchppf.gchppf_CHDRNUM = src.src_chdrnum
WHERE
    src.src_chdrnum <> gchd.gchd_chdrnum
OR  src.src_CNTTYPE <> gchd.gchd_CNTTYPE
OR  src.src_STATCODE <> gchd.gchd_STATCODE
OR  src.src_OCCDATE <> gchd.gchd_OCCDATE
OR  src.src_PNDATE <> gchd.gchd_PNDATE
OR  src.src_ZENDCDE <> gchppf.gchppf_ZENDCDE
OR  src.src_RRA2IG <> gchppf.gchppf_PETNAME
OR  src.src_B8TJIG <> gchppf.gchppf_ZGRPCLS
OR  src.src_zpenddt <> gchppf.gchppf_zpenddt

--- #9 - 16 (D_2)---
SELECT
      src_chdrnum
     ,NULL src_CNTTYPE
     ,NULL src_STATCODE
     ,NULL src_OCCDATE
     ,NULL src_PNDATE
     ,NULL src_ZENDCDE
     ,NULL src_RRA2IG
     ,NULL src_B8TJIG
     ,src_EFFDATE   --- #9
     ,src_CCDATE   --- #10
     ,src_ZAGPTNUM   --- #11
     ,src_ZBLNKPOL   --- #12
     ,src_ZNBALTPR   --- #13
     ,src_ZBLADCD   --- #14
     ,NULL src_ZCRDTYPE
     ,NULL src_ZCNBRFRM
     ,NULL src_ZCNBRTO
     ,NULL src_ZMSTID
     ,NULL src_ZMSTSNME
     ,src_ZCCDE  --- #15
     ,src_ZCONSGNM  ---#16
     ,NULL src_ZMSTIDV
     ,NULL src_ZMSTSNMEV
     ,NULL src_ZCARDDC
     ,NULL gchd_CNTTYPE
     ,NULL gchd_STATCODE
     ,NULL gchd_OCCDATE
     ,NULL gchd_PNDATE
     ,NULL gchppf_ZENDCDE
     ,NULL gchppf_PETNAME
     ,NULL gchppf_ZGRPCLS
     ,gchipf_EFFDATE   --- #9
     ,gchipf_CCDATE   --- #10
     ,gchipf_ZAGPTNUM   --- #11
     ,ztgmpf_ZBLNKPOL   --- #12
     ,ztgmpf_ZNBALTPR   --- #13
     ,zenctpf_ZBLADCD   --- #14
     ,NULL zenctpf_ZCRDTYPE
     ,NULL zenctpf_ZCNBRFRM
     ,NULL zenctpf_ZCNBRTO
     ,NULL zenctpf_ZMSTID
     ,NULL zenctpf_ZMSTSNME
     ,zenctpf_ZCCDE  --- #15
     ,zenctpf_ZCONSGNM  ---#16
     ,NULL zenctpf_ZMSTIDV
     ,NULL zenctpf_ZMSTSNMEV
     ,NULL zenctpf_ZCARDDC
FROM
     (
      SELECT
           CASE LENGTH(TRIM(chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                ELSE TRIM(chdrnum)
           END src_chdrnum
          ,TRIM(EFFDATE) src_EFFDATE
          ,TRIM(CCDATE) src_CCDATE
          ,TRIM(ZAGPTNUM) src_ZAGPTNUM
          ,TRIM(ZBLNKPOL) src_ZBLNKPOL
          ,TRIM(ZNBALTPR) src_ZNBALTPR
          ,TRIM(ZBLADCD) src_ZBLADCD
          ,TRIM(ZCCDE) src_ZCCDE
          ,TRIM(ZCONSGNM) src_ZCONSGNM
      FROM
          TITDMGMASPOL@dmstgusr2dblink
     ) src
LEFT JOIN
    (
     SELECT
           TRIM(chdrnum) gchipf_chdrnum
          ,TRIM(EFFDATE) gchipf_EFFDATE
          ,TRIM(CCDATE) gchipf_CCDATE
          ,TRIM(ZAGPTNUM) gchipf_ZAGPTNUM
     FROM
          GCHIPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) gchipf
ON 
    TRIM(src.src_chdrnum) = TRIM(gchipf.gchipf_chdrnum)
AND TRIM(src.src_CCDATE) = TRIM(gchipf.gchipf_CCDATE)
LEFT JOIN
    (
     SELECT
           TRIM(chdrnum) ztgmpf_chdrnum
          ,TRIM(ZBLNKPOL) ztgmpf_ZBLNKPOL
          ,TRIM(ZNBALTPR) ztgmpf_ZNBALTPR
          ,TRIM(EFFDATE) ztgmpf_EFFDATE
     FROM
          ZTGMPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) ztgmpf
ON 
    TRIM(src.src_chdrnum) = TRIM(ztgmpf.ztgmpf_chdrnum)
AND TRIM(src.src_CCDATE) = TRIM(ztgmpf.ztgmpf_EFFDATE)
LEFT JOIN
    (
     SELECT
           TRIM(ZPOLNMBR) zenctpf_chdrnum
          ,TRIM(ZBLADCD) zenctpf_ZBLADCD
          ,TRIM(ZCCDE) zenctpf_ZCCDE
          ,TRIM(ZCONSGNM) zenctpf_ZCONSGNM
     FROM
          ZENCTPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) zenctpf
ON 
    TRIM(src.src_chdrnum) = TRIM(zenctpf.zenctpf_chdrnum)
WHERE
    src_EFFDATE <> gchipf_EFFDATE
OR  src_CCDATE <> gchipf_CCDATE
OR  src_ZAGPTNUM <> gchipf_ZAGPTNUM
OR  DECODE(src_ZNBALTPR,NULL,' ',src_ZNBALTPR) <> DECODE(ztgmpf_ZNBALTPR,NULL,' ',ztgmpf_ZNBALTPR)
OR  DECODE(src_ZBLADCD,NULL,' ',src_ZBLADCD) <> DECODE(zenctpf_ZBLADCD,NULL,' ',zenctpf_ZBLADCD)
OR  DECODE(src_ZCCDE,NULL,' ',src_ZCCDE) <> DECODE(zenctpf_ZCCDE,NULL,' ',zenctpf_ZCCDE)
OR  DECODE(src_ZCONSGNM,NULL,' ',src_ZCONSGNM) <> DECODE(zenctpf_ZCONSGNM,NULL,' ',zenctpf_ZCONSGNM)

--- #17 - 24 (D_3)-
SELECT
      src_chdrnum
     ,NULL src_CNTTYPE
     ,NULL src_STATCODE
     ,NULL src_OCCDATE
     ,NULL src_PNDATE
     ,NULL src_ZENDCDE
     ,NULL src_RRA2IG
     ,NULL src_B8TJIG
     ,NULL src_EFFDATE
     ,NULL src_CCDATE
     ,NULL src_ZAGPTNUM
     ,NULL src_ZBLNKPOL
     ,NULL src_ZNBALTPR
     ,NULL src_ZBLADCD
     ,src_ZCRDTYPE   --- #17
     ,src_ZCNBRFRM   --- #18
     ,src_ZCNBRTO   --- #19
     ,src_ZMSTID   --- #20
     ,src_ZMSTSNME   --- #21
     ,NULL src_ZCCDE
     ,NULL src_ZCONSGNM
     ,src_ZMSTIDV   --- #22
     ,src_ZMSTSNMEV   --- #23
     ,src_ZCARDDC   --- #24
     ,NULL gchd_CNTTYPE 
     ,NULL gchd_STATCODE
     ,NULL gchd_OCCDATE 
     ,NULL gchd_PNDATE 
     ,NULL gchppf_ZENDCDE 
     ,NULL gchppf_PETNAME 
     ,NULL gchppf_ZGRPCLS 
     ,NULL gchipf_EFFDATE
     ,NULL gchipf_CCDATE
     ,NULL gchipf_ZAGPTNUM
     ,NULL ztgmpf_ZBLNKPOL
     ,NULL ztgmpf_ZNBALTPR
     ,NULL zenctpf_ZBLADCD
     ,zenctpf_ZCRDTYPE   --- #17
     ,zenctpf_ZCNBRFRM   --- #18
     ,zenctpf_ZCNBRTO   --- #19
     ,zenctpf_ZMSTID   --- #20
     ,zenctpf_ZMSTSNME   --- #21
     ,NULL zenctpf_ZCCDE
     ,NULL zenctpf_ZCONSGNM
     ,zenctpf_ZMSTIDV   --- #22
     ,zenctpf_ZMSTSNMEV   --- #23
     ,zenctpf_ZCARDDC   --- #24
FROM
     (
      SELECT
           CASE LENGTH(TRIM(src1.chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(src1.chdrnum),4,8)
                ELSE TRIM(src1.chdrnum)
           END src_chdrnum
          ,TRIM(src1.ZCRDTYPE) src_ZCRDTYPE
          ,TRIM(src1.ZCNBRFRM) src_ZCNBRFRM
          ,TRIM(src1.ZCNBRTO) src_ZCNBRTO
          ,TRIM(src1.ZMSTID) src_ZMSTID
          ,TRIM(src1.ZMSTSNME) src_ZMSTSNME
          ,TRIM(src1.ZMSTIDV) src_ZMSTIDV
          ,TRIM(src1.ZMSTSNMEV) src_ZMSTSNMEV
          ,TRIM(src1.ZCARDDC) src_ZCARDDC
          ---,TRIM(src3.ZFACTHUS) ZFACTHUS  ---@@
          ----,TRIM(src3.zcolmcls) zcolmcls  ---@@
      FROM
          TITDMGENDCTPF@dmstgusr2dblink src1
      INNER JOIN
           (
            SELECT
                  CASE LENGTH(TRIM(mstpol.chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(mstpol.chdrnum),4,8)
                       ELSE TRIM(mstpol.chdrnum)
                  END chdrnum
                 ,TRIM(mstpol.ZENDCDE) ZENDCDE
                 ,TRIM(src2.ZFACTHUS) ZFACTHUS
                 ,TRIM(src2.zcolmcls) zcolmcls
            FROM
                 TITDMGMASPOL@dmstgusr2dblink mstpol
            LEFT JOIN
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
                  ) src2
            ON TRIM(mstpol.ZENDCDE) = TRIM(src2.ZENDCDE)
           ) src3
           ON 
               TRIM(src1.chdrnum) = TRIM(src3.chdrnum)
           AND TRIM(src3.zcolmcls) = 'C'
     ) src
LEFT JOIN
    (
     SELECT
          TRIM(ZPOLNMBR) zenctpf_chdrnum
         ,TRIM(ZCRDTYPE) zenctpf_ZCRDTYPE
         ,TRIM(ZCNBRFRM) zenctpf_ZCNBRFRM
         ,TRIM(ZCNBRTO) zenctpf_ZCNBRTO
         ,TRIM(ZMSTID) zenctpf_ZMSTID
         ,TRIM(ZMSTSNME) zenctpf_ZMSTSNME
         ,TRIM(ZMSTIDV) zenctpf_ZMSTIDV
         ,TRIM(ZMSTSNMEV) zenctpf_ZMSTSNMEV
         ,TRIM(ZCARDDC) zenctpf_ZCARDDC
     FROM
         ZENCTPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
   ) zenctpf
ON
    TRIM(src.src_chdrnum) = TRIM(zenctpf.zenctpf_chdrnum)
AND DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) = DECODE(zenctpf_ZCRDTYPE,NULL,' ',zenctpf_ZCRDTYPE)
AND DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) = DECODE(zenctpf_ZCNBRFRM,NULL,' ',zenctpf_ZCNBRFRM)
AND DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) = DECODE(zenctpf_ZCNBRTO,NULL,' ',zenctpf_ZCNBRTO)
AND DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) = DECODE(zenctpf_ZMSTID,NULL,' ',zenctpf_ZMSTID)
AND DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) = DECODE(zenctpf_ZMSTSNME,NULL,' ',zenctpf_ZMSTSNME)
AND DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) = DECODE(zenctpf_ZMSTIDV,NULL,' ',zenctpf_ZMSTIDV)
AND DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) = DECODE(zenctpf_ZMSTSNMEV,NULL,' ',zenctpf_ZMSTSNMEV)
AND DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) = DECODE(zenctpf_ZCARDDC,NULL,' ',zenctpf_ZCARDDC)
WHERE
    DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) <> DECODE(zenctpf_ZCRDTYPE,NULL,' ',zenctpf_ZCRDTYPE)
OR  DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) <> DECODE(zenctpf_ZCNBRFRM,NULL,' ',zenctpf_ZCNBRFRM)
OR  DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) <> DECODE(zenctpf_ZCNBRTO,NULL,' ',zenctpf_ZCNBRTO)
OR  DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) <> DECODE(zenctpf_ZMSTID,NULL,' ',zenctpf_ZMSTID)
OR  DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) <> DECODE(zenctpf_ZMSTSNME,NULL,' ',zenctpf_ZMSTSNME)
OR  DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) <> DECODE(zenctpf_ZMSTIDV,NULL,' ',zenctpf_ZMSTIDV)
OR  DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) <> DECODE(zenctpf_ZMSTSNMEV,NULL,' ',zenctpf_ZMSTSNMEV)
OR  DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) <> DECODE(zenctpf_ZCARDDC,NULL,' ',zenctpf_ZCARDDC)