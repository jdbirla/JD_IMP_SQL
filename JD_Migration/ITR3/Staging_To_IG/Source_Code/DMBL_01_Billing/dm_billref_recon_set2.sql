create or replace procedure dm_billref_recon_set2(p_detail_batch_id  in dm_pol_billref_recon_det.v_batch_id%type,
                                                  p_summary_batch_id in dm_pol_billref_recon_det.v_summary_batch_id%type)
as

-- TYPE t_source_data IS TABLE OF r_source_data;
tl_source_data o_data_set;   
tl_staging_data o_data_set; 
tl_ig_data o_data_set;



--type r_get_src_det is ref cursor;
--c_get_src_det r_get_src_det; 

-- cur SYS_REFCURSOR;
 
--- local variable declaration

lv_attrib_name      Jd1dta.dm_pol_billref_recon_det.v_attrib_name%type;
lv_src_val          Jd1dta.dm_pol_billref_recon_det.v_src_val%type;
lv_stg_val          Jd1dta.dm_pol_billref_recon_det.v_stg_val%type;
lv_ig_val           Jd1dta.dm_pol_billref_recon_det.v_ig_val%type;
lv_batch_id         Jd1dta.dm_pol_billref_recon_det.v_batch_id%type;
lv_summary_batch_id Jd1dta.dm_pol_billref_recon_det.v_summary_batch_id%type;

--- Constant variable declaration
--lv_policy_refund_cnt      constant varchar2(50) := 'POLICY_REFUND_CNT';
lv_policy_zrefund_amt_hdr constant varchar2(50) := 'POLICY_ZREFUND_AMT_HDR';
lv_policy_erefund_amt_hdr constant varchar2(50) := 'POLICY_EREFUND_AMT_HDR';
lv_policy_refund_amt_dtl  constant varchar2(50) := 'POLICY_REFUND_AMT_DTL';
lv_policy_refund_cnt      constant varchar2(50) := 'POLICY_REFUND_CNT';
lv_policy_refund_eff_date constant varchar2(50) := 'POLICY_REFUND_EFF_DATE';
lv_policy_erefund_status  constant varchar2(50) := 'POLICY_EREFUND_STATUS';
lv_policy_zrefund_status  constant varchar2(50) := 'POLICY_ZREFUND_STATUS';
lv_policy_refund_mthd_cd  constant varchar2(50) := 'POLICY_REFUND_MTHD_CD';
lv_policy_refund_bnk_ky   constant varchar2(50) := 'POLICY_REFUND_BNK_KEY';
lv_policy_refund_ba_ky    constant varchar2(50) := 'POLICY_REFUND_BA_KEY';
lv_policy_refund_bad      constant varchar2(50) := 'POLICY_REFUND_BA_DESC';
lv_policy_refund_bat      constant varchar2(50) := 'POLICY_REFUND_BA_TYPE';
lv_policy_refund_bkrdf    constant varchar2(50) := 'POLICY_REFUND_BKRDF';
lv_policy_refund_rqdt     constant varchar2(50) := 'POLICY_REFUND_REQ_DT';
lv_policy_refund_prod_typ constant varchar2(50) := 'POLICY_REFUND_PROD_TYPE';

lv_policy_refund_mbrno      constant varchar2(50) := 'POLICY_REFUND_MBRNO';
lv_policy_refund_dpntno     constant varchar2(50) := 'POLICY_REFUND_DPNTNO';
lv_policy_refund_bprem      constant varchar2(50) := 'POLICY_REFUND_BPREM';
lv_policy_refund_trrefnum   constant varchar2(50) := 'POLICY_REFUND_TRREFNUM';
lv_policy_refund_prmfrdt    constant varchar2(50) := 'POLICY_REFUND_PRMFRDT';
lv_policy_refund_prmtodt    constant varchar2(50) := 'POLICY_REFUND_PRMTODT';
lv_policy_refund_pay_dt     constant varchar2(50) := 'POLICY_REFUND_PAY_DT';
lv_policy_refund_prbilfdt   constant varchar2(50) := 'POLICY_REFUND_PRBILFDT';
lv_policy_refund_prbiltdt   constant varchar2(50) := 'POLICY_REFUND_PRBILTDT';
lv_policy_refund_billduedt  constant varchar2(50) := 'POLICY_REFUND_BILLDUEDT';
lv_policy_refund_zposbdsm   constant varchar2(50) := 'POLICY_REFUND_ZPOSBDSM';
lv_policy_refund_zposbdsy   constant varchar2(50) := 'POLICY_REFUND_ZPOSBDSY';
lv_policy_refund_rdocpfx    constant varchar2(50) := 'POLICY_REFUND_RDOCPFX';
lv_policy_refund_rdoccoy    constant varchar2(50) := 'POLICY_REFUND_RDOCCOY';
lv_policy_refund_rdocnum    constant varchar2(50) := 'POLICY_REFUND_RDOCNUM';
lv_policy_refund_gbdprodtyp constant varchar2(50) := 'POLICY_REFUND_GBDPRDTYP';
lv_policy_refund_gbi_instno constant varchar2(50) := 'POLICY_REFUND_GBIINSTNO';




lv_module_name            constant varchar2(25) := 'Billing refund';
lv_eff_desc               constant varchar2(25) := 'Policy Cancellation date';
          
 
lv_prg  Jd1dta.dm_pol_billref_recon_det.v_job_name%type := 'dm_billref_recon_set2';

lv_err_code      error_log.v_error_code%type;
lv_err_msg       error_log.v_error_message%type;
lv_prg_name      error_log.v_prog%type := 'dm_billref_recon_set2';
begin

lv_batch_id         := p_detail_batch_id;
lv_summary_batch_id := p_summary_batch_id;

--- Below cursor might need a change incase if the renewal policy also have the same tranno 
select r_data_set(v_pol_no, src_hr_eref, src_hr_zref, src_ref_cnt, src_eff_date, src_eref_status, src_zref_status,src_ref_method,
                  src_ref_bk,src_ref_ba,src_ref_bad,src_ref_bat,src_ref_bkrdf,src_ref_rqdt, src_dt_ref,
                  src_prodtyp,src_mbrno,src_dpntno,src_bprem,src_trrefnum,src_Prbilfdt,src_prbiltdt,src_pay_dt,
                  src_prbilfdt,src_prbiltdt,src_eff_date,
                  src_hr_zposbdsm,src_hr_zposbdsy,src_hr_rdocpfx,src_hr_rdoccoy,src_hr_rdocnum,
                  src_prodtyp,src_gbi_instno)
bulk collect into tl_source_data
                  from (with header_data
                        as(select distinct a.chdrnum v_pol_no,
                               sum(a.zrefundbe) over (partition by a.chdrnum,nvl(a.tranno,0),a.rdocnum) hr_refund_by_end,
                               sum(a.zrefundbz) over (partition by a.chdrnum,nvl(a.tranno,0),a.rdocnum) hr_refund_by_zur,
                               count(a.chdrnum) over (partition by a.chdrnum,nvl(a.tranno,0),a.rdocnum) no_of_ref_per_tran,
                               min(to_date(a.effdate,'yyyymmdd')) over (partition by a.chdrnum,nvl(a.tranno,0)) hr_eff_date,
                               Zenrfdst hr_erefund_status,
                               Zzhrfdst hr_zrefund_status,
                               zrefmtcd hr_ref_mthd,
                               bankkey hr_ref_bk,
                               bankacount hr_ref_ba,
                               bankaccdsc hr_ref_bad,
                               bnkactyp hr_ref_bat,
                               zrqbkrdf hr_ref_bkrdf,
                               reqdate hr_ref_rqdt,
                               paydate hr_ref_paydt,
                               zposbdsm hr_zposbdsm,
                               zposbdsy hr_zposbdsy,
                               rdocpfx hr_rdocpfx,
                               rdoccoy hr_rdoccoy,
                               rdocnum hr_rdocnum
                        from Stagedbusr2.titdmgref1@dmstagedblink a,
                             stagedbusr2.dm_policy_recon@dmstagedblink  b
                        where a.chdrnum = b.v_policy_no)
                        select distinct b.v_pol_no,
                        to_char(b.hr_refund_by_end) src_hr_eref,
                        to_char(b.hr_refund_by_zur) src_hr_zref,
                        to_char(b.no_of_ref_per_tran) src_ref_cnt,
                        to_char(b.hr_eff_date,'YYYYMMDD') src_eff_date,
                        b.hr_erefund_status src_eref_status,
                        b.hr_zrefund_status src_zref_status,
                        b.hr_ref_mthd src_ref_method,
                        b.hr_ref_bk src_ref_bk,
                        b.hr_ref_ba src_ref_ba,
                        b.hr_ref_bad src_ref_bad,
                        b.hr_ref_bat src_ref_bat,
                        b.hr_ref_bkrdf src_ref_bkrdf,
                        b.hr_ref_rqdt src_ref_rqdt,
                        to_char(sum(a.bprem) over (partition by a.chdrnum, nvl(a.tranno,0))) src_dt_ref,  
                       (select listagg(prodtyp,'-') within group (order by prodtyp) from
                        (select distinct prodtyp  prodtyp from
                       Stagedbusr2.titdmgref2@dmstagedblink e
                        where e.chdrnum = a.chdrnum
                       and nvl(e.tranno,0) = nvl(a.tranno,0))) src_prodtyp,    
                       (select listagg(mbrno,'-') within group (order by mbrno) from
                        (select distinct e.mbrno mbrno from
                       Stagedbusr2.titdmgref2@dmstagedblink e
                        where e.chdrnum = a.chdrnum
                       and nvl(e.tranno,0) = nvl(a.tranno,0))) src_mbrno,   
                       (select listagg(dpntno,'-') within group (order by dpntno) from
                        (select distinct dpntno dpntno from
                       Stagedbusr2.titdmgref2@dmstagedblink e
                        where e.chdrnum = a.chdrnum
                       and nvl(e.tranno,0) = nvl(a.tranno,0))) src_dpntno,   
                       (select listagg(bprem,'-') within group (order by bprem) from
                        (select distinct bprem bprem from
                       Stagedbusr2.titdmgref2@dmstagedblink e
                        where e.chdrnum = a.chdrnum
                       and nvl(e.tranno,0) = nvl(a.tranno,0))) src_bprem, 
                       (select listagg(trrefnum,'-') within group (order by trrefnum) from
                        (select distinct trrefnum trrefnum from
                       Stagedbusr2.titdmgref2@dmstagedblink e
                        where e.chdrnum = a.chdrnum
                       and nvl(e.tranno,0) = nvl(a.tranno,0))) src_trrefnum,  
                        (select listagg(Prbilfdt,'-') within group (order by Prbilfdt) from
                         Stagedbusr2.titdmgref1@dmstagedblink e
                          where e.chdrnum = a.chdrnum
                         and nvl(e.tranno,0) = nvl(a.tranno,0)) src_Prbilfdt,
                        (select listagg(prbiltdt,'-') within group (order by prbiltdt) from
                         Stagedbusr2.titdmgref1@dmstagedblink e
                          where e.chdrnum = a.chdrnum
                         and nvl(e.tranno,0) = nvl(a.tranno,0)) src_prbiltdt,
                          b.hr_ref_paydt src_pay_dt,
                          b.hr_zposbdsm src_hr_zposbdsm,
                          b.hr_zposbdsy src_hr_zposbdsy,
                          b.hr_rdocpfx src_hr_rdocpfx,
                          b.hr_rdoccoy src_hr_rdoccoy,
                          b.hr_rdocnum src_hr_rdocnum,
                         (select listagg(refnum,'-') within group (order by refnum) from
                         Stagedbusr2.titdmgref1@dmstagedblink e
                          where e.chdrnum = a.chdrnum
                         and nvl(e.tranno,0) = nvl(a.tranno,0)) src_gbi_instno
                        from Stagedbusr2.titdmgref2@dmstagedblink a,
                        header_data b
                        where a.chdrnum = b.v_pol_no); 
                        
select r_data_set(v_pol_no, stg_hr_eref, stg_hr_zref, stg_ref_cnt, stg_eff_date, stg_eref_status ,stg_zref_status, stg_ref_method,
                 stg_ref_bk,stg_ref_ba,stg_ref_bad,stg_ref_bat,stg_ref_bkrdf,stg_ref_rqdt,stg_dt_ref,
                  stg_prodtyp,stg_mbrno,stg_dpntno,stg_bprem,stg_trrefnum,stg_Prbilfdt,stg_prbiltdt,stg_pay_dt,
                  stg_prbilfdt,stg_prbiltdt,stg_eff_date,
                  stg_hr_zposbdsm,stg_hr_zposbdsy,stg_hr_rdocpfx,stg_hr_rdoccoy,stg_hr_rdocnum,
                  stg_prodtyp,stg_gbi_instno)
bulk collect into tl_staging_data
                  from (with header_data
                        as(select distinct a.chdrnum v_pol_no,
                               sum(a.zrefundbe) over (partition by a.chdrnum,a.tranno,a.rdocnum) hr_refund_by_end,
                               sum(a.zrefundbz) over (partition by a.chdrnum,a.tranno,a.rdocnum) hr_refund_by_zur,
                               count(a.chdrnum) over (partition by a.chdrnum,a.tranno,a.rdocnum) no_of_ref_per_tran,
                               min(to_date(a.effdate,'yyyymmdd')) over (partition by a.chdrnum,a.tranno) hr_eff_date,
                               Zenrfdst hr_erefund_status,
                               Zzhrfdst hr_zrefund_status,
                               zrefmtcd hr_ref_mthd,
                               bankkey hr_ref_bk,
                               bankacount hr_ref_ba,
                               bankaccdsc hr_ref_bad,
                               bnkactyp hr_ref_bat,
                               zrqbkrdf hr_ref_bkrdf,
                               reqdate hr_ref_rqdt,
                               paydate hr_ref_paydt,
                               zposbdsm hr_zposbdsm,
                               zposbdsy hr_zposbdsy,
                               rdocpfx hr_rdocpfx,
                               rdoccoy hr_rdoccoy,
                               rdocnum hr_rdocnum                     
                        from Stagedbusr.titdmgref1@dmstagedblink a,
                             stagedbusr2.dm_policy_recon@dmstagedblink  b
                        where a.chdrnum = b.v_policy_no)
                        select distinct b.v_pol_no,
                        to_char(b.hr_refund_by_end) stg_hr_eref,
                        to_char(b.hr_refund_by_zur) stg_hr_zref,
                        to_char(b.no_of_ref_per_tran) stg_ref_cnt,
                        to_char(b.hr_eff_date,'YYYYMMDD') stg_eff_date,
                              b.hr_erefund_status stg_eref_status,
                              b.hr_zrefund_status stg_zref_status,
                        b.hr_ref_mthd stg_ref_method,
                              b.hr_ref_bk stg_ref_bk,
                              b.hr_ref_ba stg_ref_ba,
                              b.hr_ref_bad stg_ref_bad,
                              b.hr_ref_bat stg_ref_bat,
                              b.hr_ref_bkrdf stg_ref_bkrdf,
                              b.hr_ref_rqdt stg_ref_rqdt,                         
                              to_char(sum(a.bprem) over (partition by a.chdrnum, a.tranno)) stg_dt_ref,
                              (select listagg(prodtyp,'-') within group (order by prodtyp) from
                              (select distinct prodtyp  prodtyp from
                              Stagedbusr.titdmgref2@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno)) stg_prodtyp,   
                              (select listagg(mbrno,'-') within group (order by mbrno) from
                              (select distinct e.mbrno mbrno from
                              Stagedbusr.titdmgref2@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno)) stg_mbrno,   
                              (select listagg(dpntno,'-') within group (order by dpntno) from
                              (select distinct dpntno dpntno from
                              Stagedbusr.titdmgref2@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno)) stg_dpntno, 
                              (select listagg(bprem,'-') within group (order by bprem) from
                              (select distinct bprem bprem from
                              Stagedbusr.titdmgref2@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno)) stg_bprem, 
                              (select listagg(trrefnum,'-') within group (order by trrefnum) from
                              (select distinct trrefnum trrefnum from
                              Stagedbusr.titdmgref2@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno)) stg_trrefnum,               
                              (select listagg(Prbilfdt,'-') within group (order by Prbilfdt) from
                              Stagedbusr.titdmgref1@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno) stg_Prbilfdt,
                              (select listagg(prbiltdt,'-') within group (order by prbiltdt) from
                              Stagedbusr.titdmgref1@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                              and e.tranno = a.tranno) stg_prbiltdt,
                              b.hr_ref_paydt stg_pay_dt,
                              b.hr_zposbdsm stg_hr_zposbdsm,
                              b.hr_zposbdsy stg_hr_zposbdsy,
                              b.hr_rdocpfx stg_hr_rdocpfx,
                              b.hr_rdoccoy stg_hr_rdoccoy,
                              b.hr_rdocnum stg_hr_rdocnum,
                             (select listagg(refnum,'-') within group (order by refnum) from
                             Stagedbusr.titdmgref1@dmstagedblink e
                              where e.chdrnum = a.chdrnum
                             and e.tranno = a.tranno) stg_gbi_instno                 
                        from Stagedbusr.titdmgref2@dmstagedblink a,
                        header_data b
                        where a.chdrnum = b.v_pol_no); 
 
                      
 
select r_data_set(v_pol_no, ig_hr_eref, ig_hr_zref, ig_ref_cnt, ig_eff_date, ig_eref_status,ig_zref_status, ig_ref_method,
                 ig_ref_bk,ig_ref_ba,ig_ref_bad,ig_ref_bat,ig_ref_bkrdf,ig_ref_rqdt, ig_dt_ref,
                 ig_prodtyp, ig_mbrno,ig_dpntno, ig_bprem, ig_trrefnum, ig_prmfrdt, ig_prmtodt, ig_paydt,
                 ig_prbilfdt, ig_prbiltdt, ig_billduedt, ig_zposbdsm, ig_zposbdsy, ig_rdocpfx, ig_rdoccoy, ig_rdocnum, ig_gbd_prodtyp,
                 ig_gbi_instno)
bulk collect into tl_ig_data
from (with header_data as
            (select distinct bh.chdrnum v_pol_no,
                   brh.zrefundbe ig_hr_eref,
                   brh.zrefundbz ig_hr_zref,
                   count(bh.unique_number) over (partition by bh.chdrnum,bh.tranno,bh.rdocnum) ig_ref_cnt,
                   brh.effdate ig_eff_date,
                   brh.zenrfdst ig_eref_status,
                   brh.zzhrfdst ig_zref_status,
                   brh.zrefmtcd ig_ref_method,
                   brh.bankkey ig_ref_bk,
                   brh.bankacount ig_ref_ba,
                   brh.bankaccdsc ig_ref_bad,
                   brh.bnkactyp ig_ref_bat,
                   brh.zrqbkrdf ig_ref_bkrdf,
                   brh.reqdate ig_ref_rqdt, 
                   bh.tranno tranno
            from Jd1dta.gbihpf bh,
                 Jd1dta.zreppf brh,
                 Jd1dta.ztrapf ztp,
                 stagedbusr2.dm_policy_recon@dmstagedblink rec
            where bh.chdrnum = brh.chdrnum 
            and bh.tranno = brh.tranno
            and bh.chdrnum = rec.v_policy_no
            and bh.chdrnum = ztp.chdrnum
            and ztp.tranno = bh.tranno
            and bh.billtyp = 'A'
            and ztp.statcode = 'CA')
            select distinct hd.v_pol_no,
            to_char(hd.ig_hr_eref) ig_hr_eref,
            to_char(hd.ig_hr_zref) ig_hr_zref,
            to_char(hd.ig_ref_cnt) ig_ref_cnt,
            to_char(hd.ig_eff_date) ig_eff_date,
                    hd.ig_eref_status,
                    hd.ig_zref_status,
            to_char(hd.ig_ref_method) ig_ref_method,
                    to_char(hd.ig_ref_bk) ig_ref_bk,
                    to_char(hd.ig_ref_ba) ig_ref_ba,
                    to_char(hd.ig_ref_bad) ig_ref_bad,
                    to_char(hd.ig_ref_bat) ig_ref_bat,
                    to_char(hd.ig_ref_bkrdf) ig_ref_bkrdf,
                    to_char(hd.ig_ref_rqdt) ig_ref_rqdt,
                    to_char(sum(brd.zrefundam)  over (partition by brd.chdrnum,brd.effdate,brd.tranno)) ig_dt_ref,
                    (select listagg(prodtyp,'-') within group (order by prodtyp) 
                    from (select distinct e.prodtyp prodtyp from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_prodtyp,               
                    (select listagg(Dpntno,'-') within group (order by Dpntno) 
                    from (select distinct e.Dpntno Dpntno from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_Dpntno, 
                    (select listagg(pprem,'-') within group (order by pprem) 
                    from (select distinct abs(e.pprem) pprem from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_bprem,              
                    (select listagg(mbrno,'-') within group (order by mbrno) 
                    from (select distinct e.mbrno mbrno from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_mbrno, 
                    (select listagg(instno,'-') within group (order by instno) 
                    from (select distinct e.instno instno from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_trrefnum, 
                    (select listagg(prmfrdt,'-') within group (order by prmfrdt) 
                    from (select distinct e.prmfrdt from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_prmfrdt,           
                    (select listagg(prmtodt,'-') within group (order by prmtodt) 
                    from (select distinct e.prmtodt prmtodt from
                    gpmdpf e
                    where hd.v_pol_no = e.chdrnum
                    and e.tranno = hd.tranno
                    and e.effdate = hd.ig_eff_date)) ig_prmtodt,        
                    gbi.prbilfdt ig_prbilfdt,
                    gbi.prbiltdt ig_prbiltdt,
                    gbi.paydate ig_paydt,
                    gbi.billduedt ig_billduedt,
                    gbi.zposbdsm ig_zposbdsm,
                    gbi.zposbdsy ig_zposbdsy,
                    gbi.rdocpfx ig_rdocpfx,
                    gbi.rdoccoy ig_rdoccoy,
                    gbi.rdocnum ig_rdocnum,
                    gbd.prodtyp ig_gbd_prodtyp,
                    gbi.Instno  ig_gbi_instno
            from header_data hd,
                 zrfdpf brd,
                 (select chdrnum,tranno,billduedt,zposbdsm,zposbdsy,rdocpfx,rdoccoy,rdocnum,paydate,
                 listagg(prbilfdt,'-') within group (order by prbilfdt) prbilfdt,
                 listagg(prbiltdt,'-') within group (order by prbiltdt) prbiltdt,
                 listagg(Instno,'-') within group (order by Instno) Instno
                 from 
                     (select chdrnum,tranno,prbilfdt,prbiltdt,Instno,billduedt,zposbdsm,
                     zposbdsy,rdocpfx,rdoccoy,rdocnum,paydate
                     from gbihpf
                     where billtyp = 'A')
                 group by chdrnum,tranno,billduedt,zposbdsm,zposbdsy,rdocpfx,rdoccoy,rdocnum,paydate) gbi,
                 (select chdrnum,tranno,listagg(prodtyp,'-') within group (order by prodtyp) prodtyp
                 from (select distinct f.chdrnum,e.tranno,e.prodtyp
                 from gbidpf e,gbihpf f
                 where e.billno = f.billno
                 and e.tranno = f.tranno
                 and f.billtyp = 'A')group by  chdrnum,tranno) gbd
            where brd.chdrnum = hd.v_pol_no
            and brd.effdate = hd.ig_eff_date
            and brd.zrefmtcd = hd.ig_ref_method
            and brd.tranno = hd.tranno
            and gbi.chdrnum = hd.v_pol_no
            and gbi.tranno = hd.tranno
            and gbi.billduedt = hd.ig_eff_date
            and gbd.chdrnum = gbi.chdrnum
            and gbd.tranno = gbi.tranno);



  
                        
for c_get_recon_det in (select  distinct a.v_pol_no,d.v_prd_cde,d.d_pol_start_dt,d.v_pol_status
                                 ,a.hr_eref src_hr_eref,a.hr_zref src_hr_zref,a.ref_cnt src_ref_cnt,a.eff_date src_eff_date,a.e_ref_status src_eref_status,a.z_ref_status src_zref_status,a.ref_method src_ref_method
                                 ,a.ref_bk src_ref_bk,a.ref_ba src_ref_ba,a.ref_bd src_ref_bd,a.ref_bat src_ref_bat,a.ref_bkrdf src_ref_bkrdf,a.ref_rqdt src_ref_rqdt,a.dt_ref src_dt_ref 
                                 ,a.prodtyp src_prodtyp,a.mbrno src_mbrno,a.dpntno src_dpntno,a.bprem src_bprem,a.trrefnum src_trrefnum,a.prmfrdt src_prmfrdt,a.prmtodt src_prmtodt,a.pay_dt src_pay_dt,a.prbilfdt src_prbilfdt
                                 ,a.prbiltdt src_prbiltdt,a.Billduedt src_billduedt,a.zposbdsm src_hr_zposbdsm,a.zposbdsy src_hr_zposbdsy,a.rdocpfx src_hr_rdocpfx,a.rdoccoy src_hr_rdoccoy,a.rdocnum src_hr_rdocnum
                                 ,a.gbd_prodtyp src_gbd_prodtyp,a.gbi_instno src_gbi_instno
                                 ,b.hr_eref stg_hr_eref,b.hr_zref stg_hr_zref,b.ref_cnt stg_ref_cnt,b.eff_date stg_eff_date,b.e_ref_status stg_eref_status,b.z_ref_status stg_zref_status,b.ref_method stg_ref_method
                                 ,b.ref_bk stg_ref_bk,b.ref_ba stg_ref_ba,b.ref_bd stg_ref_bd,b.ref_bat stg_ref_bat,b.ref_bkrdf stg_ref_bkrdf,b.ref_rqdt stg_ref_rqdt,b.dt_ref stg_dt_ref 
                                 ,b.prodtyp stg_prodtyp,b.mbrno stg_mbrno,b.dpntno stg_dpntno,b.bprem stg_bprem,b.trrefnum stg_trrefnum,b.prmfrdt stg_prmfrdt,b.prmtodt stg_prmtodt,b.pay_dt stg_pay_dt,b.prbilfdt stg_prbilfdt
                                 ,b.prbiltdt stg_prbiltdt,b.Billduedt stg_billduedt,b.zposbdsm stg_hr_zposbdsm,b.zposbdsy stg_hr_zposbdsy,b.rdocpfx stg_hr_rdocpfx,b.rdoccoy stg_hr_rdoccoy,b.rdocnum stg_hr_rdocnum
                                 ,b.gbd_prodtyp stg_gbd_prodtyp,b.gbi_instno stg_gbi_instno
                                 ,c.hr_eref ig_hr_eref,c.hr_zref ig_hr_zref,c.ref_cnt ig_ref_cnt,c.eff_date ig_eff_date,c.e_ref_status ig_eref_status,c.z_ref_status ig_zref_status,c.ref_method ig_ref_method
                                 ,c.ref_bk ig_ref_bk,c.ref_ba ig_ref_ba,c.ref_bd ig_ref_bd,c.ref_bat ig_ref_bat,c.ref_bkrdf ig_ref_bkrdf,c.ref_rqdt ig_ref_rqdt,c.dt_ref ig_dt_ref 
                                 ,c.prodtyp ig_prodtyp,c.mbrno ig_mbrno,c.dpntno ig_dpntno,c.bprem ig_bprem,c.trrefnum ig_trrefnum,c.prmfrdt ig_prmfrdt,c.prmtodt ig_prmtodt,c.pay_dt ig_pay_dt,c.prbilfdt ig_prbilfdt
                                 ,c.prbiltdt ig_prbiltdt,c.billduedt ig_billduedt,c.zposbdsm ig_zposbdsm,c.zposbdsy ig_zposbdsy,c.rdocpfx ig_rdocpfx,c.rdoccoy ig_rdoccoy,c.rdocnum ig_rdocnum
                                 ,c.gbd_prodtyp ig_gbd_prodtyp,c.gbi_instno ig_gbi_instno
                        from table(tl_source_data) a,
                             table(tl_staging_data) b,
                             table(tl_ig_data) c,
                             stagedbusr2.dm_policy_recon@dmstagedblink d
                          where a.v_pol_no = b.v_pol_no (+)
                            and a.v_pol_no = c.v_pol_no (+)
                          and a.v_pol_no = d.v_policy_no)
             
loop 

  for c_get_attr in (select v_module_name,v_attrib_name 
                     from dm_data_validation_attrib 
                     where v_module_name = lv_module_name
                     and c_status_flg = 'Y')
  loop

       --  dbms_output.put_line('v_module_name '||c_get_attr.v_module_name||'--'||c_get_attr.v_attrib_name||'lv_policy_refund_amt_dtl '||lv_policy_refund_amt_dtl);
      --   dbms_output.put_line('c_get_recon_det.src_dt_ref '||c_get_recon_det.src_dt_ref);
      --   dbms_output.put_line('c_get_recon_det.stg_dt_ref '||c_get_recon_det.stg_dt_ref);
       --  dbms_output.put_line('c_get_recon_det.ig_dt_ref '||c_get_recon_det.ig_dt_ref);
         
    if (c_get_attr.v_attrib_name = lv_policy_erefund_amt_hdr
    and (nvl(trim(c_get_recon_det.src_hr_eref),'0') <> nvl(trim(c_get_recon_det.stg_hr_eref),'0') or nvl(trim(c_get_recon_det.stg_hr_eref),'0') <> nvl(trim(c_get_recon_det.ig_hr_eref),'0')))
    then  

        
         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_eref;
         lv_stg_val     := c_get_recon_det.stg_hr_eref;
         lv_ig_val      := c_get_recon_det.ig_hr_eref; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_zrefund_amt_hdr
     and (nvl(trim(c_get_recon_det.src_hr_zref),'0') <> nvl(trim(c_get_recon_det.stg_hr_zref),'0') or nvl(trim(c_get_recon_det.stg_hr_zref),'0') <> nvl(trim(c_get_recon_det.ig_hr_zref),'0')))
     then

     
         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_zref;
         lv_stg_val     := c_get_recon_det.stg_hr_zref;
         lv_ig_val      := c_get_recon_det.ig_hr_zref; 

     elsif((c_get_attr.v_attrib_name = lv_policy_refund_amt_dtl)
       and (nvl(trim(c_get_recon_det.src_dt_ref),'0') <> nvl(trim(c_get_recon_det.stg_dt_ref),0) or nvl(trim(c_get_recon_det.stg_dt_ref),'0') <> nvl(trim(c_get_recon_det.ig_dt_ref),'0')))
     then

         
         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_dt_ref;
         lv_stg_val     := c_get_recon_det.stg_dt_ref;
         lv_ig_val      := c_get_recon_det.ig_dt_ref; 

     elsif(c_get_attr.v_attrib_name = lv_policy_refund_eff_date
     and (nvl(trim(c_get_recon_det.src_eff_date),'x') <> nvl(trim(c_get_recon_det.stg_eff_date),'x') or nvl(trim(c_get_recon_det.stg_eff_date),'x') <> nvl(trim(c_get_recon_det.ig_eff_date),'x')))
     then



         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_eff_date;
         lv_stg_val     := c_get_recon_det.stg_eff_date;
         lv_ig_val      := c_get_recon_det.ig_eff_date; 

     elsif( c_get_attr.v_attrib_name = lv_policy_erefund_status
     and (nvl(trim(c_get_recon_det.src_eref_status),'x') <> nvl(trim(c_get_recon_det.stg_eref_status),'x') or nvl(trim(c_get_recon_det.stg_eref_status),'x') <> nvl(trim(c_get_recon_det.ig_eref_status),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_eref_status;
         lv_stg_val     := c_get_recon_det.stg_eref_status;
         lv_ig_val      := c_get_recon_det.ig_eref_status; 

     elsif( c_get_attr.v_attrib_name = lv_policy_zrefund_status
     and (nvl(trim(c_get_recon_det.src_zref_status),'x') <> nvl(trim(c_get_recon_det.stg_zref_status),'x') or nvl(trim(c_get_recon_det.stg_zref_status),'x') <> nvl(trim(c_get_recon_det.ig_zref_status),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_zref_status;
         lv_stg_val     := c_get_recon_det.stg_zref_status;
         lv_ig_val      := c_get_recon_det.ig_zref_status;          

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_mthd_cd
     and (nvl(trim(c_get_recon_det.src_ref_method),'x') <> nvl(trim(c_get_recon_det.stg_ref_method),'x') or nvl(trim(c_get_recon_det.stg_ref_method),'x') <> nvl(trim(c_get_recon_det.ig_ref_method),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_method;
         lv_stg_val     := c_get_recon_det.stg_ref_method;
         lv_ig_val      := c_get_recon_det.ig_ref_method; 



     elsif( c_get_attr.v_attrib_name = lv_policy_refund_bnk_ky
     and (nvl(trim(c_get_recon_det.src_ref_bk),'x') <> nvl(trim(c_get_recon_det.stg_ref_bk),'x') or nvl(trim(c_get_recon_det.stg_ref_bk),'x') <> nvl(trim(c_get_recon_det.ig_ref_bk),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_bk;
         lv_stg_val     := c_get_recon_det.stg_ref_bk;
         lv_ig_val      := c_get_recon_det.ig_ref_bk;    
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_ba_ky
     and (nvl(trim(c_get_recon_det.src_ref_ba),'x') <> nvl(trim(c_get_recon_det.stg_ref_ba),'x') or nvl(trim(c_get_recon_det.stg_ref_ba),'x') <> nvl(trim(c_get_recon_det.ig_ref_ba),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_ba;
         lv_stg_val     := c_get_recon_det.stg_ref_ba;
         lv_ig_val      := c_get_recon_det.ig_ref_ba;    
         

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_bad
     and (nvl(trim(c_get_recon_det.src_ref_bd),'x') <> nvl(trim(c_get_recon_det.stg_ref_bd),'x') or nvl(trim(c_get_recon_det.stg_ref_bd),'x') <> nvl(trim(c_get_recon_det.ig_ref_bd),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_bd;
         lv_stg_val     := c_get_recon_det.stg_ref_bd;
         lv_ig_val      := c_get_recon_det.ig_ref_bd;  
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_bat
     and (nvl(trim(c_get_recon_det.src_ref_bat),'x') <> nvl(trim(c_get_recon_det.stg_ref_bat),'x') or nvl(trim(c_get_recon_det.stg_ref_bat),'x') <> nvl(trim(c_get_recon_det.ig_ref_bat),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_bat;
         lv_stg_val     := c_get_recon_det.stg_ref_bat;
         lv_ig_val      := c_get_recon_det.ig_ref_bat; 

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_bkrdf
     and (nvl(trim(c_get_recon_det.src_ref_bkrdf),'x') <> nvl(trim(c_get_recon_det.stg_ref_bkrdf),'x') or nvl(trim(c_get_recon_det.stg_ref_bkrdf),'x') <> nvl(trim(c_get_recon_det.ig_ref_bkrdf),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_bkrdf;
         lv_stg_val     := c_get_recon_det.stg_ref_bkrdf;
         lv_ig_val      := c_get_recon_det.ig_ref_bkrdf; 

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_rqdt
     and (nvl(trim(c_get_recon_det.src_ref_rqdt),'x') <> nvl(trim(c_get_recon_det.stg_ref_rqdt),'x') or nvl(trim(c_get_recon_det.stg_ref_rqdt),'x') <> nvl(trim(c_get_recon_det.ig_ref_rqdt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_rqdt;
         lv_stg_val     := c_get_recon_det.stg_ref_rqdt;
         lv_ig_val      := c_get_recon_det.ig_ref_rqdt; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_cnt
     and (nvl(trim(c_get_recon_det.src_ref_cnt),'x') <> nvl(trim(c_get_recon_det.stg_ref_cnt),'x') or nvl(trim(c_get_recon_det.stg_ref_cnt),'x') <> nvl(trim(c_get_recon_det.ig_ref_cnt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_ref_cnt;
         lv_stg_val     := c_get_recon_det.stg_ref_cnt;
         lv_ig_val      := c_get_recon_det.ig_ref_cnt;          
 
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_prod_typ
     and (nvl(trim(c_get_recon_det.src_prodtyp),'x') <> nvl(trim(c_get_recon_det.Stg_Prodtyp),'x') or nvl(trim(c_get_recon_det.Stg_Prodtyp),'x') <> nvl(trim(c_get_recon_det.ig_prodtyp),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_prodtyp;
         lv_stg_val     := c_get_recon_det.Stg_Prodtyp;
         lv_ig_val      := c_get_recon_det.ig_prodtyp;  
         

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_mbrno
     and (nvl(trim(c_get_recon_det.src_mbrno),'x') <> nvl(trim(c_get_recon_det.stg_mbrno),'x') or nvl(trim(c_get_recon_det.stg_mbrno),'x') <> nvl(trim(c_get_recon_det.ig_mbrno),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_mbrno;
         lv_stg_val     := c_get_recon_det.stg_mbrno;
         lv_ig_val      := c_get_recon_det.ig_mbrno;  

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_dpntno
     and (nvl(trim(c_get_recon_det.src_dpntno),'x') <> nvl(trim(c_get_recon_det.Stg_Dpntno),'x') or nvl(trim(c_get_recon_det.Stg_Dpntno),'x') <> nvl(trim(c_get_recon_det.ig_dpntno),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_dpntno;
         lv_stg_val     := c_get_recon_det.Stg_Dpntno;
         lv_ig_val      := c_get_recon_det.ig_dpntno;  


     elsif( c_get_attr.v_attrib_name = lv_policy_refund_bprem
     and (nvl(trim(c_get_recon_det.src_bprem),'x') <> nvl(trim(c_get_recon_det.stg_bprem),'x') or nvl(trim(c_get_recon_det.stg_bprem),'x') <> nvl(trim(c_get_recon_det.ig_bprem),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_bprem;
         lv_stg_val     := c_get_recon_det.stg_bprem;
         lv_ig_val      := c_get_recon_det.ig_bprem;  
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_trrefnum
     and (nvl(trim(c_get_recon_det.src_trrefnum),'x') <> nvl(trim(c_get_recon_det.Stg_Trrefnum),'x') or nvl(trim(c_get_recon_det.Stg_Trrefnum),'x') <> nvl(trim(c_get_recon_det.ig_trrefnum),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_trrefnum;
         lv_stg_val     := c_get_recon_det.Stg_Trrefnum;
         lv_ig_val      := c_get_recon_det.ig_trrefnum;  

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_prmfrdt
     and (nvl(trim(c_get_recon_det.src_prmfrdt),'x') <> nvl(trim(c_get_recon_det.stg_prmfrdt),'x') or nvl(trim(c_get_recon_det.stg_prbilfdt),'x') <> nvl(trim(c_get_recon_det.ig_prmfrdt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_prmfrdt;
         lv_stg_val     := c_get_recon_det.stg_prmfrdt;
         lv_ig_val      := c_get_recon_det.ig_prmfrdt;  

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_prmtodt
     and (nvl(trim(c_get_recon_det.src_prmtodt),'x') <> nvl(trim(c_get_recon_det.stg_prmtodt),'x') or nvl(trim(c_get_recon_det.stg_prbiltdt),'x') <> nvl(trim(c_get_recon_det.ig_prmtodt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_prmtodt;
         lv_stg_val     := c_get_recon_det.stg_prmtodt;
         lv_ig_val      := c_get_recon_det.ig_prmtodt;  

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_pay_dt
     and (nvl(trim(c_get_recon_det.src_pay_dt),'x') <> nvl(trim(c_get_recon_det.Stg_Pay_Dt),'x') or nvl(trim(c_get_recon_det.Stg_Pay_Dt),'x') <> nvl(trim(c_get_recon_det.ig_pay_dt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_pay_dt;
         lv_stg_val     := c_get_recon_det.Stg_Pay_Dt;
         lv_ig_val      := c_get_recon_det.ig_pay_dt; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_prbilfdt
     and (nvl(trim(c_get_recon_det.src_prbilfdt),'x') <> nvl(trim(c_get_recon_det.Stg_Prbilfdt),'x') or nvl(trim(c_get_recon_det.Stg_Prbilfdt),'x') <> nvl(trim(c_get_recon_det.ig_prbilfdt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_prbilfdt;
         lv_stg_val     := c_get_recon_det.Stg_Prbilfdt;
         lv_ig_val      := c_get_recon_det.ig_prbilfdt; 

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_prbiltdt
     and (nvl(trim(c_get_recon_det.src_prbiltdt),'x') <> nvl(trim(c_get_recon_det.stg_prbiltdt),'x') or nvl(trim(c_get_recon_det.stg_prbiltdt),'x') <> nvl(trim(c_get_recon_det.ig_prbiltdt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_prbiltdt;
         lv_stg_val     := c_get_recon_det.stg_prbiltdt;
         lv_ig_val      := c_get_recon_det.ig_prbiltdt; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_billduedt
     and (nvl(trim(c_get_recon_det.src_billduedt),'x') <> nvl(trim(c_get_recon_det.stg_billduedt),'x') or nvl(trim(c_get_recon_det.stg_billduedt),'x') <> nvl(trim(c_get_recon_det.ig_billduedt),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_billduedt;
         lv_stg_val     := c_get_recon_det.stg_billduedt;
         lv_ig_val      := c_get_recon_det.ig_billduedt; 

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_zposbdsm
     and (nvl(trim(c_get_recon_det.src_hr_zposbdsm),'x') <> nvl(trim(c_get_recon_det.stg_hr_zposbdsm),'x') or nvl(trim(c_get_recon_det.stg_hr_zposbdsm),'x') <> nvl(trim(c_get_recon_det.ig_zposbdsm),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_zposbdsm;
         lv_stg_val     := c_get_recon_det.stg_hr_zposbdsm;
         lv_ig_val      := c_get_recon_det.ig_zposbdsm; 

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_zposbdsy
     and (nvl(trim(c_get_recon_det.src_hr_zposbdsy),'x') <> nvl(trim(c_get_recon_det.stg_hr_zposbdsy),'x') or nvl(trim(c_get_recon_det.stg_hr_zposbdsy),'x') <> nvl(trim(c_get_recon_det.ig_zposbdsy),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_zposbdsy;
         lv_stg_val     := c_get_recon_det.stg_hr_zposbdsy;
         lv_ig_val      := c_get_recon_det.ig_zposbdsy; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_rdocpfx
     and (nvl(trim(c_get_recon_det.Src_Hr_Rdocpfx),'x') <> nvl(trim(c_get_recon_det.stg_hr_rdocpfx),'x') or nvl(trim(c_get_recon_det.stg_hr_rdocpfx),'x') <> nvl(trim(c_get_recon_det.ig_rdocpfx),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.Src_Hr_Rdocpfx;
         lv_stg_val     := c_get_recon_det.stg_hr_rdocpfx;
         lv_ig_val      := c_get_recon_det.ig_rdocpfx; 
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_rdoccoy
     and (nvl(trim(c_get_recon_det.src_hr_rdoccoy),'x') <> nvl(trim(c_get_recon_det.stg_hr_rdoccoy),'x') or nvl(trim(c_get_recon_det.stg_hr_rdoccoy),'x') <> nvl(trim(c_get_recon_det.ig_rdoccoy),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_rdoccoy;
         lv_stg_val     := c_get_recon_det.stg_hr_rdoccoy;
         lv_ig_val      := c_get_recon_det.ig_rdoccoy;       
         
     elsif( c_get_attr.v_attrib_name = lv_policy_refund_rdocnum
     and (nvl(trim(c_get_recon_det.src_hr_rdocnum),'x') <> nvl(trim(c_get_recon_det.stg_hr_rdocnum),'x') or nvl(trim(c_get_recon_det.stg_hr_rdocnum),'x') <> nvl(trim(c_get_recon_det.ig_rdocnum),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_hr_rdocnum;
         lv_stg_val     := c_get_recon_det.stg_hr_rdocnum;
         lv_ig_val      := c_get_recon_det.ig_rdocnum;   

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_gbdprodtyp
     and (nvl(trim(c_get_recon_det.src_gbd_prodtyp),'x') <> nvl(trim(c_get_recon_det.stg_gbd_prodtyp),'x') or nvl(trim(c_get_recon_det.stg_gbd_prodtyp),'x') <> nvl(trim(c_get_recon_det.ig_gbd_prodtyp),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_gbd_prodtyp;
         lv_stg_val     := c_get_recon_det.stg_gbd_prodtyp;
         lv_ig_val      := c_get_recon_det.ig_gbd_prodtyp;  

     elsif( c_get_attr.v_attrib_name = lv_policy_refund_gbi_instno
     and (nvl(trim(c_get_recon_det.src_gbi_instno),'x') <> nvl(trim(c_get_recon_det.stg_gbi_instno),'x') or nvl(trim(c_get_recon_det.stg_gbi_instno),'x') <> nvl(trim(c_get_recon_det.ig_gbi_instno),'x')))
     then

         lv_attrib_name := c_get_attr.v_attrib_name;
         lv_src_val     := c_get_recon_det.src_gbi_instno;
         lv_stg_val     := c_get_recon_det.stg_gbi_instno;
         lv_ig_val      := c_get_recon_det.ig_gbi_instno;  
         
         
    else

         null;
    end if;


  if lv_attrib_name is not null then
    insert into Jd1dta.dm_pol_billref_recon_det
    (v_batch_id,
    v_policy_no,
    v_prod_cde,
    v_pol_commdt,
    v_attrib_name,
    v_pol_status,
    v_module_name,
    v_eff_date,
    v_eff_desc,
    v_src_val,
    v_stg_val,
    v_ig_val,
    v_summary_batch_id,
    d_created_on,
    v_created_by,
    v_job_name)
    values
    (lv_batch_id,
    c_get_recon_det.v_pol_no,
    c_get_recon_det.v_prd_cde,
    c_get_recon_det.d_pol_start_dt,
    lv_attrib_name,
    c_get_recon_det.v_pol_status,
    lv_module_name,
    c_get_recon_det.src_eff_date,
    lv_eff_desc,
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id,
    sysdate,
    'JPALKQ',
    lv_prg);
  
      lv_attrib_name := null;-- resetting the value to null
  end if;
  
  end loop;



end loop;

Commit;

exception when others then
rollback;
insert_error_log (
              in_error_code     =>  lv_err_code
             ,in_error_message  =>  lv_err_msg
             ,in_prog           => lv_prg_name
             );

end;