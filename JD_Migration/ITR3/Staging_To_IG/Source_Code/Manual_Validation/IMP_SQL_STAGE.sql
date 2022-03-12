--==============================================================================================================================================
--Common Operation 
select * from v$sql order by FIRST_LOAD_TIME desc ;
SELECT * FROM USER_SYS_PRIVS; 
SELECT * FROM USER_TAB_PRIVS; 
SELECT * FROM USER_ROLE_PRIVS;
select * from all_tab_modifications where table_owner='STAGEDBUSR2';
--Replace USER with the desired username

--Granted Roles:

SELECT * 
  FROM DBA_ROLE_PRIVS 
 WHERE GRANTEE = 'USER';
--Privileges Granted Directly To User:

SELECT * 
  FROM DBA_TAB_PRIVS 
 WHERE GRANTEE = 'USER';
--Privileges Granted to Role Granted to User:

SELECT * 
  FROM DBA_TAB_PRIVS  
 WHERE GRANTEE IN (SELECT granted_role 
                     FROM DBA_ROLE_PRIVS 
                    WHERE GRANTEE = 'USER');
--Granted System Privileges:

SELECT * 
  FROM DBA_SYS_PRIVS 
 WHERE GRANTEE = 'USER';
--If you want to lookup for the user you are currently connected as, you can replace DBA in the table name with USER and remove the WHERE clause.
--==============================================================================================================================================
--DM stage common checking
select * from error_log;
select DISTINCT error_message from error_log;

select * from dm_transfm_cntl_table order by start_timestamp desc;
select * from ig_copy_cntl_table order by start_timestamp desc;
select * from TAB_NOT_FOUND_LIST;
truncate table error_log;
----Distinct campcode
select distinct(apc1cd) from zmrap00;
--Exctra camp code
select * from stagedbusr2.titdmgcampcde where ZCMPCODE not in (select distinct(apc1cd) from zmrap00);
--camp code not available while its avaible in zmrap00
select * from stagedbusr2.zmrap00 where apc1cd not in (select distinct(ZCMPCODE) from titdmgcampcde);
--Distinct endorser
select distinct(APC6CD) from zmrap00;
--
select * from user_indexes where STATUS!='VALID';
select * from SYS.user_constraints where status!='ENABLED';

--==============================================================================================================================================
--Data checking in all stagedbusr2 tables

select ( SELECT             COUNT(*)         FROM             stagedbusr2.ALTER_REASON_CODE  ) AS 			ALTER_REASON_CODE,
( SELECT             COUNT(*)         FROM             stagedbusr2.BTDATE_PTDATE_LIST  ) AS         BTDATE_PTDATE_LIST,
( SELECT             COUNT(*)         FROM             stagedbusr2.CARD_ENDORSER_LIST  ) AS         CARD_ENDORSER_LIST,
( SELECT             COUNT(*)         FROM             stagedbusr2.DECLINE_REASON_CODE  ) AS        DECLINE_REASON_CODE,
( SELECT             COUNT(*)         FROM             stagedbusr2.DMPR  ) AS                       DMPR,
( SELECT             COUNT(*)         FROM             stagedbusr2.DMPR1  ) AS                      DMPR1,
( SELECT             COUNT(*)         FROM             stagedbusr2.DSH_CODE_REF  ) AS               DSH_CODE_REF,
( SELECT             COUNT(*)         FROM             stagedbusr2.GRP_POLICY_FREE  ) AS            GRP_POLICY_FREE,
( SELECT             COUNT(*)         FROM             stagedbusr2.KANA_ADDRESS_LIST  ) AS          KANA_ADDRESS_LIST,
( SELECT             COUNT(*)         FROM             stagedbusr2.LETTER_CODE  ) AS                LETTER_CODE,
( SELECT             COUNT(*)         FROM             stagedbusr2.MSTPOLDB  ) AS                   MSTPOLDB,
( SELECT             COUNT(*)         FROM             stagedbusr2.MSTPOLGRP  ) AS                  MSTPOLGRP,
( SELECT             COUNT(*)         FROM             stagedbusr2.PJ_TITDMGCOLRES  ) AS            PJ_TITDMGCOLRES,
( SELECT             COUNT(*)         FROM             stagedbusr2.SOLICITATION_FLG_LIST  ) AS      SOLICITATION_FLG_LIST,
( SELECT             COUNT(*)         FROM             stagedbusr2.persnl_clnt_flg  ) AS           persnl_clnt_flg,
( SELECT             COUNT(*)         FROM             stagedbusr2.SPPLANCONVERTION  ) AS           SPPLANCONVERTION,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGAGENTPJ  ) AS              TITDMGAGENTPJ,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGBILL1  ) AS                TITDMGBILL1,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGBILL2  ) AS                TITDMGBILL2,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGCAMPCDE  ) AS              TITDMGCAMPCDE,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGCLNTCORP  ) AS             TITDMGCLNTCORP,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGCOLRES  ) AS               TITDMGCOLRES,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGENDCTPF  ) AS              TITDMGENDCTPF,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGINSSTPL  ) AS              TITDMGINSSTPL,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGMASPOL  ) AS               TITDMGMASPOL,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGMBRINDP3  ) AS             TITDMGMBRINDP3,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGREF1  ) AS                 TITDMGREF1,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGREF2  ) AS                 TITDMGREF2,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRAP00  ) AS                    ZMRAP00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRAT00  ) AS                    ZMRAT00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRCP00  ) AS                    ZMRCP00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMREI00  ) AS                    ZMREI00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRIC00  ) AS                    ZMRIC00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRIS00  ) AS                    ZMRIS00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRISA00  ) AS                   ZMRISA00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRLH00  ) AS                    ZMRLH00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRMT00  ) AS                    ZMRMT00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRRC00  ) AS                    ZMRRC00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRRP00  ) AS                    ZMRRP00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRRPT00  ) AS                   ZMRRPT00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRRR00  ) AS                    ZMRRR00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRRS00  ) AS                    ZMRRS00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRULA00  ) AS                   ZMRULA00,
( SELECT             COUNT(*)         FROM             stagedbusr2.TITDMGSUMINSFACTOR ) AS      TITDMGSUMINSFACTOR,
( SELECT             COUNT(*)         FROM             stagedbusr2.MIPHSTDB  ) AS                   MIPHSTDB,
( SELECT             COUNT(*)         FROM             stagedbusr2.trannotbl  ) AS                   trannotbl,

( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRAGE00  ) AS                   ZMRAGE00,
( SELECT             COUNT(*)         FROM             stagedbusr2.ZMRHR00  ) AS                   ZMRHR00,
( SELECT             COUNT(*)         FROM             stagedbusr2.renew_as_is  ) AS                   renew_as_is,
( SELECT             COUNT(*)         FROM             stagedbusr2.asrf_rnw_dtrm  ) AS                   asrf_rnw_dtrm,
( SELECT             COUNT(*)         FROM             stagedbusr2.zmrda00  ) AS                   zmrda00

from dual;
--==============================================================================================================================================
--Data checking in all stagedbusr tables
select ( SELECT      COUNT(*)          FROM             Stagedbusr.TITDMGAGENTPJ		) AS		TITDMGAGENTPJ	,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGAPIRNO      ) AS           TITDMGAPIRNO     ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGBILL1       ) AS           TITDMGBILL1      ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGBILL2       ) AS           TITDMGBILL2      ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCAMPCDE     ) AS           TITDMGCAMPCDE    ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCLNTBANK    ) AS           TITDMGCLNTBANK   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCLNTCORP    ) AS           TITDMGCLNTCORP   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCLNTPRSN    ) AS           TITDMGCLNTPRSN   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCLTRNHIS    ) AS           TITDMGCLTRNHIS   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCOLRES      ) AS           TITDMGCOLRES     ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGENDCTPF     ) AS           TITDMGENDCTPF    ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGENDSPCFC    ) AS           TITDMGENDSPCFC   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGINSSTPL     ) AS           TITDMGINSSTPL    ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGLETTER      ) AS           TITDMGLETTER     ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGMASPOL      ) AS           TITDMGMASPOL     ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGMBRINDP1    ) AS           TITDMGMBRINDP1   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGMBRINDP2    ) AS           TITDMGMBRINDP2   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGMBRINDP3    ) AS           TITDMGMBRINDP3   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGPOLTRNH     ) AS           TITDMGPOLTRNH    ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGREF1        ) AS           TITDMGREF1       ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGREF2        ) AS           TITDMGREF2       ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGSALEPLN1    ) AS           TITDMGSALEPLN1   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGZCSLPF      ) AS           TITDMGZCSLPF   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGRNWDT1      ) AS           TITDMGRNWDT1   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGRNWDT2      ) AS           TITDMGRNWDT2   ,
( SELECT             COUNT(*)          FROM             Stagedbusr.TITDMGCORADDR      ) AS           TITDMGCORADDR   

from dual;
--==============================================================================================================================================
--Module wise checking
--will give the endorder for each grp
  select * from dmpagrpmig;
  
--Coporate clint
select * from TITDMGCLNTCORP;
--==============================================================================================================================================
--Agent
select * from titdmgagentpj ;

--==============================================================================================================================================
--Master Policy
---src loading from DM
desc TITDMGMASPOL;
SELECT * from TITDMGENDCTPF;  
SELECT  * from  TITDMGINSSTPL ; 
SELECT  * from  TITDMGMASPOL ;
 ---src loading from PJ
 select * from MSTPOLDB;
 select * from MSTPOLGRP;
--Transformation
 --1 update TITDMGMASPOL ZCCDE,ZCONSGNM,ZBLADCD from MSTPOLDB absed on 
select   MSTPOLDB.ZCCDE
 ,MSTPOLDB.ZCONSGNM
 ,MSTPOLDB.ZBLADCD
 ,TITDMGMASPOL.ZENDCDE
 ,TITDMGMASPOL.CNTTYPE
FROM
  MSTPOLDB,
  TITDMGMASPOL
WHERE
    TRIM(MSTPOLDB.ENDCD) = TRIM(TITDMGMASPOL.ZENDCDE)
AND TRIM(MSTPOLDB.PRODCD) = TRIM(TITDMGMASPOL.CNTTYPE);

--2. update client number TITDMGMASPOL 
SELECT
   A.CLNTNUM
  ,B.CHDRNUM
FROM
  MSTPOLGRP A,
  TITDMGMASPOL B
WHERE
    TRIM(A.GRUPNUM) =
    CASE WHEN LENGTH(TRIM(B.CHDRNUM)) = 11 THEN SUBSTR(TRIM(B.CHDRNUM),4,8)
         ELSE TRIM(B.CHDRNUM )
    END;
--==============================================================================================================================================
---Sales plan
select * from SPPLANCONVERTION;
--==============================================================================================================================================
--Camp code
--Loading
select * from titdmgcampcde;
---Tranofrmation
--1. update many fields in titdmgcampcde   by script UPDATE_TITDMGCAMPCDE
--2. Insert into titdmgzcslpf using below query
SELECT
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan
            FROM
                zmrcp00
                INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                        AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                JOIN spplanconvertion ON oldzsalplan = zmrrp00.rpbvcd
            GROUP BY
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan;
--==============================================================================================================================================             
 ----Client personal 
 --Tranformation
 --1. first creat clint nuber form zmrap and zmris for owner and insured
 select * from persnl_clnt_flg;
--2.Insert data into titdmgcltrnhis_int with priority using alltalbes
select * from titdmgcltrnhis_int;
--3. Create srcnayosetbl for checking nayos with these records
select * from srcnayosetbl;
--4. Bsed on nayose chkig create TITDMGCLNTMAP for other modue to use
select * from TITDMGCLNTMAP;
select * from TITDMGCLNTMAP where stageclntno in (select stageclntno from TITDMGCLNTMAP group by stageclntno having count(*)>1 );
select * from titdmgcltrnhis_int where refnum in ('13518CF900','16459DJ300');

--5. Finally create clinet tranformation table based on TITDMGCLNTMAP 
select * from titdmgcltrnhis where refnum in ('13518CF900','16459DJ300');
select * from titdmgclntmap where refnum like '%00582662%';
--6. Jobcode patching
select * from dmpacljobcde;
--==============================================================================================================================================
---Client bank
--src loading
select * from card_endorser_list;
select * from zmrrpt00;
select * from dmpr1;
--tranformation  insert into titdmgclntbank and update or insert from DMPR1 by PJ for refund account
select * from titdmgclntbank;
--==============================================================================================================================================
---Member policy
--src load
SELECT * FROM grp_policy_free;
--1. Create POLICY_STATCODE record by DM_POLICY_STATUS_CODE.ssql
select * from POLICY_STATCODE;
--2.Sales plan convertion based SPPLANCONVERTION usinf raltion , hcr and etc..
select * from MEM_IND_POLHIST_SSPLAN_INTRMDT;
--3.procduer DM_data_trans_mempol.dm_mempol_grp_pol inserting recrods into maxpolnum and update records into zmrap00 for free plan policy from grp_policy_free
select * from maxpolnum;
select * from zmrap00;
--4. dm_mempol_oldpol :: inserting record into mempol for oldpol and zoncpol
select * from mempol;
--5.dm_mempol_transform :: Finalltranformtiaon
select * from titdmgmbrindp1;
--==============================================================================================================================================
--Policy History
--1. dm_policytran_transform tranformdata from all src tables for policy history module
select * from titdmgpoltrnh;
--2.dm_dpntno_insert this for unnamed insured for DPNTNO and MBRNO
select count(*) from dpntno_table;--4165725
--3.dm_polhis_cov for coveragee information for coverae module
select count(*) from titdmgmbrindp2;
--4. dm_polhis_apirno
--src load form PJ MIPHSTDB  will contain Paid plan data
select * from MIPHSTDB;
--Tranfromation
--4.1 insert record from MIPHSTDB to titdmgapirno
--4.2 update titdmgapirno for mbrno = '00001' where we have only one insured
--4.3  update titdmgapirno for mbrno from  zmris00 statement for matching name (for multiple records matching name)
--4.4 If name not amtching then inset into titdmgapirno_log
--4.5 Insert record into titdmgapirno for free plan pol
select * from titdmgapirno;
select * from titdmgapirno_log;

--5. Corresponding address
select * from titdmgcoraddr;
--==============================================================================================================================================
--Billin installemnt
--src load from pj
select * from titdmgbill1;
select * from titdmgbill2;
--tranformtaion update titdmgbill1  for zacmcldt based on endorser schduleof ig
select * from titdmgbill1;

--1) To check for policy not in billing and write into stagedbusr2.policy_notin_billing if any.
  select * from policy_statcode where chdrnum in(select chdrnum from stagedbusr2.policy_notin_billing);
    select * from btdate_ptdate_list where chdrnum in(select chdrnum from stagedbusr2.policy_notin_billing);

  --2) To check for invalid bill from date in stagedbusr2.titdmgbill1 and write into stagedbusr2.invalid_cutoffperiod if any.
  select * from stagedbusr2.invalid_cutoffperiod;
  
  
  
--4) To check for invalid posting month or year in stagedbusr2.titdmgbill1 and write into stagedbusr2.invalid_zposbds if any.
  select * from stagedbusr2.invalid_zposbds;
--==============================================================================================================================================
--Billin Dishonor
--src load from pj
select * from TITDMGMBRINDP3;
--==============================================================================================================================================
--Billin Collection Result
--src load from pj
select * from dsh_code_ref;
select * from pj_titdmgcolres;
--Tranformation 
select * from titdmgcolres;
--==============================================================================================================================================
--Billin Refund
select * from titdmgref1;
select * from titdmgref2;
--==============================================================================================================================================

--Billin superman
select * from titdmgref1_sm;
select * from titdmgref2_sm;
--==============================================================================================================================================

--Letter
--src load
select * from ZMRLH00;
select * from LETTER_CODE;
--tranformation
select * from TITDMGLETTER;
--==============================================================================================================================================
--Tranno
select * from trannotbl;

select * from policy_statcode where STATCODE='CA' and ZPOLTDATE='99999999' and DTETRM='99999999';

select * from zmrap00 where substr(apcucd,1,8) = '57941939' order by APCVCD;
select * from btdate_ptdate_list where substr(chdrnum,1,8) = '57941939';

select * from titdmgmbrindp1 where refnum like '%57941939%';

select * from policy_statcode where STATCODE='CA' and ZPOLTDATE='99999999' and DTETRM='99999999' and chdrnum in (select substr(refnum,1,8) from titdmgmbrindp1 where TOTAL_PERIOD_COUNT=1);

