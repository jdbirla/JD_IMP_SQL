create or replace procedure stagedbusr2.validation_billing is

/***************************************************************************************************
  * Date    Initials   Tag   Description
  * -----   --------   ---   ---------------------------------------------------------------------------
  * 030221	CHO          	 Source to Staging CSV file validation for Billing Instalment module
  * 040221	AGUPTA           Source to Staging CSV file validation for Billing Refund module
  * 180221	CHO          	 Add in cursor c4 posting month and year validation for Billing Instalment module
  *****************************************************************************************************/

-------- Variable and Constant ---------
cnt integer := 0;
module varchar2(30 char);

cursor c1 is
select SUBSTR(TRIM(d.refnum), 1, 8) chdrnum 
from stagedbusr2.titdmgmbrindp1 d
where client_category = '0' and plnclass = 'P' 
and statcode in ('XN', 'IF')
and SUBSTR(TRIM(d.refnum), 1, 8) not in (
select distinct chdrnum from stagedbusr2.titdmgbill2)
order by SUBSTR(TRIM(d.refnum), 1, 8);

cursor c2 is
select a.chdrnum, a.prbilfdt, min(b.effdate) effdate 
from stagedbusr2.titdmgbill1 a
left outer join stagedbusr2.titdmgmbrindp1 b
on a.chdrnum = substr(trim(b.refnum), 1, 8)
and b.client_category = '0'
group by a.chdrnum, a.prbilfdt
having min(b.effdate) is null or a.prbilfdt < min(b.effdate);

cursor c3 is
select a.chdrnum, a.prbilfdt, min(b.effdate) effdate 
from stagedbusr2.titdmgref1 a
left outer join stagedbusr2.titdmgmbrindp1 b
on a.chdrnum = substr(trim(b.refnum), 1, 8)
and b.client_category = '0'
group by a.chdrnum, a.prbilfdt
having min(b.effdate) is null or a.prbilfdt < min(b.effdate);

cursor c4 is
select chdrnum, trrefnum, prbilfdt
from stagedbusr2.titdmgbill1
where zposbdsm = 0 or zposbdsy = 0
order by chdrnum, prbilfdt;

begin
--1) To check for policy not in billing and write into stagedbusr2.policy_notin_billing if any.
  delete from stagedbusr2.policy_notin_billing;
  
  for r1 in c1 loop
    insert into stagedbusr2.policy_notin_billing values(r1.chdrnum);
    cnt := cnt + 1;
  end loop;

  commit;
  
  if cnt = 0 then
    dbms_output.put_line('1) Passed: No record exists');
  else
    dbms_output.put_line('1) Failed: '||cnt||' policy not in billing found');
  end if;
  
  
--2) To check for invalid bill from date in stagedbusr2.titdmgbill1 and write into stagedbusr2.invalid_cutoffperiod if any.
  delete from stagedbusr2.invalid_cutoffperiod;
  
  cnt := 0;
  module := 'Billing Installment';
  for r1 in c2 loop
    insert into stagedbusr2.invalid_cutoffperiod values(r1.chdrnum, r1.prbilfdt, r1.effdate, module);
    cnt := cnt + 1;
  end loop;

  commit;
  
  if cnt = 0 then
    dbms_output.put_line('2) Passed: No record exists for Billing Installment');
  else
    dbms_output.put_line('2) Failed: '||cnt||' invalid cut off period billing found for Billing Installment');
  end if;
  
  
--3) To check for invalid bill from date in stagedbusr2.titdmgref1 and write into stagedbusr2.invalid_cutoffperiod if any.
  
  cnt := 0;
  module := 'Billing Refund';
  for r1 in c3 loop
    insert into stagedbusr2.invalid_cutoffperiod values(r1.chdrnum, r1.prbilfdt, r1.effdate, module);
    cnt := cnt + 1;
  end loop;

  commit;
  
  if cnt = 0 then
    dbms_output.put_line('3) Passed: No record exists for Billing Refund');
  else
    dbms_output.put_line('3) Failed: '||cnt||' invalid cut off period billing found for Billing Refund');
  end if;
  

--4) To check for invalid posting month or year in stagedbusr2.titdmgbill1 and write into stagedbusr2.invalid_zposbds if any.
  delete from stagedbusr2.invalid_zposbds;
  
  cnt := 0;
  for r1 in c4 loop
    insert into stagedbusr2.invalid_zposbds values(r1.chdrnum, r1.trrefnum, r1.prbilfdt);
    cnt := cnt + 1;
  end loop;

  commit;
  
  if cnt = 0 then
    dbms_output.put_line('4) Passed: No record exists');
  else
    dbms_output.put_line('4) Failed: '||cnt||' billing record found with invalid posting month or year');
  end if;

  
EXCEPTION
    WHEN OTHERS THEN
      rollback;
      dbms_output.put_line('Error: '||sqlerrm);
      stagedbusr2.DM_data_trans_gen.ERROR_LOGS('VALIDATION_BILLING', 'chdrnum', sqlerrm);				
                
end validation_billing;