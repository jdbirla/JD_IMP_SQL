--- CLNTNUM	Client Number

with stg_data as (select chdrnum,mbrno,stageclntno 
from stagedbusr.titdmgrnwdt1 t1,
pazdclpf cl
where T1.Stageclntno = cl.zigvalue
and cl.prefix = 'CP')
select stg.chdrnum,
stg.mbrno,
stg.STAGECLNTNO stg_clntnum,
rnd.CLNTNUM ig_CLNTNUM
from zrndtdpf rnd left outer join
stg_data stg on
stg.chdrnum = rnd.chdrnum
and stg.mbrno = rnd.mbrno
where stg.Stageclntno <> rnd.clntnum;


--- ZACCMFLG	Accumulation Fail Flag

select * from (
select CHDRNUM,MBRNO,DPNTNO,
      case when ZRNDTRCD in ('A03','A10') then
        'Y'
      else null
      end  rnd_accflg,
      ZACCMFLG
from ZRNDTDPF)
where RND_ACCFLG <> ZACCMFLG;

--- ZRNDTNUM	Renewal Determination Number


select cov.chdrnum
from zrndtcovpf cov,
zrndthpf rnd
where cov.chdrnum  = rnd.chdrnum
and rnd.zrndtnum <> Cov.zrndtnum;

-- ZINSROLE	Insured Role

select cov.chdrnum
from zrndtcovpf cov,
     zrndtdpf rndt
where cov.chdrnum  = rndt.chdrnum
and cov.mbrno = rndt.mbrno
and rndt.zinsrole <> cov.zinsrole;

-- ZRNDTNUM	Renewal Determination Number


select cov.chdrnum
from zrndtsubcovpf cov,
zrndthpf rnd
where cov.chdrnum  = rnd.chdrnum
and rnd.zrndtnum <> Cov.zrndtnum;

-- ZRNDTNUM	Renewal Determination Numer


select cov.chdrnum
from zodmprmverpf cov,
zrndthpf rnd
where cov.chdrnum  = rnd.chdrnum
and rnd.zrndtnum <> Cov.zrndtnum;

-- CCDATE	Coverage Start date


select cov.chdrnum
from zodmprmverpf cov,
zrndthpf rnd
where cov.chdrnum  = rnd.chdrnum
and rnd.Zrndtfrm <> Cov.ccdate;

-- CRDATE	Coverage end date

select cov.chdrnum
from zodmprmverpf cov,
zrndthpf rnd
where cov.chdrnum  = rnd.chdrnum
and rnd.zrndtto <> Cov.crdate;

select * from STAGEDBUSR.titdmgrnwdt2;
select * from zodmprmverpf;

--- ZINSTYPE	Insurance Type

select pr.chdrnum 
from STAGEDBUSR.titdmgrnwdt2@dmstagedblink t2,
zodmprmverpf pr
where pr.chdrnum = t2.chdrnum
and trim(pr.zinstype) <> trim(t2.zinstype);




----- ZODMPRMVER	ODM Premium Version


with stg_data as (
select cov.chdrnum,odm.zinstype stg_instyp, odm.verno stg_odmprmve
from Jd1dta.Dmigtitdmgrnwdt2_Int cov
join dmigodmversionhis odm on odm.zinstype = cov.zinstype
and (cov.zrndtfrm  Between odm.frmdte  and  odm.todte)
and cov.indic = 'S')
select ig.chdrnum,
       ig.zodmprmver ig_odmprmve,
       stg.stg_odmprmve
from zodmprmverpf ig,
     stg_data stg
where ig.chdrnum = stg.chdrnum
and ig.Zinstype = stg.stg_instyp
and ig.zodmprmver <> stg.stg_odmprmve;



--- ZINSRNWAGE	Insured age at Renewal


select * from (
select zrnh.chdrnum,zrnd.mbrno,b.cltdob,
floor(months_between(to_date(zrnh.ZRNDTFRM,'YYYYMMDD'),To_Date(B.Cltdob,'YYYYMMDD'))/12) cal_Age
,zinsrnwage ig_age
from zrndthpf zrnh,
zrndtdpf zrnd,
(select clpf.clntnum,clpf.cltdob,max(clpf.effdate) effdate 
from zclnpf clpf
group by  clpf.clntnum,clpf.cltdob) b
where b.CLNTNUM = zrnd.CLNTNUM
and zrnh.chdrnum = zrnd.chdrnum
and b.effdate <= zrnh.zrndtfrm)
where cal_age <> ig_age;


--- ZRNDTDPF	ZSALPLAN	Sales Plan



with stg_data as (
select t1.chdrnum,t1.mbrno,sp.zplancde
from stagedbusr.titdmgrnwdt1 t1,
(select chdrnum,mbrno,zplancde, max(effdate) effdate from zinsdtlspf  group by chdrnum,mbrno,zplancde) sp
where sp.chdrnum = t1.chdrnum
and sp.mbrno = t1.mbrno
and t1.zrndtfrm >= sp.effdate)
select ig.chdrnum,ig.mbrno,ig.Zsalplan
from stg_data sd,
     zrndtdpf ig
where ig.chdrnum = sd.chdrnum
and ig.mbrno = sd.mbrno
and ig.zsalplan <> sd.zplancde;
