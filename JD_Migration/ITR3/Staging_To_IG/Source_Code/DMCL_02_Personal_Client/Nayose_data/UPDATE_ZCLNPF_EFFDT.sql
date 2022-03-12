---------------------------------------------------------------------------------------
-- File Name	: UPDATE_ZCLNPF_EFFDT
-- Description	: Update effdate in zclnpf for migration
-- Author       : jbirla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo on
set feed off
set termout off


spool "&SQL_LOG_PATH.\INSRT_INTO_DMIGTITNYCLT&log_date_text..txt"


DECLARE 
  cnt number(2,1) :=0;
BEGIN  

DELETE FROM Jd1dta.ZDMBKPZCLN;
INSERT /*+ APPEND */ INTO Jd1dta.ZDMBKPZCLN
 (select clntnum, effdate from 
(select clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from zclnpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.clntstas = 'EX' ) )where row_num =1);

/*
update zclnpf set effdate = '190101',datime = sysdate where (clntnum,effdate) IN (
select clntnum, effdate from 
(select clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from zclnpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.clntstas = 'EX' ) )where row_num =1); */

UPDATE Jd1dta.ZCLNPF ZC
SET effdate = (select '19010101' from (select * from
(select clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from zclnpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.clntstas = 'EX' ) )where row_num =1)tab2 
where  ZC.clntnum = tab2.clntnum
and zc.effdate = tab2.effdate)
where exists
(
select '19010101' from (select * from
(select clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from zclnpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.clntstas = 'EX' ) )where row_num =1)tab2 
where  ZC.clntnum = tab2.clntnum
and zc.effdate = tab2.effdate
);

COMMIT;

  
END;
/
