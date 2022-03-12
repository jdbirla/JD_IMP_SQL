--------------------------------------------------------------------
-- File Name	: stg2_JobCode_Patching.sql
-- Description	: 'This is for patching Client Job code'.
-- Date			: 17 Dec 2021
-- Author		: Mark Kevin Sarmiento
--------------------------------------------------------------------
insert into STAGEDBUSR2.DMPACLJOBCDE ( APCUCD,
REFNUM,
STAGECLNTNO,
EFFDATE,
OCCPCODE,
ZOCCDSC,
ZWORKPLCE,
ZENDCDE,
CLNTROLEFLG,
POLICYSTATUS,
POLICYTYPE,
PRIORTY,
ZINSTYP,
DATIME
)
select APCUCD,
REFNUM,
STAGECLNTNO,
EFFDATE,
OCCPCODE,
ZOCCDSC,
ZWORKPLCE,
ZENDCDE,
CLNTROLEFLG,
POLICYSTATUS,
POLICYTYPE,
PRIO,
zinstype,
cast(sysdate as timestamp)
from (
    select distinct pr.*,
    row_number() over(partition by pr.stageclntno order by  pr.zinstype_prio, pr.polstat_prio,  pr.effdate desc) as prio
    from (
        select  distinct tt.refnum, tt.apcucd, mp.stageclntno, p2.zinstype,
        case when p2.zinstype = 'PO' or p2.zinstype = 'PFA' then 1
             else 2 
        end as zinstype_prio,
        tt.policystatus,
        case when tt.policystatus = 'IF' OR tt.policystatus = 'XN' then 1
             else 2 
        end as polstat_prio,
        tt.policytype, tt.effdate, tt.occpcode, tt.zworkplce, tt.zoccdsc, tt.zendcde, tt.clntroleflg
        from (select * from titdmgcltrnhis_int where TRANSHIST = 1) tt
        left join titdmgclntmap mp on mp.refnum = tt.refnum
        left join (select DISTINCT refnum, zinstype from titdmgmbrindp2) p2 on p2.refnum = substr(tt.refnum,1,8)
    )pr
) where prio = 1
order by stageclntno;

commit;