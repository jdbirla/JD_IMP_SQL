select * from (
with v_data as (
select a.chdrnum ,a.tranno,sum(a.BPREM) src_prm
from stagedbusr2.titdmgref2@dmstagedblink a
group by a.chdrnum ,a.tranno
)
select distinct a.chdrnum,b.tranno ig_tranno,b.tranno src_tranno,
abs(sum(b.bprem) over (partition by  a.chdrnum,b.tranno)) ig_prem,
v.src_prm
from gbihpf a,
     gbidpf b,
     v_data v
where v.chdrnum = a.chdrnum
and a.billno = b.billno
and v.tranno = b.tranno
)
where IG_TRANNO <> SRC_TRANNO
or IG_PREM <> SRC_PRM;



select * from (
select distinct a.chdrnum,a.tranno src_tranno ,b.tranno ig_tranno
from stagedbusr.titdmgref1@dmstagedblink a,
gbihpf b
where a.chdrnum = b.chdrnum
and  a.prbilfdt = b.prbilfdt
and b.billtyp = 'A'
--and a.tranno = b.tranno
)
where src_tranno <> ig_tranno;




select * from (
with v_data as(
select distinct a.chdrnum,a.tranno src_tranno,
    sum(a.Bprem) over (partition by  trim(a.chdrnum),a.tranno) src_ref_amt
from  stagedbusr.titdmgref2@dmstagedblink a)
select distinct a.chdrnum,a.src_tranno,a.src_ref_amt,
        b.tranno ig_tranno,
        sum(b.ZREFUNDAM) over (partition by b.chdrnum, b.tranno) ig_ref_amt
from v_data a,
     zrfdpf b
where  a.chdrnum = b.chdrnum
)
where SRC_TRANNO <> IG_TRANNO
or SRC_REF_AMT <> IG_REF_AMT;
     



select * from (
select distinct a.chdrnum ,
       sum(a.zrefundbz) over (partition by a.chdrnum,a.TRANNO,a.REQDATE) +
       sum(a.zrefundbe) over (partition by a.chdrnum,a.TRANNO,a.REQDATE) src_tot_ref_amt,
       case 
       when trim(a.zenrfdst) is not null
       then a.ZENRFDST
       when trim(a.zzhrfdst) is not null
       then a.ZZHRFDST
       end   src_ref_stat,     
       b.ZREFUNDAM ig_ref_amt,
       b.ZRFDST ig_ref_stat
from stagedbusr2.titdmgref1@dmstagedblink a,
      zreppf b
where a.chdrnum = b.chdrnum
and a.TRANNO = b.TRANNO
)
where SRC_TOT_REF_AMT <> IG_REF_AMT
or SRC_REF_STAT <> IG_REF_STAT;

     
     
   





select * from (
select distinct  a.chdrnum,
        b.trdt gbihpf_trndt,
        c.trdt gbidpf_trndt,
        to_char(to_date(d.busdate,'YYYYMMDD'),'YYMMDD') busdate
from zreppf a,
    gbihpf  b,
    gbidpf c,
    busdpf d
where a.chdrnum = b.chdrnum
and a.tranno = b.tranno
and b.billno = c.billno
--and b.trdt = to_char(to_date(d.busdate,'YYYYMMDD'),'YYMMDD')
--and c.trdt = to_char(to_date(d.busdate,'YYYYMMDD'),'YYMMDD')
)
where gbihpf_trndt <> busdate
or gbidpf_trndt <> busdate;







select * from (
with ig_data as(
select chdrnum,Zaltrcde01,btdate,ptdate,clntnum
from zreppf)
select distinct a.chdrnum,
       a.Zaltrcde01 ref_alter_Code,
       a.btdate ref_bill_date,
       a.ptdate ref_pay_to_date,
       a.clntnum ref_clntnum,
       b.zaltrcde01 ztra_alter_code,
       c.btdate gchd_bill_date,
       c.ptdate gchd_pay_to_date,
       c.Cownnum gchd_clntnum
from ig_data a,
      ztrapf b,
      gchd c
where a.chdrnum = b.chdrnum
and a.Zaltrcde01 = b.zaltrcde01
and a.btdate = c.btdate 
and a.ptdate = c.ptdate
and a.clntnum = c.Cownnum)
where ref_alter_Code <> ztra_alter_code
or ref_bill_date <> gchd_bill_date
or ref_pay_to_date <> gchd_pay_to_date
or ref_clntnum <> gchd_clntnum;





select * from (
with ig_data as(
select chdrnum,Zaltrcde01,btdate,ptdate,clntnum
from zreppf)
select distinct a.chdrnum,
       a.Zaltrcde01 ref_alter_Code,
       a.btdate ref_bill_date,
       a.ptdate ref_pay_to_date,
       a.clntnum ref_clntnum,
       b.zaltrcde01 ztra_alter_code,
       c.btdate gchd_bill_date,
       c.ptdate gchd_pay_to_date,
       c.Cownnum gchd_clntnum
from ig_data a,
      ztrapf b,
      gchd c
where a.chdrnum = b.chdrnum
and a.Zaltrcde01 = b.zaltrcde01
and a.btdate = c.btdate
and a.ptdate = c.ptdate
and a.clntnum = c.Cownnum)
where ref_alter_Code <> ztra_alter_code
or ref_bill_date <> gchd_bill_date
or ref_pay_to_date <> gchd_pay_to_date
or ref_clntnum <> gchd_clntnum;






select * from (
with v_data as(
select distinct a.chdrnum,a.tranno src_tranno,
    sum(a.Bprem) over (partition by  trim(a.chdrnum),a.tranno) src_ref_amt
from  stagedbusr2.titdmgref2@dmstagedblink a)
select distinct a.chdrnum,a.src_tranno,a.src_ref_amt,
        b.tranno ig_tranno,
        sum(b.ZREFUNDAM) over (partition by b.chdrnum, b.tranno) ig_ref_amt
from v_data a,
     zrfdpf b
where  a.chdrnum = b.chdrnum
and a.src_tranno = b.tranno
)
where SRC_TRANNO <> IG_TRANNO
or SRC_REF_AMT <> IG_REF_AMT;
