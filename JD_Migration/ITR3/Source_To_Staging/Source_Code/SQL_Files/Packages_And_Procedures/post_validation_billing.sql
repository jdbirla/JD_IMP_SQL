create or replace procedure             post_validation_billing is

/***************************************************************************************************
  * Date    Initials   Tag   Description
  * -----   --------   ---   ---------------------------------------------------------------------------
  * 062321	MKS          	 TITDMGBILL1 post validation
  *****************************************************************************************************/

-------- Variable and Constant ---------
cnt integer := 0;
module varchar2(30 char);

cursor c1 is
select chdrnum, tfrdate, TRREFNUM   from titdmgbill1 where ZACMCLDT is null;

cursor c2 is
select a.chdrnum, a.TFRDATE, a.ZPOSBDSM, a.ZPOSBDSY, count(*)  
from titdmgbill1  a 
where exists (select 1 from (
    select chdrnum, TFRDATE, count(*) from titdmgbill1 group by chdrnum, TFRDATE having count(*) > 1) b
    where b.chdrnum = a.chdrnum and b.TFRDATE = a.TFRDATE
)
group by chdrnum, TFRDATE, ZPOSBDSM, ZPOSBDSY having count(*) = 1;

begin
--1) To check for policy having null zacmcldt.
  delete from stagedbusr2.policy_null_zacmcldt;

  for r1 in c1 loop
    insert into stagedbusr2.policy_null_zacmcldt values(r1.chdrnum, r1.tfrdate, r1.TRREFNUM);
    cnt := cnt + 1;
  end loop;

  commit;

  if cnt = 0 then
    dbms_output.put_line('1) Passed: No record exists');
  else
    dbms_output.put_line('1) Failed: '||cnt||' policy billing record has NULL value in ZACMCLDT.');
  end if;
  
--2) To check if any combine billing having different posting year and month
  delete from stagedbusr2.policy_null_zacmcldt;
  cnt := 0 ;
  for r2 in c2 loop
    insert into stagedbusr2.policy_combbill_yr_mon values(r2.chdrnum, r2.TFRDATE, r2.ZPOSBDSM, r2.ZPOSBDSY);
    cnt := cnt + 1;
  end loop;

  commit;

  if cnt = 0 then
    dbms_output.put_line('2) Passed: No record exists');
  else
    dbms_output.put_line('2) Failed: '||cnt||' Combined Billing records having different posting year and month.');
  end if;  

EXCEPTION
    WHEN OTHERS THEN
      rollback;
      dbms_output.put_line('Error: '||sqlerrm);
      stagedbusr2.DM_data_trans_gen.ERROR_LOGS('POST_VALIDATION_BILLING', 'chdrnum', sqlerrm);				

end post_validation_billing;
/