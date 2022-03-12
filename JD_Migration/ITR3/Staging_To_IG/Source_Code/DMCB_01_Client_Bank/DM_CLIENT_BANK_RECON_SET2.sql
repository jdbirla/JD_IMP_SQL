create or replace Procedure Dm_Client_Bank_Recon_Set2(P_Detail_Batch_Id In Varchar2, P_Summary_Batch_Id In Varchar2) 
As
  /*
  **************************************************************************************************
  * Amendment History: Client Bank Reconcillation set 2
  * Date    Init      Tag   Decription
  * -----   -----     ---   ---------------------------------------------------------------------------
  * FEB5	vthakre2  CR2   ITR3 development
  **************************************************************************************************
  */
   ---- constants-----
    C_Module_Name      Constant Varchar2(50) := 'DM_Client_Bank_Recon_Set2';
    C_Created_By       Constant Varchar2(50) := 'JPAVTA';
    C_Job_Name         Constant Varchar2(50) := 'DM_Client_Bank_Recon_Set2';
    C_Filter_Modname       Constant Varchar2(50) := 'Client Bank';

    ---collection object
    R_Cb_Rcon  Typ_Rec_Cb_Recon2;
    T_Src Typ_Tbl_Cb_Recon2;
    T_Stg Typ_Tbl_Cb_Recon2;
    T_Ig  Typ_Tbl_Cb_Recon2;

    ----value to be validated
    V_Src_Val          Varchar2(1000);
    V_Stg_Val          Varchar2(1000);
    V_Ig_Val           Varchar2(1000);
    V_Mismatch         Boolean;

 --- types for data from source
 Type T_Cb_Src_Rec Is Record (
      V_Prd_Cde	Varchar2(10 Byte),
      V_Policy_No Varchar2(15 Char),
      V_Pol_Status	Char(4 Byte),
	  D_Pol_Start_Dt NUMBER(8,0),
      Refnum Varchar2(15 Char), 
      Currto Number(8,0), 
      Bankcd Varchar2(10 Char), 
      Branchcd Varchar2(10 Char), 
      Facthous Varchar2(2 Char), 
      Cardno Varchar2(20 Char),
      Bankaccdsc Varchar2(30 Char), 
      Bnkactyp Varchar2(4 Char)
     );
  Type T_Src_Cb_Tab Is Table Of T_Cb_Src_Rec;
  Cb_Src_Tab T_Src_Cb_Tab;

   --- types for data from stageDB
 Type T_Cb_Stg_Rec Is Record (
      V_Policy_No Varchar2(15 Char),
      V_Pol_Status	Char(4 Byte),
      Refnum Varchar2(15 Char), 
      Currto Number(8,0), 
      Bankcd Varchar2(10 Char), 
      Branchcd Varchar2(10 Char), 
      Facthous Varchar2(2 Char),  
      Cardno Varchar2(20 Char),
      Bankaccdsc Varchar2(30 Char), 
      Bnkactyp Varchar2(4 Char)
     );
  Type T_Stg_Cb_Tab Is Table Of T_Cb_Stg_Rec;
  Cb_Stg_Tab T_Stg_Cb_Tab;

  --- types for data from IG
 Type T_Cb_Ig_Rec Is Record (
      Currto Number(8,0), 
      Bankcd Varchar2(10 Char), 
      Branchcd Varchar2(10 Char), 
      Facthous Varchar2(2 Char), 
      Cardno Varchar2(20 Char), 
      Bankaccdsc Varchar2(30 Char), 
      Bnkactyp Varchar2(4 Char),
      Zentity  Varchar2(15 Char)
     );
  Type T_Ig_Cb_Tab Is Table Of T_Cb_Ig_Rec;
  Cb_Ig_Tab T_Ig_Cb_Tab;

 --- types for data from dm_data_validation_attrib
     Type Attr_R_Val Is Record (
       N_Attrib_Id     Number,
       C_Module_Name   Varchar2(50 Char),
       V_Attrib_Name   Varchar2(40 Char),
       V_Attrib_Desc   Varchar2(1000),
       C_Status_Flg    Char(1),
       D_Created_On    Date,
       C_Created_By    Varchar2(100)
     );
    Type Attr_R_Val_Tab Is Table Of Attr_R_Val;
    R_Attr Attr_R_Val_Tab;

  --- types for data to be validated
    Type Result_R_Val Is Record (
      Src_V_Prd_Cde	Varchar2(10 Byte),
      Src_V_Policy_No Varchar2(15 Char),
      Src_V_Pol_Status	Char(4 Byte), 
	  Src_D_Pol_Start_Dt NUMBER(8,0),
      Src_Currto Number(8,0), 
      Src_Bankcd Varchar2(10 Char), 
      Src_Branchcd Varchar2(10 Char), 
      Src_Facthous Varchar2(2 Char),  
      Src_Cardno Varchar2(20 Char),
      Src_Bankaccdsc Varchar2(30 Char), 
      Src_Bnkactyp Varchar2(4 Char),
      Stg_V_Policy_No Varchar2(15 Char),
      Stg_V_Pol_Status	Char(4 Byte), 
      Stg_Currto Number(8,0), 
      Stg_Bankcd Varchar2(10 Char), 
      Stg_Branchcd Varchar2(10 Char), 
      Stg_Facthous Varchar2(2 Char),  
      Stg_Cardno Varchar2(20 Char),
      Stg_Bankaccdsc Varchar2(30 Char), 
      Stg_Bnkactyp Varchar2(4 Char), 
      Ig_Currto Number(8,0), 
      Ig_Bankcd Varchar2(10 Char), 
      Ig_Branchcd Varchar2(10 Char), 
      Ig_Facthous Varchar2(2 Char), 
      Ig_Cardno Varchar2(20 Char), 
      Ig_Bankaccdsc Varchar2(30 Char), 
      Ig_Bnkactyp Varchar2(4 Char),
      Ig_Zentity  Varchar2(15 Char)
    );
    Type Result_R_Val_Tab Is Table Of Result_R_Val;
    R_Result Result_R_Val_Tab;

    Obj_Dm_Client_Bank_Recon_Det Jd1dta.Dm_Client_Bank_Recon_Det%Rowtype;
    P_Exitcode    Number;
    P_Exittext    Varchar2(2000);

Begin
   Select * Bulk Collect
   Into R_Attr
   From
   Jd1dta.Dm_Data_Validation_Attrib
   Where
   Trim(V_Module_Name) = C_Filter_Modname
   Order By
   N_Attrib_Id;

  Select Rcon.V_Prd_Cde, Rcon.V_Policy_No, Rcon.V_Pol_Status, Rcon.D_Pol_Start_Dt, Src.Refnum,Src.Currto,Src.Bankcd, 
  Src.Branchcd, Src.Facthous, Nvl(Trim(Src.Bankacckey), Trim(Src.Crdtcard)) As Cardno, Src.Bankaccdsc, Src.Bnkactyp
  Bulk Collect Into Cb_Src_Tab
  From Titdmgclntbank@Dmstgusr2dblink Src 
  Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
  On Substr(Src.Refnum,1,8) = Rcon.V_Policy_No;

  T_Src := Typ_Tbl_Cb_Recon2();
    T_Src.Extend(Cb_Src_Tab.Count);
    For Index_Cb_Tab In 1 .. Cb_Src_Tab.Count Loop
         R_Cb_Rcon := Typ_Rec_Cb_Recon2 (
                 Cb_Src_Tab(Index_Cb_Tab).V_Prd_Cde,
                 Cb_Src_Tab(Index_Cb_Tab).V_Policy_No
                ,Cb_Src_Tab(Index_Cb_Tab).V_Pol_Status
				,Cb_Src_Tab(Index_Cb_Tab).D_Pol_Start_Dt
                ,Cb_Src_Tab(Index_Cb_Tab).Refnum
                ,Cb_Src_Tab(Index_Cb_Tab).Currto
                ,Cb_Src_Tab(Index_Cb_Tab).Bankcd
                ,Cb_Src_Tab(Index_Cb_Tab).Branchcd
                ,Cb_Src_Tab(Index_Cb_Tab).Facthous
                ,Cb_Src_Tab(Index_Cb_Tab).Cardno
                ,Cb_Src_Tab(Index_Cb_Tab).Bankaccdsc
                ,Cb_Src_Tab(Index_Cb_Tab).Bnkactyp
                ,Null
                );
        T_Src(Index_Cb_Tab) := R_Cb_Rcon;
    End Loop;

  Select Rcon.V_Policy_No, Rcon.V_Pol_Status, Stg.Refnum,Stg.Currto,Stg.Bankcd, 
  Stg.Branchcd, Stg.Facthous, Nvl(Trim(Stg.Bankacckey), Trim(Stg.Crdtcard)) As Cardno, Stg.Bankaccdsc, Stg.Bnkactyp
  Bulk Collect Into Cb_Stg_Tab
  From Titdmgclntbank@Dmstagedblink Stg 
  Inner Join Dm_Policy_Recon@dmstgusr2dblink Rcon
  On Substr(Stg.Refnum,1,8) = Rcon.V_Policy_No;

  T_Stg := Typ_Tbl_Cb_Recon2();
    T_Stg.Extend(Cb_Stg_Tab.Count);
    For Index_Cb_Tab In 1 .. Cb_Stg_Tab.Count Loop
         R_Cb_Rcon := Typ_Rec_Cb_Recon2 (
                 Null,
                 Cb_Stg_Tab(Index_Cb_Tab).V_Policy_No
                ,Cb_Stg_Tab(Index_Cb_Tab).V_Pol_Status
				,Null
                ,Cb_Stg_Tab(Index_Cb_Tab).Refnum
                ,Cb_Stg_Tab(Index_Cb_Tab).Currto
                ,Cb_Stg_Tab(Index_Cb_Tab).Bankcd
                ,Cb_Stg_Tab(Index_Cb_Tab).Branchcd
                ,Cb_Stg_Tab(Index_Cb_Tab).Facthous
                ,Cb_Stg_Tab(Index_Cb_Tab).Cardno
                ,Cb_Stg_Tab(Index_Cb_Tab).Bankaccdsc
                ,Cb_Stg_Tab(Index_Cb_Tab).Bnkactyp
                ,Null
                );
        T_Stg(Index_Cb_Tab) := R_Cb_Rcon;
    End Loop;

  Select Clba.Currto, Substr(Clba.Bankkey,1,4) As Bankcd, Substr(Clba.Bankkey,8,10) As Branchcd, 
  Clba.Facthous, Nvl(Trim(Clba.Bankacckey),0) As Cardno, Clba.Bankaccdsc, Clba.Bnkactyp, 
  Paz.Zentity
  Bulk Collect Into Cb_Ig_Tab
  From Jd1dta.Clbapf Clba Inner Join Jd1dta.Pazdclpf Paz
  On Clba.Clntnum = Paz.Zigvalue
  Inner Join Dm_Policy_Recon@dmstgusr2dblink Polrec
  On Polrec.V_Policy_No = Substr(Paz.Zentity,1,8);

   T_Ig := Typ_Tbl_Cb_Recon2();
    T_Ig.Extend(Cb_Ig_Tab.Count);
    For Index_Cb_Tab In 1 .. Cb_Ig_Tab.Count Loop
         R_Cb_Rcon := Typ_Rec_Cb_Recon2 (
                 Null
                ,Null
                ,Null
                ,Null
				,Null
                ,Cb_Ig_Tab(Index_Cb_Tab).Currto
                ,Cb_Ig_Tab(Index_Cb_Tab).Bankcd
                ,Cb_Ig_Tab(Index_Cb_Tab).Branchcd
                ,Cb_Ig_Tab(Index_Cb_Tab).Facthous
                ,Cb_Ig_Tab(Index_Cb_Tab).Cardno
                ,Cb_Ig_Tab(Index_Cb_Tab).Bankaccdsc
                ,Cb_Ig_Tab(Index_Cb_Tab).Bnkactyp
                ,Cb_Ig_Tab(Index_Cb_Tab).Zentity
                );
        T_Ig(Index_Cb_Tab) := R_Cb_Rcon;
    End Loop;

    ----- merge src, stg and ig collections into result collection
    Select
    Src.V_Prd_Cde,
    Src.V_Policy_No,
	Src.V_Pol_Status,
	Src.D_Pol_Start_Dt,
    Src.Currto,
    Src.Bankcd,
    Src.Branchcd,
    Src.Facthous,
    Src.Cardno,
    Src.Bankaccdsc,
    Src.Bnkactyp,
    Stg.V_Policy_No,
	Stg.V_Pol_Status,
    Stg.Currto,
    Stg.Bankcd,
    Stg.Branchcd,
    Stg.Facthous,
    Stg.Cardno,
    Stg.Bankaccdsc,
    Stg.Bnkactyp,
    Ig.Currto,
    Ig.Bankcd,
    Ig.Branchcd,
    Ig.Facthous,
    Ig.Cardno,
    Ig.Bankaccdsc,
    Ig.Bnkactyp,
    Ig.Zentity
    Bulk Collect
    Into
         R_Result   
    From
         Table(T_Src) Src
    Left Join Table(T_Stg) Stg
         On Src.Refnum = Stg.Refnum
         And Rtrim(Src.Bankcd) = Rtrim(Stg.Bankcd)
         And Rtrim(Src.Branchcd) = Rtrim(Stg.Branchcd)
         And Src.Cardno = Stg.Cardno
    Left Join Table(T_Ig) Ig
          On Src.Refnum = Ig.Zentity
          And Rtrim(Src.Bankcd) = Rtrim(Ig.Bankcd)
          And Rtrim(Src.Branchcd) = Rtrim(Ig.Branchcd)
          And Src.Cardno = Rtrim(Ig.Cardno)
    Order By
        Src.V_Policy_No;

    --- insert into result table    
    For Index_R_Result In 1..R_Result.Count Loop
        For Index_R_Attr In 1..R_Attr.Count Loop
            V_Src_Val := Null;
            V_Stg_Val := Null;
            V_Ig_Val  := Null;

         If Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_CURRTO' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Currto;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Currto;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Currto;
          Elsif (Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_BANKACKEY') Or
                (Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_CRDTCARD') Then             
                   V_Src_Val  := R_Result(Index_R_Result).Src_Cardno;
                   V_Stg_Val  := R_Result(Index_R_Result).Stg_Cardno;
                   V_Ig_Val  := R_Result(Index_R_Result).Ig_Cardno;
          Elsif Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_FACTHOUS' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Facthous;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Facthous;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Facthous;
          Elsif Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_BANKCD' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Bankcd;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Bankcd;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Bankcd;
          Elsif Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_BRANCHCD' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Branchcd;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Branchcd;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Branchcd;
          Elsif Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_BANKACCDSC' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Bankaccdsc;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Bankaccdsc;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Bankaccdsc;
          Elsif Trim(R_Attr(Index_R_Attr).V_Attrib_Name) = 'POLICY_BNKACTYP' Then
               V_Src_Val := R_Result(Index_R_Result).Src_Bnkactyp;
               V_Stg_Val := R_Result(Index_R_Result).Stg_Bnkactyp;
               V_Ig_Val  := R_Result(Index_R_Result).Ig_Bnkactyp;
          End If;

          If (Trim(V_Src_Val) = Trim(V_Stg_Val)) And (Trim(V_Src_Val) = Trim(V_Ig_Val)) Then
               V_Mismatch := False;
            Else
               V_Mismatch := True;
          End If;

           If V_Mismatch = True Then
             Insert Into Jd1dta.Dm_Client_Bank_Recon_Det (
                                    V_Batch_Id
                                   ,V_Policy_No
                                   ,V_Prod_Cde
                                   ,V_Pol_Commdt
                                   ,V_Attrib_Name
                                   ,V_Pol_Status
                                   ,V_Module_Name
                                   ,V_Eff_Date
                                   ,V_Eff_Desc
                                   ,V_Src_Val
                                   ,V_Stg_Val
                                   ,V_Ig_Val
                                   ,V_Summary_Batch_Id
                                   ,D_Created_On
                                   ,V_Created_By
                                   ,V_Job_Name
                                   )
                            Values (
                                   P_Detail_Batch_Id
                                  ,R_Result(Index_R_Result).Src_V_Policy_No
                                  ,R_Result(Index_R_Result).Src_V_Prd_Cde
                                  ,''
                                  ,R_Attr(Index_R_Attr).V_Attrib_Name
                                  ,R_Result(Index_R_Result).Src_V_Pol_Status
                                  ,R_Attr(Index_R_Attr).C_Module_Name
                                  ,R_Result(Index_R_Result).Src_D_Pol_Start_Dt
                                  ,'Policy Start Date'
                                  ,V_Src_Val
                                  ,V_Stg_Val
                                  ,V_Ig_Val
                                  ,P_Summary_Batch_Id
                                  ,Sysdate
                                  ,C_Created_By
                                  ,C_Job_Name
                                   );
           End If;
        End Loop;
    End Loop;
    Commit;

	EXCEPTION
    WHEN OTHERS THEN
    P_Exitcode := Sqlcode;
    P_Exittext := ' Client Bank Reconciliation ' || ' ' ||
                    Dbms_Utility.Format_Error_Backtrace || ' - ' || Sqlerrm;    

    Insert_Error_Log (
                  In_Error_Code  =>  P_Exitcode
                 ,In_Error_Message  => P_Exittext
                 ,In_Prog  => C_Module_Name
                 );

   Raise_Application_Error(-20001, P_Exitcode || P_Exittext);
End Dm_Client_Bank_Recon_Set2;