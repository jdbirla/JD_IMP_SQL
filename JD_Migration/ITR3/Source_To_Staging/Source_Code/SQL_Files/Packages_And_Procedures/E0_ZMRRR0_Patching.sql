---E0 issue in campcode module for duplicate entry in zmrrr00

--step1 : Just for duplicate entry in zmrrr00
select RRBTCD, RRBUCD, RRFOCD, RRA2IG from ZMRRR00 a
where exists  (select RRBTCD,RRFOCD,count(1) from ZMRRR00 b where a.RRBTCD = b.RRBTCD
               and a.RRFOCD = b.RRFOCD  group by RRBTCD,RRFOCD having count(1) > 1 )
order by 1,3;

--Step2: If duplicate found then execute below query
Create table JD_ZMRRR00 as  select * from zmrrr00;
               
               delete from ZMRRR00 where (RRBTCD,RRBUCD,RRFOCD) in (
select RRBTCD, RRBUCD, RRFOCD from ZMRRR00 a
where exists  (select RRBTCD,RRFOCD,count(1) from ZMRRR00 b where a.RRBTCD = b.RRBTCD
               and a.RRFOCD = b.RRFOCD  group by RRBTCD,RRFOCD having count(1) > 1) ) and RRBUCD='E0';

--step3: After delete please check with below query
			   
			   select * from ZMRRR00 where (RRBTCD,RRBUCD,RRFOCD) in (
select RRBTCD, RRBUCD, RRFOCD from ZMRRR00 a
where exists  (select RRBTCD,RRFOCD,count(1) from ZMRRR00 b where a.RRBTCD = b.RRBTCD
               and a.RRFOCD = b.RRFOCD  group by RRBTCD,RRFOCD having count(1) > 1) );