--Insert into records for btdate_ptdate_list for cancelled from renewal and policy is still in IF statcode
--Create new table jd_policy_statcode 
--Create new proc with dm_policy_status_code_JD and replace policy_statcode by jd_policy_statcode.
--------------------------------------------------------------------------------------------------------------------------------------------
--Step1: Create new table jd_policy_statcode
  CREATE TABLE "STAGEDBUSR2"."JD_POLICY_STATCODE" 
   (	"APCUCD" VARCHAR2(11 CHAR) NOT NULL ENABLE, 
	"CHDRNUM" VARCHAR2(8 CHAR) NOT NULL ENABLE, 
	"EFFDATE" NUMBER(8,0) NOT NULL ENABLE, 
	"CRDATE" NUMBER(8,0) NOT NULL ENABLE, 
	"ZENDCDE" VARCHAR2(10 CHAR) NOT NULL ENABLE, 
	"PLNCLASS" VARCHAR2(1 CHAR) NOT NULL ENABLE, 
	"ZPOLTDATE" NUMBER(8,0) NOT NULL ENABLE, 
	"DTETRM" NUMBER(8,0) NOT NULL ENABLE, 
	"ZTRXSTAT" VARCHAR2(2 CHAR) NOT NULL ENABLE, 
	"ZPDATATXFLG" VARCHAR2(1 CHAR), 
	"STATCODE" VARCHAR2(2 CHAR), 
	"BTDATE" NUMBER(8,0) NOT NULL ENABLE, 
	"PTDATE" NUMBER(8,0) NOT NULL ENABLE, 
	"ZPGPFRDT" NUMBER(8,0) NOT NULL ENABLE, 
	"ZPGPTODT" NUMBER(8,0) NOT NULL ENABLE, 
	"ENDSERCD" VARCHAR2(2 CHAR), 
	"CASENAME" VARCHAR2(100 CHAR) NOT NULL ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS" ;


--Step 2 Create new proc with dm_policy_status_code_JD and replace policy_statcode by jd_policy_statcode.

--Step 3 Execute dm_policy_status_code_JD

--Step 4 check select chdrnum from jd_policy_statcode  where TRIm(statcode) is null

--Stoe 5 execute below patching 
INSERT
    INTO btdate_ptdate_list
        (
           CHDRNUM,
           PTDATE,
           BTDATE,
           STATCODE,
           ZPGPFRDT,
           ZPGPTODT,
           ENDSERCD
        )
SELECT
    *
FROM
    (
        SELECT
            substr(a.apcucd, 1, 8) chdrnum,
            --a.apa2dt,
           
           to_date(a.apa2dt, 'YYYYMMDD')-1 ptdate,
           to_date(a.apa2dt, 'YYYYMMDD')-1 btdate,
            'IF' statcode,
            99999999 zpgpfrdt,
            99999999 zpgptodt,
            'JD' endsercd
        FROM
            zmrap00    a
            LEFT JOIN zmrrpt00   c ON a.apc7cd = c.rptbtcd
        WHERE
            a.apblst IN (
                3
            )
            AND c.rptfpst = 'P'
            and substr(a.apcucd,1,8)in (select chdrnum from jd_policy_statcode where statcode='IF' and btdate='99999999')) b
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            btdate_ptdate_list a where
            a.chdrnum = b.chdrnum
            
    );
	
	
	
--======================================================================================================================================   
 --BTdate PTdate validation
 select * from
   (SELECT 
    distinct SUBSTR(a.apcucd,1,8) as chdrnum
FROM
    zmrap00    a 
    LEFT JOIN zmrrpt00   c ON a.apc7cd = c.rptbtcd
where
     c.rptfpst = 'P' and  a.apblst !='5')B 
     where not exists 
     (
      select 1 from btdate_ptdate_list A where A.chdrnum = B.chdrnum 
      ) ;
	
--======================================================================================================================================
---Policy Validation
--1.
      select * from policy_statcode where substr(apcucd,9,2)>0 and statcode='XN' ;
        
---2. Validate with below query
	     select * from jd_policy_statcode where statcode in ('IF','XN') and btdate='99999999';

---3. Validating Policy CA without termdate
	select * from policy_statcode where STATCODE='CA' and ZPOLTDATE='99999999' and DTETRM='99999999';
	
---4. Validating if poliy has CA and last transaction is not the canellation
with SEQ_NOT_ORDER as
(select 
case 
    when substr(a.zseqno,1,2) = '00' then 
        'NB' 
    else 
        'RN' 
    end as Period_Type, a.* from (
select apcucd,substr(apcucd,1,8) Chdrnum, substr(apcucd,9,3) zseqno,apa2dt, apcvcd,apcycd,
row_number() over(partition by  substr(apcucd,1,8) order by apcucd) zseq_order,
row_number() over(partition by  substr(apcucd,1,8) order by apcvcd) apcvcd_order,
row_number() over(partition by  substr(apcucd,1,8) order by apcucd desc) zseq_Max
from zmrap00
) a
where a.zseq_order <> a.apcvcd_order),
BT_PT_DATE as (select * from btdate_ptdate_list where statcode='CA')
select * from SEQ_NOT_ORDER SEQNO,BT_PT_DATE BT_PT where SEQNO.apcycd BETWEEN 50 AND 69 and SEQNO.ZSEQ_MAX !=1 and BT_PT.chdrnum= SEQNO.chdrnum;
---------------------------------------------------------------------------------------
---When policy posting year/month given as zero 
--XN ::No Patching required , posting year and month will be updated by billing transformation procedure
--These policies not in scope 
--CA  :: Posting month/year 0 and pociy statcode CA will be deleted from BIll1 and Bill2 tables	
--Step1: Delete records from Bill1 and bill2 for where posting year and month is 0 and polciy statcode is CA
delete from titdmgbill2 where chdrnum in (select chdrnum from jd_policy_statcode where statcode='CA') and chdrnum in (  
select chdrnum from titdmgbill1 where chdrnum in (select chdrnum from jd_policy_statcode where statcode='CA') and titdmgbill1.zposbdsm='0');
delete  from titdmgbill1 where chdrnum in (select chdrnum from jd_policy_statcode where statcode='CA') and titdmgbill1.zposbdsm='0';
------------------------------------------------------------------------------------------------------------

	