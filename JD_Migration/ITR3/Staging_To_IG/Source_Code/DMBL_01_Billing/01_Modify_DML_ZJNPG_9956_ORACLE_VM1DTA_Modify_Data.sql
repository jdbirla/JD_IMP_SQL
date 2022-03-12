--------------------------------------------------------------------
-- File Name	: 01_Modify_DML_ZJNPG_9956_ORACLE_VM1DTA_Modify_Data.sql.sql
-- Description	: 'This is to handle bills which are required for rebilling. (P2-17390).
--					STEPS FOR EXECUTION:
--						1. Execute select statement and validate if policys are for rebilling and and Migration Business date is between ACD and Bank Transfer date.
--						2. Once step 1 is validated, execute UPDATE and INSERT script to fix the issue.
-- Date			: 28 Aug 2021
-- Author		: Mark Kevin Sarmiento
--------------------------------------------------------------------

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--1. Select Statement for Extracting Policy/bills which requires rebilling:
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
WITH gb_data AS (       
    select i.chdrnum,p.zendcde , max(i.PRBILTDT) PRBILTDT
        from Jd1dta.gbihpf i , Jd1dta.gchppf p, Jd1dta.pazdcrpf rg
        where i.chdrnum=p.chdrnum
            and i.premout='Y'
            and p.ZCOLMCLS='F'
            AND P.ZPRDCTG='PA'
            AND P.ZPLANCLS='PP'
            and substr(rg.zentity,1,8) = i.chdrnum
            and not exists (select 1 from                                             -- Exclude policy having combine billing on the latest bill
                                    (
                                    select chdrnum, count(1) from Jd1dta.zcrhpf cl 
                                    where exists (
                                                select 1 from 
                                                (
                                                    select chdrnum, max(tfrdate) tfrdate from Jd1dta.zcrhpf i
                                                    where exists 
                                                            (
                                                            select 1 from Jd1dta.pazdcrpf reg where substr(reg.zentity,1,8) = i.chdrnum
                                                            )
                                                    group by chdrnum
                                                ) a 
                                                where a.chdrnum = cl.chdrnum and a.tfrdate = cl.tfrdate
                                                )
                                    group by chdrnum having count(1) >1
                                    ) cb 
                           where cb.chdrnum = i.chdrnum
                           )
            group by i.chdrnum,p.zendcde
)
SELECT gb.zendcde, gb.chdrnum, gb.prbiltdt, bil.billno, bil.zacmcldt, bil.zposbdsm ,bil.zposbdsy, 
    to_number(to_char(TO_DATE(gb.prbiltdt,'YYYYMMDD')+1,'YYYYMMDD')) gb_efdate, 
    zt.efdate, ze.zendscid, zs.zacmcldt nxt_zacmcldt, zs.zposbdsm nxt_zposbdsm, zs.zposbdsy nxt_zposbdsy, zs.zbildddt, zs.zbktrfdt
FROM gb_data gb
 LEFT JOIN Jd1dta.ztrapf zt ON zt.chdrnum = gb.chdrnum 
 LEFT JOIN Jd1dta.gbihpf bil ON bil.chdrnum = gb.chdrnum AND bil.prbiltdt = gb.prbiltdt
 LEFT JOIN Jd1dta.zendrpf ze ON gb.zendcde = ze.zendcde
 --left join Jd1dta.busdpf bs on bs.company = 1
 --Query to pick-up the next ACD of the bill
 LEFT JOIN (select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt from (
                select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt,
                    rank() over(partition by zendscid order by zacmcldt desc) rnk  
                from Jd1dta.zesdpf where  zacmcldt < (select busdate from Jd1dta.busdpf where company = 1) --DM business date
                ) where rnk = 1
            ) zs ON zs.zendscid = ze.zendscid AND zs.zacmcldt <> bil.zacmcldt 
WHERE zt.chdrnum=gb.chdrnum
    AND to_number(to_char(TO_DATE(gb.prbiltdt,'YYYYMMDD')+1,'YYYYMMDD'))=zt.efdate
    AND RTRIM(zt.zrcaltty)='TERM'
    and zs.zacmcldt < (select busdate from Jd1dta.busdpf where company = 1)  --DM business date
    and zs.zbktrfdt >= (select busdate from Jd1dta.busdpf where company = 1) --DM business date
ORDER BY 1,2;


/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--2. Update script for GBIHPF
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
merge into Jd1dta.gbihpf od
USING (
WITH gb_data AS (       
    select i.chdrnum,p.zendcde , max(i.PRBILTDT) PRBILTDT
        from Jd1dta.gbihpf i , Jd1dta.gchppf p, Jd1dta.pazdcrpf rg
        where i.chdrnum=p.chdrnum
            and i.premout='Y'
            and p.ZCOLMCLS='F'
            AND P.ZPRDCTG='PA'
            AND P.ZPLANCLS='PP'
            and substr(rg.zentity,1,8) = i.chdrnum
            and not exists (select 1 from                                             -- Exclude policy having combine billing on the latest bill
                                    (
                                    select chdrnum, count(1) from Jd1dta.zcrhpf cl 
                                    where exists (
                                                select 1 from 
                                                (
                                                    select chdrnum, max(tfrdate) tfrdate from Jd1dta.zcrhpf i
                                                    where exists 
                                                            (
                                                            select 1 from Jd1dta.pazdcrpf reg where substr(reg.zentity,1,8) = i.chdrnum
                                                            )
                                                    group by chdrnum
                                                ) a 
                                                where a.chdrnum = cl.chdrnum and a.tfrdate = cl.tfrdate
                                                )
                                    group by chdrnum having count(1) >1
                                    ) cb 
                           where cb.chdrnum = i.chdrnum
                           )
            group by i.chdrnum,p.zendcde
)
SELECT bil.unique_number, gb.zendcde, gb.chdrnum, gb.prbiltdt, bil.billno, bil.zacmcldt, bil.zposbdsm ,bil.zposbdsy, 
    to_number(to_char(TO_DATE(gb.prbiltdt,'YYYYMMDD')+1,'YYYYMMDD')) gb_efdate, 
    zt.efdate, ze.zendscid, zs.zacmcldt nxt_zacmcldt, zs.zposbdsm nxt_zposbdsm, zs.zposbdsy nxt_zposbdsy, zs.zbildddt, zs.zbktrfdt
FROM gb_data gb
 LEFT JOIN Jd1dta.ztrapf zt ON zt.chdrnum = gb.chdrnum 
 LEFT JOIN Jd1dta.gbihpf bil ON bil.chdrnum = gb.chdrnum AND bil.prbiltdt = gb.prbiltdt
 LEFT JOIN Jd1dta.zendrpf ze ON gb.zendcde = ze.zendcde
 --left join Jd1dta.busdpf bs on bs.company = 1
 LEFT JOIN (select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt from (
                select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt,
                    rank() over(partition by zendscid order by zacmcldt desc) rnk  
                from Jd1dta.zesdpf where  zacmcldt < (select busdate from Jd1dta.busdpf where company = 1) --DM business date
                ) where rnk = 1
            ) zs ON zs.zendscid = ze.zendscid AND zs.zacmcldt <> bil.zacmcldt 
WHERE zt.chdrnum=gb.chdrnum
    AND to_number(to_char(TO_DATE(gb.prbiltdt,'YYYYMMDD')+1,'YYYYMMDD'))=zt.efdate
    AND RTRIM(zt.zrcaltty)='TERM'
    and zs.zacmcldt < (select busdate from Jd1dta.busdpf where company = 1)  --DM business date
    and zs.zbktrfdt >= (select busdate from Jd1dta.busdpf where company = 1) --DM business date
) fn 
ON (od.unique_number=od.unique_number and od.chdrnum=fn.chdrnum and od.billno=fn.billno)
WHEN MATCHED THEN
UPDATE SET od.zbktrfdt = fn.zbktrfdt, 
           od.zposbdsm = nxt_zposbdsm, 
           od.zposbdsy = fn.nxt_zposbdsy,
           od.zcolflag = ' ';

commit;
		   
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--3. Insert Script for ZCRHPF
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
INSERT /*+ APPEND*/ INTO Jd1dta.zcrhpf (CHDRCOY, CHDRPFX, CHDRNUM, BILLNO, TFRDATE, DSHCDE, USRPRF, JOBNM, DATIME, LNBILLNO) 
WITH gb_data AS (       
    select i.chdrnum,p.zendcde , max(i.PRBILTDT) PRBILTDT
        from Jd1dta.gbihpf i , Jd1dta.gchppf p, Jd1dta.pazdcrpf rg
        where i.chdrnum=p.chdrnum
            and i.premout='Y'
            and p.ZCOLMCLS='F'
            AND P.ZPRDCTG='PA'
            AND P.ZPLANCLS='PP'
            and substr(rg.zentity,1,8) = i.chdrnum
            and not exists (select 1 from                                             -- Exclude policy having combine billing on the latest bill
                                    (
                                    select chdrnum, count(1) from Jd1dta.zcrhpf cl 
                                    where exists (
                                                select 1 from 
                                                (
                                                    select chdrnum, max(tfrdate) tfrdate from Jd1dta.zcrhpf i
                                                    where exists 
                                                            (
                                                            select 1 from Jd1dta.pazdcrpf reg where substr(reg.zentity,1,8) = i.chdrnum
                                                            )
                                                    group by chdrnum
                                                ) a 
                                                where a.chdrnum = cl.chdrnum and a.tfrdate = cl.tfrdate
                                                )
                                    group by chdrnum having count(1) >1
                                    ) cb 
                           where cb.chdrnum = i.chdrnum
                           )
            group by i.chdrnum,p.zendcde
)
SELECT '1', 'CH', gb.chdrnum, bil.billno, zs.zbktrfdt, ' ', 'JBIRLA', 'G1ZDCOLRES', CAST(sysdate AS TIMESTAMP), bil.billno 
FROM gb_data gb
 LEFT JOIN Jd1dta.ztrapf zt ON zt.chdrnum = gb.chdrnum 
 LEFT JOIN Jd1dta.gbihpf bil ON bil.chdrnum = gb.chdrnum AND bil.prbiltdt = gb.prbiltdt
 LEFT JOIN Jd1dta.zendrpf ze ON gb.zendcde = ze.zendcde
 --left join Jd1dta.busdpf bs on bs.company = 1
 LEFT JOIN (select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt from (
                select zendscid, zacmcldt, zposbdsm, zposbdsy, zbildddt, zbktrfdt,
                    rank() over(partition by zendscid order by zacmcldt desc) rnk  
                from Jd1dta.zesdpf where  zacmcldt < (select busdate from Jd1dta.busdpf where company = 1) --DM business date
                ) where rnk = 1
            ) zs ON zs.zendscid = ze.zendscid AND zs.zacmcldt <> bil.zacmcldt 
WHERE zt.chdrnum=gb.chdrnum
    AND to_number(to_char(TO_DATE(gb.prbiltdt,'YYYYMMDD')+1,'YYYYMMDD'))=zt.efdate
    AND RTRIM(zt.zrcaltty)='TERM'
    and zs.zacmcldt < (select busdate from Jd1dta.busdpf where company = 1)  --DM business date
    and zs.zbktrfdt >= (select busdate from Jd1dta.busdpf where company = 1) --DM business date
ORDER BY 1,2;

commit;