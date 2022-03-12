create or replace PROCEDURE             dm_load_policy_recon(o_err_code out number,o_err_msg out varchar2) is 
PRAGMA autonomous_transaction;


BEGIN
o_err_code:= 0;
o_err_msg := '';

insert into stagedbusr2.dm_policy_recon (
select POLICY_NO, PROD_CODE, POLICY_START_DATE,
POLICY_END_DATE POLICY_END_DATE,
POLICY_STATUS, ALT_CNT, to_char(REN_CNT,'fm09') REN_CNT,
'IND_MEMBER' POL_TYPE
from (
select distinct substr(a.APCUCD,1,8) policy_no,
APC7CD prod_code,
APA2DT policy_start_date,
APBEDT policy_end_date,
a.APCUCD,
to_number(substr(a.apcucd, 9, 2)) ren,
 to_number(substr(a.apcucd, 11, 1)) alt,
max(to_number(substr(a.apcucd, 9, 2))) over (partition by substr(a.APCUCD,1,10)) ren_cnt,
max(to_number(substr(a.apcucd, 11, 1))) over (partition by substr(a.APCUCD,1,10)) alt_cnt,
-- APA8ST policy_status,
/*
CASE
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
  
END Policy_status
*/
e.STATCODE Policy_status
from stagedbusr2.ZMRAP00 a
left outer join stagedbusr2.policy_statcode e on substr(a.apcucd, 1, 8) = e.chdrnum
LEFT outer JOIN stagedbusr2.zmrrpt00  c ON a.apc7cd = c.rptbtcd
LEFT OUTER JOIN stagedbusr2.btdate_ptdate_list pj ON substr(a.apcucd, 1, 8) = pj.chdrnum
-- where substr(a.apcucd, 1, 8) = '10331A69'
where a.apblst in ('1','2','3','5')
)
where 
 alt = alt_cnt 
AND ren = ren_cnt
union all
select chdrnum,cnttype,ccdate, crdate,statcode, NULL n_alt_cnt,NULL n_ren_cnt
,'MASTER' POL_TYPE
from stagedbusr2.Titdmgmaspol
);

o_err_code := 0;
o_err_msg := 'Success';

commit;

exception when others then
rollback;

o_err_code := sqlcode;
o_err_msg := sqlerrm;



END DM_LOAD_POLICY_RECON;