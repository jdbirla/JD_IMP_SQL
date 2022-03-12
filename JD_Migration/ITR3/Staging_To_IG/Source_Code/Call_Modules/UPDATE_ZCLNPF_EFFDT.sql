---------------------------------------------------------------------------------------
-- File Name	: UPDATE_ZCLNPF_EFFDT
-- Description	: Update effdate in zclnpf for migration
-- Author       : jbirla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\UPDATE_ZCLNPF_EFFDT&log_date_text..txt"


set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed on
set echo on
set termout on

DECLARE
 cnt number(2,1) :=0;
   p_exitcode      number;
  p_exittext      varchar2(200);
BEGIN  




DELETE FROM Jd1dta.ZDMBKPZCLN;
INSERT /*+ APPEND */ INTO Jd1dta.ZDMBKPZCLN
 (select clntnum, effdate from 
(select clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from zclnpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX' ) )where row_num =1);
COMMIT;



merge into Jd1dta.ZCLNPF ZC
using
    (select * from
            (select unique_number, clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from Jd1dta.zclnpf A where a.clntnum in
                (select DISTINCT(zigvalue) from Jd1dta.pazdnypf B where b.dm_or_ig = 'DMPA' and b.clntstas = 'NW' ) )where row_num =1
    ) tab2
ON( ZC.clntnum = tab2.clntnum and zc.unique_number = tab2.unique_number)
WHEN MATCHED THEN
update set zc.effdate = '19010101';
COMMIT;

merge into Jd1dta.ZCLNPF ZC
using
    (select * from
            (select unique_number, clntnum, effdate , row_number() over( partition by clntnum  order by clntnum ,effdate ) row_num from Jd1dta.zclnpf A where a.clntnum in
                (select DISTINCT(zigvalue) from Jd1dta.pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX' ) )where row_num =1
    ) tab2
ON( ZC.clntnum = tab2.clntnum and zc.unique_number = tab2.unique_number)
WHEN MATCHED THEN
update set zc.effdate = '19010101';

COMMIT;


DELETE FROM Jd1dta.ZDMBKPCLNT;
INSERT /*+ APPEND */ INTO Jd1dta.ZDMBKPCLNT
 (select clntnum, SRDATE from CLNTpf A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX' ));
COMMIT;


    merge into CLNTPF nw
USING (
select unique_number, clntnum from CLNTPF A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX')) tab2
ON (tab2.unique_number = nw.unique_number and tab2.clntnum = nw.clntnum)
WHEN MATCHED THEN
UPDATE SET nw.srdate = '19010101';

COMMIT;


    merge into CLNTPF nw
USING (
select unique_number, clntnum from CLNTPF A
where a.clntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'DMPA' and b.clntstas = 'NW')) tab2
ON (tab2.unique_number = nw.unique_number and tab2.clntnum = nw.clntnum)
WHEN MATCHED THEN
UPDATE SET nw.srdate = '19010101';

COMMIT;


DELETE FROM Jd1dta.ZDMBKPAUDCLNT;
INSERT /*+ APPEND */ INTO Jd1dta.ZDMBKPAUDCLNT
(select oldclntnum, newSRDATE from 
 (select oldclntnum, newSRDATE , row_number() over( partition by oldclntnum  order by oldclntnum ,newSRDATE ) row_num from audit_CLNTpf A
where a.oldclntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX' ))where row_num =1);
COMMIT;



merge into AUDIT_CLNTPF nw
USING (
select unique_number, oldclntnum from audit_CLNTpf A
where a.oldclntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'DMPA' and b.clntstas = 'NW')) tab2
ON (tab2.unique_number = nw.unique_number and tab2.oldclntnum = nw.oldclntnum)
WHEN MATCHED THEN
UPDATE SET nw.newsrdate = '19010101';

COMMIT;

merge into AUDIT_CLNTPF nw
USING (
select unique_number, oldclntnum from audit_CLNTpf A
where a.oldclntnum in (select DISTINCT(zigvalue) from pazdnypf B where b.dm_or_ig = 'IG' and b.clntstas = 'EX')) tab2
ON (tab2.unique_number = nw.unique_number and tab2.oldclntnum = nw.oldclntnum)
WHEN MATCHED THEN
UPDATE SET nw.newsrdate = '19010101';


COMMIT;






EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'UPDATE_ZCLNPF_EFFDT : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('G1ZDNAYCLT', 000, p_exitcode, p_exittext, sysdate);
    commit;
     raise;

COMMIT;
  
END;
/
