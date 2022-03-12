select * from v$parameter;
show parameter parallel;
show PARAMETERS;
show parameter CPU_COUNT;
--Flash back data fetch
select chdrnum, CCDATE, CRDATE from gchipf as of TIMESTAMP TO_TIMESTAMP('2020-10-07 09:00:00','YYYY-MM-DD HH:MI:SS') where chdrnum ='05009031';
select 'New',c.* from clntpf c where clntnum='10000002'
union
select 'Old',c.* from clntpf as of timestamp to_timestamp('2021-07-01 17:40:00','YYYY-MM-DD HH24:MI:SS') c where clntnum='10000002';
---Monitoring
select * from v$sql ;
select SQL_TEXT,CPU_TIME, ELAPSED_TIME,MODULE,FIRST_LOAD_TIME,last_active_time,last_load_time from v$sql where SQL_TEXT not  like '%ZDOEBL%' order by LAST_LOAD_TIME desc ,ELAPSED_TIME desc ;


-----
--Check the count of policies
select * from 
(
   select B.zplancls,A.chdrnum,B.zprdctg,B.zendcde   from gchd A inner join gchppf B on A.chdrnum=b.chdrnum and A.chdrnum != A.mplnum and zprdctg IN ('PA')
)
pivot
(
COUNT(chdrnum)
  FOR zprdctg IN ('PA')
) order by ZENDCDE, ZPLANCLS desc;
--============================================================================================
select name, value
from v$statname n, v$sesstat t
where n.statistic# = t.statistic#
and t.sid = ( select sid from v$mystat where rownum = 1 )
and n.name in
('session pga memory', 'session pga memory max','session uga memory', 'session uga memory max');
--PGA Memory

select NAME,ROUND((VALUE)/1024/1024,1) MB , round(VALUE/POWER(1024,3),1)  GB  from v$pgastat;
show PARAMETERS PGA;
/*
aggregate PGA target parameter	17408	17
aggregate PGA auto target	15211.7	14.9
global memory bound	100	0.1
total PGA inuse	687.1	0.7
total PGA allocated	2321.5	2.3
maximum PGA allocated	22751.4	22.2
*/
--============================================================================================
-- Query to Get List of all locked objects
SELECT B.Owner, B.Object_Name, A.Oracle_Username, A.OS_User_Name,a.session_id ,a.object_id
FROM V$Locked_Object A, All_Objects B
WHERE A.Object_ID = B.Object_ID ; 
-- and A.OS_USER_NAME = 'mahendar' 
-- Query to Get List of locked sessions        
select SID,SERIAL#,INST_ID from gv$session a  where a.osuser='JPAJBI';

-- and osuser =  'mahendar';
-- o/p: 314 26513   1
-- Statement to Kill the session [pass values in the same order and append @ for inst_id]
alter system kill session '106,44953,@1';

--Kill paralle threads session
select 'alter system kill session ''' || s.sid ||',' || s.serial# || ''';'
                                        from gv$session s,gv$sql q
                            where s.sql_address = q.address
                                         and s.sql_hash_value = q.hash_value
                                         and s.sql_child_number = q.child_number
                                         AND s.status = 'ACTIVE'
                                         and s.module = 'DBMS_SCHEDULER';
										 
--============================================================================================

--CREATE DATABASE LINK DMSTAGEDBLINK CONNECT TO STAGEDBUSR IDENTIFIED BY  USING '';
--CREATE DATABASE LINK DMSTGUSR2DBLINK CONNECT TO STAGEDBUSR2 IDENTIFIED BY  USING '';
--============================================================================================
select 'alter index '|| 'Jd1dta.' 
            ||INDEX_NAME||' rebuild ;' from user_indexes where STATUS!='VALID';
--Client number 
select * from clntpf;
--1. max client number 
--This series is going to use for client migration 11055703~50,000,000 
---IG used from 50000001
/*Production
drop SEQUENCE Jd1dta.SEQANUMPF;
create sequence Jd1dta.SEQANUMPF
minvalue 1
maxvalue 50000000
start with 20000054
increment by 1
cache 20;

then 
ALTER SEQUENCE SEQANUMPF       cache 1000;

*/

--20,000,054
select max(clntnum) from clntpf where usrprf='JBIRLA'; --11055703

select max(clntnum) from clntpf; --11055703
--Increased SEQANUMPF by that number 50747203  using  incr_seq :: SELECT SEQANUMPF.nextval  FROM dual =>50747204
SELECT SEQANUMPF.nextval  FROM dual;
--2 Check expected client for migration   count(zmris00) :50862 + buffer
select 11055703 + 60862  from dual;--60988680
select * from anumpf where prefix='CN' order by autonum;
--3. IG will start from 50000001
--4. Delete all reccords from anumpf for CN ::delete from anumpf where prefix='CN';
delete from anumpf where prefix='CN';
--5. Modify T3642 in FSU company start number by Alloted size of client to DM ::  50988680
--6. Run F9AUTOALOC for client number generation
--Billing number
--1. max bill number 
select max(billno) from GBIHPF; --16728026   --Before migration
select max(billno) from GBIHPF; --16836530     --After migration

/*Production
drop SEQUENCE Jd1dta.SEQ_BILLNO;
create sequence Jd1dta.SEQ_BILLNO
minvalue 1
maxvalue 50000000
start with 15515808
increment by 1
cache 1000;

*/


--Increased SEQ_BILLNO by that number 1000  using  incr_seq :: SELECT SEQ_BILLNO.nextval  FROM dual =>1001
SELECT SEQ_BILLNO.nextval  FROM dual;
--2 Check expected bill for migration   count(titdmgbill2) :273274 + buffer
select 1000 + 919904   from dual;--920904
--3. IG will start from 920904
--4. Delete all reccords from anumpf for PR ::delete from anumpf where prefix='PR';
delete from anumpf where prefix='PR';
--5. Modify T3642 start number by Alloted size of billing to DM + 1 ::  284275
--6. Run G1AUTOALOC for Bill number generation
select * from bsscpf order by datime desc;
select * from anumpf where prefix='CN' and RTRIm(autonum) in (select clntnum from clntpf);
select * from anumpf where prefix='PR' and RTRIm(autonum) in (select gbihpf.billno from gbihpf);
select * from anumpf where prefix='PR' ;---015846541
--Duplicate client check
select CLNTNUM , count(*) from Jd1dta.clntpf group by CLNTNUM HAVING count(*)>1;
select billno , count(*) from Jd1dta.gbihpf group by billno HAVING count(*)>1;

select min(billno) from gbihpf where usrprf='JBIRLA';--12204338
select MAX(billno) from gbihpf where usrprf='JBIRLA';--15846539
select * from pazdnypf;
select min(clntnum) from clntpf where usrprf='JBIRLA';--20000056
select MAX(clntnum) from clntpf where usrprf='JBIRLA';--21667873
--============================================================================================
--After Migration set bills and client in T -table and generate client and bills:
--1. Get max clntnum from clntpf and max bill num from GBIHPF.
--2. Increased SEQANUMPF/SEQ_BILLNO by that number  using  incr_seq
--3. Delete all reccords from anumpf for CN and PR
--4. Modify T3642 start number by Alloted size of billing to DM + 1
--5. Run G1AUTOALOC for Bill number generation
--6. Modify T3642 in FSU company start number by Alloted size of client to DM + 1
--7. Run F9AUTOLOC for client number generation
select * from bsscpf order by datime desc;
select * from anumpf where prefix='CN' and RTRIm(autonum) in (select clntnum from clntpf);
select * from anumpf where prefix='PR' and RTRIm(autonum) in (select gbihpf.billno from gbihpf);
select * from anumpf where prefix='PR' ;---015846541
select MAX(billno) from gbihpf;--16836530
select max(autonum) from anumpf where prefix='PR';
--============================================================================================
--Common query
create table zdclpf as select * from pazdclpf;
select * from usrdpf where USERID like '%NLO%';
select * from fldtpf;
select distinct SCHEDULE_NAME from DMPVALPF ;
select * from dmpvalpf where schedule_name='G1ZDMBRIND' ;
select * from dmpvalpf;
select * from DMPRFXPF;
select * from dmdefvalpf;
select * from dmbargspf;
select * from dmbmonpf order by datime desc;
select * from dmberpf order by datime desc;
truncate table dmberpf;
select * from elog;
select * from dmpvalpf order by datime desc;
select * from user_parallel_execute_tasks where task_name='DM2_G1ZDPOLHST_PARALLEL_TASK';
select * from user_parallel_execute_chunks where task_name='DM2_G1ZDCLTBNK_PARALLEL_TASK';
select * from user_scheduler_jobs;
--dbms_scheduler.stop_job(); for stop jobs
--exec DBMS_PARALLEL_EXECUTE.STOP_TASK ('DM2_G1ZDLETR_PARALLEL_TASK');
select * from DM2_DMIG_DATA_CNT;
select * from dm_target_tables;
select * from dm_index_scripts;
--Check index after migration
select *   from dm_target_tables  A where not exists(
select 1 from user_indexes B where a.index_name=b.index_name
);

select * from user_indexes;

delete from dm_index_scripts where JOBNAME='G1ZDMBRIND';
--============================================================================================
select ZENDSCID, ZSCHYEAR, ZSCHMONTH,  ZCOVCMDT,ZACMCLDT,  ZPOSBDSY, ZPOSBDSM , zbktrfdt from zesdpf where ZENDSCID in (
select ZENDSCID from zendrpf where zendcde in('OMC',
'NENKIN',
'TOBU',
'BSCYCLE_PC',
'FAMIMAT_FM',
'MITOMONKAI',
'ZURICHZW',
'AIRWEB_PC',
'HIROSIMA_B',
'IDEMITSU',
'CEDYNA',
'CLUBT_FM',
'JCB2',
'JAL',
'AIRLINK_FM',
'YOUME')) and  ZACMCLDT < 20210219 and zcovcmdt in ('20210401'
,'20210410');
--========================================================================================================================================================================================

------Coporate clien

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoecc0002 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoecc0002 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoecc0002 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoecc0002 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoecc0002 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select * from zdoecc0001 where indic ='E' ;
select *  from TITDMGCLNTCORP@dmstagedblink ;
select * from zdoecc0002;
-----Insert IG check----        

select *   from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only) ;
select *   from Jd1dta.clntpf  where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and jobnm = 'G1ZDCOPCLT' ;
select *   from Jd1dta.clexpf  where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and jobnm = 'G1ZDCOPCLT' ;
select *   from Jd1dta.audit_clntpf  where oldclntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and newjobnm = 'G1ZDCOPCLT' ;
select *   from Jd1dta.audit_clnt where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and jobnm = 'G1ZDCOPCLT' ;
select *   from Jd1dta.audit_clexpf where oldclntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and newjobnm = 'G1ZDCOPCLT' ;
select *   from Jd1dta.versionpf  where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only))  ;
select *   from Jd1dta.zclnpf where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where RTRIM(ZENTITY) in (select distinct rtrim(CLNTKEY) from TITDMGCLNTCORP@dmstagedblink fetch first 10 rows only)) and jobnm = 'G1ZDCOPCLT' ;
---Corporate client patch after exection , insertion record which are not updatd
/*
insert into pazdclpf (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
              select distinct 'OK' , 'CC', B.clntkey, A.CLNTNUM , 0002, 'INSERT' from agntpf A inner join
              ( select clntkey,RTRIM(agntnum) agntnum from titdmgclntcorp@dmstagedblink  where RTRIm(clntkey)in (
                select distinct ZREFKEY from zdoecc0002 where erorfld01='SHIAG') and rtrim(agntnum)is not null) B
                on RTRIm(A.agntnum) = RTRIM(B.agntnum)  ;
                
insert into pazdclpf (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
              select distinct 'OK' , 'CC', B.clntkey, A.CLNTNUM , 0002, 'INSERT' from agntpf A inner join
              ( select clntkey,RTRIM(agntnum) agntnum from titdmgclntcorp@dmstagedblink  where RTRIm(clntkey)in (
                select distinct ZREFKEY from zdoecc0002 where erorfld01='NOCHG') and rtrim(agntnum)is not null) B
                on RTRIm(A.agntnum) = RTRIM(B.agntnum);
*/
--========================================================================================================================================================================================
	
--Agent

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoeag0001 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoeag0001 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoeag0001 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoeag0001 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoeag0001 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select * from zdoeag0001 where indic='E';
select * from dmigtitdmgagentpj;
-----Insert IG check----        

select * from Jd1dta.PAZdropf where RTRIm(ZENTITY) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj fetch first 10 rows only) and  jobname = 'G1ZDAGENCY';
select * from Jd1dta.AGNTPF  where RTRIm(AGNTNUM) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj fetch first 10 rows only) and jobnm = 'G1ZDAGENCY' and usrprf='JBIRLA';
select * from Jd1dta.AGPLPF  where RTRIm(AGNTNUM) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj fetch first 10 rows only) and jobnm = 'G1ZDAGENCY' and usrprf='JBIRLA';
select * from Jd1dta.ZACRPF where RTRIm(GAGNTSEL) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj fetch first 10 rows only) and jobnm = 'G1ZDAGENCY' and usrprf='JBIRLA';
select * from Jd1dta.CLRRPF where RTRIM(FORENUM) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj ) and jobnm = 'G1ZDAGENCY' and usrprf='JBIRLA';
select * from Jd1dta.audit_clrrpf where RTRIM(NEWFORENUM) in (select rtrim(ZAREFNUM) from dmigtitdmgagentpj ) and newjobnm = 'G1ZDAGENCY' and newusrprf='JBIRLA';

--========================================================================================================================================================================================

--Master policy 

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoemp0001 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoemp0001 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoemp0001 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoemp0001 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoemp0001 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select * from titdmgmaspol@dmstagedblink where chdrnum in (select  zrefkey from zdoemp0012 where indic ='E' and EROR01='RPMY' );

select * from zdoemp0001 where indic ='E';

select * from dmigtitdmgmaspol;

-----Insert IG check----        

select * from Jd1dta.PAZDMPPF  where RTRIM(ZENTITY)  in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and  jobname = 'G1ZDMSTPOL';
select chdrnum,mplnum,occdate,tranno,datime from Jd1dta.gchd where chdrnum  in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.gchipf where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.gchppf where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.zenctpf where  ZPOLNMBR in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.ztgmpf where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.ztrapf where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.clrrpf where RTRIM(FORENUM) in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.audit_clrrpf where RTRIM(newFORENUM) in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and newjobnm = 'G1ZDMSTPOL' ;
select * from Jd1dta.ZGMPIRDTPF  where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol fetch first 10 rows only) and jobnm = 'G1ZDMSTPOL' ;

--========================================================================================================================================================================================

----Camp code

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoecm0001 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoecm0001 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoecm0001 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoecm0001 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoecm0001 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select * from  dmigtitdmgcampcde;
select * from  dmigtitdmgcampcde;

select * from zdoecm0001 where indic ='E' and ZFILENME='TITDMGCAMPCDE' ;

select * from gchd where chdrnum in (select distinct fldvalu01 from zdoecm0008 where indic ='E' and ZFILENME='TITDMGCAMPCDE' and eror01='RQMG');
select * from dmigtitdmgcampcde where zcmpcode in (select distinct fldvalu01 from zdoecm0008 where indic ='E' and ZFILENME='TITDMGCAMPCDE' and eror01='RQO6');
select * from zcslpf where zcmpcode in (select distinct ZREFKEY||'0' from zdoecm0008 where indic ='S' and ZFILENME='TITDMGCAMPCDE' );
select distinct  zcmpcode from titdmgmbrindp1@DMSTAGEDBLINK where RTRIM(zcmpcode) is not null and RTRIM(zcmpcode) in (select RPAD(ZREFKEY,6,0) from zdoecm0002 where indic='E' and eror01 ='RQMG');

-----Insert IG check----        
select * from pazdropf where zigvalue in (select RPAD(ZCMPCODE,6,0) from  dmigtitdmgcampcde fetch first 10 rows only)  and jobname='G1ZDCAMPCD' ;
select * from zcpnpf where ZCMPCODE in (select RPAD(ZCMPCODE,6,0) from  dmigtitdmgcampcde fetch first 10 rows only)  and jobnm='G1ZDCAMPCD' and USRPRF='JBIRLA';
select * from zcslpf where ZCMPCODE in (select RPAD(ZCMPCODE,6,0) from  dmigtitdmgcampcde fetch first 5 rows only)  and jobnm='G1ZDCAMPCD' and USRPRF='JBIRLA' fetch first 20 rows only ;


--========================================================================================================================================================================================

--Personal client 
--Pre Nayose
--1. Insert record into DMIG table from staging
select * from DMIGTITDMGCLTRNHIS;
--2. Insert SHI clients from IG DB to IGNAYOSEVIEW based on priorty
select * from IGNAYOSEVIEW;
--3.Insert PA clients from IG DB to DMPANAYOSEVIEW based on priorty
select * from DMPANAYOSEVIEW;
--4.Search into IGNAYOSEVIEW and then DMPANAYOSEVIEW and get the client and status
select * from DMIGTITNYCLT;

------------Nayose

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoeny0001 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoeny0001 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoeny0001 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoeny0001 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoeny0001 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;

select * from zdoeny0003 where indic='E';

-----Insert IG check----        

select *  from Jd1dta.pazdnypf where ZENTITY in (select refnum from DMIGTITNYCLT fetch first 10 rows only) and JOBNAME = 'G1ZDNAYCLT' ;


---------Personal clnt
select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoecp2004 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoecp2004 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoecp2004 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoecp2004 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoecp2004 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;

select * from pazdnypf where zentity in ('5716479700');
select * from pazdnypf where DM_OR_IG = 'DMPA' and CLNTSTAS='EX';
select * from pazdnypf where zigvalue='20044225';

select * from zdoecp2005 where indic='E';
select * from dmigtitdmgcltrnhis where transhist=1 and refnum='%19854HJ%';

-----Insert IG check----        

select *  from Jd1dta.pazdclpf  where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only) and JOBNAME = 'G1ZDPERCLT';
select *  from Jd1dta.clntpf  where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only)) and jobnm = 'G1ZDPERCLT' and USRPRF='JBIRLA' ;
select *  from Jd1dta.clexpf  where clntnum in (select zigvalue  from Jd1dta.pazdclpf  where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only)) and jobnm = 'G1ZDPERCLT' and USRPRF='JBIRLA' ;

select * from anumpf where autonum in (select clntnum  from Jd1dta.clntpf  where jobnm = 'G1ZDPERCLT' and USRPRF='JBIRLA') and prefix='CN';
--Duplicate client check
select CLNTNUM , count(*) from Jd1dta.clntpf group by CLNTNUM HAVING count(*)>1;
-----------Client history

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoech2003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoech2003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoech2003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoech2003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoech2003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select distinct EROR01, ERRMESS01, ERORFLD01 from zdoech2003 where indic='E';

-----Insert IG check----        

select * from Jd1dta.pazdchpf  where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only) and JOBNAME = 'G1ZDPCLHIS' ;
select * from Jd1dta.audit_clntpf  where oldclntnum in (select zigvalue from Jd1dta.pazdchpf where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only)) and oldjobnm = 'G1ZDPCLHIS' and newUSRPRF='JBIRLA';
select * from Jd1dta.audit_clnt where clntnum in (select zigvalue from Jd1dta.pazdchpf where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis )) and jobnm = 'G1ZDPCLHIS' and USRPRF='JBIRLA' fetch first 10 rows only;
select * from Jd1dta.audit_clexpf where oldclntnum in (select zigvalue from Jd1dta.pazdchpf where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis fetch first 10 rows only)) and oldjobnm = 'G1ZDPCLHIS' and newUSRPRF='JBIRLA';
select * from Jd1dta.versionpf  where clntnum in (select zigvalue from Jd1dta.pazdchpf where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis ))  fetch first 10 rows only;
select * from Jd1dta.zclnpf  where clntnum in (select zigvalue from Jd1dta.pazdchpf where ZENTITY in (select distinct REFNUM from dmigtitdmgcltrnhis )) and jobnm = 'G1ZDPCLHIS' and USRPRF='JBIRLA' fetch first 10 rows only;

--Check znlnpf effdate update 
select * from Jd1dta.zclnpf  where jobnm = 'G1ZDPCLHIS' and USRPRF='JBIRLA' order by datime desc fetch first 10 rows only;

---DM Unieque update
select * from DMUNIQUENOUPDT;

--Check unique no updated
select * from pazdnypf where zigvalue='20006501';
select * from zclnpf where clntnum='20006501';
select chdrnum, UNIQUE_NUMBER_01 from ztrapf where chdrnum='XC770767';
select chdrnum, UNIQUE_NUMBER_02 from zinsdtlspf where chdrnum='XC770767';



--========================================================================================================================================================================================
--Client Bank
select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoecb2009 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoecb2009 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoecb2009 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoecb2009 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoecb2009 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;

select * from zdoecb2009 where indic='E' ;
select * from dmigtitdmgclntbank  ;

select * from pazdclpf where zentity='0850570500';
-----Insert IG check----        

select * from pazdclpf where substr(zentity,1,10) in (select REFNUM from dmigtitdmgclntbank fetch first 10 rows only) and JOBNAME='G1ZDCLTBNK';
select * from clbapf where  clntnum in (select substr(zigvalue,1,8) from pazdclpf where substr(zentity,1,10) in (select REFNUM from dmigtitdmgclntbank fetch first 10 rows only)) and jobnm='G1ZDCLTBNK' and USRPRF='JBIRLA' ;
select * from clrrpf where  RTRIM(FORENUM) in (select BANKKEY||RTRIm(clbapf.bankacckey) from clbapf where  clntnum in (select substr(zigvalue,1,8) from pazdclpf where substr(zentity,1,10) in (select REFNUM from dmigtitdmgclntbank fetch first 10 rows only)) ) and jobnm='G1ZDCLTBNK' and USRPRF='JBIRLA' ;
select * from audit_clrrpf where RTRIM(newFORENUM) in (select BANKKEY||RTRIm(clbapf.bankacckey) from clbapf where  clntnum in (select substr(zigvalue,1,8) from pazdclpf where substr(zentity,1,10) in (select REFNUM from dmigtitdmgclntbank fetch first 10 rows only)) ) and newjobnm='G1ZDCLTBNK' and newUSRPRF='JBIRLA';
--========================================================================================================================================================================================

--Member and Ind Pol

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoemb2004 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoemb2004 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoemb2004 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoemb2004 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoemb2004 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoein2006 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoein2006 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoein2006 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoein2006 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoein2006 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select distinct EROR01, ERRMESS01, ERORFLD01  from zdoemb2004 where indic='E';
select distinct EROR02, ERRMESS02, ERORFLD02  from zdoemb2004 where indic='E';
select distinct EROR03, ERRMESS03, ERORFLD03  from zdoemb2004 where indic='E';
select distinct EROR04, ERRMESS04, ERORFLD04  from zdoemb2004 where indic='E';

             
-----Insert IG check----        

select *   from Jd1dta.PAZDRPPF where chdrnum in (select refnum  from dmigtitdmgmbrindp1 fetch first 10 rows only) and jobname='G1ZDMBRIND' ;
select chdrnum, mplnum, tranno, datime   from Jd1dta.gchd  where chdrnum in (select distinct substr(refnum,1,8)  from dmigtitdmgmbrindp1 fetch first 10 rows only)  and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.GCHPPF   where chdrnum in (select distinct substr(refnum,1,8)  from dmigtitdmgmbrindp1 fetch first 10 rows only)  and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.GCHIPF   where chdrnum in (select distinct substr(refnum,1,8)  from dmigtitdmgmbrindp1 fetch first 10 rows only)  and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.zclepf   where clntnum in ( SELECT  distinct pazd.zigvalue AS IGCLNTNUM
              FROM Jd1dta.dmigtitdmgmbrindp1 TIT
              left outer join Jd1dta.pazdclpf PAZD
                on RTRIM(TIT.clientno) = RTRIM(pazd.zentity) fetch first 10 rows only)  and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.zcelinkpf  where clntnum in ( SELECT  distinct pazd.zigvalue AS IGCLNTNUM
              FROM Jd1dta.dmigtitdmgmbrindp1 TIT
              left outer join Jd1dta.pazdclpf PAZD
                on RTRIM(TIT.clientno) = RTRIM(pazd.zentity) fetch first 10 rows only) and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.clrrpf  where clntnum in ( SELECT  distinct pazd.zigvalue AS IGCLNTNUM
              FROM Jd1dta.dmigtitdmgmbrindp1 TIT
              left outer join Jd1dta.pazdclpf PAZD
                on RTRIM(TIT.clientno) = RTRIM(pazd.zentity) fetch first 10 rows only) and jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';
select *   from Jd1dta.audit_clrrpf   where oldclntnum in ( SELECT  distinct pazd.zigvalue AS IGCLNTNUM
              FROM Jd1dta.dmigtitdmgmbrindp1 TIT
              left outer join Jd1dta.pazdclpf PAZD
                on RTRIM(TIT.clientno) = RTRIM(pazd.zentity) fetch first 10 rows only) and newjobnm='G1ZDMBRIND' and newUSRPRF='JBIRLA';
select *   from Jd1dta.gmhdpf  where chdrnum in (select distinct substr(refnum,1,8)  from dmigtitdmgmbrindp1 fetch first 10 rows only)  and  jobnm='G1ZDMBRIND'and USRPRF='JBIRLA';
select *   from Jd1dta.gmhipf  where chdrnum in (select distinct substr(refnum,1,8)  from dmigtitdmgmbrindp1 fetch first 10 rows only)  and  jobnm='G1ZDMBRIND' and USRPRF='JBIRLA';


--========================================================================================================================================================================================
---Master polpatch

select chdrnum,mplnum,occdate,tranno,datime from Jd1dta.gchd where chdrnum  in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol) and jobnm = 'G1ZDMSTPOL' ;
select chdrnum, ccdate, crdate,ZRNWCNT from Jd1dta.gchipf where  chdrnum in (select distinct RTRIM(CHDRNUM) from dmigtitdmgmaspol ) and jobnm = 'G1ZDMSTPOL' ;

--========================================================================================================================================================================================

-----POLHIST
select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoeph2005 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoeph2005 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoeph2005 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoeph2005 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoeph2005 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;

select * from zdoeph2009 where indic='E' and eror01='RQNJ';

select distinct mplnum from dmigtitdmgpoltrnh where chdrnum in (select substr(zrefkey,1,8) from  zdoeph2002 where indic='E' and EROR01='E186');

select * from dmigtitdmgpoltrnh;
-----Insert IG check----        

select * from Jd1dta.PAZDPTPF where ZENTITY in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobname = 'G1ZDPOLHST';
select * from Jd1dta.ZTRAPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA' ;
select * from Jd1dta.ZALTPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA';
select * from Jd1dta.ZMCIPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA';
select * from Jd1dta.ZBENFDTLSPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA';
select * from Jd1dta.ZINSDTLSPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA';

--========================================================================================================================================================================================
-------POLCOV

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoepc0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoepc0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoepc0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoepc0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoepc0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select distinct EROR01, ERRMESS01, ERORFLD01  from zdoepc0003 where indic='E';

select  * from dmigtitdmgmbrindp2 where chdrnum in (  select DISTINCT substr(zrefkey,1,8) from zdoepc0001 where indic='E' and EROR01='E186') ;

-----Insert IG check----        

select * from Jd1dta.PAZDPCPF where ZENTITY in (select refnum from dmigtitdmgmbrindp2 fetch first 10 rows only) and JOBNAME = 'G1ZDPOLCOV' ;
select * from Jd1dta.GXHIPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 5 rows only) and jobnm = 'G1ZDPOLCOV' and USRPRF='JBIRLA' fetch first 15 rows only ;
select * from Jd1dta.ZTEMPCOVPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 5 rows only) and  jobnm = 'G1ZDPOLCOV' and USRPRF='JBIRLA' fetch first 15 rows only ;
select * from Jd1dta.ZSUBCOVDTLS where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and  jobnm = 'G1ZDPOLCOV' and USRPRF='JBIRLA';
select * from Jd1dta.ZODMPRMVERPF where chdrnum in (select chdrnum from dmigtitdmgpoltrnh fetch first 10 rows only) and  jobnm = 'G1ZDPOLCOV' and USRPRF='JBIRLA';


--========================================================================================================================================================================================
-------POLRISK

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoern0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoern0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoern0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoern0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoern0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select * from zdoern0003 where indic ='E' and eror01='PA01';
select distinct EROR01, ERRMESS01, ERORFLD01  from zdoern0001 where indic ='E';
select * from DMIGTITDMGAPIRNO;

-----Insert IG check----        

select * from Jd1dta.PAZDRNPF where ZENTITY in (select chdrnum from DMIGTITDMGAPIRNO fetch first 10 rows only) and JOBNAME = 'G1ZDAPIRNO' ;
select * from Jd1dta.ZAPIRNOPF where chdrnum in (select chdrnum from DMIGTITDMGAPIRNO fetch first 10 rows only) and jobnm = 'G1ZDAPIRNO' and USRPRF='JBIRLA' ;

--========================================================================================================================================================================================
--Corresponding address
select * from stagedbusr.titdmgcoraddr@dmstagedblink;
-----Insert IG check----        

select * from zcorpf  where chdrnum in (select chdrnum from stagedbusr.titdmgcoraddr@dmstagedblink) and jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA'  fetch first 10 rows only;
select * from zcorpf where jobnm = 'G1ZDPOLHST' and USRPRF='JBIRLA';

--========================================================================================================================================================================================
-----Bill His

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoebl0026 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoebl0026 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoebl0026 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoebl0026 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoebl0026 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select * from dmigtitdmgbill1;



-----Insert IG check---- 
select *  from PAZDRBPF where chdrnum in (select chdrnum from dmigtitdmgbill1 fetch first 10 rows only) and JOBNAME='G1ZDBILLIN' fetch first 10 rows only;
select *  from GBIHPF where chdrnum in (select chdrnum from dmigtitdmgbill1 fetch first 10 rows only) and jobnm='G1ZDBILLIN' and USRPRF='JBIRLA' fetch first 10 rows only;
select *  from GPMDPF where chdrnum in (select chdrnum from dmigtitdmgbill1 fetch first 10 rows only) and jobnm='G1ZDBILLIN' and USRPRF='JBIRLA' fetch first 10 rows only;
select *  from GBIDPF where billno in ( select billno  from GBIHPF where chdrnum in (select chdrnum from dmigtitdmgbill1 fetch first 10 rows only)) and jobnm='G1ZDBILLIN' and USRPRF='JBIRLA' fetch first 10 rows only;

--Billing check
select * from anumpf where autonum in (select gbihpf.billno  from GBIHPF where jobnm='G1ZDBILLIN' and USRPRF='JBIRLA' ) and prefix='PR';

select max(billno)  from GBIHPF where jobnm='G1ZDBILLIN'  ;--3257896
select max(billno)  from GBIHPF  ;--12203337

--========================================================================================================================================================================================
---Billing Dishonor

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoepd0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoepd0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoepd0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoepd0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoepd0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select distinct ZFILENME, EROR01, ERRMESS01, ERORFLD01 from zdoepd0003 where indic='E';

select * from dmigtitdmgmbrindp3;
-----Insert IG check---- 
select *  from  PAZDPDPF where oldchdrnum in (select oldpolnum from dmigtitdmgmbrindp3)and jobname='G1ZDPOLDSH' ;		
select *  from ZUCLPF where jobnm='G1ZDPOLDSH' and USRPRF='JBIRLA' order by datime desc;


--========================================================================================================================================================================================

--Billing Colres
select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoecr0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoecr0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoecr0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoecr0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoecr0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select * from zdoecr000;
select * from dmigtitdmgcolres;
-----Insert IG check---- 

select *  from Jd1dta.PAZDCRPF where zentity in (select chdrnum from dmigtitdmgcolres fetch first 10 rows only) and JOBNAME='G1ZDCOLRES' ;
select *  from Jd1dta.ZCRHPF  where chdrnum in (select chdrnum from dmigtitdmgcolres fetch first 10 rows only)  and  jobnm='G1ZDCOLRES' and USRPRF='JBIRLA';
select *  from Jd1dta.ZUCLPF where chdrnum in (select chdrnum from dmigtitdmgcolres fetch first 10 rows only)  and  jobnm='G1ZDCOLRES' and USRPRF='JBIRLA';

--========================================================================================================================================================================================

--Billing Refund

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoerf0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoerf0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoerf0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoerf0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoerf0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;



select * from zdoerf0003 where indic='E';
select * from dmigtitdmgref1;

-----Insert IG check---- 

select *  from  PAZDRFPF where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only) and JOBNAME='G1ZDBILLRF';
select *  from   Jd1dta.GBIHPF  where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only) and  jobnm='G1ZDBILLRF' and USRPRF='JBIRLA';
select *  from   Jd1dta.ZRFDPF  where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only) and  jobnm='G1ZDBILLRF' and USRPRF='JBIRLA';
select *  from   Jd1dta.ZREPPF  where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only) and  jobnm='G1ZDBILLRF' and USRPRF='JBIRLA'; 
select *  from   Jd1dta.GPMDPF  where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only) and  jobnm='G1ZDBILLRF' and USRPRF='JBIRLA' fetch first 10 rows only;
select *  from   Jd1dta.GBIDPF  where billno in (select billno  from   Jd1dta.GBIHPF  where chdrnum in (select chdrnum from dmigtitdmgref1 fetch first 10 rows only)) and  jobnm='G1ZDBILLRF' and USRPRF='JBIRLA' fetch first 10 rows only;


select max(billno)  from GBIHPF where jobnm='G1ZDBILLIN'  ;--3257896
select max(billno)  from GBIHPF  ;--12203337
-----========================================================================================================================================================================================
---Superman
select chdrnum, datime from zsmandtlpf  where USRPRF='JBIRLA' order by datime desc;
select chdrnum, tranno,zsmandte,datime from ztempcovpf  where (chdrnum,tranno) in (select chdrnum,tranno from zsmandtlpf  where USRPRF='JBIRLA') fetch FIRST 5 rows only;


--========================================================================================================================================================================================
--Letters

select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoelt0007 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoelt0007 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoelt0007 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoelt0007 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoelt0007 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select distinct EROR01, ERRMESS01, ERORFLD01   from zdoelt0005 where indic='E';--ER120  

select * from dmigtitdmgletter;
-----Insert IG check---- 

select *  from Jd1dta.pazdltpf where chdrnum in (select chdrnum from dmigtitdmgletter fetch first 10 rows only) and jobname = 'G1ZDLETR' fetch first 10 rows only;  
select *  from Jd1dta.letcpf where chdrnum in (select chdrnum from dmigtitdmgletter fetch first 10 rows only) and jobnm = 'G1ZDLETR' and USRPRF='JBIRLA' fetch first 10 rows only; 

--========================================================================================================================================================================================
----RENEWAl Determination


select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoerd0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoerd0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoerd0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoerd0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoerd0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select distinct  ZFILENME, EROR01, ERRMESS01, ERORFLD01,ERRORNO from (
select distinct ZFILENME,  EROR01, ERRMESS01, ERORFLD01, FLDVALU01, ERORPROG01, JOBNUM, INDIC ,'EROR01' as ERRORNO from zdoerc0003 where indic='E' and RTRIm(EROR01) is not null
union 
select distinct ZFILENME,  EROR02, ERRMESS02, ERORFLD02, FLDVALU02, ERORPROG02, JOBNUM, INDIC ,'EROR02'as ERRORNO  from zdoerc0003 where indic='E' and RTRIm(EROR02) is not null
union 
select distinct ZFILENME,  EROR03, ERRMESS03, ERORFLD03, FLDVALU03, ERORPROG03, JOBNUM, INDIC ,'EROR03' as ERRORNO from zdoerc0003 where indic='E' and RTRIm(EROR03) is not null
union 
select distinct ZFILENME,  EROR04, ERRMESS04, ERORFLD04, FLDVALU04, ERORPROG04, JOBNUM, INDIC ,'EROR04' as ERRORNO from zdoerc0003 where indic='E' and RTRIm(EROR04) is not null
union
select distinct ZFILENME,  EROR05, ERRMESS05, ERORFLD05, FLDVALU05, ERORPROG05, JOBNUM, INDIC ,'EROR05' as ERRORNO  from zdoerc0003 where indic='E' and RTRIm(EROR05) is not null)
where EROR01 is not null order by ERRORNO ;


select * from zdoerc0002 where indic='E' and eror01='RQLP';
select * from zdoerd0002 where indic='E' and ZFILENME='DMIGTITDMGRNWDT2';


select * from STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK where RTRIm(prodtyp02) IS not null;

select * from DMIGODMVERSIONHIS;


select * from dmigtitdmgrnwdt1_int;
select * from ZRNWPERDPF;
select * from ZDOERD_INT;  ---Error tables 
select * from ZDOERC_INT;   ---Error tables 
select distinct chdrnum from ZDOERD_INT ;
select * from ZDOERC_INT;
 
-----Insert IG check---- 

select * from ZRNWPERDPF;
select * from PAZDRDPF  where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobname='G1ZDRNWDTM';
select * from PAZDRCPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobname='G1ZDRNWDTM' fetch first 10 rows only;
select * from ZRNDTHPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobnm='G1ZDRNWDTM' and USRPRF='JBIRLA' ;
select * from ZRNDTDPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobnm='G1ZDRNWDTM' and USRPRF='JBIRLA' ;
select * from ZRNDTCOVPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobnm='G1ZDRNWDTM' and USRPRF='JBIRLA'fetch first 10 rows only ;
select * from ZRNDTSUBCOVPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only) and  jobnm='G1ZDRNWDTM' and USRPRF='JBIRLA' ;
select * from ZODMPRMVERPF where chdrnum in (select chdrnum from DMIGTITDMGRNWDT1 fetch first 10 rows only)and  jobnm='G1ZDRNWDTM' and USRPRF='JBIRLA' ;


---------------------------------
 --HCR Java API
select * from ZRNDTCOVPF where DPREM=0  and  SUMINS != 0;
select * from Jd1dta.DM_HCR_ODM  ;
select * from Jd1dta.ZRNDTCOVPF where PRODTYP like '%951%'  and DPREM=0;

----
select * from recon_master_rd where STATUS='PASS';
--========================================================================================================================================================================================
--Job code patching
select * from dmpacljobprty;
select * from dmpacljobprty where validflg='Y';
select clntnum,occpcode,occpclas,zoccdsc,zworkplce from clntpf where clntnum ='10952740';--76	建設作業	B

with 
FP_T1 as( select * from DMPACLJOBPRTY where policytype='FP'),
PP_T2 as (select * from DMPACLJOBPRTY where policytype='PP')
select FP_T1.CHDRNUM         FP_T1_CHDRNUM 		, PP_T2.CHDRNUM         PP_T2_CHDRNUM 	  , FP_T1.STAGECLNTNO     FP_T1_STAGECLNTNO     , PP_T2.STAGECLNTNO     PP_T2_STAGECLNTNO , FP_T1.ZIGVALUE        FP_T1_ZIGVALUE        , PP_T2.ZIGVALUE        PP_T2_ZIGVALUE    , FP_T1.EFFDATE         FP_T1_EFFDATE         , PP_T2.EFFDATE         PP_T2_EFFDATE     , FP_T1.OCCPCODE        FP_T1_OCCPCODE        , PP_T2.OCCPCODE        PP_T2_OCCPCODE    , FP_T1.ZOCCDSC         FP_T1_ZOCCDSC         , PP_T2.ZOCCDSC         PP_T2_ZOCCDSC     , FP_T1.OCCPCLAS        FP_T1_OCCPCLAS        , PP_T2.OCCPCLAS        PP_T2_OCCPCLAS    , FP_T1.ZWORKPLCE       FP_T1_ZWORKPLCE       , PP_T2.ZWORKPLCE       PP_T2_ZWORKPLCE   , FP_T1.ZENDCDE         FP_T1_ZENDCDE         , PP_T2.ZENDCDE         PP_T2_ZENDCDE     , FP_T1.POLICYSTATUS    FP_T1_POLICYSTATUS    , PP_T2.POLICYSTATUS    PP_T2_POLICYSTATUS, FP_T1.POLICYTYPE      FP_T1_POLICYTYPE      , PP_T2.POLICYTYPE      PP_T2_POLICYTYPE  , FP_T1.PRIORTY         FP_T1_PRIORTY         , PP_T2.PRIORTY         PP_T2_PRIORTY     , FP_T1.ZINSTYP         FP_T1_ZINSTYP         , PP_T2.ZINSTYP         PP_T2_ZINSTYP     , FP_T1.VALIDFLG        FP_T1_VALIDFLG        , PP_T2.VALIDFLG        PP_T2_VALIDFLG    , FP_T1.DATIME          FP_T1_DATIME          , PP_T2.DATIME          PP_T2_DATIME   
from FP_T1,PP_T2 where FP_T1.zigvalue=PP_T2.zigvalue and FP_T1.zinstyp<>PP_T2.zinstyp and (FP_T1.VALIDFLG='Y' or PP_T2.VALIDFLG='Y' )  order by FP_T1.zigvalue;

 --========================================================================================================================================================================================