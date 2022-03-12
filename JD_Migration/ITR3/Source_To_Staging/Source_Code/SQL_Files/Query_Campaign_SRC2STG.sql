--------------------------------------------------------
--Query for Individual Policy Type----------------------
--------------------------------------------------------
SELECT DISTINCT CPBCCD ,RRA2IG , CPEUST ,CPBDCD , CPBECD
FROM ZMRCP00, ZMRRR00, ZMRAP00 WHERE
APEVST = '1'
AND APC1CD = CPBCCD
AND APC7CD = RRBTCD
and RRFOCD = APC6CD;

---------------------------------------------------
--Query for Group Policy Type----------------------
---------------------------------------------------
select CPBCCD, RRA2IG, CPEUST, CPBDCD, 
nvl2(GRP_POLICY_NO_PJ,GRP_POLICY_NO_PJ,CHDRNUM  ) as CHDRNUM,
CPBECD
from
(SELECT DISTINCT CPBCCD ,RRA2IG , CPEUST ,CPBDCD , SUBSTR(MTCHCD,4,9) as CHDRNUM,
CPBECD
FROM ZMRCP00 , ZMRMT00 , ZMRRR00 WHERE
CPBCCD = MTM0CD
AND RRBTCD = MTCECD
AND RRFOCD = MTCGCD
order by SUBSTR(MTCHCD,4,9)
)A LEFT OUTER JOIN grp_policy_free B ON
A.CHDRNUM = SUBSTR(B.grp_policy_no_dm,4,9)
and Rtrim(A.CPBCCD) = RTRIM(B.CAMPAIGN);



