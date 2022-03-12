Stg to ig nayose task:


1.changes DDL "STAGEDBUSR"."TITDMGCLTRNHIS"

2.
IG nayose data:


  CREATE MATERIALIZED VIEW "Jd1dta"."MV_CLIENT_NAYOSE" ("ZENDCDE", "CLNTNUM", "KANASURNAME", "KANAGIVNAME", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE", "ZKANASNMNOR", "ZKANAGNMNOR")
  AS SELECT ZCEL.ZENDCDE, CLNT.CLNTNUM,
SUBSTR((REGEXP_REPLACE(CLNT.ZKANASNMNOR, '[ 　]','')),1,60) AS KANASURNAME,
SUBSTR((REGEXP_REPLACE(CLNT.ZKANAGNMNOR, '[ 　]','')),1,60) AS KANAGIVNAME,
CLNT.CLTSEX,CLNT.CLTDOB, CLNT.CLTPCODE, TRIM(CLEX.RMBLPHONE), TRIM(CLNT.ZKANAGNMNOR),  
TRIM(CLNT.ZKANASNMNOR)FROM Jd1dta.CLNTPF CLNT INNER JOIN Jd1dta.ZCELINKPF ZCEL ON ZCEL.CLNTNUM = CLNT.CLNTNUM 
LEFT OUTER JOIN Jd1dta.CLEX ON CLEX.CLNTNUM = CLNT.CLNTNUM
WHERE CLNT.VALIDFLAG = '1' AND CLNT.CLTTYPE ='P';

 Create table IGNAYOSEVIEW and DMPANAAYOSEVIEW and PAZDNYPF
 
3.PRE_NAYOSE_STEP for insert data into IGNAYOSEVIEW and DMPANAAYOSEVIEW.
    Search into into both views and get the client and status

--------------Current running notes
select *  from dmpanayoseview;
select *  from ignayoseview;--50546519
select * from clntpf where clntnum='50546519';
select * from pazdrppf;
--Case 1: FP Plan pol : no client in ig  :5000000100  : DMPA, NW , N
--Case 2: FP plan pol : Clint in ig  :5000000200   : IG, EX , N    50546519
--Case 3 : PP plan client No client in DMPA : 5000000300  : DMPA : NW , N
--Case 4 : PP+IF plan cleint client in DMPA FP+CA  :5000000400 : DMPA, EX , Y
--Case 4 : PP+CA plan client in DMPA FP+CA :5000000500 : DMPA,EX, Y
--Case 5 : PP+CA plan client in DMPA FP+IF :5000000600 : DMPA,EX, N  : 50582332
/*
NY	DMPA	NW	N	5000000100	55246840
NY	IG	    EX	N	5000000200	50546519
NY	DMPA	NW	N	5000000300	55246842
NY	DMPA	EX	Y	5000000400	50581603
NY	DMPA	EX	Y	5000000500	50581616
NY	DMPA	EX	N	5000000600	50582332
NY	DMPA	NW	N	5000000700	55246846
NY	DMPA	NW	N	5000000800	55246847
*/
select * FROM Jd1dta.DMIGTITDMGCLTRNHIS;
select * FROM Jd1dta.dmpanayoseview;
select * FROM Jd1dta.ignayoseview;
select * FROM Jd1dta.DMIGTITNYCLT;
select * from padmnypf;
select * from dmuniquenoupdt;
select * from ZDMBKPZTRA;
select * from zdmbkpzins;
select * from zinsdtlspf;

DELETE FROM Jd1dta.DMIGTITDMGCLTRNHIS;
DELETE FROM Jd1dta.dmpanayoseview;
delete from ignayoseview;
delete from DMIGTITNYCLT;

      select * from dmberpf;
    select * from dmbmonpf;
  select * from zdoeny0031;


-------------------m
--DMMB01
 --20200410
     select * from busdpf;
select refnum,mbrno,statcode,zpoltdate,plnclass,zlaptrx,effdate,crdate,period_no,total_period_count,trannomin,last_trxs from STAGEDBUSR.titdmgmbrindp1 where ZRNWCNT =0 and total_period_count=1 ;
select * from STAGEDBUSR.titdmgmbrindp1 where substr(refnum ,1,8)='N00A1407' order by refnum , mbrno desc;
/*
Type A
M00A1402001		IF	99999999	F	Y	1	Y
M00A1409001		XN	99999999	P	N	1	Y
M00A1460001		IF	99999999	P	N	1	Y
M00A1524001		CA	99999999	P	N	1	Y
M00A1610001		PN	99999999	P	N	1	Y
M00A1703001		IF	99999999	F	Y	1	Y

Type B
J00A1407010		IF	99999999	P	N	1	Y

Type C
K00A1407001		IF	99999999	P	N	2	N
K00A1407011		IF	99999999	P	N	2	Y

Type D
L00A1407011		IF	99999999	P	N	2	N
L00A1407021		IF	99999999	P	N	2	Y

Type E(Renewal rejection)
Future cancel:
N00A1407000		IF	99999999	P	N	3	N
N00A1407010		IF	99999999	P	N	3	N
N00A1407011		IF	20200410	P	N	3	Y

already cancel:
O00A1407000		CA	99999999	P	N	3	N
O00A1407010		CA	99999999	P	N	3	N
O00A1407011		CA	20200410	P	N	3	Y
*/
/*
700A1198	IF	PP	F 	99999999	1A      	00000746	20190410	20200409
700A1198	IF	PP	F 	99999999	1A      	00000746	20200410	20210409
700A1197	IF	PP	F 	99999999	3C      	00000747	20190401	20200331
800A0044	IF	FP	C 	99999999	99      	00000748	20190401	20200331
700A1336	IF	PP	F 	99999999	99      	00000747	20190410	20200409
700A1336	IF	PP	F 	99999999	99      	00000747	20190410	20200409
*/

 select * from gchppf where chdrnum in (select chdrnum from gchd where chdrnum != mplnum and statcode='CA') and zplancls ='PP';
select chdrnum, statcode,effdcldt from gchd where chdrnum='700A5922';
select * from gchipf where chdrnum='700A6143';
select * from gchppf;
select * from gchppf where chdrnum in (select chdrnum from gchipf where zrnwcnt= 0) and zplancls='FP';
select chdrnum, mplnum, tranno from gchd where chdrnum='700A6324' order by tranno;
select chdrnum,ccdate,crate ,tranno from gchipf where chdrnum='700A6324' order by tranno;
select * from gmhdpf where chdrnum='700A5922' order by tranno;
select chdrnum, tranno  from gmhipf where chdrnum='700A5922' order by tranno;
select * from ztrapf where chdrnum='700A5922';
