--VALIDATION QUERY:

--NULL VALUES
SELECT  /*csv*/
      table_name, apcucd, 
      DECODE(TRIM(LSURNAME),      null, 'Y', 'N') AS LSURNAME,
      DECODE(TRIM(LGIVNAME),      null, 'Y', 'N') AS LGIVNAME,
      DECODE(TRIM(ZKANAGIVNAME),  null, 'Y', 'N') AS ZKANAGIVNAME,
      DECODE(TRIM(ZKANASURNAME),  null, 'Y', 'N') AS ZKANASURNAME,
      DECODE(TRIM(CLTPCODE),      null, 'Y', 'N') AS CLTPCODE,
      DECODE(TRIM(CLTADDR01),     null, 'Y', 'N') AS CLTADDR01,
      DECODE(TRIM(CLTADDR02),     null, 'Y', 'N') AS CLTADDR02,
      DECODE(TRIM(ZKANADDR01),    null, 'Y', 'N') AS ZKANADDR01,
      DECODE(TRIM(ZKANADDR02),    null, 'Y', 'N') AS ZKANADDR02,
      DECODE(TRIM(CLTSEX),        null, 'Y', 'N') AS CLTSEX,
      DECODE(TRIM(CLTPHONE01),    null, 'Y', 'N') AS CLTPHONE01,
      DECODE(TRIM(CLTDOB),        null, 'Y', 'N') AS CLTDOB
    FROM
            (
                SELECT
                    'ZMRAP00'  AS table_name,
                    a.apcucd        AS apcucd,
                    substr(a.apcucd, - 3) AS zseqno,
                    a.apa2dt        AS effdate,
                    TRIM(substr((TRIM(a.apcbig)), 1,(
                          CASE
                              WHEN instr(TRIM(a.apcbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.apcbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.apcbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.apcbig), ' ')
                              ELSE
                                  instr(TRIM(a.apcbig), '?')
                          END
                    ) - 1))  lsurname,
                 
                    TRIM(substr((TRIM(a.apcbig)),(
                          CASE
                              WHEN instr(TRIM(a.apcbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.apcbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.apcbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.apcbig), ' ')
                              ELSE
                                  instr(TRIM(a.apcbig), '?')
                          END
                    ) + 1)) lgivname,
                    nvl(TRIM(substr((TRIM(a.apb5tx)), instr((TRIM(a.apb5tx)), ' ') + 1)), ' ') AS zkanagivname,
                    nvl(TRIM(substr((TRIM(a.apb5tx)), 1, instr((TRIM(a.apb5tx)), ' ') - 1)), ' ') AS zkanasurname,
                    a.apc9cd        AS cltpcode,
                    regexp_replace(a.apc9cd, '\D', '') AS  cln_cltpcode,
                    a.apb7ig        AS cltaddr01,
                    a.apb8ig        AS cltaddr02,
                    a.apb9ig        AS cltaddr03,
                    ( CASE
                        WHEN a.apb1tx IS NULL AND k.kana1 IS NOT NULL THEN
                          k.kana1
                        WHEN a.apb1tx = ' ' AND k.kana1 IS NOT NULL THEN
                          k.kana1
                        ELSE
                          a.apb0tx
                    END ) AS zkanaddr01,
                    ( CASE
                        WHEN a.apb1tx IS NULL AND k.kana2 IS NOT NULL THEN
                          k.kana2
                        WHEN a.apb1tx = ' ' AND k.kana2 IS NOT NULL THEN
                          k.kana2
                        ELSE
                          a.apb1tx
                    END ) AS zkanaddr02,
                    decode(a.apbast, '1', 'M', '2', 'F') AS cltsex,
                    NULL AS addrtype,
                    a.apb4tx        AS cltphone01,
                    regexp_replace(a.apb4tx, '\D', '') AS  cln_cltphone01,
                    a.apb9tx        AS cltphone02,
                    b.iscpcd        AS occpcode,
                    a.apa3dt        AS cltdob,
                    b.isb1ig        AS zoccdsc,
                    substr(a.apcdig, 1, 25) AS zworkplce,
                    a.apdlcd        AS zaltrcde01,
					decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
					a.apc6cd        AS zendcde
              FROM
                (
                    SELECT
                        a.*,
                        concat(substr(apcucd, 1, 10), MIN(substr(apcucd, - 1)) OVER(
                            PARTITION BY substr(apcucd, 1, 10)
                        )) min_apcucd,
                        concat(substr(apcucd, 1, 10), MAX(substr(apcucd, - 1)) OVER(
                            PARTITION BY substr(apcucd, 1, 10)
                        )) max_apcucd
                    FROM
                        zmrap00 a 
                    WHERE (a.apblst IN (1,3,5) 
                                      OR a.apdlcd IN ('N1','NS','N7','N4'))
                ) a
                LEFT OUTER JOIN zmris00           b ON a.apcucd = b.iscucd
                                                      AND b.isa4st = '1'
                LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                LEFT OUTER JOIN kana_address_list k ON a.apc9cd = k.postalcd
                WHERE
                    ( a.apcucd = a.min_apcucd AND apblst IN (1,3, 5) )
                    OR apdlcd IN ('N1','NS','N7','N4')
                    
                UNION ALL
                
                SELECT
                    'ZMRIS00/ZMRISA00'  AS table_name,
                    a.apcucd        AS apcucd,
                    substr(a.apcucd, - 3) AS zseqno,
                    a.apa2dt        AS effdate,
                    TRIM(substr((TRIM(b.isbvig)), 1,(
                          CASE
                              WHEN instr(TRIM(b.isbvig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(b.isbvig), unistr('\3000')) 
                              WHEN instr(TRIM(b.isbvig), ' ')  <> 0 THEN
                                  instr(TRIM(b.isbvig), ' ')
                              ELSE
                                  instr(TRIM(b.isbvig), '?')
                          END
                    ) - 1))   AS lsurname,
                    TRIM(substr((TRIM(b.isbvig)),(
                          CASE
                              WHEN instr(TRIM(b.isbvig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(b.isbvig), unistr('\3000')) 
                              WHEN instr(TRIM(b.isbvig), ' ')  <> 0 THEN
                                  instr(TRIM(b.isbvig), ' ')
                              ELSE
                                  instr(TRIM(b.isbvig), '?')
                          END
                    ) + 1)) AS lgivname,
                    nvl(TRIM(substr((TRIM(b.isbtig)), instr((TRIM(b.isbtig)), ' ') + 1)), ' ') AS zkanagivname,
                    nvl(TRIM(substr((TRIM(b.isbtig)), 1, instr((TRIM(b.isbtig)), ' ') - 1)), ' ') AS zkanasurname,
                    c.isac9cd AS cltpcode,
                    regexp_replace(c.isac9cd, '\D', '') AS  cln_cltpcode,
                    c.isab7ig AS cltaddr01,
                    c.isab8ig AS cltaddr02,
                    c.isab9ig AS cltaddr03,
                    ( CASE
                        WHEN c.isab0tx IS NULL AND k.kana1 IS NOT NULL THEN
                          k.kana1
                        WHEN c.isab0tx = ' ' AND k.kana1 IS NOT NULL THEN
                          k.kana1
                        ELSE
                          c.isab0tx
                    END ) AS zkanaddr01,
                    ( CASE
                        WHEN c.isab1tx IS NULL AND k.kana2 IS NOT NULL THEN
                          k.kana2
                        WHEN c.isab1tx = ' ' AND k.kana2 IS NOT NULL THEN
                          k.kana2
                        ELSE
                          c.isab1tx
                    END ) AS zkanaddr02,
                    decode(b.isa3st, '1', 'M', '2', 'F') AS cltsex,
                    NULL AS addrtype,
                    c.isab4tx AS cltphone01,
                    regexp_replace(c.isab4tx, '\D', '') cln_cltphone01,
                    b.isbytx        AS cltphone02,
                    b.iscpcd        AS occpcode,
                    b.isatdt        AS cltdob,
                    b.isb1ig        AS zoccdsc,
                    substr(b.isbzig, 1, 25) AS zworkplce,
                    a.apdlcd        AS zaltrcde01,
                    decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
                    a.apc6cd        AS zendcde
                FROM
                (
                    SELECT
                        a.*,
                        concat(substr(apcucd, 1, 10), MIN(substr(apcucd, - 1)) OVER(
                            PARTITION BY substr(apcucd, 1, 10)
                        )) min_apcucd,
                        concat(substr(apcucd, 1, 10), MAX(substr(apcucd, - 1)) OVER(
                            PARTITION BY substr(apcucd, 1, 10)
                        )) max_apcucd
                    FROM
                        zmrap00 a 
                    WHERE (a.apblst IN (1,3,5 ) 
                                OR a.apdlcd IN ('N7','ND','N6','N4'))
                ) a
                INNER JOIN zmris00                b ON b.iscucd = a.apcucd
                                                        AND b.isa4st <> '1'
                LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                LEFT OUTER JOIN kana_address_list k ON c.isac9cd = k.postalcd
                WHERE
                    b.isa4st <> 1
                    AND ( a.apcucd = min_apcucd 
                          AND apblst IN (1,3, 5 ) )
                    OR a.apdlcd IN ('N7','ND','N6', 'N4')
            ) WHERE LSURNAME is null OR 
              LGIVNAME is null OR 
              ZKANAGIVNAME is null OR 
              ZKANASURNAME is null OR 
              cln_CLTPCODE is null OR 
              CLTADDR01 is null OR 
              CLTADDR02 is null OR 
              ZKANADDR01 is null OR 
              ZKANADDR02 is null OR 
              CLTSEX is null OR 
              cln_cltphone01 is null OR 
              CLTDOB is null 
        ORDER BY
            apcucd,
            zseqno;
			


--Missing Insured Details in ZMRISA00
select * from  zmris00 where ISA4ST <> 1 and ISCICD not in (select zmrisa00.isacicd from zmrisa00); 

--Relationship Issue
SELECT iscucd,  iscicd,  isa4st
FROM zmris00
WHERE ISCICD IN
  (SELECT ISCICD FROM
    (SELECT (SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2)) AS Policy_Insured,
      ISCICD,
      ISA4ST
    FROM zmris00
    WHERE (SUBSTR(ISCICD, 1,8)|| SUBSTR(ISCICD, -2)) IN
      (SELECT a FROM
          (SELECT a, COUNT(b)
               FROM
                ( SELECT DISTINCT SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2) AS a, ISA4ST AS b
                    FROM stagedbusr2.zmris00 )
            GROUP BY a
            HAVING COUNT(b) > 1
        )
      )
    )
  )
ORDER BY 1,2;


--Missing records in ZMRISA00 after relationship fix for 1
select a.ISCUCD, 
a.ISCICD, 
b.ISAA4ST,
b.ISAFLAG,
b.ISAC9CD,
b.ISADICD,
b.ISAB0TX,
b.ISAB1TX,
b.ISAB2TX,
b.ISAB3TX,
b.ISAB7IG,
b.ISAB8IG,
b.ISAB9IG,
b.ISACAIG,
b.ISAB4TX,
b.ISAYOB1,
b.ISAYOB2,
b.ISAYOB3,
b.ISAYOB4,
b.ISAYOB5,
b.ISAYOB6,
b.ISAYOB7,
b.ISAYOB8,
b.ISABOCD,
b.ISABPCD,
b.ISAAMDT,
b.ISAAATM,
b.ISABQCD,
b.ISAANDT,
b.ISAABTM,
b.ISABRCD,
b.ISAB6IG
from  stagedbusr2.zmris00 a , stagedbusr2.zmrisa00 b where a.ISA4ST <>1 and a.ISCICD  in (select isacicd from stagedbusr2.zmrisa00)
and (substr(a.ISCUCD, 1,10) || 1) = b.ISACUCD;

--Missing records in ZMRISA00 after relationship fix for 3
select a.ISCUCD, 
a.ISCICD, 
b.ISAA4ST,
b.ISAFLAG,
b.ISAC9CD,
b.ISADICD,
b.ISAB0TX,
b.ISAB1TX,
b.ISAB2TX,
b.ISAB3TX,
b.ISAB7IG,
b.ISAB8IG,
b.ISAB9IG,
b.ISACAIG,
b.ISAB4TX,
b.ISAYOB1,
b.ISAYOB2,
b.ISAYOB3,
b.ISAYOB4,
b.ISAYOB5,
b.ISAYOB6,
b.ISAYOB7,
b.ISAYOB8,
b.ISABOCD,
b.ISABPCD,
b.ISAAMDT,
b.ISAAATM,
b.ISABQCD,
b.ISAANDT,
b.ISAABTM,
b.ISABRCD,
b.ISAB6IG
 from  stagedbusr2.zmris00 a , stagedbusr2.zmrisa00 b where a.ISA4ST <>1 and a.ISCICD not in (select isacicd from stagedbusr2.zmrisa00)
and (substr(a.ISCUCD, 1,10) || 3) = b.ISACUCD;  
