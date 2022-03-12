create table stagedbusr2.titdmgref1_sm
as (select a.* from stagedbusr2.titdmgref1 a where not exists (select 1 from stagedbusr2.titdmgbill1 b
where a.chdrnum = b.chdrnum
and to_char(to_date(a.PRBILFDT,'yyyymmdd'),'yyyymm') =  to_char(to_date(b.PRBILFDT,'yyyymmdd'),'yyyymm')));

create table stagedbusr2.titdmgref2_sm
as (select * from stagedbusr2.titdmgref2 c where 
exists (
        select 1
        from stagedbusr2.titdmgref1 a 
        where not exists (select 1 from stagedbusr2.titdmgbill1 b
                        where a.chdrnum = b.chdrnum
                        and to_char(to_date(a.PRBILFDT,'yyyymmdd'),'yyyymm') =  to_char(to_date(b.PRBILFDT,'yyyymmdd'),'yyyymm'))
         and  a.chdrnum = c.chdrnum 
         and a.refnum = c.trrefnum));