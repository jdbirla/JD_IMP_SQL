--Nmon AIX path

/zurwork/nmon


---statspack
https://docs.oracle.com/cd/E13160_01/wli/docs10gr3/dbtuning/statsApdx.html

--Snap id generate
variable snap number;
begin   
:snap := statspack.snap;   
end;
/
print snap;


--Report Generation
sduo su - oracle

bash

()[oracle@jpaigdbp05]$ sqlplus perfstat/perfstat@igprd51

@?/rdbms/admin/spreport.sql

/home/jpajbi/Test_Report/sp_874_875.lst

oracle link for statspack id:

--============================================================================================



EXPLAIN PLAN FOR
select * from bsprpf order by datime desc;
SELECT * 
FROM   TABLE(DBMS_XPLAN.DISPLAY);



--============================================================================================

---PGA memory checking
 --PGA
   select A.*, a.VALUE/POWER(1024,2)  MB,
     a.VALUE/POWER(1024,3)  GB from V$PGASTAT A;
	 
select name, value
from v$statname n, v$sesstat t
where n.statistic# = t.statistic#
and t.sid = ( select sid from v$mystat where rownum = 1 )
and n.name in
('session pga memory', 'session pga memory max','session uga memory', 'session uga memory max');
--PGA Memory

select NAME,ROUND((VALUE)/1024/1024,1) MB , round(VALUE/POWER(1024,3),1)  GB  from v$pgastat;
--============================================================================================


   ----Redo Log checking
    SELECT
   a.group#,
   substr(b.member,1,30) name,
   a.members,
    a.bytes/POWER(1024,2)  MB,
     a.bytes/POWER(1024,3)  GB,
   a.status
FROM
   v$log     a,
   v$logfile b
WHERE
   a.group# = b.group#;
   
   --Temp file size
   
select a.name,b.name, a.bytes, a.bytes/POWER(1024,2)  MB,
     a.bytes/POWER(1024,3)  GB from v$tempfile a, v$tablespace b where a.ts#=b.ts#;
   
   -- SGA
   show sga;
   
   
   ---Undo Table space current usage
   SELECT a.tablespace_name,
SIZEMB,
USAGEMB,
(SIZEMB - USAGEMB) FREEMB
FROM ( SELECT SUM (bytes) / 1024 / 1024 SIZEMB, b.tablespace_name
FROM dba_data_files a, dba_tablespaces b
WHERE a.tablespace_name = b.tablespace_name AND b.contents like 'UNDO'
GROUP BY b.tablespace_name) a,
( SELECT c.tablespace_name, SUM (bytes) / 1024 / 1024 USAGEMB
FROM DBA_UNDO_EXTENTS c
WHERE status <> 'EXPIRED'
GROUP BY c.tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name;
   
  
--============================================================================================
--Kill paralle threads session
select 'alter system kill session ''' || s.sid ||',' || s.serial# || ''';'
                                        from gv$session s,gv$sql q
                            where s.sql_address = q.address
                                         and s.sql_hash_value = q.hash_value
                                         and s.sql_child_number = q.child_number
                                         AND s.status = 'ACTIVE'
                                         and s.module = 'DBMS_SCHEDULER';
				  


--============================================================================================
--MATERIALIZED View
				  
alter MATERIALIZED VIEW MV_ZENCIPF 
REFRESH 
ON DEMAND;

alter MATERIALIZED VIEW MV_ZENDRPF 
REFRESH 
ON DEMAND;

alter MATERIALIZED VIEW MV_ZMCIPF 
REFRESH 
ON DEMAND;

alter MATERIALIZED VIEW MV_ZMCIPF_CRDT 
REFRESH 
ON DEMAND;


--============================================================================================

alter MATERIALIZED VIEW MV_ZENCIPF 
REFRESH 
ON COMMIT;

alter MATERIALIZED VIEW MV_ZENDRPF 
REFRESH 
ON COMMIT;

alter MATERIALIZED VIEW MV_ZMCIPF 
REFRESH 
ON COMMIT;

alter MATERIALIZED VIEW MV_ZMCIPF_CRDT 
REFRESH 
ON COMMIT;

 --============================================================================================

 
---All tabble row count check
select
   table_name,
   num_rows counter
from
   dba_tables
where
   owner = 'STAGEDBUSR2'
  and table_name like 'TIT%'
order by
   table_name;
   

 
--============================================================================================
--DM all tables
SELECT *
   FROM USER_INDEXES where table_name in (
'AGNTPF',
'AGPLPF',
'AUDIT_CLEXPF',
'AUDIT_CLNT',
'AUDIT_CLNTPF',
'AUDIT_CLRRPF',
'CLBAPF',
'CLEXPF',
'CLNTPF',
'CLRRPF',
'GBIDPF',
'GBIHPF',
'CHDRPF',
'GCHIPF',
'GCHPPF',
'GMHDPF',
'GMHIPF',
'GPMDPF',
'GXHIPF',
'LETCPF',
'VERSIONPF',
'ZACRPF',
'ZALTPF',
'ZAPIRNOPF',
'ZBENFDTLSPF',
'ZCELINKPF',
'ZCLEPF',
'ZCLNPF',
'ZCPNPF',
'ZCRHPF',
'ZCSLPF',
'ZENCTPF',
'ZINSDTLSPF',
'ZMCIPF',
'ZODMPRMVERPF',
'ZREPPF',
'ZRFDPF',
'ZRNDTCOVPF',
'ZRNDTDPF',
'ZRNDTHPF',
'ZRNDTSUBCOVPF',
'ZRNWPERDPF',
'ZSUBCOVDTLS',
'ZTEMPCOVPF',
'ZTGMPF',
'ZTRAPF',
'ZUCLPF',) and UNIQUENESS != 'UNIQUE' ;




--============================================================================================
--Elapsed time
--LONG tun query
select SQL_TEXT,CPU_TIME, ELAPSED_TIME,MODULE,FIRST_LOAD_TIME,last_active_time,last_load_time from v$sql where SQL_TEXT not  like '%ZDOEBL%' order by LAST_LOAD_TIME desc ,ELAPSED_TIME desc ;

select * from ALL_SNAPSHOTS;
select * from
(
  select
     opname,
     start_time,
     target,
     sofar,
     totalwork,
     units,
     elapsed_seconds,
     message
   from
        v$session_longops
        
  order by start_time desc
)
where rownum <=1;

--This one shows SQL that is currently "ACTIVE":-

select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text
from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid,t.piece;

--This shows locks. Sometimes things are going slow, but it's because it is blocked waiting for a lock:

select
  object_name, 
  object_type, 
  session_id, 
  type,         -- Type or system/user lock
  lmode,        -- lock mode in which session holds lock
  request, 
  block, 
  ctime         -- Time since current mode was granted
from
  v$locked_object, all_objects, v$lock
where
  v$locked_object.object_id = all_objects.object_id AND
  v$lock.id1 = all_objects.object_id AND
  v$lock.sid = v$locked_object.session_id
order by
  session_id, ctime desc, object_name;
  
  --This is a good one for finding long operations (e.g. full table scans). If it is because of lots of short operations, nothing will show up.
  SELECT sid, to_char(start_time,'hh24:mi:ss') stime, 
message,( sofar/totalwork)* 100 percent 
FROM v$session_longops
WHERE sofar/totalwork < 1;

------------------------
--Sequnce Cache
select * from user_sequences where sequence_name in (

'SEQ_CHDRPF',
'SEQ_GCHIPF',   
'SEQ_GCHPPF',   
'SEQ_CLRRPF',   
'SEQANUMPF',   
'SEQ_CLEXPF',   
'SEQ_CLNTPF',   
'SEQ_CLNTPF',   
'SEQ_VERSIONPF',
'SEQ_ZCSLPF',   
'SEQ_CLBAPF',   
'SEQ_ZMCIPF',   
'SEQ_GXHIPF',   
'SEQ_CLRRPF',   
'SEQ_GMHDPF',   
'SEQ_GMHIPF',   
'SEQ_ZCLEPF',   
'SEQ_ZUCLPF',   
'SEQ_BILLNO',   
'SEQ_GBIHPF',   
'SEQ_GPMDPF',   
'SEQ_GBIDPF',   
'SEQ_ZDOEPF', 
'SEQ_LETCPF'  

);

ALTER SEQUENCE SEQ_CHDRPF		 cache 1000;
ALTER SEQUENCE SEQ_GCHIPF       cache 1000;
ALTER SEQUENCE SEQ_GCHPPF       cache 1000;
ALTER SEQUENCE SEQ_CLRRPF       cache 1000;
ALTER SEQUENCE SEQANUMPF        cache 1000;
ALTER SEQUENCE SEQ_CLEXPF       cache 1000;
ALTER SEQUENCE SEQ_CLNTPF       cache 1000;
ALTER SEQUENCE SEQ_CLNTPF       cache 1000;
ALTER SEQUENCE SEQ_VERSIONPF    cache 1000;
ALTER SEQUENCE SEQ_ZCSLPF       cache 1000;
ALTER SEQUENCE SEQ_CLBAPF       cache 1000;
ALTER SEQUENCE SEQ_ZMCIPF       cache 1000;
ALTER SEQUENCE SEQ_GXHIPF       cache 1000;
ALTER SEQUENCE SEQ_CLRRPF       cache 1000;
ALTER SEQUENCE SEQ_GMHDPF       cache 1000;
ALTER SEQUENCE SEQ_GMHIPF       cache 1000;
ALTER SEQUENCE SEQ_ZCLEPF       cache 1000;
ALTER SEQUENCE SEQ_ZUCLPF       cache 1000;
ALTER SEQUENCE SEQ_BILLNO       cache 1000;
ALTER SEQUENCE SEQ_GBIHPF       cache 1000;
ALTER SEQUENCE SEQ_GPMDPF       cache 1000;
ALTER SEQUENCE SEQ_GBIDPF       cache 1000;
ALTER SEQUENCE SEQ_ZDOEPF       cache 1000;
ALTER SEQUENCE SEQ_LETCPF		cache 1000;




-----===============================
--SQL LOADER and stage dbusr2 rollbakc
truncate table ZMRAT00;
truncate table ZMRCP00;
truncate table ZMREI00;
truncate table ZMRIC00;
truncate table ZMRISA00;
truncate table ZMRLH00;
truncate table ZMRMT00;
truncate table ZMRRC00;
truncate table ZMRRP00;
truncate table ZMRRPT00;
truncate table ZMRRR00;
truncate table ZMRRS00;
truncate table ZMRULA00;
truncate table ZMRIS00;
truncate table DMPR;
truncate table DECLINE_REASON_CODE;
truncate table KANA_ADDRESS_LIST;
truncate table COL_FEE_LST;
truncate table LETTER_CODE;
truncate table SOLICITATION_FLG_LIST;
truncate table DSH_CODE_REF;
truncate table ZMRAP00;
truncate table ALTER_REASON_CODE;
truncate table TITDMGSUMINSFACTOR;
truncate table SPPLANCONVERTION;
truncate table TITDMGCAMPCDE;
truncate table TITDMGINSSTPL;
truncate table TITDMGMASPOL;
truncate table TITDMGENDCTPF;
truncate table GRP_POLICY_FREE;
truncate table CARD_ENDORSER_LIST;
truncate table DMPR1;
truncate table BTDATE_PTDATE_LIST;
truncate table MSTPOLDB;
truncate table MSTPOLGRP;
truncate table TITDMGCLNTCORP;
truncate table TITDMGREF1;
truncate table TITDMGMBRINDP3;
truncate table PJ_TITDMGCOLRES;
truncate table TITDMGCOLRES;
truncate table TITDMGREF2;
truncate table TITDMGAGENTPJ;
truncate table MIPHSTDB;
truncate table TITDMGBILL1;
truncate table TITDMGBILL2;
truncate table persnl_clnt_flg;
truncate table trannotbl;

truncate table TRANNOTBL;
truncate table DM_POLICY_RECON;
truncate table POLICY_NOTIN_BILLING;
truncate table INVALID_CUTOFFPERIOD;
truncate table RENEW_AS_IS;
truncate table ASRF_RNW_DTRM;
truncate table TITDMGRNWDT1;
truncate table DPNTNO_TABLE_KEVIN;
truncate table TITDMGMBRINDP2_KEVIN;
truncate table TITDMGRNWDT2;
truncate table RND_COVERAGE_TABLE;
truncate table SOURCE_COVERAGE_RESULTS;
truncate table ASRF_RNW_INTERMEDIATE;
truncate table INVALID_ZPOSBDS;
truncate table PERSNL_CLNT_FLG;
truncate table TITDMGCLNTMAP;
truncate table SRCNAYOSETBL;
truncate table TITDMGCLTRNHIS_INT;
truncate table POLICY_STATCODE;
truncate table TMP_TITDMGSUMINSFACTOR;
truncate table TITDMGSUMINSFACTOR;
truncate table MEM_IND_POLHIST_SSPLAN_INTRMDT;
truncate table DPNTNO_TABLE;
truncate table TITDMGAPIRNO;
truncate table TITDMGAPIRNO_LOG;
truncate table GRP_POLICY_FREE;
truncate table KANA_ADDRESS_LIST;
truncate table LETTER_CODE;
truncate table MAXPOLNUM;
truncate table MEMPOL;
truncate table MEMPOL_VIEW1;
truncate table TITDMGMBRINDP1;
truncate table titdmgcltrnhis;
truncate table TITDMGCLNTBANK;
truncate table titdmgpoltrnh;
truncate table titdmgmbrindp2;
truncate table TITDMGLETTER;

select * from TITDMGMASPOL;
select * from TITDMGCAMPCDE;
select * from persnl_clnt_flg;
select * from POLICY_STATCODE;
select * from titdmgcltrnhis_int;
select * from srcnayosetbl;
select * from titdmgclntmap;
select * from titdmgcltrnhis;
select * from TITDMGCLNTBANK;
select * from MEM_IND_POLHIST_SSPLAN_INTRMDT;
select * from maxpolnum;
select * from mempol;
select * from titdmgmbrindp1;
select * from titdmgpoltrnh;
select * from dpntno_table;
select * from titdmgmbrindp2;
select * from titdmgapirno_log;
select * from titdmgapirno;
select * from titdmgbill1;
select * from titdmgbill2;
select * from TITDMGCOLRES;
select * from titdmgletter;
select * from trannotbl;

-----stagedbusr

truncate table BUSDPF;
truncate table ITEMPF;
truncate table TITDMGAGENTPJ;
truncate table TITDMGAPIRNO;
truncate table TITDMGBILL1;
truncate table TITDMGBILL2;
truncate table TITDMGCAMPCDE;
truncate table TITDMGCLNTBANK;
truncate table TITDMGCLNTCORP;
truncate table TITDMGCLNTPRSN;
truncate table TITDMGCLTRNHIS;
truncate table TITDMGCOLRES;
truncate table TITDMGENDCTPF;
truncate table TITDMGENDSPCFC;
truncate table TITDMGINSSTPL;
truncate table TITDMGLETTER;
truncate table TITDMGMASPOL;
truncate table TITDMGMBRINDP1;
truncate table TITDMGMBRINDP2;
truncate table TITDMGMBRINDP3;
truncate table TITDMGPOLTRNH;
truncate table TITDMGREF1;
truncate table TITDMGREF2;
truncate table TITDMGRNWDT1;
truncate table TITDMGRNWDT2;
truncate table TITDMGSALEPLN1;
truncate table TITDMGZCSLPF;
truncate table ZENDRPF;
truncate table ZESDPF;
truncate table ZSLPHPF;
truncate table ZSLPPF;

---DM Table in IG

select * from user_tables where table_name in ('PAZDCHPF',
'PAZDCLPF',
'PAZDCRPF',
'PAZDLTPF',
'ZDOEPF',
'PAZDRBPF',
'PAZDRFPF',
'PAZDROPF',
'PAZDRPPF',
'CONV_POL_HIST',
'MB01_POLHIST_RANGE',
'IG_TITDMGPOLTRNH',
'IG_DM_MASTERPOL',
'DMBARGSPF',
'DMBERPF',
'DMBMONPF',
'DMDEFVALPF',
'DMPRFXPF',
'DMPVALPF',
'DMIGTITDMGAGENTPJ',
'DMIGTITDMGCLTRNHIS',
'DMIGTITDMGCLNTBANK',
'DMIGTITDMGMBRINDP1',
'DMIGTITDMGBILL1',
'DMIGTITDMGBILL2',
'ZDMBKPZCLN',
'ZDMBKPCLNT',
'ZDMBKPAUDCLNT',
'ZDMBKPZTRA',
'ZDMBKPZINS',
'DMIGTITDMGCOLRES',
'DMIGTITDMGMASPOL',
'PAZDMPPF',
'DMIGTITDMGCLNTCORP',
'DMIGTITDMGLETTER',
'PAZDPDPF',
'DMIGTITDMGMBRINDP3',
'DMIGTITDMGREF1',
'DMIGTITDMGREF2',
'RECON_MASTER',
'PAZDPTPF',
'PAZDPCPF',
'PAZDRNPF',
'DM_TEMP_POLHIST',
'DMIGTITDMGPOLTRNH',
'DMIGTITDMGMBRINDP2',
'DMIGTITDMGAPIRNO',
'DM_DATA_VALIDATION_ATTRIB',
'DM_DV_RECON_SUMMARY',
'DM_DV_RECON_DETAIL',
'DM_BILLINST_RECON_DET',
'DM_MEM_IND_RECON_DET',
'DM_MASTER_POL_RECON_DET',
'DM_POL_DISHNR_RECON_DET',
'DM_POL_COLLRES_RECON_DET',
'DM_POL_MIHIS_RECON_DET',
'DM_POL_BILLREF_RECON_DET',
'ERROR_LOG',
'IGNAYOSEVIEW',
'DMPANAYOSEVIEW',
'PAZDNYPF',
'DMIGTITNYCLT',
'DMUNIQUENOUPDT',
'DM2_DMIG_DATA_CNT',
'DMIGTITDMGRNWDT1',
'DMIGTITDMGRNWDT2',
'PAZDRDPF',
'PAZDRCPF',
'DMIGTITDMGRNWDT1_INT',
'DMIGTITDMGRNWDT2_INT',
'ZDOERC_INT',
'ZDOERD_INT',
'RECON_MASTER_RD',
'DM_CLIENT_BANK_RECON_DET',
'DMIGODMVERSIONHIS',
'DM_POL_RNWL_DET_RECON_DET',
'DMIGTITDMGCAMPCDE',
'DMIGTITDMGZCSLPF',
'DM_TARGET_TABLES',
'DM_INDEX_SCRIPTS');

------------=========================================================================================
--Roll Back
--Corporate client
delete from DMIGTITDMGCLNTCORP ;

delete  from vm1dta.pazdclpf  where JOBNAME = 'G1ZDCOPCLT';
delete  from vm1dta.clntpf  where jobnm = 'G1ZDCOPCLT';
delete  from vm1dta.clexpf  where jobnm = 'G1ZDCOPCLT';


delete  from vm1dta.audit_clntpf  where oldjobnm = 'G1ZDCOPCLT';
delete  from vm1dta.audit_clnt where jobnm = 'G1ZDCOPCLT';
delete  from vm1dta.audit_clexpf where oldjobnm = 'G1ZDCOPCLT';
delete  from vm1dta.versionpf  where clntnum in (select clntnum from vm1dta.zclnpf  where jobnm = 'G1ZDCOPCLT');
delete  from vm1dta.zclnpf  where jobnm = 'G1ZDCOPCLT';

--Agency
delete from vm1dta.PAZdropf where jobname = 'G1ZDAGENCY';
delete from vm1dta.AGNTPF  where jobnm = 'G1ZDAGENCY';
delete from vm1dta.AGPLPF  where jobnm = 'G1ZDAGENCY';
delete from vm1dta.ZACRPF where jobnm = 'G1ZDAGENCY';
delete from vm1dta.CLRRPF where jobnm = 'G1ZDAGENCY';
delete from vm1dta.audit_clrrpf where newjobnm = 'G1ZDAGENCY';


--Master Policy
delete from vm1dta.DMIGTITDMGMASPOL;
delete from vm1dta.PAZDMPPF where jobname = 'G1ZDMSTPOL';
delete from vm1dta.gchd where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.gchipf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.gchppf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.zenctpf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.ztgmpf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.ztrapf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.clrrpf where jobnm = 'G1ZDMSTPOL';
delete from vm1dta.audit_clrrpf where newjobnm = 'G1ZDMSTPOL';
delete from vm1dta.ZGMPIRDTPF where jobnm = 'G1ZDMSTPOL';


---Camp code
delete from zcpnpf where jobnm='G1ZDCAMPCD';
delete from zcslpf where jobnm='G1ZDCAMPCD';
delete from pazdropf where PREFIX='CM';
commit;




--nyose
Delete from vm1dta.pazdnypf where   JOBNAME = 'G1ZDNAYCLT';

--Personal clnt
Delete from vm1dta.pazdclpf  where JOBNAME = 'G1ZDPERCLT';
Delete from vm1dta.clntpf  where jobnm = 'G1ZDPERCLT';
Delete from vm1dta.clexpf  where jobnm = 'G1ZDPERCLT';

--Client his
Delete from vm1dta.pazdchpf  where JOBNAME = 'G1ZDPCLHIS';
Delete from vm1dta.audit_clntpf  where oldjobnm = 'G1ZDPCLHIS';
Delete from vm1dta.audit_clnt where jobnm = 'G1ZDPCLHIS';
Delete from vm1dta.audit_clexpf where oldjobnm = 'G1ZDPCLHIS';
Delete from vm1dta.versionpf  where clntnum in (select clntnum from vm1dta.zclnpf  where jobnm = 'G1ZDPCLHIS');
Delete from vm1dta.zclnpf  where jobnm = 'G1ZDPCLHIS';


--Clinet bank
Delete from clbapf where jobnm='G1ZDCLTBNK';--80780  Rows
Delete from pazdclpf where JOBNAME='G1ZDCLTBNK';
Delete from clrrpf where jobnm='G1ZDCLTBNK';
Delete from audit_clrrpf where newjobnm='G1ZDCLTBNK';
commit;


--

--Member policy
delete  from vm1dta.PAZDRPPF where jobname='G1ZDMBRIND';
delete  from vm1dta.gchd  where jobnm='G1ZDMBRIND';
delete  from vm1dta.GCHPPF  where jobnm='G1ZDMBRIND';
delete  from vm1dta.GCHIPF  where jobnm='G1ZDMBRIND';
delete  from vm1dta.zclepf  where jobnm='G1ZDMBRIND';
delete  from vm1dta.zcelinkpf  where jobnm='G1ZDMBRIND';
delete  from vm1dta.clrrpf  where jobnm='G1ZDMBRIND';
delete  from vm1dta.audit_clrrpf   where newjobnm='G1ZDMBRIND';
delete  from vm1dta.gmhdpf where jobnm='G1ZDMBRIND';
delete  from vm1dta.gmhipf where jobnm='G1ZDMBRIND';
delete  from vm1dta.zcelinkpf where jobnm='G1ZDMBRIND';



--Letters
delete from vm1dta.pazdltpf where jobname = 'G1ZDLETR';
delete from vm1dta.letcpf where jobnm = 'G1ZDLETR';




--POLHIST
select * from vm1dta.PAZDPTPF where jobname = 'G1ZDPOLHST';
select * from vm1dta.ZTRAPF where jobnm = 'G1ZDPOLHST';
select * from vm1dta.ZALTPF where jobnm = 'G1ZDPOLHST';
select * from vm1dta.ZMCIPF where jobnm = 'G1ZDPOLHST';
select * from vm1dta.ZBENFDTLSPF where jobnm = 'G1ZDPOLHST';
select * from vm1dta.ZINSDTLSPF where jobnm = 'G1ZDPOLHST';

--POLCOV
select * from vm1dta.PAZDPCPF where JOBNAME = 'G1ZDPOLCOV';
select * from vm1dta.GXHIPF where jobnm = 'G1ZDPOLCOV';
select * from vm1dta.ZTEMPCOVPF where jobnm = 'G1ZDPOLCOV';
select * from vm1dta.ZSUBCOVDTLS where jobnm = 'G1ZDPOLCOV';
select * from vm1dta.ZODMPRMVERPF where jobnm = 'G1ZDPOLCOV';

--POLRISK
select * from vm1dta.PAZDRNPF where JOBNAME = 'G1ZDAPIRNO';
select * from vm1dta.ZAPIRNOPF where jobnm = 'G1ZDAPIRNO';

-----------------------------------------------------------------------
--delete
--POLHIST
delete from vm1dta.PAZDPTPF where jobname = 'G1ZDPOLHST';
delete from vm1dta.ZTRAPF where jobnm = 'G1ZDPOLHST';
delete from vm1dta.ZALTPF where jobnm = 'G1ZDPOLHST';
delete from vm1dta.ZMCIPF where jobnm = 'G1ZDPOLHST';
delete from vm1dta.ZBENFDTLSPF where jobnm = 'G1ZDPOLHST';
delete from vm1dta.ZINSDTLSPF where jobnm = 'G1ZDPOLHST';

--POLCOV
Delete from vm1dta.PAZDPCPF where JOBNAME = 'G1ZDPOLCOV';
Delete from vm1dta.GXHIPF where jobnm = 'G1ZDPOLCOV';
Delete from vm1dta.ZTEMPCOVPF where jobnm = 'G1ZDPOLCOV';
Delete from vm1dta.ZSUBCOVDTLS where jobnm = 'G1ZDPOLCOV';
Delete from vm1dta.ZODMPRMVERPF where jobnm = 'G1ZDPOLCOV';

--POLRISK
Delete  from vm1dta.PAZDRNPF where JOBNAME = 'G1ZDAPIRNO';
Delete from vm1dta.ZAPIRNOPF where jobnm = 'G1ZDAPIRNO';

--Bill His

Delete from GBIHPF where jobnm='G1ZDBILLIN' ;
Delete from GPMDPF where jobnm='G1ZDBILLIN' ;
Delete from GBIDPF where jobnm='G1ZDBILLIN' ;
Delete from PAZDRBPF where JOBNAME='G1ZDBILLIN' ;

---Billing Dishonor
delete from ZUCLPF where jobnm='G1ZDPOLDSH';
delete from  PAZDPDPF where jobname='G1ZDPOLDSH';		

--Billing Colres
delete from  VM1DTA.PAZDCRPF where JOBNAME='G1ZDCOLRES';
delete from  VM1DTA.ZCRHPF where jobnm='G1ZDCOLRES';
delete from   VM1DTA.ZUCLPF where jobnm='G1ZDCOLRES';


--Billing Refund

delete from  PAZDRFPF where JOBNAME='G1ZDBILLRF';
delete from   VM1DTA.GBIHPF  where jobnm='G1ZDBILLRF';
delete from   VM1DTA.ZRFDPF  where jobnm='G1ZDBILLRF';
delete from   ZREPPF  where jobnm='G1ZDBILLRF'; 
delete from   VM1DTA.GPMDPF  where jobnm='G1ZDBILLRF';
delete from   VM1DTA.GBIDPF  where jobnm='G1ZDBILLRF';
commit;

--LETTEr
delete from pazdltpf where jobname='G1ZDLETR';
delete from letcpf where jobnm='G1ZDLETR';



--Renewal determination



--========================================================================================================
--Column issue for ORA-00600
--http://blog.sydoracle.com/2010/05/ambiguity-resolved.html
--https://stackoverflow.com/questions/6516601/oracle-given-column-names
/*
ORA-00600: internal error code, arguments: [evaopn2.h:kaf_qeeCol], [CHDRCOY], [11], [1], [4], [0x700010006414A80], [2], [], [], [], [], []
00600. 00000 -  "internal error code, arguments: [%s], [%s], [%s], [%s], [%s], [%s], [%s], [%s], [%s], [%s], [%s], [%s]"
*Cause:    This is the generic internal error number for Oracle program
           exceptions. It indicates that a process has encountered a low-level,
           unexpected condition. The first argument is the internal message
           number. This argument and the database version number are critical in
           identifying the root cause and the potential impact to your system.
		   */
		   
select * from
(select *  FROM ZPDTPF ZPDT
      INNER JOIN ZTRAPF ZTRA
      ON ZTRA.CHDRCOY  = ZPDT.CHDRCOY
      AND ZTRA.CHDRNUM = ZPDT.CHDRNUM
      AND ZTRA.TRANNO  = ZPDT.TRANNO
      AND ZTRA.TRANNO  > 1
      --ZJNPG-6844 -START
      LEFT OUTER JOIN ZTGMPF ZTGM
      ON ZTRA.CHDRCOY = ZTGM.CHDRCOY
      AND ZTRA.CHDRNUM = ZTGM.CHDRNUM) ZTRA
      LEFT OUTER JOIN
	  (
        SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
        FROM
            ( SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM,
              ROW_NUMBER() OVER (PARTITION BY CHDRCOY,CHDRNUM,TRANNO,MBRNO,DPNTNO ORDER BY UNIQUE_NUMBER DESC) AS RN
              FROM
                ( SELECT UNIQUE_NUMBER,CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
                  FROM
                    ( SELECT DISTINCT ZINSDTLSPF.UNIQUE_NUMBER,ZTRAPF.CHDRCOY,ZTRAPF.CHDRNUM,
                      ZINSDTLSPF.MBRNO,ZINSDTLSPF.DPNTNO,ZTRAPF.TRANNO,ZINSDTLSPF.ZPLANCDE,
					  ZINSDTLSPF.EFFDATE,ZINSDTLSPF.DTETRM,ZINSDTLSPF.CLNTNUM
                      FROM ZTRAPF
                      INNER JOIN ZINSDTLSPF
                      ON  ZTRAPF.CHDRCOY = ZINSDTLSPF.CHDRCOY
                      AND ZTRAPF.CHDRNUM = ZINSDTLSPF.CHDRNUM
                    ) FULLMEMBER
                   WHERE NOT EXISTS
                   ( SELECT 1
                     FROM ZINSDTLSPF
                     WHERE FULLMEMBER.CHDRCOY = ZINSDTLSPF.CHDRCOY
                     AND FULLMEMBER.CHDRNUM = ZINSDTLSPF.CHDRNUM
                     AND FULLMEMBER.TRANNO  = ZINSDTLSPF.TRANNO
                     AND FULLMEMBER.MBRNO   = ZINSDTLSPF.MBRNO
                     AND FULLMEMBER.DPNTNO  = ZINSDTLSPF.DPNTNO
                    )
                 ) ALLFULL
               WHERE EXISTS
                ( SELECT 1
                  FROM ZINSDTLSPF
                  WHERE ALLFULL.CHDRCOY = ZINSDTLSPF.CHDRCOY
                  AND ALLFULL.CHDRNUM   = ZINSDTLSPF.CHDRNUM
                  AND ALLFULL.MBRNO     = ZINSDTLSPF.MBRNO
                  AND ALLFULL.DPNTNO    = ZINSDTLSPF.DPNTNO
                  AND ALLFULL.ZPLANCDE  = ZINSDTLSPF.ZPLANCDE
                  AND ALLFULL.EFFDATE   = ZINSDTLSPF.EFFDATE
				  AND ALLFULL.DTETRM    = ZINSDTLSPF.DTETRM
                  AND ALLFULL.TRANNO    > ZINSDTLSPF.TRANNO)
             ) TBLMEMBER
        WHERE RN= 1
        UNION
        SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
        FROM ZINSDTLSPF
      ) ZINSDTLS
          ON  ZINSDTLS.CHDRCOY = ZTRA.CHDRCOY
      AND ZINSDTLS.CHDRNUM = ZTRA.CHDRNUM
      AND ZINSDTLS.TRANNO  = ZTRA.TRANNO
	  AND ZINSDTLS.EFFDATE <= ZTRA.EFFDATE
      AND ZINSDTLS.DTETRM >= ZTRA.EFFDATE
	  
-----Error Query working in 12 C and but not working in 19 C

	  select *  FROM ZPDTPF ZPDT
      INNER JOIN ZTRAPF ZTRA
      ON ZTRA.CHDRCOY  = ZPDT.CHDRCOY
      AND ZTRA.CHDRNUM = ZPDT.CHDRNUM
      AND ZTRA.TRANNO  = ZPDT.TRANNO
      AND ZTRA.TRANNO  > 1
      --ZJNPG-6844 -START
      LEFT OUTER JOIN ZTGMPF ZTGM
      ON ZTRA.CHDRCOY = ZTGM.CHDRCOY
      AND ZTRA.CHDRNUM = ZTGM.CHDRNUM
      LEFT OUTER JOIN
	  (
        SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
        FROM
            ( SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM,
              ROW_NUMBER() OVER (PARTITION BY CHDRCOY,CHDRNUM,TRANNO,MBRNO,DPNTNO ORDER BY UNIQUE_NUMBER DESC) AS RN
              FROM
                ( SELECT UNIQUE_NUMBER,CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
                  FROM
                    ( SELECT DISTINCT ZINSDTLSPF.UNIQUE_NUMBER,ZTRAPF.CHDRCOY,ZTRAPF.CHDRNUM,
                      ZINSDTLSPF.MBRNO,ZINSDTLSPF.DPNTNO,ZTRAPF.TRANNO,ZINSDTLSPF.ZPLANCDE,
					  ZINSDTLSPF.EFFDATE,ZINSDTLSPF.DTETRM,ZINSDTLSPF.CLNTNUM
                      FROM ZTRAPF
                      INNER JOIN ZINSDTLSPF
                      ON  ZTRAPF.CHDRCOY = ZINSDTLSPF.CHDRCOY
                      AND ZTRAPF.CHDRNUM = ZINSDTLSPF.CHDRNUM
                    ) FULLMEMBER
                   WHERE NOT EXISTS
                   ( SELECT 1
                     FROM ZINSDTLSPF
                     WHERE FULLMEMBER.CHDRCOY = ZINSDTLSPF.CHDRCOY
                     AND FULLMEMBER.CHDRNUM = ZINSDTLSPF.CHDRNUM
                     AND FULLMEMBER.TRANNO  = ZINSDTLSPF.TRANNO
                     AND FULLMEMBER.MBRNO   = ZINSDTLSPF.MBRNO
                     AND FULLMEMBER.DPNTNO  = ZINSDTLSPF.DPNTNO
                    )
                 ) ALLFULL
               WHERE EXISTS
                ( SELECT 1
                  FROM ZINSDTLSPF
                  WHERE ALLFULL.CHDRCOY = ZINSDTLSPF.CHDRCOY
                  AND ALLFULL.CHDRNUM   = ZINSDTLSPF.CHDRNUM
                  AND ALLFULL.MBRNO     = ZINSDTLSPF.MBRNO
                  AND ALLFULL.DPNTNO    = ZINSDTLSPF.DPNTNO
                  AND ALLFULL.ZPLANCDE  = ZINSDTLSPF.ZPLANCDE
                  AND ALLFULL.EFFDATE   = ZINSDTLSPF.EFFDATE
				  AND ALLFULL.DTETRM    = ZINSDTLSPF.DTETRM
                  AND ALLFULL.TRANNO    > ZINSDTLSPF.TRANNO)
             ) TBLMEMBER
        WHERE RN= 1
        UNION
        SELECT CHDRCOY,CHDRNUM,MBRNO,DPNTNO,TRANNO,ZPLANCDE,EFFDATE,DTETRM,CLNTNUM
        FROM ZINSDTLSPF
      ) ZINSDTLS
          ON  ZINSDTLS.CHDRCOY = ZTRA.CHDRCOY
      AND ZINSDTLS.CHDRNUM = ZTRA.CHDRNUM
      AND ZINSDTLS.TRANNO  = ZTRA.TRANNO
	  AND ZINSDTLS.EFFDATE <= ZTRA.EFFDATE
      AND ZINSDTLS.DTETRM >= ZTRA.EFFDATE;
--========================================================================================================

--ROUND2 
--1. The tables in which we will do the heavy write (in stagedbusr2 or in stagebdusr) make those tables as nologging and initrans be change to 5.  :  Done
--2. Index script drop and creation  : Done
--3. sperate post validation from execution script : Done
--3.1 Passing batch name and Pre dm should execute for each module:done
--4. Check enable triggers to disable and do the code
/*
TR_GCHIPF:
 select SEQ_GCHIPF.nextval into v_pkValue from dual;
     :New.unique_number := v_pkValue;

TR_CLNTPF:
select SEQ_CLNTPF.nextval into v_pkValue from dual;
     :New.unique_number := v_pkValue;

TR_ZCSLPF:
select SEQ_ZCSLPF.nextval into v_pkValue from dual;
     :New.unique_number := v_pkValue;

	 
TR_VERSIONPF:
SELECT SEQ_VERSIONPF.nextval INTO v_pkValue FROM dual;
  :New.unique_number := v_pkValue;

VM1DTA_AUDIT_CLRRPF:
SELECT SEQ_CLRRPF.nextval INTO v_pkValue FROM dual;
    :New.unique_number := v_pkValue;
 :NEW.OLDCLNTNUM :=:NEW.NEWCLNTNUM;

 
TR_ZCLEPF:

select SEQ_ZCLEPF.nextval into v_pkValue from dual;
     :New.unique_number := v_pkValue;

	 
*/
--5. Camp code should be in parallel
--6. Pol his stg to ig chanes that
--MLOG$_ZMCIPF
--SELECT NVL(MAX(SEQNUMB),0) FROM VM1DTA.ZBENFDTLSPF WHERE TRIM(CHDRNUM) = TRIM(:B2 ) AND TRIM(MBRNO) = TRIM(:B1 )
--(NO Chnages) SELECT DISTINCT ZCRDTYPE FROM ZENCTPF WHERE TRIM(ZPOLNMBR) = TRIM(:B2 ) AND ((TRIM(ZCNBRFRM) < TRIM(:B1 ) AND TRIM(ZCNBRTO) > TRIM(:B1 )) OR TRIM(ZCNBRFRM) = TRIM(:B1 ) AND TRIM(ZCNBRTO) = TRIM(:B1 )) AND ZCARDDC = LENGTH(:B1 )
--7. Client bank code needs to be check
--8. Campcode , biling his. refund check if we are not inserting error for second table will performance improve? : No change
--9. Polhis check if commit will remove performance will improve : No change
--10. Remove dual from all procedure and put direct seq

----Experiemnet:

--1. Code change benef and no logging and init trans  Time 10/03/2021 17:19 ,   N--> 17:56  :: Time 79 SEC 
--2. Remove commit     N-->18:03  :: Time  76 sec
--3. arraysize = 9000    N->18:10   :: Time 82 Sec
--4. arraysize = 5000    N->18:14   :: Time 79 Sec
--5. arraysize = 1000    N->18:18      :: Time 82 Sec
--6. chunk_size =4146  means 60 chunks   N-->    :: Time 93 SEC
--7. With out index arraysize = 2000 , chunk is 30 N-->18:42   :: Time:70 SEC
--8. With index arraysize = 2000 , chunk is 30 N-->18:46   :: Time:79 SEC

---Conclusion for single stag module : keep Chunk as equal to CPU counts and Array size = 1K to 5 K and without index

----Billing
--1. arraysize = 1000 , chunk size = 3159 means 60    Y->11/03/2021 19:01  :: Time 160 SEC  with 'Y'
--2. arraysize = 1000 , chunk size = 3159 means 60    N->10:11  :: Time 223 SEC
--3. arraysize = 5000 , chunk size = 3159 means 60    N->15:55  :: Time 220 SEC 
--4. arraysize = 1000 , chunk size = 3159 means 60    N->16:06  :: Time 184 SEC  :: Without index
--5. arraysize = 1000 , chunk size = 3159 means 60    N->  :: Time 180.56 SEC  :: Without index  ::  cache 1000
--6. arraysize = 1000 , chunk size = 3159 means 60    N-> 17:13 :: Time 184 SEC  :: Without index  ::  cache 20000  :: Without Dual in seq
--7. arraysize = 1000 , chunk size = 3159 means 60    N-> 17:30 :: Time 184  SEC  :: Without index  ::  cache 50000  :: Without Dual in seq


--8. arraysize = 1000 , chunk size = 6317 means 30    N->15:32  :: Time  231.86 SEC
--9. arraysize = 5000 , chunk size = 6317 means 30    N->15:45  :: Time 232 SEC
--10. arraysize = 1000 , chunk size = 6317 means 30    N->16:12  :: Time 201 SEC  :: Without index

--Conclusion : for Billing array zise 1000, chunk sie equal to CPU counts ,and without index and Seq cache zise 1K


--Clinent bank
--1. arraysize = 1000 , chunk size = 2693 means 30    N->11/03/2021 18:28  :: Time 21 SEC
--2. arraysize = 1000 , chunk size = 2693 means 30    N->  :: Time 21.49 SEC  :: Wihtout index

--Coverage 
--1. arraysize = 1000 , chunk size = 30377 means 30    N->11/03/2021   :: Time 168.28 SEC  :: Witout index
--2. arraysize = 5000 , chunk size = 30377 means 30    N->11/03/2021   :: Time 159.56 SEC  :: Witout index 
--3. arraysize = 30377 , chunk size = 30377 means 30    N->11/03/2021   :: Time 156.7 SEC  :: Witout index 
--4. arraysize = 5000 , chunk size = 30377 means 30    N->11/03/2021   :: Time 157.25 SEC  :: Witout index 

--Conclusion : for More records like coverage we can extend Array size by 5K it will give good performance

---Round2 EXP
--1. Master Policy:
--With Index

--2. Camp code:

--3. Personal client
--With index
--Y => 28.8
--N => 63.43
--Post val =>37.231

--WITHOUT INDEX
--DROP Index  :: 18
--Y =>
--N => 49.11
--Post val =>36.11

--4. Clint his
--With index
--Y => 31
--N => 45
--Post val =>37

--WITHOUT INDEX
--DROP Index  :: 
--Y =>
--N => 
--Post val =>

--5. Clinet Bank
--With index
--Y => 12.56
--N => 15.4
--Post val =>

--WITHOUT INDEX
--DROP Index  :: 
--Y =>
--N => 
--Post val =>

--6. Member policy

--With index
--Y => 52.71
--N => 109.49
--Post val =>51

--WITHOUT INDEX
--DROP Index  :: 
--Y =>
--N => 
--Post val =>







--Current running notes


