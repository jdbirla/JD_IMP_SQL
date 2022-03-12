create or replace procedure dm_renewal_recon_set2(p_detail_batch_id  in Jd1dta.dm_pol_rnwl_det_recon_det.v_batch_id%type,
                                                  p_summary_batch_id in Jd1dta.dm_pol_rnwl_det_recon_det.v_summary_batch_id%type)
as


--p_detail_batch_id    varchar2(1000) := 'RECON_DET_001';
--p_summary_batch_id   varchar2(1000) := 'RECON_SUM_001';  

lv_attrib_name      Jd1dta.dm_data_validation_attrib.v_attrib_name%type;
lv_pol_attrb_des    Jd1dta.dm_data_validation_attrib.v_attrib_desc%type;
lv_src_val          Jd1dta.dm_pol_rnwl_det_recon_det.v_src_val%type;
lv_stg_val          Jd1dta.dm_pol_rnwl_det_recon_det.v_stg_val%type;
lv_ig_val           Jd1dta.dm_pol_rnwl_det_recon_det.v_ig_val%type;
lv_batch_id         Jd1dta.dm_pol_rnwl_det_recon_det.v_batch_id%type; 
lv_summary_batch_id Jd1dta.dm_pol_rnwl_det_recon_det.v_summary_batch_id%type;
lv_mod_name         Jd1dta.dm_pol_rnwl_det_recon_det.v_module_name%type := 'Renewal Determination';
 
lv_pol_rd_hfrmdt    constant varchar2(50) := 'POLICY_RD_HFRMDT';
lv_pol_rd_hhdtto    constant varchar2(50) := 'POLICY_RD_HDTTO';
lv_pol_rd_altcd     constant varchar2(50) := 'POLICY_RD_ALTCD';
lv_pol_rd_regdt     constant varchar2(50) := 'POLICY_RD_REGDT';
lv_pol_rd_appdt     constant varchar2(50) := 'POLICY_RD_APPDT';

lv_pol_rd_hmbrno    constant varchar2(50) := 'POLICY_RD_MBRNO';
lv_pol_rd_hinsrol   constant varchar2(50) := 'POLICY_RD_INSROL';
lv_pol_rd_htermflg  constant varchar2(50) := 'POLICY_RD_TRMFLG';
lv_pol_rd_hsalplan  constant varchar2(50) := 'POLICY_RD_SALPLN';
lv_pol_rd_hrsltcd   constant varchar2(50) := 'POLICY_RD_RSLTCD';
lv_pol_rd_hrnwage   constant varchar2(50) := 'POLICY_RD_RNWAGE';

lv_pol_rd_dmbrno    constant varchar2(50) := 'POLICY_RD_DTMBRNO'; 
lv_pol_rd_ddpno     constant varchar2(50) := 'POLICY_RD_DTDPNO';  
lv_pol_rd_dprdty    constant varchar2(50) := 'POLICY_RD_DTPRDTY'; 
lv_pol_rd_dsi       constant varchar2(50) := 'POLICY_RD_SUMINS';
lv_pol_rd_dprem     constant varchar2(50) := 'POLICY_RD_PREM';	
lv_pol_rd_dinstyp   constant varchar2(50) := 'POLICY_RD_INSTYP';  

lv_pol_rd_scbrno    constant varchar2(50) := 'POLICY_RD_SCMBRNO'; 
lv_pol_rd_scpno     constant varchar2(50) := 'POLICY_RD_SCDPNO';  
lv_pol_rd_scprd01   constant varchar2(50) := 'POLICY_RD_SCPRD01'; 
lv_pol_rd_scprd02   constant varchar2(50) := 'POLICY_RD_SCPRD02';
lv_pol_rd_scprem    constant varchar2(50) := 'POLICY_RD_SCPREM';	

lv_pol_rd_pvpol     constant varchar2(50) := 'POLICY_RD_PVPOL';	

lv_err_code      error_log.v_error_code%type;
lv_err_msg       error_log.v_error_message%type;
lv_prg_name      error_log.v_prog%type := 'dm_rnwdet_recon_set2';

begin

lv_batch_id         := p_detail_batch_id;
lv_summary_batch_id := p_summary_batch_id;

--- header reconciliation

for c_fetch_rd1 in (select distinct srd1.chdrnum chdrnum,
                           pol.v_prd_cde,
                           pol.d_pol_start_dt,
                           pol.v_pol_status,
                           srd1.zrndtfrm shrd_frmdt,
                           srd1.zrndtto  shrd_todt,
                           srd1.zaltrcde shrd_altcde,
                           srd1.zrndtreg shrd_regdt,
                           srd1.zrndtapp shrd_appdt,
                           tsrd1.zrndtfrm thrd_frmdt,
                           tsrd1.zrndtto  thrd_todt,
                           tsrd1.zaltrcde thrd_altcde,
                           tsrd1.zrndtreg thrd_regdt,
                           tsrd1.zrndtapp thrd_appdt,
                           igrd1.zrndtfrm ighrd_frmdt,
                           igrd1.zrndtto  ighrd_todt,
                           igrd1.zaltrcde ighrd_altcde,
                           igrd1.zrndtreg ighrd_regdt,
                           igrd1.zrndtapp ighrd_appdt       
                       
                    from stagedbusr2.dm_policy_recon@dmstagedblink pol,
                         Stagedbusr2.titdmgrnwdt1@dmstagedblink srd1,
                         Stagedbusr.titdmgrnwdt1@dmstagedblink tsrd1,
                         Jd1dta.Zrndthpf igrd1
                    where pol.v_policy_no = srd1.chdrnum
                    and  pol.v_policy_no = tsrd1.chdrnum (+)
                    and pol.v_policy_no = igrd1.chdrnum (+))
loop

--dbms_output.put_line('1--c_fetch_rd1.chdrnum '||c_fetch_rd1.chdrnum||'--'||c_fetch_rd1.ighrd_frmdt);

if (nvl(trim(c_fetch_rd1.shrd_frmdt),'0') <> nvl(trim(c_fetch_rd1.thrd_frmdt),'0') 
 or nvl(trim(c_fetch_rd1.thrd_frmdt),'0') <> nvl(trim(c_fetch_rd1.ighrd_frmdt),'0'))
then

    lv_src_val      := c_fetch_rd1.shrd_frmdt;
    lv_stg_val      := c_fetch_rd1.thrd_frmdt;
    lv_ig_val       := c_fetch_rd1.ighrd_frmdt;
    lv_attrib_name  := lv_pol_rd_hfrmdt;
   -- dbms_output.put_line('c_fetch_rd1.chdrnum '||c_fetch_rd1.chdrnum||'--'||c_fetch_rd1.ighrd_frmdt);

elsif (nvl(trim(c_fetch_rd1.shrd_todt),'0') <> nvl(trim(c_fetch_rd1.thrd_todt),'0') 
 or nvl(trim(c_fetch_rd1.thrd_todt),'0') <> nvl(trim(c_fetch_rd1.ighrd_todt),'0'))
then    

    lv_src_val      := c_fetch_rd1.shrd_todt;
    lv_stg_val      := c_fetch_rd1.thrd_todt;
    lv_ig_val       := c_fetch_rd1.ighrd_todt;
    lv_attrib_name  := lv_pol_rd_hhdtto;

elsif (nvl(trim(c_fetch_rd1.shrd_altcde),'0') <> nvl(trim(c_fetch_rd1.thrd_altcde),'0') 
 or nvl(trim(c_fetch_rd1.thrd_altcde),'0') <> nvl(trim(c_fetch_rd1.ighrd_altcde),'0'))
then    

    lv_src_val      := c_fetch_rd1.shrd_altcde;
    lv_stg_val      := c_fetch_rd1.thrd_altcde;
    lv_ig_val       := c_fetch_rd1.ighrd_altcde;
    lv_attrib_name  := lv_pol_rd_altcd;

elsif (nvl(trim(c_fetch_rd1.shrd_regdt),'0') <> nvl(trim(c_fetch_rd1.thrd_regdt),'0') 
 or nvl(trim(c_fetch_rd1.thrd_regdt),'0') <> nvl(trim(c_fetch_rd1.ighrd_regdt),'0'))
then    

    lv_src_val      := c_fetch_rd1.shrd_regdt;
    lv_stg_val      := c_fetch_rd1.thrd_regdt;
    lv_ig_val       := c_fetch_rd1.ighrd_regdt;
    lv_attrib_name  := lv_pol_rd_regdt;


elsif (nvl(trim(c_fetch_rd1.shrd_appdt),'0') <> nvl(trim(c_fetch_rd1.thrd_appdt),'0') 
 or nvl(trim(c_fetch_rd1.thrd_appdt),'0') <> nvl(trim(c_fetch_rd1.ighrd_appdt),'0'))
then    

    lv_src_val      := c_fetch_rd1.shrd_appdt;
    lv_stg_val      := c_fetch_rd1.thrd_appdt;
    lv_ig_val       := c_fetch_rd1.ighrd_appdt;
    lv_attrib_name  := lv_pol_rd_appdt;
    
   
--    open c_get_attrib_det(lv_pol_rd_hfrmdt);
 --   fetch c_get_attrib_det into lv_pol_attrb_des;
--    close c_get_attrib_det;

end if;

if lv_attrib_name is not null then

    insert into dm_pol_rnwl_det_recon_det
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
    c_fetch_rd1.chdrnum,
    c_fetch_rd1.v_prd_cde,
    c_fetch_rd1.d_pol_start_dt,
    lv_attrib_name,
    c_fetch_rd1.v_pol_status,
    lv_mod_name,
    c_fetch_rd1.shrd_regdt,
    'Renewal determination reg date',
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id ,
    sysdate,
    'JPALKQ',
    lv_prg_name
    );

lv_attrib_name := null;

end if;

end loop;


--- Detail detail reconciliation


for c_get_rd2 in (select  distinct srd1.chdrnum||'-'||srd1.Mbrno chdrnum,
                           pol.v_prd_cde v_prd_cde,
                           pol.d_pol_start_dt d_pol_start_dt,
                           pol.v_pol_status v_pol_status,
                           srd1.zrndtreg,
                           srd1.Input_Source_Table,
                           srd1.Mbrno src_mbrno,
                           trd1.Mbrno stg_mbrno,
                           igdpt.mbrno ig_mbrno,
                           srd1.zinsrole src_insrole,
                           trd1.zinsrole stg_insrole,
                           igdpt.zinsrole ig_insrole,
                           srd1.ztermflg src_termflg,
                           trd1.ztermflg stg_termflg,
                           igdpt.ztermflg ig_termflg,
                           srd1.zsalplan src_sp,
                           trd1.zsalplan stg_sp,
                           igdpt.zsalplan ig_sp,
                           srd1.zrndtrcd src_rcd,
                           trd1.zrndtrcd stg_rcd,
                           igdpt.zrndtrcd ig_rcd,
                           srd1.zinsrnwage src_rnwage,
                           trd1.zinsrnwage stg_rnwage,
                           igdpt.zinsrnwage ig_rnwage
                    from stagedbusr2.dm_policy_recon@dmstagedblink pol,
                         Stagedbusr2.titdmgrnwdt1@dmstagedblink srd1,
                         Stagedbusr.titdmgrnwdt1@dmstagedblink trd1,
                         Jd1dta.zrndtdpf igdpt
                    where pol.v_policy_no = srd1.chdrnum
                    and  pol.v_policy_no = trd1.chdrnum (+) 
                    and srd1.mbrno = trd1.mbrno(+)
                    and pol.v_policy_no = igdpt.chdrnum (+)
                    and srd1.mbrno = igdpt.mbrno(+))
loop

if (nvl(trim(c_get_rd2.src_mbrno),'0') <> nvl(trim(c_get_rd2.stg_mbrno),'0') 
 or nvl(trim(c_get_rd2.stg_mbrno),'0') <> nvl(trim(c_get_rd2.ig_mbrno),'0'))
then

    lv_src_val      := c_get_rd2.src_mbrno;
    lv_stg_val      := c_get_rd2.stg_mbrno;
    lv_ig_val       := c_get_rd2.ig_mbrno;
    lv_attrib_name  := lv_pol_rd_hmbrno;

elsif (nvl(trim(c_get_rd2.src_insrole),'0') <> nvl(trim(c_get_rd2.stg_insrole),'0') 
 or nvl(trim(c_get_rd2.stg_insrole),'0') <> nvl(trim(c_get_rd2.ig_insrole),'0'))
then

    lv_src_val      := c_get_rd2.src_insrole;
    lv_stg_val      := c_get_rd2.stg_insrole;
    lv_ig_val       := c_get_rd2.ig_insrole;
    lv_attrib_name  := lv_pol_rd_hinsrol;
    
elsif (nvl(trim(c_get_rd2.src_termflg),'0') <> nvl(trim(c_get_rd2.stg_termflg),'0') 
 or nvl(trim(c_get_rd2.stg_termflg),'0') <> nvl(trim(c_get_rd2.ig_termflg),'0'))
then

    lv_src_val      := c_get_rd2.src_termflg;
    lv_stg_val      := c_get_rd2.stg_termflg;
    lv_ig_val       := c_get_rd2.ig_termflg;
    lv_attrib_name  := lv_pol_rd_htermflg;    

elsif (nvl(c_get_rd2.src_sp,'0') <> nvl(c_get_rd2.stg_sp,'0') 
 or nvl(c_get_rd2.stg_sp,'0') <> nvl(c_get_rd2.ig_termflg,'0'))
 and c_get_rd2.Input_Source_Table <> 'ASRF_RNW_DTRM'
then
--- For sales plan removed the trim because it can have space as a value from source

    lv_src_val      := c_get_rd2.src_sp;
    lv_stg_val      := c_get_rd2.stg_sp;
    lv_ig_val       := c_get_rd2.ig_termflg;
    lv_attrib_name  := lv_pol_rd_hsalplan;  

elsif (nvl(trim(c_get_rd2.src_rcd),'0') <> nvl(trim(c_get_rd2.stg_rcd),'0') 
 or nvl(trim(c_get_rd2.stg_rcd),'0') <> nvl(trim(c_get_rd2.ig_rcd),'0'))
then


    lv_src_val      := c_get_rd2.src_rcd;
    lv_stg_val      := c_get_rd2.stg_rcd;
    lv_ig_val       := c_get_rd2.ig_rcd;
    lv_attrib_name  := lv_pol_rd_hrsltcd; 

elsif (nvl(trim(c_get_rd2.src_rnwage),'0') <> nvl(trim(c_get_rd2.stg_rnwage),'0') 
 or nvl(trim(c_get_rd2.stg_rnwage),'0') <> nvl(trim(c_get_rd2.ig_rnwage),'0'))
then


    lv_src_val      := c_get_rd2.src_rnwage;
    lv_stg_val      := c_get_rd2.stg_rnwage;
    lv_ig_val       := c_get_rd2.ig_rnwage;
    lv_attrib_name  := lv_pol_rd_hrnwage; 
    
end if;


if lv_attrib_name is not null then

  insert into dm_pol_rnwl_det_recon_det
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
    c_get_rd2.chdrnum,
    c_get_rd2.v_prd_cde,
    c_get_rd2.d_pol_start_dt,
    lv_attrib_name,
    c_get_rd2.v_pol_status,
    lv_mod_name,
    c_get_rd2.zrndtreg,
    'Renewal determination reg date',
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id ,
    sysdate,
    'JPALKQ',
    lv_prg_name
    );


lv_attrib_name := null;

end if;

end loop;


--- Coverage reconciliation

for c_get_rdt2 in (select distinct srdt2.chdrnum||'-'||srdt2.Mbrno||'-'||srdt2.dpntno chdrnum,
                           pol.v_prd_cde,
                           pol.d_pol_start_dt,
                           pol.v_pol_status,
                           srd1.zrndtreg,
                           srdt2.Mbrno src_mbrno,
                           trdt2.mbrno stg_mbrno,
                           igrdt2.mbrno ig_mbrno,
                           srdt2.dpntno src_dpno,
                           trdt2.dpntno stg_dpno,
                           igrdt2.dpntno ig_dpno,
                           srdt2.prodtyp src_prdtyp,
                           trdt2.prodtyp stg_prdtyp,
                           igrdt2.prodtyp ig_prdtyp,
                           srdt2.sumins src_sumins,
                           trdt2.sumins stg_sumins,
                           igrdt2.sumins ig_sumins,
                           srdt2.dprem src_dprem,
                           trdt2.dprem stg_dprem,
                           igrdt2.dprem ig_dprem,
                           srdt2.Zinstype src_Zinstype,
                           trdt2.Zinstype stg_Zinstype,
                           igrdt2.Zinstype ig_Zinstype
                    from stagedbusr2.dm_policy_recon@dmstagedblink pol,
                         Stagedbusr2.titdmgrnwdt1@dmstagedblink srd1,
                         Stagedbusr2.titdmgrnwdt2@dmstagedblink srdt2,
                         Stagedbusr.titdmgrnwdt2@dmstagedblink trdt2,
                         Jd1dta.zrndtcovpf igrdt2
                    where pol.v_policy_no = srdt2.chdrnum
                    and srd1.chdrnum = srdt2.chdrnum
                    and srd1.mbrno = srdt2.mbrno
                    and  pol.v_policy_no = trdt2.chdrnum (+)
                    and srdt2.mbrno = trdt2.mbrno(+)
                    and pol.v_policy_no = igrdt2.chdrnum (+)
                    and srdt2.mbrno = igrdt2.mbrno(+)  
                    and srdt2.prodtyp = trdt2.prodtyp (+)
                    and srdt2.prodtyp = igrdt2.prodtyp (+))
loop

if (nvl(trim(c_get_rdt2.src_mbrno),'0') <> nvl(trim(c_get_rdt2.stg_mbrno),'0') 
 or nvl(trim(c_get_rdt2.stg_mbrno),'0') <> nvl(trim(c_get_rdt2.ig_mbrno),'0'))
then

    lv_src_val      := c_get_rdt2.src_mbrno;
    lv_stg_val      := c_get_rdt2.stg_mbrno;
    lv_ig_val       := c_get_rdt2.ig_mbrno;
    lv_attrib_name  := lv_pol_rd_dmbrno;

elsif (nvl(trim(c_get_rdt2.src_dpno),'0') <> nvl(trim(c_get_rdt2.stg_dpno),'0') 
 or nvl(trim(c_get_rdt2.stg_dpno),'0') <> nvl(trim(c_get_rdt2.ig_dpno),'0'))    
then

    lv_src_val      := c_get_rdt2.src_dpno;
    lv_stg_val      := c_get_rdt2.stg_dpno;
    lv_ig_val       := c_get_rdt2.ig_dpno;
    lv_attrib_name  := lv_pol_rd_ddpno;

elsif (nvl(trim(c_get_rdt2.src_prdtyp),'0') <> nvl(trim(c_get_rdt2.stg_prdtyp),'0') 
 or nvl(trim(c_get_rdt2.stg_prdtyp),'0') <> nvl(trim(c_get_rdt2.ig_prdtyp),'0'))    
then

    lv_src_val      := c_get_rdt2.src_prdtyp;
    lv_stg_val      := c_get_rdt2.stg_prdtyp;
    lv_ig_val       := c_get_rdt2.ig_prdtyp;
    lv_attrib_name  := lv_pol_rd_dprdty;
    

elsif (nvl(trim(c_get_rdt2.src_sumins),'0') <> nvl(trim(c_get_rdt2.stg_sumins),'0') 
 or nvl(trim(c_get_rdt2.stg_sumins),'0') <> nvl(trim(c_get_rdt2.ig_sumins),'0'))    
then

    lv_src_val      := c_get_rdt2.src_sumins;
    lv_stg_val      := c_get_rdt2.stg_sumins;
    lv_ig_val       := c_get_rdt2.ig_sumins;
    lv_attrib_name  := lv_pol_rd_dsi;
    

elsif (nvl(trim(c_get_rdt2.src_dprem),'0') <> nvl(trim(c_get_rdt2.stg_dprem),'0') 
 or nvl(trim(c_get_rdt2.stg_dprem),'0') <> nvl(trim(c_get_rdt2.ig_dprem),'0'))    
then

    lv_src_val      := c_get_rdt2.src_dprem;
    lv_stg_val      := c_get_rdt2.stg_dprem;
    lv_ig_val       := c_get_rdt2.ig_dprem;
    lv_attrib_name  := lv_pol_rd_dprem;
    
    
elsif (nvl(trim(c_get_rdt2.src_Zinstype),'0') <> nvl(trim(c_get_rdt2.stg_Zinstype),'0') 
 or nvl(trim(c_get_rdt2.stg_Zinstype),'0') <> nvl(trim(c_get_rdt2.ig_Zinstype),'0'))    
then

    lv_src_val      := c_get_rdt2.src_Zinstype;
    lv_stg_val      := c_get_rdt2.stg_Zinstype;
    lv_ig_val       := c_get_rdt2.ig_Zinstype;
    lv_attrib_name  := lv_pol_rd_dinstyp; 
    
end if;

if lv_attrib_name is not null then

  insert into dm_pol_rnwl_det_recon_det
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
    c_get_rdt2.chdrnum,
    c_get_rdt2.v_prd_cde,
    c_get_rdt2.d_pol_start_dt,
    lv_attrib_name,
    c_get_rdt2.v_pol_status,
    lv_mod_name,
    c_get_rdt2.zrndtreg,
    'Renewal determination reg date',
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id ,
    sysdate,
    'JPALKQ',
    lv_prg_name
    );


lv_attrib_name := null;

end if;

end loop;


--- Sub coverage


for c_get_scrd in (select distinct scrd2.chdrnum||'-'||scrd2.Mbrno||'-'||scrd2.dpntno chdrnum,
                                 pol.v_prd_cde,
                                 pol.d_pol_start_dt,
                                 pol.v_pol_status,
                                 scrd.zrndtreg,
                                 scrd2.Mbrno src_mbrno,
                                 tcrd2.mbrno stg_mbrno,
                                 igcrd.mbrno ig_mbrno,
                                 scrd2.dpntno src_dpno,
                                 tcrd2.dpntno stg_dpno,
                                 igcrd.dpntno ig_dpno,
                                 scrd2.prodtyp src_prodtyp,
                                 tcrd2.prodtyp stg_prodtyp,
                                 igcrd.prodtyp01 ig_prodtyp,
                                 scrd2.prodtyp02 src_prodtyp02,
                                 tcrd2.prodtyp02 stg_prodtyp02,
                                 igcrd.prodtyp02 ig_prodtyp02,
                                 scrd2.ndr_dprem src_ndrprem,
                                 tcrd2.ndr_dprem stg_ndrprem,
                                 igcrd.dprem ig_ndrprem
                          from stagedbusr2.dm_policy_recon@dmstagedblink pol,
                               Stagedbusr2.titdmgrnwdt1@dmstagedblink scrd,
                               Stagedbusr2.titdmgrnwdt2@dmstagedblink scrd2,
                               Stagedbusr.titdmgrnwdt2@dmstagedblink tcrd2,
                               Jd1dta.zrndtsubcovpf igcrd
                          where pol.v_policy_no = scrd.chdrnum  
                          and scrd2.chdrnum = scrd.chdrnum
                          and scrd2.mbrno = scrd.mbrno
                          and pol.v_policy_no = tcrd2.chdrnum (+)
                          and scrd2.mbrno = tcrd2.mbrno(+)
                          and pol.v_policy_no = igcrd.chdrnum (+)
                          and scrd2.mbrno = igcrd.mbrno(+)  
                          and scrd2.prodtyp = tcrd2.prodtyp (+)
                          and scrd2.prodtyp = igcrd.prodtyp01 (+)
                          and scrd2.prodtyp02 = tcrd2.prodtyp02 (+)
                          and scrd2.prodtyp02 = igcrd.prodtyp02 (+)
                          and scrd2.ndr_dprem > 0)
loop


if (nvl(trim(c_get_scrd.src_mbrno),'0') <> nvl(trim(c_get_scrd.stg_mbrno),'0') 
 or nvl(trim(c_get_scrd.stg_mbrno),'0') <> nvl(trim(c_get_scrd.ig_mbrno),'0'))
then

    lv_src_val      := c_get_scrd.src_mbrno;
    lv_stg_val      := c_get_scrd.stg_mbrno;
    lv_ig_val       := c_get_scrd.ig_mbrno;
    lv_attrib_name  := lv_pol_rd_scbrno;
    
elsif (nvl(trim(c_get_scrd.src_dpno),'0') <> nvl(trim(c_get_scrd.stg_dpno),'0') 
 or nvl(trim(c_get_scrd.stg_dpno),'0') <> nvl(trim(c_get_scrd.ig_dpno),'0'))
then

    lv_src_val      := c_get_scrd.src_dpno;
    lv_stg_val      := c_get_scrd.stg_dpno;
    lv_ig_val       := c_get_scrd.ig_dpno;
    lv_attrib_name  := lv_pol_rd_scpno;

elsif (nvl(trim(c_get_scrd.src_prodtyp),'0') <> nvl(trim(c_get_scrd.stg_prodtyp),'0') 
 or nvl(trim(c_get_scrd.stg_prodtyp),'0') <> nvl(trim(c_get_scrd.ig_prodtyp),'0'))
then

    lv_src_val      := c_get_scrd.src_prodtyp;
    lv_stg_val      := c_get_scrd.stg_prodtyp;
    lv_ig_val       := c_get_scrd.ig_prodtyp;
    lv_attrib_name  := lv_pol_rd_scprd01;

elsif (nvl(trim(c_get_scrd.src_prodtyp02),'0') <> nvl(trim(c_get_scrd.stg_prodtyp02),'0') 
 or nvl(trim(c_get_scrd.stg_prodtyp02),'0') <> nvl(trim(c_get_scrd.ig_prodtyp02),'0'))
then

    lv_src_val      := c_get_scrd.src_prodtyp02;
    lv_stg_val      := c_get_scrd.stg_prodtyp02;
    lv_ig_val       := c_get_scrd.ig_prodtyp02;
    lv_attrib_name  := lv_pol_rd_scprd02;

elsif (nvl(trim(c_get_scrd.src_ndrprem),'0') <> nvl(trim(c_get_scrd.stg_ndrprem),'0') 
 or nvl(trim(c_get_scrd.stg_ndrprem),'0') <> nvl(trim(c_get_scrd.ig_ndrprem),'0'))
then

    lv_src_val      := c_get_scrd.src_ndrprem;
    lv_stg_val      := c_get_scrd.stg_ndrprem;
    lv_ig_val       := c_get_scrd.ig_ndrprem;
    lv_attrib_name  := lv_pol_rd_scprem;
    
end if;


if lv_attrib_name is not null then

  insert into dm_pol_rnwl_det_recon_det
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
    c_get_scrd.chdrnum,
    c_get_scrd.v_prd_cde,
    c_get_scrd.d_pol_start_dt,
    lv_attrib_name,
    c_get_scrd.v_pol_status,
    lv_mod_name,
    c_get_scrd.zrndtreg,
    'Renewal determination reg date',
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id ,
    sysdate,
    'JPALKQ',
    lv_prg_name
    );


lv_attrib_name := null;

end if;

end loop;

---- premium version


for c_get_pv in (select  distinct sprd2.chdrnum chdrnum,
                           pol.v_prd_cde,
                           pol.d_pol_start_dt,
                           pol.v_pol_status,
                           sprd.zrndtreg,
                           sprd2.chdrnum src_chdrnum,
                           sprd2.chdrnum stg_chdrnum,
                           ig_prd.chdrnum ig_chdrnum
                    from  stagedbusr2.dm_policy_recon@dmstagedblink pol,
                         Stagedbusr2.titdmgrnwdt1@dmstagedblink sprd,
                         Stagedbusr2.titdmgrnwdt2@dmstagedblink sprd2,
                         Stagedbusr.titdmgrnwdt2@dmstagedblink tprd2,
                         Jd1dta.Zodmprmverpf ig_prd
                    where   pol.v_policy_no = sprd.chdrnum  
                    and sprd2.chdrnum = sprd.chdrnum
                    and sprd2.mbrno = sprd.mbrno   
                    and pol.v_policy_no = tprd2.chdrnum (+)
                    and sprd2.mbrno = tprd2.mbrno(+)
                    and sprd2.zinstype = tprd2.zinstype (+)
                    and pol.v_policy_no = ig_prd.chdrnum (+)
                    and sprd2.zinstype = ig_prd.zinstype (+))
loop

if (nvl(trim(c_get_pv.src_chdrnum),'0') <> nvl(trim(c_get_pv.stg_chdrnum),'0') 
 or nvl(trim(c_get_pv.stg_chdrnum),'0') <> nvl(trim(c_get_pv.ig_chdrnum),'0'))
then

    lv_src_val      := c_get_pv.src_chdrnum;
    lv_stg_val      := c_get_pv.stg_chdrnum;
    lv_ig_val       := c_get_pv.ig_chdrnum;
    lv_attrib_name  := lv_pol_rd_pvpol;
    
end if;

if lv_attrib_name is not null then

  insert into dm_pol_rnwl_det_recon_det
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
    c_get_pv.chdrnum,
    c_get_pv.v_prd_cde,
    c_get_pv.d_pol_start_dt,
    lv_attrib_name,
    c_get_pv.v_pol_status,
    lv_mod_name,
    c_get_pv.zrndtreg,
    'Renewal determination reg date',
    lv_src_val,
    lv_stg_val,
    lv_ig_val,
    lv_summary_batch_id ,
    sysdate,
    'JPALKQ',
    lv_prg_name
    );


lv_attrib_name := null;

end if;




end loop;


commit;

exception when others then

rollback;
insert_error_log (
              in_error_code     =>  lv_err_code
             ,in_error_message  =>  lv_err_msg
             ,in_prog           => lv_prg_name
             );

commit;



end;