--------------------------------------------------------------------
-- File Name	: 01_Update_DML_P2-11367_ORACLE_STAGEDBUSR2_Update_Data.sql
-- Description	: 'This is to alteration transacstions having apcvcd greater thant the NB/RN transactions on P2-11367'.
-- Date			: 28 Jul 2021
-- Author		: Mark Kevin Sarmiento
--------------------------------------------------------------------

merge into zmrap00 fn 
    using (
    select
    case 
        when substr(a.zseqno,1,2) = '00' then 
            'NB' 
        else 
            'RN' 
        end as Period_Type, a.*,
        (select apcvcd from zmrap00 b where substr(a.apcucd,1,10) || '0' = b.apcucd) correct_apcvcd
    from (
        select apcucd,substr(apcucd,1,8) chdrnum, substr(apcucd,9,3) zseqno,apa2dt, apcvcd,
        row_number() over(partition by  substr(apcucd,1,8) order by apcucd) zseq_order,
        row_number() over(partition by  substr(apcucd,1,8) order by apcvcd,apcucd) apcvcd_order from zmrap00 
    ) a
              where a.zseq_order <> a.apcvcd_order
              and a.apcvcd_order = 1
    --and zseqno = '000'
    order by a.apcucd
) od 
ON (fn.apcucd = od.apcucd)
when matched then
update set fn.apcvcd = od.correct_apcvcd;

commit;