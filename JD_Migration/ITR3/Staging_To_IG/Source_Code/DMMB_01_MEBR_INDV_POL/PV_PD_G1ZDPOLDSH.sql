/**************************************************************************************************************************
  * File Name        : PV_PD_G1ZDPOLDSH
  * Author           : Abhishek Gupta
  * Creation Date    : August 10 , 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure for post migration validation
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: MB01 Dishonor
  * Date    Init   Tag   Decription
  * -----   ----   ----   ---------------------------------------------------------------------------
  * MMMDD   XXX    DHXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0810    ABG    DH1   New developed in PA
  
  ********************************************************************************************************************************/

create or replace procedure        PV_PD_G1ZDPOLDSH(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALPOLDSHCHECK                                               
cursor  C_ZUCLPF is
select OLDPOLNUM from Jd1dta.DMIGTITDMGMBRINDP3 A where not EXISTS (
  select 1
  from ZUCLPF B
  where
 trim(B.CHDRNUM) = trim(A.OLDPOLNUM)
  );
 cursor  C_PAZDPDPF is
select OLDPOLNUM from Jd1dta.DMIGTITDMGMBRINDP3 A where not EXISTS (
  select 1
  from Jd1dta.PAZDPDPF B
  where
 trim(B.OLDCHDRNUM) = trim(A.OLDPOLNUM)
  );
  
   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin
  
 FOR REC_ZUCLPF IN C_ZUCLPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_ZUCLPF.OLDPOLNUM;    
        obj_DMPVALPF.reftab := 'ZUCLPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated policy';    
        obj_DMPVALPF.erorfld  := 'OLDPOLNUM'; 
        obj_DMPVALPF.fldvalue:= REC_ZUCLPF.OLDPOLNUM; 
        obj_DMPVALPF.valdno:= 'VALPOLDSHCHECK:1'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
    FOR REC_PAZDPDPF IN C_PAZDPDPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_PAZDPDPF.OLDPOLNUM;    
        obj_DMPVALPF.reftab := 'PAZDPDPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated policy';    
        obj_DMPVALPF.erorfld  := 'OLDPOLNUM'; 
        obj_DMPVALPF.fldvalue:= REC_PAZDPDPF.OLDPOLNUM; 
        obj_DMPVALPF.valdno:= 'VALPOLDSHCHECK:2'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
		 idx := DMPVALPF_list.first;
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT  /*+ APPEND_VALUES */    INTO Jd1dta.VIEW_DM_DMPVALPF VALUES DMPVALPF_list (idx);

  END IF;
   
  DMPVALPF_list.delete;
   DMPVALPFindex  := 0;
commit;
end PV_PD_G1ZDPOLDSH;