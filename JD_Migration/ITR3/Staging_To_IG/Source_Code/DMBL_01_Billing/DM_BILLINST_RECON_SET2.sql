create or replace PROCEDURE Jd1dta.DM_BILLINST_RECON_SET2(p_detail_batch_id varchar2, p_summary_batch_id varchar2) IS

/***************************************************************************************************
  * Amendment History: BL01 Billing History
  * Date    Initials   Tag   Description
  * -----   --------   ---   ---------------------------------------------------------------------------
  * FEB03	   CHO          	 PA ITR3 Implementation for Reconciliation Set 2 task
  *****************************************************************************************************/

  obj_recon_master view_dm_billinst_recon_det%rowtype;
  
  C_MODULE_NAME constant dm_billinst_recon_det.v_module_name%type := 'Billing Instalment';
  C_EFF_DESC    constant dm_billinst_recon_det.v_eff_desc%type    := 'Policy Start Date';
  C_EFF_DESC2   constant dm_billinst_recon_det.v_eff_desc%type    := 'Bill From Date';
  C_CREATED_BY  constant dm_billinst_recon_det.v_created_by%type  := 'JPAXTU';
  C_JOB_NAME    constant dm_billinst_recon_det.v_job_name%type    := 'DM_BILLINST_RECON_SET2';

  v_attrib      dm_data_validation_attrib.v_attrib_name%type;

  p_exitcode    number;
  p_exittext    varchar2(2000);

  CURSOR c_valid_attrib(i_attrib_name varchar2) IS
  select *
    FROM Jd1dta.dm_data_validation_attrib
   where v_attrib_name = i_attrib_name
     and c_status_flg = 'Y';
	 
  CURSOR c_policy_bill_cnt IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            count(*) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            count(*) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            count(*) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.v_policy_no = c.v_policy_no
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policy_bill_cnt c_policy_bill_cnt%rowtype;

  CURSOR c_policy_prem_sum IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            nvl(sum(b.bprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            nvl(sum(b.bprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill2@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            nvl(sum(b.pprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gpmdpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.v_policy_no = c.v_policy_no
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policy_prem_sum c_policy_prem_sum%rowtype;

  CURSOR c_policy_prodtyp_cnt IS
    with data_1 as (
     select 'source' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
      union all
     select 'staging' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr.titdmgbill2@DMSTAGEDBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
      union all
     select 'IG' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    Jd1dta.gpmdpf b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum
                and b.billtyp = 'N')
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.v_policy_no = c.v_policy_no
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policy_prodtyp_cnt c_policy_prodtyp_cnt%rowtype;

  CURSOR c_policy_insured_cnt IS
    with data_1 as (
     select 'source' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
      union all
     select 'staging' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr.titdmgbill2@DMSTAGEDBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
      union all
     select 'IG' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    Jd1dta.gpmdpf b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum
                and b.billtyp = 'N')
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.v_policy_no = c.v_policy_no
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policy_insured_cnt c_policy_insured_cnt%rowtype;

  CURSOR c_policybill_prbiltdt IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde,
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.prbilfdt,
            b.prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.prbiltdt src_val,
         b.prbiltdt stg_val,
         c.prbiltdt ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.prbiltdt <> b.prbiltdt or b.prbiltdt <> c.prbiltdt)
   order by a.v_policy_no;	 

  obj_policybill_prbiltdt c_policybill_prbiltdt%rowtype;

  CURSOR c_policybill_instno IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde,
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            to_number(b.trrefnum) instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            to_number(b.trrefnum) instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.prbilfdt,
            b.instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.instno src_val,
         b.instno stg_val,
         c.instno ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.instno <> b.instno or b.instno <> c.instno)
   order by a.v_policy_no;	 

  obj_policybill_instno c_policybill_instno%rowtype;

  CURSOR c_policybill_nrflg IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde,
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.nrflag nrflg
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.nrflag nrflg
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.prbilfdt,
            b.nrflg
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.nrflg src_val,
         b.nrflg stg_val,
         c.nrflg ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.nrflg <> b.nrflg or b.nrflg <> c.nrflg)
   order by a.v_policy_no;	 

  obj_policybill_nrflg c_policybill_nrflg%rowtype;

  CURSOR c_policybill_zposbdsm IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde,
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.zposbdsm
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.zposbdsm
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.prbilfdt,
            b.zposbdsm
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.zposbdsm src_val,
         b.zposbdsm stg_val,
         c.zposbdsm ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.zposbdsm <> b.zposbdsm or b.zposbdsm <> c.zposbdsm)
   order by a.v_policy_no;	 

  obj_policybill_zposbdsm c_policybill_zposbdsm%rowtype;

  CURSOR c_policybill_zposbdsy IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde,
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.zposbdsy
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.prbilfdt,
            b.zposbdsy
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.prbilfdt,
            b.zposbdsy
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gbihpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.zposbdsy src_val,
         b.zposbdsy stg_val,
         c.zposbdsy ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.zposbdsy <> b.zposbdsy or b.zposbdsy <> c.zposbdsy)
   order by a.v_policy_no;	 

  obj_policybill_zposbdsy c_policybill_zposbdsy%rowtype;

  CURSOR c_policybill_prodtyp_cnt IS
    with data_1 as (
     select 'source' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'staging' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr.titdmgbill2@DMSTAGEDBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            count(*) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.pazdrbpf b,
            Jd1dta.gbidpf c
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.zigvalue = c.billno
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status, b.prbilfdt
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policybill_prodtyp_cnt c_policybill_prodtyp_cnt%rowtype;

  CURSOR c_policybill_prodtyp2_cnt IS
    with data_1 as (
     select 'source' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'staging' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr.titdmgbill2@DMSTAGEDBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'IG' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prmfrdt prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prmfrdt,
                    b.prodtyp
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    Jd1dta.gpmdpf b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum
                and b.billtyp = 'N')
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prmfrdt
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policybill_prodtyp2_cnt c_policybill_prodtyp2_cnt%rowtype;

  CURSOR c_policybill_insured_cnt IS
    with data_1 as (
     select 'source' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'staging' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prbilfdt,
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    stagedbusr.titdmgbill2@DMSTAGEDBLINK b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum)
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prbilfdt
      union all
     select 'IG' data_from,
            v_policy_no,
            v_prd_cde, 
            d_pol_start_dt, 
            v_pol_status, 
            prmfrdt prbilfdt,
            count(*) v_Count
       from (
             select distinct
                    a.v_policy_no,
                    a.v_prd_cde, 
                    a.d_pol_start_dt, 
                    a.v_pol_status, 
                    b.prmfrdt,
                    b.mbrno || b.dpntno
               from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
                    Jd1dta.gpmdpf b
              where a.v_pol_type = 'IND_MEMBER'
                and a.v_policy_no = b.chdrnum
                and b.billtyp = 'N')
      group by v_policy_no, v_prd_cde, d_pol_start_dt, v_pol_status, prmfrdt
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policybill_insured_cnt c_policybill_insured_cnt%rowtype;

  CURSOR c_policybill_effdate IS
    with data_1 as (
     select distinct
            'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            b.prbilfdt effdate
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select distinct
            'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            b.prbilfdt effdate
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill2@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select distinct
            'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prmfrdt prbilfdt,
            b.effdate
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gpmdpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.effdate src_val,
         b.effdate stg_val,
         c.effdate ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.effdate <> b.effdate or b.effdate <> c.effdate)
   order by a.v_policy_no;	 

  obj_policybill_effdate c_policybill_effdate%rowtype;

  CURSOR c_policybill_prem_sum IS
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            nvl(sum(b.bprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status, b.prbilfdt
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            nvl(sum(b.bprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill2@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status, b.prbilfdt
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prmfrdt prbilfdt,
            nvl(sum(b.pprem), 0) v_Count
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gpmdpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
      group by a.v_policy_no, a.v_prd_cde, a.d_pol_start_dt, a.v_pol_status, b.prmfrdt
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.v_Count src_val,
         b.v_Count stg_val,
         c.v_Count ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.v_Count <> b.v_Count or b.v_Count <> c.v_Count)
   order by a.v_policy_no;	 

  obj_policybill_prem_sum c_policybill_prem_sum%rowtype;

  CURSOR c_policybill_instno2 IS
    with data_1 as (
     select distinct
            'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            to_number(b.trrefnum) instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select distinct
            'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            to_number(b.trrefnum) instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill2@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select distinct
            'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prmfrdt prbilfdt,
            b.instno
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gpmdpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.instno src_val,
         b.instno stg_val,
         c.instno ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.instno <> b.instno or b.instno <> c.instno)
   order by a.v_policy_no;	 

  obj_policybill_instno2 c_policybill_instno2%rowtype;

  CURSOR c_policybill_prbiltdt2 IS
    with data_1 as (
     select distinct
            'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            c.prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.titdmgbill2@DMSTGUSR2DBLINK b,
            stagedbusr2.titdmgbill1@DMSTGUSR2DBLINK c
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.chdrnum = c.chdrnum
        and b.prbilfdt = c.prbilfdt
      union all
     select distinct
            'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prbilfdt,
            c.prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgbill2@DMSTAGEDBLINK b,
            stagedbusr.titdmgbill1@DMSTAGEDBLINK c
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.chdrnum = c.chdrnum
        and b.prbilfdt = c.prbilfdt
      union all
     select distinct
            'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.prmfrdt prbilfdt,
            b.prmtodt prbiltdt
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.gpmdpf b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.billtyp = 'N'
    )
  
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.prbilfdt,
         a.prbiltdt src_val,
         b.prbiltdt stg_val,
         c.prbiltdt ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.prbilfdt = c.prbilfdt
     and (a.prbiltdt <> b.prbiltdt or b.prbiltdt <> c.prbiltdt)
   order by a.v_policy_no;	 

  obj_policybill_prbiltdt2 c_policybill_prbiltdt2%rowtype;

BEGIN

  v_attrib := 'POLICY_BILL_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policy_bill_cnt;
    
    loop
  
      fetch c_policy_bill_cnt into obj_policy_bill_cnt;
      exit when c_policy_bill_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policy_bill_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policy_bill_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policy_bill_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policy_bill_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policy_bill_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policy_bill_cnt.d_pol_start_dt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC;
      obj_recon_master.v_src_val          := obj_policy_bill_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policy_bill_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policy_bill_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policy_bill_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICY_PREM_SUM';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policy_prem_sum;
    
    loop
  
      fetch c_policy_prem_sum into obj_policy_prem_sum;
      exit when c_policy_prem_sum%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policy_prem_sum.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policy_prem_sum.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policy_prem_sum.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policy_prem_sum.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policy_prem_sum.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policy_prem_sum.d_pol_start_dt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC;
      obj_recon_master.v_src_val          := obj_policy_prem_sum.src_val;
      obj_recon_master.v_stg_val          := obj_policy_prem_sum.stg_val;
      obj_recon_master.v_ig_val           := obj_policy_prem_sum.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policy_prem_sum;
  
    commit;

  end loop;

  v_attrib := 'POLICY_PRODTYP_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policy_prodtyp_cnt;
    
    loop
  
      fetch c_policy_prodtyp_cnt into obj_policy_prodtyp_cnt;
      exit when c_policy_prodtyp_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policy_prodtyp_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policy_prodtyp_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policy_prodtyp_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policy_prodtyp_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policy_prodtyp_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policy_prodtyp_cnt.d_pol_start_dt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC;
      obj_recon_master.v_src_val          := obj_policy_prodtyp_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policy_prodtyp_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policy_prodtyp_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policy_prodtyp_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICY_INSURED_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policy_insured_cnt;
    
    loop
  
      fetch c_policy_insured_cnt into obj_policy_insured_cnt;
      exit when c_policy_insured_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policy_insured_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policy_insured_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policy_insured_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policy_insured_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policy_insured_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policy_insured_cnt.d_pol_start_dt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC;
      obj_recon_master.v_src_val          := obj_policy_insured_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policy_insured_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policy_insured_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policy_insured_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_PRBILTDT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_prbiltdt;
    
    loop
  
      fetch c_policybill_prbiltdt into obj_policybill_prbiltdt;
      exit when c_policybill_prbiltdt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_prbiltdt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_prbiltdt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_prbiltdt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_prbiltdt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_prbiltdt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_prbiltdt.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_prbiltdt.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_prbiltdt.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_prbiltdt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_prbiltdt;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_INSTNO';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_instno;
    
    loop
  
      fetch c_policybill_instno into obj_policybill_instno;
      exit when c_policybill_instno%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_instno.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_instno.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_instno.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_instno.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_instno.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_instno.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_instno.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_instno.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_instno.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_instno;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_NRFLG';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_nrflg;
    
    loop
  
      fetch c_policybill_nrflg into obj_policybill_nrflg;
      exit when c_policybill_nrflg%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_nrflg.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_nrflg.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_nrflg.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_nrflg.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_nrflg.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_nrflg.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_nrflg.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_nrflg.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_nrflg.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_nrflg;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_ZPOSBDSM';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_zposbdsm;
    
    loop
  
      fetch c_policybill_zposbdsm into obj_policybill_zposbdsm;
      exit when c_policybill_zposbdsm%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_zposbdsm.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_zposbdsm.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_zposbdsm.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_zposbdsm.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_zposbdsm.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_zposbdsm.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_zposbdsm.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_zposbdsm.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_zposbdsm.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_zposbdsm;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_ZPOSBDSY';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_zposbdsy;
    
    loop
  
      fetch c_policybill_zposbdsy into obj_policybill_zposbdsy;
      exit when c_policybill_zposbdsy%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_zposbdsy.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_zposbdsy.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_zposbdsy.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_zposbdsy.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_zposbdsy.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_zposbdsy.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_zposbdsy.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_zposbdsy.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_zposbdsy.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_zposbdsy;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_PRODTYP_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_prodtyp_cnt;
    
    loop
  
      fetch c_policybill_prodtyp_cnt into obj_policybill_prodtyp_cnt;
      exit when c_policybill_prodtyp_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_prodtyp_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_prodtyp_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_prodtyp_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_prodtyp_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_prodtyp_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_prodtyp_cnt.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_prodtyp_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_prodtyp_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_prodtyp_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_prodtyp_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_PRODTYP2_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_prodtyp2_cnt;
    
    loop
  
      fetch c_policybill_prodtyp2_cnt into obj_policybill_prodtyp2_cnt;
      exit when c_policybill_prodtyp2_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_prodtyp2_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_prodtyp2_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_prodtyp2_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_prodtyp2_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_prodtyp2_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_prodtyp2_cnt.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_prodtyp2_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_prodtyp2_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_prodtyp2_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_prodtyp2_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_INSURED_CNT';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_insured_cnt;
    
    loop
  
      fetch c_policybill_insured_cnt into obj_policybill_insured_cnt;
      exit when c_policybill_insured_cnt%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_insured_cnt.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_insured_cnt.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_insured_cnt.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_insured_cnt.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_insured_cnt.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_insured_cnt.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_insured_cnt.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_insured_cnt.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_insured_cnt.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_insured_cnt;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_EFFDATE';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_effdate;
    
    loop
  
      fetch c_policybill_effdate into obj_policybill_effdate;
      exit when c_policybill_effdate%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_effdate.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_effdate.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_effdate.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_effdate.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_effdate.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_effdate.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_effdate.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_effdate.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_effdate.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_effdate;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_PREM_SUM';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_prem_sum;
    
    loop
  
      fetch c_policybill_prem_sum into obj_policybill_prem_sum;
      exit when c_policybill_prem_sum%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_prem_sum.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_prem_sum.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_prem_sum.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_prem_sum.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_prem_sum.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_prem_sum.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_prem_sum.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_prem_sum.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_prem_sum.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_prem_sum;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_INSTNO2';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_instno2;
    
    loop
  
      fetch c_policybill_instno2 into obj_policybill_instno2;
      exit when c_policybill_instno2%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_instno2.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_instno2.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_instno2.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_instno2.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_instno2.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_instno2.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_instno2.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_instno2.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_instno2.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_instno2;
  
    commit;

  end loop;

  v_attrib := 'POLICYBILL_PRBILTDT2';
  for r1 in c_valid_attrib(v_attrib) loop

    open c_policybill_prbiltdt2;
    
    loop
  
      fetch c_policybill_prbiltdt2 into obj_policybill_prbiltdt2;
      exit when c_policybill_prbiltdt2%notfound;
      
      p_exittext := v_attrib || ' - ' || obj_policybill_prbiltdt2.v_policy_no;
    
      obj_recon_master.v_batch_id         := p_detail_batch_id;
      obj_recon_master.v_policy_no        := obj_policybill_prbiltdt2.v_policy_no;
      obj_recon_master.v_prod_cde         := obj_policybill_prbiltdt2.v_prd_cde;
      obj_recon_master.v_pol_commdt       := obj_policybill_prbiltdt2.d_pol_start_dt;
      obj_recon_master.v_attrib_name      := v_attrib;
      obj_recon_master.v_pol_status       := obj_policybill_prbiltdt2.v_pol_status;
      obj_recon_master.v_module_name      := C_MODULE_NAME;
      obj_recon_master.v_eff_date         := obj_policybill_prbiltdt2.prbilfdt;
      obj_recon_master.v_eff_desc         := C_EFF_DESC2;
      obj_recon_master.v_src_val          := obj_policybill_prbiltdt2.src_val;
      obj_recon_master.v_stg_val          := obj_policybill_prbiltdt2.stg_val;
      obj_recon_master.v_ig_val           := obj_policybill_prbiltdt2.ig_val;
      obj_recon_master.v_summary_batch_id := p_summary_batch_id;
      obj_recon_master.d_created_on       := SYSDATE;
      obj_recon_master.v_created_by       := C_CREATED_BY;
      obj_recon_master.v_job_name         := C_JOB_NAME;
    
      INSERT INTO view_dm_billinst_recon_det VALUES obj_recon_master;
  
    end loop;
    
    close c_policybill_prbiltdt2;
  
    commit;

  end loop;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
    dbms_output.put_line('error: '||sqlerrm);
    p_exitcode := SQLCODE;
    p_exittext := p_exittext || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    Jd1dta.insert_error_log(p_exitcode, p_exittext, 'BILLINST');
    raise_application_error(-20001, p_exitcode || p_exittext);

END DM_BILLINST_RECON_SET2;