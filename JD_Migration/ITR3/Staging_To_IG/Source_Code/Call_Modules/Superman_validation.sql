---------------------------------------------------------------------------------------
-- File Name	: Superman Validation.sql
-- Description	: Superman validation to check if the business date is greater than Ztrapf-zpdatatxdat
-- Author       : Lakshmanaprabu K
-- Date 	: 2/3/2022
---------------------------------------------------------------------------------------

set serveroutput on;

Begin

for c_get in (select distinct a.chdrnum ,b.zpdatatxdat,c.busdate
			from stagedbusr2.titdmgref1_sm@stagedblink a,
			Jd1dta.ztrapf b,
			Jd1dta.busdpf c
			where a.chdrnum = b.chdrnum
			and b.zpdatatxdat > c.busdate) 
loop


dbms_output.put_line(c_get.chdrnum||' --- '||c_get.zpdatatxdat||' --- '||c_get.busdate);

end loop;



end;