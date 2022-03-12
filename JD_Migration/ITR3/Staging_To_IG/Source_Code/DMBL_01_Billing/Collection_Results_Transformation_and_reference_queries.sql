select * from (
  with ig_data as (
    select chdrnum, billno, lnbillno, dshcde, tfrdate
    from Jd1dta.zcrhpf
    where jobnm = 'G1ZDCOLRES'
  )
  
  select a.chdrnum, a.billno, b.zigvalue ref_billno, a.lnbillno,
         case when a.dshcde = '00' then
           to_number(b.zigvalue)
         else 
           (select max(c.billno) from Jd1dta.gbihpf c where a.chdrnum = c.chdrnum and a.tfrdate = c.zbktrfdt)
         end ref_lnbillno
  from ig_data a, Jd1dta.pazdrbpf b
  where a.chdrnum = b.chdrnum
    and a.billno = b.zigvalue    
  )
where billno <> ref_billno or nvl(lnbillno, 0) <> nvl(ref_lnbillno, 0);


select * from (
  with ig_data as (
    select chdrnum, zstrtpgp, zendpgp
    from Jd1dta.zuclpf
    where jobnm = 'G1ZDCOLRES'
  )
  
  select distinct a.chdrnum, a.zstrtpgp, a.zendpgp, c.prbilfdt ref_zendpgp
  from ig_data a, Jd1dta.zcrhpf b, Jd1dta.gbihpf c
  where a.chdrnum = b.chdrnum
    and b.dshcde not in ('00', ' ')
    and b.chdrnum = c.chdrnum
    and b.billno = c.billno  
    and a.zstrtpgp = c.prbilfdt
  )
where nvl(zendpgp, 0) <> ref_zendpgp;


select * from (
  with ig_data as (
    select chdrnum, zstrtpgp, zcombill
    from Jd1dta.zuclpf
    where jobnm = 'G1ZDCOLRES'
  )
  
  select d.chdrnum, d.zstrtpgp, d.zcombill,
  (select count(*)
  from ig_data a, Jd1dta.zcrhpf b, Jd1dta.gbihpf c
  where d.chdrnum = a.chdrnum
    and d.zstrtpgp = a.zstrtpgp
    and a.chdrnum = b.chdrnum
    and b.dshcde not in ('00', ' ')
    and b.chdrnum = c.chdrnum
    and b.billno = c.billno  
    and a.zstrtpgp = c.prbilfdt) ref_zcombill
  from ig_data d
  )
where nvl(zcombill, 0) <> ref_zcombill;


select * from (
  with ig_data as (
    select chdrnum, zstrtpgp, validflag
    from Jd1dta.zuclpf
    where jobnm = 'G1ZDCOLRES'
  )
  
  select d.chdrnum, d.zstrtpgp, to_number(d.validflag) validflag,
  (select count(*) from (
     select distinct a.zstrtpgp
     from ig_data a, Jd1dta.zcrhpf b, Jd1dta.gbihpf c
     where d.chdrnum = a.chdrnum
     and d.zstrtpgp = a.zstrtpgp
     and a.chdrnum = b.chdrnum
     and b.dshcde not in ('00', ' ')
     and b.chdrnum = c.chdrnum
     and b.billno = c.billno  
     and a.zstrtpgp = c.prbilfdt
     union all
     select distinct a.zstrtpgp
     from ig_data a, Jd1dta.zcrhpf b, Jd1dta.gbihpf c
     where d.chdrnum = a.chdrnum
     and d.zstrtpgp = a.zstrtpgp
     and a.chdrnum = b.chdrnum
     and b.dshcde = '00'
     and b.chdrnum = c.chdrnum
     and b.billno = c.billno  
     and a.zstrtpgp = c.prbilfdt)
   ) ref_validflag
  from ig_data d
  )
where nvl(validflag, 0) <> ref_validflag;