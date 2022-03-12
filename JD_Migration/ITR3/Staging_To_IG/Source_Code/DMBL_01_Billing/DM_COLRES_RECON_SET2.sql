create or replace PROCEDURE Jd1dta.DM_COLRES_RECON_SET2(p_detail_batch_id IN VARCHAR2,
                                                        p_summary_batch_id IN VARCHAR2) 
AS
  /*
  **************************************************************************************************
  * Amendment History: Collection Result Reconcillation set 2
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * FEB12	  CHO          PA ITR3 Implementation for Reconciliation Set 2 task
  **************************************************************************************************
  */
  v_prog_name    VARCHAR2(50)    := 'RECON_2_CR_G1ZDCOLRES';
  v_crtd_by      VARCHAR2(20)    := 'JPAFSN';
  v_job_name     VARCHAR(50)     := 'DM_COLRES_RECON_SET2';
  v_module_name  VARCHAR2(40)    := 'Collection Result';
  v_attr_name    VARCHAR2(50);
  v_eff_desc     VARCHAR2(100);
  
  v_err_code     NUMBER;
  v_err_msg      VARCHAR2(500);

  CURSOR c_valid_attrib(i_attrib_name varchar2) IS
  select *
    FROM Jd1dta.dm_data_validation_attrib
   where v_attrib_name = i_attrib_name
     and c_status_flg = 'Y';
	 
  CURSOR attr1_cur IS 
    with data_1 as (
     select 'source' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt, 
            a.v_pol_status, 
            b.tfrdate,
            to_number(b.trrefnum) instno,
            b.prbilfdt,
            b.tfrdate || '-' || b.trrefnum || '-' || b.prbilfdt || '-' ||
            (select dsh.ig_dshcde from stagedbusr2.dsh_code_ref@DMSTGUSR2DBLINK dsh 
              where dsh.pj_dshcde = b.pshcde and dsh.pj_facthous = b.facthous) v_Val
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr2.pj_titdmgcolres@DMSTGUSR2DBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'staging' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status,
            b.tfrdate,
            to_number(b.trrefnum) instno,
            b.prbilfdt,
            b.tfrdate || '-' || b.trrefnum || '-' || b.prbilfdt || '-' || b.dshcde v_Val
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            stagedbusr.titdmgcolres@DMSTAGEDBLINK b
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
      union all
     select 'IG' data_from,
            a.v_policy_no,
            a.v_prd_cde, 
            a.d_pol_start_dt,
            a.v_pol_status, 
            b.tfrdate,
            c.instno,
            c.prbilfdt,
            b.tfrdate || '-' || c.instno || '-' || c.prbilfdt || '-' || b.dshcde v_Val
       from stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK a,
            Jd1dta.zcrhpf b, 
            Jd1dta.gbihpf c
      where a.v_pol_type = 'IND_MEMBER'
        and a.v_policy_no = b.chdrnum
        and b.chdrnum = c.chdrnum 
        and b.billno = c.billno 
        and b.jobnm = 'G1ZDCOLRES'
    )
    
  select a.v_policy_no,
         a.v_prd_cde, 
         a.d_pol_start_dt, 
         a.v_pol_status, 
         a.tfrdate,
         a.v_Val src_val,
         b.v_Val stg_val,
         c.v_Val ig_val
    from data_1 a,
         data_1 b,
         data_1 c
   where a.data_from = 'source'
     and b.data_from = 'staging'
     and c.data_from = 'IG'
     and a.v_policy_no = b.v_policy_no
     and a.tfrdate = b.tfrdate
     and a.instno = b.instno
     and a.prbilfdt = b.prbilfdt
     and a.v_policy_no = c.v_policy_no
     and a.tfrdate = c.tfrdate
     and a.instno = c.instno
     and a.prbilfdt = c.prbilfdt
     and (a.v_Val <> b.v_Val or b.v_Val <> c.v_Val)
   order by a.v_policy_no;	 
    
  attr1_data attr1_cur%rowtype;

BEGIN

  v_eff_desc  := 'Transfer Date';
  v_attr_name := 'POLICY_DISHONOR_DATA';
  for r1 in c_valid_attrib(v_attr_name) loop

    OPEN attr1_cur;
    
    LOOP
    
      FETCH attr1_cur INTO attr1_data;
      exit when attr1_cur%notfound;
      
      INSERT INTO Jd1dta.dm_pol_collres_recon_det
        (V_MODULE_NAME, V_ATTRIB_NAME, V_POLICY_NO, V_POL_STATUS, V_PROD_CDE, V_POL_COMMDT, 
         V_SRC_VAL, V_STG_VAL, V_IG_VAL, V_EFF_DATE, V_EFF_DESC, V_JOB_NAME, 
         V_BATCH_ID, V_SUMMARY_BATCH_ID, V_CREATED_BY, D_CREATED_ON)
      VALUES
        (v_module_name, v_attr_name, attr1_data.v_policy_no, attr1_data.v_pol_status, attr1_data.v_prd_cde, attr1_data.tfrdate, 
         attr1_data.src_val, attr1_data.stg_val, attr1_data.ig_val, attr1_data.tfrdate, v_eff_desc, v_job_name, 
         p_detail_batch_id, p_summary_batch_id, v_crtd_by, SYSDATE);

    END LOOP;

    CLOSE attr1_cur;

    COMMIT;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    v_err_code := SQLCODE;
    v_err_msg  := SQLERRM;

    Jd1dta.insert_error_log(v_err_code, v_err_msg, v_prog_name);
    dbms_output.put_line(v_err_code || ' - ' || v_err_msg);
        
END DM_COLRES_RECON_SET2;