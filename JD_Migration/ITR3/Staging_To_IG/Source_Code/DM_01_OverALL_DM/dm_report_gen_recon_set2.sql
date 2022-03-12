create or replace procedure dm_report_gen_recon_set2(p_det_batch_id dm_dv_recon_detail.v_batch_id%type,
                                                     p_summary_batch_id dm_dv_recon_detail.v_summary_batch_id%type)
as





-- local cursor declaration


cursor c_get_attrib(p_summary_batch_id varchar2)
is
select distinct p_summary_batch_id as v_summary_batch_id,
       b.v_module_name as v_module_name,
       b.v_attrib_name as v_attrib_name,
       (select count(distinct(substr(v_policy_no,1,8))) 
        from dm_dv_recon_detail s
        where nvl(s.v_src_val,'x') <> nvl(s.v_stg_val,'x')
        and s.v_attrib_name = b.v_attrib_name
        and s.v_module_name = b.v_module_name) v_src_stg_mismatch,
       (select count(distinct(substr(v_policy_no,1,8))) 
       from dm_dv_recon_detail s
        where nvl(s.v_stg_val,'x') <> nvl(s.v_ig_val,'x')
        and s.v_attrib_name = b.v_attrib_name
        and s.v_module_name = b.v_module_name) v_stg_ig_mismatch 
from dm_data_validation_attrib b left outer join
dm_dv_recon_detail a 
on a.v_attrib_name = b.v_attrib_name
and a.v_module_name = b.v_module_name
order by b.v_module_name;

-- Type declaration

obj_dm_recon_summary Jd1dta.dm_dv_recon_summary%rowtype;

--- local variable declaration 
--p_det_batch_id varchar2(100) := 'RECON_DET_001';
P_oracledir varchar2(50) := 'ORACLE_BASE';
P_detail_excelname varchar2(30) := 'Recon_Set2_Detail_Report.xlsx';
p_sql VARCHAR2(4000); --:= 'select  v_batch_id , v_policy_no , v_prod_cde, v_pol_commdt ,v_pol_status , v_eff_date , v_eff_desc as "Effective Date Description", v_module_name ,v_attrib_name ,  v_src_val, v_stg_val , v_ig_val , v_summary_batch_id  from Jd1dta.dm_pol_billref_recon_det  Where v_batch_id = ''RECON_DET_001''';  
p_column_headers boolean := TRUE;

lv_date           date;
lv_created_by     varchar2(15) := 'JPALKQ';
lv_det_job_name       varchar2(20) := 'dm_dv_recon_det';
--p_summary_batch_id varchar2(100) := 'RECON_SUM_001';
P_summary_excelname varchar2(30) := 'Recon_Set2_Summary_Report.xlsx';

lv_Billing_refund     dm_data_validation_attrib.v_module_name%type := 'Billing refund';
lv_collres            dm_data_validation_attrib.v_module_name%type := 'Collection Result';
lv_master_pol         dm_data_validation_attrib.v_module_name%type := 'Master Policy';
lv_Billing_Instalment dm_data_validation_attrib.v_module_name%type := 'Billing Instalment';
lv_Policy_Dishonor    dm_data_validation_attrib.v_module_name%type := 'Policy Dishonor'; 
lv_mem_ind_pol        dm_data_validation_attrib.v_module_name%type := 'Member and Individual Policy'; 
lv_mem_ind_pol_his    dm_data_validation_attrib.v_module_name%type := 'Member and Individual Policy History'; 
lv_client_bank        dm_data_validation_attrib.v_module_name%type := 'client bank';
lv_renewal_det        dm_data_validation_attrib.v_module_name%type := 'Renewal Determination';

lv_src_pol_cnt      dm_dv_recon_summary.n_src_pol_cnt%type;
lv_stg_pol_cnt      dm_dv_recon_summary.n_src_pol_cnt%type;
lv_ig_pol_cnt       dm_dv_recon_summary.n_src_pol_cnt%type;


lv_err_code      error_log.v_error_code%type;
lv_err_msg       error_log.v_error_message%type;
lv_prg_name      error_log.v_prog%type := 'dm_report_gen_recon_set2';

begin

lv_date:= sysdate;


insert into dm_dv_recon_detail 
(v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, d_created_on, v_created_by, v_job_name)
(
select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, d_created_on, v_created_by, v_job_name
from
      (select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_billinst_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_mem_ind_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_master_pol_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_pol_dishnr_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_pol_collres_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_pol_mihis_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_pol_billref_recon_det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from Dm_Client_Bank_Recon_Det
      union all
      select v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_attrib_name, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, sysdate d_created_on, 'JPALKQ' v_created_by, 'dm_dv_recon_det'  v_job_name
      from dm_pol_rnwl_det_recon_det
      )
);
-- Dm_Client_Bank_Recon_Det


p_sql := 'select  v_batch_id , v_policy_no , v_prod_cde, v_pol_commdt ,v_pol_status , v_eff_date , v_eff_desc , v_module_name ,v_attrib_name ,  v_src_val, v_stg_val , v_ig_val , v_summary_batch_id  from Jd1dta.dm_dv_recon_detail  Where v_batch_id = '''||p_det_batch_id ||''' order by v_batch_id,v_module_name';


pkg_write_xlsx.query2sheetrecon2(p_sql, p_det_batch_id,p_column_headers,P_oracledir,P_detail_excelname,null);

dbms_output.put_line('Det Success');


for c_fetch_attrib in c_get_attrib(p_summary_batch_id) 
loop

        obj_dm_recon_summary.v_batch_id     := c_fetch_attrib.v_summary_batch_id;
        obj_dm_recon_summary.v_module_name  := c_fetch_attrib.v_module_name;
        obj_dm_recon_summary.v_attrib_name  := c_fetch_attrib.v_attrib_name;
        
   if c_fetch_attrib.v_module_name = lv_Billing_refund then 
    
        select count(distinct(chdrnum)) into 
                lv_src_pol_cnt
        from Stagedbusr2.titdmgref1@dmstagedblink a,
             stagedbusr2.dm_policy_recon@dmstagedblink  b
        where trim(a.chdrnum) = trim(b.v_policy_no);
        
        select count(distinct(chdrnum)) into 
                lv_stg_pol_cnt
        from Stagedbusr.titdmgref1@dmstagedblink a,
             stagedbusr2.dm_policy_recon@dmstagedblink  b
        where trim(a.chdrnum) = trim(b.v_policy_no);
        
        select count(distinct(chdrnum)) into 
                lv_ig_pol_cnt
        from Jd1dta.zreppf a,
             stagedbusr2.dm_policy_recon@dmstagedblink  b
        where trim(a.chdrnum) = trim(b.v_policy_no);
    
        obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
        obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
        obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;
        
    elsif c_fetch_attrib.v_module_name = lv_collres then
      
          select Count(distinct(a.chdrnum))
          into lv_src_pol_cnt
          from stagedbusr2.pj_titdmgcolres@dmstagedblink a, 
               stagedbusr2.dm_policy_recon@dmstagedblink b
          where trim(a.chdrnum) = trim(b.v_policy_no);

          select count(distinct(a.chdrnum))  
           into   lv_stg_pol_cnt
          from stagedbusr.titdmgcolres@dmstagedblink a,
          stagedbusr2.dm_policy_recon@dmstagedblink b
          where trim(a.chdrnum) = trim(b.v_policy_no);
          
          select count(distinct(a.chdrnum))  
            into   lv_ig_pol_cnt
          from Jd1dta.zcrhpf a, 
          stagedbusr2.dm_policy_recon@dmstagedblink b
          where trim(a.chdrnum) = trim(b.v_policy_no);
          
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;         

    elsif c_fetch_attrib.v_module_name = lv_master_pol then
    
            select count(distinct(Src.Chdrnum))
            into lv_src_pol_cnt
            from stagedbusr2.titdmgmaspol@dmstagedblink Src,
            stagedbusr2.DM_POLICY_RECON@dmstagedblink rec
            Where Trim(Src.Chdrnum) = Trim(Rec.V_Policy_No)
            And  Trim(Src.Ccdate)  = Trim(Rec.D_Pol_Start_Dt)
            And  Trim(Src.Crdate)  = Trim(Rec.D_Pol_End_Dt);      

            select count(distinct(Src.Chdrnum)) 
            into lv_stg_pol_cnt
            from stagedbusr.titdmgmaspol@dmstagedblink Src,
            stagedbusr2.DM_POLICY_RECON@dmstagedblink rec
            Where Trim(Src.Chdrnum) = Trim(Rec.V_Policy_No)
            And  Trim(Src.Ccdate)  = Trim(Rec.D_Pol_Start_Dt)
            And  Trim(Src.Crdate)  = Trim(Rec.D_Pol_End_Dt);

            select count(distinct(Src.Chdrnum)) 
            into lv_ig_pol_cnt
            from Jd1dta.ZTGMPF Src,
            stagedbusr2.DM_POLICY_RECON@dmstagedblink rec
            Where Trim(Src.Chdrnum) = Trim(Rec.V_Policy_No);
      
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt; 
    
    elsif c_fetch_attrib.v_module_name = lv_Billing_Instalment then        
        
        select count(distinct(a.chdrnum))
        into lv_src_pol_cnt
        from stagedbusr2.titdmgbill1@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b 
        where trim(a.chdrnum) = trim(b.v_policy_no);
        
        select count(distinct(a.chdrnum))
        into lv_stg_pol_cnt
        from stagedbusr.titdmgbill1@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b 
        where trim(a.chdrnum) = trim(b.v_policy_no);       
        
        select count(distinct(a.chdrnum))
        into lv_ig_pol_cnt
        from Jd1dta.gbihpf a,
        stagedbusr2.dm_policy_recon@dmstagedblink b 
        where trim(a.chdrnum) = trim(b.v_policy_no);      
    
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;   
      
    elsif c_fetch_attrib.v_module_name = lv_Policy_Dishonor then   
      
        select count(distinct(trim(a.oldpolnum)))
        into lv_src_pol_cnt
        from stagedbusr2.titdmgmbrindp3@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b
        where trim(a.oldpolnum) = trim(b.v_policy_no);
        
        select count(distinct(b.v_policy_no))
        into lv_stg_pol_cnt
        from stagedbusr.titdmgmbrindp1@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b,
        stagedbusr2.titdmgmbrindp3@dmstagedblink c
        where  trim(c.oldpolnum) = trim(b.v_policy_no)
        and trim(substr(A.refnum,1,8)) = trim(b.v_policy_no);
        
        
        select count(distinct(a.zprvchdr))
        into lv_ig_pol_cnt
        from Jd1dta.Gchd  a,
        stagedbusr2.dm_policy_recon@dmstagedblink b,
        stagedbusr2.titdmgmbrindp3@dmstagedblink c
        where trim(zprvchdr ) = trim(b.v_policy_no)
        and  trim(c.oldpolnum) = trim(b.v_policy_no);    
      
      
      
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt; 

    elsif c_fetch_attrib.v_module_name = lv_mem_ind_pol_his then   
      
         select count(distinct(chdrnum))
         into lv_src_pol_cnt
        from stagedbusr.titdmgpoltrnh@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b
        where trim(chdrnum) =  trim(b.v_policy_no); 
  
        select count(distinct(chdrnum)) 
        into lv_stg_pol_cnt
        from ztrapf a,
        stagedbusr2.dm_policy_recon@dmstagedblink b
        where trim(chdrnum) =  trim(b.v_policy_no);  
      
        select count(distinct chdrnum)
        into lv_ig_pol_cnt
        from Jd1dta.ztrapf 
        where jobnm = 'G1ZDPOLHST';     
      
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;   
      
    elsif c_fetch_attrib.v_module_name = lv_mem_ind_pol then  
 
        select count(distinct(v_policy_no)) 
        into lv_src_pol_cnt
        from stagedbusr2.dm_policy_recon@dmstagedblink 
        where v_pol_type = 'IND_MEMBER'; 
              
        select count(distinct(b.v_policy_no))
        into lv_stg_pol_cnt
        from stagedbusr.titdmgmbrindp1@dmstagedblink a,
        stagedbusr2.dm_policy_recon@dmstagedblink b
        where trim(substr(A.refnum,1,8)) = trim(b.v_policy_no);
        
        select count(distinct(b.v_policy_no))
        into lv_ig_pol_cnt
        from Jd1dta.gchipf a,
        stagedbusr2.dm_policy_recon@dmstagedblink b
        where trim(substr(A.CHDRNUM,1,8)) = trim(b.v_policy_no)
        and JOBNM = 'G1ZDMBRIND';       
 
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;  
      
     
    elsif c_fetch_attrib.v_module_name = lv_client_bank then  

      select count(distinct(substr(refnum,1,8))) 
      into lv_src_pol_cnt
      from stagedbusr2.titdmgclntbank@dmstagedblink;
      
      --STAGING
      select count(distinct(substr(refnum,1,8))) 
      into lv_stg_pol_cnt
      from stagedbusr.titdmgclntbank@dmstagedblink;
      
      --IG
      Select Count(Distinct(Substr(Paz.Zentity,1,8)))
       into lv_ig_pol_cnt
      From Jd1dta.Clbapf Clba 
      Inner Join Jd1dta.Pazdclpf Paz
      On Clba.Clntnum = Paz.Zigvalue
      Inner Join Stagedbusr2.Dm_Policy_Recon@dmstagedblink Polrec
      On Polrec.V_Policy_No = Substr(Paz.Zentity,1,8);


      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;  
      
     elsif c_fetch_attrib.v_module_name = lv_renewal_det then 

        select count(distinct(substr(chdrnum,1,8))) 
        into lv_src_pol_cnt
        from stagedbusr2.titdmgrnwdt1@dmstagedblink;

        select count(distinct(substr(chdrnum,1,8))) 
        into lv_stg_pol_cnt
        from stagedbusr.titdmgrnwdt1@dmstagedblink;
        
        
        select count(distinct(chdrnum))
        into lv_ig_pol_cnt
        from Zrndthpf
        where jobnm = 'G1ZDRNWDTM';
 
      obj_dm_recon_summary.n_src_pol_cnt  := lv_src_pol_cnt;
      obj_dm_recon_summary.n_stg_pol_cnt  := lv_stg_pol_cnt;
      obj_dm_recon_summary.n_ig_pol_cnt   := lv_ig_pol_cnt;  
      
    end if;
 
             
    
        obj_dm_recon_summary.n_src_stg_mis  := c_fetch_attrib.v_src_stg_mismatch;
        obj_dm_recon_summary.n_stg_ig_mis   := c_fetch_attrib.v_stg_ig_mismatch;
        obj_dm_recon_summary.d_created_on   := sysdate;
        obj_dm_recon_summary.v_created_by   := 'JPALKQ';
        obj_dm_recon_summary.v_job_name     := 'dm_dv_recon_sum';
        
insert into dm_dv_recon_summary
(v_batch_id,v_module_name,v_attrib_name,n_src_pol_cnt,n_stg_pol_cnt,n_ig_pol_cnt,n_src_stg_mis,n_stg_ig_mis,d_created_on,v_created_by,v_job_name)
values
(obj_dm_recon_summary.v_batch_id,obj_dm_recon_summary.v_module_name,obj_dm_recon_summary.v_attrib_name,obj_dm_recon_summary.n_src_pol_cnt,obj_dm_recon_summary.n_stg_pol_cnt,obj_dm_recon_summary.n_ig_pol_cnt,obj_dm_recon_summary.n_src_stg_mis,obj_dm_recon_summary.n_stg_ig_mis,obj_dm_recon_summary.d_created_on,obj_dm_recon_summary.v_created_by,obj_dm_recon_summary.v_job_name);

end loop;



p_sql := 'select v_batch_id,v_module_name,v_attrib_name,n_src_pol_cnt,n_stg_pol_cnt,n_src_stg_mis,n_stg_pol_cnt,n_ig_pol_cnt,n_stg_ig_mis from Jd1dta.dm_dv_recon_summary where v_batch_id = '''||p_summary_batch_id||''' order by v_batch_id,v_module_name';


pkg_write_xlsx.query2sheetrecon2(p_sql, p_summary_batch_id,p_column_headers,P_oracledir,P_summary_excelname,null);

dbms_output.put_line('Summary Success');
commit;



exception when others then
rollback;
insert_error_log (
              in_error_code     =>  lv_err_code
             ,in_error_message  =>  lv_err_msg
             ,in_prog           =>  lv_prg_name
             );

end;
/
