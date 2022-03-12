--- Campaign checks
select * from titdmgcampcde where trim(zpetname) is null;
select * from titdmgcampcde where zpolcls is null;
select distinct zpolcls from titdmgcampcde ;
select * from titdmgcampcde where trim(ZENDCODE) is null;
select * from titdmgcampcde where zpolcls = 'G' and trim(CHDRNUM) is null;
select * from titdmgcampcde where zpolcls = 'I' and trim(GPOLTYP) is null;
select * from titdmgcampcde where zpolcls = 'I' and trim(ZAGPTID) is null;
select * from titdmgcampcde where RCDATE is null;
select * from titdmgcampcde where ZCMPFRM is null;
select * from titdmgcampcde where ZCMPTO is null;
select * from titdmgcampcde where ZMAILDAT is null;
select * from titdmgcampcde where ZDLVCDDT is null;
select * from titdmgcampcde where ZAPPDATE is null;
select * from titdmgcampcde where trim(ZCCODIND) not in ('Y','N');



--- Billing instalment checks


select * from stagedbusr2.titdmgbill1 a where not exists (select 1 from stagedbusr2.titdmgbill2 b
where a.chdrnum = b.chdrnum);-- 3045307  Rows


select * from stagedbusr2.titdmgbill2 a where not exists (select 1 from stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum);-- 3045307  Rows

select * from stagedbusr2.titdmgbill1 a where not exists (select 1 from stagedbusr2.zmrap00 b
where a.chdrnum = substr(b.apcucd,1,8));-- 615159  Rows

select * from stagedbusr2.titdmgbill1 a where (trim(ZPOSBDSY) = '0' or trim(ZPOSBDSM) = '0');-- This will be 
-- updated in the transformation. However if there are records which has cancellation from inception
-- then the PTDATE_BTDATE will not have records -- check with JD


--- To check if the premout flag is properly set 
-- collection successful, premout -> Y
select a.*,b.PSHCDE,b.FACTHOUS from titdmgbill1 a,
 pj_titdmgcolres b,
 dsh_code_ref c
 where a.chdrnum = b.chdrnum
 and a.PRBILFDT = b.PRBILFDT
 and b.PSHCDE = c.PJ_DSHCDE
 and b.FACTHOUS = c.PJ_FACTHOUS
--  and a.chdrnum = '00037052'
 and c.IG_DSHCDE = '00'
 and a.PREMOUT = 'Y';
 
 
  -- collection failure, premout -> N
select a.*,b.PSHCDE from titdmgbill1 a,
 pj_titdmgcolres b
 where a.chdrnum = b.chdrnum
 and a.PRBILFDT = b.PRBILFDT
--  and a.chdrnum = '00037052'
 and b.PSHCDE <> '0'
 and a.PREMOUT = 'N'
 and not exists (select 1 from pj_titdmgcolres c where c.chdrnum = b.chdrnum and c.PRBILFDT = b.PRBILFDT
                 and PSHCDE = 0);
				 
				 
 --- Pending for collection ***** 
 -- Need to join with zendrpf to get teh collection flag is Facthouse 
 
 select distinct (substr(TFRDATE,1,6))from titdmgbill1 a
 where not exists (Select 1 from pj_titdmgcolres b where a.chdrnum = b.chdrnum
 and a.PRBILFDT = b.PRBILFDT)
 order by 1 desc;				 


--- Bill set as Pending for collection but stop bill date is crossed

select a.* from (
select distinct b.APC6CD,c.ZCOLM, case when ZBSTPJDT03 <> '99999999'
then ZBSTPJDT03
when ZBSTPJDT02 <> '99999999'
then ZBSTPJDT02
else ZBSTPJDT01 end stop_bill_date,
a.* --- distinct c.ZCOLM
from titdmgbill1 a,
zmrap00 b,
stagedbusr.zendrpf c,
stagedbusr.zesdpf d
where a.chdrnum = substr(b.apcucd,1,8)
and b.APC6CD = c.zendcde
and c.zendscid = d.zendscid
and d.ZSCHYEAR = '2021'
and d.ZCOVCMDT = a.PRBILFDT
and c.ZCOLM = 'CC'
and trim(a.zcolflag) is null ) a,
stagedbusr.busdpf b
where a.STOP_BILL_DATE < b.BUSDATE
and b.company = 1;


-- check for the FH & CC with premout Y after the collection is successful
-- for FH already the post validation exists


-- check if any duplicate billing period

select CHDRNUM,PRBILFDT, PRBILTDT,count(1) from titdmgbill1
group by CHDRNUM,PRBILFDT, PRBILTDT
having count(1) > 1;



---- after migration to IG



select * from dmigtitdmgbill1 a 
where not exists (select 1 from gbihpf b where a.chdrnum = b.chdrnum);

select * from dmigtitdmgbill1 a 
where not exists (select 1 from gpmdpf b where a.chdrnum = b.chdrnum);

select * from gbidpf where USRPRF = 'JBIRLA' and bprem = 0;

select billno,prodtyp,count(1)
from gbidpf
where USRPRF = 'JBIRLA'
group by billno,prodtyp
having count(1) > 1;

select * from (
with vd as (select a.billno, sum(b.bprem) bill_pr
from gbihpf a,
gbidpf b
where a.billno = b.billno
and a.USRPRF = b.USRPRF 
and  a.USRPRF = 'JBIRLA'
group by a.billno)
select pm.billno,d.bill_pr,sum(pm.pprem) pmprem
from vd d,
gpmdpf pm
where pm.billno = d.billno
and pm.USRPRF = 'JBIRLA'
group by  pm.billno,d.bill_pr)
a
where a.bill_pr <> a.pmprem;





--- Billing refunds 

select * from stagedbusr2.titdmgref1 

select * from stagedbusr2.titdmgref1 a where not exists (select 1 from stagedbusr2.titdmgref2 b
where a.chdrnum = b.chdrnum);

select * from stagedbusr2.titdmgref2 a where not exists (select 1 from stagedbusr2.titdmgref1 b
where a.chdrnum = b.chdrnum);

select * from stagedbusr2.titdmgref1 a where not exists (select 1 from stagedbusr2.zmrap00 b
where a.chdrnum = substr(b.apcucd,1,8));

-- Issue no 9 validation 
select * from titdmgref1 where nrflag is null;


--- Super man check
/* select * from stagedbusr2.titdmgref1 a where not exists (select 1 from stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum
and a.PRBILFDT = b.PRBILFDT);
*/


select a.* from stagedbusr2.titdmgref1 a where not exists (select 1 from stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum
and to_char(to_date(a.PRBILFDT,'yyyymmdd'),'yyyymm') =  to_char(to_date(b.PRBILFDT,'yyyymmdd'),'yyyymm'));


--- refund bills for the premout Y

select * from stagedbusr2.titdmgref1 a where  exists (select 1 from stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum
and a.PRBILFDT = b.PRBILFDT
and b.premout = 'Y');


-- refunds bill from date and to date is not matching with billing from date and to date
-- Issue no 16.. this should be reported and patched as per billing from data and to date

select a.chdrnum,a.PRBILFDT,a.PRBILTDT,b.PRBILFDT,b.PRBILTDT
from stagedbusr2.titdmgref1 a,
stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum
and to_char(to_date(a.PRBILFDT,'yyyymmdd'),'yyyymm') =  to_char(to_date(b.PRBILFDT,'yyyymmdd'),'yyyymm')
and a.PRBILFDT <> b.PRBILFDT;


-- check if there are any duplicate from date for billing refunds

select CHDRNUM,PRBILFDT,count(1)
 from Stagedbusr2.titdmgref1 
 group by CHDRNUM,PRBILFDT
 having count(1) > 1;
 
 

---- after migration to IG Jd1dta


SELECT * FROM dmigtitdmgref1  A 
WHERE NOT EXISTS (SELECT 1 FROM gbihpf B where A.CHDRNUM = B.CHDRNUM AND  billtyp = 'A' and usrprf = 'JBIRLA');

SELECT * FROM dmigtitdmgref1  A 
WHERE NOT EXISTS (SELECT 1 FROM ZREPPF B where A.CHDRNUM = B.CHDRNUM  and usrprf = 'JBIRLA');

SELECT * FROM dmigtitdmgref1  A 
WHERE NOT EXISTS (SELECT 1 FROM gpmdpf B where A.CHDRNUM = B.CHDRNUM  AND  billtyp = 'A' AND usrprf = 'JBIRLA');

select * from (
with vd as (select b.billno, sum(b.ZREFUNDAM) bill_pr
from zreppf a,
zrfdpf b
where a.chdrnum = b.chdrnum
and a.tranno = b.tranno
and a.USRPRF = b.USRPRF 
and  a.USRPRF = 'JBIRLA'
group by b.billno)
select pm.billno,d.bill_pr,abs(sum(pm.pprem)) pmprem
from vd d,
gpmdpf pm
where pm.billno = d.billno
and pm.USRPRF = 'JBIRLA'
group by  pm.billno,d.bill_pr)
a
where a.bill_pr <> a.pmprem;



select * from (
with vd as (select b.billno, sum(b.ZREFUNDAM) bill_pr
from zreppf a,
zrfdpf b
where a.chdrnum = b.chdrnum
and a.tranno = b.tranno
and a.USRPRF = b.USRPRF 
and  a.USRPRF = 'JBIRLA'
group by b.billno)
select pm.billno,d.bill_pr,abs(sum(pm.bprem)) pmprem
from vd d,
gbidpf pm
where pm.billno = d.billno
and pm.USRPRF = 'JBIRLA'
group by  pm.billno,d.bill_pr)
a
where a.bill_pr <> a.pmprem;

-- Super man validation to check if any cancellation which has superman record and the ztrapf PJ transfer tx (zpdatatxdat)
-- is greater than the business date, then it should be validated because those backdated cancellation 
-- may have already had the PJ transfer in DM

select distinct a.chdrnum ,b.zpdatatxdat,c.busdate
from stagedbusr2.titdmgref1_sm@stagedblink a,
Jd1dta.ztrapf b,
Jd1dta.busdpf c
where a.chdrnum = b.chdrnum
and b.zpdatatxdat > c.busdate;


---- Tranno no validation 

select * from stagedbusr.titdmgbill1 a,
STAGEDBUSR2.trannotbl b
where a.chdrnum = b.chdrnum
and a.PRBILFDT = b.PRBILFDT
and b.T_TYPE = 'B'
and a.tranno <> b.tranno;

select * from stagedbusr.titdmgref1 a,
STAGEDBUSR2.trannotbl b
where a.chdrnum = b.chdrnum
and a.PRBILFDT = b.PRBILFDT
and b.T_TYPE = 'R'
and a.tranno <> b.tranno;
