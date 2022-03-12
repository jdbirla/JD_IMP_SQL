--Insert Script for jobcode 
insert into Jd1dta.DMPACLJOBPRTY(
CHDRNUM,
STAGECLNTNO,
ZIGVALUE,
EFFDATE,
OCCPCODE,
ZOCCDSC,
OCCPCLAS,
ZWORKPLCE,
ZENDCDE,
POLICYSTATUS,
POLICYTYPE,
PRIORTY,
ZINSTYP,
VALIDFLG,
DATIME
)
select CHDRNUM,
STAGECLNTNO,
ZIGVALUE,
EFFDATE,
OCCPCODE,
ZOCCDSC,
OCCPCLAS,
ZWORKPLCE,
ZENDCDE,
POLICYSTATUS,
POLICYTYPE,
PRIO,
ZINSTYP,
VALIDFLG,
cast(sysdate as timestamp)
from (
    select distinct tb1.*,
    row_number() over(partition by zigvalue order by zinstype_prio, typstat_prio, effdate desc) prio
    from (
        select pc.zigvalue, itm.occpclas, substr(pc.zentity,1,8) chdrnum,
        case when st.zinstyp = 'PO' or st.zinstyp = 'PFA' then 1
            else 2 
        end as zinstype_prio,
        case when st.policytype = 'PP' and (st.policystatus = 'IF' or st.policystatus = 'XN') then 1
             when st.policytype = 'FP' and (st.policystatus = 'IF' or st.policystatus = 'XN') then 2
             when st.policytype = 'PP' and (st.policystatus = 'CA' or st.policystatus = 'LA') then 3
             when st.policytype = 'FP' and (st.policystatus = 'CA' or st.policystatus = 'LA') then 4
        end typstat_prio,
		case
			when nvl(rtrim(cl.occpcode),'0') <>  nvl(rtrim(st.occpcode) ,'0') then 'Y'
			when nvl(rtrim(cl.zoccdsc),'0') <>   nvl(rtrim(st.zoccdsc)  ,'0') then 'Y'
			when nvl(rtrim(cl.zworkplce),'0') <> nvl(rtrim(st.zworkplce),'0') then 'Y'
			else 'N'
			end validflg,
        st.*
        from stagedbusr2.DMPACLJOBCDE@DMSTGUSR2DBLINK st
        left join pazdnypf pc on trim(pc.zentity) = st.stageclntno
        left join clntpf cl on pc.zigvalue = cl.clntnum
        left join (select trim(itemitem) occpcode, trim(substr(utl_raw.cast_to_varchar2(genarea),501,2)) occpclas from itempf where trim(itemtabl) = 'T3644' and trim(itemcoy) = '9' and trim(itempfx) = 'IT' and trim(validflag) = '1'
                       ) itm ON itm.occpcode = st.occpcode 
    ) tb1
) where prio = 1 ;
---------------------------------------------------------
commit;



--Update clntpf  
merge into clntpf fn
using 
    (select * from dmpacljobprty where validflg = 'Y')
od on ( fn.clntnum = od.zigvalue)
when matched then
update set fn.occpcode = od.occpcode,
fn.occpclas = od.occpclas,
fn.zoccdsc = od.zoccdsc,
fn.zworkplce = od.zworkplce;

commit;


--Disable triggers

--Update audit_clntpf

--TRANNO <> 1
UPDATE audit_clntpf q
SET
    ( q.oldoccpcode,
      q.oldoccpclas,
      q.newoccpcode,
      q.newoccpclas ) = (
        SELECT
            c.occpcode,
            c.occpclas,
            c.occpcode,
            c.occpclas
        FROM
            dmpacljobprty c
        WHERE
                c.validflg = 'Y'
            AND c.zigvalue = q.oldclntnum
    )
WHERE
    EXISTS (
        SELECT
            1
        FROM
            dmpacljobprty c
        WHERE
                c.validflg = 'Y'
            AND c.zigvalue = q.oldclntnum
    )
    AND q.tranno <> 1;
    Commit;
--TRANNO = 1
UPDATE audit_clntpf q
SET
    ( q.newoccpcode,
      q.newoccpclas ) = (
        SELECT
            c.occpcode,
            c.occpclas
        FROM
            dmpacljobprty c
        WHERE
                c.validflg = 'Y'
            AND c.zigvalue = q.oldclntnum
    )
WHERE
    EXISTS (
        SELECT
            1
        FROM
            dmpacljobprty c
        WHERE
                c.validflg = 'Y'
            AND c.zigvalue = q.oldclntnum
    )
    AND q.tranno = 1;
 
Commit;

--Update zclnpf
merge into zclnpf fn
using 
(select * from dmpacljobprty where validflg = 'Y')
od on ( fn.clntnum = od.zigvalue)
when matched then
update set fn.occpcode = od.occpcode,
fn.occpclas = od.occpclas,
fn.zoccdsc = od.zoccdsc,
fn.zworkplce = od.zworkplce;
Commit;

--Update zinsdtlspf
MERGE INTO zinsdtlspf fn
USING (
          SELECT
              c.occpcode occpcode_1,
              c.zworkplce,
              z.*
          FROM
                   zinsdtlspf z
              INNER JOIN dmpacljobprty c ON z.clntnum = c.zigvalue
          WHERE
              EXISTS (
                  SELECT
                      1
                  FROM
                      pazdptpf r
                  WHERE
                      r.zentity = z.chdrnum
              )
              AND c.validflg = 'Y'
      )
od ON ( fn.chdrnum = od.chdrnum
        AND fn.tranno = od.tranno
        AND fn.mbrno = od.mbrno
        AND fn.dpntno = od.dpntno )
WHEN MATCHED THEN UPDATE
SET fn.occpcode = od.occpcode_1,
    fn.zworkplce2 = od.zworkplce;
Commit;
	
-------Update zaltpf
MERGE INTO zaltpf fn
USING (
          SELECT
              c.zworkplce,
              z.*
          FROM
                   zaltpf z
              INNER JOIN dmpacljobprty c ON z.cownnum = c.zigvalue
          WHERE
              EXISTS (
                  SELECT
                      1
                  FROM
                      pazdptpf r
                  WHERE
                      r.zentity = z.chdrnum
              )
              AND c.validflg = 'Y'
      )
od ON ( fn.unique_number = od.unique_number
        AND fn.chdrnum = od.chdrnum
        AND fn.tranno = od.tranno )
WHEN MATCHED THEN UPDATE
SET fn.zworkplce1 = od.zworkplce;


--Enable triggers

commit;
