--- Renewal determination pre-valiation file


-- Check if a same insured is present in more than one file

select * from zmrage00 a,
zmrhr00 b
where substr(AGECICD,1,8) = substr(HRCICD1,1,8)
and substr(AGECICD,-2) = substr(HRCICD1,-2);


select * from zmrage00 a,
renew_as_is b
where substr(AGECICD,1,8) = b.APCUCD
and substr(AGECICD,-2) = b.ICICD;

select * from zmrhr00 a,
renew_as_is b
where substr(HRCICD1,1,8) = b.APCUCD
and substr(HRCICD1,-2) = b.ICICD;



--- Check if all insured in ZMAGE00, ZMRHR00 , Renewas_is is available in ZMRIS00


with v_data as (select distinct substr(AGECICD,1,8) chdrnum,substr(AGECICD,-2) insured_no
from zmrage00
union 
select distinct APCUCD, ICICD
from renew_as_is
union 
select distinct substr(HRCUCD,1,8) , substr(HRCICD1,-2)
from zmrhr00)
select * from zmris00 ins
left outer join v_data d
on  substr(ins.ISCUCD,1,8) = d.chdrnum
and substr(ins.ISCJCD,-2) = d.insured_no
where exists (select 1 from zmris00 ins1 where substr(ins1.ISCUCD,1,8) = d.chdrnum)
and d.insured_no is null;


-- Checking if any policies exists in ASRF should not exists in any other files

select * from zmrhr00 a
where exists (select 1 from asrf_rnw_dtrm b where substr(a.HRCUCD,1,8) = b.chdrnum);

select * from zmrage00 a
where exists (select 1 from asrf_rnw_dtrm b where substr(a.AGECUCD,1,8) = b.chdrnum);

select * from renew_as_is a
where exists (select 1 from asrf_rnw_dtrm b where a.apcucd = b.chdrnum);




--- Check if any policy is duplicated in same file

select  substr(AGECICD,1,8) chdrnum,substr(AGECICD,-2) insured_no, count(1)
from zmrage00
group by  substr(AGECICD,1,8) ,substr(AGECICD,-2) 
having count(1) > 1;


select APCUCD, ICICD , count(1)
from renew_as_is
group by APCUCD, ICICD
having count(1) > 1;


select substr(HRCUCD,1,8) , substr(HRCICD1,-2), count(1)
from zmrhr00
group by  substr(HRCUCD,1,8) ,substr(HRCICD1,-2) 
having count(1) > 1;

select CHDRNUM,count(1)
from asrf_rnw_dtrm
group by CHDRNUM
having count(1) > 1;

---- Check if a policy exists in renewal det file but not in zmrap00

select * from (
with data as(
select distinct substr(AGECICD,1,8) chdrnum, 'zmrage00' as files
from zmrage00
union 
select distinct APCUCD,'renew_as_is' 
from renew_as_is
union 
select distinct substr(HRCUCD,1,8) ,'zmrhr00' 
from zmrhr00
union
select distinct chdrnum,'asrf_rnw_dtrm' 
from asrf_rnw_dtrm)
select * from data d where not exists (Select 1 from zmrap00 b where d.chdrnum = substr(b.apcucd,1,8))
) v
where exists (select 1 from fct_deleted_pol f where f.chdrnum = v.chdrnum);



--- Check if the zmrage00 current salesplan is available in mem_ind_polhist_ssplan_intrmdt
select * from zmrage00 a
where not exists (select 1 from mem_ind_polhist_ssplan_intrmdt b where 
b.chdrnum = substr(AGECICD,1,8)
and a.AGECJCDO = b.OLDZSALPLAN);




-- post validation



--- to check if there are any policy with different SP in ZMRAGE00 with determination code <> A10(no change in SP)
select * from titdmgrnwdt1 a 
where not exists (Select 1 from mem_ind_polhist_ssplan_intrmdt b where a.chdrnum = b.chdrnum and a.zsalplan = b.NEWZSALPLAN)
and INPUT_SOURCE_TABLE = 'ZMRAGE00'
and ZRNDTRCD <> 'A10';


-- to check the coverage has prmium 0 but the SI > 0 and vice versa
-- for ZMRAGE00, we will set the prm = 0 for 2950 , 3951
select distinct INPUT_SOURCE_TABLE from  dmigtitdmgrnwdt2
where dprem = 0 and sumins > 0
and prodtyp not in ('2951','3951');


select * from  dmigtitdmgrnwdt2
where dprem > 0 and sumins = 0;
