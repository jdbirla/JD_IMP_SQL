create or replace Procedure recon_G1ZDCLTBNK(I_Schedulenumber In Varchar2) 
IS
  /*
  **************************************************************************************************
  * Amendment History: Client Bank Reconcillation set 1
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * FEB9	  VINAY  CR2   ITR3 development
  **************************************************************************************************
  */
    Obj_Recon_Master Recon_Master%Rowtype;
    ---- constants-----
    v_module_name   Constant Varchar2(50) := 'DMCB - Client Bank';
    v_src_stg_flg varchar2(1) := 'N';
    V_Stg_Ig_Flg  Varchar2(1) := 'N';
    V_Final_Flg   Varchar2(1) := 'N';
    C_PASS constant varchar2(4) := 'PASS';
    C_FAIL constant varchar2(4) := 'FAIL';
    
    V_Count_Src Varchar2(10);
    V_Count_Stg Varchar2(10);
    V_Count_Ig  Varchar2(10);   
    P_Exitcode    Number;
    P_Exittext    Varchar2(2000);
        
Begin
  -- Count Based on Credit Card Policies (Facthous = '99'): START
  Begin
    Select Count(*)
    Into V_Count_Src
    From Titdmgclntbank@Dmstgusr2dblink Src 
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
    On Substr(Src.Refnum,1,8) = Rcon.V_Policy_No
    Where Src.Facthous = '99';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_src := 0;
    End;
    
  Begin    
    Select Count(*)
    Into V_Count_Stg
    From Titdmgclntbank@Dmstagedblink Stg 
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
    On Substr(Stg.Refnum,1,8) = Rcon.V_Policy_No
    Where Stg.Facthous = '99';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_stg := 0;
    End;
  
  Begin  
    Select Count(*)
    Into V_Count_Ig
    From Jd1dta.Clbapf Clba Inner Join Jd1dta.Pazdclpf Paz
    On Clba.Clntnum = Paz.Zigvalue
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Polrec
    On Polrec.V_Policy_No = Substr(Paz.Zentity,1,8)
    Where Clba.Facthous = '99';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_ig := 0;
    End;
        
    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_RECON_MASTER.module_name     := v_module_name;
    Obj_Recon_Master.Rundate         := Sysdate;
    obj_recon_master.recon_query_id  := 'CB01';
    Obj_Recon_Master.Group_Clause    := '';
    obj_recon_master.where_clause    := 'Facthous = 99';
    Obj_Recon_Master.Validation_Type := 'COUNT';
    Obj_Recon_Master.Source_Value    := V_Count_Src;
    Obj_Recon_Master.Staging_Value   := V_Count_Stg;
    Obj_Recon_Master.Ig_Value        := V_Count_Ig;
    obj_recon_master.query_desc      := 'SOURCE: [Titdmgclntbank] , STAGE: [Titdmgclntbank] , IG: [Clbapf]';
    
    If(v_count_stg = V_Count_Ig) Then
      V_Stg_Ig_Flg := 'Y';
    End if;
    
    If(V_Count_Src = V_Count_Stg) Then
      V_Src_Stg_Flg := 'Y';
    End If;
    
    if (v_src_stg_flg = 'Y' AND v_stg_ig_flg = 'Y') then
        V_Final_Flg := 'Y';
    end if;
  
    If (V_Final_Flg = 'Y') Then
       Obj_Recon_Master.status := C_PASS;
    else
       Obj_Recon_Master.Status := C_Fail;
    End If;
    
    --  Insert Into Recon_Master Values
    Insert Into Jd1dta.Recon_Master Values Obj_Recon_Master;
    Commit;
-- Count Based on Credit Card Policies (Facthous = '99'): END

-- Count Based on Client Bank Policies (Facthous = '98'): START
    V_Count_Src := 0;
    V_Count_Stg := 0;
    V_Count_Ig := 0;
    v_src_stg_flg := 'N';
    V_Stg_Ig_Flg := 'N';
    V_Final_Flg := 'N';
    Obj_Recon_Master := Null;
    
  Begin
    Select Count(*)
    Into V_Count_Src
    From Titdmgclntbank@Dmstgusr2dblink Src 
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
    On Substr(Src.Refnum,1,8) = Rcon.V_Policy_No
    Where Src.Facthous = '98';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_src := 0;
    End;
    
  Begin    
    Select Count(*)
    Into V_Count_Stg
    From Titdmgclntbank@Dmstagedblink Stg 
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
    On Substr(Stg.Refnum,1,8) = Rcon.V_Policy_No
    Where Stg.Facthous = '98';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_stg := 0;
    End;
  
  Begin  
    Select Count(*)
    Into V_Count_Ig
    From Jd1dta.Clbapf Clba Inner Join Jd1dta.Pazdclpf Paz
    On Clba.Clntnum = Paz.Zigvalue
    Inner Join Dm_Policy_Recon@dmstgusr2dblink Polrec
    On Polrec.V_Policy_No = Substr(Paz.Zentity,1,8)
    Where Clba.Facthous = '98';
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_count_ig := 0;
    End;
        
    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_RECON_MASTER.module_name     := v_module_name;
    Obj_Recon_Master.Rundate         := Sysdate;
    obj_recon_master.recon_query_id  := 'CB02';
    Obj_Recon_Master.Group_Clause    := '';
    obj_recon_master.where_clause    := 'Facthous = 98';
    Obj_Recon_Master.Validation_Type := 'COUNT';
    Obj_Recon_Master.Source_Value    := V_Count_Src;
    Obj_Recon_Master.Staging_Value   := V_Count_Stg;
    Obj_Recon_Master.Ig_Value        := V_Count_Ig;
    obj_recon_master.query_desc      := 'SOURCE: [Titdmgclntbank] , STAGE: [Titdmgclntbank] , IG: [Clbapf]';
    
    If(v_count_stg = V_Count_Ig) Then
      v_stg_ig_flg := 'Y';
    End if;
    
    If(V_Count_Src = V_Count_Stg) Then
      V_Src_Stg_Flg := 'Y';
    End If;
    
    if (v_src_stg_flg = 'Y' AND v_stg_ig_flg = 'Y') then
        v_final_flg := 'Y';
    end if;
  
    If (V_Final_Flg = 'Y') Then
       obj_recon_master.status := C_PASS;
    else
       Obj_Recon_Master.Status := C_Fail;
    End If;
    
    --  Insert Into Recon_Master Values
    Insert Into Jd1dta.Recon_Master Values Obj_Recon_Master;
    Commit;
-- Count Based on Client Bank Policies (Facthous = '98'): END

 EXCEPTION
    WHEN OTHERS THEN
    P_Exitcode := Sqlcode;
    p_exittext := 'DMCB - Client Bank' || ' ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;    
   raise_application_error(-20001, p_exitcode || p_exittext);  
End recon_G1ZDCLTBNK;